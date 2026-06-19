"use client";

import Link from "next/link";

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

interface Props {
  acePassProb: number | null;
}

const MS_COLOR = {
  "in-progress": "#f59e0b",
  "next":        "#3b82f6",
  "upcoming":    "#333333",
} as const;

export function RoadmapClient({ acePassProb }: Props) {
  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  return (
    <div className={wrap}>
      <div className={container}>
        {/* Header */}
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="text-base font-semibold text-white">学習ロードマップ</h1>
            <p className="text-xs text-[#444]">DevOpsならユウ — 設計・自動化・組織浸透</p>
          </div>
          <Link
            href="/"
            className="text-xs text-[#444] transition hover:text-[#888]"
          >
            ← 戻る
          </Link>
        </div>

        {/* Timeline */}
        <div className="relative pl-8">
          {ROADMAP_PHASES.map((ph, i) => {
            const isLast = i === ROADMAP_PHASES.length - 1;
            const isDone = ph.status === "done";
            const isCurrent = ph.status === "current";
            const isFuture = ph.status === "future";

            const dotColor = isDone ? "#22c55e" : isCurrent ? "#3b82f6" : "#222";
            const dotBorder = isCurrent ? "2px solid #3b82f6" : isDone ? "none" : "1px solid #222";

            return (
              <div key={ph.id} className="relative">
                {/* Vertical line */}
                {!isLast && (
                  <div
                    className="absolute left-[-19px] top-7 w-px"
                    style={{
                      height: "calc(100% - 12px)",
                      background: isDone
                        ? "linear-gradient(to bottom, #22c55e33, #22c55e11)"
                        : isCurrent
                          ? "linear-gradient(to bottom, #3b82f633, #1a1a1a)"
                          : "#1a1a1a",
                    }}
                  />
                )}

                {/* Dot */}
                <div
                  className="absolute flex h-6 w-6 items-center justify-center rounded-full text-[9px] font-bold"
                  style={{
                    left: "-31px",
                    top: "2px",
                    background: dotColor,
                    border: dotBorder,
                    boxShadow: isCurrent ? "0 0 12px #3b82f644" : "none",
                    color: isFuture ? "#333" : "#fff",
                  }}
                >
                  {isDone ? "✓" : ph.id}
                </div>

                {/* Card */}
                <div
                  className="mb-5 rounded-xl border p-4 transition-opacity"
                  style={{
                    borderColor: isCurrent ? "#1e3a6e" : "#1a1a1a",
                    background: isCurrent ? "#0a1628" : "#0d0d0d",
                    opacity: isFuture ? 0.45 : 1,
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
                      <span className="text-[10px] text-[#333]">{ph.period}</span>
                    </div>
                    {isCurrent && (
                      <span className="rounded-full border border-[#1e3a6e] bg-[#0d1f3c] px-2 py-0.5 text-[9px] font-semibold text-[#3b82f6]">
                        現在地
                      </span>
                    )}
                  </div>

                  <p
                    className="mb-1 text-sm font-medium"
                    style={{ color: isFuture ? "#444" : "#e0e0e0" }}
                  >
                    {ph.title}
                  </p>
                  {ph.subtitle && (
                    <p className="mb-3 text-xs text-[#555]">{ph.subtitle}</p>
                  )}

                  {ph.body && (
                    <ul className="mt-2 space-y-1">
                      {ph.body.map((item, j) => (
                        <li key={j} className="flex items-start gap-2 text-xs text-[#555]">
                          <span className="mt-[5px] h-1 w-1 shrink-0 rounded-full bg-[#333]" />
                          {item}
                          {isDone && <span className="text-[#22c55e]">✓</span>}
                        </li>
                      ))}
                    </ul>
                  )}

                  {ph.milestones && (
                    <div className="mt-3 space-y-2">
                      {ph.milestones.map((ms, j) => {
                        const isAce = ms.slug === "gcp-ace";
                        return (
                          <div
                            key={j}
                            className="flex items-start gap-3 rounded-xl border border-[#111] bg-[#070707] px-3 py-2.5"
                          >
                            <span
                              className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full"
                              style={{ background: MS_COLOR[ms.ms] }}
                            />
                            <div className="min-w-0 flex-1">
                              <div className="flex items-center justify-between gap-2">
                                <p className="text-xs font-medium text-[#ccc]">{ms.title}</p>
                                {ms.ms === "in-progress" && (
                                  <span className="shrink-0 text-[9px] font-semibold text-[#f59e0b]">
                                    進行中
                                  </span>
                                )}
                                {ms.ms === "next" && (
                                  <span className="shrink-0 text-[9px] font-semibold text-[#3b82f6]">
                                    NEXT
                                  </span>
                                )}
                              </div>
                              <p className="text-[11px] text-[#444]">{ms.detail}</p>
                              {isAce && acePassProb !== null && (
                                <div className="mt-2 flex items-center gap-2">
                                  <div className="h-px flex-1 overflow-hidden rounded-full bg-[#111]">
                                    <div
                                      className="h-full rounded-full transition-all"
                                      style={{
                                        width: `${acePassProb}%`,
                                        background:
                                          acePassProb >= 70
                                            ? "#22c55e"
                                            : acePassProb >= 50
                                              ? "#f59e0b"
                                              : "#ef4444",
                                      }}
                                    />
                                  </div>
                                  <span
                                    className="shrink-0 text-xs font-semibold tabular-nums"
                                    style={{
                                      color:
                                        acePassProb >= 70
                                          ? "#22c55e"
                                          : acePassProb >= 50
                                            ? "#f59e0b"
                                            : "#ef4444",
                                    }}
                                  >
                                    {acePassProb}%
                                  </span>
                                </div>
                              )}
                              {isAce && acePassProb === null && (
                                <p className="mt-1 text-[10px] text-[#2a2a2a]">
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
          className="block w-full rounded-xl border border-[#1a1a1a] py-3 text-center text-sm text-[#444] transition hover:border-[#333] hover:text-[#888]"
        >
          メニューに戻る
        </Link>
      </div>
    </div>
  );
}
