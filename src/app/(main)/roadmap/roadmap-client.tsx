"use client";

import Link from "next/link";

const ROADMAP_PHASES = [
  {
    id: "A", label: "Phase A", title: "CI/CD基礎", period: "〜2025",
    status: "done" as const,
    body: ["GitHub Actions を実務で習得 ✓"],
  },
  {
    id: "B", label: "Phase B", title: "QA資格の積み上げ", period: "〜2025",
    status: "done" as const,
    body: ["GCP CDL 合格 ✓", "JSTQB AL-TM 合格 ✓"],
  },
  {
    id: "C", label: "Phase C", title: "DevOps技術の本丸", period: "2026",
    status: "current" as const,
    subtitle: "QA × DevOps の二刀流を確立する",
    milestones: [
      { title: "Terraform", detail: "init/apply/destroy着手済み → 自分プロジェクトで実機運用", ms: "in-progress" as const, slug: null },
      { title: "GCP Associate Cloud Engineer", detail: "7/11 受験予定", ms: "next" as const, slug: "gcp-ace" },
      { title: "CKA / Kubernetes基礎", detail: "最難関（実技）· 目安 11月〜 → 2027年3月受験見込み", ms: "upcoming" as const, slug: null },
    ],
  },
  {
    id: "1", label: "Phase 1", title: "QAアーキテクト級へ", period: "2027〜2028",
    status: "future" as const,
    body: ["CI/CD・IaC 環境を設計できる状態", "GCP Professional 級（Architect / DevOps Engineer）視野に"],
  },
  {
    id: "2", label: "Phase 2", title: "プロダクトビルダーへ", period: "2029〜2030",
    status: "future" as const,
    body: ["Q-Entropy を実プロダクト化"],
  },
];

interface Props {
  acePassProb: number | null;
}

