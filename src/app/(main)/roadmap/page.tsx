import { getServerSupabase, getSessionUser } from "@/shared/lib/supabase/server";
import { fetchFamilyProgress } from "@/features/quiz/lib/server-data";
import type { ProgressMap } from "@/features/quiz/lib/selection";
import {
  DEFAULT_ROADMAP,
  defaultDocWithLegacyDone,
  isRoadmapDoc,
  type RoadmapDoc,
} from "@/features/roadmap/lib/roadmap";
import { RoadmapClient } from "./roadmap-client";

export const dynamic = "force-dynamic";

export default async function RoadmapPage() {
  const supabase = await getServerSupabase();
  const user = await getSessionUser();
  const userId = user?.id ?? "";

  if (!user) {
    return (
      <RoadmapClient acePassProb={null} userId="" initialDoc={DEFAULT_ROADMAP} examGoals={[]} />
    );
  }

  // ── 第1波: 互いに独立な3つを並列で ──
  const [{ data: roadmapRow }, { data: goalRows }, { data: aceSubject }] = await Promise.all([
    supabase.from("user_roadmap").select("doc").eq("user_id", user.id).maybeSingle(),
    supabase
      .from("user_exam_goals")
      .select("exam_key, exam_date, target_name")
      .eq("user_id", user.id),
    supabase.from("subjects").select("id").eq("slug", "gcp-ace").maybeSingle(),
  ]);

  // ロードマップ本体（ユーザー編集可能・DB）。無ければ既定＋旧完了状態を引き継ぐ。
  let initialDoc: RoadmapDoc = DEFAULT_ROADMAP;
  let needsLegacy = false;
  if (roadmapRow && isRoadmapDoc(roadmapRow.doc)) {
    initialDoc = roadmapRow.doc as unknown as RoadmapDoc;
  } else {
    needsLegacy = true;
  }

  // 試験日サマリ用: 各試験区分の試験日（user_exam_goals）
  const examGoals = (goalRows ?? [])
    .filter((g) => !!g.exam_date)
    .map((g) => ({
      examKey: g.exam_key,
      examDate: g.exam_date as string,
      targetName: g.target_name ?? g.exam_key,
    }));

  // ── 第2波: ACE の合格確率に必要なもの＋（必要なら）旧完了状態 ──
  // 進捗は ACE の問題ぶんだけ引く。以前は全問題の進捗（1,355件）を取っており、
  // PostgREST の 1000行上限で切り捨てられて確率がずれていた。
  const aceId = aceSubject?.id ?? null;
  const [qCountRes, aceProgress, legacyRes] = await Promise.all([
    aceId
      ? supabase
          .from("questions")
          .select("id", { count: "exact", head: true })
          .eq("subject_id", aceId)
          .eq("is_active", true)
      : Promise.resolve({ count: 0 }),
    aceId
      ? fetchFamilyProgress(supabase, user.id, [aceId])
      : Promise.resolve({} as ProgressMap),
    needsLegacy
      ? supabase.from("user_roadmap_items").select("item_key, done").eq("user_id", user.id)
      : Promise.resolve({ data: null }),
  ]);

  if (needsLegacy) {
    const map: Record<string, boolean> = {};
    for (const r of legacyRes.data ?? []) map[r.item_key] = r.done;
    initialDoc = defaultDocWithLegacyDone(map);
  }

  // GCP ACE の合格確率（ACE マイルストンのバー用）
  let acePassProb: number | null = null;
  const qCount = qCountRes.count ?? 0;
  if (qCount > 0) {
    let total = 0;
    for (const p of Object.values(aceProgress)) {
      const attempts = p.correct_count + p.wrong_count;
      if (attempts === 0) continue;
      const accuracy = p.correct_count / attempts;
      const selfScore = p.last_confidence === 1 ? 1.0 : p.last_confidence === 2 ? 0.5 : 0.0;
      const streakBonus = Math.min(p.consecutive_correct, 3) / 30;
      total += Math.min(1, accuracy * 0.6 + selfScore * 0.3 + streakBonus);
    }
    acePassProb = Math.max(5, Math.min(95, Math.round((total / qCount) * 90 + 5)));
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
