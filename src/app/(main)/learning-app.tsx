"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import {
  FLAGS,
  FLAG_COLORS,
  type Progress,
  type QuizMode,
  type QuizQuestion,
} from "@/lib/quiz/types";
import {
  buildDeck,
  eligibleQuestions,
  getProgress,
  isResting,
  totalCorrect,
  totalWrong,
  type ProgressMap,
} from "@/lib/quiz/selection";
import { buildCSV, downloadCSV } from "@/lib/quiz/csv";

type Screen = "menu" | "quiz" | "done" | "analysis" | "export";
type SessionResult = { correct: boolean; category: string; color: string };

interface Props {
  userId: string;
  subjects: { slug: string; name: string }[];
  currentSubjectSlug: string;
  subjectName: string;
  categories: { id: string; name: string; color: string }[];
  questions: QuizQuestion[];
  initialProgress: ProgressMap;
}

export function LearningApp({
  userId,
  subjects,
  currentSubjectSlug,
  subjectName,
  categories,
  questions,
  initialProgress,
}: Props) {
  const router = useRouter();
  const [now, setNow] = useState(0);
  const [progressMap, setProgressMap] = useState<ProgressMap>(initialProgress);
  const [screen, setScreen] = useState<Screen>("menu");
  const [selCats, setSelCats] = useState<Set<string>>(
    () => new Set(categories.map((c) => c.id))
  );
  const [count, setCount] = useState(10);
  const [mode, setMode] = useState<QuizMode>("shuffle");
  const [deck, setDeck] = useState<QuizQuestion[]>([]);
  const [idx, setIdx] = useState(0);
  const [picked, setPicked] = useState<number | null>(null);
  const [sessionResults, setSessionResults] = useState<SessionResult[]>([]);
  const [memoText, setMemoText] = useState("");
  const [saving, setSaving] = useState(false);
  const [csvText, setCsvText] = useState("");
  const [onlyMemo, setOnlyMemo] = useState(true);
  const [copyMsg, setCopyMsg] = useState("");

  // Date.now() はハイドレーション不一致を避けるためマウント後に確定
  useEffect(() => {
    setNow(Date.now());
  }, []);

  const supabase = useMemo(() => createClient(), []);

  const persist = async (qid: string, partial: Partial<Progress>) => {
    const cur = getProgress(progressMap, qid);
    const next: Progress = { ...cur, ...partial };
    setProgressMap((m) => ({ ...m, [qid]: next }));
    setSaving(true);
    const { error } = await supabase.from("user_question_progress").upsert(
      {
        user_id: userId,
        question_id: qid,
        correct_count: next.correct_count,
        wrong_count: next.wrong_count,
        consecutive_correct: next.consecutive_correct,
        last_is_correct: next.last_is_correct,
        last_selected_index: next.last_selected_index,
        last_answered_at: next.last_answered_at,
        understanding_level: next.understanding_level,
        memo: next.memo,
      },
      { onConflict: "user_id,question_id" }
    );
    if (error) console.error("save failed", error);
    setSaving(false);
  };

  const restingCount = useMemo(
    () => questions.filter((q) => isResting(getProgress(progressMap, q.id), now)).length,
    [questions, progressMap, now]
  );

  const eligible = useMemo(
    () => eligibleQuestions(questions, progressMap, selCats, now),
    [questions, progressMap, selCats, now]
  );

  const startQuiz = () => {
    const pool = buildDeck({
      questions,
      progressMap,
      selectedCategoryIds: selCats,
      count,
      mode,
      now,
    });
    if (!pool.length) return;
    setDeck(pool);
    setIdx(0);
    setPicked(null);
    setSessionResults([]);
    setMemoText(getProgress(progressMap, pool[0].id).memo);
    setScreen("quiz");
  };

  const answer = (choiceIdx: number) => {
    if (picked !== null) return;
    setPicked(choiceIdx);
    const q = deck[idx];
    const correct = choiceIdx === q.correct_index;
    const cur = getProgress(progressMap, q.id);
    const partial: Partial<Progress> = correct
      ? {
          correct_count: cur.correct_count + 1,
          consecutive_correct: cur.consecutive_correct + 1,
          last_is_correct: true,
          last_selected_index: choiceIdx,
          last_answered_at: new Date().toISOString(),
        }
      : {
          wrong_count: cur.wrong_count + 1,
          consecutive_correct: 0,
          last_is_correct: false,
          last_selected_index: choiceIdx,
          last_answered_at: new Date().toISOString(),
        };
    setSessionResults((r) => [
      ...r,
      { correct, category: q.category_name, color: q.category_color },
    ]);
    persist(q.id, partial);
  };

  const setFlag = (level: number) => {
    const q = deck[idx];
    persist(q.id, { understanding_level: level });
  };

  const saveMemoAndNext = () => {
    const q = deck[idx];
    persist(q.id, { memo: memoText });
    if (idx + 1 >= deck.length) {
      setScreen("done");
    } else {
      const nq = deck[idx + 1];
      setIdx(idx + 1);
      setPicked(null);
      setMemoText(getProgress(progressMap, nq.id).memo);
    }
  };

  const switchSubject = (slug: string) => {
    router.push(slug ? `/?subject=${slug}` : "/");
  };

  // ============ LOADING ============
  if (now === 0) {
    return (
      <div className="flex justify-center pt-32 text-sm text-muted">読み込み中…</div>
    );
  }

  const page = "flex flex-col items-center px-3.5 pb-24 pt-5";
  const card = "w-full max-w-[560px] rounded-2xl bg-card p-5 shadow-2xl sm:p-6";

  // ============ MENU ============
  if (screen === "menu") {
    const answered = questions.filter((q) => {
      const p = getProgress(progressMap, q.id);
      return p.correct_count + p.wrong_count > 0;
    }).length;

    const countOptions = [5, 10, 20, eligible.length];

    return (
      <div className={page}>
        <div className={card}>
          <div className="mb-1 flex items-center justify-between">
            <h1 className="text-lg font-extrabold text-slate-100">{subjectName}</h1>
            {subjects.length > 1 && (
              <select
                value={currentSubjectSlug}
                onChange={(e) => switchSubject(e.target.value)}
                className="rounded-lg border border-border bg-card2 px-2 py-1 text-xs text-muted"
              >
                {subjects.map((s) => (
                  <option key={s.slug} value={s.slug}>
                    {s.name}
                  </option>
                ))}
              </select>
            )}
          </div>
          <p className="mb-4 text-center text-xs text-muted2">
            全{questions.length}問 ｜ 演習済み {answered}問 ｜ 休眠中 {restingCount}問
          </p>

          {/* 分野選択 */}
          <p className="mb-2 text-sm font-bold text-slate-300">分野（タップで選択/解除）</p>
          <div className="mb-3 flex flex-wrap gap-1.5">
            {categories.map((c) => {
              const on = selCats.has(c.id);
              const all = questions.filter((q) => q.category_id === c.id);
              const rest = all.filter((q) =>
                isResting(getProgress(progressMap, q.id), now)
              ).length;
              return (
                <button
                  key={c.id}
                  onClick={() => {
                    const s = new Set(selCats);
                    s.has(c.id) ? s.delete(c.id) : s.add(c.id);
                    setSelCats(s);
                  }}
                  className="rounded-2xl border-2 px-3 py-1.5 text-xs font-bold"
                  style={{
                    borderColor: on ? c.color : "#2a3648",
                    background: on ? c.color + "22" : "transparent",
                    color: on ? c.color : "#4b5563",
                  }}
                >
                  {c.name} {all.length - rest}
                  {rest > 0 ? `(+休${rest})` : ""}
                </button>
              );
            })}
          </div>
          <div className="mb-4 flex gap-2">
            <button
              onClick={() => setSelCats(new Set(categories.map((c) => c.id)))}
              className="rounded-lg bg-card2 px-3 py-1.5 text-xs font-bold text-muted"
            >
              全選択
            </button>
            <button
              onClick={() => setSelCats(new Set())}
              className="rounded-lg bg-card2 px-3 py-1.5 text-xs font-bold text-muted"
            >
              全解除
            </button>
          </div>

          {/* 問題数 */}
          <p className="mb-2 text-sm font-bold text-slate-300">問題数</p>
          <div className="mb-4 flex gap-2">
            {countOptions.map((n, i) => (
              <button
                key={i}
                onClick={() => setCount(n)}
                className="flex-1 rounded-xl py-2.5 text-sm font-bold"
                style={{
                  background: count === n ? "#2563eb" : "#1e2d3d",
                  color: count === n ? "#fff" : "#94a3b8",
                }}
              >
                {i === 3 ? `全部(${eligible.length})` : `${n}問`}
              </button>
            ))}
          </div>

          {/* 出題モード */}
          <p className="mb-2 text-sm font-bold text-slate-300">出題モード</p>
          <div className="mb-2 flex gap-2">
            <button
              onClick={() => setMode("shuffle")}
              className="flex-1 rounded-xl py-3 text-sm font-bold"
              style={{
                background: mode === "shuffle" ? "#2563eb" : "#1e2d3d",
                color: mode === "shuffle" ? "#fff" : "#94a3b8",
              }}
            >
              🔀 シャッフル
            </button>
            <button
              onClick={() => setMode("priority")}
              className="flex-1 rounded-xl py-3 text-sm font-bold"
              style={{
                background: mode === "priority" ? "#dc2626" : "#1e2d3d",
                color: mode === "priority" ? "#fff" : "#94a3b8",
              }}
            >
              🔥 弱点優先
            </button>
          </div>
          <p className="mb-4 text-[11px] text-muted2">
            {mode === "priority"
              ? "間違えた回数が多い問題から優先的に出題"
              : "選択した分野からランダムに出題"}
            ｜3回連続正解は2週間、正解かつ完璧は1週間出題されません
          </p>

          <button
            onClick={startQuiz}
            disabled={!eligible.length}
            className="mb-3 w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-4 text-base font-bold text-white disabled:from-slate-700 disabled:to-slate-700"
          >
            スタート（{Math.min(count, eligible.length)}問）
          </button>

          <div className="flex gap-2">
            <button
              onClick={() => setScreen("analysis")}
              className="flex-1 rounded-xl bg-card2 py-3 text-sm font-bold text-muted"
            >
              📊 苦手分析
            </button>
            <button
              onClick={() => {
                setCsvText(buildCSV(questions, progressMap, now, onlyMemo));
                setCopyMsg("");
                setScreen("export");
              }}
              className="flex-1 rounded-xl bg-card2 py-3 text-sm font-bold text-muted"
            >
              📋 書き出し
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ============ EXPORT ============
  if (screen === "export") {
    const memoCount = questions.filter((q) =>
      getProgress(progressMap, q.id).memo.trim()
    ).length;

    const rebuild = (only: boolean) => {
      setOnlyMemo(only);
      setCsvText(buildCSV(questions, progressMap, now, only));
      setCopyMsg("");
    };

    const doCopy = async () => {
      try {
        await navigator.clipboard.writeText(csvText);
        setCopyMsg("✓ コピーしました");
      } catch {
        setCopyMsg("⚠ コピー不可。下のテキストを手動で全選択してください");
      }
    };

    return (
      <div className={page}>
        <div className={card}>
          <h2 className="mb-1.5 text-lg font-extrabold text-slate-100">📋 書き出し（CSV）</h2>
          <p className="mb-4 text-xs text-muted2">
            メモあり {memoCount}問 ／ 全{questions.length}問。CSVをダウンロード、または下のボタンでコピーできます。
          </p>

          <div className="mb-3.5 flex gap-2">
            <button
              onClick={() => rebuild(true)}
              className="flex-1 rounded-xl py-2.5 text-sm font-bold"
              style={{ background: onlyMemo ? "#2563eb" : "#1e2d3d", color: onlyMemo ? "#fff" : "#94a3b8" }}
            >
              メモのある問題だけ
            </button>
            <button
              onClick={() => rebuild(false)}
              className="flex-1 rounded-xl py-2.5 text-sm font-bold"
              style={{ background: !onlyMemo ? "#2563eb" : "#1e2d3d", color: !onlyMemo ? "#fff" : "#94a3b8" }}
            >
              全問題
            </button>
          </div>

          <button
            onClick={() =>
              downloadCSV(`${currentSubjectSlug}-export-${onlyMemo ? "memo" : "all"}.csv`, csvText)
            }
            className="mb-2 w-full rounded-xl bg-gradient-to-br from-emerald-600 to-emerald-700 py-3.5 text-sm font-bold text-white"
          >
            ⬇ CSVをダウンロード
          </button>
          <button
            onClick={doCopy}
            className="mb-2 w-full rounded-xl bg-card2 py-2.5 text-sm font-bold text-muted"
          >
            📋 クリップボードにコピー
          </button>
          {copyMsg && (
            <p
              className="mb-3 text-center text-xs"
              style={{ color: copyMsg.startsWith("✓") ? "#86efac" : "#fbbf24" }}
            >
              {copyMsg}
            </p>
          )}

          <textarea
            readOnly
            value={csvText}
            onFocus={(e) => e.target.select()}
            className="mb-4 min-h-[200px] w-full resize-y overflow-x-auto whitespace-pre rounded-xl border border-border bg-card2 px-3 py-2.5 font-mono text-[11px] text-slate-300"
          />

          <button
            onClick={() => setScreen("menu")}
            className="w-full rounded-xl bg-card2 py-3 text-sm font-bold text-muted"
          >
            メニューに戻る
          </button>
        </div>
      </div>
    );
  }

  // ============ ANALYSIS ============
  if (screen === "analysis") {
    const catStats = categories
      .map((c) => {
        const qs = questions.filter((q) => q.category_id === c.id);
        let w = 0;
        let cc = 0;
        qs.forEach((q) => {
          const p = getProgress(progressMap, q.id);
          w += totalWrong(q, p);
          cc += totalCorrect(p);
        });
        const acc = w + cc > 0 ? Math.round((cc / (w + cc)) * 100) : null;
        return { ...c, w, cc, acc, n: qs.length };
      })
      .sort((a, b) => (a.acc ?? 0) - (b.acc ?? 0));

    const worst = [...questions]
      .sort((a, b) => {
        const pa = getProgress(progressMap, a.id);
        const pb = getProgress(progressMap, b.id);
        return (
          totalWrong(b, pb) - totalCorrect(pb) - (totalWrong(a, pa) - totalCorrect(pa))
        );
      })
      .slice(0, 8);

    const flagDist = [0, 0, 0, 0, 0];
    questions.forEach((q) => {
      flagDist[getProgress(progressMap, q.id).understanding_level]++;
    });

    return (
      <div className={page}>
        <div className={card}>
          <h2 className="mb-4 text-lg font-extrabold text-slate-100">📊 苦手傾向分析</h2>

          <p className="mb-2.5 text-sm font-bold text-slate-300">
            分野別 正答率（累計・模試の誤答含む）
          </p>
          {catStats.map((s) => (
            <div key={s.id} className="mb-2.5">
              <div className="mb-1 flex justify-between">
                <span className="text-xs font-bold" style={{ color: s.color }}>
                  {s.name}
                </span>
                <span className="text-xs text-muted">
                  {s.acc !== null ? `${s.acc}%` : "未演習"}（誤{s.w}/正{s.cc}）
                </span>
              </div>
              <div className="h-2 overflow-hidden rounded bg-card2">
                <div
                  className="h-full rounded"
                  style={{
                    width: `${s.acc ?? 0}%`,
                    background: (s.acc ?? 0) >= 70 ? "#16a34a" : (s.acc ?? 0) >= 40 ? "#f59e0b" : "#dc2626",
                  }}
                />
              </div>
            </div>
          ))}

          <p className="mb-2.5 mt-5 text-sm font-bold text-slate-300">
            🔥 最重点問題トップ8（誤答−正答が大きい順）
          </p>
          {worst.map((q) => {
            const p = getProgress(progressMap, q.id);
            return (
              <div
                key={q.id}
                className="mb-1.5 rounded-xl bg-card2 px-3 py-2.5"
                style={{ borderLeft: `3px solid ${q.category_color}` }}
              >
                <div className="mb-1 flex justify-between">
                  <span className="text-[10px] font-bold" style={{ color: q.category_color }}>
                    {q.category_name}
                  </span>
                  <span className="text-[10px] text-muted">
                    誤{totalWrong(q, p)} 正{totalCorrect(p)} ｜ {FLAGS[p.understanding_level]}
                  </span>
                </div>
                <div className="text-xs leading-relaxed text-slate-300">
                  {q.question_text.slice(0, 60)}…
                </div>
              </div>
            );
          })}

          <p className="mb-2.5 mt-5 text-sm font-bold text-slate-300">理解度フラグ分布</p>
          <div className="mb-5 flex gap-1.5">
            {FLAGS.map((f, i) => (
              <div key={i} className="flex-1 rounded-xl bg-card2 px-1 py-2.5 text-center">
                <div className="text-xl font-extrabold" style={{ color: FLAG_COLORS[i] }}>
                  {flagDist[i]}
                </div>
                <div className="text-[9px] text-muted2">{f}</div>
              </div>
            ))}
          </div>

          <button
            onClick={() => setScreen("menu")}
            className="w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-3 text-sm font-bold text-white"
          >
            メニューに戻る
          </button>
        </div>
      </div>
    );
  }

  // ============ DONE ============
  if (screen === "done") {
    const ok = sessionResults.filter((r) => r.correct).length;
    const pct = sessionResults.length
      ? Math.round((ok / sessionResults.length) * 100)
      : 0;
    const breakdown: Record<string, { ok: number; ng: number; color: string }> = {};
    sessionResults.forEach((r) => {
      if (!breakdown[r.category])
        breakdown[r.category] = { ok: 0, ng: 0, color: r.color };
      r.correct ? breakdown[r.category].ok++ : breakdown[r.category].ng++;
    });

    return (
      <div className={page}>
        <div className={`${card} text-center`}>
          <div className="mb-2 text-5xl">{pct >= 80 ? "🎉" : pct >= 60 ? "💪" : "📚"}</div>
          <h2 className="mb-1.5 text-2xl font-extrabold text-slate-100">
            {ok} / {sessionResults.length} 正解
          </h2>
          <p className="mb-5 text-muted">正答率 {pct}%</p>
          <div className="mb-6 text-left">
            {Object.entries(breakdown).map(([d, v]) => (
              <div
                key={d}
                className="flex justify-between border-b border-card2 py-1.5"
              >
                <span className="text-sm font-bold" style={{ color: v.color }}>
                  {d}
                </span>
                <span className="text-sm">
                  <span className="text-emerald-300">✓{v.ok}</span>{" "}
                  <span className="text-red-300">✗{v.ng}</span>
                </span>
              </div>
            ))}
          </div>
          <div className="flex gap-2.5">
            <button
              onClick={() => setScreen("analysis")}
              className="flex-1 rounded-xl bg-card2 py-3 text-sm font-bold text-muted"
            >
              📊 分析
            </button>
            <button
              onClick={() => setScreen("menu")}
              className="flex-1 rounded-xl bg-gradient-to-br from-primary to-primary2 py-3 text-sm font-bold text-white"
            >
              メニュー
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ============ QUIZ ============
  const q = deck[idx];
  const p = getProgress(progressMap, q.id);
  const correct = picked === q.correct_index;

  return (
    <div className={page}>
      <div className="mb-3 w-full max-w-[560px]">
        <div className="mb-1.5 flex justify-between">
          <span className="text-sm font-semibold text-muted">
            {idx + 1} / {deck.length}
          </span>
          <span className="text-[11px] text-muted2">{saving ? "保存中…" : "保存済み"}</span>
        </div>
        <div className="h-1 rounded bg-card2">
          <div
            className="h-full rounded bg-gradient-to-r from-primary to-sky-400"
            style={{ width: `${((idx + 1) / deck.length) * 100}%` }}
          />
        </div>
      </div>

      <div className={card}>
        <div className="mb-3.5 flex items-center justify-between">
          <span
            className="rounded-2xl px-3 py-1 text-[11px] font-bold"
            style={{
              background: q.category_color + "22",
              border: `1px solid ${q.category_color}55`,
              color: q.category_color,
            }}
          >
            {q.category_name}
          </span>
          <span className="text-[11px] text-muted2">
            誤答 {totalWrong(q, p)}回 / 連続正解 {p.consecutive_correct}
          </span>
        </div>

        <p className="mb-4 text-[15px] font-bold leading-8 text-slate-200">{q.question_text}</p>

        {q.options.map((choice, i) => {
          let bg = "#0f1825";
          let bd = "#2a3648";
          let fg = "#cbd5e1";
          if (picked !== null) {
            if (i === q.correct_index) {
              bg = "#14532d";
              bd = "#16a34a";
              fg = "#bbf7d0";
            } else if (i === picked) {
              bg = "#7f1d1d";
              bd = "#dc2626";
              fg = "#fecaca";
            } else {
              fg = "#64748b";
            }
          }
          return (
            <button
              key={i}
              onClick={() => answer(i)}
              disabled={picked !== null}
              className="mb-2 block w-full rounded-xl border-2 px-3.5 py-3 text-left"
              style={{ background: bg, borderColor: bd, cursor: picked === null ? "pointer" : "default" }}
            >
              <span className="text-[13px] leading-relaxed" style={{ color: fg }}>
                <b className="mr-2">{"ABCD"[i]}.</b>
                {choice}
              </span>
            </button>
          );
        })}

        {picked !== null && (
          <>
            <div
              className="my-3.5 rounded-xl px-4 py-3.5"
              style={{
                background: correct ? "#14532d33" : "#7f1d1d33",
                border: `1px solid ${correct ? "#16a34a" : "#dc2626"}44`,
              }}
            >
              <p
                className="mb-2 text-sm font-extrabold"
                style={{ color: correct ? "#86efac" : "#fca5a5" }}
              >
                {correct ? "✓ 正解！" : "✗ 不正解"}
              </p>
              <p className="text-[13px] leading-8 text-slate-300">{q.explanation}</p>
            </div>

            <p className="mb-1.5 text-xs font-bold text-slate-300">理解度フラグ</p>
            <div className="mb-3.5 flex gap-1.5">
              {FLAGS.slice(1).map((f, i) => {
                const fv = i + 1;
                const on = p.understanding_level === fv;
                return (
                  <button
                    key={fv}
                    onClick={() => setFlag(fv)}
                    className="flex-1 rounded-xl border-2 px-0.5 py-2 text-[10px] font-bold"
                    style={{
                      borderColor: on ? FLAG_COLORS[fv] : "#2a3648",
                      background: on ? FLAG_COLORS[fv] + "26" : "transparent",
                      color: on ? FLAG_COLORS[fv] : "#64748b",
                    }}
                  >
                    {f}
                  </button>
                );
              })}
            </div>

            <p className="mb-1.5 text-xs font-bold text-slate-300">メモ</p>
            <textarea
              value={memoText}
              onChange={(e) => setMemoText(e.target.value)}
              placeholder="気づき・覚え方・自分の言葉での説明を残す"
              className="mb-3.5 min-h-[70px] w-full resize-y rounded-xl border border-border bg-card2 px-3 py-2.5 text-[13px] text-slate-200 outline-none focus:border-primary2"
            />

            <button
              onClick={saveMemoAndNext}
              className="w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-3.5 text-sm font-bold text-white"
            >
              {idx + 1 >= deck.length ? "結果を見る" : "保存して次へ →"}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
