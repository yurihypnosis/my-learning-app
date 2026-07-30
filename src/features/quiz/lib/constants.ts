import { type Verdict } from "@/features/quiz/lib/readiness";

// 「苦手だけ演習」1セッションの上限。弱点順に上位から出す（多すぎる一括を避ける）。
export const WEAK_SESSION_MAX = 30;

export const VERDICT_META: Record<Verdict, { label: string; color: string }> = {
  passed: { label: "合格圏内", color: "#22c55e" },
  "on-track": { label: "間に合う", color: "#22c55e" },
  tight: { label: "ギリギリ", color: "#f59e0b" },
  "at-risk": { label: "危険", color: "#ef4444" },
  "no-date": { label: "", color: "#8892a4" },
};

export const CONFIDENCE_LABELS = ["確信あり", "迷った", "勘"] as const;
export const CONFIDENCE_COLORS = ["#22c55e", "#f59e0b", "#ef4444"] as const;

// 不正解後の理解度の自己申告。user_question_progress.understanding_level の 1..3 に対応
// （0=未評価, 4=完璧 は既存定義のまま残す。4 は休眠判定に使われるためここからは書かない）。
// 表示は「わかった」が先頭（読み順）、見直しの並びは level の小さい順（わからない問題が先）。
export const COMPREHENSION_LEVELS = [
  { level: 3, label: "解説でわかった", color: "#6ab08d" },
  { level: 2, label: "なんとなくわかった", color: "#c9a04a" },
  { level: 1, label: "全くわからない", color: "#c47070" },
] as const;
