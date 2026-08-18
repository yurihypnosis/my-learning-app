import { getServerSupabase, getSessionUser } from "@/shared/lib/supabase/server";
import type { ExplanationData, QuizQuestion } from "@/features/quiz/lib/types";
import { examGroupKey, groupSubjectsByExam } from "@/features/quiz/lib/stats";
import {
  fetchDailyBreakdown,
  fetchDailyCounts,
  fetchFamilyProgress,
  fetchSubjectStats,
  jstDayKey,
  toSubjectStats,
} from "@/features/quiz/lib/server-data";
import { capacityFromDailyCounts } from "@/features/quiz/lib/readiness";
import { LearningApp } from "./learning-app";
import { OverviewDashboard } from "./overview-dashboard";

export const dynamic = "force-dynamic";

// 学習アクティビティ・連続学習日数を見るのに十分な日数。
// これを超える連続記録は表示上ここで頭打ちになる。
const ACTIVITY_DAYS = 120;

// 現在セット以外の問題は本文と分類だけを送り、選択肢・解説は演習開始時に取りに行く。
// 解説(explanation_data)は 1試験区分で 800KB を超えることがあり、初期表示の主因だった。
const FULL_COLS =
  "id, subject_id, category_id, source_ref, question_text, code, options, correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight";
const LIGHT_COLS = "id, subject_id, category_id, question_text, initial_wrong_weight";

// 試験区分が決まらないと成立しない画面。?screen= で直接来た場合だけ、
// 前回学習した問題集にフォールバックして行き止まりにしない。
const SUBJECT_SCOPED_SCREENS = ["analysis", "export", "goal"];

interface AnyQRow {
  id: string;
  subject_id: string;
  category_id: string;
  question_text: string;
  initial_wrong_weight: number;
  source_ref?: string | null;
  code?: string | null;
  options?: unknown;
  correct_index?: number | null;
  correct_indices?: unknown;
  question_type?: string | null;
  explanation?: string | null;
  explanation_data?: unknown;
}

