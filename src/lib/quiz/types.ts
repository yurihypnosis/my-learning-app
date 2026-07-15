// 理解度フラグ（0=未評価, 1..4）。元 jsx の FLAGS/FLAG_COLORS を踏襲
export const FLAGS = ["未評価", "全く分からない", "怪しい", "だいたい理解", "完璧"] as const;
export const FLAG_COLORS = ["#64748b", "#dc2626", "#f59e0b", "#3b82f6", "#16a34a"] as const;

export const WEEK_MS = 7 * 24 * 60 * 60 * 1000;
export const TWO_WEEKS_MS = 14 * 24 * 60 * 60 * 1000;

export type QuizMode = "shuffle" | "priority";

// 解説データの構造（JSONB で保存するリッチ解説）
export interface ExplanationData {
  asked: string;
  terms?: [string, string][];
  think: string;
  vs?: string;
  opt?: string[];
}

// DB の questions + categories を結合したクイズ用の問題
export interface QuizQuestion {
  id: string;
  source_ref: string | null;
  question_text: string;
  code: string | null;
  options: string[];
  correct_index: number;
  correct_indices: number[] | null;
  question_type: "single" | "multi";
  explanation: string;
  explanation_data: ExplanationData | null;
  initial_wrong_weight: number;
  category_id: string;
  category_name: string;
  category_color: string;
  // 表示用に選択肢をシャッフルした場合のみ設定。optionOrder[表示index] = 元(DB)のindex。
  // 正解の偏り対策として buildDeck で付与される。未シャッフルなら undefined。
  optionOrder?: number[];
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
  last_confidence: number | null; // 1=確信あり, 2=迷った, 3=勘
  // FSRS 記憶エンジンの状態（列が無い環境/未学習では未設定）
  fsrs_stability?: number | null;
  fsrs_difficulty?: number | null;
  fsrs_due?: string | null;
  fsrs_last_review?: string | null;
  fsrs_reps?: number;
  fsrs_lapses?: number;
  fsrs_state?: string; // 'new' | 'review'
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
    last_confidence: null,
    fsrs_stability: null,
    fsrs_difficulty: null,
    fsrs_due: null,
    fsrs_last_review: null,
    fsrs_reps: 0,
    fsrs_lapses: 0,
    fsrs_state: "new",
  };
}
