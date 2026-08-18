"use client";

import { useEffect, useState } from "react";
import { type ExplanationData } from "@/features/quiz/lib/types";

// 図（SVG）はドット柄のキャンバスに載せ、クリックでライトボックス拡大できるようにする。
// 決定木のような細かい図は本文幅だと潰れるため、拡大導線を常に添える。
function Figure({ svg }: { svg: string }) {
  const [zoom, setZoom] = useState(false);

  useEffect(() => {
    if (!zoom) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setZoom(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [zoom]);

  return (
    <>
      <div className="figure-card">
        <div className="figure-head">
          <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            図で見る
          </p>
          <button className="figure-zoom-btn" onClick={() => setZoom(true)}>
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="11" cy="11" r="7" />
              <path d="M21 21l-3.5-3.5M11 8v6M8 11h6" />
            </svg>
            拡大表示
          </button>
        </div>
        <div
          className="figure-canvas"
          role="button"
          tabIndex={0}
          onClick={() => setZoom(true)}
          onKeyDown={(e) => {
            if (e.key === "Enter" || e.key === " ") setZoom(true);
          }}
          dangerouslySetInnerHTML={{ __html: svg }}
        />
      </div>

      {zoom && (
        <div
          className="lightbox-overlay"
          onClick={(e) => {
            if (e.target === e.currentTarget) setZoom(false);
          }}
        >
          <div className="lightbox-panel">
            <button className="lightbox-close" onClick={() => setZoom(false)} aria-label="閉じる">
              ✕
            </button>
            <div dangerouslySetInnerHTML={{ __html: svg }} />
          </div>
        </div>
      )}
    </>
  );
}

export function RichExplanation({ data }: { data: ExplanationData }) {
  const lbl = "mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]";
  return (
    <div className="space-y-5 text-sm leading-7 text-[#c0c8d8]">
      <div>
        <p className={lbl}>何を問われているか</p>
        <p>{data.asked}</p>
      </div>

      {data.point && (
        <div className="border-l-2 border-[#3b82f6]/60 pl-3.5">
          <p className={lbl}>決め手</p>
          <p className="text-[15px] text-[#e8eaf0]">{data.point}</p>
        </div>
      )}

      {data.kid && (
        <div>
          <p className={lbl}>ざっくり言うと</p>
          <p>{data.kid}</p>
        </div>
      )}

      {data.eg && (
        <div>
          <p className={lbl}>たとえると</p>
          <p>{data.eg}</p>
        </div>
      )}

      {data.viz && <Figure svg={data.viz} />}

      {data.terms && data.terms.length > 0 && (
        <div>
          <p className={lbl}>キーワード</p>
          <div className="space-y-2">
            {data.terms.map(([term, def], i) => (
              <div key={i} className="flex flex-wrap gap-x-2">
                <span className="font-semibold text-[#e8eaf0]">{term}</span>
                <span className="text-[#8892a4]">—</span>
                <span className="text-[#8892a4]">{def}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div>
        <p className={lbl}>考え方</p>
        <p>{data.think}</p>
      </div>

      {data.calc && (
        <div>
          <p className={lbl}>手で計算してみる</p>
          <pre className="overflow-x-auto whitespace-pre-wrap rounded-xl bg-[#141720] px-4 py-3.5 font-mono text-xs leading-7 text-[#c0c8d8] tabular-nums">
            {data.calc}
          </pre>
        </div>
      )}

      {data.snippet && (
        <div>
          <p className={lbl}>正しい書き方</p>
          <pre className="overflow-x-auto rounded-xl bg-[#141720] px-4 py-3.5 font-mono text-xs leading-6 text-[#8892a4]">
            <code>{data.snippet}</code>
          </pre>
        </div>
      )}

      {data.vs && (
        <div>
          <p className={lbl}>混同ポイント</p>
          <p>{data.vs}</p>
        </div>
      )}

      {data.why_asked && (
        <div>
          <p className={lbl}>なぜ問われるか</p>
          <p>{data.why_asked}</p>
        </div>
      )}

      {data.usecase && (
        <div className="rounded-xl border border-[#1e2530] bg-[#12151d] px-4 py-3">
          <p className={lbl}>使いどころ・どう役立つか</p>
          <p>{data.usecase}</p>
        </div>
      )}

      {data.opt && data.opt.length > 0 && (
        <div>
          <p className={lbl}>選択肢の解説</p>
          <div className="space-y-2">
            {data.opt.map((o, i) => (
              <div key={i} className="flex gap-3">
                <span className="w-4 shrink-0 font-semibold text-[#555e70]">{"ABCD"[i]}.</span>
                <span>{o}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