export function RoadmapClient({ acePassProb }: Props) {
  const dotBg = (s: "done" | "current" | "future") =>
    s === "done" ? "#16a34a" : s === "current" ? "#2563eb" : "#1e293b";
  const msDot = (s: "in-progress" | "next" | "upcoming") =>
    s === "in-progress" ? "#f59e0b" : s === "next" ? "#3b82f6" : "#475569";

  const page = "flex flex-col items-center px-3.5 pb-24 pt-5";
  const card = "w-full max-w-[560px] rounded-2xl bg-card p-5 shadow-2xl sm:p-6";

  return (
    <div className={page}>
      <div className={card}>
        <div className="mb-1">
          <h2 className="text-lg font-extrabold text-slate-100">🗺 学習ロードマップ</h2>
        </div>
        <p className="mb-5 text-center text-[11px] text-muted2">
          目標：「DevOpsならユウ」― 設計・自動化・組織浸透の三拍子
        </p>

        {/* Timeline */}
        <div className="relative pl-7">
          {ROADMAP_PHASES.map((ph, i) => {
            const isLast = i === ROADMAP_PHASES.length - 1;
            return (
              <div key={ph.id} className="relative">
                {/* Vertical connector */}
                {!isLast && (
                  <div
                    className="absolute left-[-14px] top-6 w-px"
                    style={{
                      height: "calc(100% - 4px)",
                      background:
                        ph.status === "done"
                          ? "linear-gradient(to bottom, #16a34a66, #16a34a22)"
                          : ph.status === "current"
                            ? "linear-gradient(to bottom, #2563eb44, #1e293b)"
                            : "#1e293b",
                    }}
                  />
                )}
                {/* Dot */}
                <div
                  className="absolute left-[-21px] top-0 flex h-[27px] w-[27px] items-center justify-center rounded-full text-[10px] font-extrabold"
                  style={{
                    background: dotBg(ph.status),
                    border:
                      ph.status === "current" ? "2px solid #3b82f6" : "2px solid transparent",
                    boxShadow:
                      ph.status === "current" ? "0 0 14px #2563eb66" : undefined,
                    color: ph.status === "future" ? "#475569" : "#fff",
                  }}
                >
                  {ph.status === "done" ? "✓" : ph.id}
                </div>

                {/* Card */}
                <div
                  className="mb-5 rounded-xl px-4 py-3"
                  style={{
                    background:
                      ph.status === "current"
                        ? "rgba(37,99,235,0.10)"
                        : ph.status === "done"
                          ? "rgba(0,0,0,0.12)"
                          : "rgba(30,45,64,0.5)",
                    border:
                      ph.status === "current"
                        ? "1px solid rgba(59,130,246,0.35)"
                        : "1px solid transparent",
                    opacity: ph.status === "future" ? 0.55 : 1,
                  }}
                >
                  <div className="mb-0.5 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span
                        className="text-[10px] font-extrabold"
                        style={{ color: dotBg(ph.status) }}
                      >
                        {ph.label}
                      </span>
                      <span className="text-[10px] text-muted2">{ph.period}</span>
                    </div>
                    {ph.status === "current" && (
                      <span className="rounded-full bg-blue-600 px-2 py-0.5 text-[9px] font-bold text-white">
                        → 今ここ
                      </span>
                    )}
                  </div>

                  <p
                    className="text-sm font-bold"
                    style={{ color: ph.status === "future" ? "#64748b" : "#e2e8f0" }}
                  >
                    {ph.title}
                  </p>
                  {ph.subtitle && (
                    <p className="mb-2 text-[11px] text-slate-400">{ph.subtitle}</p>
                  )}

                  {ph.body && (
                    <ul className="mt-1.5 flex flex-col gap-0.5">
                      {ph.body.map((item, j) => (
                        <li key={j} className="flex items-start gap-1.5 text-[11px] text-slate-500">
                          <span className="mt-[3px] shrink-0 text-[7px] text-slate-600">●</span>
                          <span>{item}</span>
                        </li>
                      ))}
                    </ul>
                  )}

                  {ph.milestones && (
                    <div className="mt-2.5 flex flex-col gap-2">
                      {ph.milestones.map((ms, j) => {
                        const isAce = ms.slug === "gcp-ace";
                        return (
                          <div
                            key={j}
                            className="flex items-start gap-3 rounded-lg bg-black/20 px-3 py-2.5"
                          >
                            <div
                              className="mt-[3px] h-2 w-2 shrink-0 rounded-full"
                              style={{ background: msDot(ms.ms) }}
                            />
                            <div className="min-w-0 flex-1">
                              <div className="flex items-center justify-between gap-2">
                                <p className="text-[12px] font-bold text-slate-200">{ms.title}</p>
                                {ms.ms === "in-progress" && (
                                  <span className="shrink-0 text-[9px] font-bold text-amber-400">
                                    進行中
                                  </span>
                                )}
                                {ms.ms === "next" && (
                                  <span className="shrink-0 rounded bg-blue-600/30 px-1.5 py-0.5 text-[9px] font-bold text-blue-300">
                                    NEXT
                                  </span>
                                )}
                              </div>
                              <p className="text-[11px] text-slate-500">{ms.detail}</p>
                              {isAce && acePassProb !== null && (
                                <div className="mt-1.5 flex items-center gap-2">
                                  <div className="h-1.5 flex-1 overflow-hidden rounded-full bg-black/40">
                                    <div
                                      className="h-full rounded-full transition-all"
                                      style={{
                                        width: `${acePassProb}%`,
                                        background:
                                          acePassProb >= 70
                                            ? "#16a34a"
                                            : acePassProb >= 50
                                              ? "#d97706"
                                              : "#dc2626",
                                      }}
                                    />
                                  </div>
                                  <span
                                    className="shrink-0 text-[11px] font-extrabold"
                                    style={{
                                      color:
                                        acePassProb >= 70
                                          ? "#86efac"
                                          : acePassProb >= 50
                                            ? "#fcd34d"
                                            : "#f87171",
                                    }}
                                  >
                                    {acePassProb}%
                                  </span>
                                </div>
                              )}
                              {isAce && acePassProb === null && (
                                <p className="mt-0.5 text-[10px] text-slate-600">
                                  GCP ACE を演習すると合格確率が表示されます
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

        {/* Tagline */}
        <div className="rounded-xl border border-slate-700/40 px-4 py-3 text-center">
          <p className="text-[11px] text-slate-400">
            「DevOpsならユウ」— DeNA 級の DevOps エンジニア
          </p>
          <p className="mt-0.5 text-[10px] text-muted2">
            設計できる・自動化できる・組織に浸透させられる
          </p>
        </div>

        <Link
          href="/"
          className="mt-4 block w-full rounded-xl bg-card2 py-3 text-center text-sm font-bold text-muted"
        >
          メニューに戻る
        </Link>
      </div>
    </div>
  );
}