/** 暦日キー(YYYY-MM-DD)を days 日ずらす。 */
function shiftDay(key: string, days: number): string {
  const d = new Date(key + "T00:00:00Z");
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

/** 日別集計から直近7日のバーと連続学習日数を作る。 */
function activityFrom(
  dayCounts: Map<string, { total: number; correct: number }>,
  todayKey: string
) {
  const weekly = Array.from({ length: 7 }, (_, i) => {
    const key = shiftDay(todayKey, i - 6);
    const rec = dayCounts.get(key) ?? { total: 0, correct: 0 };
    return {
      dow: ["日", "月", "火", "水", "木", "金", "土"][new Date(key + "T00:00:00Z").getUTCDay()],
      total: rec.total,
      correct: rec.correct,
    };
  });

  // 今日に記録が無ければ昨日から数え始める（当日分をまだ解いていない朝を切り捨てない）。
  let streak = 0;
  let cursor = dayCounts.has(todayKey) ? todayKey : shiftDay(todayKey, -1);
  while (dayCounts.has(cursor)) {
    streak++;
    cursor = shiftDay(cursor, -1);
  }

  return { weekly, streak };
}

export default async function HomePage({
  searchParams,
}: {
  searchParams: Promise<{ subject?: string; screen?: string }>;
}) {
  const { subject: subjectSlug, screen: requestedScreen } = await searchParams;
  const supabase = await getServerSupabase();
  const user = await getSessionUser();
  const todayKey = jstDayKey(new Date().toISOString());

  // ── 第1波: 科目一覧・科目別集計（互いに独立なので並列）──
  const [{ data: subjects }, { stats }] = await Promise.all([
    supabase.from("subjects").select("id, slug, name").eq("is_active", true).order("sort_order"),
    fetchSubjectStats(supabase, user!.id),
  ]);

  if (!subjects || subjects.length === 0) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center text-muted">
        科目データがありません。Supabase にマイグレーション（00001 / 00002）を適用してください。
      </div>
    );
  }

  const examGroups = groupSubjectsByExam(toSubjectStats(subjects, stats));

  // 前回学習したセット（全体ビューの「続きから」と ?screen= のフォールバックに使う）
  const lastStudied = subjects.reduce<{ s: (typeof subjects)[number]; at: string } | null>(
    (best, s) => {
      const at = stats.get(s.id)?.lastAnsweredAt;
      if (!at) return best;
      return !best || at > best.at ? { s, at } : best;
    },
    null
  )?.s;

  // ?subject= が無ければ全体ビュー。
  const explicit = subjectSlug ? subjects.find((s) => s.slug === subjectSlug) : undefined;
  const subject =
    explicit ??
    (subjectSlug || SUBJECT_SCOPED_SCREENS.includes(requestedScreen ?? "")
      ? (lastStudied ?? subjects[0])
      : null);

  // ── 全体ビュー（問題集を選ぶ前）──
  // 試験区分に依存するデータは一切読まないので、取得も表示もここで完結する。
  if (!subject) {
    const [dayCounts, { data: goalRows }] = await Promise.all([
      fetchDailyCounts(supabase, user!.id, ACTIVITY_DAYS),
      supabase
        .from("user_exam_goals")
        .select("exam_key, exam_date, target_name")
        .eq("user_id", user!.id)
        .not("exam_date", "is", null)
        .gte("exam_date", todayKey)
        .order("exam_date", { ascending: true })
        .limit(1),
    ]);

    const { weekly, streak } = activityFrom(dayCounts, todayKey);
    const goal = goalRows?.[0];
    const nextExam = goal
      ? {
          examKey: goal.exam_key,
          examDate: goal.exam_date as string,
          targetName: goal.target_name ?? goal.exam_key,
          slug:
            examGroups.find((g) => g.examKey === goal.exam_key)?.sets[0]?.slug ?? subjects[0].slug,
        }
      : null;

    return (
      <OverviewDashboard
        examGroups={examGroups}
        streak={streak}
        weekly={weekly}
        nextExam={nextExam}
        lastStudied={lastStudied ? { slug: lastStudied.slug, name: lastStudied.name } : null}
      />
    );
  }

  // ── 現在の試験区分（全セット）を束ねる ──
  // 「全セット横断で苦手だけ演習」を可能にするため、現在の subject が属する
  // 試験区分の全アクティブセットの問題をまとめて読み込む。
  const examKey = examGroupKey(subject.slug);
  const examSets = subjects.filter((s) => examGroupKey(s.slug) === examKey);
  const examSetIds = examSets.map((s) => s.id);
  const examSetSlugs = examSets.map((s) => s.slug);
  const otherSetIds = examSetIds.filter((id) => id !== subject.id);

  // ── 第2波: 現在の試験区分に依存するものをまとめて並列取得 ──
  const [
    { data: categories },
    { data: examCats },
    { data: fullRows },
    { data: lightRows },
    progressMap,
    { data: goalRow },
    { data: textbookRows },
    trendDays,
  ] = await Promise.all([
    supabase
      .from("categories")
      .select("id, name, color")
      .eq("subject_id", subject.id)
      .order("sort_order"),
    supabase.from("categories").select("id, name, color, sort_order").in("subject_id", examSetIds),
    supabase.from("questions").select(FULL_COLS).eq("is_active", true).eq("subject_id", subject.id),
    otherSetIds.length
      ? supabase
          .from("questions")
          .select(LIGHT_COLS)
          .eq("is_active", true)
          .in("subject_id", otherSetIds)
      : Promise.resolve({ data: [] as unknown[] }),
    fetchFamilyProgress(supabase, user!.id, examSetIds),
    supabase
      .from("user_exam_goals")
      .select("exam_date, target_name")
      .eq("user_id", user!.id)
      .eq("exam_key", examKey)
      .maybeSingle(),
    supabase
      .from("user_textbooks")
      .select("id, label, url")
      .eq("user_id", user!.id)
      .eq("exam_key", examKey)
      .order("sort_order", { ascending: true })
      .order("created_at", { ascending: true }),
    // 学習アクティビティと推移グラフは、この試験区分の解答だけを1回で引いて作る。
    fetchDailyBreakdown(supabase, user!.id, ACTIVITY_DAYS, examSetSlugs),
  ]);

  const dayCounts = new Map(
    trendDays.map((d) => [d.day, { total: d.total, correct: d.correct }])
  );

  const examCatMap = new Map((examCats ?? []).map((c) => [c.id, c]));
  const idToSlug = new Map(subjects.map((s) => [s.id, s.slug]));

  const toQuizQuestion = (q: AnyQRow): QuizQuestion => {
    const cat = examCatMap.get(q.category_id);
    return {
      id: q.id,
      source_ref: q.source_ref ?? null,
      question_text: q.question_text,
      code: q.code ?? null,
      // 選択肢が空配列 = 本文だけの軽量版。演習開始時にクライアントが取りに行く目印。
      options: (q.options as string[] | undefined) ?? [],
      correct_index: q.correct_index ?? 0,
      correct_indices: (q.correct_indices as number[] | null | undefined) ?? null,
      question_type: (q.question_type === "multi" ? "multi" : "single") as "single" | "multi",
      explanation: q.explanation ?? "",
      explanation_data: (q.explanation_data as ExplanationData | null | undefined) ?? null,
      initial_wrong_weight: q.initial_wrong_weight,
      category_id: q.category_id,
      category_name: cat?.name ?? "未分類",
      category_color: cat?.color ?? "#64748b",
    };
  };

  const familyRows = [
    ...((fullRows ?? []) as unknown as AnyQRow[]),
    ...((lightRows ?? []) as unknown as AnyQRow[]),
  ];

  // 試験区分の全問題（横断の苦手演習・分析用）と、その各問がどのセット由来か。
  const examQuestions: QuizQuestion[] = familyRows.map(toQuizQuestion);
  const examQuestionSlug: Record<string, string> = {};
  for (const q of familyRows) examQuestionSlug[q.id] = idToSlug.get(q.subject_id) ?? "";

  // 現在セットの問題（通常クイズ・分野選択はこれで動く）。
  // examQuestions の要素をそのまま使い回すことで、RSC ペイロードに二重に載せない。
  const questions = examQuestions.filter((q) => examQuestionSlug[q.id] === subject.slug);

  // 苦手分析の「問題 × 分野」カタログは examQuestions から導出できるので、
  // 配列を別途送らずに、分野名→表示順の対応表（数十件）だけ渡す。
  const sectionSort: Record<string, number> = {};
  for (const c of examCats ?? []) {
    const name = c.name ?? "未分類";
    const sort = (c as { sort_order?: number }).sort_order ?? 0;
    if (sectionSort[name] === undefined || sort < sectionSort[name]) sectionSort[name] = sort;
  }

  const initialGoal = goalRow
    ? { examDate: goalRow.exam_date ?? "", targetName: goalRow.target_name ?? "" }
    : null;
  const examName = examGroups.find((g) => g.examKey === examKey)?.examName ?? subject.name;

  const initialTextbooks = (textbookRows ?? []).map((t) => ({
    id: t.id,
    label: t.label ?? "",
    url: t.url,
  }));

  const dailyCapacity = capacityFromDailyCounts([...dayCounts.values()].map((v) => v.total));
  const { weekly, streak } = activityFrom(dayCounts, todayKey);

  return (
    <LearningApp
      userId={user!.id}
      subjects={subjects.map((s) => ({ slug: s.slug, name: s.name }))}
      currentSubjectSlug={subject.slug}
      subjectName={subject.name}
      examGroups={examGroups}
      sectionSort={sectionSort}
      categories={(categories ?? []).map((c) => ({ id: c.id, name: c.name, color: c.color }))}
      questions={questions}
      examQuestions={examQuestions}
      examQuestionSlug={examQuestionSlug}
      initialProgress={progressMap}
      goalExamKey={examKey}
      examName={examName}
      initialGoal={initialGoal}
      initialTextbooks={initialTextbooks}
      dailyCapacity={dailyCapacity}
      streak={streak}
      weekly={weekly}
      trendDays={trendDays}
      todayKey={todayKey}
      requestedScreen={requestedScreen}
    />
  );
}
