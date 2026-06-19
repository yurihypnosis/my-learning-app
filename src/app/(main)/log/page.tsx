import { createServerSupabaseClient } from "@/lib/supabase/server";
import { LogClient } from "./log-client";

export const dynamic = "force-dynamic";

function todayJSTKey(): string {
  const now = new Date();
  const jst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  return jst.toISOString().slice(0, 10);
}

function yesterdayJSTKey(todayKey: string): string {
  const d = new Date(todayKey + "T00:00:00+09:00");
  d.setDate(d.getDate() - 1);
  return d.toISOString().slice(0, 10);
}

export default async function LogPage() {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const todayKey = todayJSTKey();
  const yestKey = yesterdayJSTKey(todayKey);

  if (!user) {
    return (
      <LogClient
        events={[]}
        todayKey={todayKey}
        yesterdayKey={yestKey}
        totalEvents={0}
      />
    );
  }

  // 直近90日のイベントを取得（最大5000件）
  const ninetyDaysAgo = new Date(
    new Date().getTime() - 90 * 24 * 60 * 60 * 1000
  ).toISOString();

  const { data: events } = await supabase
    .from("answer_events")
    .select(
      "answered_at, is_correct, confidence, category_name, category_color, subject_slug"
    )
    .eq("user_id", user.id)
    .gte("answered_at", ninetyDaysAgo)
    .order("answered_at", { ascending: false })
    .limit(5000);

  const rows = events ?? [];

  return (
    <LogClient
      events={rows}
      todayKey={todayKey}
      yesterdayKey={yestKey}
      totalEvents={rows.length}
    />
  );
}
