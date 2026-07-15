import { describe, expect, it } from "vitest";
import { computeReadiness, retentionEstimate } from "./readiness";
import { emptyProgress, type Progress } from "./types";

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
