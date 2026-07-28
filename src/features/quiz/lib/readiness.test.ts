import { describe, expect, it } from "vitest";
import {
  capacityFromDailyCounts,
  computeReadiness,
  demonstratedSkill,
  estimatePassProbability,
  examItemProb,
  itemCorrectProb,
  passLineFor,
  passProbability,
  poissonBinomialPMF,
  retentionEstimate,
  type ExamItem,
} from "./readiness";
import { emptyProgress, type Progress } from "./types";

describe("passLineFor", () => {
  it("uses per-exam pass lines, with a default", () => {
    expect(passLineFor("ctal-ta")).toBe(0.65);
    expect(passLineFor("gcp-pca")).toBe(0.7);
    expect(passLineFor("unknown-exam")).toBe(0.72);
    expect(passLineFor(null)).toBe(0.72);
  });
});

describe("capacityFromDailyCounts", () => {
  it("returns the median of active days, clamped", () => {
    expect(capacityFromDailyCounts([10, 20, 30])).toBe(20);
    expect(capacityFromDailyCounts([0, 0, 5])).toBe(10); // clamp min
    expect(capacityFromDailyCounts([100, 100])).toBe(60); // clamp max
    expect(capacityFromDailyCounts([])).toBe(20); // fallback
    expect(capacityFromDailyCounts([], 15)).toBe(15);
  });
});

const arr = (n: number, v: number) => Array.from({ length: n }, () => v);

describe("computeReadiness", () => {
  it("no exam date → verdict no-date, projection = now", () => {
    const r = computeReadiness({
      retentions: arr(100, 0.5), total: 100, attempted: 100,
      daysLeft: null, capacity: 20, passLine: 0.8,
    });
    expect(r.verdict).toBe("no-date");
    expect(r.readinessNow).toBeCloseTo(0.5, 6);
    expect(r.projectedAtExam).toBeCloseTo(0.5, 6);
  });

  it("already at pass level → passed", () => {
    const r = computeReadiness({
      retentions: arr(100, 0.85), total: 100, attempted: 100,
      daysLeft: 10, capacity: 20, passLine: 0.8,
    });
    expect(r.verdict).toBe("passed");
  });

  it("plenty of time and capacity → on-track, projection near target", () => {
    const r = computeReadiness({
      retentions: arr(30, 0.6).concat(arr(70, 0)), total: 100, attempted: 30,
      daysLeft: 30, capacity: 20, passLine: 0.8,
    });
    // 30日×20 = 600 >> 未着手70 → 全カバー可能 → 予測 ≈ 0.9
    expect(r.projectedAtExam).toBeGreaterThanOrEqual(0.8);
    expect(r.verdict === "on-track" || r.verdict === "tight").toBe(true);
    expect(r.dailyNew).toBeGreaterThan(0);
  });

  it("too many unseen for the days left → at-risk", () => {
    const r = computeReadiness({
      retentions: arr(10, 0.6).concat(arr(490, 0)), total: 500, attempted: 10,
      daysLeft: 3, capacity: 20, passLine: 0.8,
    });
    // 3日×20=60 では 490 を潰せない → 予測が合格ライン未満
    expect(r.projectedAtExam).toBeLessThan(0.8);
    expect(r.verdict).toBe("at-risk");
    expect(r.neededPerDayForPass).toBeGreaterThan(r.dailyNew === 20 ? 0 : -1);
  });

  it("readinessNow and coverage reflect attempted", () => {
    const r = computeReadiness({
      retentions: arr(40, 0.75).concat(arr(60, 0)), total: 100, attempted: 40,
      daysLeft: 20, capacity: 20, passLine: 0.8,
    });
    expect(r.readinessNow).toBeCloseTo(0.3, 6); // 40*0.75/100
    expect(r.coverage).toBeCloseTo(0.4, 6);
  });
});

describe("itemCorrectProb", () => {
  it("blends recall and guessing: R + (1-R)*g", () => {
    expect(itemCorrectProb(0, 0.25)).toBeCloseTo(0.25, 6); // 未着手=推測当たり
    expect(itemCorrectProb(1, 0.25)).toBeCloseTo(1, 6);
    expect(itemCorrectProb(0.8, 0.25)).toBeCloseTo(0.85, 6);
  });
});

describe("poissonBinomialPMF / passProbability", () => {
  it("PMF sums to 1 and matches binomial when p is identical", () => {
    const pmf = poissonBinomialPMF([0.5, 0.5, 0.5]);
    expect(pmf.reduce((a, b) => a + b, 0)).toBeCloseTo(1, 9);
    // Binomial(3, .5): 1/8, 3/8, 3/8, 1/8
    expect(pmf[0]).toBeCloseTo(0.125, 9);
    expect(pmf[2]).toBeCloseTo(0.375, 9);
  });

  it("degenerate cases", () => {
    expect(passProbability([1, 1, 1], 3)).toBeCloseTo(1, 9);
    expect(passProbability([0, 0, 0], 1)).toBeCloseTo(0, 9);
    // 3問すべて 0.5、2問以上正答で合格 → 1/2
    expect(passProbability([0.5, 0.5, 0.5], 2)).toBeCloseTo(0.5, 9);
  });
});

