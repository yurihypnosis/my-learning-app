"use client";

import { useEffect, useReducer } from "react";
import type { FlashCard } from "@/features/flashcards/lib/flashcards";

// 表示専用のシャッフル（Fisher-Yates）。Start 押下時にだけ回すので SSR とはずれない。
function shuffled<T>(arr: T[]): T[] {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export type Phase = "setup" | "session" | "done";

type SessionState = {
  phase: Phase;
  queue: FlashCard[];
  idx: number;
  flipped: boolean;
  showPrecise: boolean;
  known: number;
  weakCards: FlashCard[];
  masteredAtStart: number;
};

type Action =
  | { type: "START_SESSION"; cards: FlashCard[]; count: number; masteredNow: number }
  | { type: "FLIP" }
  | { type: "TOGGLE_PRECISE" }
  | { type: "GRADE"; card: FlashCard; ok: boolean }
  | { type: "REPEAT_WEAK"; masteredNow: number }
  | { type: "BACK_TO_SETUP" };

const INITIAL: SessionState = {
  phase: "setup",
  queue: [],
  idx: 0,
  flipped: false,
  showPrecise: false,
  known: 0,
  weakCards: [],
  masteredAtStart: 0,
};

function beginSession(cards: FlashCard[], masteredNow: number): SessionState {
  return {
    phase: "session",
    queue: cards,
    idx: 0,
    flipped: false,
    showPrecise: false,
    known: 0,
    weakCards: [],
    masteredAtStart: masteredNow,
  };
}

function sessionReducer(s: SessionState, a: Action): SessionState {
  switch (a.type) {
    case "START_SESSION": {
      const take = a.count <= 0 ? a.cards.length : Math.min(a.count, a.cards.length);
      return beginSession(shuffled(a.cards).slice(0, take), a.masteredNow);
    }
    case "FLIP":
      return s.flipped ? s : { ...s, flipped: true, showPrecise: false };
    case "TOGGLE_PRECISE":
      return { ...s, showPrecise: !s.showPrecise };
    case "GRADE": {
      const known = a.ok ? s.known + 1 : s.known;
      const weakCards = a.ok ? s.weakCards : [...s.weakCards, a.card];
      const next = s.idx + 1;
      if (next >= s.queue.length) {
        return { ...s, known, weakCards, phase: "done" };
      }
      return { ...s, known, weakCards, idx: next, flipped: false, showPrecise: false };
    }
    case "REPEAT_WEAK":
      return beginSession(shuffled(s.weakCards), a.masteredNow);
    case "BACK_TO_SETUP":
      return { ...s, phase: "setup" };
  }
}

type Params = {
  deckKey: string;
  record: (deckKey: string, term: string, ok: boolean) => void;
  logEvent: (card: FlashCard, deckKey: string, ok: boolean) => void;
};

// カード学習セッションの状態機械（現在カード・めくり・自己評価・進行）。
// DB への進捗保存（record）とログ（logEvent）は副作用として grade() 内で呼ぶ。
export function useFlashcardSession({ deckKey, record, logEvent }: Params) {
  const [state, dispatch] = useReducer(sessionReducer, INITIAL);
  const { phase, queue, idx, flipped } = state;

  const start = (cards: FlashCard[], count: number, masteredNow: number) =>
    dispatch({ type: "START_SESSION", cards, count, masteredNow });

  const flip = () => dispatch({ type: "FLIP" });
  const togglePrecise = () => dispatch({ type: "TOGGLE_PRECISE" });

  const grade = (ok: boolean) => {
    const card = queue[idx];
    record(deckKey, card.term, ok); // 進捗を永続化
    logEvent(card, deckKey, ok); // 学習ログを1行残す
    dispatch({ type: "GRADE", card, ok });
  };

  const repeatWeak = (masteredNow: number) => dispatch({ type: "REPEAT_WEAK", masteredNow });
  const backToSetup = () => dispatch({ type: "BACK_TO_SETUP" });

  // キーボード操作: Space=めくる, 1=あやしい, 2=覚えていた
  useEffect(() => {
    if (phase !== "session") return;
    const onKey = (e: KeyboardEvent) => {
      if (e.code === "Space") {
        e.preventDefault();
        if (!flipped) flip();
      } else if (flipped && e.key === "1") {
        grade(false);
      } else if (flipped && e.key === "2") {
        grade(true);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
    // flip/grade は毎レンダー再生成される薄いラッパーで、実体は dispatch（安定）。
    // deps に含めると idx が進むたびにリスナーを張り直すだけで無意味なため、
    // 実際に効果を左右する値（phase/flipped/idx/queue）だけを列挙する。
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [phase, flipped, idx, queue]);

  return { ...state, start, flip, togglePrecise, grade, repeatWeak, backToSetup };
}
