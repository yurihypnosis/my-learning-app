"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import {
  type ExplanationData,
  type Progress,
  type QuizMode,
  type QuizQuestion,
} from "@/lib/quiz/types";
import {
  buildDeck,
  eligibleQuestions,
  getProgress,
  isResting,
  shuffleOptions,
  totalCorrect,
  totalWrong,
  type ProgressMap,
} from "@/lib/quiz/selection";
import { buildCSV, downloadCSV, type ExportMode } from "@/lib/quiz/csv";
import {
  type UserGoal,
  type Textbook,
  type ExamGroup,
  type SectionQuestionRef,
  calcMasteryStats,
  analyzeSections,
  sectionOverview,
  weakReviewPool,
} from "@/lib/quiz/stats";
import { type Card, gradeFromAnswer, review } from "@/lib/quiz/fsrs";
import {
  type Readiness,
  type Verdict,
  computeReadiness,
  passLineFor,
  retentionEstimate,
} from "@/lib/quiz/readiness";

// 「苦手だけ演習」1セッションの上限。弱点順に上位から出す（多すぎる一括を避ける）。
const WEAK_SESSION_MAX = 30;

const VERDICT_META: Record<Verdict, { label: string; color: string }> = {
  passed: { label: "合格圏内", color: "#22c55e" },
  "on-track": { label: "間に合う", color: "#22c55e" },
  tight: { label: "ギリギリ", color: "#f59e0b" },
  "at-risk": { label: "危険", color: "#ef4444" },
  "no-date": { label: "", color: "#8892a4" },
};

function daysUntilDate(dateStr: string, nowMs: number): number {
  const target = new Date(dateStr + "T00:00:00");
  if (Number.isNaN(target.getTime())) return 0;
  const today = new Date(nowMs);
  today.setHours(0, 0, 0, 0);
  return Math.round((target.getTime() - today.getTime()) / 86_400_000);
}

// 進捗行 → FSRS カード。列が無い/未学習なら new。
function cardFromProgress(p: Progress): Card {
  return {
    stability: p.fsrs_stability ?? 0,
    difficulty: p.fsrs_difficulty ?? 0,
    reps: p.fsrs_reps ?? 0,
    lapses: p.fsrs_lapses ?? 0,
    lastReview: p.fsrs_last_review ?? null,
    due: p.fsrs_due ?? null,
    state: p.fsrs_state === "review" ? "review" : "new",
  };
}

// 1 解答分の FSRS 更新を Progress の部分更新として返す。
function fsrsFields(
  cur: Progress,
  isCorrect: boolean,
  conf: number | null,
  nowMs: number
): Partial<Progress> {
  const card = review(cardFromProgress(cur), gradeFromAnswer(isCorrect, conf), nowMs);
  return {
    fsrs_stability: card.stability,
    fsrs_difficulty: card.difficulty,
    fsrs_due: card.due,
    fsrs_last_review: card.lastReview,
    fsrs_reps: card.reps,
    fsrs_lapses: card.lapses,
    fsrs_state: card.state,
  };
}

type Screen = "menu" | "quiz" | "done" | "analysis" | "export" | "goal";
type SessionResult = { correct: boolean; category: string; color: string };
// クイズ中の1問ごとの解答状態スナップショット（前後移動時の復元用）
type QState = {
  picked: number | null;
  multiSelected: number[];
  answered: boolean;
  confidence: number | null;
  choicesHidden: boolean;
};

const CONFIDENCE_LABELS = ["確信あり", "迷った", "勘"] as const;
const CONFIDENCE_COLORS = ["#22c55e", "#f59e0b", "#ef4444"] as const;

function arraysEqual(a: number[], b: number[]): boolean {
  return a.length === b.length && a.every((v, i) => v === b[i]);
}

