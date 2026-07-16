import { describe, expect, it } from "vitest";
import { weakReviewPool } from "./stats";
import type { ProgressMap } from "./selection";
import { emptyProgress, type Progress, type QuizQuestion } from "./types";

// テスト用の最小 QuizQuestion。苦手判定は Progress にしか依存しないため、
// 本文・選択肢は空でよい（initial_wrong_weight だけ弱点スコアに効く）。
function q(id: string, initialWrongWeight = 0): QuizQuestion {
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
    initial_wrong_weight: initialWrongWeight,
    category_id: "c",
    category_name: "c",
    category_color: "#000",
  };
}

function prog(id: string, patch: Partial<Progress>): Progress {
  return { ...emptyProgress(id), ...patch };
}

describe("weakReviewPool", () => {
  it("excludes never-attempted questions", () => {
    const questions = [q("a"), q("b")];
    const map: ProgressMap = {}; // 全問未着手
    expect(weakReviewPool(questions, map)).toEqual([]);
  });

  it("excludes an attempted question that is confidently mastered", () => {
    const questions = [q("a")];
    // 3回連続正解・確信あり → mastery 高（>=0.5）かつ誤答なし → 対象外
    const map: ProgressMap = {
      a: prog("a", {
        correct_count: 3,
        consecutive_correct: 3,
        last_is_correct: true,
        last_confidence: 1,
      }),
    };
    expect(weakReviewPool(questions, map)).toEqual([]);
  });

  it("includes a question that has ever been wrong even if mastery recovered", () => {
    const questions = [q("a")];
    const map: ProgressMap = {
      a: prog("a", { correct_count: 5, wrong_count: 1, last_is_correct: true, last_confidence: 1 }),
    };
    // wrong_count>0 なので「間違えた」に該当
    expect(weakReviewPool(questions, map).map((x) => x.id)).toEqual(["a"]);
  });

  it("includes a low-mastery question with no wrong answers (weak by score)", () => {
    const questions = [q("a")];
    // 1回だけ正解だが確信度=勘(3) → mastery = 0.6 のみ… 正解率1.0*0.6=0.6 >=0.5 → 除外されるはず
    // 迷い(2)で1回正解 → 0.6+0.15=0.75 → 除外。ここは「勘で正解」を弱点として拾えることを確認するため
    // wrong はないが mastery < 0.5 を作る: 未確信かつ正解率が低いケース
    const map: ProgressMap = {
      a: prog("a", { correct_count: 1, wrong_count: 1, last_is_correct: true, last_confidence: 3 }),
    };
    // 正解率 0.5*0.6=0.3 + 0 = 0.3 < 0.5 かつ wrong_count>0 → 対象
    expect(weakReviewPool(questions, map).map((x) => x.id)).toEqual(["a"]);
  });

  it("sorts worst-first by wrongness score and honors limit", () => {
    const questions = [q("mild"), q("worst"), q("mid")];
    const map: ProgressMap = {
      mild: prog("mild", { correct_count: 3, wrong_count: 1, last_is_correct: false }),
      worst: prog("worst", { correct_count: 0, wrong_count: 5, last_is_correct: false }),
      mid: prog("mid", { correct_count: 1, wrong_count: 3, last_is_correct: false }),
    };
    const ranked = weakReviewPool(questions, map).map((x) => x.id);
    expect(ranked).toEqual(["worst", "mid", "mild"]);
    expect(weakReviewPool(questions, map, { limit: 2 }).map((x) => x.id)).toEqual(["worst", "mid"]);
  });

  it("counts模試由来の初期誤答(initial_wrong_weight) toward wrongness", () => {
    const questions = [q("seeded", 4)];
    // 一度解答済み(正解)だが initial_wrong_weight が高い → スコアで拾う。ただし
    // 「間違えた/苦手」条件（wrong_count>0 か mastery<0.5）を満たす必要がある。
    // ここは確信度なし正解1回で mastery=0.6 → 除外されることを確認（初期重みだけでは拾わない）。
    const map: ProgressMap = {
      seeded: prog("seeded", { correct_count: 1, last_is_correct: true, last_confidence: 2 }),
    };
    // mastery = 1.0*0.6 + 0.5*0.3 = 0.75 >= 0.5, wrong_count=0 → 対象外
    expect(weakReviewPool(questions, map)).toEqual([]);
  });
});
