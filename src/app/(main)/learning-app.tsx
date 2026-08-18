"use client";

import { useCallback, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { buildDeck, getProgress, shuffle, type ProgressMap } from "@/features/quiz/lib/selection";
import {
  type UserGoal,
  type Textbook,
  type ExamGroup,
  type SectionQuestionRef,
  weakReviewPool,
  isSpeakFirstSubject,
} from "@/features/quiz/lib/stats";
import { useNow } from "@/features/quiz/hooks/use-now";
import { useScreen } from "@/features/quiz/hooks/use-screen";
import { useProgress } from "@/features/quiz/hooks/use-progress";
import { useMenuSettings } from "@/features/quiz/hooks/use-menu-settings";
import { useQuizSession } from "@/features/quiz/hooks/use-quiz-session";
import { useExamGoal } from "@/features/quiz/hooks/use-exam-goal";
import { useTextbooks } from "@/features/quiz/hooks/use-textbooks";
import { useCsvExport } from "@/features/quiz/hooks/use-csv-export";
import { useFsrsBackfill } from "@/features/quiz/hooks/use-fsrs-backfill";
import { useReadiness } from "@/features/quiz/hooks/use-readiness";
import { GoalScreen } from "@/features/quiz/screens/goal-screen";
import { MenuScreen } from "@/features/quiz/screens/menu-screen";
import { ExportScreen } from "@/features/quiz/screens/export-screen";
import { AnalysisScreen } from "@/features/quiz/screens/analysis-screen";
import { DoneScreen } from "@/features/quiz/screens/done-screen";
import { QuizScreen } from "@/features/quiz/screens/quiz-screen";
import { usePageHeader, useCurrentSubject } from "@/shared/components/app-shell";
import type { WeeklyBar } from "@/features/quiz/components/dashboard-parts";
import type { TrendDay } from "@/features/quiz/components/trend-card";

export type { WeeklyBar } from "@/features/quiz/components/dashboard-parts";

interface Props {
  userId: string;
  subjects: { slug: string; name: string }[];
  currentSubjectSlug: string;
  subjectName: string;
  examGroups: ExamGroup[];
  // 分野名 → 表示順。examSections はこれと examQuestions から組み立てる。
  sectionSort: Record<string, number>;
  categories: { id: string; name: string; color: string }[];
  questions: QuizQuestion[];
  // 現在の試験区分に属する全セットの問題（横断の苦手演習・分析用）。
  examQuestions: QuizQuestion[];
  // examQuestions の各問がどのセット(slug)由来か（横断演習の記録・表示用）。
  examQuestionSlug: Record<string, string>;
  initialProgress: ProgressMap;
  // 試験区分ごとの試験日（DB: user_exam_goals）。サーバから初期値を受け取る。
  goalExamKey: string;
  examName: string;
  initialGoal: UserGoal | null;
  // 試験区分ごとの教科書リンク（DB: user_textbooks）。
  initialTextbooks: Textbook[];
  dailyCapacity: number;
  // 連続学習日数と直近7日の解答実績（ダッシュボードの表示専用）。
  streak: number;
  weekly: WeeklyBar[];
  // 推移グラフ（この試験区分の日別 解答/正答/確信度）
  trendDays: TrendDay[];
  todayKey: string;
  // サイドバーから ?screen= で直接開かれた画面。
  requestedScreen?: string;
}

export function LearningApp({
  userId,
  subjects,
  currentSubjectSlug,
  subjectName,
  examGroups,
  sectionSort,
  categories,
  questions,
  examQuestions,
  examQuestionSlug,
  initialProgress,
  goalExamKey,
  examName,
  initialGoal,
  initialTextbooks,
  dailyCapacity,
  streak,
  weekly,
  trendDays,
  todayKey,
  requestedScreen,
}: Props) {
  const router = useRouter();
  const now = useNow();
  const { screen, setScreen } = useScreen(requestedScreen);
  // 分野別 苦手マップで開いている分野（分析画面だけのローカル表示状態）
  const [expandedSection, setExpandedSection] = useState<string | null>(null);

  // トップバーの見出しは画面ごとに切り替える（シェルはレイアウト側にある）。
  const header =
    screen === "analysis"
      ? { t: "苦手分析", s: `${examName} ・ 全セット横断`, nav: "/?screen=analysis" }
      : screen === "export"
        ? { t: "書き出し", s: `${subjectName} の解答データを CSV に`, nav: "/?screen=export" }
        : screen === "goal"
          ? { t: "試験日を設定", s: examName, nav: "/" }
          : screen === "quiz"
            ? { t: `${subjectName} ・ 演習中`, s: "", nav: "/" }
            : screen === "done"
              ? { t: "おつかれさま", s: "このセッションの結果", nav: "/" }
              : {
                  t: "ダッシュボード",
                  s: `${examName} の状況（トップバーで「すべて」に戻せます）`,
                  nav: "/",
                };
  usePageHeader(header.t, header.s, header.nav);
  useCurrentSubject(currentSubjectSlug, subjectName);

  // 問題集ピッカーは試験単位に折りたたみ、1試験だけ展開する（学習中の試験を初期展開）。
  const currentExamKey = useMemo(
    () => examGroups.find((g) => g.sets.some((s) => s.slug === currentSubjectSlug))?.examKey ?? null,
    [examGroups, currentSubjectSlug]
  );

  const { progressMap, persist, recordAnswer } = useProgress({
    userId,
    initialProgress,
    examQuestionSlug,
    currentSubjectSlug,
  });

  const menu = useMenuSettings({ categories, questions, progressMap, now, currentExamKey });

  // 「問題 × 分野(カテゴリ)」カタログ。examQuestions から導出するのでサーバから運ばない。
  const examSections = useMemo<SectionQuestionRef[]>(
    () =>
      examQuestions.map((q) => ({
        id: q.id,
        slug: examQuestionSlug[q.id] ?? "",
        section: q.category_name,
        color: q.category_color,
        sort: sectionSort[q.category_name] ?? 0,
      })),
    [examQuestions, examQuestionSlug, sectionSort]
  );

  // Speak-First 科目か（横断苦手デッキでは問題ごとに由来セットで判定）
  const isSpeakFirstQ = (q: QuizQuestion) =>
    isSpeakFirstSubject(examQuestionSlug[q.id] ?? currentSubjectSlug);

  // 現在セット以外の問題は初期表示では本文だけを持っている（解説だけで数百KBあるため）。
  // 出題直前に、選択肢が空のものだけまとめて取り直す。
  const hydrate = useCallback(async (qs: QuizQuestion[]): Promise<QuizQuestion[]> => {
    const missing = qs.filter((q) => q.options.length === 0);
    if (missing.length === 0) return qs;
    try {
      const res = await fetch("/api/questions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ids: missing.map((q) => q.id) }),
      });
      if (!res.ok) return qs;
      const { questions: full } = (await res.json()) as { questions: QuizQuestion[] };
      const byId = new Map(full.map((q) => [q.id, q]));
      return qs.map((q) => byId.get(q.id) ?? q);
    } catch {
      // 取得に失敗しても本文だけで先へ進める（選択肢が出ないので事故には気づける）
      return qs;
    }
  }, []);

  const session = useQuizSession({
    screen,
    setScreen,
    questions,
    progressMap,
    persist,
    recordAnswer,
    recallMode: menu.recallMode,
    isSpeakFirstQ,
    hydrate,
  });

  const examGoal = useExamGoal({ userId, goalExamKey, initialGoal });
  const textbooks = useTextbooks({ userId, goalExamKey, initialTextbooks });
  const csv = useCsvExport({ questions, progressMap, now, enabled: screen === "export" });
  const { backfilling, backfillMsg, runBackfill } = useFsrsBackfill();
  const { readiness, passEstimate } = useReadiness({
    examSections,
    examQuestions,
    progressMap,
    goal: examGoal.goal,
    now,
    dailyCapacity,
    goalExamKey,
  });

  // 試験区分の全セットを横断した「間違えた/苦手」問題プール（弱点順）。
  const examWeakPool = useMemo(
    () => weakReviewPool(examQuestions, progressMap),
    [examQuestions, progressMap]
  );
  // 試験区分の全セットを横断した「一度も解答していない」問題プール（順不同でシャッフル済み）。
  const examFirstTimePool = useMemo(
    () =>
      shuffle(
        examQuestions.filter((q) => {
          const p = getProgress(progressMap, q.id);
          return !p.excluded && p.correct_count + p.wrong_count === 0;
        })
      ),
    [examQuestions, progressMap]
  );
  // この試験区分が複数セットか（横断であることを UI で示すかの判定）。
  const isMultiSet = useMemo(
    () => (examGroups.find((g) => g.examKey === currentExamKey)?.sets.length ?? 1) > 1,
    [examGroups, currentExamKey]
  );

  // force=true で休眠中も含める（全問休眠時の脱出口・トグルの両方から使う）。
  const startQuiz = (force = false) => {
    session.enterQuiz(
      buildDeck({
        questions,
        progressMap,
        selectedCategoryIds: menu.selCats,
        count: menu.count,
        mode: menu.mode,
        now,
        includeResting: force || menu.includeResting,
      })
    );
  };

  // テーマ横断演習: 試験区分の全セットから、選んだテーマ（分野名）の問題だけを
  // 集めて出題する。進捗の記録は examQuestionSlug 経由で由来セットに帰属する。
  const startThemeQuiz = (names: Set<string>, count: number, force = false) => {
    const pool = examQuestions.filter((q) => names.has(q.category_name));
    session.enterQuiz(
      buildDeck({
        questions: pool,
        progressMap,
        selectedCategoryIds: new Set(pool.map((q) => q.category_id)),
        count,
        mode: menu.mode,
        now,
        includeResting: force || menu.includeResting,
      })
    );
  };

  const switchSubject = (slug: string) => {
    router.push(slug ? `/?subject=${slug}` : "/");
  };

  if (now === 0) {
    return (
      <div className="flex justify-center pt-32 text-xs text-[#555e70]">
        読み込み中
      </div>
    );
  }

  // セット横断の演習は、出題直前に問題本体を取りに行く。その待ち時間の目印。
  const loadingOverlay = session.deckLoading ? (
    <div className="fixed inset-0 z-[900] flex items-center justify-center bg-[#0f1117]/70">
      <div className="rounded-xl border border-border bg-card px-5 py-3 text-xs text-muted">
        出題を準備しています…
      </div>
    </div>
  ) : null;

  if (screen === "goal") {
    return (
      <GoalScreen
        examName={examName}
        goal={examGoal.goal}
        goalDraft={examGoal.goalDraft}
        setGoalDraft={examGoal.setGoalDraft}
        saveGoal={examGoal.saveGoal}
        clearGoal={examGoal.clearGoal}
        setScreen={setScreen}
      />
    );
  }

  if (screen === "menu") {
    return (
      <>
      <MenuScreen
        subjectName={subjectName}
        subjects={subjects}
        currentSubjectSlug={currentSubjectSlug}
        examGroups={examGroups}
        examName={examName}
        questions={questions}
        categories={categories}
        progressMap={progressMap}
        now={now}
        dailyCapacity={dailyCapacity}
        goal={examGoal.goal}
        readiness={readiness}
        passEstimate={passEstimate}
        menu={menu}
        textbooks={textbooks}
        examWeakPool={examWeakPool}
        examFirstTimePool={examFirstTimePool}
        isMultiSet={isMultiSet}
        examQuestions={examQuestions}
        examSections={examSections}
        startThemeQuiz={startThemeQuiz}
        setScreen={setScreen}
        startQuiz={startQuiz}
        startReview={session.startReview}
        switchSubject={switchSubject}
        router={router}
        streak={streak}
        weekly={weekly}
        trendDays={trendDays}
        todayKey={todayKey}
      />
      {loadingOverlay}
      </>
    );
  }

  if (screen === "export") {
    return (
      <ExportScreen
        questions={questions}
        progressMap={progressMap}
        currentSubjectSlug={currentSubjectSlug}
        csv={csv}
        setScreen={setScreen}
      />
    );
  }

  if (screen === "analysis") {
    return (
      <>
      <AnalysisScreen
        examSections={examSections}
        progressMap={progressMap}
        examGroups={examGroups}
        currentExamKey={currentExamKey}
        subjectName={subjectName}
        examQuestions={examQuestions}
        examQuestionSlug={examQuestionSlug}
        isMultiSet={isMultiSet}
        expandedSection={expandedSection}
        setExpandedSection={setExpandedSection}
        startReview={session.startReview}
        backfilling={backfilling}
        backfillMsg={backfillMsg}
        runBackfill={runBackfill}
        setScreen={setScreen}
      />
      {loadingOverlay}
      </>
    );
  }

  if (screen === "done") {
    return (
      <>
      <DoneScreen
        session={session}
        questions={questions}
        progressMap={progressMap}
        examWeakPool={examWeakPool}
        setScreen={setScreen}
      />
      {loadingOverlay}
      </>
    );
  }

  // ── QUIZ ──────────────────────────────────────────────────────────────
  return (
    <QuizScreen
      session={session}
      progressMap={progressMap}
      persist={persist}
      isSpeakFirstQ={isSpeakFirstQ}
    />
  );
}
