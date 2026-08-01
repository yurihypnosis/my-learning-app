"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { CODE_TOUR_DATA, SECTION_META, type CtSection, type CtTopic } from "@/features/code-tour/lib/code-tour";
import {
  DiagramHierarchy,
  DiagramFolders,
  DiagramServerClient,
  DiagramDataFlow,
  DiagramFeatureAnatomy,
  DiagramSupabaseClients,
  DiagramTestAsSpec,
  DiagramUnknownCodeFlow,
} from "@/features/code-tour/components/diagrams";

const DIAGRAMS: Record<CtTopic["diagram"], () => React.JSX.Element> = {
  hierarchy: DiagramHierarchy,
  folders: DiagramFolders,
  "server-client": DiagramServerClient,
  "data-flow": DiagramDataFlow,
  "feature-anatomy": DiagramFeatureAnatomy,
  "supabase-clients": DiagramSupabaseClients,
  "test-spec": DiagramTestAsSpec,
  "unknown-flow": DiagramUnknownCodeFlow,
};

const SECTION_ORDER: CtSection[] = ["map", "trace", "habit"];

export function CodeTourClient() {
  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  const [filter, setFilter] = useState<CtSection | "all">("all");
  const [openId, setOpenId] = useState<string | null>(CODE_TOUR_DATA[0]?.id ?? null);

  const list = useMemo(
    () => (filter === "all" ? CODE_TOUR_DATA : CODE_TOUR_DATA.filter((t) => t.section === filter)),
    [filter]
  );

  return (
    <div className={wrap}>
      <div className={container}>
        {/* ── ヘッダ ── */}
        <div className="mb-8 flex items-start justify-between">
          <div>
            <h1 className="text-base font-semibold text-white">コードの読み方</h1>
            <p className="text-xs text-[#555e70]">このリポジトリを教材に、未知のコードを読む型を身につける</p>
          </div>
          <Link href="/" className="mt-1 text-xs text-[#555e70] transition hover:text-[#8892a4]">
            ← 戻る
          </Link>
        </div>

        {/* ── セクション絞り込み ── */}
        <div className="mb-4 flex flex-wrap gap-1.5">
          {(["all", ...SECTION_ORDER] as const).map((key) => {
            const active = filter === key;
            const color = key === "all" ? "#8892a4" : SECTION_META[key].color;
            const label = key === "all" ? "すべて" : SECTION_META[key].label;
            const count = key === "all" ? CODE_TOUR_DATA.length : CODE_TOUR_DATA.filter((t) => t.section === key).length;
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

        {/* ── トピック一覧 ── */}
        <div className="space-y-2">
          {list.map((t) => (
            <TopicCard
              key={t.id}
              t={t}
              open={openId === t.id}
              onToggle={() => setOpenId((cur) => (cur === t.id ? null : t.id))}
            />
          ))}
        </div>

        <p className="mt-8 border-t border-[#1e222e] pt-4 text-[10px] leading-relaxed text-[#3f4757]">
          ここで身につける手順（grep起点で探す・データの流れで追う・テストを仕様書として読む）は、
          このリポジトリに限らず次の現場のコードベースでもそのまま使える型として書いています。
        </p>
      </div>
    </div>
  );
}

function SectionTag({ section }: { section: CtSection }) {
  const meta = SECTION_META[section];
  return (
    <span
      className="text-[10px] font-semibold uppercase tracking-widest"
      style={{ color: meta.color }}
    >
      {meta.label}
    </span>
  );
}

function TopicCard({ t, open, onToggle }: { t: CtTopic; open: boolean; onToggle: () => void }) {
  const meta = SECTION_META[t.section];
  const Diagram = DIAGRAMS[t.diagram];
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
        <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full" style={{ background: meta.color }} />
        <span className="min-w-0 flex-1">
          <SectionTag section={t.section} />
          <span className="mt-0.5 block text-sm font-medium text-[#e6ebf5]">{t.title}</span>
          <span className="mt-0.5 block text-xs leading-relaxed text-[#555e70]">{t.point}</span>
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
          <p className="text-[10px] font-semibold tracking-wider text-[#555e70]">ざっくり言うと</p>
          <p className="mt-1.5 text-[13px] leading-relaxed text-[#c0c8d8]">{t.kid}</p>

          <p className="mt-4 text-[10px] font-semibold tracking-wider text-[#555e70]">たとえると</p>
          <p className="mt-1.5 text-[13px] leading-relaxed text-[#c0c8d8]">{t.eg}</p>

          <div className="mt-4">
            <p className="mb-2 text-[10px] font-semibold tracking-wider text-[#555e70]">図で見る</p>
            <div className="overflow-x-auto rounded-xl bg-[#0f1117] px-4 py-4 [&_svg]:h-auto [&_svg]:w-full [&_svg]:max-w-[420px]">
              <Diagram />
            </div>
          </div>

          <p className="mt-4 text-[10px] font-semibold tracking-wider text-[#555e70]">もう少し詳しく</p>
          <p className="mt-1.5 text-xs leading-[1.9] text-[#8892a4]">{t.detail}</p>

          {t.files.length > 0 && (
            <div className="mt-4 rounded-xl border border-[#2a2f3f] bg-[#0f1117]/60 p-3">
              <p className="text-[10px] font-semibold tracking-wider text-[#555e70]">実際に開いてみるファイル</p>
              <ul className="mt-1.5 space-y-1">
                {t.files.map((f) => (
                  <li key={f} className="font-mono text-[11px] leading-relaxed text-[#8892a4]">
                    {f}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
