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

  const { data: events, error: eventsError } = await supabase
    .from("answer_events")
    .select(
      "answered_at, is_correct, confidence, category_name, category_color, subject_slug"
    )
    .eq("user_id", user.id)
    .gte("answered_at", ninetyDaysAgo)
    .order("answered_at", { ascending: false })
    .limit(5000);

  let rows: {
    answered_at: string;
    is_correct: boolean;
    confidence: number | null;
    category_name: string;
    category_color: string;
    subject_slug: string;
  }[] = [];

  if (!eventsError) {
    rows = events ?? [];
  } else {
    // answer_events テーブル未作成時は user_question_progress で代替
    console.warn("[log] answer_events unavailable, falling back to user_question_progress:", eventsError.code);
    const { data: prog } = await supabase
      .from("user_question_progress")
      .select(
        "last_answered_at, last_is_correct, last_confidence, questions(categories(name, color), subjects(slug))"
      )
      .eq("user_id", user.id)
      .not("last_answered_at", "is", null)
      .gte("last_answered_at", ninetyDaysAgo)
      .order("last_answered_at", { ascending: false })
      .limit(5000);

    rows = (prog ?? []).map((p: any) => ({
      answered_at: p.last_answered_at as string,
      is_correct: p.last_is_correct ?? false,
      confidence: p.last_confidence ?? null,
      category_name: p.questions?.categories?.name ?? "不明",
      category_color: p.questions?.categories?.color ?? "#64748b",
      subject_slug: p.questions?.subjects?.slug ?? "",
    }));
  }

  // 単語カードの学習履歴も同じログに載せる（answer_events と同形にマージ）。
  const { data: fcEvents } = await supabase
    .from("flashcard_events")
    .select("answered_at, result, deck_key, cat, category_color")
    .eq("user_id", user.id)
    .gte("answered_at", ninetyDaysAgo)
    .order("answered_at", { ascending: false })
    .limit(5000);

  for (const e of fcEvents ?? []) {
    rows.push({
      answered_at: e.answered_at as string,
      is_correct: (e.result as string) === "k",
      confidence: null,
      category_name: (e.cat as string) ?? "単語",
      category_color: (e.category_color as string) ?? "#8892a4",
      subject_slug: (e.deck_key as string) ?? "",
    });
  }
  rows.sort((a, b) => b.answered_at.localeCompare(a.answered_at));

  return (
    <LogClient
      events={rows}
      todayKey={todayKey}
      yesterdayKey={yestKey}
      totalEvents={rows.length}
    />
  );
}
