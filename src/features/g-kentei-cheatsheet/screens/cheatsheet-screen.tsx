"use client";

import { useMemo, useState } from "react";
import type { CheatsheetEntry } from "@/features/g-kentei-cheatsheet/lib/types";

function searchableText(e: CheatsheetEntry): string {
  return [
    e.category,
    e.asked,
    e.point,
    e.whyAsked,
    e.eg,
    e.vs,
    e.think,
    e.calc ?? "",
    ...e.terms.flat(),
  ].join(" \n");
}

function EntryCard({ entry }: { entry: CheatsheetEntry }) {
  const [open, setOpen] = useState(false);
  const hasDetail = entry.whyAsked || entry.eg || entry.think || entry.calc;

  return (
    <div className="border-b border-border py-4">
      <p className="mb-1.5 text-[10px] font-semibold uppercase tracking-[.18em] text-muted2">
        {entry.category}
      </p>
      <p className="text-[15px] leading-6 text-fg">{entry.asked}</p>

      {entry.point && (
        <div className="mt-2 border-l-2 border-primary/60 pl-3">
          <p className="text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
            決め手
          </p>
          <p className="text-sm leading-6 text-fg/90">{entry.point}</p>
        </div>
      )}

      {entry.terms.length > 0 && (
        <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1">
          {entry.terms.map(([term, def], i) => (
            <p key={i} className="text-[13px] leading-6 text-muted">
              <span className="font-medium text-muted/90">{term}</span>
              <span className="text-muted2"> — </span>
              {def}
            </p>
          ))}
        </div>
      )}

      {entry.vs && <p className="mt-1.5 text-[13px] leading-6 text-muted2">{entry.vs}</p>}

      {hasDetail && (
        <div className="mt-2">
          <button
            type="button"
            onClick={() => setOpen((v) => !v)}
            className="text-[11px] font-medium tracking-wide text-primary2 hover:text-primary"
          >
            {open ? "閉じる ▲" : "もっと見る ▾"}
          </button>
          {open && (
            <div className="mt-2 space-y-2 border-t border-border pt-2">
              {entry.whyAsked && (
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
                    なぜ問われるか
                  </p>
                  <p className="text-[13px] leading-6 text-muted">{entry.whyAsked}</p>
                </div>
              )}
              {entry.eg && (
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
                    たとえ
                  </p>
                  <p className="text-[13px] leading-6 text-muted">{entry.eg}</p>
                </div>
              )}
              {entry.think && (
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
                    考え方
                  </p>
                  <p className="text-[13px] leading-6 text-muted">{entry.think}</p>
                </div>
              )}
              {entry.calc && (
                <div>
                  <p className="text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
                    計算
                  </p>
                  <pre className="whitespace-pre-wrap font-mono text-[12px] leading-6 text-muted">
                    {entry.calc}
                  </pre>
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export function CheatsheetScreen({ entries }: { entries: CheatsheetEntry[] }) {
  const [query, setQuery] = useState("");
  const [activeCategories, setActiveCategories] = useState<Set<string>>(new Set());

  const categories = useMemo(() => {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const e of entries) {
      if (!seen.has(e.category)) {
        seen.add(e.category);
        out.push(e.category);
      }
    }
    return out;
  }, [entries]);

  const indexed = useMemo(
    () => entries.map((e) => ({ entry: e, text: searchableText(e) })),
    [entries]
  );

  const filtered = useMemo(() => {
    const q = query.trim();
    return indexed
      .filter(({ entry }) => activeCategories.size === 0 || activeCategories.has(entry.category))
      .filter(({ text }) => q === "" || text.includes(q))
      .map(({ entry }) => entry);
  }, [indexed, query, activeCategories]);

  function toggleCategory(name: string) {
    setActiveCategories((prev) => {
      const next = new Set(prev);
      if (next.has(name)) next.delete(name);
      else next.add(name);
      return next;
    });
  }

  return (
    <div className="mx-auto max-w-2xl px-4 pb-16 pt-6">
      <p className="text-[10px] font-semibold uppercase tracking-[.18em] text-muted2">
        G検定 チートシート
      </p>
      <h1 className="mt-1 text-xl font-light tracking-tight text-fg">全{entries.length}問の決め手・用語弁別</h1>

      <div className="sticky top-0 z-10 -mx-4 mt-4 bg-bg/95 px-4 pb-3 pt-3 backdrop-blur">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="用語・キーワードで検索"
          className="w-full rounded-md border border-border bg-card px-3 py-2 text-sm text-fg placeholder:text-muted2 focus:border-border2 focus:outline-none"
        />
        <div className="mt-2 flex flex-wrap gap-1.5">
          {categories.map((c) => {
            const active = activeCategories.has(c);
            return (
              <button
                key={c}
                type="button"
                onClick={() => toggleCategory(c)}
                className={
                  "rounded-full border px-2.5 py-1 text-[11px] leading-none transition-colors " +
                  (active
                    ? "border-primary/60 text-primary2"
                    : "border-border text-muted hover:border-border2")
                }
              >
                {c}
              </button>
            );
          })}
        </div>
        <p className="mt-2 text-[11px] text-muted2">{filtered.length}件</p>
      </div>

      <div>
        {filtered.map((entry) => (
          <EntryCard key={entry.id} entry={entry} />
        ))}
        {filtered.length === 0 && (
          <p className="py-10 text-center text-sm text-muted2">該当する項目がありません</p>
        )}
      </div>
    </div>
  );
}