function RichExplanation({ data }: { data: ExplanationData }) {
  const lbl = "mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]";
  return (
    <div className="space-y-5 text-sm leading-7 text-[#c0c8d8]">
      <div>
        <p className={lbl}>何を問われているか</p>
        <p>{data.asked}</p>
      </div>

      {data.point && (
        <div className="border-l-2 border-[#3b82f6]/60 pl-3.5">
          <p className={lbl}>決め手</p>
          <p className="text-[15px] text-[#e8eaf0]">{data.point}</p>
        </div>
      )}

      {data.kid && (
        <div>
          <p className={lbl}>ざっくり言うと</p>
          <p>{data.kid}</p>
        </div>
      )}

      {data.eg && (
        <div>
          <p className={lbl}>たとえると</p>
          <p>{data.eg}</p>
        </div>
      )}

      {data.terms && data.terms.length > 0 && (
        <div>
          <p className={lbl}>キーワード</p>
          <div className="space-y-2">
            {data.terms.map(([term, def], i) => (
              <div key={i} className="flex flex-wrap gap-x-2">
                <span className="font-semibold text-[#e8eaf0]">{term}</span>
                <span className="text-[#8892a4]">—</span>
                <span className="text-[#8892a4]">{def}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div>
        <p className={lbl}>考え方</p>
        <p>{data.think}</p>
      </div>

      {data.snippet && (
        <div>
          <p className={lbl}>正しい書き方</p>
          <pre className="overflow-x-auto rounded-xl bg-[#141720] px-4 py-3.5 font-mono text-xs leading-6 text-[#8892a4]">
            <code>{data.snippet}</code>
          </pre>
        </div>
      )}

      {data.vs && (
        <div>
          <p className={lbl}>混同ポイント</p>
          <p>{data.vs}</p>
        </div>
      )}

      {data.why_asked && (
        <div>
          <p className={lbl}>なぜ問われるか</p>
          <p>{data.why_asked}</p>
        </div>
      )}

      {data.usecase && (
        <div className="rounded-xl border border-[#1e2530] bg-[#12151d] px-4 py-3">
          <p className={lbl}>使いどころ・どう役立つか</p>
          <p>{data.usecase}</p>
        </div>
      )}

      {data.opt && data.opt.length > 0 && (
        <div>
          <p className={lbl}>選択肢の解説</p>
          <div className="space-y-2">
            {data.opt.map((o, i) => (
              <div key={i} className="flex gap-3">
                <span className="w-4 shrink-0 font-semibold text-[#555e70]">{"ABCD"[i]}.</span>
                <span>{o}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

interface Props {
  userId: string;
  subjects: { slug: string; name: string }[];
  currentSubjectSlug: string;
  subjectName: string;
  examGroups: ExamGroup[];
  examSections: SectionQuestionRef[];
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
}

// 最終学習日を「今日 / 昨日 / N日前 / M/D」の短い表記にする。
function fmtLastStudied(iso: string | null, now: number): string {
  if (!iso) return "未学習";
  const t = Date.parse(iso);
  if (Number.isNaN(t)) return "未学習";
  const days = Math.floor((now - t) / 86_400_000);
  if (days <= 0) return "今日";
  if (days === 1) return "昨日";
  if (days < 7) return `${days}日前`;
  const d = new Date(iso);
  return `${d.getMonth() + 1}/${d.getDate()}`;
}

const accColor = (acc: number, answers: number): string =>
  answers === 0 ? "#555e70" : acc >= 0.7 ? "#22c55e" : acc >= 0.5 ? "#f59e0b" : "#ef4444";

// 得点率＋演習量・最終学習日をまとめた右端の統計セル（試験行・セット行で共用）。
function StatCell({
  accuracy,
  answers,
  attempted,
  total,
  last,
  now,
}: {
  accuracy: number;
  answers: number;
  attempted: number;
  total: number;
  last: string | null;
  now: number;
}) {
  return (
    <span className="shrink-0 text-right leading-tight">
      <span
        className="block font-mono text-[11px] tabular-nums"
        style={{ color: accColor(accuracy, answers) }}
      >
        {answers === 0 ? "—" : `${Math.round(accuracy * 100)}%`}
      </span>
      <span className="block text-[9px] text-[#555e70]">
        {attempted}/{total} · {fmtLastStudied(last, now)}
      </span>
    </span>
  );
}

export function LearningApp({
  userId,
  subjects,
  currentSubjectSlug,
  subjectName,
  examGroups,
  examSections,
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
}: Props) {
  const router = useRouter();
  const [now, setNow] = useState(0);
  const [progressMap, setProgressMap] = useState<ProgressMap>(initialProgress);
  const [screen, setScreen] = useState<Screen>("menu");
  const [pickerOpen, setPickerOpen] = useState(false);
  const [expandedSection, setExpandedSection] = useState<string | null>(null);
  const [backfilling, setBackfilling] = useState(false);
  const [backfillMsg, setBackfillMsg] = useState("");
  // 問題集ピッカーは試験単位に折りたたみ、1試験だけ展開する（学習中の試験を初期展開）。
  const currentExamKey = useMemo(
    () => examGroups.find((g) => g.sets.some((s) => s.slug === currentSubjectSlug))?.examKey ?? null,
    [examGroups, currentSubjectSlug]
  );
  const [expandedExam, setExpandedExam] = useState<string | null>(currentExamKey);
  const [selCats, setSelCats] = useState<Set<string>>(
    () => new Set(categories.map((c) => c.id))
  );
  const [count, setCount] = useState(10);
  const [mode, setMode] = useState<QuizMode>("shuffle");
  const [recallMode, setRecallMode] = useState(false);
  // 休眠中（復習日がまだ来ていない）の問題も出題対象に含めるか。手動復習用。
  const [includeResting, setIncludeResting] = useState(false);
  const [deck, setDeck] = useState<QuizQuestion[]>([]);
  const [idx, setIdx] = useState(0);

  const [picked, setPicked] = useState<number | null>(null);
  const [multiSelected, setMultiSelected] = useState<Set<number>>(new Set());
  const [answered, setAnswered] = useState(false);
  const [confidence, setConfidence] = useState<number | null>(null);
  const [choicesHidden, setChoicesHidden] = useState(false);
  // 「前の問題に戻る」用: デッキ位置ごとに解答状態を保持し、行き来しても復元できるようにする
  const [qStates, setQStates] = useState<Record<number, QState>>({});

  const [sessionResults, setSessionResults] = useState<SessionResult[]>([]);
  const [memoText, setMemoText] = useState("");
  const [csvText, setCsvText] = useState("");
  const [exportMode, setExportMode] = useState<ExportMode>("weak");
  const [copyMsg, setCopyMsg] = useState("");

  // 試験区分ごとの試験日。サーバ(DB)由来の initialGoal を初期値にし、
  // 試験区分が変わったら（別試験へ切替）サーバの新しい値へ同期する。
  const [goal, setGoal] = useState<UserGoal | null>(initialGoal);
  const [goalDraft, setGoalDraft] = useState<{ examDate: string; targetName: string }>({
    examDate: initialGoal?.examDate ?? "",
    targetName: initialGoal?.targetName ?? "",
  });
  const [sessionStartPassProb, setSessionStartPassProb] = useState<number | null>(null);

  // 試験区分ごとの教科書リンク。goal と同様、区分が変わったらサーバの新しい値へ同期する。
  const [textbooks, setTextbooks] = useState<Textbook[]>(initialTextbooks);
  const [tbEditing, setTbEditing] = useState(false);
  const [tbDraft, setTbDraft] = useState<{ label: string; url: string }>({ label: "", url: "" });
  const [tbError, setTbError] = useState<string | null>(null);

  useEffect(() => {
    setNow(Date.now());
  }, []);

  useEffect(() => {
    setGoal(initialGoal);
    setGoalDraft({
      examDate: initialGoal?.examDate ?? "",
      targetName: initialGoal?.targetName ?? "",
    });
    setTextbooks(initialTextbooks);
    setTbEditing(false);
    setTbDraft({ label: "", url: "" });
    setTbError(null);
    // 試験区分キーが変わったときだけ同期（同一試験内のセット切替では維持）。
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [goalExamKey]);

  // ヘッダの Home ボタンからの合図で、内部画面(クイズ/分析など)を
  // トップ(メニュー)へ戻す。別ルートからの遷移は新規マウントで menu になる。
  useEffect(() => {
    const goMenu = () => {
      setScreen("menu");
      setPickerOpen(false);
      window.scrollTo({ top: 0 });
    };
    window.addEventListener("app:home", goMenu);
    return () => window.removeEventListener("app:home", goMenu);
  }, []);

  useEffect(() => {
    if (!answered || !deck[idx]) return;
    const qid = deck[idx].id;
    const timer = setTimeout(() => {
      persist(qid, { memo: memoText });
    }, 800);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [memoText]);

  const supabase = useMemo(() => createClient(), []);

  // ── 教科書リンク CRUD（試験区分ごと・楽観的更新）──
  const addTextbook = async () => {
    const url = tbDraft.url.trim();
    const label = tbDraft.label.trim();
    if (!/^https?:\/\//i.test(url)) {
      setTbError("URL は http:// または https:// で始めてください");
      return;
    }
    const id = crypto.randomUUID();
    setTextbooks((list) => [...list, { id, label, url }]);
    setTbDraft({ label: "", url: "" });
    setTbError(null);
    const { error } = await supabase.from("user_textbooks").insert({
      id,
      user_id: userId,
      exam_key: goalExamKey,
      label,
      url,
      sort_order: textbooks.length,
    });
    if (error) {
      console.error("[user_textbooks] add failed:", error.code, error.message);
      setTextbooks((list) => list.filter((t) => t.id !== id)); // ロールバック
      setTbError("保存に失敗しました");
    }
  };
  const deleteTextbook = async (id: string) => {
    const prev = textbooks;
    setTextbooks((list) => list.filter((t) => t.id !== id));
    const { error } = await supabase
      .from("user_textbooks")
      .delete()
      .eq("user_id", userId)
      .eq("id", id);
    if (error) {
      console.error("[user_textbooks] delete failed:", error.code, error.message);
      setTextbooks(prev); // ロールバック
    }
  };

  const recordAnswer = (q: QuizQuestion, isCorrect: boolean, conf: number | null) => {
    supabase.from("answer_events").insert({
      user_id: userId,
      question_id: q.id,
      category_id: q.category_id,
      category_name: q.category_name,
      category_color: q.category_color,
      subject_slug: examQuestionSlug[q.id] ?? currentSubjectSlug,
      is_correct: isCorrect,
      confidence: conf,
    }).then(({ error }) => {
      if (error) console.error("[answer_events] insert failed:", error.code, error.message);
    });
  };

  const persist = async (qid: string, partial: Partial<Progress>) => {
    const cur = getProgress(progressMap, qid);
    const next: Progress = { ...cur, ...partial };
    setProgressMap((m) => ({ ...m, [qid]: next }));

    // 1) 中核カラム（必ず保存する。ここは常に成功させたい）
    const { error } = await supabase.from("user_question_progress").upsert(
      {
        user_id: userId,
        question_id: qid,
        correct_count: next.correct_count,
        wrong_count: next.wrong_count,
        consecutive_correct: next.consecutive_correct,
        last_is_correct: next.last_is_correct,
        last_selected_index: next.last_selected_index,
        last_answered_at: next.last_answered_at,
        understanding_level: next.understanding_level,
        memo: next.memo,
        last_confidence: next.last_confidence,
      },
      { onConflict: "user_id,question_id" }
    );
    if (error) console.error("save failed", error);

    // 2) FSRS カラム（解答時のみ・別クエリ）。列が無い環境ではここだけ失敗し、
    //    中核の保存は守られる（マイグレーション適用前にデプロイしても壊れない）。
    if (partial.fsrs_state !== undefined) {
      const { error: e2 } = await supabase
        .from("user_question_progress")
        .update({
          fsrs_stability: next.fsrs_stability ?? null,
          fsrs_difficulty: next.fsrs_difficulty ?? null,
          fsrs_due: next.fsrs_due ?? null,
          fsrs_last_review: next.fsrs_last_review ?? null,
          fsrs_reps: next.fsrs_reps ?? 0,
          fsrs_lapses: next.fsrs_lapses ?? 0,
          fsrs_state: next.fsrs_state ?? "new",
        })
        .eq("user_id", userId)
        .eq("question_id", qid);
      if (e2) console.error("[fsrs] save skipped:", e2.code, e2.message);
    }
  };

  const restingCount = useMemo(
    () => questions.filter((q) => isResting(getProgress(progressMap, q.id), now)).length,
    [questions, progressMap, now]
  );

  const eligible = useMemo(
    () => eligibleQuestions(questions, progressMap, selCats, now, includeResting),
    [questions, progressMap, selCats, now, includeResting]
  );
  // 休眠を無視した出題対象。全問休眠でスタートが空のとき、脱出口を出すかの判定に使う。
  const eligibleWithResting = useMemo(
    () => eligibleQuestions(questions, progressMap, selCats, now, true),
    [questions, progressMap, selCats, now]
  );

  // 試験区分の全セットを横断した「間違えた/苦手」問題プール（弱点順）。
  const examWeakPool = useMemo(
    () => weakReviewPool(examQuestions, progressMap),
    [examQuestions, progressMap]
  );
  // この試験区分が複数セットか（横断であることを UI で示すかの判定）。
  const isMultiSet = useMemo(
    () => (examGroups.find((g) => g.examKey === currentExamKey)?.sets.length ?? 1) > 1,
    [examGroups, currentExamKey]
  );

  // 合格ナビ: 試験全体（examSections=全Set）× 定着度 × 試験日 から着地予測。
  const readiness = useMemo<Readiness | null>(() => {
    if (now === 0 || examSections.length === 0) return null;
    const ids = [...new Set(examSections.map((s) => s.id))];
    const retentions = ids.map((id) => retentionEstimate(getProgress(progressMap, id), now));
    const attempted = ids.reduce((n, id) => {
      const p = getProgress(progressMap, id);
      return n + (p.correct_count + p.wrong_count > 0 ? 1 : 0);
    }, 0);
    const daysLeft = goal?.examDate ? daysUntilDate(goal.examDate, now) : null;
    return computeReadiness({
      retentions,
      total: ids.length,
      attempted,
      daysLeft,
      capacity: dailyCapacity,
      passLine: passLineFor(goalExamKey),
    });
  }, [examSections, progressMap, goal, now, dailyCapacity, goalExamKey]);

  const enterQuiz = (pool: QuizQuestion[]) => {
    if (!pool.length) return;
    setSessionStartPassProb(calcMasteryStats(questions, progressMap).passProb);
    setDeck(pool);
    setIdx(0);
    setPicked(null);
    setMultiSelected(new Set());
    setAnswered(false);
    setConfidence(null);
    setChoicesHidden(recallMode);
    setSessionResults([]);
    setQStates({});
    setMemoText(getProgress(progressMap, pool[0].id).memo);
    setScreen("quiz");
  };

  // force=true で休眠中も含める（全問休眠時の脱出口・トグルの両方から使う）。
  const startQuiz = (force = false) => {
    enterQuiz(
      buildDeck({
        questions,
        progressMap,
        selectedCategoryIds: selCats,
        count,
        mode,
        now,
        includeResting: force || includeResting,
      })
    );
  };

  // 苦手問題など、指定した問題だけを復習するセッションを開始（選択肢はシャッフル）
  const startReview = (qs: QuizQuestion[]) => {
    enterQuiz(qs.map(shuffleOptions));
  };

  const toggleMulti = (i: number) => {
    if (answered) return;
    setMultiSelected((prev) => {
      const s = new Set(prev);
      s.has(i) ? s.delete(i) : s.add(i);
      return s;
    });
  };

  const submitAnswer = () => {
    if (answered || confidence === null) return;
    const q = deck[idx];
    if (q.question_type === "multi") {
      if (multiSelected.size === 0) return;
      const selected = Array.from(multiSelected).sort((a, b) => a - b);
      const expected = [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b);
      const isCorrect = arraysEqual(selected, expected);
      const magure = isCorrect && confidence === 3;
      setAnswered(true);
      const cur = getProgress(progressMap, q.id);
      const base: Partial<Progress> = isCorrect
        ? { correct_count: cur.correct_count + 1, consecutive_correct: magure ? 0 : cur.consecutive_correct + 1, last_is_correct: true, last_answered_at: new Date().toISOString(), last_confidence: confidence }
        : { wrong_count: cur.wrong_count + 1, consecutive_correct: 0, last_is_correct: false, last_answered_at: new Date().toISOString(), last_confidence: confidence };
      const partial: Partial<Progress> = { ...base, ...fsrsFields(cur, isCorrect, confidence, Date.now()) };
      setSessionResults((r) => [...r, { correct: isCorrect, category: q.category_name, color: q.category_color }]);
      persist(q.id, partial);
      recordAnswer(q, isCorrect, confidence);
    } else {
      if (picked === null) return;
      const isCorrect = picked === q.correct_index;
      const magure = isCorrect && confidence === 3;
      setAnswered(true);
      const cur = getProgress(progressMap, q.id);
      // 表示順でシャッフルしているため、保存は元(DB)のインデックスに戻す
      const selectedOrig = q.optionOrder ? q.optionOrder[picked] : picked;
      const base: Partial<Progress> = isCorrect
        ? { correct_count: cur.correct_count + 1, consecutive_correct: magure ? 0 : cur.consecutive_correct + 1, last_is_correct: true, last_selected_index: selectedOrig, last_answered_at: new Date().toISOString(), last_confidence: confidence }
        : { wrong_count: cur.wrong_count + 1, consecutive_correct: 0, last_is_correct: false, last_selected_index: selectedOrig, last_answered_at: new Date().toISOString(), last_confidence: confidence };
      const partial: Partial<Progress> = { ...base, ...fsrsFields(cur, isCorrect, confidence, Date.now()) };
      setSessionResults((r) => [...r, { correct: isCorrect, category: q.category_name, color: q.category_color }]);
      persist(q.id, partial);
      recordAnswer(q, isCorrect, confidence);
    }
  };

  // 現在の問題の解答状態をスナップショット化
  const snapshotCurrent = (): QState => ({
    picked,
    multiSelected: Array.from(multiSelected),
    answered,
    confidence,
    choicesHidden,
  });

  // デッキ内の任意の問題へ移動。現在の状態を保存し、移動先の状態を復元（なければ新規）
  const goToIndex = (target: number) => {
    if (target < 0 || target >= deck.length || target === idx) return;
    persist(deck[idx].id, { memo: memoText });
    setQStates((m) => ({ ...m, [idx]: snapshotCurrent() }));
    window.scrollTo({ top: 0, behavior: "smooth" });

    const nq = deck[target];
    const saved = qStates[target];
    if (saved) {
      setPicked(saved.picked);
      setMultiSelected(new Set(saved.multiSelected));
      setAnswered(saved.answered);
      setConfidence(saved.confidence);
      setChoicesHidden(saved.choicesHidden);
    } else {
      setPicked(null);
      setMultiSelected(new Set());
      setAnswered(false);
      setConfidence(null);
      setChoicesHidden(recallMode);
    }
    setMemoText(getProgress(progressMap, nq.id).memo);
    setIdx(target);
  };

  const saveMemoAndNext = () => {
    if (idx + 1 >= deck.length) {
      persist(deck[idx].id, { memo: memoText });
      window.scrollTo({ top: 0, behavior: "smooth" });
      setScreen("done");
      return;
    }
    goToIndex(idx + 1);
  };

  const switchSubject = (slug: string) => {
    router.push(slug ? `/?subject=${slug}` : "/");
  };

  // 過去の解答から FSRS 状態を一括再構築（合格ナビ/復習間隔を正確化）
  const runBackfill = async () => {
    setBackfilling(true);
    setBackfillMsg("");
    try {
      const res = await fetch("/api/fsrs/backfill", { method: "POST" });
      const j = await res.json();
      if (!res.ok) throw new Error(j.error || "失敗");
      setBackfillMsg(`${j.updated} 問を過去の解答から再構築しました`);
      router.refresh();
    } catch (e) {
      setBackfillMsg("再構築に失敗しました: " + (e as Error).message);
    } finally {
      setBackfilling(false);
    }
  };

  if (now === 0) {
    return (
      <div className="flex justify-center pt-32 text-xs text-[#555e70]">
        読み込み中
      </div>
    );
  }

  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  // ── GOAL ──────────────────────────────────────────────────────────────
  if (screen === "goal") {
    const handleSaveGoal = async () => {
      if (!goalDraft.examDate) return;
      const g: UserGoal = { examDate: goalDraft.examDate, targetName: goalDraft.targetName };
      setGoal(g);
      setScreen("menu");
      const { error } = await supabase.from("user_exam_goals").upsert(
        {
          user_id: userId,
          exam_key: goalExamKey,
          exam_date: g.examDate,
          target_name: g.targetName,
        },
        { onConflict: "user_id,exam_key" }
      );
      if (error) console.error("[user_exam_goals] save failed:", error.code, error.message);
    };
    const handleClearGoal = async () => {
      setGoal(null);
      setGoalDraft({ examDate: "", targetName: "" });
      setScreen("menu");
      const { error } = await supabase
        .from("user_exam_goals")
        .delete()
        .eq("user_id", userId)
        .eq("exam_key", goalExamKey);
      if (error) console.error("[user_exam_goals] clear failed:", error.code, error.message);
    };

    return (
      <div className={wrap}>
        <div className={container}>
          <h1 className="mb-6 text-sm font-semibold text-white">目標設定</h1>

          <label className="mb-1.5 block text-xs text-[#8892a4]">試験日</label>
          <input
            type="date"
            value={goalDraft.examDate}
            onChange={(e) => setGoalDraft((d) => ({ ...d, examDate: e.target.value }))}
            className="mb-5 w-full rounded-xl border border-[#2a2f3f] bg-[#1a1d27] px-4 py-3 text-sm text-white outline-none focus:border-[#3b82f6] transition-colors"
          />

          <label className="mb-1.5 block text-xs text-[#8892a4]">試験名（任意）</label>
          <input
            type="text"
            value={goalDraft.targetName}
            onChange={(e) => setGoalDraft((d) => ({ ...d, targetName: e.target.value }))}
            placeholder={`例: ${examName} 合格`}
            className="mb-6 w-full rounded-xl border border-[#2a2f3f] bg-[#1a1d27] px-4 py-3 text-sm text-white outline-none placeholder:text-[#555e70] focus:border-[#3b82f6] transition-colors"
          />

          <button
            onClick={handleSaveGoal}
            disabled={!goalDraft.examDate}
            className="mb-2 w-full rounded-xl bg-[#3b82f6] py-3 text-sm font-medium text-white transition hover:bg-[#60a5fa] disabled:bg-[#1a1d27] disabled:text-[#555e70]"
          >
            保存
          </button>
          {goal && (
            <button
              onClick={handleClearGoal}
              className="mb-2 w-full rounded-xl border border-[#2a1010] bg-[#160606] py-3 text-sm font-medium text-[#ef4444] transition hover:border-[#3f1515]"
            >
              削除
            </button>
          )}
          <button
            onClick={() => setScreen("menu")}
            className="w-full rounded-xl py-3 text-sm text-[#555e70] transition hover:text-[#8892a4]"
          >
            キャンセル
          </button>
        </div>
      </div>
    );
  }

  // ── MENU ──────────────────────────────────────────────────────────────
  if (screen === "menu") {
    const answeredCount = questions.filter((q) => {
      const p = getProgress(progressMap, q.id);
      return p.correct_count + p.wrong_count > 0;
    }).length;
    const countOptions = [5, 10, 20, eligible.length];

    return (
      <div className={wrap}>
        <div className={container}>
          {/* Header */}
          <div className="mb-6 flex items-start justify-between">
            <div>
              <h1 className="text-base font-semibold text-white">{subjectName}</h1>
              <p className="text-xs text-[#555e70]">
                全 {questions.length} 問
                {answeredCount > 0 && <span> · 演習済み {answeredCount}</span>}
                {restingCount > 0 && <span> · 休眠 {restingCount}</span>}
              </p>
            </div>
            {subjects.length > 1 && (
              <div className="relative shrink-0">
                <button
                  onClick={() => setPickerOpen((o) => !o)}
                  className="flex items-center gap-1.5 rounded-lg border border-[#2a2f3f] bg-[#1a1d27] px-3 py-1.5 text-xs text-[#8892a4] outline-none transition hover:border-[#3a4055]"
                >
                  <span className="max-w-[180px] truncate">問題集を選ぶ</span>
                  <svg width="9" height="9" viewBox="0 0 10 10" fill="none">
                    <path d="M2 3.5L5 6.5L8 3.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </button>

                {pickerOpen && (
                  <>
                    <button
                      aria-label="閉じる"
                      onClick={() => setPickerOpen(false)}
                      className="fixed inset-0 z-40 cursor-default"
                    />
                    <div className="absolute right-0 z-50 mt-2 max-h-[70vh] w-[340px] overflow-auto rounded-xl border border-[#2a2f3f] bg-[#12141c] p-1.5 shadow-2xl">
                      {examGroups.map((g) => {
                        // 単一セットの試験はそのまま1行で選択可能にする。
                        if (g.sets.length === 1) {
                          const s = g.sets[0];
                          const active = s.slug === currentSubjectSlug;
                          return (
                            <button
                              key={g.examKey}
                              onClick={() => {
                                setPickerOpen(false);
                                if (!active) switchSubject(s.slug);
                              }}
                              className={`flex w-full items-center gap-2 rounded-lg px-2 py-2 text-left transition ${
                                active ? "bg-[#1e2230]" : "hover:bg-[#1a1d27]"
                              }`}
                            >
                              <span
                                className={`min-w-0 flex-1 truncate text-xs ${
                                  active ? "font-medium text-white" : "text-[#c0c8d8]"
                                }`}
                              >
                                {g.examName}
                              </span>
                              <StatCell
                                accuracy={s.accuracy}
                                answers={s.answers}
                                attempted={s.attempted}
                                total={s.total}
                                last={s.lastAnsweredAt}
                                now={now}
                              />
                            </button>
                          );
                        }

                        // 複数セットの試験は「試験見出し（集計）」を1行に折りたたみ、
                        // クリックで展開してセット一覧を表示する。
                        const open = expandedExam === g.examKey;
                        const hasCurrent = g.sets.some((s) => s.slug === currentSubjectSlug);
                        return (
                          <div key={g.examKey}>
                            <button
                              onClick={() => setExpandedExam(open ? null : g.examKey)}
                              className={`flex w-full items-center gap-2 rounded-lg px-2 py-2 text-left transition hover:bg-[#1a1d27] ${
                                hasCurrent && !open ? "bg-[#161922]" : ""
                              }`}
                            >
                              <svg
                                width="9"
                                height="9"
                                viewBox="0 0 10 10"
                                fill="none"
                                className="shrink-0 transition-transform"
                                style={{ transform: open ? "rotate(90deg)" : "none", color: "#8892a4" }}
                              >
                                <path d="M3.5 2L6.5 5L3.5 8" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
                              </svg>
                              <span className="min-w-0 flex-1 truncate text-xs font-semibold text-[#c0c8d8]">
                                {g.examName}
                                <span className="ml-1.5 font-normal text-[#555e70]">{g.sets.length}セット</span>
                              </span>
                              <StatCell
                                accuracy={g.accuracy}
                                answers={g.answers}
                                attempted={g.attempted}
                                total={g.total}
                                last={g.lastAnsweredAt}
                                now={now}
                              />
                            </button>

                            {open && (
                              <div className="mb-1 ml-3.5 space-y-0.5 border-l border-[#2a2f3f] pl-2">
                                {g.sets.map((s) => {
                                  const active = s.slug === currentSubjectSlug;
                                  return (
                                    <button
                                      key={s.slug}
                                      onClick={() => {
                                        setPickerOpen(false);
                                        if (!active) switchSubject(s.slug);
                                      }}
                                      className={`flex w-full items-center gap-2 rounded-lg px-2 py-1.5 text-left transition ${
                                        active ? "bg-[#1e2230]" : "hover:bg-[#1a1d27]"
                                      }`}
                                    >
                                      <span
                                        className={`min-w-0 flex-1 truncate text-xs ${
                                          active ? "font-medium text-white" : "text-[#c0c8d8]"
                                        }`}
                                      >
                                        {s.name}
                                      </span>
                                      <StatCell
                                        accuracy={s.accuracy}
                                        answers={s.answers}
                                        attempted={s.attempted}
                                        total={s.total}
                                        last={s.lastAnsweredAt}
                                        now={now}
                                      />
                                    </button>
                                  );
                                })}
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  </>
                )}
              </div>
            )}
          </div>

          {/* 合格ナビ card — 本日時点の合格可能性は試験日と独立に常時表示。
              試験日があれば加えて着地予測・ノルマも出す。 */}
          {readiness &&
            (() => {
              const hasDate = readiness.verdict !== "no-date";
              const nowPct = Math.round(readiness.readinessNow * 100);
              const passPct = Math.round(readiness.passLine * 100);
              const nowReached = readiness.readinessNow >= readiness.passLine;
              // 本日時点の色: 合格ライン到達なら緑、未到達は学習中を示すアクセント青。
              const nowColor = nowReached ? "#22c55e" : "#3b82f6";
              // ヘッダーのバッジ: 試験日ありは着地予測の判定、なしは本日到達なら合格圏内。
              const chip = hasDate
                ? VERDICT_META[readiness.verdict].label
                  ? VERDICT_META[readiness.verdict]
                  : null
                : nowReached
                  ? VERDICT_META.passed
                  : null;
              return (
                <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-4">
                  <div className="mb-3 flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="truncate text-sm font-medium text-white">
                        {goal?.targetName || examName}
                      </p>
                      <p className="text-xs text-[#555e70]">
                        {hasDate ? `試験まで残り ${readiness.daysLeft} 日` : "試験日は未設定"}
                      </p>
                    </div>
                    {chip && (
                      <span
                        className="shrink-0 rounded-full px-2.5 py-1 text-[11px] font-semibold"
                        style={{ color: chip.color, background: chip.color + "22" }}
                      >
                        {chip.label}
                      </span>
                    )}
                  </div>

                  <div className="mb-1 flex items-baseline justify-between text-xs">
                    <span className="text-[#8892a4]">
                      本日時点の合格可能性{" "}
                      <b className="tabular-nums text-base" style={{ color: nowColor }}>
                        {nowPct}%
                      </b>
                    </span>
                    {hasDate && (
                      <span className="text-[#8892a4]">
                        試験日予測{" "}
                        <b
                          className="tabular-nums"
                          style={{ color: VERDICT_META[readiness.verdict].color }}
                        >
                          {Math.round(readiness.projectedAtExam * 100)}%
                        </b>
                      </span>
                    )}
                  </div>
                  <div className="relative mb-1 h-2 overflow-hidden rounded-full bg-[#2a2f3f]">
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{ width: `${nowPct}%`, background: nowColor }}
                    />
                    <div
                      className="absolute -top-0.5 bottom-[-2px] w-px bg-white/70"
                      style={{ left: `${passPct}%` }}
                      title={`合格ライン ${passPct}%`}
                    />
                  </div>
                  <p className="mb-3 text-[10px] text-[#3a4050]">白線 = 合格ライン {passPct}%</p>

                  <div className="flex items-center justify-between gap-3">
                    <p className="min-w-0 text-xs" style={{ color: nowReached ? "#22c55e" : "#8892a4" }}>
                      {nowReached
                        ? "本日時点で合格ラインに到達。維持しよう"
                        : `合格ラインまで あと ${passPct - nowPct}%` +
                          (hasDate && readiness.neededPerDayForPass > 0
                            ? ` · 1日 ${readiness.neededPerDayForPass} 問`
                            : "")}
                    </p>
                    <button
                      onClick={() => setScreen("goal")}
                      className="shrink-0 text-xs text-[#555e70] transition hover:text-[#8892a4]"
                    >
                      {hasDate ? "編集" : "試験日を設定"}
                    </button>
                  </div>
                </div>
              );
            })()}

          {/* 教科書リンク（試験区分ごと・クリックで外部ページへ） */}
          <section className="mb-6">
            <div className="mb-2 flex items-center justify-between">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
                教科書
              </p>
              {(textbooks.length > 0 || tbEditing) && (
                <button
                  onClick={() => {
                    setTbEditing((v) => !v);
                    setTbError(null);
                  }}
                  className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
                >
                  {tbEditing ? "完了" : "編集"}
                </button>
              )}
            </div>

            {textbooks.length > 0 && (
              <div className="overflow-hidden rounded-xl border border-[#2a2f3f] bg-[#1a1d27]">
                {textbooks.map((tb, i) => (
                  <div
                    key={tb.id}
                    className={`flex items-center ${i > 0 ? "border-t border-[#20242e]" : ""}`}
                  >
                    <a
                      href={tb.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="group flex min-w-0 flex-1 items-center gap-2.5 px-3.5 py-3 transition hover:bg-[#1e2230]"
                    >
                      <svg
                        width="15"
                        height="15"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="1.8"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        className="shrink-0 text-[#555e70]"
                      >
                        <path d="M4 5a2 2 0 0 1 2-2h12v16H6a2 2 0 0 0-2 2V5Z" />
                        <path d="M4 19a2 2 0 0 0 2 2h12" />
                      </svg>
                      <span className="min-w-0 flex-1 truncate text-sm text-[#c0c8d8] transition group-hover:text-white">
                        {tb.label || tb.url}
                      </span>
                      <svg
                        width="13"
                        height="13"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="1.8"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        className="shrink-0 text-[#555e70] transition group-hover:text-[#8892a4]"
                      >
                        <path d="M7 17 17 7M9 7h8v8" />
                      </svg>
                    </a>
                    {tbEditing && (
                      <button
                        onClick={() => deleteTextbook(tb.id)}
                        aria-label="削除"
                        className="mr-1.5 shrink-0 rounded-md px-2 py-2 text-[#555e70] transition hover:bg-[#ef4444]/15 hover:text-[#ef4444]"
                      >
                        <svg
                          width="14"
                          height="14"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2"
                          strokeLinecap="round"
                        >
                          <path d="M6 6l12 12M18 6 6 18" />
                        </svg>
                      </button>
                    )}
                  </div>
                ))}
              </div>
            )}

            {textbooks.length === 0 && !tbEditing && (
              <button
                onClick={() => setTbEditing(true)}
                className="w-full rounded-xl border border-dashed border-[#2a2f3f] px-4 py-3.5 text-left transition hover:border-[#3a4050]"
              >
                <p className="text-sm text-[#8892a4]">教科書リンクを追加</p>
                <p className="text-xs text-[#555e70]">Claude アーティファクト等の公開ページ URL を貼る</p>
              </button>
            )}

            {tbEditing && (
              <div className="mt-2 rounded-xl border border-[#2a2f3f] bg-[#14161d] p-3">
                <input
                  type="text"
                  value={tbDraft.label}
                  onChange={(e) => setTbDraft((d) => ({ ...d, label: e.target.value }))}
                  placeholder="タイトル（例: 公式ドキュメントまとめ）"
                  className="mb-2 w-full rounded-lg border border-[#2a2f3f] bg-[#1a1d27] px-3 py-2 text-sm text-white outline-none transition-colors placeholder:text-[#555e70] focus:border-[#3b82f6]"
                />
                <input
                  type="url"
                  value={tbDraft.url}
                  onChange={(e) => setTbDraft((d) => ({ ...d, url: e.target.value }))}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") addTextbook();
                  }}
                  placeholder="https://claude.ai/public/artifacts/..."
                  className="w-full rounded-lg border border-[#2a2f3f] bg-[#1a1d27] px-3 py-2 text-sm text-white outline-none transition-colors placeholder:text-[#555e70] focus:border-[#3b82f6]"
                />
                {tbError && <p className="mt-1.5 text-[11px] text-[#ef4444]">{tbError}</p>}
                <button
                  onClick={addTextbook}
                  disabled={!tbDraft.url.trim()}
                  className="mt-2.5 w-full rounded-lg bg-[#3b82f6] px-4 py-2 text-sm font-medium text-white transition hover:bg-[#3b82f6]/90 disabled:cursor-not-allowed disabled:opacity-40"
                >
                  追加
                </button>
              </div>
            )}
          </section>

          {/* 苦手だけ演習（試験区分の全セット横断・弱点順） */}
          {examWeakPool.length > 0 && (
            <button
              onClick={() => startReview(examWeakPool.slice(0, WEAK_SESSION_MAX))}
              className="mb-6 flex w-full items-center justify-between gap-3 rounded-xl border border-[#3a1d1d] bg-[#181215] px-4 py-3.5 text-left transition hover:border-[#ef4444]"
            >
              <div className="min-w-0">
                <p className="text-sm font-medium text-white">苦手だけ演習</p>
                <p className="text-xs text-[#8892a4]">
                  {isMultiSet ? "全セット横断・" : ""}間違えた・苦手な問題を弱点順に
                </p>
              </div>
              <span className="shrink-0 rounded-lg bg-[#ef4444]/15 px-3 py-1.5 text-xs font-semibold tabular-nums text-[#f87171]">
                {examWeakPool.length > WEAK_SESSION_MAX
                  ? `上位${WEAK_SESSION_MAX} / ${examWeakPool.length}問`
                  : `${examWeakPool.length}問`}
              </span>
            </button>
          )}

          {/* Categories */}
          <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            分野
          </p>
          <div className="mb-2 flex flex-wrap gap-1.5">
            {categories.map((c) => {
              const on = selCats.has(c.id);
              const all = questions.filter((q) => q.category_id === c.id);
              const rest = all.filter((q) =>
                isResting(getProgress(progressMap, q.id), now)
              ).length;
              return (
                <button
                  key={c.id}
                  onClick={() => {
                    const s = new Set(selCats);
                    s.has(c.id) ? s.delete(c.id) : s.add(c.id);
                    setSelCats(s);
                  }}
                  className="flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs transition"
                  style={{
                    borderColor: on ? c.color + "55" : "#2a2f3f",
                    color: on ? c.color : "#8892a4",
                    background: on ? c.color + "0f" : "transparent",
                  }}
                >
                  <span
                    className="h-1.5 w-1.5 shrink-0 rounded-full"
                    style={{ background: on ? c.color : "#3a4050" }}
                  />
                  {c.name}
                  <span className="text-[10px] opacity-60">{all.length - rest}</span>
                </button>
              );
            })}
          </div>
          <div className="mb-6 flex gap-3">
            <button
              onClick={() => setSelCats(new Set(categories.map((c) => c.id)))}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              全選択
            </button>
            <span className="text-[#2a2f3f]">·</span>
            <button
              onClick={() => setSelCats(new Set())}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              全解除
            </button>
          </div>

          {/* Count */}
          <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            問題数
          </p>
          <div className="mb-6 flex overflow-hidden rounded-xl border border-[#2a2f3f]">
            {countOptions.map((n, i) => {
              const on = count === n;
              return (
                <button
                  key={i}
                  onClick={() => setCount(n)}
                  className="flex-1 border-r border-[#2a2f3f] py-2.5 text-sm font-medium last:border-r-0 transition"
                  style={{
                    background: on ? "#3b82f6" : "transparent",
                    color: on ? "#fff" : "#8892a4",
                  }}
                >
                  {i === 3 ? eligible.length : n}
                </button>
              );
            })}
          </div>

          {/* Start CTA */}
          {eligible.length > 0 ? (
            <button
              onClick={() => startQuiz()}
              className="mb-6 w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
            >
              スタート — {Math.min(count, eligible.length)} 問
            </button>
          ) : eligibleWithResting.length > 0 ? (
            // 全問休眠でも「今すぐ復習したい」に応える脱出口。休眠を無視して出題する。
            <div className="mb-6">
              <button
                onClick={() => startQuiz(true)}
                className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
              >
                休眠中も含めて復習 — {Math.min(count, eligibleWithResting.length)} 問
              </button>
              <p className="mt-1.5 text-center text-xs text-[#555e70]">
                いまは全問が休眠中（復習日は先）。それでも復習できます
              </p>
            </div>
          ) : (
            <button
              disabled
              className="mb-6 w-full rounded-xl bg-[#141720] py-4 text-sm font-semibold text-[#555e70]"
            >
              この分野に出題できる問題がありません
            </button>
          )}

          {/* Advanced settings */}
          <details className="mb-6 group" open={mode === "priority" || recallMode || includeResting}>
            <summary className="mb-3 cursor-pointer list-none text-xs text-[#555e70] transition hover:text-[#8892a4] group-open:text-[#8892a4]">
              詳細設定
            </summary>

            <div className="space-y-4">
              <div>
                <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
                  出題モード
                </p>
                <div className="flex overflow-hidden rounded-xl border border-[#2a2f3f]">
                  {([["shuffle", "シャッフル"], ["priority", "弱点優先"]] as const).map(
                    ([m, lbl], i) => (
                      <button
                        key={m}
                        onClick={() => setMode(m)}
                        className="flex-1 py-2.5 text-sm transition"
                        style={{
                          borderRight: i === 0 ? "1px solid #2a2f3f" : "none",
                          background:
                            mode === m
                              ? m === "priority"
                                ? "#1f0a0a"
                                : "#0d1f3c"
                              : "transparent",
                          color:
                            mode === m
                              ? m === "priority"
                                ? "#f87171"
                                : "#60a5fa"
                              : "#8892a4",
                        }}
                      >
                        {lbl}
                      </button>
                    )
                  )}
                </div>
                <p className="mt-1.5 text-xs text-[#555e70]">
                  3回連続正解は2週間休眠
                </p>
              </div>

              <div className="flex items-center justify-between rounded-xl border border-[#2a2f3f] px-4 py-3">
                <div>
                  <p className="text-sm text-[#c0c8d8]">想起モード</p>
                  <p className="text-xs text-[#555e70]">選択肢を隠して先に考える</p>
                </div>
                <button
                  onClick={() => setRecallMode((v) => !v)}
                  className="relative h-6 w-11 shrink-0 rounded-full transition-colors"
                  style={{ background: recallMode ? "#3b82f6" : "#2a2f3f" }}
                >
                  <span
                    className="absolute top-1 h-4 w-4 rounded-full bg-white shadow transition-all"
                    style={{ left: recallMode ? "calc(100% - 20px)" : "4px" }}
                  />
                </button>
              </div>

              <div className="flex items-center justify-between rounded-xl border border-[#2a2f3f] px-4 py-3">
                <div>
                  <p className="text-sm text-[#c0c8d8]">休眠中も出す</p>
                  <p className="text-xs text-[#555e70]">復習日が来ていない問題も出題する</p>
                </div>
                <button
                  onClick={() => setIncludeResting((v) => !v)}
                  className="relative h-6 w-11 shrink-0 rounded-full transition-colors"
                  style={{ background: includeResting ? "#3b82f6" : "#2a2f3f" }}
                >
                  <span
                    className="absolute top-1 h-4 w-4 rounded-full bg-white shadow transition-all"
                    style={{ left: includeResting ? "calc(100% - 20px)" : "4px" }}
                  />
                </button>
              </div>
            </div>
          </details>

          {/* Nav grid */}
          <div className="grid grid-cols-2 gap-2">
            {[
              { label: "ロードマップ", action: () => router.push("/roadmap") },
              { label: "学習ログ",     action: () => router.push("/log") },
              { label: "思考フレーム", action: () => router.push("/mindset") },
              { label: "苦手分析",     action: () => setScreen("analysis") },
              {
                label: "書き出し",
                action: () => {
                  setCsvText(buildCSV(questions, progressMap, now, exportMode));
                  setCopyMsg("");
                  setScreen("export");
                },
              },
            ].map(({ label, action }) => (
              <button
                key={label}
                onClick={action}
                className="rounded-xl border border-[#2a2f3f] py-3 text-xs text-[#555e70] transition hover:border-[#3a4050] hover:text-[#8892a4]"
              >
                {label}
              </button>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // ── EXPORT ────────────────────────────────────────────────────────────
  if (screen === "export") {
    const weakCount = questions.filter((q) => {
      const p = getProgress(progressMap, q.id);
      if (p.correct_count + p.wrong_count === 0 && q.initial_wrong_weight === 0) return false;
      const attempts = p.correct_count + p.wrong_count;
      if (attempts === 0) return true;
      const accuracy = p.correct_count / attempts;
      const selfScore = p.last_confidence === 1 ? 1.0 : p.last_confidence === 2 ? 0.5 : 0.0;
      const streakBonus = Math.min(p.consecutive_correct, 3) / 30;
      return Math.min(1, accuracy * 0.6 + selfScore * 0.3 + streakBonus) < 0.5;
    }).length;
    const memoCount = questions.filter((q) =>
      getProgress(progressMap, q.id).memo.trim()
    ).length;

    const MODES: { key: ExportMode; label: string; count: number }[] = [
      { key: "weak", label: "苦手",     count: weakCount },
      { key: "memo", label: "メモあり", count: memoCount },
      { key: "all",  label: "全問題",   count: questions.length },
    ];

    const rebuild = (m: ExportMode) => {
      setExportMode(m);
      setCsvText(buildCSV(questions, progressMap, now, m));
      setCopyMsg("");
    };

    return (
      <div className={wrap}>
        <div className={container}>
          <div className="mb-6 flex items-center justify-between">
            <h1 className="text-sm font-semibold text-white">書き出し（CSV）</h1>
            <button
              onClick={() => setScreen("menu")}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              ← 戻る
            </button>
          </div>

          <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            対象
          </p>
          <div className="mb-5 flex overflow-hidden rounded-xl border border-[#2a2f3f]">
            {MODES.map(({ key, label, count }, i) => {
              const on = exportMode === key;
              return (
                <button
                  key={key}
                  onClick={() => rebuild(key)}
                  className="flex-1 py-2.5 text-xs font-medium transition"
                  style={{
                    borderRight: i < MODES.length - 1 ? "1px solid #2a2f3f" : "none",
                    background: on ? "#1a1d27" : "transparent",
                    color: on ? "#fff" : "#8892a4",
                  }}
                >
                  {label}
                  <span className="ml-1 opacity-50">({count})</span>
                </button>
              );
            })}
          </div>

          {exportMode === "weak" && weakCount === 0 && (
            <div className="mb-5 rounded-xl border border-[#0a2a1a] bg-[#061510] p-4 text-center">
              <p className="text-sm text-[#22c55e]">苦手問題なし</p>
              <p className="text-xs text-[#1a5a2a]">習得度 50% 以上の問題のみです</p>
            </div>
          )}

          <button
            onClick={() => downloadCSV(`${currentSubjectSlug}-${exportMode}.csv`, csvText)}
            className="mb-2 w-full rounded-xl bg-[#3b82f6] py-3.5 text-sm font-medium text-white transition hover:bg-[#60a5fa]"
          >
            ダウンロード
          </button>
          <button
            onClick={async () => {
              try {
                await navigator.clipboard.writeText(csvText);
                setCopyMsg("コピーしました");
              } catch {
                setCopyMsg("コピー不可 — テキストを手動で選択してください");
              }
            }}
            className="mb-2 w-full rounded-xl border border-[#2a2f3f] py-3 text-sm text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#c0c8d8]"
          >
            クリップボードにコピー
          </button>
          {copyMsg && (
            <p className="mb-3 text-center text-xs text-[#8892a4]">{copyMsg}</p>
          )}

          <textarea
            readOnly
            value={csvText}
            onFocus={(e) => e.target.select()}
            className="mb-4 min-h-[180px] w-full resize-y overflow-x-auto rounded-xl border border-[#2a2f3f] bg-[#141720] px-3 py-2.5 font-mono text-[11px] text-[#8892a4]"
          />
        </div>
      </div>
    );
  }

  // ── ANALYSIS ──────────────────────────────────────────────────────────
  if (screen === "analysis") {
    // 試験全体（全Set合算）の分野別分析
    const sections = analyzeSections(examSections, progressMap);
    const overview = sectionOverview(sections);
    const examName =
      examGroups.find((g) => g.examKey === currentExamKey)?.examName ?? subjectName;
    const setNameOf = new Map(examGroups.flatMap((g) => g.sets).map((s) => [s.slug, s.name]));
    const shortSet = (slug: string): string => {
      const n = setNameOf.get(slug) ?? slug;
      const s = n.replace(examName, "").replace(/[（()）]/g, "").trim();
      return s || n;
    };
    // 弱点順に並べる: 演習済みは習熟度が低い順、未着手は末尾
    const ranked = [...sections].sort((a, b) => {
      const aa = a.attempted > 0;
      const bb = b.attempted > 0;
      if (aa !== bb) return aa ? -1 : 1;
      if (aa) return a.mastery - b.mastery;
      return a.sort - b.sort;
    });
    const secColor = (pct: number, attempted: number): string =>
      attempted === 0 ? "#555e70" : pct >= 70 ? "#22c55e" : pct >= 40 ? "#f59e0b" : "#ef4444";
    const overPct = Math.round(overview.mastery * 100);

    // 弱点問題（試験区分の全セット横断・弱点順に上位8問）
    const worst = weakReviewPool(examQuestions, progressMap, { limit: 8 });

    // 確信度キャリブレーション（直近の解答: 自信度 × 正誤・全セット横断）。
    // 「自信あり」なのに誤答 = 思い込みの危険ゾーン（最優先で復習すべき）。
    const cal = { sureCorrect: 0, sureWrong: 0, unsureCorrect: 0, unsureWrong: 0 };
    const dangerQs: QuizQuestion[] = [];
    for (const q of examQuestions) {
      const p = getProgress(progressMap, q.id);
      if (p.last_confidence === null || p.last_is_correct === null) continue;
      const sure = p.last_confidence === 1;
      if (p.last_is_correct) sure ? cal.sureCorrect++ : cal.unsureCorrect++;
      else if (sure) {
        cal.sureWrong++;
        dangerQs.push(q);
      } else cal.unsureWrong++;
    }

    return (
      <div className={wrap}>
        <div className={container}>
          <div className="mb-6 flex items-center justify-between">
            <h1 className="text-sm font-semibold text-white">苦手分析</h1>
            <button
              onClick={() => setScreen("menu")}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              ← 戻る
            </button>
          </div>

          {/* 試験全体サマリ（全Set合算） */}
          <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-4">
            <div className="mb-3 flex items-end justify-between gap-3">
              <div className="min-w-0">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
                  試験全体
                </p>
                <p className="truncate text-sm font-medium text-white">{examName}</p>
              </div>
              <p
                className="shrink-0 text-3xl font-bold tabular-nums"
                style={{ color: secColor(overPct, overview.attempted) }}
              >
                {overview.attempted === 0 ? "—" : `${overPct}%`}
              </p>
            </div>
            <div className="mb-3 h-1.5 overflow-hidden rounded-full bg-[#2a2f3f]">
              <div
                className="h-full rounded-full transition-all"
                style={{
                  width: `${overview.attempted === 0 ? 0 : overPct}%`,
                  background: secColor(overPct, overview.attempted),
                }}
              />
            </div>
            <div className="flex flex-wrap gap-4 text-xs text-[#555e70]">
              <span>
                カバー {Math.round(overview.coverage * 100)}%（{overview.attempted}/{overview.total}）
              </span>
              <span>分野 {overview.sectionCount}</span>
              {overview.weakSections > 0 && (
                <span className="text-[#ef4444]">弱点分野 {overview.weakSections}</span>
              )}
            </div>
          </div>

          {/* 分野別 苦手マップ（弱点順・全Set合算・タップでSet別内訳） */}
          <div className="mb-3 flex items-baseline justify-between">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
              分野別 苦手マップ
            </p>
            <span className="text-[10px] text-[#3a4050]">弱点が上・タップでSet別内訳</span>
          </div>
          <div className="mb-6 space-y-2">
            {ranked.length === 0 && (
              <p className="text-xs text-[#555e70]">まだデータがありません</p>
            )}
            {ranked.map((sec) => {
              const pct = Math.round(sec.mastery * 100);
              const open = expandedSection === sec.name;
              const color = secColor(pct, sec.attempted);
              return (
                <div key={sec.name} className="rounded-xl border border-[#2a2f3f] bg-[#141720] p-3.5">
                  <button
                    onClick={() => setExpandedSection(open ? null : sec.name)}
                    className="w-full text-left"
                  >
                    <div className="mb-2 flex items-center justify-between gap-2">
                      <div className="flex min-w-0 items-center gap-2">
                        <svg
                          width="8"
                          height="8"
                          viewBox="0 0 10 10"
                          fill="none"
                          className="shrink-0 transition-transform"
                          style={{ transform: open ? "rotate(90deg)" : "none", color: "#555e70" }}
                        >
                          <path d="M3.5 2L6.5 5L3.5 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                        <span className="h-2 w-2 shrink-0 rounded-full" style={{ background: sec.color }} />
                        <span className="truncate text-xs font-medium text-[#c0c8d8]">{sec.name}</span>
                      </div>
                      <div className="flex shrink-0 items-center gap-3 text-[10px] text-[#555e70]">
                        <span>{sec.attempted}/{sec.total}</span>
                        <span className="w-9 text-right font-semibold" style={{ color }}>
                          {sec.attempted === 0 ? "未着" : `${pct}%`}
                        </span>
                      </div>
                    </div>
                    <div className="h-1.5 overflow-hidden rounded-full bg-[#2a2f3f]">
                      <div
                        className="h-full rounded-full transition-all"
                        style={{ width: `${sec.attempted === 0 ? 0 : pct}%`, background: color }}
                      />
                    </div>
                  </button>

                  {open && (
                    <div className="mt-3 space-y-1.5 border-t border-[#2a2f3f] pt-3">
                      {sec.sets.map((st) => {
                        const sp = Math.round(st.mastery * 100);
                        const sc = secColor(sp, st.attempted);
                        return (
                          <div key={st.slug} className="flex items-center gap-2">
                            <span className="w-24 shrink-0 truncate text-[10px] text-[#8892a4]">
                              {shortSet(st.slug)}
                            </span>
                            <div className="h-1 flex-1 overflow-hidden rounded-full bg-[#2a2f3f]">
                              <div
                                className="h-full rounded-full"
                                style={{ width: `${st.attempted === 0 ? 0 : sp}%`, background: sc }}
                              />
                            </div>
                            <span className="w-16 shrink-0 text-right text-[10px] tabular-nums" style={{ color: sc }}>
                              {st.attempted === 0 ? "未着" : `${sp}%`}
                              <span className="ml-1 text-[#3a4050]">{st.attempted}/{st.total}</span>
                            </span>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {/* Worst questions */}
          <div className="mb-3 flex items-center justify-between">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
              {isMultiSet ? "弱点問題（全セット）" : "弱点問題"}
            </p>
            {worst.length > 0 && (
              <button
                onClick={() => startReview(worst)}
                className="rounded-lg border border-[#2a2f3f] px-3 py-1 text-[11px] font-medium text-[#8892a4] transition hover:border-[#3b82f6] hover:text-white"
              >
                まとめて復習 →
              </button>
            )}
          </div>
          <p className="mb-3 text-[10px] text-[#3a4050]">
            タップするとその問題だけを復習できます
          </p>
          <div className="mb-6 space-y-1.5">
            {worst.length === 0 && (
              <p className="text-xs text-[#555e70]">弱点問題はありません（演習するとここに出ます）</p>
            )}
            {worst.map((q) => {
              const p = getProgress(progressMap, q.id);
              return (
                <button
                  key={q.id}
                  onClick={() => startReview([q])}
                  className="flex w-full items-start gap-3 rounded-xl border border-[#2a2f3f] px-3.5 py-3 text-left transition hover:border-[#3b82f6] hover:bg-[#141720]"
                >
                  <span
                    className="mt-0.5 h-2 w-2 shrink-0 rounded-full"
                    style={{ background: q.category_color }}
                  />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-xs text-[#8892a4]">
                      {q.question_text.slice(0, 55)}…
                    </p>
                    <p className="mt-0.5 text-[10px] text-[#555e70]">
                      {isMultiSet && (
                        <span className="mr-2 rounded bg-[#1e2230] px-1.5 py-px text-[#8892a4]">
                          {shortSet(examQuestionSlug[q.id] ?? "")}
                        </span>
                      )}
                      誤 {totalWrong(q, p)} 正 {totalCorrect(p)}
                      {p.last_confidence !== null && (
                        <span className="ml-2" style={{ color: CONFIDENCE_COLORS[(p.last_confidence ?? 1) - 1] }}>
                          {CONFIDENCE_LABELS[(p.last_confidence ?? 1) - 1]}
                        </span>
                      )}
                    </p>
                  </div>
                  <span className="mt-0.5 shrink-0 text-xs text-[#3a4050]">→</span>
                </button>
              );
            })}
          </div>

          {/* 確信度キャリブレーション */}
          <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            確信度キャリブレーション
          </p>
          {cal.sureWrong > 0 && (
            <div className="mb-3 flex items-center justify-between gap-3 rounded-xl border border-[#3f1515] bg-[#160606] px-4 py-3">
              <div className="min-w-0">
                <p className="text-xs font-semibold text-[#ef4444]">
                  「自信あり」なのに誤答 {cal.sureWrong}問
                </p>
                <p className="text-[11px] text-[#8892a4]">思い込みの危険ゾーン。最優先で復習を。</p>
              </div>
              <button
                onClick={() => startReview(dangerQs)}
                className="shrink-0 rounded-lg border border-[#3f1515] px-3 py-1.5 text-[11px] font-medium text-[#ef4444] transition hover:bg-[#1a0808]"
              >
                復習 →
              </button>
            </div>
          )}
          <div className="mb-6 grid grid-cols-[56px_1fr_1fr] gap-1.5">
            <div />
            <div className="text-center text-[10px] font-mono text-[#555e70]">正解</div>
            <div className="text-center text-[10px] font-mono text-[#555e70]">誤答</div>

            <div className="flex items-center text-[10px] font-mono text-[#555e70]">自信あり</div>
            <div className="rounded-lg border border-[#2a2f3f] bg-[#141720] py-2.5 text-center">
              <span className="text-lg font-bold tabular-nums text-[#22c55e]">{cal.sureCorrect}</span>
            </div>
            <div
              className="rounded-lg border py-2.5 text-center"
              style={{ borderColor: cal.sureWrong > 0 ? "#ef4444" : "#2a2f3f", background: cal.sureWrong > 0 ? "#160606" : "#141720" }}
            >
              <span className="text-lg font-bold tabular-nums" style={{ color: cal.sureWrong > 0 ? "#ef4444" : "#3a4050" }}>
                {cal.sureWrong}
              </span>
            </div>

            <div className="flex items-center text-[10px] font-mono text-[#555e70]">自信なし</div>
            <div className="rounded-lg border border-[#2a2f3f] bg-[#141720] py-2.5 text-center">
              <span className="text-lg font-bold tabular-nums text-[#8892a4]">{cal.unsureCorrect}</span>
            </div>
            <div className="rounded-lg border border-[#2a2f3f] bg-[#141720] py-2.5 text-center">
              <span className="text-lg font-bold tabular-nums text-[#8892a4]">{cal.unsureWrong}</span>
            </div>
          </div>

          {/* FSRS 再構築（過去の解答から記憶エンジンを一括計算） */}
          <div className="mt-2 rounded-xl border border-[#2a2f3f] bg-[#141720] p-3.5">
            <div className="flex items-center justify-between gap-3">
              <div className="min-w-0">
                <p className="text-xs font-medium text-[#c0c8d8]">記憶エンジンを再構築</p>
                <p className="text-[11px] text-[#555e70]">
                  過去の解答から復習間隔・合格ナビの精度を作り直します
                </p>
              </div>
              <button
                onClick={runBackfill}
                disabled={backfilling}
                className="shrink-0 rounded-lg border border-[#2a2f3f] px-3 py-1.5 text-[11px] font-medium text-[#8892a4] transition hover:border-[#3b82f6] hover:text-white disabled:opacity-50"
              >
                {backfilling ? "計算中…" : "⟳ 再構築"}
              </button>
            </div>
            {backfillMsg && <p className="mt-2 text-[11px] text-[#3E8E6E]">{backfillMsg}</p>}
          </div>
        </div>
      </div>
    );
  }

  // ── DONE ──────────────────────────────────────────────────────────────
  if (screen === "done") {
    const ok = sessionResults.filter((r) => r.correct).length;
    const pct = sessionResults.length
      ? Math.round((ok / sessionResults.length) * 100)
      : 0;
    const breakdown: Record<string, { ok: number; ng: number; color: string }> = {};
    sessionResults.forEach((r) => {
      if (!breakdown[r.category]) breakdown[r.category] = { ok: 0, ng: 0, color: r.color };
      r.correct ? breakdown[r.category].ok++ : breakdown[r.category].ng++;
    });
    const currentPassProb = calcMasteryStats(questions, progressMap).passProb;
    const probDelta = sessionStartPassProb !== null ? currentPassProb - sessionStartPassProb : null;

    return (
      <div className={wrap}>
        <div className={container}>
          {/* Score */}
          <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-6 text-center">
            <p className="mb-1 text-4xl font-bold tabular-nums text-white">
              {ok}
              <span className="text-xl text-[#555e70]"> / {sessionResults.length}</span>
            </p>
            <p className="text-sm text-[#8892a4]">正答率 {pct}%</p>

            {probDelta !== null && (
              <div className="mt-4 flex items-center justify-center gap-2 text-sm tabular-nums">
                <span className="text-[#555e70]">{sessionStartPassProb}%</span>
                <span className="text-[#3a4050]">→</span>
                <span
                  className="font-semibold"
                  style={{
                    color:
                      currentPassProb >= 70 ? "#22c55e" : currentPassProb >= 50 ? "#f59e0b" : "#ef4444",
                  }}
                >
                  {currentPassProb}%
                </span>
                {probDelta !== 0 && (
                  <span
                    className="text-xs"
                    style={{ color: probDelta > 0 ? "#22c55e" : "#ef4444" }}
                  >
                    ({probDelta > 0 ? "+" : ""}{probDelta}%)
                  </span>
                )}
              </div>
            )}
          </div>

          {/* Category breakdown */}
          {Object.keys(breakdown).length > 0 && (
            <div className="mb-6 rounded-xl border border-[#2a2f3f] overflow-hidden">
              {Object.entries(breakdown).map(([cat, v], i) => (
                <div
                  key={cat}
                  className="flex items-center justify-between px-4 py-3"
                  style={{
                    borderTop: i > 0 ? "1px solid #2a2f3f" : "none",
                  }}
                >
                  <div className="flex items-center gap-2">
                    <span
                      className="h-1.5 w-1.5 rounded-full"
                      style={{ background: v.color }}
                    />
                    <span className="text-xs text-[#8892a4]">{cat}</span>
                  </div>
                  <div className="flex gap-3 text-xs">
                    <span className="text-[#22c55e]">{v.ok}</span>
                    <span className="text-[#ef4444]">{v.ng}</span>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="flex gap-2">
            <button
              onClick={() => setScreen("analysis")}
              className="flex-1 rounded-xl border border-[#2a2f3f] py-3 text-sm text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#c0c8d8]"
            >
              分析
            </button>
            <button
              onClick={() => setScreen("menu")}
              className="flex-1 rounded-xl bg-[#3b82f6] py-3 text-sm font-medium text-white transition hover:bg-[#60a5fa]"
            >
              メニュー
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ── QUIZ ──────────────────────────────────────────────────────────────
  const q = deck[idx];
  const p = getProgress(progressMap, q.id);

  const isCorrect =
    q.question_type === "multi"
      ? answered &&
        arraysEqual(
          Array.from(multiSelected).sort((a, b) => a - b),
          [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b)
        )
      : picked === q.correct_index;

  const correctSet = new Set(q.correct_indices ?? [q.correct_index]);

  const getChoiceClass = (i: number): string => {
    if (!answered) {
      if (q.question_type === "multi" && multiSelected.has(i)) return "border-[#2a4a7f] bg-[#0f1f40]";
      if (q.question_type !== "multi" && i === picked)          return "border-[#3b82f6] bg-[#0d1f3c]";
      return "border-[#2a2f3f] hover:border-[#3b82f6] cursor-pointer";
    }
    const isCorrectOption = correctSet.has(i);
    const wasSelected = q.question_type === "multi" ? multiSelected.has(i) : i === picked;
    if (isCorrectOption && wasSelected)  return "border-[#166534] bg-[#052e16]";
    if (isCorrectOption && !wasSelected) return "border-[#134e26] bg-[#031a0e]";
    if (!isCorrectOption && wasSelected) return "border-[#7f1d1d] bg-[#1c0606]";
    return "border-[#2a2f3f]";
  };

  const getChoiceColor = (i: number): string => {
    if (!answered) {
      if ((q.question_type === "multi" && multiSelected.has(i)) ||
          (q.question_type !== "multi" && i === picked)) return "#ffffff";
      return "#c0c8d8";
    }
    const isCorrectOption = correctSet.has(i);
    const wasSelected = q.question_type === "multi" ? multiSelected.has(i) : i === picked;
    if (isCorrectOption && wasSelected)  return "#86efac";
    if (isCorrectOption && !wasSelected) return "#4ade80";
    if (!isCorrectOption && wasSelected) return "#fca5a5";
    return "#555e70";
  };

  return (
    <div className={wrap}>
      {/* Progress */}
      <div className="mb-4 w-full max-w-[520px]">
        <div className="mb-2 flex items-center gap-3">
          <button
            onClick={() => goToIndex(idx - 1)}
            disabled={idx === 0}
            className="shrink-0 rounded-lg border border-[#2a2f3f] px-2.5 py-1 text-xs text-[#8892a4] transition hover:border-[#3b82f6] hover:text-white disabled:cursor-default disabled:border-transparent disabled:text-transparent"
            aria-label="前の問題へ戻る"
          >
            ← 前へ
          </button>
          <span className="min-w-[40px] text-xs tabular-nums text-[#555e70]">
            {idx + 1} / {deck.length}
          </span>
          <div className="h-px flex-1 overflow-hidden rounded-full bg-[#1a1d27]">
            <div
              className="h-full rounded-full bg-[#3b82f6] transition-all"
              style={{ width: `${((idx + 1) / deck.length) * 100}%` }}
            />
          </div>
        </div>
      </div>

      <div className="w-full max-w-[520px] rounded-2xl border border-[#2a2f3f] bg-[#1a1d27] p-5">
        {/* Meta */}
        <div className="mb-4 flex items-center gap-2">
          <span className="h-2 w-2 shrink-0 rounded-full" style={{ background: q.category_color }} />
          <span className="text-xs text-[#8892a4]">{q.category_name}</span>
          {q.question_type === "multi" && (
            <span className="text-xs text-[#555e70]">· 複数選択</span>
          )}
          <span className="ml-auto text-xs text-[#555e70]">
            {p.correct_count + p.wrong_count === 0
              ? "初挑戦"
              : `誤 ${totalWrong(q, p)} 連 ${p.consecutive_correct}`}
          </span>
        </div>

        {/* Question */}
        <p className="mb-5 text-[15px] font-medium leading-8 text-[#e8eaf0]">
          {q.question_text}
        </p>

        {/* Code */}
        {q.code && (
          <pre className="mb-5 overflow-x-auto rounded-xl bg-[#141720] px-4 py-3.5 font-mono text-xs leading-6 text-[#8892a4]">
            <code>{q.code}</code>
          </pre>
        )}

        {/* Recall placeholder */}
        {choicesHidden ? (
          <div className="mb-5 rounded-xl border border-dashed border-[#2a2f3f] py-8 text-center">
            <p className="mb-1 text-sm text-[#8892a4]">まず自分で考えてみよう</p>
            <p className="mb-4 text-xs text-[#555e70]">答えが浮かんだら選択肢を表示する</p>
            <button
              onClick={() => setChoicesHidden(false)}
              className="rounded-lg bg-[#3b82f6] px-5 py-2 text-sm font-medium text-white transition hover:bg-[#60a5fa]"
            >
              選択肢を表示
            </button>
          </div>
        ) : (
          <>
            {/* Choices — always fully visible, click to select */}
            <div className="space-y-2">
              {q.options.map((choice, i) => (
                <button
                  key={i}
                  onClick={() =>
                    answered ? undefined : q.question_type === "multi" ? toggleMulti(i) : setPicked(i)
                  }
                  disabled={answered}
                  className={`block w-full rounded-xl border px-4 py-3.5 text-left text-sm leading-relaxed transition ${getChoiceClass(i)}`}
                  style={{ color: getChoiceColor(i) }}
                >
                  <span className="mr-2.5 font-semibold">{"ABCD"[i]}.</span>
                  {choice}
                </button>
              ))}
            </div>

            {/* Confidence + Submit */}
            {!answered && (
              <div className="mt-4 space-y-3">
                <div className="flex overflow-hidden rounded-xl border border-[#2a2f3f]">
                  {CONFIDENCE_LABELS.map((label, i) => {
                    const level = i + 1;
                    const on = confidence === level;
                    const color = CONFIDENCE_COLORS[i];
                    return (
                      <button
                        key={level}
                        onClick={() => setConfidence(level)}
                        className="flex flex-1 items-center justify-center gap-1.5 border-r border-[#2a2f3f] py-2.5 text-xs font-medium last:border-r-0 transition"
                        style={{
                          background: on ? color + "18" : "transparent",
                          color: on ? color : "#8892a4",
                        }}
                      >
                        {on && <span className="h-1.5 w-1.5 rounded-full" style={{ background: color }} />}
                        {label}
                      </button>
                    );
                  })}
                </div>
                <button
                  onClick={submitAnswer}
                  disabled={
                    confidence === null ||
                    (q.question_type === "multi" ? multiSelected.size === 0 : picked === null)
                  }
                  className="w-full rounded-xl bg-[#3b82f6] py-3.5 text-sm font-semibold text-white transition hover:bg-[#60a5fa] disabled:bg-[#141720] disabled:text-[#555e70]"
                >
                  {q.question_type === "multi"
                    ? `回答する（${multiSelected.size} 選択中）`
                    : "回答する"}
                </button>
              </div>
            )}
          </>
        )}

        {/* After answer */}
        {answered && (
          <div className="mt-5 space-y-4">
            {/* Result banner */}
            <div
              className="rounded-xl border px-4 py-3"
              style={{
                borderColor: isCorrect ? "#14532d" : "#7f1d1d",
                background: isCorrect ? "#052e1620" : "#1c060620",
              }}
            >
              <div className="mb-0.5 flex items-center gap-2">
                <span
                  className="text-sm font-semibold"
                  style={{ color: isCorrect ? "#86efac" : "#f87171" }}
                >
                  {isCorrect ? "正解" : "不正解"}
                </span>
                {confidence !== null && (
                  <span
                    className="text-xs"
                    style={{ color: CONFIDENCE_COLORS[confidence - 1] }}
                  >
                    · {CONFIDENCE_LABELS[confidence - 1]}
                  </span>
                )}
                {confidence === 3 && isCorrect && (
                  <span className="ml-auto text-[10px] text-[#92400e]">まぐれ当たり</span>
                )}
              </div>
            </div>

            {/* Explanation */}
            <div className="rounded-xl border border-[#2a2f3f] bg-[#141720] p-4">
              {q.explanation_data ? (
                <RichExplanation data={q.explanation_data} />
              ) : (
                <p className="text-sm leading-7 text-[#c0c8d8]">{q.explanation}</p>
              )}
            </div>

            {/* Memo */}
            <textarea
              value={memoText}
              onChange={(e) => setMemoText(e.target.value)}
              placeholder="気づき・覚え方・自分の言葉でのメモ"
              className="w-full resize-y rounded-xl border border-[#2a2f3f] bg-[#141720] px-4 py-3 text-xs leading-relaxed text-[#8892a4] outline-none placeholder:text-[#3a4050] focus:border-[#3a4050]"
              rows={3}
            />

            <button
              onClick={saveMemoAndNext}
              className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
            >
              {idx + 1 >= deck.length ? "結果を見る" : "次へ →"}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
