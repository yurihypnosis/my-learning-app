"use client";

import { useCallback, useMemo, useState } from "react";
import { FLASHCARD_DECKS, type FlashDeck } from "@/features/flashcards/lib/flashcards";
import type { Status, Store } from "./use-term-progress";

export type Scope = "all" | "weak" | "new";

type Params = {
  store: Store;
};

// 単語カード画面（setup）の出題設定（デッキ・分野・範囲・枚数）と、そこから決まる出題対象。
export function useDeckFilter({ store }: Params) {
  const [deck, setDeck] = useState<FlashDeck>(FLASHCARD_DECKS[0]);
  const [selCat, setSelCat] = useState<string | null>(null); // null=全分野
  const [scope, setScope] = useState<Scope>("all");
  const [count, setCount] = useState<number>(20);

  const switchDeck = (d: FlashDeck) => {
    setDeck(d);
    setSelCat(null);
    setScope("all");
  };

  // 進捗を useMemo で安定させ、statusOf 依存の各所が毎レンダー再計算にならないようにする。
  const deckProg = useMemo(() => store[deck.key] ?? {}, [store, deck]);
  const statusOf = useCallback(
    (term: string): Status => {
      const s = deckProg[term];
      return !s ? "new" : s.r === "k" ? "mastered" : "weak";
    },
    [deckProg]
  );

  const cats = useMemo(() => {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const c of deck.cards) {
      if (!seen.has(c.cat)) {
        seen.add(c.cat);
        out.push(c.cat);
      }
    }
    return out;
  }, [deck]);

  const catCount = (cat: string) => deck.cards.filter((c) => c.cat === cat).length;

  // 現在の分野フィルタを反映したカード集合。範囲(scope)と進捗の数はこれを基準にする。
  const catCards = useMemo(
    () => (selCat ? deck.cards.filter((c) => c.cat === selCat) : deck.cards),
    [deck, selCat]
  );

  const counts = useMemo(() => {
    let mastered = 0,
      weak = 0,
      neu = 0;
    for (const c of catCards) {
      const st = statusOf(c.term);
      if (st === "mastered") mastered++;
      else if (st === "weak") weak++;
      else neu++;
    }
    return { mastered, weak, new: neu, total: catCards.length };
  }, [catCards, statusOf]);

  const pool = useMemo(() => {
    if (scope === "weak") return catCards.filter((c) => statusOf(c.term) === "weak");
    if (scope === "new") return catCards.filter((c) => statusOf(c.term) === "new");
    return catCards;
  }, [catCards, scope, statusOf]);

  const scopeLabel = scope === "weak" ? "苦手" : scope === "new" ? "未学習" : "全部";

  return {
    deck,
    switchDeck,
    selCat,
    setSelCat,
    scope,
    setScope,
    count,
    setCount,
    cats,
    catCount,
    counts,
    pool,
    scopeLabel,
  };
}
