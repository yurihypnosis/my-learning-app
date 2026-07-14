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
  shuffleOptions,
  totalCorrect,
  totalWrong,
  type ProgressMap,
} from "@/lib/quiz/selection";
import { buildCSV, downloadCSV, type ExportMode } from "@/lib/quiz/csv";
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
// クイズ中の1問ごとの解答状態スナップショット（前後移動時の復元用）
type QState = {
  picked: number | null;
  multiSelected: number[];
  answered: boolean;
  confidence: number | null;
  choicesHidden: boolean;
};

const CONFIDENCE_LABELS = ["確信あり", "迷った", "勘"] as const;
const CONFIDENCE_COLORS = ["#22c55e", "#f59e0b", "#ef4444"] as const;

function arraysEqual(a: number[], b: number[]): boolean {
  return a.length === b.length && a.every((v, i) => v === b[i]);
}

function RichExplanation({ data }: { data: ExplanationData }) {
  const lbl = "mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]";
  return (
    <div className="space-y-5 text-sm leading-7 text-[#c0c8d8]">
      <div>
        <p className={lbl}>何を問われているか</p>
        <p>{data.asked}</p>
      </div>

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

      {data.vs && (
        <div>
          <p className={lbl}>混同ポイント</p>
          <p>{data.vs}</p>
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

  const [picked, setPicked] = useState<number | null>(null);
  const [multiSelected, setMultiSelected] = useState<Set<number>>(new Set());
  const [answered, setAnswered] = useState(false);
  const [confidence, setConfidence] = useState<number | null>(null);
  const [choicesHidden, setChoicesHidden] = useState(false);
  // 「前の問題に戻る」用: デッキ位置ごとに解答状態を保持し、行き来しても復元できるようにする
  const [qStates, setQStates] = useState<Record<number, QState>>({});

  const [sessionResults, setSessionResults] = useState<SessionResult[]>([]);
  const [memoText, setMemoText] = useState("");
  const [csvText, setCsvText] = useState("");
  const [exportMode, setExportMode] = useState<ExportMode>("weak");
  const [copyMsg, setCopyMsg] = useState("");

  const [goal, setGoal] = useState<UserGoal | null>(null);
  const [goalDraft, setGoalDraft] = useState<{ examDate: string; targetName: string }>({
    examDate: "",
    targetName: "",
  });
  const [sessionStartPassProb, setSessionStartPassProb] = useState<number | null>(null);

  useEffect(() => {
    const ts = Date.now();
    setNow(ts);
    const g = loadGoal(currentSubjectSlug);
    setGoal(g);
    if (g) setGoalDraft({ examDate: g.examDate, targetName: g.targetName });
  }, [currentSubjectSlug]);

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
    }).then(({ error }) => {
      if (error) console.error("[answer_events] insert failed:", error.code, error.message);
    });
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

  const enterQuiz = (pool: QuizQuestion[]) => {
    if (!pool.length) return;
    setSessionStartPassProb(calcMasteryStats(questions, progressMap).passProb);
    setDeck(pool);
    setIdx(0);
    setPicked(null);
    setMultiSelected(new Set());
    setAnswered(false);
    setConfidence(null);
    setChoicesHidden(recallMode);
    setSessionResults([]);
    setQStates({});
    setMemoText(getProgress(progressMap, pool[0].id).memo);
    setScreen("quiz");
  };

  const startQuiz = () => {
    enterQuiz(buildDeck({ questions, progressMap, selectedCategoryIds: selCats, count, mode, now }));
  };

  // 苦手問題など、指定した問題だけを復習するセッションを開始（選択肢はシャッフル）
  const startReview = (qs: QuizQuestion[]) => {
    enterQuiz(qs.map(shuffleOptions));
  };

  const toggleMulti = (i: number) => {
    if (answered) return;
    setMultiSelected((prev) => {
      const s = new Set(prev);
      s.has(i) ? s.delete(i) : s.add(i);
      return s;
    });
  };

  const submitAnswer = () => {
    if (answered || confidence === null) return;
    const q = deck[idx];
    if (q.question_type === "multi") {
      if (multiSelected.size === 0) return;
      const selected = Array.from(multiSelected).sort((a, b) => a - b);
      const expected = [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b);
      const isCorrect = arraysEqual(selected, expected);
      const magure = isCorrect && confidence === 3;
      setAnswered(true);
      const cur = getProgress(progressMap, q.id);
      const partial: Partial<Progress> = isCorrect
        ? { correct_count: cur.correct_count + 1, consecutive_correct: magure ? 0 : cur.consecutive_correct + 1, last_is_correct: true, last_answered_at: new Date().toISOString(), last_confidence: confidence }
        : { wrong_count: cur.wrong_count + 1, consecutive_correct: 0, last_is_correct: false, last_answered_at: new Date().toISOString(), last_confidence: confidence };
      setSessionResults((r) => [...r, { correct: isCorrect, category: q.category_name, color: q.category_color }]);
      persist(q.id, partial);
      recordAnswer(q, isCorrect, confidence);
    } else {
      if (picked === null) return;
      const isCorrect = picked === q.correct_index;
      const magure = isCorrect && confidence === 3;
      setAnswered(true);
      const cur = getProgress(progressMap, q.id);
      // 表示順でシャッフルしているため、保存は元(DB)のインデックスに戻す
      const selectedOrig = q.optionOrder ? q.optionOrder[picked] : picked;
      const partial: Partial<Progress> = isCorrect
        ? { correct_count: cur.correct_count + 1, consecutive_correct: magure ? 0 : cur.consecutive_correct + 1, last_is_correct: true, last_selected_index: selectedOrig, last_answered_at: new Date().toISOString(), last_confidence: confidence }
        : { wrong_count: cur.wrong_count + 1, consecutive_correct: 0, last_is_correct: false, last_selected_index: selectedOrig, last_answered_at: new Date().toISOString(), last_confidence: confidence };
      setSessionResults((r) => [...r, { correct: isCorrect, category: q.category_name, color: q.category_color }]);
      persist(q.id, partial);
      recordAnswer(q, isCorrect, confidence);
    }
  };

  // 現在の問題の解答状態をスナップショット化
  const snapshotCurrent = (): QState => ({
    picked,
    multiSelected: Array.from(multiSelected),
    answered,
    confidence,
    choicesHidden,
  });

  // デッキ内の任意の問題へ移動。現在の状態を保存し、移動先の状態を復元（なければ新規）
  const goToIndex = (target: number) => {
    if (target < 0 || target >= deck.length || target === idx) return;
    persist(deck[idx].id, { memo: memoText });
    setQStates((m) => ({ ...m, [idx]: snapshotCurrent() }));
    window.scrollTo({ top: 0, behavior: "smooth" });

    const nq = deck[target];
    const saved = qStates[target];
    if (saved) {
      setPicked(saved.picked);
      setMultiSelected(new Set(saved.multiSelected));
      setAnswered(saved.answered);
      setConfidence(saved.confidence);
      setChoicesHidden(saved.choicesHidden);
    } else {
      setPicked(null);
      setMultiSelected(new Set());
      setAnswered(false);
      setConfidence(null);
      setChoicesHidden(recallMode);
    }
    setMemoText(getProgress(progressMap, nq.id).memo);
    setIdx(target);
  };

  const saveMemoAndNext = () => {
    if (idx + 1 >= deck.length) {
      persist(deck[idx].id, { memo: memoText });
      window.scrollTo({ top: 0, behavior: "smooth" });
      setScreen("done");
      return;
    }
    goToIndex(idx + 1);
  };

  const switchSubject = (slug: string) => {
    router.push(slug ? `/?subject=${slug}` : "/");
  };

  if (now === 0) {
    return (
      <div className="flex justify-center pt-32 text-xs text-[#555e70]">
        読み込み中
      </div>
    );
  }

  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  // ── GOAL ──────────────────────────────────────────────────────────────
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
      <div className={wrap}>
        <div className={container}>
          <h1 className="mb-6 text-sm font-semibold text-white">目標設定</h1>

          <label className="mb-1.5 block text-xs text-[#8892a4]">試験日</label>
          <input
            type="date"
            value={goalDraft.examDate}
            onChange={(e) => setGoalDraft((d) => ({ ...d, examDate: e.target.value }))}
            className="mb-5 w-full rounded-xl border border-[#2a2f3f] bg-[#1a1d27] px-4 py-3 text-sm text-white outline-none focus:border-[#3b82f6] transition-colors"
          />

          <label className="mb-1.5 block text-xs text-[#8892a4]">試験名（任意）</label>
          <input
            type="text"
            value={goalDraft.targetName}
            onChange={(e) => setGoalDraft((d) => ({ ...d, targetName: e.target.value }))}
            placeholder={`例: ${subjectName} 合格`}
            className="mb-6 w-full rounded-xl border border-[#2a2f3f] bg-[#1a1d27] px-4 py-3 text-sm text-white outline-none placeholder:text-[#555e70] focus:border-[#3b82f6] transition-colors"
          />

          <button
            onClick={handleSaveGoal}
            disabled={!goalDraft.examDate}
            className="mb-2 w-full rounded-xl bg-[#3b82f6] py-3 text-sm font-medium text-white transition hover:bg-[#60a5fa] disabled:bg-[#1a1d27] disabled:text-[#555e70]"
          >
            保存
          </button>
          {goal && (
            <button
              onClick={handleClearGoal}
              className="mb-2 w-full rounded-xl border border-[#2a1010] bg-[#160606] py-3 text-sm font-medium text-[#ef4444] transition hover:border-[#3f1515]"
            >
              削除
            </button>
          )}
          <button
            onClick={() => setScreen("menu")}
            className="w-full rounded-xl py-3 text-sm text-[#555e70] transition hover:text-[#8892a4]"
          >
            キャンセル
          </button>
        </div>
      </div>
    );
  }

  // ── MENU ──────────────────────────────────────────────────────────────
  if (screen === "menu") {
    const answeredCount = questions.filter((q) => {
      const p = getProgress(progressMap, q.id);
      return p.correct_count + p.wrong_count > 0;
    }).length;
    const stats = calcMasteryStats(questions, progressMap);
    const dailyRec = calcDailyRec(questions, progressMap, now, goal?.examDate ?? null);
    const countOptions = [5, 10, 20, eligible.length];

    const probColor =
      stats.passProb >= 70 ? "#22c55e" : stats.passProb >= 50 ? "#f59e0b" : "#ef4444";

    return (
      <div className={wrap}>
        <div className={container}>
          {/* Header */}
          <div className="mb-6 flex items-start justify-between">
            <div>
              <h1 className="text-base font-semibold text-white">{subjectName}</h1>
              <p className="text-xs text-[#555e70]">
                全 {questions.length} 問
                {answeredCount > 0 && <span> · 演習済み {answeredCount}</span>}
                {restingCount > 0 && <span> · 休眠 {restingCount}</span>}
              </p>
            </div>
            {subjects.length > 1 && (
              <select
                value={currentSubjectSlug}
                onChange={(e) => switchSubject(e.target.value)}
                className="rounded-lg border border-[#2a2f3f] bg-[#1a1d27] px-2.5 py-1.5 text-xs text-[#8892a4] outline-none"
              >
                {subjects.map((s) => (
                  <option key={s.slug} value={s.slug}>{s.name}</option>
                ))}
              </select>
            )}
          </div>

          {/* Goal card */}
          {goal ? (
            <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-4">
              <div className="mb-3 flex items-start justify-between gap-4">
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium text-white">
                    {goal.targetName || subjectName}
                  </p>
                  <p className="text-xs text-[#555e70]">残り {dailyRec.daysRemaining} 日</p>
                </div>
                <div className="shrink-0 text-right">
                  <p className="text-2xl font-bold tabular-nums" style={{ color: probColor }}>
                    {stats.passProb}%
                  </p>
                  <p className="text-[10px] text-[#555e70]">合格確率</p>
                </div>
              </div>
              <div className="mb-3 h-px overflow-hidden rounded-full bg-[#2a2f3f]">
                <div
                  className="h-full rounded-full transition-all duration-500"
                  style={{ width: `${stats.passProb}%`, background: probColor }}
                />
              </div>
              <div className="flex items-center justify-between">
                <p className="text-xs text-[#555e70]">
                  {dailyRec.newCount > 0 && `新規 ${dailyRec.newCount}問`}
                  {dailyRec.newCount > 0 && dailyRec.reviewCount > 0 && " · "}
                  {dailyRec.reviewCount > 0 && `復習 ${dailyRec.reviewCount}問`}
                  {dailyRec.newCount === 0 && dailyRec.reviewCount === 0 && "今日のタスク完了"}
                </p>
                <button
                  onClick={() => setScreen("goal")}
                  className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
                >
                  編集
                </button>
              </div>
            </div>
          ) : (
            <button
              onClick={() => setScreen("goal")}
              className="mb-6 w-full rounded-xl border border-dashed border-[#2a2f3f] px-4 py-4 text-left transition hover:border-[#3a4050]"
            >
              <p className="text-sm text-[#8892a4]">試験日を設定</p>
              <p className="text-xs text-[#555e70]">合格確率と今日のノルマを逆算します</p>
            </button>
          )}

          {/* Categories */}
          <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            分野
          </p>
          <div className="mb-2 flex flex-wrap gap-1.5">
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
                  className="flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs transition"
                  style={{
                    borderColor: on ? c.color + "55" : "#2a2f3f",
                    color: on ? c.color : "#8892a4",
                    background: on ? c.color + "0f" : "transparent",
                  }}
                >
                  <span
                    className="h-1.5 w-1.5 shrink-0 rounded-full"
                    style={{ background: on ? c.color : "#3a4050" }}
                  />
                  {c.name}
                  <span className="text-[10px] opacity-60">{all.length - rest}</span>
                </button>
              );
            })}
          </div>
          <div className="mb-6 flex gap-3">
            <button
              onClick={() => setSelCats(new Set(categories.map((c) => c.id)))}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              全選択
            </button>
            <span className="text-[#2a2f3f]">·</span>
            <button
              onClick={() => setSelCats(new Set())}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              全解除
            </button>
          </div>

          {/* Count */}
          <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            問題数
          </p>
          <div className="mb-6 flex overflow-hidden rounded-xl border border-[#2a2f3f]">
            {countOptions.map((n, i) => {
              const on = count === n;
              return (
                <button
                  key={i}
                  onClick={() => setCount(n)}
                  className="flex-1 border-r border-[#2a2f3f] py-2.5 text-sm font-medium last:border-r-0 transition"
                  style={{
                    background: on ? "#3b82f6" : "transparent",
                    color: on ? "#fff" : "#8892a4",
                  }}
                >
                  {i === 3 ? eligible.length : n}
                </button>
              );
            })}
          </div>

          {/* Start CTA */}
          <button
            onClick={startQuiz}
            disabled={!eligible.length}
            className="mb-6 w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa] disabled:bg-[#141720] disabled:text-[#555e70]"
          >
            スタート — {Math.min(count, eligible.length)} 問
          </button>

          {/* Advanced settings */}
          <details className="mb-6 group" open={mode === "priority" || recallMode}>
            <summary className="mb-3 cursor-pointer list-none text-xs text-[#555e70] transition hover:text-[#8892a4] group-open:text-[#8892a4]">
              詳細設定
            </summary>

            <div className="space-y-4">
              <div>
                <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
                  出題モード
                </p>
                <div className="flex overflow-hidden rounded-xl border border-[#2a2f3f]">
                  {([["shuffle", "シャッフル"], ["priority", "弱点優先"]] as const).map(
                    ([m, lbl], i) => (
                      <button
                        key={m}
                        onClick={() => setMode(m)}
                        className="flex-1 py-2.5 text-sm transition"
                        style={{
                          borderRight: i === 0 ? "1px solid #2a2f3f" : "none",
                          background:
                            mode === m
                              ? m === "priority"
                                ? "#1f0a0a"
                                : "#0d1f3c"
                              : "transparent",
                          color:
                            mode === m
                              ? m === "priority"
                                ? "#f87171"
                                : "#60a5fa"
                              : "#8892a4",
                        }}
                      >
                        {lbl}
                      </button>
                    )
                  )}
                </div>
                <p className="mt-1.5 text-xs text-[#555e70]">
                  3回連続正解は2週間休眠
                </p>
              </div>

              <div className="flex items-center justify-between rounded-xl border border-[#2a2f3f] px-4 py-3">
                <div>
                  <p className="text-sm text-[#c0c8d8]">想起モード</p>
                  <p className="text-xs text-[#555e70]">選択肢を隠して先に考える</p>
                </div>
                <button
                  onClick={() => setRecallMode((v) => !v)}
                  className="relative h-6 w-11 shrink-0 rounded-full transition-colors"
                  style={{ background: recallMode ? "#3b82f6" : "#2a2f3f" }}
                >
                  <span
                    className="absolute top-1 h-4 w-4 rounded-full bg-white shadow transition-all"
                    style={{ left: recallMode ? "calc(100% - 20px)" : "4px" }}
                  />
                </button>
              </div>
            </div>
          </details>

          {/* Nav grid */}
          <div className="grid grid-cols-2 gap-2">
            {[
              { label: "ロードマップ", action: () => router.push("/roadmap") },
              { label: "学習ログ",     action: () => router.push("/log") },
              { label: "苦手分析",     action: () => setScreen("analysis") },
              {
                label: "書き出し",
                action: () => {
                  setCsvText(buildCSV(questions, progressMap, now, exportMode));
                  setCopyMsg("");
                  setScreen("export");
                },
              },
            ].map(({ label, action }) => (
              <button
                key={label}
                onClick={action}
                className="rounded-xl border border-[#2a2f3f] py-3 text-xs text-[#555e70] transition hover:border-[#3a4050] hover:text-[#8892a4]"
              >
                {label}
              </button>
            ))}
          </div>
        </div>
      </div>
    );
  }

  // ── EXPORT ────────────────────────────────────────────────────────────
  if (screen === "export") {
    const weakCount = questions.filter((q) => {
      const p = getProgress(progressMap, q.id);
      if (p.correct_count + p.wrong_count === 0 && q.initial_wrong_weight === 0) return false;
      const attempts = p.correct_count + p.wrong_count;
      if (attempts === 0) return true;
      const accuracy = p.correct_count / attempts;
      const selfScore = p.last_confidence === 1 ? 1.0 : p.last_confidence === 2 ? 0.5 : 0.0;
      const streakBonus = Math.min(p.consecutive_correct, 3) / 30;
      return Math.min(1, accuracy * 0.6 + selfScore * 0.3 + streakBonus) < 0.5;
    }).length;
    const memoCount = questions.filter((q) =>
      getProgress(progressMap, q.id).memo.trim()
    ).length;

    const MODES: { key: ExportMode; label: string; count: number }[] = [
      { key: "weak", label: "苦手",     count: weakCount },
      { key: "memo", label: "メモあり", count: memoCount },
      { key: "all",  label: "全問題",   count: questions.length },
    ];

    const rebuild = (m: ExportMode) => {
      setExportMode(m);
      setCsvText(buildCSV(questions, progressMap, now, m));
      setCopyMsg("");
    };

    return (
      <div className={wrap}>
        <div className={container}>
          <div className="mb-6 flex items-center justify-between">
            <h1 className="text-sm font-semibold text-white">書き出し（CSV）</h1>
            <button
              onClick={() => setScreen("menu")}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              ← 戻る
            </button>
          </div>

          <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            対象
          </p>
          <div className="mb-5 flex overflow-hidden rounded-xl border border-[#2a2f3f]">
            {MODES.map(({ key, label, count }, i) => {
              const on = exportMode === key;
              return (
                <button
                  key={key}
                  onClick={() => rebuild(key)}
                  className="flex-1 py-2.5 text-xs font-medium transition"
                  style={{
                    borderRight: i < MODES.length - 1 ? "1px solid #2a2f3f" : "none",
                    background: on ? "#1a1d27" : "transparent",
                    color: on ? "#fff" : "#8892a4",
                  }}
                >
                  {label}
                  <span className="ml-1 opacity-50">({count})</span>
                </button>
              );
            })}
          </div>

          {exportMode === "weak" && weakCount === 0 && (
            <div className="mb-5 rounded-xl border border-[#0a2a1a] bg-[#061510] p-4 text-center">
              <p className="text-sm text-[#22c55e]">苦手問題なし</p>
              <p className="text-xs text-[#1a5a2a]">習得度 50% 以上の問題のみです</p>
            </div>
          )}

          <button
            onClick={() => downloadCSV(`${currentSubjectSlug}-${exportMode}.csv`, csvText)}
            className="mb-2 w-full rounded-xl bg-[#3b82f6] py-3.5 text-sm font-medium text-white transition hover:bg-[#60a5fa]"
          >
            ダウンロード
          </button>
          <button
            onClick={async () => {
              try {
                await navigator.clipboard.writeText(csvText);
                setCopyMsg("コピーしました");
              } catch {
                setCopyMsg("コピー不可 — テキストを手動で選択してください");
              }
            }}
            className="mb-2 w-full rounded-xl border border-[#2a2f3f] py-3 text-sm text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#c0c8d8]"
          >
            クリップボードにコピー
          </button>
          {copyMsg && (
            <p className="mb-3 text-center text-xs text-[#8892a4]">{copyMsg}</p>
          )}

          <textarea
            readOnly
            value={csvText}
            onFocus={(e) => e.target.select()}
            className="mb-4 min-h-[180px] w-full resize-y overflow-x-auto rounded-xl border border-[#2a2f3f] bg-[#141720] px-3 py-2.5 font-mono text-[11px] text-[#8892a4]"
          />
        </div>
      </div>
    );
  }

  // ── ANALYSIS ──────────────────────────────────────────────────────────
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
      .filter((q) => {
        const p = getProgress(progressMap, q.id);
        return p.correct_count + p.wrong_count > 0;
      })
      .sort((a, b) => {
        const pa = getProgress(progressMap, a.id);
        const pb = getProgress(progressMap, b.id);
        return totalWrong(b, pb) - totalCorrect(pb) - (totalWrong(a, pa) - totalCorrect(pa));
      })
      .slice(0, 8);

    const masteryStats = calcMasteryStats(questions, progressMap);
    const catMastery = calcCategoryMastery(categories, questions, progressMap);
    const probColor =
      masteryStats.passProb >= 70 ? "#22c55e" : masteryStats.passProb >= 50 ? "#f59e0b" : "#ef4444";

    return (
      <div className={wrap}>
        <div className={container}>
          <div className="mb-6 flex items-center justify-between">
            <h1 className="text-sm font-semibold text-white">苦手分析</h1>
            <button
              onClick={() => setScreen("menu")}
              className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
            >
              ← 戻る
            </button>
          </div>

          {/* Pass probability */}
          <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-4">
            <div className="mb-3 flex items-end justify-between">
              <p className="text-xs text-[#8892a4]">予測合格確率</p>
              <p className="text-3xl font-bold tabular-nums" style={{ color: probColor }}>
                {masteryStats.passProb}%
              </p>
            </div>
            <div className="mb-3 h-px overflow-hidden rounded-full bg-[#2a2f3f]">
              <div
                className="h-full rounded-full transition-all"
                style={{ width: `${masteryStats.passProb}%`, background: probColor }}
              />
            </div>
            <div className="flex flex-wrap gap-4 text-xs text-[#555e70]">
              <span>カバー {Math.round(masteryStats.coverage * 100)}%</span>
              <span>習得 {masteryStats.masteredCount}</span>
              <span>弱点 {masteryStats.weakCount}</span>
              {masteryStats.untestedCount > 0 && (
                <span>未着手 {masteryStats.untestedCount}</span>
              )}
            </div>
          </div>

          {/* Skill tree */}
          <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            分野別スキルツリー
          </p>
          <div className="mb-6 space-y-2">
            {catMastery.map((cm) => {
              const pct = Math.round(cm.mastery * 100);
              const stat = catStats.find((s) => s.id === cm.id);
              return (
                <div key={cm.id} className="rounded-xl border border-[#2a2f3f] bg-[#141720] p-3.5">
                  <div className="mb-2 flex items-center justify-between gap-2">
                    <div className="flex min-w-0 items-center gap-2">
                      <span
                        className="h-2 w-2 shrink-0 rounded-full"
                        style={{ background: cm.color }}
                      />
                      <span className="truncate text-xs font-medium text-[#c0c8d8]">{cm.name}</span>
                    </div>
                    <div className="flex shrink-0 items-center gap-3 text-[10px] text-[#555e70]">
                      {stat?.acc !== null && stat?.acc !== undefined && (
                        <span>正答 {stat.acc}%</span>
                      )}
                      <span>{cm.masteredCount}/{cm.total}</span>
                      <span
                        className="w-9 text-right font-semibold"
                        style={{
                          color:
                            cm.attempted === 0
                              ? "#555e70"
                              : pct >= 70
                                ? "#22c55e"
                                : pct >= 40
                                  ? "#f59e0b"
                                  : "#ef4444",
                        }}
                      >
                        {cm.attempted === 0 ? "未着" : `${pct}%`}
                      </span>
                    </div>
                  </div>
                  <div className="h-px overflow-hidden rounded-full bg-[#2a2f3f]">
                    <div
                      className="h-full rounded-full transition-all"
                      style={{
                        width: `${pct}%`,
                        background: cm.color,
                        opacity: pct === 0 ? 0.15 : 0.7,
                      }}
                    />
                  </div>
                </div>
              );
            })}
          </div>

          {/* Worst questions */}
          <div className="mb-3 flex items-center justify-between">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
              最重点 8 問
            </p>
            {worst.length > 0 && (
              <button
                onClick={() => startReview(worst)}
                className="rounded-lg border border-[#2a2f3f] px-3 py-1 text-[11px] font-medium text-[#8892a4] transition hover:border-[#3b82f6] hover:text-white"
              >
                まとめて復習 →
              </button>
            )}
          </div>
          <p className="mb-3 text-[10px] text-[#3a4050]">
            タップするとその問題だけを復習できます
          </p>
          <div className="mb-6 space-y-1.5">
            {worst.length === 0 && (
              <p className="text-xs text-[#555e70]">演習済み問題がありません</p>
            )}
            {worst.map((q) => {
              const p = getProgress(progressMap, q.id);
              return (
                <button
                  key={q.id}
                  onClick={() => startReview([q])}
                  className="flex w-full items-start gap-3 rounded-xl border border-[#2a2f3f] px-3.5 py-3 text-left transition hover:border-[#3b82f6] hover:bg-[#141720]"
                >
                  <span
                    className="mt-0.5 h-2 w-2 shrink-0 rounded-full"
                    style={{ background: q.category_color }}
                  />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-xs text-[#8892a4]">
                      {q.question_text.slice(0, 55)}…
                    </p>
                    <p className="mt-0.5 text-[10px] text-[#555e70]">
                      誤 {totalWrong(q, p)} 正 {totalCorrect(p)}
                      {p.last_confidence !== null && (
                        <span className="ml-2" style={{ color: CONFIDENCE_COLORS[(p.last_confidence ?? 1) - 1] }}>
                          {CONFIDENCE_LABELS[(p.last_confidence ?? 1) - 1]}
                        </span>
                      )}
                    </p>
                  </div>
                  <span className="mt-0.5 shrink-0 text-xs text-[#3a4050]">→</span>
                </button>
              );
            })}
          </div>

          {/* Confidence distribution */}
          <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            確信度の分布
          </p>
          <div className="mb-6 flex gap-2">
            {CONFIDENCE_LABELS.map((label, i) => {
              const level = i + 1;
              const cnt = questions.filter(
                (qq) => getProgress(progressMap, qq.id).last_confidence === level
              ).length;
              return (
                <div
                  key={i}
                  className="flex-1 rounded-xl border border-[#2a2f3f] bg-[#141720] py-3 text-center"
                >
                  <p className="text-xl font-bold tabular-nums" style={{ color: CONFIDENCE_COLORS[i] }}>
                    {cnt}
                  </p>
                  <p className="text-[9px] text-[#555e70]">{label}</p>
                </div>
              );
            })}
            <div className="flex-1 rounded-xl border border-[#2a2f3f] bg-[#141720] py-3 text-center">
              <p className="text-xl font-bold tabular-nums text-[#3a4050]">
                {questions.filter((qq) => getProgress(progressMap, qq.id).last_confidence === null).length}
              </p>
              <p className="text-[9px] text-[#555e70]">未回答</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ── DONE ──────────────────────────────────────────────────────────────
  if (screen === "done") {
    const ok = sessionResults.filter((r) => r.correct).length;
    const pct = sessionResults.length
      ? Math.round((ok / sessionResults.length) * 100)
      : 0;
    const breakdown: Record<string, { ok: number; ng: number; color: string }> = {};
    sessionResults.forEach((r) => {
      if (!breakdown[r.category]) breakdown[r.category] = { ok: 0, ng: 0, color: r.color };
      r.correct ? breakdown[r.category].ok++ : breakdown[r.category].ng++;
    });
    const currentPassProb = calcMasteryStats(questions, progressMap).passProb;
    const probDelta = sessionStartPassProb !== null ? currentPassProb - sessionStartPassProb : null;

    return (
      <div className={wrap}>
        <div className={container}>
          {/* Score */}
          <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-6 text-center">
            <p className="mb-1 text-4xl font-bold tabular-nums text-white">
              {ok}
              <span className="text-xl text-[#555e70]"> / {sessionResults.length}</span>
            </p>
            <p className="text-sm text-[#8892a4]">正答率 {pct}%</p>

            {probDelta !== null && (
              <div className="mt-4 flex items-center justify-center gap-2 text-sm tabular-nums">
                <span className="text-[#555e70]">{sessionStartPassProb}%</span>
                <span className="text-[#3a4050]">→</span>
                <span
                  className="font-semibold"
                  style={{
                    color:
                      currentPassProb >= 70 ? "#22c55e" : currentPassProb >= 50 ? "#f59e0b" : "#ef4444",
                  }}
                >
                  {currentPassProb}%
                </span>
                {probDelta !== 0 && (
                  <span
                    className="text-xs"
                    style={{ color: probDelta > 0 ? "#22c55e" : "#ef4444" }}
                  >
                    ({probDelta > 0 ? "+" : ""}{probDelta}%)
                  </span>
                )}
              </div>
            )}
          </div>

          {/* Category breakdown */}
          {Object.keys(breakdown).length > 0 && (
            <div className="mb-6 rounded-xl border border-[#2a2f3f] overflow-hidden">
              {Object.entries(breakdown).map(([cat, v], i) => (
                <div
                  key={cat}
                  className="flex items-center justify-between px-4 py-3"
                  style={{
                    borderTop: i > 0 ? "1px solid #2a2f3f" : "none",
                  }}
                >
                  <div className="flex items-center gap-2">
                    <span
                      className="h-1.5 w-1.5 rounded-full"
                      style={{ background: v.color }}
                    />
                    <span className="text-xs text-[#8892a4]">{cat}</span>
                  </div>
                  <div className="flex gap-3 text-xs">
                    <span className="text-[#22c55e]">{v.ok}</span>
                    <span className="text-[#ef4444]">{v.ng}</span>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="flex gap-2">
            <button
              onClick={() => setScreen("analysis")}
              className="flex-1 rounded-xl border border-[#2a2f3f] py-3 text-sm text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#c0c8d8]"
            >
              分析
            </button>
            <button
              onClick={() => setScreen("menu")}
              className="flex-1 rounded-xl bg-[#3b82f6] py-3 text-sm font-medium text-white transition hover:bg-[#60a5fa]"
            >
              メニュー
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ── QUIZ ──────────────────────────────────────────────────────────────
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

  const getChoiceClass = (i: number): string => {
    if (!answered) {
      if (q.question_type === "multi" && multiSelected.has(i)) return "border-[#2a4a7f] bg-[#0f1f40]";
      if (q.question_type !== "multi" && i === picked)          return "border-[#3b82f6] bg-[#0d1f3c]";
      return "border-[#2a2f3f] hover:border-[#3b82f6] cursor-pointer";
    }
    const isCorrectOption = correctSet.has(i);
    const wasSelected = q.question_type === "multi" ? multiSelected.has(i) : i === picked;
    if (isCorrectOption && wasSelected)  return "border-[#166534] bg-[#052e16]";
    if (isCorrectOption && !wasSelected) return "border-[#134e26] bg-[#031a0e]";
    if (!isCorrectOption && wasSelected) return "border-[#7f1d1d] bg-[#1c0606]";
    return "border-[#2a2f3f]";
  };

  const getChoiceColor = (i: number): string => {
    if (!answered) {
      if ((q.question_type === "multi" && multiSelected.has(i)) ||
          (q.question_type !== "multi" && i === picked)) return "#ffffff";
      return "#c0c8d8";
    }
    const isCorrectOption = correctSet.has(i);
    const wasSelected = q.question_type === "multi" ? multiSelected.has(i) : i === picked;
    if (isCorrectOption && wasSelected)  return "#86efac";
    if (isCorrectOption && !wasSelected) return "#4ade80";
    if (!isCorrectOption && wasSelected) return "#fca5a5";
    return "#555e70";
  };

  return (
    <div className={wrap}>
      {/* Progress */}
      <div className="mb-4 w-full max-w-[520px]">
        <div className="mb-2 flex items-center gap-3">
          <button
            onClick={() => goToIndex(idx - 1)}
            disabled={idx === 0}
            className="shrink-0 rounded-lg border border-[#2a2f3f] px-2.5 py-1 text-xs text-[#8892a4] transition hover:border-[#3b82f6] hover:text-white disabled:cursor-default disabled:border-transparent disabled:text-transparent"
            aria-label="前の問題へ戻る"
          >
            ← 前へ
          </button>
          <span className="min-w-[40px] text-xs tabular-nums text-[#555e70]">
            {idx + 1} / {deck.length}
          </span>
          <div className="h-px flex-1 overflow-hidden rounded-full bg-[#1a1d27]">
            <div
              className="h-full rounded-full bg-[#3b82f6] transition-all"
              style={{ width: `${((idx + 1) / deck.length) * 100}%` }}
            />
          </div>
        </div>
      </div>

      <div className="w-full max-w-[520px] rounded-2xl border border-[#2a2f3f] bg-[#1a1d27] p-5">
        {/* Meta */}
        <div className="mb-4 flex items-center gap-2">
          <span className="h-2 w-2 shrink-0 rounded-full" style={{ background: q.category_color }} />
          <span className="text-xs text-[#8892a4]">{q.category_name}</span>
          {q.question_type === "multi" && (
            <span className="text-xs text-[#555e70]">· 複数選択</span>
          )}
          <span className="ml-auto text-xs text-[#555e70]">
            {p.correct_count + p.wrong_count === 0
              ? "初挑戦"
              : `誤 ${totalWrong(q, p)} 連 ${p.consecutive_correct}`}
          </span>
        </div>

        {/* Question */}
        <p className="mb-5 text-[15px] font-medium leading-8 text-[#e8eaf0]">
          {q.question_text}
        </p>

        {/* Code */}
        {q.code && (
          <pre className="mb-5 overflow-x-auto rounded-xl bg-[#141720] px-4 py-3.5 font-mono text-xs leading-6 text-[#8892a4]">
            <code>{q.code}</code>
          </pre>
        )}

        {/* Recall placeholder */}
        {choicesHidden ? (
          <div className="mb-5 rounded-xl border border-dashed border-[#2a2f3f] py-8 text-center">
            <p className="mb-1 text-sm text-[#8892a4]">まず自分で考えてみよう</p>
            <p className="mb-4 text-xs text-[#555e70]">答えが浮かんだら選択肢を表示する</p>
            <button
              onClick={() => setChoicesHidden(false)}
              className="rounded-lg bg-[#3b82f6] px-5 py-2 text-sm font-medium text-white transition hover:bg-[#60a5fa]"
            >
              選択肢を表示
            </button>
          </div>
        ) : (
          <>
            {/* Choices — always fully visible, click to select */}
            <div className="space-y-2">
              {q.options.map((choice, i) => (
                <button
                  key={i}
                  onClick={() =>
                    answered ? undefined : q.question_type === "multi" ? toggleMulti(i) : setPicked(i)
                  }
                  disabled={answered}
                  className={`block w-full rounded-xl border px-4 py-3.5 text-left text-sm leading-relaxed transition ${getChoiceClass(i)}`}
                  style={{ color: getChoiceColor(i) }}
                >
                  <span className="mr-2.5 font-semibold">{"ABCD"[i]}.</span>
                  {choice}
                </button>
              ))}
            </div>

            {/* Confidence + Submit */}
            {!answered && (
              <div className="mt-4 space-y-3">
                <div className="flex overflow-hidden rounded-xl border border-[#2a2f3f]">
                  {CONFIDENCE_LABELS.map((label, i) => {
                    const level = i + 1;
                    const on = confidence === level;
                    const color = CONFIDENCE_COLORS[i];
                    return (
                      <button
                        key={level}
                        onClick={() => setConfidence(level)}
                        className="flex flex-1 items-center justify-center gap-1.5 border-r border-[#2a2f3f] py-2.5 text-xs font-medium last:border-r-0 transition"
                        style={{
                          background: on ? color + "18" : "transparent",
                          color: on ? color : "#8892a4",
                        }}
                      >
                        {on && <span className="h-1.5 w-1.5 rounded-full" style={{ background: color }} />}
                        {label}
                      </button>
                    );
                  })}
                </div>
                <button
                  onClick={submitAnswer}
                  disabled={
                    confidence === null ||
                    (q.question_type === "multi" ? multiSelected.size === 0 : picked === null)
                  }
                  className="w-full rounded-xl bg-[#3b82f6] py-3.5 text-sm font-semibold text-white transition hover:bg-[#60a5fa] disabled:bg-[#141720] disabled:text-[#555e70]"
                >
                  {q.question_type === "multi"
                    ? `回答する（${multiSelected.size} 選択中）`
                    : "回答する"}
                </button>
              </div>
            )}
          </>
        )}

        {/* After answer */}
        {answered && (
          <div className="mt-5 space-y-4">
            {/* Result banner */}
            <div
              className="rounded-xl border px-4 py-3"
              style={{
                borderColor: isCorrect ? "#14532d" : "#7f1d1d",
                background: isCorrect ? "#052e1620" : "#1c060620",
              }}
            >
              <div className="mb-0.5 flex items-center gap-2">
                <span
                  className="text-sm font-semibold"
                  style={{ color: isCorrect ? "#86efac" : "#f87171" }}
                >
                  {isCorrect ? "正解" : "不正解"}
                </span>
                {confidence !== null && (
                  <span
                    className="text-xs"
                    style={{ color: CONFIDENCE_COLORS[confidence - 1] }}
                  >
                    · {CONFIDENCE_LABELS[confidence - 1]}
                  </span>
                )}
                {confidence === 3 && isCorrect && (
                  <span className="ml-auto text-[10px] text-[#92400e]">まぐれ当たり</span>
                )}
              </div>
            </div>

            {/* Explanation */}
            <div className="rounded-xl border border-[#2a2f3f] bg-[#141720] p-4">
              {q.explanation_data ? (
                <RichExplanation data={q.explanation_data} />
              ) : (
                <p className="text-sm leading-7 text-[#c0c8d8]">{q.explanation}</p>
              )}
            </div>

            {/* Memo */}
            <textarea
              value={memoText}
              onChange={(e) => setMemoText(e.target.value)}
              placeholder="気づき・覚え方・自分の言葉でのメモ"
              className="w-full resize-y rounded-xl border border-[#2a2f3f] bg-[#141720] px-4 py-3 text-xs leading-relaxed text-[#8892a4] outline-none placeholder:text-[#3a4050] focus:border-[#3a4050]"
              rows={3}
            />

            <button
              onClick={saveMemoAndNext}
              className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
            >
              {idx + 1 >= deck.length ? "結果を見る" : "次へ →"}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
