import { createServerSupabaseClient } from "@/lib/supabase/server";
import { RoadmapClient } from "./roadmap-client";

export const dynamic = "force-dynamic";

export default async function RoadmapPage() {
  const supabase = await createServerSupabaseClient();
  const { data: { user } } = await supabase.auth.getUser();

  const { data: subject } = await supabase
    .from("subjects")
    .select("id")
    .eq("slug", "gcp-ace")
    .single();

  if (!subject || !user) {
    return <RoadmapClient acePassProb={null} />;
  }

  const [{ data: questions }, { data: progRows }] = await Promise.all([
    supabase
      .from("questions")
      .select("id")
      .eq("subject_id", subject.id)
      .eq("is_active", true),
    supabase
      .from("user_question_progress")
      .select("question_id, correct_count, wrong_count, last_confidence, consecutive_correct")
      .eq("user_id", user.id),
  ]);

  const qCount = questions?.length ?? 0;
  if (qCount === 0) return <RoadmapClient acePassProb={null} />;

  const progMap = new Map(
    (progRows ?? []).map((p) => [p.question_id, p])
  );

  let total = 0;
  for (const q of questions ?? []) {
    const p = progMap.get(q.id);
    if (!p) continue;
    const attempts = p.correct_count + p.wrong_count;
    if (attempts === 0) continue;
    const accuracy = p.correct_count / attempts;
    const selfScore =
      p.last_confidence === 1 ? 1.0 : p.last_confidence === 2 ? 0.5 : 0.0;
    const streakBonus = Math.min(p.consecutive_correct, 3) / 30;
    total += Math.min(1, accuracy * 0.6 + selfScore * 0.3 + streakBonus);
  }

  const avgMastery = total / qCount;
  const acePassProb = Math.max(5, Math.min(95, Math.round(avgMastery * 90 + 5)));

  return <RoadmapClient acePassProb={acePassProb} />;
}
