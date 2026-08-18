import { redirect } from "next/navigation";
import { getServerSupabase, getSessionUser } from "@/shared/lib/supabase/server";
import { AppShell, type ShellExam } from "@/shared/components/app-shell";
import {
  buildSubjectStats,
  groupSubjectsByExam,
} from "@/features/quiz/lib/stats";

export default async function MainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // クライアント生成と getUser() はページ側と同じリクエスト内で共有される（React cache）。
  const supabase = await getServerSupabase();
  const user = await getSessionUser();

  if (!user) redirect("/login");

  // トップバーの問題集スイッチャ用。進捗は不要なので slug/name だけを読み、
  // 試験区分（複数セットを束ねた単位）にまとめて渡す。
  const { data: subjects } = await supabase
    .from("subjects")
    .select("slug, name")
    .eq("is_active", true)
    .order("sort_order");

  const exams: ShellExam[] = groupSubjectsByExam(
    buildSubjectStats(subjects ?? [], [], {})
  ).map((g) => ({
    examKey: g.examKey,
    examName: g.examName,
    sets: g.sets.map((s) => ({ slug: s.slug, name: s.name })),
  }));

  return (
    <AppShell email={user.email ?? null} exams={exams}>
      {children}
    </AppShell>
  );
}
