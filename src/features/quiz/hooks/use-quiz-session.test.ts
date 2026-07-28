import { describe, expect, it } from "vitest";
import { sessionReducer, type SessionResult } from "./use-quiz-session";
import type { QuizQuestion } from "@/features/quiz/lib/types";

// テスト用の最小 QuizQuestion（reducer は options/explanation の中身を見ないため空でよい）
function q(id: string): QuizQuestion {
  return {
    id,
    source_ref: id,
    question_text: "",
    code: null,
    options: [],
    correct_index: 0,
    correct_indices: null,
    question_type: "single",
    explanation: "",
    explanation_data: null,
    initial_wrong_weight: 0,
    category_id: "c",
    category_name: "c",
    category_color: "#000",
  };
}

function result(id: string, correct: boolean, confidence: number | null = 1): SessionResult {
  return { id, correct, confidence, category: "c", color: "#000" };
}

// reducer は module 内で private な SessionState/Action 型しか公開していないため、
// dispatch する Action はリテラルで組み立てる（as を使わない範囲で型推論に任せる）。
describe("sessionReducer", () => {
  describe("START_SESSION", () => {
    it("initializes state from the given deck/memo/passProb and resets prior session data", () => {
      const deck = [q("a"), q("b")];
      const prev = sessionReducer(undefined as never, {
        type: "START_SESSION",
        deck: [q("z")],
        choicesHidden: true,
        memo: "old",
        passProb: 0.1,
      });
      // 2周目の START_SESSION が前回セッションの qStates/sessionResults を確実にクリアすることを確認
      const primed = sessionReducer(
        { ...prev, qStates: { 0: { picked: 1, multiSelected: [], answered: true, confidence: 1, choicesHidden: false } }, sessionResults: [result("z", true)] },
        {
          type: "START_SESSION",
          deck,
          choicesHidden: false,
          memo: "hello",
          passProb: 0.42,
        }
      );

      expect(primed.deck).toBe(deck);
      expect(primed.idx).toBe(0);
      expect(primed.picked).toBeNull();
      expect(primed.multiSelected).toEqual(new Set());
      expect(primed.answered).toBe(false);
      expect(primed.confidence).toBeNull();
      expect(primed.choicesHidden).toBe(false);
      expect(primed.qStates).toEqual({});
      expect(primed.sessionResults).toEqual([]);
      expect(primed.memoText).toBe("hello");
      expect(primed.sessionStartPassProb).toBe(0.42);
      expect(primed.speakCue).toBe(0);
    });
  });

  describe("PICK / TOGGLE_MULTI", () => {
    const base = sessionReducer(undefined as never, {
      type: "START_SESSION",
      deck: [q("a")],
      choicesHidden: false,
      memo: "",
      passProb: 0,
    });

    it("PICK replaces the single selection", () => {
      const s1 = sessionReducer(base, { type: "PICK", index: 2 });
      expect(s1.picked).toBe(2);
      const s2 = sessionReducer(s1, { type: "PICK", index: 0 });
      expect(s2.picked).toBe(0);
    });

    it("TOGGLE_MULTI adds then removes an index", () => {
      const s1 = sessionReducer(base, { type: "TOGGLE_MULTI", index: 1 });
      expect(Array.from(s1.multiSelected)).toEqual([1]);
      const s2 = sessionReducer(s1, { type: "TOGGLE_MULTI", index: 3 });
      expect(Array.from(s2.multiSelected).sort()).toEqual([1, 3]);
      const s3 = sessionReducer(s2, { type: "TOGGLE_MULTI", index: 1 });
      expect(Array.from(s3.multiSelected)).toEqual([3]);
    });

    it("TOGGLE_MULTI is a no-op once the question is answered", () => {
      const answered = { ...base, answered: true };
      const s1 = sessionReducer(answered, { type: "TOGGLE_MULTI", index: 1 });
      expect(s1).toBe(answered);
      expect(Array.from(s1.multiSelected)).toEqual([]);
    });
  });

  describe("SET_CONFIDENCE / REVEAL_CHOICES", () => {
    const base = sessionReducer(undefined as never, {
      type: "START_SESSION",
      deck: [q("a")],
      choicesHidden: true,
      memo: "",
      passProb: 0,
    });

    it("SET_CONFIDENCE sets the confidence level", () => {
      const s1 = sessionReducer(base, { type: "SET_CONFIDENCE", level: 2 });
      expect(s1.confidence).toBe(2);
    });

    it("REVEAL_CHOICES unhides choices", () => {
      expect(base.choicesHidden).toBe(true);
      const s1 = sessionReducer(base, { type: "REVEAL_CHOICES" });
      expect(s1.choicesHidden).toBe(false);
    });
  });

  describe("ANSWER", () => {
    it("marks answered and appends the result, preserving prior results", () => {
      const base = sessionReducer(undefined as never, {
        type: "START_SESSION",
        deck: [q("a"), q("b")],
        choicesHidden: false,
        memo: "",
        passProb: 0,
      });
      const r1 = result("a", true);
      const s1 = sessionReducer(base, { type: "ANSWER", result: r1 });
      expect(s1.answered).toBe(true);
      expect(s1.sessionResults).toEqual([r1]);

      const r2 = result("b", false, 3);
      const s2 = sessionReducer(s1, { type: "ANSWER", result: r2 });
      expect(s2.sessionResults).toEqual([r1, r2]);
      // 元の配列は不変（イミュータブル更新）
      expect(s1.sessionResults).toEqual([r1]);
    });
  });

  describe("GO_TO_INDEX", () => {
    function started() {
      return sessionReducer(undefined as never, {
        type: "START_SESSION",
        deck: [q("a"), q("b"), q("c")],
        choicesHidden: false,
        memo: "memo-0",
        passProb: 0,
      });
    }

    it("snapshots the current question's state and moves to a fresh target with the given memo/choicesHidden", () => {
      const base = started();
      const answered = sessionReducer(
        sessionReducer(base, { type: "PICK", index: 1 }),
        { type: "ANSWER", result: result("a", true) }
      );

      const moved = sessionReducer(answered, {
        type: "GO_TO_INDEX",
        target: 1,
        memo: "memo-1",
        choicesHidden: true,
      });

      expect(moved.idx).toBe(1);
      expect(moved.memoText).toBe("memo-1");
      // target=1 は未訪問なので保存済みスナップショットが無く、デフォルトへリセット
      expect(moved.picked).toBeNull();
      expect(moved.multiSelected).toEqual(new Set());
      expect(moved.answered).toBe(false);
      expect(moved.confidence).toBeNull();
      expect(moved.choicesHidden).toBe(true);
      // 元の位置(0)の状態がスナップショットとして保存されている
      expect(moved.qStates[0]).toEqual({
        picked: 1,
        multiSelected: [],
        answered: true,
        confidence: null,
        choicesHidden: false,
      });
    });

    it("restores a previously visited question's snapshot when navigating back to it", () => {
      const base = started();
      const onQ0 = sessionReducer(base, { type: "PICK", index: 2 });
      const onQ1 = sessionReducer(onQ0, {
        type: "GO_TO_INDEX",
        target: 1,
        memo: "memo-1",
        choicesHidden: false,
      });
      // q1 で別の選択をしてから q0 に戻る
      const onQ1Picked = sessionReducer(onQ1, { type: "PICK", index: 0 });
      const backToQ0 = sessionReducer(onQ1Picked, {
        type: "GO_TO_INDEX",
        target: 0,
        memo: "memo-0",
        choicesHidden: false,
      });

      expect(backToQ0.idx).toBe(0);
      expect(backToQ0.picked).toBe(2); // q0 で選んだ値が復元される
      // q1 のスナップショットも保存されている
      expect(backToQ0.qStates[1]).toEqual({
        picked: 0,
        multiSelected: [],
        answered: false,
        confidence: null,
        choicesHidden: false,
      });
    });

    it("does not itself clamp/reject an out-of-range target — that guard lives in the goToIndex caller, not the reducer", () => {
      const base = started();
      // reducer 単体には範囲チェックが無いことを固定化する（呼び出し側の goToIndex 関数が
      // target<0 || target>=deck.length を弾いてから dispatch している）
      const moved = sessionReducer(base, {
        type: "GO_TO_INDEX",
        target: 99,
        memo: "oob",
        choicesHidden: false,
      });
      expect(moved.idx).toBe(99);
      expect(moved.memoText).toBe("oob");
    });
  });

  describe("SET_MEMO", () => {
    it("sets memoText", () => {
      const base = sessionReducer(undefined as never, {
        type: "START_SESSION",
        deck: [q("a")],
        choicesHidden: false,
        memo: "",
        passProb: 0,
      });
      const s1 = sessionReducer(base, { type: "SET_MEMO", text: "note" });
      expect(s1.memoText).toBe("note");
    });
  });

  describe("SET_SPEAK_CUE", () => {
    const base = sessionReducer(undefined as never, {
      type: "START_SESSION",
      deck: [q("a")],
      choicesHidden: false,
      memo: "",
      passProb: 0,
    });

    it("updates speakCue when the value changes", () => {
      const s1 = sessionReducer(base, { type: "SET_SPEAK_CUE", value: 3 });
      expect(s1.speakCue).toBe(3);
      expect(s1).not.toBe(base);
    });

    it("bypasses the update and returns the identical state reference when the value is unchanged", () => {
      const s1 = sessionReducer(base, { type: "SET_SPEAK_CUE", value: 0 });
      expect(s1).toBe(base); // 参照同一性: 同値なら再レンダリングを起こさない
    });
  });

  describe("unknown action safety", () => {
    it("returns the current state unchanged for an action type the switch doesn't handle", () => {
      const base = sessionReducer(undefined as never, {
        type: "START_SESSION",
        deck: [q("a")],
        choicesHidden: false,
        memo: "",
        passProb: 0,
      });
      // 型を迂回した未知の action でも state を壊さない（default: return s）。
      const bogus = { type: "NOT_A_REAL_ACTION" } as unknown as Parameters<typeof sessionReducer>[1];
      const out = sessionReducer(base, bogus);
      expect(out).toBe(base);
    });
  });
});
