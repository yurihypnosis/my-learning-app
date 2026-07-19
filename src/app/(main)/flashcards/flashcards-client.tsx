"use client";

import { useMemo, useState, useCallback, useEffect } from "react";
import Link from "next/link";
import {
  FLASHCARD_DECKS,
  categoryColor,
  type FlashCard,
  type FlashDeck,
} from "@/lib/flashcards";
import { createClient } from "@/lib/supabase/client";

// 表示専用のシャッフル（Fisher-Yates）。Start 押下時にだけ回すので SSR とはずれない。
function shuffled<T>(arr: T[]): T[] {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// ── 学習進捗の永続化（DB: user_term_progress）──
// 用語ごとに直近の自己採点だけ見て「定着 / あやしい / 未学習」に振り分ける。
// 本人の行のみ RLS で読み書き。PC/モバイルで同期する。
export type TermRow = {
  deck_key: string;
  term: string;
  result: string; // 'k'=定着 | 'w'=あやしい
  known_count: number;
  weak_count: number;
};
type TermStat = { r: "k" | "w"; k: number; w: number };
type DeckProgress = Record<string, TermStat>;
type Store = Record<string, DeckProgress>;
type Status = "mastered" | "weak" | "new";
type Scope = "all" | "weak" | "new";

const MASTERED = "#6ab08d"; // 定着（落ち着いた緑）
const WEAK = "#d0a45c"; // あやしい（琥珀）

type Phase = "setup" | "session" | "done";

const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
const container = "w-full max-w-[440px]";
const lbl =
  "text-[10px] font-semibold uppercase tracking-[0.18em] text-[#555e70]";

export function FlashcardsClient({
  userId,
  initialProgress,
}: {
  userId: string | null;
  initialProgress: TermRow[];
}) {
  const supabase = useMemo(() => createClient(), []);

  const [deck, setDeck] = useState<FlashDeck>(FLASHCARD_DECKS[0]);
  const [phase, setPhase] = useState<Phase>("setup");

  // ── setup 状態 ──
  const [selCat, setSelCat] = useState<string | null>(null); // null=全分野
  const [scope, setScope] = useState<Scope>("all");
  const [count, setCount] = useState<number>(20);

  // ── 永続進捗（DBから受け取った初期値で seed。SSRと一致する）──
  const [store, setStore] = useState<Store>(() => {
    const s: Store = {};
    for (const r of initialProgress) {
      (s[r.deck_key] ??= {})[r.term] = {
        r: r.result === "k" ? "k" : "w",
        k: r.known_count,
        w: r.weak_count,
      };
    }
    return s;
  });

  const record = useCallback(
    (deckKey: string, term: string, ok: boolean) => {
      const cur = store[deckKey]?.[term] ?? { r: "w" as const, k: 0, w: 0 };
      const next: TermStat = {
        r: ok ? "k" : "w",
        k: cur.k + (ok ? 1 : 0),
        w: cur.w + (ok ? 0 : 1),
      };
      // 楽観的にローカル state を先に更新（UIは即反映）。
      setStore((prev) => ({
        ...prev,
        [deckKey]: { ...(prev[deckKey] ?? {}), [term]: next },
      }));
      if (userId) {
        void supabase
          .from("user_term_progress")
          .upsert(
            {
              user_id: userId,
              deck_key: deckKey,
              term,
              result: next.r,
              known_count: next.k,
              weak_count: next.w,
            },
            { onConflict: "user_id,deck_key,term" }
          )
          .then(({ error }) => {
            if (error)
              console.error("[term_progress] save failed:", error.message);
          });
      }
    },
    [store, userId, supabase]
  );

  // ── session 状態 ──
  const [queue, setQueue] = useState<FlashCard[]>([]);
  const [idx, setIdx] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [showPrecise, setShowPrecise] = useState(false);
  const [known, setKnown] = useState(0);
  const [weakCards, setWeakCards] = useState<FlashCard[]>([]);
  const [masteredAtStart, setMasteredAtStart] = useState(0);

  const deckProg = store[deck.key] ?? {};
  const statusOf = useCallback(
    (term: string): Status => {
      const s = deckProg[term];
      return !s ? "new" : s.r === "k" ? "mastered" : "weak";
    },
    [deckProg]
  );

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

  // 現在の分野フィルタを反映したカード集合。範囲(scope)と進捗の数はこれを基準にする。
  const catCards = useMemo(
    () => (selCat ? deck.cards.filter((c) => c.cat === selCat) : deck.cards),
    [deck, selCat]
  );

  const counts = useMemo(() => {
    let mastered = 0,
      weak = 0,
      neu = 0;
    for (const c of catCards) {
      const st = statusOf(c.term);
      if (st === "mastered") mastered++;
      else if (st === "weak") weak++;
      else neu++;
    }
    return { mastered, weak, new: neu, total: catCards.length };
  }, [catCards, statusOf]);

  const pool = useMemo(() => {
    if (scope === "weak") return catCards.filter((c) => statusOf(c.term) === "weak");
    if (scope === "new") return catCards.filter((c) => statusOf(c.term) === "new");
    return catCards;
  }, [catCards, scope, statusOf]);

  const start = useCallback(
    (cards: FlashCard[], n: number, masteredNow: number) => {
      const take = n <= 0 ? cards.length : Math.min(n, cards.length);
      setQueue(shuffled(cards).slice(0, take));
      setIdx(0);
      setFlipped(false);
      setShowPrecise(false);
      setKnown(0);
      setWeakCards([]);
      setMasteredAtStart(masteredNow);
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
      record(deck.key, card.term, ok); // 進捗を永続化
      if (userId) {
        // 学習ログ用の履歴を1行残す（answer_events の単語版）。失敗はログのみ。
        void supabase
          .from("flashcard_events")
          .insert({
            user_id: userId,
            deck_key: deck.key,
            cat: card.cat,
            category_color: categoryColor(card.cat),
            result: ok ? "k" : "w",
          })
          .then(({ error }) => {
            if (error)
              console.error("[flashcard_events] insert failed:", error.message);
          });
      }
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
    [queue, idx, record, deck.key, userId, supabase]
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

  const scopeLabel = scope === "weak" ? "苦手" : scope === "new" ? "未学習" : "全部";

  // ───────────────────────── setup ─────────────────────────
  if (phase === "setup") {
    const startN = count <= 0 ? pool.length : Math.min(count, pool.length);
    const studied = counts.mastered + counts.weak;
    const pct = (v: number) => (counts.total ? (v / counts.total) * 100 : 0);
    return (
      <div className={wrap}>
        <div className={container}>
          {/* デッキ（試験区分）切替 */}
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
                      setScope("all");
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
            onClick={() => start(pool, count, counts.mastered)}
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

  // ───────────────────────── done ─────────────────────────
  if (phase === "done") {
    const weak = weakCards.length;
    const total = queue.length;
    const gained = Math.max(0, counts.mastered - masteredAtStart);
    return (
      <div className={wrap}>
        <div className={container}>
          <div className="pt-6 text-center">
            <p className={`mb-4 ${lbl}`}>学習の定着{selCat ? `（${selCat}）` : ""}</p>
            <div className="text-[52px] font-extralight leading-none tracking-[-0.03em] tabular-nums text-[#e8eaf0]">
              {counts.mastered}
              <span className="font-thin text-[#555e70]"> / {counts.total}</span>
            </div>
            <p className="mt-2 text-xs text-[#555e70]">
              語 定着
              {gained > 0 && (
                <span style={{ color: MASTERED }}> ・ 今回 +{gained}</span>
              )}
            </p>

            <div className="my-8 flex justify-center gap-8">
              <div className="text-center">
                <div className="text-2xl font-light tabular-nums" style={{ color: MASTERED }}>
                  {known}
                </div>
                <div className="mt-1 text-[11px] text-[#555e70]">覚えていた</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-light tabular-nums" style={{ color: WEAK }}>
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
                  setMasteredAtStart(counts.mastered);
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
          <span>
            {scopeLabel}・{selCat ?? "全分野"}
          </span>
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
                className="my-auto font-extralight leading-tight tracking-[-0.02em] text-[#e8eaf0]"
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
              <p
                className="text-[19px] font-normal leading-[1.7] tracking-[-0.01em] text-[#e8eaf0]"
                style={{ textWrap: "balance" }}
              >
                {card.gist}
              </p>
              {card.eg && (
                <div
                  className="mt-[18px] border-l-2 pl-3"
                  style={{ borderColor: "rgba(96,165,250,0.4)" }}
                >
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
