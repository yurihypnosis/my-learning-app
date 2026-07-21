import { describe, expect, it } from "vitest";
import { examGroupKey, isSpeakFirstSubject } from "./stats";

describe("examGroupKey", () => {
  it("strips the set-letter suffix by convention", () => {
    expect(examGroupKey("gcp-pcde-c")).toBe("gcp-pcde");
    expect(examGroupKey("gcp-ace")).toBe("gcp-ace");
  });

  it("maps aliases explicitly", () => {
    expect(examGroupKey("istqb-ctal-ta")).toBe("ctal-ta");
  });

  it("bundles all phrasal-verb tiers into the single pv exam", () => {
    // 規約の "-<英字>" 除去だと pv-t1/pv-t2/pv-t3 に割れるため、別名表で束ねている
    for (const slug of [
      "pv-t1-a", "pv-t1-b",
      "pv-t2-a", "pv-t2-b", "pv-t2-c",
      "pv-t3-a", "pv-t3-b", "pv-t3-c", "pv-t3-d",
      "pv-test",
    ]) {
      expect(examGroupKey(slug)).toBe("pv");
    }
  });
});

describe("isSpeakFirstSubject", () => {
  it("matches only pv-* slugs", () => {
    expect(isSpeakFirstSubject("pv-t1-a")).toBe(true);
    expect(isSpeakFirstSubject("pv-test")).toBe(true);
    expect(isSpeakFirstSubject("gcp-ace")).toBe(false);
    expect(isSpeakFirstSubject("terraform-associate-b")).toBe(false);
  });
});
