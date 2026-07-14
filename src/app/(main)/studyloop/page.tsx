import { createServerSupabaseClient } from "@/lib/supabase/server";
import type { ProgressMap } from "@/lib/quiz/selection";
import type { ExplanationData, Progress, QuizQuestion } from "@/lib/quiz/types";
import { StudyLoopClient } from "./studyloop-client";

export const dynamic = "force-dynamic";

export default async function StudyLoopPage({
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
        科目データがありません。Supabase にマイグレーションを適用してください。
      </div>
    );
  }

  const subject = subjects.find((s) => s.slug === subjectSlug) ?? subjects[0];

  const [{ data: categories }, { data: rawQuestions }, { data: rawProgress }, { data: events }] =
    await Promise.all([
      supabase
        .from("categories")
        .select("*")
        .eq("subject_id", subject.id)
        .order("sort_order"),
      supabase
        .from("questions")
        .select("*")
        .eq("subject_id", subject.id)
        .eq("is_active", true),
      supabase
        .from("user_question_progress")
        .select("*")
        .eq("user_id", user!.id),
      supabase
        .from("answer_events")
        .select("answered_at, is_correct, confidence, subject_slug")
        .eq("user_id", user!.id)
        .order("answered_at", { ascending: false })
        .limit(3000),
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
      question_type: ((q.question_type as string) === "multi" ? "multi" : "single") as
        | "single"
        | "multi",
      explanation: q.explanation ?? "",
      explanation_data: (q.explanation_data as ExplanationData | null) ?? null,
      initial_wrong_weight: q.initial_wrong_weight,
      category_id: q.category_id,
      category_name: cat?.name ?? "未分類",
      category_color: cat?.color ?? "#64748b",
    };
  });

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

  // ── 連続学習日数（全科目の answer_events から算出）──
  const dayKey = (d: Date) => `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
  const activeDays = new Set(
    (events ?? []).map((e) => dayKey(new Date(e.answered_at as string)))
  );
  let streakDays = 0;
  {
    const cur = new Date();
    if (!activeDays.has(dayKey(cur))) cur.setDate(cur.getDate() - 1);
    while (activeDays.has(dayKey(cur))) {
      streakDays++;
      cur.setDate(cur.getDate() - 1);
    }
  }

  // ── 確信度キャリブレーション（この科目）──
  // 確信度: 1=確信あり=「自信あり」、2/3/null=「自信なし」
  const calibration = { sureCorrect: 0, sureWrong: 0, unsureCorrect: 0, unsureWrong: 0 };
  for (const e of events ?? []) {
    if (e.subject_slug !== subject.slug) continue;
    const sure = e.confidence === 1;
    if (e.is_correct) sure ? calibration.sureCorrect++ : calibration.unsureCorrect++;
    else sure ? calibration.sureWrong++ : calibration.unsureWrong++;
  }

  return (
    <StudyLoopClient
      userId={user!.id}
      subjects={subjects.map((s) => ({ slug: s.slug, name: s.name }))}
      currentSubjectSlug={subject.slug}
      subjectName={subject.name}
      categories={(categories ?? []).map((c) => ({
        id: c.id,
        name: c.name,
        color: c.color,
      }))}
      questions={questions}
      initialProgress={progressMap}
      streakDays={streakDays}
      calibration={calibration}
    />
  );
}
