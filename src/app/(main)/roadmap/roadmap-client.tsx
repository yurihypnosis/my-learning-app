"use client";

import { useMemo, useRef, useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import type { Json } from "@/types/database";
import {
  newId,
  type RItem,
  type RPhase,
  type RStatus,
  type RoadmapDoc,
} from "@/lib/roadmap";

interface Props {
  acePassProb: number | null;
  userId: string;
  initialDoc: RoadmapDoc;
}

const STATUS_META: Record<RStatus, { label: string; color: string }> = {
  done: { label: "完了", color: "#22c55e" },
  current: { label: "現在", color: "#3b82f6" },
  future: { label: "予定", color: "#555e70" },
};

const passColor = (p: number) => (p >= 70 ? "#22c55e" : p >= 50 ? "#f59e0b" : "#ef4444");

export function RoadmapClient({ acePassProb, userId, initialDoc }: Props) {
  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  const supabase = useMemo(() => createClient(), []);
  const [doc, setDoc] = useState<RoadmapDoc>(initialDoc);
  const [screen, setScreen] = useState<"view" | "edit">("view");
  const saveTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // doc 全体を（デバウンスして）DB に保存する。編集・完了トグルすべてで使う。
  const commit = (next: RoadmapDoc) => {
    setDoc(next);
    if (!userId) return;
    if (saveTimer.current) clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(async () => {
      const { error } = await supabase
        .from("user_roadmap")
        .upsert(
          { user_id: userId, doc: next as unknown as Json },
          { onConflict: "user_id" }
        );
      if (error) console.error("[user_roadmap] save failed:", error.code, error.message);
    }, 600);
  };

  // ── mutators ──
  const patchPhase = (pi: number, patch: Partial<RPhase>) =>
    commit({ phases: doc.phases.map((p, i) => (i === pi ? { ...p, ...patch } : p)) });

  const addPhase = () =>
    commit({
      phases: [
        ...doc.phases,
        {
          id: newId("p"),
          label: `Phase ${doc.phases.length + 1}`,
          title: "新しいフェーズ",
          period: "",
          status: "future",
          items: [],
        },
      ],
    });

  const deletePhase = (pi: number) =>
    commit({ phases: doc.phases.filter((_, i) => i !== pi) });

  const movePhase = (pi: number, dir: -1 | 1) => {
    const j = pi + dir;
    if (j < 0 || j >= doc.phases.length) return;
    const phases = [...doc.phases];
    [phases[pi], phases[j]] = [phases[j], phases[pi]];
    commit({ phases });
  };

  const patchItem = (pi: number, ii: number, patch: Partial<RItem>) =>
    commit({
      phases: doc.phases.map((p, i) =>
        i === pi
          ? { ...p, items: p.items.map((it, k) => (k === ii ? { ...it, ...patch } : it)) }
          : p
      ),
    });

  const addItem = (pi: number) =>
    commit({
      phases: doc.phases.map((p, i) =>
        i === pi
          ? {
              ...p,
              items: [
                ...p.items,
                { id: newId("i"), kind: "milestone", text: "", detail: "", done: false },
              ],
            }
          : p
      ),
    });

  const deleteItem = (pi: number, ii: number) =>
    commit({
      phases: doc.phases.map((p, i) =>
        i === pi ? { ...p, items: p.items.filter((_, k) => k !== ii) } : p
      ),
    });

  const moveItem = (pi: number, ii: number, dir: -1 | 1) => {
    const phase = doc.phases[pi];
    const j = ii + dir;
    if (j < 0 || j >= phase.items.length) return;
    const items = [...phase.items];
    [items[ii], items[j]] = [items[j], items[ii]];
    commit({ phases: doc.phases.map((p, i) => (i === pi ? { ...p, items } : p)) });
  };

  // ── 編集画面 ──
  if (screen === "edit") {
    const iconBtn =
      "flex h-6 w-6 items-center justify-center rounded-md border border-[#2a2f3f] text-[11px] text-[#8892a4] transition hover:border-[#3a4050] hover:text-white disabled:opacity-30";
    const field =
      "w-full rounded-lg border border-[#2a2f3f] bg-[#0f1117] px-2.5 py-1.5 text-xs text-white outline-none focus:border-[#3b82f6] transition-colors";

    return (
      <div className={wrap}>
        <div className={container}>
          <div className="mb-1 flex items-center justify-between">
            <h1 className="text-base font-semibold text-white">ロードマップ編集</h1>
            <button
              onClick={() => setScreen("view")}
              className="rounded-lg bg-[#3b82f6] px-3 py-1.5 text-xs font-medium text-white transition hover:bg-[#60a5fa]"
            >
              完了
            </button>
          </div>
          <p className="mb-5 text-[11px] text-[#555e70]">変更は自動保存されます</p>

          <div className="space-y-4">
            {doc.phases.map((ph, pi) => (
              <div key={ph.id} className="rounded-xl border border-[#2a2f3f] bg-[#141720] p-3.5">
                <div className="mb-2 flex items-center gap-2">
                  <input
                    className={field + " flex-1"}
                    value={ph.label}
                    placeholder="ラベル（Phase X）"
                    onChange={(e) => patchPhase(pi, { label: e.target.value })}
                  />
                  <div className="flex items-center gap-1">
                    <button className={iconBtn} disabled={pi === 0} onClick={() => movePhase(pi, -1)}>↑</button>
                    <button className={iconBtn} disabled={pi === doc.phases.length - 1} onClick={() => movePhase(pi, 1)}>↓</button>
                    <button
                      className="flex h-6 w-6 items-center justify-center rounded-md border border-[#2a1010] text-[11px] text-[#ef4444] transition hover:border-[#3f1515]"
                      onClick={() => deletePhase(pi)}
                    >
                      🗑
                    </button>
                  </div>
                </div>

                <input
                  className={field + " mb-2"}
                  value={ph.title}
                  placeholder="タイトル"
                  onChange={(e) => patchPhase(pi, { title: e.target.value })}
                />
                <div className="mb-2 flex gap-2">
                  <input
                    className={field + " flex-1"}
                    value={ph.period}
                    placeholder="時期（例: 2026）"
                    onChange={(e) => patchPhase(pi, { period: e.target.value })}
                  />
                  <div className="flex shrink-0 gap-1">
                    {(Object.keys(STATUS_META) as RStatus[]).map((st) => (
                      <button
                        key={st}
                        onClick={() => patchPhase(pi, { status: st })}
                        className="rounded-lg border px-2 py-1.5 text-[11px] font-medium transition"
                        style={{
                          borderColor: ph.status === st ? STATUS_META[st].color : "#2a2f3f",
                          color: ph.status === st ? STATUS_META[st].color : "#8892a4",
                          background: ph.status === st ? STATUS_META[st].color + "1a" : "transparent",
                        }}
                      >
                        {STATUS_META[st].label}
                      </button>
                    ))}
                  </div>
                </div>
                <input
                  className={field + " mb-3"}
                  value={ph.subtitle ?? ""}
                  placeholder="サブタイトル（任意）"
                  onChange={(e) => patchPhase(pi, { subtitle: e.target.value || undefined })}
                />

                <div className="space-y-2">
                  {ph.items.map((it, ii) => (
                    <div key={it.id} className="rounded-lg border border-[#2a2f3f] bg-[#0f1117] p-2.5">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => patchItem(pi, ii, { done: !it.done })}
                          className="flex h-4 w-4 shrink-0 items-center justify-center rounded-[5px] border text-[10px] font-bold"
                          style={{
                            background: it.done ? "#22c55e" : "transparent",
                            borderColor: it.done ? "#22c55e" : "#3a4050",
                            color: "#0f1117",
                          }}
                          aria-label="完了"
                        >
                          {it.done ? "✓" : ""}
                        </button>
                        <input
                          className={field + " flex-1"}
                          value={it.text}
                          placeholder="項目名"
                          onChange={(e) => patchItem(pi, ii, { text: e.target.value })}
                        />
                        <div className="flex items-center gap-1">
                          <button className={iconBtn} disabled={ii === 0} onClick={() => moveItem(pi, ii, -1)}>↑</button>
                          <button className={iconBtn} disabled={ii === ph.items.length - 1} onClick={() => moveItem(pi, ii, 1)}>↓</button>
                          <button
                            className="flex h-6 w-6 items-center justify-center rounded-md border border-[#2a1010] text-[11px] text-[#ef4444] transition hover:border-[#3f1515]"
                            onClick={() => deleteItem(pi, ii)}
                          >
                            ✕
                          </button>
                        </div>
                      </div>
                      <input
                        className={field + " mt-2"}
                        value={it.detail ?? ""}
                        placeholder="詳細（任意）"
                        onChange={(e) => patchItem(pi, ii, { detail: e.target.value || undefined })}
                      />
                    </div>
                  ))}
                  <button
                    onClick={() => addItem(pi)}
                    className="w-full rounded-lg border border-dashed border-[#2a2f3f] py-2 text-[11px] text-[#8892a4] transition hover:border-[#3a4050] hover:text-white"
                  >
                    + 項目を追加
                  </button>
                </div>
              </div>
            ))}

            <button
              onClick={addPhase}
              className="w-full rounded-xl border border-dashed border-[#2a2f3f] py-3 text-xs text-[#8892a4] transition hover:border-[#3a4050] hover:text-white"
            >
              + フェーズを追加
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ── 表示（本体） ──
  return (
    <div className={wrap}>
      <div className={container}>
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="text-base font-semibold text-white">学習ロードマップ</h1>
            <p className="text-xs text-[#555e70]">DevOpsならユウ — 設計・自動化・組織浸透</p>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => setScreen("edit")}
              className="rounded-lg border border-[#2a2f3f] px-2.5 py-1.5 text-[11px] text-[#8892a4] transition hover:border-[#3a4050] hover:text-white"
            >
              ⚙ 編集
            </button>
            <Link href="/" className="text-xs text-[#555e70] transition hover:text-[#8892a4]">
              ← 戻る
            </Link>
          </div>
        </div>

        {doc.phases.length === 0 && (
          <p className="mb-6 rounded-xl border border-dashed border-[#2a2f3f] py-8 text-center text-xs text-[#555e70]">
            まだフェーズがありません。「⚙ 編集」から追加してください。
          </p>
        )}

        <div className="relative pl-8">
          {doc.phases.map((ph, i) => {
            const isLast = i === doc.phases.length - 1;
            const isDonePhase = ph.status === "done";
            const isCurrent = ph.status === "current";
            const isFuture = ph.status === "future";
            const dotColor = STATUS_META[ph.status].color;
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
                    background: isFuture ? "#2a2f3f" : dotColor,
                    border: dotBorder,
                    boxShadow: isCurrent ? "0 0 12px #3b82f644" : "none",
                    color: isFuture ? "#555e70" : "#fff",
                  }}
                >
                  {isDonePhase ? "✓" : String(ph.id).slice(0, 1).toUpperCase()}
                </div>

                <div
                  className="mb-5 rounded-xl border p-4 transition-opacity"
                  style={{
                    borderColor: isCurrent ? "#1e3a6e" : "#2a2f3f",
                    background: isCurrent ? "#0a1628" : "#141720",
                    opacity: isFuture ? 0.6 : 1,
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
                      {ph.period && <span className="text-[10px] text-[#555e70]">{ph.period}</span>}
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
                  {ph.subtitle && <p className="mb-3 text-xs text-[#8892a4]">{ph.subtitle}</p>}

                  {ph.items.length > 0 && (
                    <div className="mt-3 space-y-2">
                      {ph.items.map((it) => {
                        const isAce = it.slug === "gcp-ace";
                        return (
                          <div
                            key={it.id}
                            className="flex items-start gap-3 rounded-xl border border-[#2a2f3f] bg-[#0f1117] px-3 py-2.5"
                          >
                            <span
                              className="mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded-full text-[9px] font-bold"
                              style={{
                                background: it.done ? "#22c55e" : "transparent",
                                border: it.done ? "none" : "1.5px solid #3a4050",
                                color: "#0f1117",
                              }}
                            >
                              {it.done ? "✓" : ""}
                            </span>
                            <div className="min-w-0 flex-1">
                              <div className="flex items-center justify-between gap-2">
                                <p
                                  className="text-xs font-medium text-[#c0c8d8]"
                                  style={{ textDecoration: it.done ? "line-through" : "none" }}
                                >
                                  {it.text || "（無題）"}
                                </p>
                                {it.done && (
                                  <span className="shrink-0 text-[9px] font-semibold text-[#22c55e]">
                                    完了
                                  </span>
                                )}
                              </div>
                              {it.detail && <p className="text-[11px] text-[#555e70]">{it.detail}</p>}
                              {isAce && !it.done && acePassProb !== null && (
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
