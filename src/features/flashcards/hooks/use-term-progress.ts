"use client";

import { useEffect, useState } from "react";
import { categoryColor, type FlashCard } from "@/features/flashcards/lib/flashcards";
import { useSupabaseClient } from "@/features/quiz/hooks/use-supabase-client";

// ── 学習進捗の永続化（DB: user_term_progress）──
// 用語ごとに直近の自己採点だけ見て「定着 / あやしい / 未学習」に振り分ける。
// 本人の行のみ RLS で読み書き。PC/モバイルで同期する。
export type TermRow = {
  deck_key: string;
  term: string;
  result: string; // 'k'=定着 | 'w'=あやしい
  known_count: number;
  weak_count: number;
};
export type TermStat = { r: "k" | "w"; k: number; w: number };
export type DeckProgress = Record<string, TermStat>;
export type Store = Record<string, DeckProgress>;
export type Status = "mastered" | "weak" | "new";

type Params = {
  userId: string | null;
  initialProgress: TermRow[];
};

// 単語カードの学習進捗（メモリ上の Store）と、その DB 読み書きを担う。
export function useTermProgress({ userId, initialProgress }: Params) {
  const supabase = useSupabaseClient();

  // ── 永続進捗（DBから受け取った初期値で seed。SSRと一致する）──
  const [store, setStore] = useState<Store>(() => {
    const s: Store = {};
    for (const r of initialProgress) {
      (s[r.deck_key] ??= {})[r.term] = {
        r: r.result === "k" ? "k" : "w",
        k: r.known_count,
        w: r.weak_count,
      };
    }
    return s;
  });

  // 有効なユーザーID。原則は SSR から渡る userId。だが SSR 時にトークンが未更新だと
  // userId=null / initialProgress=[] で描画され、学習済みの語が「未学習」に出戻る。
  // ブラウザ側クライアントは生きたセッションを持つので、マウント後にそこから本人を解決し直す。
  const [effUserId, setEffUserId] = useState<string | null>(userId);

  // マウント後、DBから自分の進捗を取り直して store を補完する（DBが正本）。
  // SSR が空／部分的だった場合でも、これで学習済みの語が確実に「未学習」から外れる。
  // PC・スマホどちらでも同じDBを読むのでクロスデバイスで一致する。
  useEffect(() => {
    let cancelled = false;
    void (async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (cancelled || !user) return;
      setEffUserId(user.id);
      const { data, error } = await supabase
        .from("user_term_progress")
        .select("deck_key, term, result, known_count, weak_count")
        .eq("user_id", user.id);
      if (cancelled || error || !data) return;
      // DB にあってローカル store に無い語だけを足す（進行中の採点を上書きしない）。
      setStore((prev) => {
        const next: Store = { ...prev };
        let changed = false;
        for (const r of data as TermRow[]) {
          const deckMap = next[r.deck_key];
          if (deckMap && r.term in deckMap) continue; // 既にある語はそのまま
          const merged = { ...(next[r.deck_key] ?? {}) };
          merged[r.term] = {
            r: r.result === "k" ? "k" : "w",
            k: r.known_count,
            w: r.weak_count,
          };
          next[r.deck_key] = merged;
          changed = true;
        }
        return changed ? next : prev;
      });
    })();
    return () => {
      cancelled = true;
    };
  }, [supabase]);

  // 用語1件の自己採点を反映（楽観的にローカル state を先に更新 → DBへ upsert）。
  const record = (deckKey: string, term: string, ok: boolean) => {
    const cur = store[deckKey]?.[term] ?? { r: "w" as const, k: 0, w: 0 };
    const next: TermStat = {
      r: ok ? "k" : "w",
      k: cur.k + (ok ? 1 : 0),
      w: cur.w + (ok ? 0 : 1),
    };
    setStore((prev) => ({
      ...prev,
      [deckKey]: { ...(prev[deckKey] ?? {}), [term]: next },
    }));
    if (effUserId) {
      void supabase
        .from("user_term_progress")
        .upsert(
          {
            user_id: effUserId,
            deck_key: deckKey,
            term,
            result: next.r,
            known_count: next.k,
            weak_count: next.w,
          },
          { onConflict: "user_id,deck_key,term" }
        )
        .then(({ error }) => {
          if (error) console.error("[term_progress] save failed:", error.message);
        });
    }
  };

  // 学習ログ用の履歴を1行残す（answer_events の単語版）。失敗はログのみ。
  const logEvent = (card: FlashCard, deckKey: string, ok: boolean) => {
    if (!effUserId) return;
    void supabase
      .from("flashcard_events")
      .insert({
        user_id: effUserId,
        deck_key: deckKey,
        cat: card.cat,
        category_color: categoryColor(card.cat),
        result: ok ? "k" : "w",
      })
      .then(({ error }) => {
        if (error) console.error("[flashcard_events] insert failed:", error.message);
      });
  };

  return { store, record, logEvent };
}
