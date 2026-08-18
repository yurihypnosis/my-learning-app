import { describe, expect, it } from "vitest";
import { countStreak } from "../lib/streak";

describe("countStreak", () => {
  it("tdd test for countStreak", () => {
    expect(countStreak([], "2026-08-01")).toBe(0);
    expect(countStreak(["2026-07-31"], "2026-08-01")).toBe(0);
    expect(countStreak(["2026-07-31", "2026-08-01"], "2026-08-01")).toBe(2);
    expect(countStreak(["2026-07-30"], "2026-08-01")).toBe(0);
  });
});
