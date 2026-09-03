"use client";

import { useMemo, useState } from "react";
import type { ComparisonGroup, TermEntry } from "@/features/g-kentei-cheatsheet/lib/types";

interface RelatedNote {
  category: string;
  note: string;
}

type RelatedMap = Map<string, Map<string, RelatedNote[]>>;

// 1問の terms に一緒に並んでいた用語どうしを「似ている概念」として双方向に結びつける。
// note はその問題の vs をそのまま使い、新しい比較文は作らない。
function buildRelatedMap(comparisons: ComparisonGroup[]): RelatedMap {
  const m: RelatedMap = new Map();
  for (const g of comparisons) {
    for (let i = 0; i < g.terms.length; i++) {
      for (let j = 0; j < g.terms.length; j++) {
        if (i === j) continue;
        const a = g.terms[i];
        const b = g.terms[j];
        if (!m.has(a)) m.set(a, new Map());
        const inner = m.get(a)!;
        if (!inner.has(b)) inner.set(b, []);
        inner.get(b)!.push({ category: g.category, note: g.note });
      }
    }
  }
  return m;
}

function TermRow({
  term,
  related,
  termById,
}: {
  term: TermEntry;
  related: Map<string, RelatedNote[]> | undefined;
  termById: Map<string, TermEntry>;
}) {
  const [showAlt, setShowAlt] = useState(false);
  const [showExamples, setShowExamples] = useState(false);
  const [compareId, setCompareId] = useState<string | null>(null);

  const relatedList = useMemo(
    () => (related ? [...related.entries()].sort((a, b) => b[1].length - a[1].length) : []),
    [related]
  );

  const compareTarget = compareId ? termById.get(compareId) : undefined;
  const compareNotes = compareId ? related?.get(compareId) : undefined;
  const uniqueNotes = compareNotes
    ? [...new Map(compareNotes.map((n) => [n.note, n])).values()]
    : [];

  return (
    <div className="border-b border-border py-4">
      <p className="mb-1.5 text-[10px] font-semibold uppercase tracking-[.18em] text-muted2">
        {term.categories[0]}
        {term.categories.length > 1 && ` 他${term.categories.length - 1}分野`}
      </p>
      <div className="flex flex-wrap items-baseline gap-x-2">
        <p className="text-[16px] font-medium text-fg">{term.term}</p>
        {term.occurrences > 1 && (
          <span className="text-[11px] text-muted2">{term.occurrences}問で言及</span>
        )}
      </div>
      <p className="mt-1 text-sm leading-6 text-fg/90">{term.definition}</p>

      {term.altDefinitions.length > 0 && (
        <div className="mt-1.5">
          <button
            type="button"
            onClick={() => setShowAlt((v) => !v)}
            className="text-[11px] font-medium tracking-wide text-primary2 hover:text-primary"
          >
            {showAlt ? "閉じる ▲" : `他の言い方（${term.altDefinitions.length}） ▾`}
          </button>
          {showAlt && (
            <ul className="mt-1.5 space-y-1">
              {term.altDefinitions.map((d) => (
                <li key={d} className="text-[13px] leading-6 text-muted">
                  {d}
                </li>
              ))}
            </ul>
          )}
        </div>
      )}

      {relatedList.length > 0 && (
        <div className="mt-2.5">
          <p className="mb-1.5 text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
            似ている概念（クリックで比較）
          </p>
          <div className="flex flex-wrap gap-1.5">
            {relatedList.map(([id]) => {
              const active = compareId === id;
              return (
                <button
                  key={id}
                  type="button"
                  onClick={() => setCompareId((v) => (v === id ? null : id))}
                  className={
                    "rounded-full border px-2.5 py-1 text-[11px] leading-none transition-colors " +
                    (active
                      ? "border-primary/60 text-primary2"
                      : "border-border text-muted hover:border-border2")
                  }
                >
                  {id}
                </button>
              );
            })}
          </div>
        </div>
      )}

      {compareTarget && (
        <div className="mt-3 rounded-md border border-border bg-card2 p-3">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <p className="text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
                {term.term}
              </p>
              <p className="mt-1 text-[13px] leading-6 text-fg/90">{term.definition}</p>
            </div>
            <div>
              <p className="text-[10px] font-semibold uppercase tracking-[.16em] text-muted2">
                {compareTarget.term}
              </p>
              <p className="mt-1 text-[13px] leading-6 text-fg/90">{compareTarget.definition}</p>
            </div>
          </div>
          {uniqueNotes.length > 0 && (
            <div className="mt-2 space-y-1.5 border-t border-border pt-2">
              {uniqueNotes.map((n) => (
                <p key={n.note} className="text-[12px] leading-6 text-muted">
                  {n.note}
                </p>
              ))}
            </div>
          )}
        </div>
      )}

      {term.examples.length > 0 && (
        <div className="mt-2">
          <button
            type="button"
            onClick={() => setShowExamples((v) => !v)}
            className="text-[11px] font-medium tracking-wide text-primary2 hover:text-primary"
          >
            {showExamples ? "閉じる ▲" : `出題例（${term.examples.length}） ▾`}
          </button>
          {showExamples && (
            <ul className="mt-1.5 space-y-1.5">
              {term.examples.map((e) => (
                <li key={e.id} className="text-[13px] leading-6 text-muted2">
                  {e.asked}
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  );
}

export function CheatsheetScreen({
  terms,
  comparisons,
}: {
  terms: TermEntry[];
  comparisons: ComparisonGroup[];
}) {
  const [query, setQuery] = useState("");
  const [activeCategories, setActiveCategories] = useState<Set<string>>(new Set());

  const termById = useMemo(() => new Map(terms.map((t) => [t.id, t])), [terms]);
  const relatedMap = useMemo(() => buildRelatedMap(comparisons), [comparisons]);

  const categories = useMemo(() => {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const t of terms) {
      const c = t.categories[0];
      if (!seen.has(c)) {
        seen.add(c);
        out.push(c);
      }
    }
    return out;
  }, [terms]);

  const indexed = useMemo(
    () =>
      terms.map((t) => ({
        term: t,
        text: [t.term, t.definition, ...t.altDefinitions, ...t.categories].join(" \n"),
      })),
    [terms]
  );

  const filtered = useMemo(() => {
    const q = query.trim();
    return indexed
      .filter(
        ({ term }) =>
          activeCategories.size === 0 || term.categories.some((c) => activeCategories.has(c))
      )
      .filter(({ text }) => q === "" || text.includes(q))
      .map(({ term }) => term);
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
        G検定 用語辞典
      </p>
      <h1 className="mt-1 text-xl font-light tracking-tight text-fg">
        全{terms.length}語の定義・比較
      </h1>

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
        {filtered.map((term) => (
          <TermRow
            key={term.id}
            term={term}
            related={relatedMap.get(term.id)}
            termById={termById}
          />
        ))}
        {filtered.length === 0 && (
          <p className="py-10 text-center text-sm text-muted2">該当する用語がありません</p>
        )}
      </div>
    </div>
  );
}
