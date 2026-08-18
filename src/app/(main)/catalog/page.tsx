import { getServerSupabase, getSessionUser } from "@/shared/lib/supabase/server";
import { groupSubjectsByExam } from "@/features/quiz/lib/stats";
import { fetchSubjectStats, toSubjectStats } from "@/features/quiz/lib/server-data";
import { CatalogClient } from "./catalog-client";

export const dynamic = "force-dynamic";

export default async function CatalogPage({
  searchParams,
}: {
  searchParams: Promise<{ subject?: string }>;
}) {
  const { subject: currentSlug } = await searchParams;
  const supabase = await getServerSupabase();
  const user = await getSessionUser();

  // 集計は DB 側（subject_stats）で済ませ、問題・進捗の全行はクライアントまで運ばない。
  const [{ data: subjects }, { stats }] = await Promise.all([
    supabase.from("subjects").select("id, slug, name").eq("is_active", true).order("sort_order"),
    fetchSubjectStats(supabase, user!.id),
  ]);

  const examGroups = groupSubjectsByExam(toSubjectStats(subjects ?? [], stats));

  return <CatalogClient examGroups={examGroups} currentSlug={currentSlug ?? null} />;
}
