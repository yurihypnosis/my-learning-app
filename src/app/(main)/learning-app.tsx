"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import {
  type ExplanationData,
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
import {
  type UserGoal,
  loadGoal,
  saveGoal,
  calcMasteryStats,
  calcDailyRec,
  calcCategoryMastery,
} from "@/lib/quiz/stats";

type Screen = "menu" | "quiz" | "done" | "analysis" | "export" | "goal";
type SessionResult = { correct: boolean; category: string; color: string };

const CONFIDENCE_LABELS = ["確信あり", "迷った", "勘"] as const;
const CONFIDENCE_COLORS = ["#16a34a", "#f59e0b", "#dc2626"] as const;

function arraysEqual(a: number[], b: number[]): boolean {
  return a.length === b.length && a.every((v, i) => v === b[i]);
}

function RichExplanation({ data }: { data: ExplanationData }) {
  return (
    <div className="text-[13px] leading-7 text-slate-300">
      <p className="mb-1.5 font-bold text-slate-200">▶ 何を問われているか</p>
      <p className="mb-3">{data.asked}</p>

      {data.terms && data.terms.length > 0 && (
        <>
          <p className="mb-1.5 font-bold text-slate-200">▶ キーワード</p>
          <div className="mb-3 flex flex-col gap-1.5">
            {data.terms.map(([term, def], i) => (
              <div key={i} className="rounded-lg bg-black/20 px-3 py-2">
                <span className="font-bold text-sky-300">{term}</span>
                <span className="ml-2 text-slate-400">{def}</span>
              </div>
            ))}
          </div>
        </>
      )}

      <p className="mb-1.5 font-bold text-slate-200">▶ 考え方</p>
      <p className="mb-3">{data.think}</p>

      {data.vs && (
        <>
          <p className="mb-1.5 font-bold text-slate-200">▶ 混同ポイント</p>
          <p className="mb-3">{data.vs}</p>
        </>
      )}

      {data.opt && data.opt.length > 0 && (
        <>
          <p className="mb-1.5 font-bold text-slate-200">▶ 選択肢の解説</p>
          <div className="flex flex-col gap-1">
            {data.opt.map((o, i) => (
              <div key={i} className="flex gap-2">
                <span className="shrink-0 font-bold text-slate-400">{"ABCD"[i]}.</span>
                <span>{o}</span>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

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
  const [recallMode, setRecallMode] = useState(false);
  const [deck, setDeck] = useState<QuizQuestion[]>([]);
  const [idx, setIdx] = useState(0);

  // 単一回答: picked = 選んだ選択肢インデックス
  const [picked, setPicked] = useState<number | null>(null);
  // 複数回答: 選択中のインデックス集合
  const [multiSelected, setMultiSelected] = useState<Set<number>>(new Set());
  // 回答済みフラグ（single / multi 共通）
  const [answered, setAnswered] = useState(false);
  // 確信度: 1=確信あり, 2=迷った, 3=勘
  const [confidence, setConfidence] = useState<number | null>(null);
  // 想起モードで選択肢をまだ表示していない
  const [choicesHidden, setChoicesHidden] = useState(false);

  const [sessionResults, setSessionResults] = useState<SessionResult[]>([]);
  const [memoText, setMemoText] = useState("");
  const [csvText, setCsvText] = useState("");
  const [onlyMemo, setOnlyMemo] = useState(true);
  const [copyMsg, setCopyMsg] = useState("");

  // 目標設定
  const [goal, setGoal] = useState<UserGoal | null>(null);
  const [goalDraft, setGoalDraft] = useState<{ examDate: string; targetName: string }>({
    examDate: "",
    targetName: "",
  });
  // セッション開始時の合格確率（セッション後の変化量計算用）
  const [sessionStartPassProb, setSessionStartPassProb] = useState<number | null>(null);

  useEffect(() => {
    const ts = Date.now();
    setNow(ts);
    const g = loadGoal(currentSubjectSlug);
    setGoal(g);
    if (g) setGoalDraft({ examDate: g.examDate, targetName: g.targetName });
  }, [currentSubjectSlug]);

  // 解説表示中にメモを編集したら自動保存（800ms debounce）
  useEffect(() => {
    if (!answered || !deck[idx]) return;
    const qid = deck[idx].id;
    const timer = setTimeout(() => {
      persist(qid, { memo: memoText });
    }, 800);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [memoText]);

  const supabase = useMemo(() => createClient(), []);

  const recordAnswer = (q: QuizQuestion, isCorrect: boolean, conf: number | null) => {
    supabase.from("answer_events").insert({
      user_id: userId,
      question_id: q.id,
      category_id: q.category_id,
      category_name: q.category_name,
      category_color: q.category_color,
      subject_slug: currentSubjectSlug,
      is_correct: isCorrect,
      confidence: conf,
    }).then(() => {});
  };

  const persist = async (qid: string, partial: Partial<Progress>) => {
    const cur = getProgress(progressMap, qid);
    const next: Progress = { ...cur, ...partial };
    setProgressMap((m) => ({ ...m, [qid]: next }));
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
        last_confidence: next.last_confidence,
      },
      { onConflict: "user_id,question_id" }
    );
    if (error) console.error("save failed", error);
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
    const pool = buildDeck({ questions, progressMap, selectedCategoryIds: selCats, count, mode, now });
    if (!pool.length) return;
    // セッション開始前の合格確率を記録（完了後のデルタ表示用）
    setSessionStartPassProb(calcMasteryStats(questions, progressMap).passProb);
    setDeck(pool);
    setIdx(0);
    setPicked(null);
    setMultiSelected(new Set());
    setAnswered(false);
    setConfidence(null);
    setChoicesHidden(recallMode);
    setSessionResults([]);
    setMemoText(getProgress(progressMap, pool[0].id).memo);
    setScreen("quiz");
  };

  // 単一回答
  const answerSingle = (choiceIdx: number) => {
    if (answered || confidence === null) return;
    const q = deck[idx];
    const isCorrect = choiceIdx === q.correct_index;
    // まぐれ当たり：勘で正解 → consecutive_correct リセット
    const magure = isCorrect && confidence === 3;
    setPicked(choiceIdx);
    setAnswered(true);
    const cur = getProgress(progressMap, q.id);
    const partial: Partial<Progress> = isCorrect
      ? {
          correct_count: cur.correct_count + 1,
          consecutive_correct: magure ? 0 : cur.consecutive_correct + 1,
          last_is_correct: true,
          last_selected_index: choiceIdx,
          last_answered_at: new Date().toISOString(),
          last_confidence: confidence,
        }
      : {
          wrong_count: cur.wrong_count + 1,
          consecutive_correct: 0,
          last_is_correct: false,
          last_selected_index: choiceIdx,
          last_answered_at: new Date().toISOString(),
          last_confidence: confidence,
        };
    setSessionResults((r) => [
      ...r,
      { correct: isCorrect, category: q.category_name, color: q.category_color },
    ]);
    persist(q.id, partial);
    recordAnswer(q, isCorrect, confidence);
  };

  // 複数回答の選択切り替え
  const toggleMulti = (i: number) => {
    if (answered) return;
    setMultiSelected((prev) => {
      const s = new Set(prev);
      s.has(i) ? s.delete(i) : s.add(i);
      return s;
    });
  };

  // 複数回答の確定
  const submitMulti = () => {
    if (answered || multiSelected.size === 0 || confidence === null) return;
    const q = deck[idx];
    const selected = Array.from(multiSelected).sort((a, b) => a - b);
    const expected = [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b);
    const isCorrect = arraysEqual(selected, expected);
    const magure = isCorrect && confidence === 3;
    setAnswered(true);
    const cur = getProgress(progressMap, q.id);
    const partial: Partial<Progress> = isCorrect
      ? {
          correct_count: cur.correct_count + 1,
          consecutive_correct: magure ? 0 : cur.consecutive_correct + 1,
          last_is_correct: true,
          last_answered_at: new Date().toISOString(),
          last_confidence: confidence,
        }
      : {
          wrong_count: cur.wrong_count + 1,
          consecutive_correct: 0,
          last_is_correct: false,
          last_answered_at: new Date().toISOString(),
          last_confidence: confidence,
        };
    setSessionResults((r) => [
      ...r,
      { correct: isCorrect, category: q.category_name, color: q.category_color },
    ]);
    persist(q.id, partial);
    recordAnswer(q, isCorrect, confidence);
  };

  const handleConfidence = (level: number) => {
    setConfidence(level);
  };

  const saveMemoAndNext = () => {
    const q = deck[idx];
    persist(q.id, { memo: memoText });
    window.scrollTo({ top: 0, behavior: "smooth" });
    if (idx + 1 >= deck.length) {
      setScreen("done");
    } else {
      const ni = idx + 1;
      const nq = deck[ni];
      setIdx(ni);
      setPicked(null);
      setMultiSelected(new Set());
      setAnswered(false);
      setConfidence(null);
      setChoicesHidden(recallMode);
      setMemoText(getProgress(progressMap, nq.id).memo);
    }
  };

  const switchSubject = (slug: string) => {
    router.push(slug ? `/?subject=${slug}` : "/");
  };

  if (now === 0) {
    return <div className="flex justify-center pt-32 text-sm text-muted">読み込み中…</div>;
  }

  const page = "flex flex-col items-center px-3.5 pb-24 pt-5";
  const card = "w-full max-w-[560px] rounded-2xl bg-card p-5 shadow-2xl sm:p-6";

  // ============ GOAL SCREEN ============
  if (screen === "goal") {
    const handleSaveGoal = () => {
      if (!goalDraft.examDate) return;
      const g: UserGoal = { examDate: goalDraft.examDate, targetName: goalDraft.targetName };
      saveGoal(currentSubjectSlug, g);
      setGoal(g);
      setScreen("menu");
    };
    const handleClearGoal = () => {
      saveGoal(currentSubjectSlug, null);
      setGoal(null);
      setGoalDraft({ examDate: "", targetName: "" });
      setScreen("menu");
    };

    return (
      <div className={page}>
        <div className={card}>
          <h2 className="mb-4 text-lg font-extrabold text-slate-100">🎯 目標設定</h2>

          <p className="mb-1.5 text-sm font-bold text-slate-300">試験日</p>
          <input
            type="date"
            value={goalDraft.examDate}
            onChange={(e) => setGoalDraft((d) => ({ ...d, examDate: e.target.value }))}
            className="mb-4 w-full rounded-xl border border-border bg-card2 px-4 py-3 text-sm text-slate-200 outline-none focus:border-primary2"
          />

          <p className="mb-1.5 text-sm font-bold text-slate-300">試験名・目標メモ（任意）</p>
          <input
            type="text"
            value={goalDraft.targetName}
            onChange={(e) => setGoalDraft((d) => ({ ...d, targetName: e.target.value }))}
            placeholder={`例: ${subjectName} 合格`}
            className="mb-5 w-full rounded-xl border border-border bg-card2 px-4 py-3 text-sm text-slate-200 outline-none focus:border-primary2"
          />

          <button
            onClick={handleSaveGoal}
            disabled={!goalDraft.examDate}
            className="mb-2 w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-3.5 text-sm font-bold text-white disabled:from-slate-700 disabled:to-slate-700"
          >
            保存する
          </button>
          {goal && (
            <button
              onClick={handleClearGoal}
              className="mb-2 w-full rounded-xl bg-red-900/40 py-2.5 text-sm font-bold text-red-300"
            >
              目標を削除する
            </button>
          )}
          <button
            onClick={() => setScreen("menu")}
            className="w-full rounded-xl bg-card2 py-2.5 text-sm font-bold text-muted"
          >
            キャンセル
          </button>
        </div>
      </div>
    );
  }

  // ============ MENU ============
  if (screen === "menu") {
    const answeredCount = questions.filter((q) => {
      const p = getProgress(progressMap, q.id);
      return p.correct_count + p.wrong_count > 0;
    }).length;
    // 目標逆算
    const stats = calcMasteryStats(questions, progressMap);
    const dailyRec = calcDailyRec(questions, progressMap, now, goal?.examDate ?? null);

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
          <p className="mb-3 text-center text-xs text-muted2">
            全{questions.length}問 ｜ 演習済み {answeredCount}問 ｜ 休眠中 {restingCount}問
          </p>

          {/* 🎯 目標・合格確率カード */}
          {goal ? (
            <div className="mb-4 rounded-xl bg-card2 px-4 py-3.5">
              <div className="mb-2.5 flex items-start justify-between">
                <div>
                  <p className="text-[11px] font-bold text-sky-400">
                    🎯 {goal.targetName || subjectName}
                  </p>
                  <p className="mt-0.5 text-xs text-muted">
                    残り{dailyRec.daysRemaining}日（
                    {new Date(goal.examDate).toLocaleDateString("ja-JP", {
                      month: "short",
                      day: "numeric",
                    })}
                    ）
                  </p>
                </div>
                <button
                  onClick={() => setScreen("goal")}
                  className="rounded-lg bg-black/20 px-2.5 py-1 text-[10px] font-bold text-muted2"
                >
                  変更
                </button>
              </div>
              {/* 合格確率バー */}
              <div className="mb-1.5 flex items-center justify-between">
                <span className="text-[11px] font-bold text-slate-400">予測合格確率</span>
                <span
                  className="text-lg font-extrabold"
                  style={{
                    color:
                      stats.passProb >= 70
                        ? "#86efac"
                        : stats.passProb >= 50
                          ? "#fcd34d"
                          : "#f87171",
                  }}
                >
                  {stats.passProb}%
                </span>
              </div>
              <div className="mb-2.5 h-2.5 overflow-hidden rounded-full bg-black/30">
                <div
                  className="h-full rounded-full transition-all"
                  style={{
                    width: `${stats.passProb}%`,
                    background:
                      stats.passProb >= 70
                        ? "linear-gradient(to right, #16a34a, #86efac)"
                        : stats.passProb >= 50
                          ? "linear-gradient(to right, #d97706, #fcd34d)"
                          : "linear-gradient(to right, #dc2626, #f87171)",
                  }}
                />
              </div>
              {/* 今日のタスク推薦 */}
              <div className="rounded-lg bg-black/20 px-3 py-2">
                <p className="mb-1 text-[10px] font-bold text-slate-400">今日のおすすめ</p>
                <p className="text-[12px] text-slate-200">
                  {dailyRec.newCount > 0 && (
                    <span>📗 新規 <b>{dailyRec.newCount}</b>問</span>
                  )}
                  {dailyRec.newCount > 0 && dailyRec.reviewCount > 0 && (
                    <span className="mx-1.5 text-muted2">+</span>
                  )}
                  {dailyRec.reviewCount > 0 && (
                    <span>🔄 復習 <b>{dailyRec.reviewCount}</b>問</span>
                  )}
                  {dailyRec.newCount === 0 && dailyRec.reviewCount === 0 && (
                    <span className="text-emerald-400">✓ 今日のタスクは完了！</span>
                  )}
                </p>
                <p className="mt-0.5 text-[10px] text-muted2">
                  未習得{dailyRec.totalNew}問 ÷ 残り{dailyRec.daysRemaining}日 ＝ 1日{dailyRec.dailyNorm}問ペース
                </p>
              </div>
            </div>
          ) : (
            <button
              onClick={() => setScreen("goal")}
              className="mb-4 flex w-full items-center gap-3 rounded-xl border border-dashed border-slate-600 px-4 py-3.5 text-left"
            >
              <span className="text-2xl">🎯</span>
              <div>
                <p className="text-sm font-bold text-slate-300">目標日を設定する</p>
                <p className="text-[11px] text-muted2">試験日から今日のノルマと合格確率を逆算</p>
              </div>
            </button>
          )}

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

          {/* ★ スタート（主動線） */}
          <button
            onClick={startQuiz}
            disabled={!eligible.length}
            className="mb-5 w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-4 text-base font-bold text-white disabled:from-slate-700 disabled:to-slate-700"
          >
            スタート（{Math.min(count, eligible.length)}問）
          </button>

          {/* 詳細設定（折りたたみ感覚で下に） */}
          <details className="mb-4 group" open={mode === "priority" || recallMode}>
            <summary className="mb-3 cursor-pointer list-none text-[11px] font-bold text-slate-500 group-open:text-slate-400">
              ▸ 詳細設定（モード・想起）
            </summary>

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
              ｜3回連続正解は2週間出題されません
            </p>

            {/* 想起モード */}
            <div className="flex items-center justify-between rounded-xl bg-card2 px-4 py-3">
              <div>
                <p className="text-sm font-bold text-slate-300">🧠 想起モード</p>
                <p className="text-[11px] text-muted2">選択肢を隠して先に考える（検索練習効果）</p>
              </div>
              <button
                onClick={() => setRecallMode((v) => !v)}
                className="relative inline-flex h-6 w-11 items-center rounded-full transition-colors"
                style={{ background: recallMode ? "#2563eb" : "#2a3648" }}
              >
                <span
                  className="inline-block h-4 w-4 rounded-full bg-white shadow transition-transform"
                  style={{ transform: recallMode ? "translateX(22px)" : "translateX(2px)" }}
                />
              </button>
            </div>
          </details>

          <div className="mb-2 flex gap-2">
            <button
              onClick={() => router.push("/roadmap")}
              className="flex-1 rounded-xl bg-card2 py-3 text-sm font-bold text-slate-300"
            >
              🗺 ロードマップ
            </button>
            <button
              onClick={() => router.push("/log")}
              className="flex-1 rounded-xl bg-card2 py-3 text-sm font-bold text-slate-300"
            >
              📅 学習ログ
            </button>
          </div>
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
        let practiced = false;
        qs.forEach((q) => {
          const p = getProgress(progressMap, q.id);
          w += totalWrong(q, p);
          cc += totalCorrect(p);
          if (p.correct_count + p.wrong_count > 0) practiced = true;
        });
        const acc = practiced ? Math.round((cc / (w + cc)) * 100) : null;
        return { ...c, w, cc, acc, n: qs.length };
      })
      .sort((a, b) => (a.acc ?? 101) - (b.acc ?? 101));

    const worst = [...questions]
      .sort((a, b) => {
        const pa = getProgress(progressMap, a.id);
        const pb = getProgress(progressMap, b.id);
        return (
          totalWrong(b, pb) - totalCorrect(pb) - (totalWrong(a, pa) - totalCorrect(pa))
        );
      })
      .slice(0, 8);

    // 合格確率 + スキルツリー
    const masteryStats = calcMasteryStats(questions, progressMap);
    const catMastery = calcCategoryMastery(categories, questions, progressMap);

    return (
      <div className={page}>
        <div className={card}>
          <h2 className="mb-4 text-lg font-extrabold text-slate-100">📊 苦手傾向分析</h2>

          {/* 予測合格確率カード */}
          <div className="mb-5 rounded-xl bg-card2 px-4 py-4">
            <div className="mb-3 flex items-center justify-between">
              <p className="text-sm font-bold text-slate-300">🎯 予測合格確率</p>
              <span
                className="text-2xl font-extrabold"
                style={{
                  color:
                    masteryStats.passProb >= 70
                      ? "#86efac"
                      : masteryStats.passProb >= 50
                        ? "#fcd34d"
                        : "#f87171",
                }}
              >
                {masteryStats.passProb}%
              </span>
            </div>
            <div className="mb-3 h-3 overflow-hidden rounded-full bg-black/30">
              <div
                className="h-full rounded-full transition-all"
                style={{
                  width: `${masteryStats.passProb}%`,
                  background:
                    masteryStats.passProb >= 70
                      ? "linear-gradient(to right, #16a34a, #86efac)"
                      : masteryStats.passProb >= 50
                        ? "linear-gradient(to right, #d97706, #fcd34d)"
                        : "linear-gradient(to right, #dc2626, #f87171)",
                }}
              />
            </div>
            <div className="flex justify-between text-[11px] text-muted2">
              <span>演習済み {masteryStats.attempted}/{questions.length}問</span>
              <span>習得済み {masteryStats.masteredCount}問</span>
              <span>弱点 {masteryStats.weakCount}問</span>
            </div>
          </div>

          {/* スキルツリー：分野別習得マップ + 正答率 */}
          <p className="mb-2.5 text-sm font-bold text-slate-300">🗺 分野別スキルツリー</p>
          <div className="mb-5 flex flex-col gap-2">
            {catMastery.map((cm) => {
              const pct = Math.round(cm.mastery * 100);
              const stat = catStats.find((s) => s.id === cm.id);
              return (
                <div key={cm.id} className="rounded-xl bg-card2 p-3">
                  <div className="mb-1.5 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div
                        className="h-2.5 w-2.5 rounded-full"
                        style={{ background: cm.color }}
                      />
                      <span className="text-[12px] font-bold text-slate-300">{cm.name}</span>
                    </div>
                    <div className="flex items-center gap-2.5">
                      {stat?.acc !== null && stat?.acc !== undefined && (
                        <span className="text-[10px] text-muted2">
                          正答{stat.acc}%（誤{stat.w}/正{stat.cc}）
                        </span>
                      )}
                      <span className="text-[10px] text-muted2">
                        {cm.masteredCount}/{cm.total}習得
                      </span>
                      <span
                        className="min-w-[36px] text-right text-[12px] font-extrabold"
                        style={{
                          color: pct >= 70 ? "#86efac" : pct >= 40 ? "#fcd34d" : pct === 0 ? "#475569" : "#f87171",
                        }}
                      >
                        {pct === 0 ? "未着" : `${pct}%`}
                      </span>
                    </div>
                  </div>
                  <div className="h-1.5 overflow-hidden rounded-full bg-black/30">
                    <div
                      className="h-full rounded-full"
                      style={{
                        width: `${pct}%`,
                        background: cm.color,
                        opacity: pct === 0 ? 0.2 : 1,
                      }}
                    />
                  </div>
                </div>
              );
            })}
          </div>

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
                    誤{totalWrong(q, p)} 正{totalCorrect(p)} ｜{" "}
                    {p.last_confidence === 1
                      ? "確信あり"
                      : p.last_confidence === 2
                        ? "迷った"
                        : p.last_confidence === 3
                          ? "勘"
                          : "未回答"}
                  </span>
                </div>
                <div className="text-xs leading-relaxed text-slate-300">
                  {q.question_text.slice(0, 60)}…
                </div>
              </div>
            );
          })}

          <p className="mb-2.5 mt-5 text-sm font-bold text-slate-300">確信度の分布（演習済み問題）</p>
          <div className="mb-5 flex gap-1.5">
            {CONFIDENCE_LABELS.map((label, i) => {
              const level = i + 1;
              const count = questions.filter(
                (qq) => getProgress(progressMap, qq.id).last_confidence === level
              ).length;
              return (
                <div key={i} className="flex-1 rounded-xl bg-card2 px-1 py-2.5 text-center">
                  <div className="text-xl font-extrabold" style={{ color: CONFIDENCE_COLORS[i] }}>
                    {count}
                  </div>
                  <div className="text-[9px] text-muted2">{label}</div>
                </div>
              );
            })}
            <div className="flex-1 rounded-xl bg-card2 px-1 py-2.5 text-center">
              <div className="text-xl font-extrabold text-slate-600">
                {questions.filter((qq) => getProgress(progressMap, qq.id).last_confidence === null).length}
              </div>
              <div className="text-[9px] text-muted2">未回答</div>
            </div>
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
    const currentPassProb = calcMasteryStats(questions, progressMap).passProb;
    const probDelta =
      sessionStartPassProb !== null ? currentPassProb - sessionStartPassProb : null;

    return (
      <div className={page}>
        <div className={`${card} text-center`}>
          <div className="mb-2 text-5xl">{pct >= 80 ? "🎉" : pct >= 60 ? "💪" : "📚"}</div>
          <h2 className="mb-1.5 text-2xl font-extrabold text-slate-100">
            {ok} / {sessionResults.length} 正解
          </h2>
          <p className="mb-4 text-muted">正答率 {pct}%</p>

          {/* 合格確率の変化 */}
          {probDelta !== null && (
            <div
              className="mx-auto mb-5 max-w-xs rounded-xl px-5 py-3"
              style={{
                background: probDelta > 0 ? "#14532d33" : probDelta < 0 ? "#7f1d1d33" : "#1e2d3d",
                border: `1px solid ${probDelta > 0 ? "#16a34a44" : probDelta < 0 ? "#dc262644" : "#2a3648"}`,
              }}
            >
              <p className="mb-1 text-[11px] font-bold text-slate-400">予測合格確率</p>
              <p className="text-xl font-extrabold">
                <span className="text-slate-400">{sessionStartPassProb}%</span>
                <span className="mx-2 text-slate-500">→</span>
                <span
                  style={{
                    color:
                      currentPassProb >= 70
                        ? "#86efac"
                        : currentPassProb >= 50
                          ? "#fcd34d"
                          : "#f87171",
                  }}
                >
                  {currentPassProb}%
                </span>
                {probDelta !== 0 && (
                  <span
                    className="ml-2 text-sm font-bold"
                    style={{ color: probDelta > 0 ? "#86efac" : "#f87171" }}
                  >
                    ({probDelta > 0 ? "+" : ""}
                    {probDelta}%)
                  </span>
                )}
              </p>
            </div>
          )}

          <div className="mb-6 text-left">
            {Object.entries(breakdown).map(([d, v]) => (
              <div key={d} className="flex justify-between border-b border-card2 py-1.5">
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

  const isCorrect =
    q.question_type === "multi"
      ? answered &&
        arraysEqual(
          Array.from(multiSelected).sort((a, b) => a - b),
          [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b)
        )
      : picked === q.correct_index;

  const correctSet = new Set(q.correct_indices ?? [q.correct_index]);

  const getOptionStyle = (i: number) => {
    if (!answered) {
      // 未回答
      if (q.question_type === "multi" && multiSelected.has(i)) {
        return { bg: "#1e3a5f", bd: "#3b82f6", fg: "#93c5fd" };
      }
      return { bg: "#0f1825", bd: "#2a3648", fg: "#cbd5e1" };
    }
    // 回答済み
    const isCorrectOption = correctSet.has(i);
    const wasSelected = q.question_type === "multi" ? multiSelected.has(i) : i === picked;

    if (isCorrectOption && wasSelected) return { bg: "#14532d", bd: "#16a34a", fg: "#bbf7d0" };
    if (isCorrectOption && !wasSelected) return { bg: "#1a3a1a", bd: "#65a30d", fg: "#d9f99d" }; // missed correct (multi)
    if (!isCorrectOption && wasSelected) return { bg: "#7f1d1d", bd: "#dc2626", fg: "#fecaca" };
    return { bg: "#0f1825", bd: "#2a3648", fg: "#64748b" };
  };

  return (
    <div className={page}>
      {/* プログレスバー */}
      <div className="mb-3 w-full max-w-[560px]">
        <div className="mb-1.5 flex justify-between">
          <span className="text-sm font-semibold text-muted">
            {idx + 1} / {deck.length}
          </span>
          <span className="text-[11px] text-muted2">{q.category_name}</span>
        </div>
        <div className="h-1 rounded bg-card2">
          <div
            className="h-full rounded bg-gradient-to-r from-primary to-sky-400"
            style={{ width: `${((idx + 1) / deck.length) * 100}%` }}
          />
        </div>
      </div>

      <div className={card}>
        {/* カテゴリ + 統計 */}
        <div className="mb-3.5 flex items-center justify-between">
          <div className="flex items-center gap-1.5">
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
            {q.question_type === "multi" && (
              <span className="rounded-md bg-blue-900/40 px-2 py-0.5 text-[10px] font-bold text-blue-300">
                複数選択
              </span>
            )}
          </div>
          <span className="text-[11px] text-muted2">
            {p.correct_count + p.wrong_count === 0
              ? "初挑戦"
              : `誤${totalWrong(q, p)} 連${p.consecutive_correct}`}
          </span>
        </div>

        {/* 問題文 */}
        <p className="mb-4 text-[15px] font-bold leading-8 text-slate-200">{q.question_text}</p>

        {/* コードブロック */}
        {q.code && (
          <pre className="mb-4 overflow-x-auto rounded-xl bg-black/40 px-4 py-3 font-mono text-[12px] leading-6 text-slate-300">
            <code>{q.code}</code>
          </pre>
        )}

        {/* 想起モード: 選択肢を隠す */}
        {choicesHidden ? (
          <div className="mb-4 flex flex-col items-center gap-3 rounded-xl bg-card2 py-6">
            <p className="text-sm font-bold text-slate-300">🧠 まず自分で考えてみよう</p>
            <p className="text-xs text-muted2">答えが浮かんだら選択肢を表示する</p>
            <button
              onClick={() => setChoicesHidden(false)}
              className="rounded-xl bg-gradient-to-br from-primary to-primary2 px-6 py-2.5 text-sm font-bold text-white"
            >
              選択肢を表示する
            </button>
          </div>
        ) : (
          <>
            {/* 確信度（回答前に選択する） */}
            {!answered && (
              <div
                className="mb-3.5 rounded-xl p-2.5 transition-all"
                style={
                  confidence === null
                    ? { background: "rgba(234,179,8,0.07)", border: "1px solid rgba(234,179,8,0.25)" }
                    : { background: "transparent", border: "1px solid transparent" }
                }
              >
                <p
                  className="mb-1.5 text-xs font-bold"
                  style={{ color: confidence === null ? "#fbbf24" : "#64748b" }}
                >
                  {confidence === null ? "① まず確信度を選ぶ" : "確信度を選択済み"}
                </p>
                <div className="flex gap-1.5">
                  {CONFIDENCE_LABELS.map((label, i) => {
                    const level = i + 1;
                    const on = confidence === level;
                    const color = CONFIDENCE_COLORS[i];
                    return (
                      <button
                        key={level}
                        onClick={() => handleConfidence(level)}
                        className="flex-1 rounded-xl border-2 px-0.5 py-2 text-[11px] font-bold transition-colors"
                        style={{
                          borderColor: on ? color : "#2a3648",
                          background: on ? color + "26" : "transparent",
                          color: on ? color : "#64748b",
                        }}
                      >
                        {label}
                      </button>
                    );
                  })}
                </div>
              </div>
            )}

            {/* 選択肢 */}
            {q.options.map((choice, i) => {
              const { bg, bd, fg } = getOptionStyle(i);
              const locked = !answered && confidence === null;
              return (
                <button
                  key={i}
                  onClick={() =>
                    q.question_type === "multi" ? toggleMulti(i) : answerSingle(i)
                  }
                  disabled={answered || locked}
                  className="mb-2 block w-full rounded-xl border-2 px-3.5 py-3 text-left transition-opacity"
                  style={{
                    background: bg,
                    borderColor: bd,
                    cursor: answered || locked ? "default" : "pointer",
                    opacity: locked ? 0.4 : 1,
                  }}
                >
                  <span className="text-[13px] leading-relaxed" style={{ color: fg }}>
                    <b className="mr-2">{"ABCD"[i]}.</b>
                    {choice}
                  </span>
                </button>
              );
            })}

            {/* 複数選択の回答ボタン */}
            {q.question_type === "multi" && !answered && (
              <button
                onClick={submitMulti}
                disabled={multiSelected.size === 0 || confidence === null}
                className="mb-2 w-full rounded-xl bg-gradient-to-br from-blue-600 to-blue-700 py-3 text-sm font-bold text-white disabled:from-slate-700 disabled:to-slate-700"
              >
                回答する（{multiSelected.size}個選択中）
              </button>
            )}
          </>
        )}

        {/* 回答後: 解説 + メモ + 次へ */}
        {answered && (
          <>
            <div
              className="my-3.5 rounded-xl px-4 py-3.5"
              style={{
                background: isCorrect ? "#14532d33" : "#7f1d1d33",
                border: `1px solid ${isCorrect ? "#16a34a" : "#dc2626"}44`,
              }}
            >
              <p
                className="mb-3 text-sm font-extrabold"
                style={{ color: isCorrect ? "#86efac" : "#fca5a5" }}
              >
                {isCorrect ? "✓ 正解！" : "✗ 不正解"}
                {confidence !== null && (
                  <span
                    className="ml-2 text-[11px] font-bold"
                    style={{ color: CONFIDENCE_COLORS[confidence - 1] }}
                  >
                    （{CONFIDENCE_LABELS[confidence - 1]}）
                  </span>
                )}
              </p>
              {confidence === 3 && isCorrect && (
                <p className="mb-3 text-center text-[11px] text-amber-400">
                  ⚠ まぐれ当たり — 連続正解をリセットしました
                </p>
              )}
              {q.explanation_data ? (
                <RichExplanation data={q.explanation_data} />
              ) : (
                <p className="text-[13px] leading-8 text-slate-300">{q.explanation}</p>
              )}
            </div>

            {/* メモ */}
            <p className="mb-1.5 text-xs font-bold text-slate-300">メモ</p>
            <textarea
              value={memoText}
              onChange={(e) => setMemoText(e.target.value)}
              placeholder="気づき・覚え方・自分の言葉での説明を残す"
              className="mb-3.5 min-h-[70px] w-full resize-y rounded-xl border border-border bg-card2 px-3 py-2.5 text-[13px] text-slate-200 outline-none focus:border-primary2"
            />

            <button
              onClick={saveMemoAndNext}
              className="w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-4 text-sm font-bold text-white"
            >
              {idx + 1 >= deck.length ? "結果を見る 🏁" : "次の問題へ →"}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
