import { type Verdict } from "@/lib/quiz/readiness";

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
