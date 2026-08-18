import {
  FLASHCARD_DECKS,
  categoryColor,
  type FlashCard,
  type FlashDeck,
} from "@/features/flashcards/lib/flashcards";
import { wrap, container, lbl, MASTERED, WEAK } from "@/features/flashcards/lib/constants";
import { FilterChip } from "@/features/flashcards/components/filter-chip";
import type { useDeckFilter } from "@/features/flashcards/hooks/use-deck-filter";

interface SetupScreenProps {
  filter: ReturnType<typeof useDeckFilter>;
  onStart: (cards: FlashCard[], count: number, masteredNow: number) => void;
}

export function SetupScreen({ filter, onStart }: SetupScreenProps) {
  const {
    deck,
    switchDeck,
    selCat,
    setSelCat,
    scope,
    setScope,
    count,
    setCount,
    cats,
    catCount,
    counts,
    pool,
    scopeLabel,
  } = filter;

  const startN = count <= 0 ? pool.length : Math.min(count, pool.length);
  const studied = counts.mastered + counts.weak;
  const pct = (v: number) => (counts.total ? (v / counts.total) * 100 : 0);

  return (
    <div className={wrap}>
      <div className={container}>
        {/* デッキ（試験区分）切替 */}
        {FLASHCARD_DECKS.length > 1 && (
          <div className="mb-6 flex flex-wrap gap-1.5">
            {FLASHCARD_DECKS.map((d: FlashDeck) => {
              const on = d.key === deck.key;
              return (
                <button
                  key={d.key}
                  onClick={() => switchDeck(d)}
                  className="rounded-full border px-3 py-1.5 text-xs transition"
                  style={{
                    borderColor: on ? "#3b82f6" : "#2a2f3f",
                    color: on ? "#60a5fa" : "#555e70",
                    background: on ? "#0d1f3c" : "transparent",
                  }}
                >
                  {d.name}
                </button>
              );
            })}
          </div>
        )}

        {/* 学習の定着（進捗の主役） */}
        <div className="mb-8">
          <p className={`mb-3 ${lbl}`}>
            学習の定着{selCat ? `（${selCat}）` : ""}
          </p>
          <div className="flex items-baseline justify-between">
            <div className="flex items-baseline gap-2">
              <span className="text-[40px] font-extralight leading-none tracking-[-0.03em] tabular-nums text-[#e8eaf0]">
                {counts.mastered}
              </span>
              <span className="text-sm text-[#555e70]">
                / {counts.total} 定着
              </span>
            </div>
            <div className="text-right text-[11px] tabular-nums">
              <span style={{ color: WEAK }}>あやしい {counts.weak}</span>
              <span className="text-[#3a4050]"> · </span>
              <span className="text-[#555e70]">未学習 {counts.new}</span>
            </div>
          </div>
          {/* 細い3分割バー */}
          <div className="mt-3 flex h-1 overflow-hidden rounded-full bg-[#161922]">
            <div
              style={{ width: `${pct(counts.mastered)}%`, background: MASTERED }}
              className="h-full transition-[width] duration-500 motion-reduce:transition-none"
            />
            <div
              style={{ width: `${pct(counts.weak)}%`, background: WEAK }}
              className="h-full transition-[width] duration-500 motion-reduce:transition-none"
            />
          </div>
          {studied === 0 && (
            <p className="mt-2 text-[11px] text-[#555e70]">
              カードをめくって「覚えていた / あやしい」で答えると、ここに定着が積み上がります
            </p>
          )}
        </div>

        {/* 出す範囲 */}
        <div className="mb-6">
          <p className={`mb-3 ${lbl}`}>出す範囲</p>
          <div className="flex overflow-hidden rounded-xl border border-[#2a2f3f]">
            {(
              [
                ["all", "全部", counts.total],
                ["weak", "苦手", counts.weak],
                ["new", "未学習", counts.new],
              ] as const
            ).map(([key, label, n], i) => {
              const on = scope === key;
              const disabled = n === 0 && key !== "all";
              const accent =
                key === "weak" ? WEAK : key === "new" ? "#8892a4" : "#60a5fa";
              return (
                <button
                  key={key}
                  onClick={() => !disabled && setScope(key)}
                  disabled={disabled}
                  className="flex-1 py-2.5 text-sm transition disabled:opacity-40"
                  style={{
                    borderRight: i < 2 ? "1px solid #2a2f3f" : "none",
                    background: on ? "#0d1f3c" : "transparent",
                    color: on ? accent : "#8892a4",
                  }}
                >
                  {label}
                  <span className="ml-1 text-[11px] opacity-60 tabular-nums">
                    {n}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* 分野 */}
        <div className="mb-6">
          <p className={`mb-3 ${lbl}`}>分野</p>
          <div className="flex flex-wrap gap-1.5">
            <FilterChip
              label="すべて"
              color="#8892a4"
              count={deck.cards.length}
              active={selCat === null}
              onClick={() => setSelCat(null)}
            />
            {cats.map((cat) => (
              <FilterChip
                key={cat}
                label={cat}
                color={categoryColor(cat)}
                count={catCount(cat)}
                active={selCat === cat}
                onClick={() => setSelCat(cat)}
              />
            ))}
          </div>
        </div>

        {/* 枚数 */}
        <div className="mb-8">
          <p className={`mb-3 ${lbl}`}>枚数</p>
          <div className="flex overflow-hidden rounded-xl border border-[#2a2f3f]">
            {[10, 20, 40, 0].map((n, i) => {
              const on = count === n;
              return (
                <button
                  key={n}
                  onClick={() => setCount(n)}
                  className="flex-1 py-2.5 text-sm transition"
                  style={{
                    borderRight: i < 3 ? "1px solid #2a2f3f" : "none",
                    background: on ? "#0d1f3c" : "transparent",
                    color: on ? "#60a5fa" : "#8892a4",
                  }}
                >
                  {n === 0 ? "全部" : n}
                </button>
              );
            })}
          </div>
        </div>

        <button
          onClick={() => onStart(pool, count, counts.mastered)}
          disabled={pool.length === 0}
          className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa] disabled:bg-[#141720] disabled:text-[#555e70]"
        >
          {pool.length === 0
            ? scope === "weak"
              ? "苦手な語はありません"
              : "出せる語がありません"
            : `はじめる — ${scopeLabel} ${startN} 枚`}
        </button>
        <p className="mt-2.5 text-center text-xs text-[#555e70]">
          用語を見て意味を思い出す → タップで答え合わせ
        </p>
      </div>
    </div>
  );
}
