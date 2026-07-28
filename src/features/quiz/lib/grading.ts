import type { Progress } from "@/features/quiz/lib/types";
import { type Card, gradeFromAnswer, review } from "@/features/quiz/lib/fsrs";

// 複数選択の一致判定（呼び出し側でソート済みの前提）
export function arraysEqual(a: number[], b: number[]): boolean {
  return a.length === b.length && a.every((v, i) => v === b[i]);
}

// 進捗行 → FSRS カード。列が無い/未学習なら new。
export function cardFromProgress(p: Progress): Card {
  return {
    stability: p.fsrs_stability ?? 0,
    difficulty: p.fsrs_difficulty ?? 0,
    reps: p.fsrs_reps ?? 0,
    lapses: p.fsrs_lapses ?? 0,
    lastReview: p.fsrs_last_review ?? null,
    due: p.fsrs_due ?? null,
    state: p.fsrs_state === "review" ? "review" : "new",
  };
}

// 1 解答分の FSRS 更新を Progress の部分更新として返す。
export function fsrsFields(
  cur: Progress,
  isCorrect: boolean,
  conf: number | null,
  nowMs: number
): Partial<Progress> {
  const card = review(cardFromProgress(cur), gradeFromAnswer(isCorrect, conf), nowMs);
  return {
    fsrs_stability: card.stability,
    fsrs_difficulty: card.difficulty,
    fsrs_due: card.due,
    fsrs_last_review: card.lastReview,
    fsrs_reps: card.reps,
    fsrs_lapses: card.lapses,
    fsrs_state: card.state,
  };
}
