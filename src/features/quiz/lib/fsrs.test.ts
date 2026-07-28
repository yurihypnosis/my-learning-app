import { describe, expect, it } from "vitest";
import {
  type Card,
  currentRetrievability,
  gradeFromAnswer,
  intervalFromStability,
  isDue,
  newCard,
  retrievability,
  review,
} from "./fsrs";

const DAY = 86_400_000;
const T0 = Date.parse("2026-07-15T00:00:00Z");

describe("gradeFromAnswer", () => {
  it("maps correctness × confidence to FSRS grades", () => {
    expect(gradeFromAnswer(false, 1)).toBe(1); // 誤答 → Again
    expect(gradeFromAnswer(true, 3)).toBe(2); // 正答×勘 → Hard
    expect(gradeFromAnswer(true, 2)).toBe(3); // 正答×迷った → Good
    expect(gradeFromAnswer(true, null)).toBe(3); // 正答×未回答 → Good
    expect(gradeFromAnswer(true, 1)).toBe(4); // 正答×自信あり → Easy
  });
});

describe("retrievability", () => {
  it("is 1 at t=0 and ~0.9 at t=S", () => {
    expect(retrievability(0, 10)).toBeCloseTo(1, 6);
    expect(retrievability(10, 10)).toBeCloseTo(0.9, 2);
  });
  it("decays monotonically with time", () => {
    const a = retrievability(1, 10);
    const b = retrievability(5, 10);
    const c = retrievability(20, 10);
    expect(a).toBeGreaterThan(b);
    expect(b).toBeGreaterThan(c);
  });
});

describe("intervalFromStability", () => {
  it("equals stability (rounded) at Rt=0.9", () => {
    expect(intervalFromStability(10, 0.9, 36500)).toBe(10);
    expect(intervalFromStability(37, 0.9, 36500)).toBe(37);
  });
  it("gives longer intervals for lower target retention", () => {
    const hi = intervalFromStability(20, 0.9, 36500);
    const lo = intervalFromStability(20, 0.8, 36500);
    expect(lo).toBeGreaterThan(hi);
  });
  it("clamps to at least 1 day", () => {
    expect(intervalFromStability(0.1, 0.9, 36500)).toBe(1);
  });
});

describe("review", () => {
  it("initializes a new card and schedules a future due", () => {
    const c = review(newCard(), 3, T0);
    expect(c.state).toBe("review");
    expect(c.reps).toBe(1);
    expect(c.stability).toBeGreaterThan(0);
    expect(c.difficulty).toBeGreaterThanOrEqual(1);
    expect(c.difficulty).toBeLessThanOrEqual(10);
    expect(Date.parse(c.due!)).toBeGreaterThan(T0);
  });

  it("Easy schedules a longer first interval than Good than Hard", () => {
    const hard = review(newCard(), 2, T0);
    const good = review(newCard(), 3, T0);
    const easy = review(newCard(), 4, T0);
    expect(Date.parse(good.due!)).toBeGreaterThanOrEqual(Date.parse(hard.due!));
    expect(Date.parse(easy.due!)).toBeGreaterThan(Date.parse(good.due!));
  });

  it("successful reviews grow stability; the interval lengthens", () => {
    let c = review(newCard(), 3, T0);
    const s1 = c.stability;
    // 期日どおりに正答(Good)で復習
    c = review(c, 3, Date.parse(c.due!));
    expect(c.stability).toBeGreaterThan(s1);
  });

  it("a lapse (Again) shrinks stability and counts a lapse", () => {
    let c = review(newCard(), 4, T0); // Easy で大きめの S
    c = review(c, 3, Date.parse(c.due!)); // さらに伸ばす
    const before = c.stability;
    c = review(c, 1, Date.parse(c.due!)); // 忘れた
    expect(c.stability).toBeLessThan(before);
    expect(c.lapses).toBe(1);
  });

  it("keeps difficulty within [1,10] and raises it on Again", () => {
    let c = review(newCard(), 3, T0);
    const d0 = c.difficulty;
    c = review(c, 1, Date.parse(c.due!));
    expect(c.difficulty).toBeGreaterThan(d0);
    expect(c.difficulty).toBeLessThanOrEqual(10);
  });
});

describe("isDue / currentRetrievability", () => {
  it("new cards are always due; reviewed cards become due at their due date", () => {
    expect(isDue(newCard(), T0)).toBe(true);
    const c = review(newCard(), 3, T0);
    expect(isDue(c, T0 + DAY)).toBe(false);
    expect(isDue(c, Date.parse(c.due!) + DAY)).toBe(true);
  });

  it("currentRetrievability is 0 for new cards and decays after review", () => {
    expect(currentRetrievability(newCard(), T0)).toBe(0);
    const c: Card = review(newCard(), 3, T0);
    const rSoon = currentRetrievability(c, T0 + DAY);
    const rLater = currentRetrievability(c, T0 + 30 * DAY);
    expect(rSoon).toBeGreaterThan(rLater);
    expect(rSoon).toBeLessThanOrEqual(1);
  });
});
