import { createServerSupabaseClient } from "@/shared/lib/supabase/server";
import {
  DEFAULT_ROADMAP,
  defaultDocWithLegacyDone,
  isRoadmapDoc,
  type RoadmapDoc,
} from "@/features/roadmap/lib/roadmap";
import { RoadmapClient } from "./roadmap-client";

export const dynamic = "force-dynamic";

export default async function RoadmapPage() {
  const supabase = await createServerSupabaseClient();
  const { data: { user } } = await supabase.auth.getUser();
  const userId = user?.id ?? "";

  // ロードマップ本体（ユーザー編集可能・DB）。無ければ既定＋旧完了状態を引き継ぐ。
  let initialDoc: RoadmapDoc = DEFAULT_ROADMAP;
  if (user) {
    const { data: row } = await supabase
      .from("user_roadmap")
      .select("doc")
      .eq("user_id", user.id)
      .maybeSingle();
    if (row && isRoadmapDoc(row.doc)) {
      initialDoc = row.doc as unknown as RoadmapDoc;
    } else {
      const { data: legacy } = await supabase
        .from("user_roadmap_items")
        .select("item_key, done")
        .eq("user_id", user.id);
      const map: Record<string, boolean> = {};
      for (const r of legacy ?? []) map[r.item_key] = r.done;
      initialDoc = defaultDocWithLegacyDone(map);
    }
  }

  // 試験日サマリ用: 各試験区分の試験日（user_exam_goals）
  let examGoals: { examKey: string; examDate: string; targetName: string }[] = [];
  if (user) {
    const { data: goalRows } = await supabase
      .from("user_exam_goals")
      .select("exam_key, exam_date, target_name")
      .eq("user_id", user.id);
    examGoals = (goalRows ?? [])
      .filter((g) => !!g.exam_date)
      .map((g) => ({
        examKey: g.exam_key,
        examDate: g.exam_date as string,
        targetName: g.target_name ?? g.exam_key,
      }));
  }

  // GCP ACE の合格確率（ACE マイルストンのバー用）
  let acePassProb: number | null = null;
  const { data: subject } = await supabase
    .from("subjects")
    .select("id")
    .eq("slug", "gcp-ace")
    .single();

  if (subject && user) {
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
    if (qCount > 0) {
      const progMap = new Map((progRows ?? []).map((p) => [p.question_id, p]));
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
      acePassProb = Math.max(5, Math.min(95, Math.round(avgMastery * 90 + 5)));
    }
  }

  return (
    <RoadmapClient
      acePassProb={acePassProb}
      userId={userId}
      initialDoc={initialDoc}
      examGoals={examGoals}
    />
  );
}
