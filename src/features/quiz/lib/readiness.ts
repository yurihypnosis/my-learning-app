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

// ── 合格確率（ポアソン二項）────────────────────────────────────────────
// 1問の正答確率。思い出せれば正答、思い出せなくても選択肢から当たる:
//   P(正答) = R + (1-R)*g   （R=想起確率, g=推測当たり=1/選択肢数）
export function itemCorrectProb(retention: number, guess: number): number {
  const r = Math.min(1, Math.max(0, retention));
  const g = Math.min(1, Math.max(0, guess));
  return r + (1 - r) * g;
}

// ポアソン二項分布: 各試行の成功確率が異なる独立試行の「成功数」の分布を
// 動的計画法で厳密に求める（O(n^2)）。dist[k] = P(成功数 = k), k=0..n。
export function poissonBinomialPMF(probs: number[]): number[] {
  let dist = [1];
  for (const p of probs) {
    const pc = Math.min(1, Math.max(0, p));
    const next = new Array<number>(dist.length + 1).fill(0);
    for (let k = 0; k < dist.length; k++) {
      next[k] += dist[k] * (1 - pc);
      next[k + 1] += dist[k] * pc;
    }
    dist = next;
  }
  return dist;
}

// 成功数（正答数）が minCorrect 以上になる確率 = 合格確率。
export function passProbability(probs: number[], minCorrect: number): number {
  if (probs.length === 0) return 0;
  const pmf = poissonBinomialPMF(probs);
  const from = Math.max(0, Math.ceil(minCorrect - 1e-9));
  let s = 0;
  for (let k = from; k < pmf.length; k++) s += pmf[k];
  return Math.min(1, Math.max(0, s));
}

// 直近の「正誤 × 確信度」から実力（本試験の未見問題に正答できる確率）を推定。
// まぐれ当たり（勘=確信度3の正解）は実力として高く評価しない＝推測床付近まで。
// 未着手は null。（app の思想「まぐれ当たりは加算しない」を確率に反映）
export function demonstratedSkill(p: Progress): number | null {
  const attempts = p.correct_count + p.wrong_count;
  if (attempts === 0) return null;
  const conf = p.last_confidence; // 1=確信 / 2=迷い / 3=勘 / null
  if (p.last_is_correct === true) {
    return conf === 1 ? 0.95 : conf === 2 ? 0.7 : conf === 3 ? 0.35 : 0.55;
  }
  // 直近が誤答（または不明）
  return conf === 1 ? 0.08 : conf === 2 ? 0.2 : conf === 3 ? 0.28 : 0.15;
}

// 着手済み1問の「本試験で正答する確率」。実力 × 現在の想起(FSRS) を推測床でクランプ。
// 直後は想起≈1 だが実力(demonstratedSkill)が低ければ低いまま＝勘の直後正解でも過大にならない。
// 時間が経てば想起が減衰し確率も下がる。未着手は null。
export function examItemProb(p: Progress, nowMs: number, guess: number): number | null {
  const skill = demonstratedSkill(p);
  if (skill === null) return null;
  let recall = 1;
  if (p.fsrs_state === "review" && p.fsrs_last_review && (p.fsrs_stability ?? 0) > 0) {
    recall = currentRetrievability(
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
  return Math.min(1, Math.max(guess, skill * recall));
}

// 合格確率の推定に使う1問の材料。prob=本試験で正答する確率（未着手は null）。
export interface ExamItem {
  prob: number | null;
  guess: number; // 推測当たり（1/選択肢数）
  category: string; // 分野。未見問題の汎化に使う
}

// 本試験を今受けたときの合格確率と推定得点率。
//  - 着手済み: examItemProb（実力×想起、確信度込み）。
//  - 未着手: 「その分野の能力」で予測（着手済み prob の平均をベイズ縮約、推測当たりへ寄せる）。
//  - 合格確率は正答数のポアソン二項で P(正答数 ≥ 合格ライン×問題数)。
export function estimatePassProbability(
  items: ExamItem[],
  passLine: number,
  priorStrength = 3
): { passProbability: number; expectedScore: number } {
  if (items.length === 0) return { passProbability: 0, expectedScore: 0 };
  const byCat = new Map<string, { sum: number; n: number; guess: number }>();
  for (const it of items) {
    if (it.prob === null) continue;
    const c = byCat.get(it.category) ?? { sum: 0, n: 0, guess: it.guess };
    c.sum += it.prob;
    c.n += 1;
    c.guess = it.guess;
    byCat.set(it.category, c);
  }
  const abilityOf = (cat: string, guess: number): number => {
    const c = byCat.get(cat);
    if (!c || c.n === 0) return guess; // 未着手分野 → 推測当たりまで
    return (c.sum + priorStrength * guess) / (c.n + priorStrength);
  };
  const probs = items.map((it) => it.prob ?? abilityOf(it.category, it.guess));
  const n = probs.length;
  const expectedScore = probs.reduce((a, b) => a + b, 0) / n;
  return { passProbability: passProbability(probs, passLine * n), expectedScore };
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
