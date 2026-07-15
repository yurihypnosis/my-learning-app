import { NextResponse } from "next/server";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import { type Card, gradeFromAnswer, newCard, review } from "@/lib/quiz/fsrs";

export const dynamic = "force-dynamic";

// 過去の answer_events を時系列でリプレイし、各問題の FSRS 状態(S/D/due)を
// まとめて再構築する。既存の演習済み問題を一括で FSRS 化するための一回きり操作
// （冪等：何度実行しても履歴から再計算する）。本人のセッションで実行され、RLS で
// 自分の行だけを読み書きする。
export async function POST() {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  const { data: events, error } = await supabase
    .from("answer_events")
    .select("question_id, is_correct, confidence, answered_at")
    .eq("user_id", user.id)
    .order("answered_at", { ascending: true })
    .limit(100000);
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  // 問題ごとにカードを時系列で再構築
  const cards = new Map<string, Card>();
  for (const e of events ?? []) {
    const grade = gradeFromAnswer(!!e.is_correct, (e.confidence as number | null) ?? null);
    const nowMs = Date.parse(e.answered_at as string);
    if (Number.isNaN(nowMs)) continue;
    const cur = cards.get(e.question_id) ?? newCard();
    cards.set(e.question_id, review(cur, grade, nowMs));
  }

  // user_question_progress の該当行に fsrs_* を書き戻す（並列・チャンク）
  const entries = [...cards.entries()];
  let updated = 0;
  const CHUNK = 25;
  for (let i = 0; i < entries.length; i += CHUNK) {
    const results = await Promise.all(
      entries.slice(i, i + CHUNK).map(async ([qid, card]) => {
        const { error: e2 } = await supabase
          .from("user_question_progress")
          .update({
            fsrs_stability: card.stability,
            fsrs_difficulty: card.difficulty,
            fsrs_due: card.due,
            fsrs_last_review: card.lastReview,
            fsrs_reps: card.reps,
            fsrs_lapses: card.lapses,
            fsrs_state: card.state,
          })
          .eq("user_id", user.id)
          .eq("question_id", qid);
        return !e2;
      })
    );
    updated += results.filter(Boolean).length;
  }

  return NextResponse.json({ questions: cards.size, updated, events: events?.length ?? 0 });
}
