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

  // subject 固有データ
  const [{ data: categories }, { data: rawQuestions }] = await Promise.all([
    supabase.from("categories").select("*").eq("subject_id", subject.id).order("sort_order"),
    supabase.from("questions").select("*").eq("subject_id", subject.id).eq("is_active", true),
  ]);

  const catMap = new Map((categories ?? []).map((c) => [c.id, c]));

  const questions: QuizQuestion[] = (rawQuestions ?? []).map((q) => {
    const cat = catMap.get(q.category_id);
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
  });
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
  const examKey = examGroupKey(subject.slug);
  const examSetIds = new Set(
    subjects.filter((s) => examGroupKey(s.slug) === examKey).map((s) => s.id)
  );
  const { data: examCats } = await supabase
    .from("categories")
    .select("id, name, color, sort_order")
    .in("subject_id", [...examSetIds]);
  const examCatMap = new Map((examCats ?? []).map((c) => [c.id, c]));
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
      initialProgress={progressMap}
      goalExamKey={examKey}
      examName={examName}
      initialGoal={initialGoal}
    />
  );
}
