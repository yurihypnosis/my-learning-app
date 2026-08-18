"use client";

import { useEffect, useReducer, useState } from "react";
import type { Progress, QuizQuestion } from "@/features/quiz/lib/types";
import { getProgress, shuffleOptions, type ProgressMap } from "@/features/quiz/lib/selection";
import { calcMasteryStats } from "@/features/quiz/lib/stats";
import { arraysEqual, fsrsFields } from "../lib/grading";
import type { PersistFn, RecordAnswerFn } from "./use-progress";
import type { Screen } from "./use-screen";

export type SessionResult = {
  id: string;
  correct: boolean;
  confidence: number | null;
  category: string;
  color: string;
};

// クイズ中の1問ごとの解答状態スナップショット（前後移動時の復元用）
type QState = {
  picked: number | null;
  multiSelected: number[];
  answered: boolean;
  confidence: number | null;
  choicesHidden: boolean;
};

type SessionState = {
  deck: QuizQuestion[];
  idx: number;
  picked: number | null;
  multiSelected: Set<number>;
  answered: boolean;
  confidence: number | null;
  choicesHidden: boolean;
  // 「前の問題に戻る」用: デッキ位置ごとに解答状態を保持し、行き来しても復元できるようにする
  qStates: Record<number, QState>;
  sessionResults: SessionResult[];
  memoText: string;
  sessionStartPassProb: number | null;
  // Speak-First の「声に出す」ペーシング用カウントダウン（3→0）。門ではなくキュー。
  speakCue: number;
};

type Action =
  | {
      type: "START_SESSION";
      deck: QuizQuestion[];
      choicesHidden: boolean;
      memo: string;
      passProb: number;
    }
  | { type: "PICK"; index: number }
  | { type: "TOGGLE_MULTI"; index: number }
  | { type: "SET_CONFIDENCE"; level: number }
  | { type: "REVEAL_CHOICES" }
  | { type: "ANSWER"; result: SessionResult }
  | { type: "GO_TO_INDEX"; target: number; memo: string; choicesHidden: boolean }
  | { type: "SET_MEMO"; text: string }
  | { type: "SET_SPEAK_CUE"; value: number };

const INITIAL: SessionState = {
  deck: [],
  idx: 0,
  picked: null,
  multiSelected: new Set(),
  answered: false,
  confidence: null,
  choicesHidden: false,
  qStates: {},
  sessionResults: [],
  memoText: "",
  sessionStartPassProb: null,
  speakCue: 0,
};

function snapshot(s: SessionState): QState {
  return {
    picked: s.picked,
    multiSelected: Array.from(s.multiSelected),
    answered: s.answered,
    confidence: s.confidence,
    choicesHidden: s.choicesHidden,
  };
}

export function sessionReducer(s: SessionState, a: Action): SessionState {
  switch (a.type) {
    case "START_SESSION":
      return {
        ...INITIAL,
        multiSelected: new Set(),
        qStates: {},
        sessionResults: [],
        deck: a.deck,
        choicesHidden: a.choicesHidden,
        memoText: a.memo,
        sessionStartPassProb: a.passProb,
      };
    case "PICK":
      return { ...s, picked: a.index };
    case "TOGGLE_MULTI": {
      if (s.answered) return s;
      const next = new Set(s.multiSelected);
      next.has(a.index) ? next.delete(a.index) : next.add(a.index);
      return { ...s, multiSelected: next };
    }
    case "SET_CONFIDENCE":
      return { ...s, confidence: a.level };
    case "REVEAL_CHOICES":
      return { ...s, choicesHidden: false };
    case "ANSWER":
      return { ...s, answered: true, sessionResults: [...s.sessionResults, a.result] };
    case "GO_TO_INDEX": {
      const qStates = { ...s.qStates, [s.idx]: snapshot(s) };
      const saved = s.qStates[a.target];
      return {
        ...s,
        qStates,
        idx: a.target,
        memoText: a.memo,
        picked: saved ? saved.picked : null,
        multiSelected: saved ? new Set(saved.multiSelected) : new Set(),
        answered: saved ? saved.answered : false,
        confidence: saved ? saved.confidence : null,
        choicesHidden: saved ? saved.choicesHidden : a.choicesHidden,
      };
    }
    case "SET_MEMO":
      return { ...s, memoText: a.text };
    case "SET_SPEAK_CUE":
      // 値が変わらないときは再レンダリングを起こさない（useState と同じ挙動）
      return s.speakCue === a.value ? s : { ...s, speakCue: a.value };
    default:
      // Action 型の網羅は switch 済み。型を迂回した呼び出しでも state を壊さない
      return s;
  }
}

