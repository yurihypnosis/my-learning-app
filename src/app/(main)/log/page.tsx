import { getServerSupabase, getSessionUser } from "@/shared/lib/supabase/server";
import { fetchAllRows } from "@/features/quiz/lib/server-data";
import { buildDays, calcStreak, shiftKey, type AnswerEvent } from "./build-days";
import { LogClient } from "./log-client";

export const dynamic = "force-dynamic";

const WINDOW_DAYS = 90;

function todayJSTKey(): string {
  const jst = new Date(Date.now() + 9 * 60 * 60 * 1000);
  return jst.toISOString().slice(0, 10);
}

export default async function LogPage() {
  const supabase = await getServerSupabase();
  const user = await getSessionUser();

  const todayKey = todayJSTKey();
  const yestKey = shiftKey(todayKey, -1);

  if (!user) {
    return <LogClient days={[]} streak={0} totalEvents={0} todayKey={todayKey} />;
  }

  // 集計対象は JST の暦日で 90 日前の 0 時から。todayKey 起点にして時刻依存を作らない。
  const since = `${shiftKey(todayKey, -WINDOW_DAYS)}T00:00:00+09:00`;

  // PostgREST の 1000行上限で切り捨てられないよう range で全件たどる。
  // 生イベントはここで日別に畳んでからクライアントへ渡す（従来は全件送っていた）。
  const answerRows = await fetchAllRows<AnswerEvent>((from, to) =>
    supabase
      .from("answer_events")
      .select("answered_at, is_correct, confidence, category_name, category_color, subject_slug")
      .eq("user_id", user.id)
      .gte("answered_at", since)
      .order("answered_at", { ascending: false })
      .range(from, to)
  );

  let rows: AnswerEvent[] = answerRows;

  // answer_events が未作成の環境では user_question_progress で代替する。
  if (rows.length === 0) {
    const { data: prog } = await supabase
      .from("user_question_progress")
      .select(
        "last_answered_at, last_is_correct, last_confidence, questions(categories(name, color), subjects(slug))"
      )
      .eq("user_id", user.id)
      .not("last_answered_at", "is", null)
      .gte("last_answered_at", since)
      .order("last_answered_at", { ascending: false })
      .limit(1000);

    rows = (prog ?? []).map((p) => {
      const q = p.questions as unknown as
        | { categories?: { name?: string; color?: string } | null; subjects?: { slug?: string } | null }
        | null;
      return {
        answered_at: p.last_answered_at as string,
        is_correct: p.last_is_correct ?? false,
        confidence: p.last_confidence ?? null,
        category_name: q?.categories?.name ?? "不明",
        category_color: q?.categories?.color ?? "#64748b",
        subject_slug: q?.subjects?.slug ?? "",
      };
    });
  }

  // 単語カードの学習履歴も同じログに載せる（answer_events と同形にマージ）。
  const fcRows = await fetchAllRows<{
    answered_at: string;
    result: string;
    deck_key: string | null;
    cat: string | null;
    category_color: string | null;
  }>((from, to) =>
    supabase
      .from("flashcard_events")
      .select("answered_at, result, deck_key, cat, category_color")
      .eq("user_id", user.id)
      .gte("answered_at", since)
      .order("answered_at", { ascending: false })
      .range(from, to)
  );

  for (const e of fcRows) {
    rows.push({
      answered_at: e.answered_at,
      is_correct: e.result === "k",
      confidence: null,
      category_name: e.cat ?? "単語",
      category_color: e.category_color ?? "#8892a4",
      subject_slug: e.deck_key ?? "",
    });
  }

  const days = buildDays(rows, todayKey, yestKey);

  return (
    <LogClient
      days={days}
      streak={calcStreak(days, todayKey)}
      totalEvents={rows.length}
      todayKey={todayKey}
    />
  );
}
