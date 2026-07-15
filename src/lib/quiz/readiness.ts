// 合格ナビ: 試験日 × 定着度 × 網羅率 から「間に合う?」「今日これ」を出す。
//
// 定着度は問題ごとに retentionEstimate() で見積もる:
//   FSRS の状態があれば現在の保持率 R、無ければ従来の mastery、未着手は 0。
// これで FSRS の記録が貯まる前でも動き、貯まるほど精度が上がる。

import { currentRetrievability } from "./fsrs";
import { masteryFromProgress } from "./stats";
import type { Progress } from "./types";

// 試験別の合格ライン（0..1）。exam_key（examGroupKey の値）でひく。
// 公表されている合格点の目安（GCP≈70% / ISTQB CTAL-TA≈65% / DCA≈66%）。
export const EXAM_PASS_LINE: Record<string, number> = {
  "gcp-ace": 0.7,
  "gcp-pca": 0.7,
  "gcp-pcde": 0.7,
  "gh-200": 0.7,
  dca: 0.66,
  "ctal-ta": 0.65,
};

export function passLineFor(examKey: string | null | undefined): number {
  return (examKey ? EXAM_PASS_LINE[examKey] : undefined) ?? 0.72;
}

// 直近の「1日あたり解答数」の配列から、現実的な1日 capacity を推定する。
// 活動日（>0）の中央値を採用し、極端値を [10, 60] に丸める。
export function capacityFromDailyCounts(dailyCounts: number[], fallback = 20): number {
  const active = dailyCounts.filter((c) => c > 0).sort((a, b) => a - b);
  if (active.length === 0) return fallback;
  const mid = active[Math.floor(active.length / 2)];
  return Math.min(60, Math.max(10, mid));
}

// 1 問の現在の定着推定 (0..1)。
export function retentionEstimate(p: Progress, nowMs: number): number {
  if (p.fsrs_state === "review" && p.fsrs_last_review && (p.fsrs_stability ?? 0) > 0) {
    return currentRetrievability(
      {
        stability: p.fsrs_stability ?? 0,
        difficulty: p.fsrs_difficulty ?? 0,
        reps: p.fsrs_reps ?? 0,
        lapses: p.fsrs_lapses ?? 0,
        lastReview: p.fsrs_last_review,
        due: p.fsrs_due ?? null,
        state: "review",
      },
      nowMs
    );
  }
  const attempts = p.correct_count + p.wrong_count;
  return attempts > 0 ? masteryFromProgress(p) : 0;
}

export type Verdict = "passed" | "on-track" | "tight" | "at-risk" | "no-date";

export interface Readiness {
  readinessNow: number; // 0..1  Σretention / total（未着手=0）
  projectedAtExam: number; // 0..1  今のプランを続けた場合の試験日予測
  coverage: number; // 0..1  着手済み / 全問
  total: number;
  attempted: number;
  daysLeft: number;
  verdict: Verdict;
  dailyNew: number; // 今日やる新規の推奨数
  neededPerDayForPass: number; // 合格ラインに乗せるのに必要な1日新規数
  targetRetention: number;
  passLine: number;
}

export interface ReadinessInput {
  retentions: number[]; // 各問題の定着推定
  total: number;
  attempted: number;
  daysLeft: number | null; // 試験日まで（未設定なら null）
  capacity: number; // 1日に現実的にこなせる問数
  passLine: number; // 合格ライン T (0..1)
  targetRetention?: number; // 既定 0.9
}

export function computeReadiness(input: ReadinessInput): Readiness {
  const Rt = input.targetRetention ?? 0.9;
  const total = Math.max(1, input.total);
  const attempted = Math.min(input.attempted, total);
  const sumR = input.retentions.reduce((a, b) => a + b, 0);
  const readinessNow = sumR / total;
  const coverage = attempted / total;

  if (input.daysLeft === null) {
    return {
      readinessNow, projectedAtExam: readinessNow, coverage, total, attempted,
      daysLeft: 0, verdict: "no-date", dailyNew: 0, neededPerDayForPass: 0,
      targetRetention: Rt, passLine: input.passLine,
    };
  }

  const daysLeft = Math.max(0, input.daysLeft);
  const cap = Math.max(1, input.capacity);
  const unseen = Math.max(0, total - attempted);

  // 残り日 × capacity で未着手をどれだけ潰せるか → 到達可能な網羅率
  const reachableCoverage = Math.min(1, (attempted + daysLeft * cap) / total);
  // 復習を続ければ着手済みは Rt まで戻る前提 → 予測 ≈ Rt × 到達網羅率
  const projectedAtExam = Rt * reachableCoverage;

  // 合格ライン T に乗せるのに必要な網羅率と、その1日新規数
  const neededCoverage = Math.min(1, input.passLine / Rt);
  const neededQ = Math.ceil(neededCoverage * total);
  const stillNeed = Math.max(0, neededQ - attempted);
  const neededPerDayForPass = daysLeft > 0 ? Math.ceil(stillNeed / daysLeft) : stillNeed;

  const coverPerDay = daysLeft > 0 ? Math.ceil(unseen / daysLeft) : unseen;
  const dailyNew = Math.min(cap, Math.max(neededPerDayForPass, coverPerDay));

  let verdict: Verdict;
  if (readinessNow >= input.passLine) verdict = "passed";
  else if (projectedAtExam < input.passLine || neededPerDayForPass > cap) verdict = "at-risk";
  else if (neededPerDayForPass > 0.7 * cap) verdict = "tight";
  else verdict = "on-track";

  return {
    readinessNow, projectedAtExam, coverage, total, attempted, daysLeft,
    verdict, dailyNew, neededPerDayForPass, targetRetention: Rt, passLine: input.passLine,
  };
}