type Params = {
  screen: Screen;
  setScreen: (s: Screen) => void;
  // 「セッション開始時の合格確率」の算出対象（現在の問題集）
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  persist: PersistFn;
  recordAnswer: RecordAnswerFn;
  recallMode: boolean;
  isSpeakFirstQ: (q: QuizQuestion) => boolean;
  // 現在セット以外の問題は本文だけを持っている（選択肢が空）。
  // 出題直前にサーバから全カラムを取り直すための解決関数。
  hydrate: (qs: QuizQuestion[]) => Promise<QuizQuestion[]>;
};

// 演習セッションの状態機械（出題列・解答・確信度・結果蓄積・前後移動）。
export function useQuizSession({
  screen,
  setScreen,
  questions,
  progressMap,
  persist,
  recordAnswer,
  recallMode,
  isSpeakFirstQ,
  hydrate,
}: Params) {
  const [state, dispatch] = useReducer(sessionReducer, INITIAL);
  const [deckLoading, setDeckLoading] = useState(false);
  const { deck, idx, picked, multiSelected, answered, confidence, choicesHidden, memoText } = state;

  // メモの自動保存（入力が止まって 800ms 後）
  useEffect(() => {
    if (!answered || !deck[idx]) return;
    const qid = deck[idx].id;
    const timer = setTimeout(() => {
      persist(qid, { memo: memoText });
    }, 800);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [memoText]);

  // Speak-First: 選択肢が隠れている間、3秒の口頭産出キューを刻む。
  // reveal/解答/移動で止まる。QState には入れない（未解答で戻ったら再スタートでよい）。
  useEffect(() => {
    const q = deck[idx];
    if (screen !== "quiz" || !q || !isSpeakFirstQ(q) || !choicesHidden || answered) {
      dispatch({ type: "SET_SPEAK_CUE", value: 0 });
      return;
    }
    dispatch({ type: "SET_SPEAK_CUE", value: 3 });
    const timers = [1, 2, 3].map((s) =>
      setTimeout(() => dispatch({ type: "SET_SPEAK_CUE", value: 3 - s }), s * 1000)
    );
    return () => timers.forEach(clearTimeout);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [screen, deck, idx, choicesHidden, answered]);

  // 出題列を確定してセッションを開始する。本文だけの軽量問題が混じっていれば
  // ここで全カラムを取り直す（選択肢のシャッフルは実データが揃ってから）。
  const enterQuiz = async (pool: QuizQuestion[], shuffleChoices = false) => {
    if (!pool.length) return;
    let deck = pool;
    if (pool.some((q) => q.options.length === 0)) {
      setDeckLoading(true);
      try {
        deck = await hydrate(pool);
      } finally {
        setDeckLoading(false);
      }
    }
    if (shuffleChoices) deck = deck.map(shuffleOptions);
    dispatch({
      type: "START_SESSION",
      deck,
      choicesHidden: recallMode || isSpeakFirstQ(deck[0]),
      memo: getProgress(progressMap, deck[0].id).memo,
      passProb: calcMasteryStats(questions, progressMap).passProb,
    });
    setScreen("quiz");
  };

  // 苦手問題など、指定した問題だけを復習するセッションを開始（選択肢はシャッフル）
  const startReview = (qs: QuizQuestion[]) => enterQuiz(qs, true);

  const submitAnswer = () => {
    if (answered || confidence === null) return;
    const q = deck[idx];
    const cur = getProgress(progressMap, q.id);
    const nowIso = new Date().toISOString();

    if (q.question_type === "multi") {
      if (multiSelected.size === 0) return;
      const selected = Array.from(multiSelected).sort((a, b) => a - b);
      const expected = [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b);
      const isCorrect = arraysEqual(selected, expected);
      const magure = isCorrect && confidence === 3;
      const base: Partial<Progress> = isCorrect
        ? { correct_count: cur.correct_count + 1, consecutive_correct: magure ? 0 : cur.consecutive_correct + 1, last_is_correct: true, last_answered_at: nowIso, last_confidence: confidence }
        : { wrong_count: cur.wrong_count + 1, consecutive_correct: 0, last_is_correct: false, last_answered_at: nowIso, last_confidence: confidence };
      const partial: Partial<Progress> = { ...base, ...fsrsFields(cur, isCorrect, confidence, Date.now()) };
      dispatch({
        type: "ANSWER",
        result: { id: q.id, correct: isCorrect, confidence, category: q.category_name, color: q.category_color },
      });
      persist(q.id, partial);
      recordAnswer(q, isCorrect, confidence);
    } else {
      if (picked === null) return;
      const isCorrect = picked === q.correct_index;
      const magure = isCorrect && confidence === 3;
      // 表示順でシャッフルしているため、保存は元(DB)のインデックスに戻す
      const selectedOrig = q.optionOrder ? q.optionOrder[picked] : picked;
      const base: Partial<Progress> = isCorrect
        ? { correct_count: cur.correct_count + 1, consecutive_correct: magure ? 0 : cur.consecutive_correct + 1, last_is_correct: true, last_selected_index: selectedOrig, last_answered_at: nowIso, last_confidence: confidence }
        : { wrong_count: cur.wrong_count + 1, consecutive_correct: 0, last_is_correct: false, last_selected_index: selectedOrig, last_answered_at: nowIso, last_confidence: confidence };
      const partial: Partial<Progress> = { ...base, ...fsrsFields(cur, isCorrect, confidence, Date.now()) };
      dispatch({
        type: "ANSWER",
        result: { id: q.id, correct: isCorrect, confidence, category: q.category_name, color: q.category_color },
      });
      persist(q.id, partial);
      recordAnswer(q, isCorrect, confidence);
    }
  };

  // デッキ内の任意の問題へ移動。現在の状態を保存し、移動先の状態を復元（なければ新規）
  const goToIndex = (target: number) => {
    if (target < 0 || target >= deck.length || target === idx) return;
    persist(deck[idx].id, { memo: memoText });
    window.scrollTo({ top: 0, behavior: "smooth" });
    const nq = deck[target];
    dispatch({
      type: "GO_TO_INDEX",
      target,
      memo: getProgress(progressMap, nq.id).memo,
      choicesHidden: recallMode || isSpeakFirstQ(nq),
    });
  };

  const saveMemoAndNext = () => {
    if (idx + 1 >= deck.length) {
      persist(deck[idx].id, { memo: memoText });
      window.scrollTo({ top: 0, behavior: "smooth" });
      setScreen("done");
      return;
    }
    goToIndex(idx + 1);
  };

  return {
    ...state,
    deckLoading,
    pick: (index: number) => dispatch({ type: "PICK", index }),
    toggleMulti: (index: number) => dispatch({ type: "TOGGLE_MULTI", index }),
    setConfidence: (level: number) => dispatch({ type: "SET_CONFIDENCE", level }),
    revealChoices: () => dispatch({ type: "REVEAL_CHOICES" }),
    setMemoText: (text: string) => dispatch({ type: "SET_MEMO", text }),
    enterQuiz,
    startReview,
    submitAnswer,
    goToIndex,
    saveMemoAndNext,
  };
}
