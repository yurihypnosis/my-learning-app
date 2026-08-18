"use client";

import { useEffect, useMemo, useState } from "react";
import { usePageHeader } from "@/shared/components/app-shell";
import {
  CATEGORY_META,
  MINDSET_DATA,
  type MCategory,
  type MPrinciple,
} from "@/features/mindset/lib/mindset";

// 「今日の視点」は日付で決める。毎日ひとつだけ回ってくるほうが読む。
// SSR と食い違わないよう、日付の確定は mount 後に行う（ロードマップと同じ作法）。
function pickOfDay(nowMs: number): MPrinciple {
  const d = new Date(nowMs);
  const dayNo = Math.floor(
    new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime() / 86_400_000
  );
  return MINDSET_DATA[dayNo % MINDSET_DATA.length];
}

export function MindsetClient() {
  const wrap = "flex flex-col items-center pb-16";
  const container = "w-full max-w-[560px]";

  usePageHeader("勉強の思考フレーム", "迷ったときに開く — 考え方から決める");

  const [filter, setFilter] = useState<MCategory | "all">("all");
  const [openId, setOpenId] = useState<string | null>(null);

  const [nowMs, setNowMs] = useState<number | null>(null);
  // eslint-disable-next-line react-hooks/set-state-in-effect -- SSR と初回描画を一致させるため mount 後に実時刻を確定する
  useEffect(() => setNowMs(Date.now()), []);

  const today = nowMs === null ? null : pickOfDay(nowMs);

  const list = useMemo(
    () =>
      filter === "all"
        ? MINDSET_DATA
        : MINDSET_DATA.filter((p) => p.category === filter),
    [filter]
  );

  return (
    <div className={wrap}>
      <div className={container}>
        {/* ── 今日の視点 ── */}
        <div className="mb-8">
          <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            今日の視点
          </p>
          {today === null ? (
            <div className="h-[150px] animate-pulse rounded-2xl border border-[#2a2f3f] bg-[#151823]" />
          ) : (
            <TodayCard p={today} />
          )}
        </div>

        {/* ── カテゴリ絞り込み ── */}
        <div className="mb-4 flex flex-wrap gap-1.5">
          {(["all", ...(Object.keys(CATEGORY_META) as MCategory[])] as const).map((key) => {
            const active = filter === key;
            const color = key === "all" ? "#8892a4" : CATEGORY_META[key].color;
            const label = key === "all" ? "すべて" : CATEGORY_META[key].label;
            const count =
              key === "all"
                ? MINDSET_DATA.length
                : MINDSET_DATA.filter((p) => p.category === key).length;
            return (
              <button
                key={key}
                onClick={() => setFilter(key)}
                className="rounded-lg border px-2.5 py-1.5 text-[11px] font-medium transition"
                style={{
                  borderColor: active ? color : "#2a2f3f",
                  color: active ? color : "#8892a4",
                  background: active ? color + "1a" : "transparent",
                }}
              >
                {label}
                <span className="ml-1.5 opacity-50">{count}</span>
              </button>
            );
          })}
        </div>

        {/* ── 原則リスト ── */}
        <div className="space-y-2">
          {list.map((p) => (
            <PrincipleCard
              key={p.id}
              p={p}
              open={openId === p.id}
              onToggle={() => setOpenId((cur) => (cur === p.id ? null : p.id))}
            />
          ))}
        </div>

        {/* ── 出典の断り書き ── */}
        <p className="mt-8 border-t border-[#1e222e] pt-4 text-[10px] leading-relaxed text-[#3f4757]">
          ※印の付いたものを除き、河野玄斗さんが公開している勉強法（逆算・回転数・アウトプット重視など）を
          下敷きに、「この原則ならこう考えるはず」という形で再構成したものです。本人の発言の引用ではありません。
        </p>
      </div>
    </div>
  );
}

// 由来が違う原則にだけ付く小さな断り。下部の注記と食い違わせないための札。
function SourceTag({ text }: { text: string }) {
  return (
    <p className="mt-3 flex items-start gap-1.5 text-[10px] leading-relaxed text-[#555e70]">
      <span className="mt-px shrink-0 opacity-60">※</span>
      <span>{text}</span>
    </p>
  );
}

// 今日ひとつだけ回ってくるカード。カテゴリ色を淡く敷いて、リストとは別格に見せる。
function TodayCard({ p }: { p: MPrinciple }) {
  const meta = CATEGORY_META[p.category];
  return (
    <div
      className="relative overflow-hidden rounded-2xl border p-5"
      style={{ borderColor: meta.color + "40", background: meta.color + "0d" }}
    >
      <div
        className="pointer-events-none absolute -right-16 -top-16 h-40 w-40 rounded-full blur-3xl"
        style={{ background: meta.color + "26" }}
      />
      <div className="relative">
        <span
          className="text-[10px] font-semibold uppercase tracking-widest"
          style={{ color: meta.color }}
        >
          {meta.label}
        </span>
        <h2 className="mt-2 text-lg font-semibold leading-snug text-white">{p.title}</h2>
        <p className="mt-2 text-[13px] leading-relaxed text-[#c0c8d8]">{p.essence}</p>
        {p.attribution && <SourceTag text={p.attribution} />}
        <div className="mt-4 rounded-xl border border-[#2a2f3f] bg-[#0f1117]/60 p-3">
          <p className="text-[10px] font-semibold tracking-wider text-[#555e70]">今日の一手</p>
          <p className="mt-1 text-xs leading-relaxed text-[#8892a4]">{p.action}</p>
        </div>
      </div>
    </div>
  );
}

// 畳んだ状態はタイトルと一言だけ。読む気があるときだけ中身を開く。
function PrincipleCard({
  p,
  open,
  onToggle,
}: {
  p: MPrinciple;
  open: boolean;
  onToggle: () => void;
}) {
  const meta = CATEGORY_META[p.category];
  return (
    <div
      className="overflow-hidden rounded-xl border bg-[#151823] transition-colors"
      style={{ borderColor: open ? meta.color + "59" : "#2a2f3f" }}
    >
      <button
        onClick={onToggle}
        aria-expanded={open}
        className="flex w-full items-start gap-3 px-4 py-3.5 text-left"
      >
        <span
          className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full"
          style={{ background: meta.color }}
        />
        <span className="min-w-0 flex-1">
          <span className="block text-sm font-medium text-[#e6ebf5]">{p.title}</span>
          <span className="mt-0.5 block text-xs leading-relaxed text-[#555e70]">{p.essence}</span>
        </span>
        <span
          className="mt-0.5 shrink-0 text-[10px] text-[#555e70] transition-transform"
          style={{ transform: open ? "rotate(180deg)" : "none" }}
        >
          ▾
        </span>
      </button>

      {open && (
        <div className="border-t border-[#1e222e] px-4 py-4">
          <p className="text-[10px] font-semibold tracking-wider" style={{ color: meta.color }}>
            こう考える
          </p>
          <p className="mt-1.5 text-[13px] leading-[1.9] text-[#c0c8d8]">{p.think}</p>
          {p.attribution && <SourceTag text={p.attribution} />}

          <p className="mt-4 text-[10px] font-semibold tracking-wider text-[#555e70]">
            ユウの場合
          </p>
          <p className="mt-1.5 text-xs leading-relaxed text-[#8892a4]">{p.action}</p>
        </div>
      )}
    </div>
  );
}
