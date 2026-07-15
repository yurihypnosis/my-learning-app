"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";

const ROADMAP_PHASES = [
  {
    id: "A", label: "Phase A", title: "CI/CD 基礎", period: "〜2025",
    status: "done" as const,
    body: ["GitHub Actions を実務で習得"],
  },
  {
    id: "B", label: "Phase B", title: "QA 資格の積み上げ", period: "〜2025",
    status: "done" as const,
    body: ["GCP CDL 合格", "JSTQB AL-TM 合格"],
  },
  {
    id: "C", label: "Phase C", title: "DevOps 技術の本丸", period: "2026",
    status: "current" as const,
    subtitle: "QA × DevOps の二刀流を確立する",
    milestones: [
      { title: "Terraform",                         detail: "init/apply/destroy 着手 → 自プロジェクトで実運用", ms: "in-progress" as const, slug: null },
      { title: "GCP Associate Cloud Engineer",      detail: "7/11 受験予定",                                    ms: "next"        as const, slug: "gcp-ace" },
      { title: "CKA / Kubernetes",                  detail: "最難関（実技）· 11月〜 → 2027年3月受験見込み",       ms: "upcoming"    as const, slug: null },
    ],
  },
  {
    id: "1", label: "Phase 1", title: "QA アーキテクト級", period: "2027〜2028",
    status: "future" as const,
    body: ["CI/CD・IaC 環境を設計できる状態", "GCP Professional 級（Architect / DevOps）"],
  },
  {
    id: "2", label: "Phase 2", title: "プロダクトビルダー", period: "2029〜2030",
    status: "future" as const,
    body: ["Q-Entropy を実プロダクト化"],
  },
];

type MsHint = "in-progress" | "next" | "upcoming";

interface Item {
  key: string;
  label: string;
  detail?: string;
  def: boolean; // DB に記録が無いときの既定の完了状態
  kind: "milestone" | "body";
  msHint?: MsHint;
  slug?: string | null;
}

// 各フェーズを「完了チェック可能な項目」に平坦化する。キーは安定（例: C.m1 / B.b0）。
function phaseItems(ph: (typeof ROADMAP_PHASES)[number]): Item[] {
  if ("milestones" in ph && ph.milestones) {
    return ph.milestones.map((ms, j) => ({
      key: `${ph.id}.m${j}`,
      label: ms.title,
      detail: ms.detail,
      def: false,
      kind: "milestone" as const,
      msHint: ms.ms,
      slug: ms.slug,
    }));
  }
  if ("body" in ph && ph.body) {
    return ph.body.map((b, j) => ({
      key: `${ph.id}.b${j}`,
      label: b,
      def: ph.status === "done",
      kind: "body" as const,
    }));
  }
  return [];
}

interface Props {
  acePassProb: number | null;
  userId: string;
  doneOverrides: Record<string, boolean>;
}

const MS_COLOR = {
  "in-progress": "#f59e0b",
  "next":        "#3b82f6",
  "upcoming":    "#555e70",
} as const;

const passColor = (p: number) => (p >= 70 ? "#22c55e" : p >= 50 ? "#f59e0b" : "#ef4444");