describe("demonstratedSkill", () => {
  const P = (o: Partial<Progress>): Progress => ({ ...emptyProgress("q"), ...o });
  it("prices confidence: sure-correct high, guessed-correct near the floor", () => {
    expect(demonstratedSkill(P({ correct_count: 1, last_is_correct: true, last_confidence: 1 }))).toBe(0.95);
    expect(demonstratedSkill(P({ correct_count: 1, last_is_correct: true, last_confidence: 3 }))).toBe(0.35);
    expect(demonstratedSkill(P({ wrong_count: 1, last_is_correct: false, last_confidence: 1 }))).toBe(0.08);
    expect(demonstratedSkill(P({}))).toBeNull(); // 未着手
  });
});

describe("examItemProb", () => {
  const NOW = Date.parse("2026-07-17T00:00:00Z");
  it("a lucky guess just answered is NOT treated as mastery", () => {
    // 勘で正解・今さっき解答(想起≈1・stability小)。実力どまりで高くならない。
    const p: Progress = {
      ...emptyProgress("q"), correct_count: 1, last_is_correct: true, last_confidence: 3,
      fsrs_state: "review", fsrs_stability: 0.7,
      fsrs_last_review: new Date(NOW).toISOString(),
    };
    const prob = examItemProb(p, NOW, 0.25)!;
    expect(prob).toBeGreaterThanOrEqual(0.25); // 推測床は下回らない
    expect(prob).toBeLessThan(0.45); // だが実力(0.35)どまり、1にならない
  });
});

describe("estimatePassProbability", () => {
  const item = (o: Partial<ExamItem>): ExamItem => ({
    prob: null, guess: 0.25, category: "c", ...o,
  });

  it("all mastered → near-certain pass", () => {
    const items = Array.from({ length: 20 }, () => item({ prob: 0.95 }));
    const { passProbability: pp, expectedScore } = estimatePassProbability(items, 0.72);
    expect(expectedScore).toBeGreaterThan(0.9);
    expect(pp).toBeGreaterThan(0.9);
  });

  it("nothing attempted → ~guessing floor, fails a 72% line", () => {
    const items = Array.from({ length: 20 }, () => item({}));
    const { passProbability: pp, expectedScore } = estimatePassProbability(items, 0.72);
    expect(expectedScore).toBeCloseTo(0.25, 6);
    expect(pp).toBeLessThan(0.01);
  });

  it("mostly lucky guesses → low pass probability (not 100%)", () => {
    // 20問: 実力0.35(勘正解)相当。合格ライン0.72 → 期待得点が届かず合格確率は低い。
    const items = Array.from({ length: 20 }, () => item({ prob: 0.35 }));
    const { passProbability: pp } = estimatePassProbability(items, 0.72);
    expect(pp).toBeLessThan(0.05);
  });

  it("unseen items inherit category ability (generalization, not dilution)", () => {
    const answered = Array.from({ length: 6 }, () => item({ prob: 0.9, category: "ml" }));
    const unseen = Array.from({ length: 114 }, () => item({ category: "ml" }));
    const withUnseen = estimatePassProbability([...answered, ...unseen], 0.6);
    const onlyAnswered = estimatePassProbability(answered, 0.6);
    expect(withUnseen.expectedScore).toBeGreaterThan(0.5);
    expect(withUnseen.passProbability).toBeGreaterThan(0.5);
    expect(withUnseen.expectedScore).toBeLessThan(onlyAnswered.expectedScore);
  });
});

describe("retentionEstimate", () => {
  const NOW = Date.parse("2026-07-15T00:00:00Z");

  it("returns 0 for unattempted", () => {
    expect(retentionEstimate(emptyProgress("q"), NOW)).toBe(0);
  });

  it("falls back to mastery when no FSRS state", () => {
    const p: Progress = { ...emptyProgress("q"), correct_count: 8, wrong_count: 2, last_confidence: 1 };
    const r = retentionEstimate(p, NOW);
    expect(r).toBeGreaterThan(0);
    expect(r).toBeLessThanOrEqual(1);
  });

  it("uses FSRS retrievability when the card was reviewed", () => {
    const reviewedRecently: Progress = {
      ...emptyProgress("q"), correct_count: 1,
      fsrs_state: "review", fsrs_stability: 20,
      fsrs_last_review: new Date(NOW - 86_400_000).toISOString(), // 1日前
    };
    const r = retentionEstimate(reviewedRecently, NOW);
    expect(r).toBeGreaterThan(0.9); // S=20, 経過1日 → R高い
  });
});
