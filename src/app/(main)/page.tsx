import { createServerSupabaseClient } from "@/lib/supabase/server";
import type { ProgressMap } from "@/lib/quiz/selection";
import type { ExplanationData, Progress, QuizQuestion } from "@/lib/quiz/types";
import {
  buildSubjectStats,
  examGroupKey,
  groupSubjectsByExam,
  type QuestionSubjectRef,
  type SectionQuestionRef,
} from "@/lib/quiz/stats";
import { capacityFromDailyCounts } from "@/lib/quiz/readiness";
import { LearningApp } from "./learning-app";

export const dynamic = "force-dynamic";

export default async function HomePage({
  searchParams,
}: {
  searchParams: Promise<{ subject?: string }>;
}) {
  const { subject: subjectSlug } = await searchParams;
  const supabase = await createServerSupabaseClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: subjects } = await supabase
    .from("subjects")
    .select("*")
    .eq("is_active", true)
    .order("sort_order");

  if (!subjects || subjects.length === 0) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 text-center text-muted">
        科目データがありません。Supabase にマイグレーション（00001 / 00002）を適用してください。
      </div>
    );
  }

  // subject 非依存のデータを先に読む（着地セットの判定・全体の集計に使う）。
  const [{ data: rawProgress }, { data: allQ }] = await Promise.all([
    supabase.from("user_question_progress").select("*").eq("user_id", user!.id),
    supabase.from("questions").select("id, subject_id, category_id").eq("is_active", true),
  ]);

  const progressMap: ProgressMap = {};
  for (const p of rawProgress ?? []) {
    const prog: Progress = {
      question_id: p.question_id,
      correct_count: p.correct_count,
      wrong_count: p.wrong_count,
      consecutive_correct: p.consecutive_correct,
      last_is_correct: p.last_is_correct,
      last_selected_index: p.last_selected_index,
      last_answered_at: p.last_answered_at,
      understanding_level: p.understanding_level,
      memo: p.memo,
      last_confidence: (p.last_confidence as number | null) ?? null,
      last_spoken_ok: (p.last_spoken_ok as boolean | null) ?? null,
      fsrs_stability: (p.fsrs_stability as number | null) ?? null,
      fsrs_difficulty: (p.fsrs_difficulty as number | null) ?? null,
      fsrs_due: (p.fsrs_due as string | null) ?? null,
      fsrs_last_review: (p.fsrs_last_review as string | null) ?? null,
      fsrs_reps: (p.fsrs_reps as number | undefined) ?? 0,
      fsrs_lapses: (p.fsrs_lapses as number | undefined) ?? 0,
      fsrs_state: (p.fsrs_state as string | undefined) ?? "new",
    };
    progressMap[p.question_id] = prog;
  }

  const idToSlug = new Map(subjects.map((s) => [s.id, s.slug]));

  // 着地するセットを決める:
  //  - ?subject 指定があればそれ
  //  - 無ければ「最後に学習したセット」（home が特定セットに固定表示されないように）
  //  - どれも未学習なら先頭
  let lastStudied: (typeof subjects)[number] | undefined;
  {
    const lastTsBySubject = new Map<string, number>();
    for (const q of allQ ?? []) {
      const at = progressMap[q.id]?.last_answered_at;
      const ts = at ? Date.parse(at) : NaN;
      if (!Number.isNaN(ts)) {
        lastTsBySubject.set(
          q.subject_id,
          Math.max(lastTsBySubject.get(q.subject_id) ?? -Infinity, ts)
        );
      }
    }
    let bestTs = -Infinity;
    for (const s of subjects) {
      const ts = lastTsBySubject.get(s.id);
      if (ts !== undefined && ts > bestTs) {
        bestTs = ts;
        lastStudied = s;
      }
    }
  }
  const subject = subjectSlug
    ? (subjects.find((s) => s.slug === subjectSlug) ?? subjects[0])
    : (lastStudied ?? subjects[0]);

  // ── 現在の試験区分（全セット）を束ねる ──
  // 「全セット横断で苦手だけ演習」を可能にするため、現在の subject が属する
  // 試験区分の全アクティブセットの問題をまとめて読み込む。questions（現在セット）は
  // その部分集合として切り出す。
  const examKey = examGroupKey(subject.slug);
  const examSetIds = new Set(
    subjects.filter((s) => examGroupKey(s.slug) === examKey).map((s) => s.id)
  );

  const [{ data: categories }, { data: examCats }, { data: rawFamily }] = await Promise.all([
    supabase.from("categories").select("*").eq("subject_id", subject.id).order("sort_order"),
    supabase.from("categories").select("id, name, color, sort_order").in("subject_id", [...examSetIds]),
    supabase.from("questions").select("*").eq("is_active", true).in("subject_id", [...examSetIds]),
  ]);

  const examCatMap = new Map((examCats ?? []).map((c) => [c.id, c]));
  type QRow = NonNullable<typeof rawFamily>[number];
  const toQuizQuestion = (q: QRow): QuizQuestion => {
    const cat = examCatMap.get(q.category_id);
    return {
      id: q.id,
      source_ref: q.source_ref,
      question_text: q.question_text,
      code: (q.code as string | null) ?? null,
      options: (q.options as string[]) ?? [],
      correct_index: q.correct_index ?? 0,
      correct_indices: (q.correct_indices as number[] | null) ?? null,
      question_type: ((q.question_type as string) === "multi" ? "multi" : "single") as "single" | "multi",
      explanation: q.explanation ?? "",
      explanation_data: (q.explanation_data as ExplanationData | null) ?? null,
      initial_wrong_weight: q.initial_wrong_weight,
      category_id: q.category_id,
      category_name: cat?.name ?? "未分類",
      category_color: cat?.color ?? "#64748b",
    };
  };

  // 試験区分の全問題（横断の苦手演習・分析用）と、その各問がどのセット由来か。
  const examQuestions: QuizQuestion[] = (rawFamily ?? []).map(toQuizQuestion);
  const examQuestionSlug: Record<string, string> = {};
  for (const q of rawFamily ?? []) examQuestionSlug[q.id] = idToSlug.get(q.subject_id) ?? "";
  // 現在セットの問題（通常クイズ・分野選択はこれで動く）。
  const questions: QuizQuestion[] = (rawFamily ?? [])
    .filter((q) => q.subject_id === subject.id)
    .map(toQuizQuestion);

  const refs: QuestionSubjectRef[] = (allQ ?? [])
    .map((q) => ({ id: q.id, slug: idToSlug.get(q.subject_id) ?? "" }))
    .filter((r): r is QuestionSubjectRef => r.slug !== "");
  const examGroups = groupSubjectsByExam(
    buildSubjectStats(
      subjects.map((s) => ({ slug: s.slug, name: s.name })),
      refs,
      progressMap
    )
  );

  // ── 体系的な苦手分析（試験全体）用: 現在の試験に属する全Setの
  //    「問題 × 分野(カテゴリ)」カタログを組み立てる ──
  const examSections: SectionQuestionRef[] = (allQ ?? [])
    .filter((q) => examSetIds.has(q.subject_id))
    .map((q) => {
      const c = examCatMap.get(q.category_id);
      return {
        id: q.id,
        slug: idToSlug.get(q.subject_id) ?? "",
        section: (c?.name as string) ?? "未分類",
        color: (c?.color as string) ?? "#64748b",
        sort: (c?.sort_order as number) ?? 0,
      };
    });

  // ── 試験区分ごとの試験日（DB: user_exam_goals・本人のみ RLS）──
  const { data: goalRow } = await supabase
    .from("user_exam_goals")
    .select("exam_date, target_name")
    .eq("user_id", user!.id)
    .eq("exam_key", examKey)
    .maybeSingle();
  const initialGoal = goalRow
    ? {
        examDate: (goalRow.exam_date as string | null) ?? "",
        targetName: (goalRow.target_name as string | null) ?? "",
      }
    : null;
  const examName = examGroups.find((g) => g.examKey === examKey)?.examName ?? subject.name;

  // ── 試験区分ごとの教科書リンク（DB: user_textbooks・本人のみ RLS）──
  const { data: textbookRows } = await supabase
    .from("user_textbooks")
    .select("id, label, url")
    .eq("user_id", user!.id)
    .eq("exam_key", examKey)
    .order("sort_order", { ascending: true })
    .order("created_at", { ascending: true });
  const initialTextbooks = (textbookRows ?? []).map((t) => ({
    id: t.id as string,
    label: (t.label as string | null) ?? "",
    url: t.url as string,
  }));

  // 合格ナビの逆算に使う1日 capacity を、直近の解答実績から推定する。
  const { data: capEvents } = await supabase
    .from("answer_events")
    .select("answered_at")
    .eq("user_id", user!.id)
    .order("answered_at", { ascending: false })
    .limit(5000);
  const byDay = new Map<string, number>();
  for (const e of capEvents ?? []) {
    const d = new Date(e.answered_at as string);
    const key = `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
    byDay.set(key, (byDay.get(key) ?? 0) + 1);
  }
  const dailyCapacity = capacityFromDailyCounts([...byDay.values()]);

  return (
    <LearningApp
      userId={user!.id}
      subjects={subjects.map((s) => ({ slug: s.slug, name: s.name }))}
      currentSubjectSlug={subject.slug}
      subjectName={subject.name}
      examGroups={examGroups}
      examSections={examSections}
      categories={(categories ?? []).map((c) => ({
        id: c.id,
        name: c.name,
        color: c.color,
      }))}
      questions={questions}
      examQuestions={examQuestions}
      examQuestionSlug={examQuestionSlug}
      initialProgress={progressMap}
      goalExamKey={examKey}
      examName={examName}
      initialGoal={initialGoal}
      initialTextbooks={initialTextbooks}
      dailyCapacity={dailyCapacity}
    />
  );
}