export function RoadmapClient({ acePassProb, userId, doneOverrides }: Props) {
  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  const supabase = useMemo(() => createClient(), []);
  const [overrides, setOverrides] = useState<Record<string, boolean>>(doneOverrides);
  const [screen, setScreen] = useState<"view" | "settings">("view");

  const isDone = (it: Item): boolean => overrides[it.key] ?? it.def;

  const toggle = async (key: string, next: boolean) => {
    setOverrides((o) => ({ ...o, [key]: next })); // 楽観的更新
    if (!userId) return;
    const { error } = await supabase
      .from("user_roadmap_items")
      .upsert({ user_id: userId, item_key: key, done: next }, { onConflict: "user_id,item_key" });
    if (error) console.error("[user_roadmap_items] save failed:", error.code, error.message);
  };

  // ── 設定画面（完了チェック） ──
  if (screen === "settings") {
    return (
      <div className={wrap}>
        <div className={container}>
          <div className="mb-6 flex items-center justify-between">
            <div>
              <h1 className="text-base font-semibold text-white">ロードマップ設定</h1>
              <p className="text-xs text-[#555e70]">各マイルストンの完了をチェック</p>
            </div>
            <button
              onClick={() => setScreen("view")}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              ← 戻る
            </button>
          </div>

          <div className="space-y-5">
            {ROADMAP_PHASES.map((ph) => {
              const items = phaseItems(ph);
              if (items.length === 0) return null;
              return (
                <div key={ph.id}>
                  <div className="mb-2 flex items-center gap-2">
                    <span className="text-[10px] font-semibold uppercase tracking-wider text-[#8892a4]">
                      {ph.label}
                    </span>
                    <span className="text-xs text-[#c0c8d8]">{ph.title}</span>
                    <span className="text-[10px] text-[#555e70]">{ph.period}</span>
                  </div>
                  <div className="space-y-1.5">
                    {items.map((it) => {
                      const done = isDone(it);
                      return (
                        <button
                          key={it.key}
                          onClick={() => toggle(it.key, !done)}
                          className="flex w-full items-start gap-3 rounded-xl border border-[#2a2f3f] bg-[#141720] px-3.5 py-3 text-left transition hover:border-[#3a4050]"
                        >
                          <span
                            className="mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded-[5px] border text-[10px] font-bold"
                            style={{
                              background: done ? "#22c55e" : "transparent",
                              borderColor: done ? "#22c55e" : "#3a4050",
                              color: "#0f1117",
                            }}
                          >
                            {done ? "✓" : ""}
                          </span>
                          <div className="min-w-0 flex-1">
                            <p
                              className="text-xs font-medium"
                              style={{
                                color: done ? "#555e70" : "#c0c8d8",
                                textDecoration: done ? "line-through" : "none",
                              }}
                            >
                              {it.label}
                            </p>
                            {it.detail && (
                              <p className="text-[11px] text-[#555e70]">{it.detail}</p>
                            )}
                          </div>
                        </button>
                      );
                    })}
                  </div>
                </div>
              );
            })}
          </div>

          <button
            onClick={() => setScreen("view")}
            className="mt-6 block w-full rounded-xl bg-[#3b82f6] py-3 text-center text-sm font-medium text-white transition hover:bg-[#60a5fa]"
          >
            完了
          </button>
        </div>
      </div>
    );
  }

  // ── ロードマップ本体 ──
  return (
    <div className={wrap}>
      <div className={container}>
        {/* Header */}
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="text-base font-semibold text-white">学習ロードマップ</h1>
            <p className="text-xs text-[#555e70]">DevOpsならユウ — 設計・自動化・組織浸透</p>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => setScreen("settings")}
              className="rounded-lg border border-[#2a2f3f] px-2.5 py-1.5 text-[11px] text-[#8892a4] transition hover:border-[#3a4050] hover:text-white"
            >
              ⚙ 設定
            </button>
            <Link href="/" className="text-xs text-[#555e70] transition hover:text-[#8892a4]">
              ← 戻る
            </Link>
          </div>
        </div>

        {/* Timeline */}
        <div className="relative pl-8">
          {ROADMAP_PHASES.map((ph, i) => {
            const isLast = i === ROADMAP_PHASES.length - 1;
            const isDonePhase = ph.status === "done";
            const isCurrent = ph.status === "current";
            const isFuture = ph.status === "future";
            const items = phaseItems(ph);

            const dotColor = isDonePhase ? "#22c55e" : isCurrent ? "#3b82f6" : "#2a2f3f";
            const dotBorder = isCurrent ? "2px solid #3b82f6" : isDonePhase ? "none" : "1px solid #2a2f3f";

            return (
              <div key={ph.id} className="relative">
                {!isLast && (
                  <div
                    className="absolute left-[-19px] top-7 w-px"
                    style={{
                      height: "calc(100% - 12px)",
                      background: isDonePhase
                        ? "linear-gradient(to bottom, #22c55e33, #22c55e11)"
                        : isCurrent
                          ? "linear-gradient(to bottom, #3b82f633, #1a1d27)"
                          : "#2a2f3f",
                    }}
                  />
                )}

                <div
                  className="absolute flex h-6 w-6 items-center justify-center rounded-full text-[9px] font-bold"
                  style={{
                    left: "-31px",
                    top: "2px",
                    background: dotColor,
                    border: dotBorder,
                    boxShadow: isCurrent ? "0 0 12px #3b82f644" : "none",
                    color: isFuture ? "#555e70" : "#fff",
                  }}
                >
                  {isDonePhase ? "✓" : ph.id}
                </div>

                <div
                  className="mb-5 rounded-xl border p-4 transition-opacity"
                  style={{
                    borderColor: isCurrent ? "#1e3a6e" : "#2a2f3f",
                    background: isCurrent ? "#0a1628" : "#141720",
                    opacity: isFuture ? 0.5 : 1,
                  }}
                >
                  <div className="mb-1 flex items-center justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span
                        className="text-[10px] font-semibold uppercase tracking-wider"
                        style={{ color: dotColor }}
                      >
                        {ph.label}
                      </span>
                      <span className="text-[10px] text-[#555e70]">{ph.period}</span>
                    </div>
                    {isCurrent && (
                      <span className="rounded-full border border-[#1e3a6e] bg-[#0d1f3c] px-2 py-0.5 text-[9px] font-semibold text-[#3b82f6]">
                        現在地
                      </span>
                    )}
                  </div>

                  <p
                    className="mb-1 text-sm font-medium"
                    style={{ color: isFuture ? "#8892a4" : "#e8eaf0" }}
                  >
                    {ph.title}
                  </p>
                  {"subtitle" in ph && ph.subtitle && (
                    <p className="mb-3 text-xs text-[#8892a4]">{ph.subtitle}</p>
                  )}

                  {/* body 項目（フェーズにマイルストンが無い場合） */}
                  {ph.status !== "current" && items.length > 0 && (
                    <ul className="mt-2 space-y-1">
                      {items.map((it) => {
                        const done = isDone(it);
                        return (
                          <li
                            key={it.key}
                            className="flex items-start gap-2 text-xs text-[#8892a4]"
                          >
                            <span
                              className="mt-[5px] h-1 w-1 shrink-0 rounded-full"
                              style={{ background: done ? "#22c55e" : "#3a4050" }}
                            />
                            <span style={{ textDecoration: done ? "line-through" : "none" }}>
                              {it.label}
                            </span>
                            {done && <span className="text-[#22c55e]">✓</span>}
                          </li>
                        );
                      })}
                    </ul>
                  )}

                  {/* マイルストン（Phase C） */}
                  {isCurrent && items.length > 0 && (
                    <div className="mt-3 space-y-2">
                      {items.map((it) => {
                        const done = isDone(it);
                        const isAce = it.slug === "gcp-ace";
                        const dot = done ? "#22c55e" : MS_COLOR[it.msHint ?? "upcoming"];
                        return (
                          <div
                            key={it.key}
                            className="flex items-start gap-3 rounded-xl border border-[#2a2f3f] bg-[#0f1117] px-3 py-2.5"
                          >
                            <span
                              className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full"
                              style={{ background: dot }}
                            />
                            <div className="min-w-0 flex-1">
                              <div className="flex items-center justify-between gap-2">
                                <p
                                  className="text-xs font-medium text-[#c0c8d8]"
                                  style={{ textDecoration: done ? "line-through" : "none" }}
                                >
                                  {it.label}
                                </p>
                                {done ? (
                                  <span className="shrink-0 text-[9px] font-semibold text-[#22c55e]">
                                    完了 ✓
                                  </span>
                                ) : it.msHint === "in-progress" ? (
                                  <span className="shrink-0 text-[9px] font-semibold text-[#f59e0b]">
                                    進行中
                                  </span>
                                ) : it.msHint === "next" ? (
                                  <span className="shrink-0 text-[9px] font-semibold text-[#3b82f6]">
                                    NEXT
                                  </span>
                                ) : null}
                              </div>
                              <p className="text-[11px] text-[#555e70]">{it.detail}</p>
                              {isAce && !done && acePassProb !== null && (
                                <div className="mt-2 flex items-center gap-2">
                                  <div className="h-px flex-1 overflow-hidden rounded-full bg-[#2a2f3f]">
                                    <div
                                      className="h-full rounded-full transition-all"
                                      style={{ width: `${acePassProb}%`, background: passColor(acePassProb) }}
                                    />
                                  </div>
                                  <span
                                    className="shrink-0 text-xs font-semibold tabular-nums"
                                    style={{ color: passColor(acePassProb) }}
                                  >
                                    {acePassProb}%
                                  </span>
                                </div>
                              )}
                              {isAce && !done && acePassProb === null && (
                                <p className="mt-1 text-[10px] text-[#3a4050]">
                                  GCP ACE を演習すると確率が表示されます
                                </p>
                              )}
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        <Link
          href="/"
          className="block w-full rounded-xl border border-[#2a2f3f] py-3 text-center text-sm text-[#555e70] transition hover:border-[#3a4050] hover:text-[#8892a4]"
        >
          メニューに戻る
        </Link>
      </div>
    </div>
  );
}
