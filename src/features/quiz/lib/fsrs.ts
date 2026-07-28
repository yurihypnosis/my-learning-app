// FSRS (Free Spaced Repetition Scheduler) — 記憶エンジン。
//
// 各カード(問題)を「安定度 S(stability, 日)」と「難易度 D(difficulty, 1..10)」で
// モデル化し、経過日数から保持率 R(retrievability) を計算する。復習ごとに
// grade(1..4) を受けて S・D を更新し、目標保持率 Rt に落ちる日を次の復習日(due)
// とする。アルゴリズムは FSRS-4.5 に準拠。重みはデフォルト値（将来 answer_events
// からユーザー最適化できるが、v1 は固定）。
//
// すべて純粋関数。"now" は呼び出し側が渡す（テスト容易・時計依存なし）。

export type Grade = 1 | 2 | 3 | 4; // 1=Again 2=Hard 3=Good 4=Easy

export interface Card {
  stability: number; // 日
  difficulty: number; // 1..10
  reps: number;
  lapses: number;
  lastReview: string | null; // ISO
  due: string | null; // ISO
  state: "new" | "review";
}

export interface FsrsParams {
  w: number[]; // 17 個の重み
  requestRetention: number; // 目標保持率 Rt
  maximumInterval: number; // 日
}

// FSRS-4.5 デフォルト重み（open-spaced-repetition の公開既定値）
export const DEFAULT_WEIGHTS: number[] = [
  0.4197, 1.1869, 3.0412, 15.2441, 7.1434, 0.6477, 1.0007, 0.0674, 1.6597,
  0.1712, 1.1178, 2.0225, 0.0904, 0.3025, 2.1214, 0.2498, 2.9466,
];

export const DEFAULT_PARAMS: FsrsParams = {
  w: DEFAULT_WEIGHTS,
  requestRetention: 0.9,
  maximumInterval: 36500,
};

const DECAY = -0.5;
// FACTOR: R(t=S, S) が Rt=0.9 になるよう定めた定数（= 0.9^(1/DECAY) - 1 = 19/81）
const FACTOR = Math.pow(0.9, 1 / DECAY) - 1;

const MS_DAY = 86_400_000;
const clampD = (d: number) => Math.min(Math.max(d, 1), 10);

// 経過 t 日・安定度 S における保持率 R（0..1）。R(0,S)=1, R(S,S)=0.9。
export function retrievability(elapsedDays: number, stability: number): number {
  if (stability <= 0) return 0;
  return Math.pow(1 + (FACTOR * Math.max(0, elapsedDays)) / stability, DECAY);
}

// 目標保持率 Rt に落ちるまでの日数（= 次の復習間隔）。Rt=0.9 のとき ≈ S。
export function intervalFromStability(
  stability: number,
  requestRetention: number,
  maximumInterval: number
): number {
  const raw = (stability / FACTOR) * (Math.pow(requestRetention, 1 / DECAY) - 1);
  return Math.min(Math.max(Math.round(raw), 1), maximumInterval);
}

function initStability(g: Grade, w: number[]): number {
  return Math.max(0.1, w[g - 1]);
}
function initDifficulty(g: Grade, w: number[]): number {
  return clampD(w[4] - w[5] * (g - 3));
}
function nextDifficulty(d: number, g: Grade, w: number[]): number {
  const next = d - w[6] * (g - 3);
  // 平易(Easy)初期難易度への弱い平均回帰
  const reverted = w[7] * initDifficulty(4, w) + (1 - w[7]) * next;
  return clampD(reverted);
}
function nextRecallStability(s: number, d: number, r: number, g: Grade, w: number[]): number {
  const hardPenalty = g === 2 ? w[15] : 1;
  const easyBonus = g === 4 ? w[16] : 1;
  const inc =
    Math.exp(w[8]) *
    (11 - d) *
    Math.pow(s, -w[9]) *
    (Math.exp(w[10] * (1 - r)) - 1) *
    hardPenalty *
    easyBonus;
  return s * (1 + inc);
}
function nextForgetStability(s: number, d: number, r: number, w: number[]): number {
  return (
    w[11] * Math.pow(d, -w[12]) * (Math.pow(s + 1, w[13]) - 1) * Math.exp(w[14] * (1 - r))
  );
}

// 解答(正誤 × 確信度) を FSRS の grade に写像する。
// 既にアプリが確信度を取っているので、FSRS が自己申告で欲しがる grade をそのまま作れる。
//   誤答→Again / 正答×勘(3)→Hard / 正答×迷った(2)or未回答→Good / 正答×自信あり(1)→Easy
export function gradeFromAnswer(isCorrect: boolean, confidence: number | null): Grade {
  if (!isCorrect) return 1;
  if (confidence === 1) return 4;
  if (confidence === 3) return 2;
  return 3;
}

export function newCard(): Card {
  return {
    stability: 0,
    difficulty: 0,
    reps: 0,
    lapses: 0,
    lastReview: null,
    due: null,
    state: "new",
  };
}

// 1 回のレビューを適用して次のカード状態を返す。
export function review(
  card: Card,
  grade: Grade,
  nowMs: number,
  params: FsrsParams = DEFAULT_PARAMS
): Card {
  const { w, requestRetention, maximumInterval } = params;
  const nowIso = new Date(nowMs).toISOString();

  let stability: number;
  let difficulty: number;

  if (card.state === "new" || card.lastReview === null) {
    stability = initStability(grade, w);
    difficulty = initDifficulty(grade, w);
  } else {
    const elapsedDays = Math.max(0, (nowMs - Date.parse(card.lastReview)) / MS_DAY);
    const r = retrievability(elapsedDays, card.stability);
    difficulty = nextDifficulty(card.difficulty, grade, w);
    stability =
      grade === 1
        ? nextForgetStability(card.stability, difficulty, r, w)
        : nextRecallStability(card.stability, difficulty, r, grade, w);
  }

  stability = Math.max(0.1, stability);
  const interval = intervalFromStability(stability, requestRetention, maximumInterval);

  return {
    stability,
    difficulty,
    reps: card.reps + 1,
    lapses: card.lapses + (grade === 1 ? 1 : 0),
    lastReview: nowIso,
    due: new Date(nowMs + interval * MS_DAY).toISOString(),
    state: "review",
  };
}

// due を過ぎているか（出題対象か）。
export function isDue(card: Card, nowMs: number): boolean {
  if (card.state === "new" || !card.due) return true;
  return Date.parse(card.due) <= nowMs;
}

// 現時点の保持率（弱点/合格ナビ用）。未学習は 0。
export function currentRetrievability(card: Card, nowMs: number): number {
  if (card.state === "new" || !card.lastReview || card.stability <= 0) return 0;
  const elapsedDays = Math.max(0, (nowMs - Date.parse(card.lastReview)) / MS_DAY);
  return retrievability(elapsedDays, card.stability);
}
