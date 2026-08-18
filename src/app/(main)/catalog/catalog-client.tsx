"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import type { ExamGroup } from "@/features/quiz/lib/stats";
import { accuracyColor, fmtLastStudied, statusOf } from "@/features/quiz/lib/format";
import { useNow } from "@/features/quiz/hooks/use-now";
import { usePageHeader } from "@/shared/components/app-shell";

type Filter = "all" | "pass" | "study" | "weak" | "new";

const FILTERS: { key: Filter; label: string }[] = [
  { key: "all", label: "すべて" },
  { key: "pass", label: "合格圏" },
  { key: "study", label: "学習中" },
  { key: "weak", label: "苦手" },
  { key: "new", label: "未着手" },
];

// 状況ラベル → フィルタキー。statusOf と同じ閾値を使う。
function filterKeyOf(g: ExamGroup): Exclude<Filter, "all"> {
  if (g.answers === 0) return "new";
  if (g.accuracy >= 0.7) return "pass";
  if (g.accuracy >= 0.5) return "study";
  return "weak";
}

// 試験区分ごとのアイコン色。slug の接頭辞でざっくり系統を分ける。
function iconTone(examKey: string): { color: string; soft: string } {
  if (examKey.startsWith("gcp")) return { color: "var(--primary2)", soft: "var(--primary-soft)" };
  if (examKey.startsWith("pv")) return { color: "var(--orange)", soft: "var(--orange-soft)" };
  if (examKey.includes("ctal") || examKey.includes("istqb"))
    return { color: "var(--green)", soft: "var(--green-soft)" };
  return { color: "var(--purple)", soft: "var(--purple-soft)" };
}

export function CatalogClient({
  examGroups,
  currentSlug,
}: {
  examGroups: ExamGroup[];
  currentSlug: string | null;
}) {
  const router = useRouter();
  // 「最終演習」の相対表記に使う現在時刻。マウント後に確定させて SSR とのズレを避ける。
  const now = useNow();
  const [filter, setFilter] = useState<Filter>("all");
  const [query, setQuery] = useState("");
  const [openSets, setOpenSets] = useState<Set<string>>(new Set());

  usePageHeader(
    "問題集一覧",
    `全 ${examGroups.length} 試験区分 ・ カードをクリックするとその問題集を開きます`
  );

  const counts = useMemo(() => {
    const c: Record<Filter, number> = { all: examGroups.length, pass: 0, study: 0, weak: 0, new: 0 };
    for (const g of examGroups) c[filterKeyOf(g)]++;
    return c;
  }, [examGroups]);

  const visible = examGroups.filter((g) => {
    if (filter !== "all" && filterKeyOf(g) !== filter) return false;
    const q = query.trim().toLowerCase();
    if (!q) return true;
    return (
      g.examName.toLowerCase().includes(q) ||
      g.examKey.toLowerCase().includes(q) ||
      g.sets.some((s) => s.name.toLowerCase().includes(q))
    );
  });

  const open = (slug: string) => router.push(`/?subject=${slug}`);

  return (
    <>
      <div className="catalog-toolbar">
        <div className="filter-chips">
          {FILTERS.map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`filter-chip ${filter === f.key ? "on" : ""}`}
            >
              {f.label} <span className="n">{counts[f.key]}</span>
            </button>
          ))}
        </div>
        <label className="flex w-[240px] items-center gap-2 rounded-[10px] border border-border bg-card px-3 py-2 text-[12.5px] text-muted2">
          <svg
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            className="shrink-0"
          >
            <circle cx="11" cy="11" r="7" />
            <path d="M21 21l-3.5-3.5" />
          </svg>
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="問題集を検索"
            className="w-full border-none bg-transparent text-[12.5px] text-fg outline-none placeholder:text-muted2"
          />
        </label>
      </div>

      {visible.length === 0 ? (
        <p className="py-10 text-center text-[13px] text-muted2">該当する問題集が見つかりません</p>
      ) : (
        <div className="catalog-grid">
          {visible.map((g) => {
            const st = statusOf(g.accuracy, g.answers);
            const tone = iconTone(g.examKey);
            const isCurrent = g.sets.some((s) => s.slug === currentSlug);
            const setsOpen = openSets.has(g.examKey);
            const target = g.sets.find((s) => s.slug === currentSlug)?.slug ?? g.sets[0].slug;
            return (
              <div
                key={g.examKey}
                role="button"
                tabIndex={0}
                className={`catalog-card ${isCurrent ? "current" : ""}`}
                onClick={() => open(target)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") open(target);
                }}
              >
                <div className="catalog-top">
                  <div
                    className="catalog-icon"
                    style={{ background: tone.soft, color: tone.color }}
                  >
                    <svg
                      width="18"
                      height="18"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <path d="M12 2 2 7l10 5 10-5-10-5z" />
                      <path d="M2 17l10 5 10-5" />
                      <path d="M2 12l10 5 10-5" />
                    </svg>
                  </div>
                  <span className="status-pill" style={{ color: st.color, background: st.bg }}>
                    {st.label}
                  </span>
                </div>

                <div className="catalog-name">{g.examName}</div>
                <div className="catalog-sub">
                  全{g.total}問
                  {g.sets.length > 1 && (
                    <button
                      className={`set-toggle ml-1.5 ${setsOpen ? "open" : ""}`}
                      onClick={(e) => {
                        e.stopPropagation();
                        setOpenSets((prev) => {
                          const next = new Set(prev);
                          if (next.has(g.examKey)) next.delete(g.examKey);
                          else next.add(g.examKey);
                          return next;
                        });
                      }}
                    >
                      {g.sets.length}セット
                      <svg width="9" height="9" viewBox="0 0 10 10" fill="none">
                        <path
                          d="M2 3.5L5 6.5L8 3.5"
                          stroke="currentColor"
                          strokeWidth="1.4"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                    </button>
                  )}
                </div>

                {setsOpen && g.sets.length > 1 && (
                  <div className="set-list">
                    {g.sets.map((s) => (
                      <button
                        key={s.slug}
                        className="set-row"
                        onClick={(e) => {
                          e.stopPropagation();
                          open(s.slug);
                        }}
                      >
                        <b>{s.name}</b>
                        <span>
                          {s.total}問 ・ {s.answers === 0 ? "未演習" : `${Math.round(s.accuracy * 100)}%`}
                        </span>
                      </button>
                    ))}
                  </div>
                )}

                <div className="catalog-progress-row">
                  <div className="accuracy-track">
                    <div
                      className="accuracy-fill"
                      style={{
                        width: `${Math.round(g.accuracy * 100)}%`,
                        background: accuracyColor(g.accuracy, g.answers),
                      }}
                    />
                  </div>
                  <span
                    className="text-[11.5px] font-bold"
                    style={{ color: g.answers === 0 ? "var(--muted2)" : undefined }}
                  >
                    {g.answers === 0 ? "—" : `${Math.round(g.accuracy * 100)}%`}
                  </span>
                </div>
                <div className="catalog-meta">
                  <span>
                    {g.attempted} / {g.total}問 着手
                  </span>
                  <span>{fmtLastStudied(g.lastAnsweredAt, now)}</span>
                </div>

                <div className="catalog-footer">
                  <button
                    className={g.answers === 0 ? "btn-ghost" : "btn-primary"}
                    style={{ flex: 1, padding: 9, fontSize: 12.5 }}
                    onClick={(e) => {
                      e.stopPropagation();
                      open(target);
                    }}
                  >
                    {g.answers === 0 ? "はじめる" : "演習する"}
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </>
  );
}
