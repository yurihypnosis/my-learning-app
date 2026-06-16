// 理解度フラグ（0=未評価, 1..4）。元 jsx の FLAGS/FLAG_COLORS を踏襲
export const FLAGS = ["未評価", "全く分からない", "怪しい", "だいたい理解", "完璧"] as const;
export const FLAG_COLORS = ["#64748b", "#dc2626", "#f59e0b", "#3b82f6", "#16a34a"] as const;

export const WEEK_MS = 7 * 24 * 60 * 60 * 1000;
export const TWO_WEEKS_MS = 14 * 24 * 60 * 60 * 1000;

export type QuizMode = "shuffle" | "priority";

// DB の questions + categories を結合したクイズ用の問題
export interface QuizQuestion {
  id: string;
  source_ref: string | null;
  question_text: string;
  options: string[];
  correct_index: number;
  explanation: string;
  initial_wrong_weight: number;
  category_id: string;
  category_name: string;
  category_color: string;
}

// user_question_progress のうちクイズ判定に使う部分
export interface Progress {
  question_id: string;
  correct_count: number;
  wrong_count: number;
  consecutive_correct: number;
  last_is_correct: boolean | null;
  last_selected_index: number | null;
  last_answered_at: string | null;
  understanding_level: number;
  memo: string;
}

export function emptyProgress(questionId: string): Progress {
  return {
    question_id: questionId,
    correct_count: 0,
    wrong_count: 0,
    consecutive_correct: 0,
    last_is_correct: null,
    last_selected_index: null,
    last_answered_at: null,
    understanding_level: 0,
    memo: "",
  };
}
