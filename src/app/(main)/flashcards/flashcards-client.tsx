"use client";

import { useMemo, useState, useCallback, useEffect } from "react";
import Link from "next/link";
import {
  FLASHCARD_DECKS,
  categoryColor,
  type FlashCard,
  type FlashDeck,
} from "@/lib/flashcards";

// 表示専用のシャッフル（Fisher-Yates）。Start 押下時にだけ回すので SSR とはずれない。
function shuffled<T>(arr: T[]): T[] {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

type Phase = "setup" | "session" | "done";

const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
const container = "w-full max-w-[440px]";
const lbl =
  "text-[10px] font-semibold uppercase tracking-[0.18em] text-[#555e70]";

export function FlashcardsClient() {
  // いまは G検定デッキのみ。将来 examGroupKey で複数デッキを切り替える。
  const [deck, setDeck] = useState<FlashDeck>(FLASHCARD_DECKS[0]);

  const [phase, setPhase] = useState<Phase>("setup");

  // ── setup 状態 ──
  const [selCat, setSelCat] = useState<string | null>(null); // null=全分野
  const [count, setCount] = useState<number>(20);

  // ── session 状態 ──
  const [queue, setQueue] = useState<FlashCard[]>([]);
  const [idx, setIdx] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [showPrecise, setShowPrecise] = useState(false);
  const [known, setKnown] = useState(0);
  const [weakCards, setWeakCards] = useState<FlashCard[]>([]);

  const cats = useMemo(() => {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const c of deck.cards) {
      if (!seen.has(c.cat)) {
        seen.add(c.cat);
        out.push(c.cat);
      }
    }
    return out;
  }, [deck]);

  const catCount = useCallback(
    (cat: string) => deck.cards.filter((c) => c.cat === cat).length,
    [deck]
  );

  const pool = useMemo(
    () => (selCat ? deck.cards.filter((c) => c.cat === selCat) : deck.cards),
    [deck, selCat]
  );

  const start = useCallback(
    (cards: FlashCard[], n: number) => {
      const take = n <= 0 ? cards.length : Math.min(n, cards.length);
      setQueue(shuffled(cards).slice(0, take));
      setIdx(0);
      setFlipped(false);
      setShowPrecise(false);
      setKnown(0);
      setWeakCards([]);
      setPhase("session");
    },
    []
  );

  const flip = useCallback(() => {
    setFlipped((f) => {
      if (!f) setShowPrecise(false);
      return true;
    });
  }, []);

  const grade = useCallback(
    (ok: boolean) => {
      const card = queue[idx];
      if (ok) setKnown((k) => k + 1);
      else setWeakCards((w) => [...w, card]);
      const next = idx + 1;
      if (next >= queue.length) {
        setPhase("done");
      } else {
        setIdx(next);
        setFlipped(false);
        setShowPrecise(false);
      }
    },
    [queue, idx]
  );

  // キーボード操作: Space=めくる, 1=あやしい, 2=覚えていた
  useEffect(() => {
    if (phase !== "session") return;
    const onKey = (e: KeyboardEvent) => {
      if (e.code === "Space") {
        e.preventDefault();
        if (!flipped) flip();
      } else if (flipped && e.key === "1") {
        grade(false);
      } else if (flipped && e.key === "2") {
        grade(true);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [phase, flipped, flip, grade]);

  // ───────────────────────── setup ─────────────────────────
  if (phase === "setup") {
    const total = pool.length;
    const startN = count <= 0 ? total : Math.min(count, total);
    return (
      <div className={wrap}>
        <div className={container}>
          {/* デッキ（試験区分）切替。デッキが1つのときは出さない。 */}
          {FLASHCARD_DECKS.length > 1 && (
            <div className="mb-6 flex flex-wrap gap-1.5">
              {FLASHCARD_DECKS.map((d) => {
                const on = d.key === deck.key;
                return (
                  <button
                    key={d.key}
                    onClick={() => {
                      setDeck(d);
                      setSelCat(null);
                    }}
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

          <div className="mb-8 flex items-start justify-between">
            <div>
              <h1 className="text-base font-semibold text-white">単語カード</h1>
              <p className="text-xs text-[#555e70]">
                {deck.name} · 全 {deck.cards.length} 語
              </p>
            </div>
            <Link
              href="/"
              className="mt-1 text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              ← 戻る
            </Link>
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
            onClick={() => start(pool, count)}
            disabled={total === 0}
            className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa] disabled:bg-[#141720] disabled:text-[#555e70]"
          >
            はじめる — {startN} 枚
          </button>
          <p className="mt-2.5 text-center text-xs text-[#555e70]">
            用語を見て意味を思い出す → タップで答え合わせ
          </p>
        </div>
      </div>
    );
  }

  // ───────────────────────── done ─────────────────────────
  if (phase === "done") {
    const weak = weakCards.length;
    const total = queue.length;
    return (
      <div className={wrap}>
        <div className={container}>
          <div className="pt-6 text-center">
            <p className={`mb-4 ${lbl}`}>今回のセッション</p>
            <div className="text-[52px] font-extralight leading-none tracking-[-0.03em] tabular-nums text-[#e8eaf0]">
              {known}
              <span className="font-thin text-[#555e70]"> / {total}</span>
            </div>
            <p className="mt-1.5 text-xs text-[#555e70]">語 覚えていた</p>

            <div className="my-8 flex justify-center gap-8">
              <div className="text-center">
                <div className="text-2xl font-light tabular-nums text-[#6ab08d]">
                  {known}
                </div>
                <div className="mt-1 text-[11px] text-[#555e70]">覚えていた</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-light tabular-nums text-[#d0a45c]">
                  {weak}
                </div>
                <div className="mt-1 text-[11px] text-[#555e70]">あやしい</div>
              </div>
            </div>

            {weak > 0 && (
              <button
                onClick={() => {
                  const again = weakCards;
                  setQueue(shuffled(again));
                  setIdx(0);
                  setFlipped(false);
                  setShowPrecise(false);
                  setKnown(0);
                  setWeakCards([]);
                  setPhase("session");
                }}
                className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
              >
                あやしい {weak} 語をもう一周
              </button>
            )}
            <button
              onClick={() => setPhase("setup")}
              className="mt-2.5 w-full rounded-xl border border-[#2a2f3f] py-4 text-sm font-medium text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#e8eaf0]"
            >
              メニューに戻る
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ───────────────────────── session ─────────────────────────
  const card = queue[idx];
  const accent = categoryColor(card.cat);
  const progress = queue.length > 0 ? (idx / queue.length) * 100 : 0;

  return (
    <div className={wrap}>
      <div className={container}>
        {/* 進捗 */}
        <div className="mb-1 h-0.5 overflow-hidden rounded bg-[#2a2f3f]">
          <div
            className="h-full bg-[#3b82f6] transition-[width] duration-300 motion-reduce:transition-none"
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className="mb-6 flex items-center justify-between text-[11px] text-[#555e70]">
          <span className="tabular-nums">
            {idx + 1} / {queue.length}
          </span>
          <span>{selCat ?? "全分野"}・シャッフル</span>
        </div>

        {/* カード（3Dフリップ） */}
        <div className="mb-6" style={{ perspective: "1600px" }}>
          <button
            onClick={() => !flipped && flip()}
            aria-label={flipped ? "答え" : "タップして意味を確認"}
            className="grid w-full text-left transition-transform duration-500 motion-reduce:transition-none"
            style={{
              transformStyle: "preserve-3d",
              transform: flipped ? "rotateY(180deg)" : "none",
              cursor: flipped ? "default" : "pointer",
            }}
          >
            {/* 2面をグリッドの同一セルに重ね、背の高い面がカード高を決める。
                こうすると「正確な定義」を開いてもカードが伸びて全文が読める。 */}
            {/* front */}
            <div
              className="flex min-h-[340px] flex-col rounded-[20px] border border-[#2a2f3f] bg-[#1a1d27] px-8 py-8"
              style={{ backfaceVisibility: "hidden", gridArea: "1 / 1" }}
            >
              <span
                className="text-[10px] font-semibold uppercase tracking-[0.16em]"
                style={{ color: accent }}
              >
                {card.cat}
              </span>
              <span
                className="my-auto font-extralight leading-tight tracking-[-0.02em] text-[#e8eaf0] text-wrap-balance"
                style={{
                  fontSize: card.term.length > 8 ? "29px" : "38px",
                  textWrap: "balance",
                }}
              >
                {card.term}
              </span>
              <span className="mt-auto text-center text-[11px] text-[#555e70]">
                タップして意味を確認
              </span>
            </div>

            {/* back — やさしく一言を先頭に */}
            <div
              className="flex min-h-[340px] flex-col rounded-[20px] border border-[#2a2f3f] bg-[#141720] px-8 py-8"
              style={{
                backfaceVisibility: "hidden",
                transform: "rotateY(180deg)",
                gridArea: "1 / 1",
              }}
            >
              <span className="text-[10px] font-semibold uppercase tracking-[0.16em] text-[#555e70]">
                {card.cat}
              </span>
              <span className="mb-5 mt-3.5 text-[15px] font-semibold text-[#e8eaf0]">
                {card.term}
              </span>
              <p className="text-[19px] font-normal leading-[1.7] tracking-[-0.01em] text-[#e8eaf0] text-wrap-balance" style={{ textWrap: "balance" }}>
                {card.gist}
              </p>
              {card.eg && (
                <div className="mt-[18px] border-l-2 pl-3" style={{ borderColor: "rgba(96,165,250,0.4)" }}>
                  <span className="mb-1.5 block text-[10px] font-semibold uppercase tracking-[0.14em] text-[#60a5fa]">
                    たとえると
                  </span>
                  <span className="text-[13.5px] leading-[1.7] text-[#8892a4]">
                    {card.eg}
                  </span>
                </div>
              )}
              {card.use && (
                <div className="mt-[18px]">
                  <span className="mb-1.5 block text-[10px] font-semibold uppercase tracking-[0.14em] text-[#7d8798]">
                    使いどころ
                  </span>
                  <span className="text-[13.5px] leading-[1.7] text-[#8892a4]">
                    {card.use}
                  </span>
                </div>
              )}

              <div className="mt-auto pt-4">
                <span
                  role="button"
                  tabIndex={0}
                  onClick={(e) => {
                    e.stopPropagation();
                    setShowPrecise((s) => !s);
                  }}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" || e.code === "Space") {
                      e.preventDefault();
                      e.stopPropagation();
                      setShowPrecise((s) => !s);
                    }
                  }}
                  className="inline-flex cursor-pointer items-center gap-1.5 text-[11px] text-[#555e70] transition hover:text-[#8892a4]"
                >
                  <svg
                    width="8"
                    height="8"
                    viewBox="0 0 10 10"
                    fill="none"
                    className="transition-transform"
                    style={{ transform: showPrecise ? "rotate(90deg)" : "none" }}
                  >
                    <path
                      d="M3.5 2L6.5 5L3.5 8"
                      stroke="currentColor"
                      strokeWidth="1.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                  正確な定義
                </span>
                {showPrecise && (
                  <p className="mt-2 text-[12.5px] leading-[1.75] text-[#555e70]">
                    {card.precise}
                  </p>
                )}
                <p className="mt-3 border-t border-[#2a2f3f] pt-3 text-[11px] text-[#555e70]">
                  {card.src}
                </p>
              </div>
            </div>
          </button>
        </div>

        {/* 自己採点 */}
        {flipped ? (
          <div className="flex gap-2.5">
            <button
              onClick={() => grade(false)}
              className="flex-1 rounded-xl border border-[#2a2f3f] py-3.5 text-sm text-[#8892a4] transition hover:border-[#d0a45c] hover:bg-[#d0a45c12] hover:text-[#d0a45c]"
            >
              あやしい
            </button>
            <button
              onClick={() => grade(true)}
              className="flex-1 rounded-xl border border-[#2a2f3f] py-3.5 text-sm text-[#8892a4] transition hover:border-[#6ab08d] hover:bg-[#6ab08d12] hover:text-[#6ab08d]"
            >
              覚えていた
            </button>
          </div>
        ) : (
          <p className="py-3.5 text-center text-xs text-[#555e70]">
            思い出せたか、自分に正直に
          </p>
        )}
      </div>
    </div>
  );
}

function FilterChip({
  label,
  color,
  count,
  active,
  onClick,
}: {
  label: string;
  color: string;
  count: number;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className="rounded-lg border px-2.5 py-1.5 text-[11px] font-medium transition"
      style={{
        borderColor: active ? color : "#2a2f3f",
        color: active ? color : "#8892a4",
        background: active ? color + "1a" : "transparent",
      }}
    >
      {label}
      <span className="ml-1.5 opacity-50 tabular-nums">{count}</span>
    </button>
  );
}
