import { getProgress, totalWrong, type ProgressMap } from "@/features/quiz/lib/selection";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { arraysEqual } from "@/features/quiz/lib/grading";
import { useQuizSession } from "@/features/quiz/hooks/use-quiz-session";
import type { PersistFn } from "@/features/quiz/hooks/use-progress";
import { RichExplanation } from "@/features/quiz/components/rich-explanation";
import { CONFIDENCE_COLORS, CONFIDENCE_LABELS } from "@/features/quiz/lib/constants";

interface QuizScreenProps {
  session: ReturnType<typeof useQuizSession>;
  progressMap: ProgressMap;
  persist: PersistFn;
  isSpeakFirstQ: (q: QuizQuestion) => boolean;
}

export function QuizScreen({ session, progressMap, persist, isSpeakFirstQ }: QuizScreenProps) {
  const {
    deck,
    idx,
    picked,
    multiSelected,
    answered,
    confidence,
    choicesHidden,
    speakCue,
    memoText,
    pick,
    toggleMulti,
    setConfidence,
    revealChoices,
    setMemoText,
    goToIndex,
    saveMemoAndNext,
  } = session;

  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";

  const q = deck[idx];
  const p = getProgress(progressMap, q.id);
  const speakFirst = isSpeakFirstQ(q);

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
            <p className="mb-1 text-sm text-[#8892a4]">
              {speakFirst ? "声に出して英文を言ってみよう" : "まず自分で考えてみよう"}
            </p>
            <p className="mb-4 text-xs tabular-nums text-[#555e70]">
              {speakFirst
                ? speakCue > 0
                  ? `${speakCue} 秒以内に言い切る`
                  : "言い終えたら選択肢を表示する"
                : "答えが浮かんだら選択肢を表示する"}
            </p>
            <button
              onClick={revealChoices}
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
                    answered ? undefined : q.question_type === "multi" ? toggleMulti(i) : pick(i)
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
                  onClick={session.submitAnswer}
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

            {/* Speak-First: 口頭産出の自己申告。false の問題は苦手だけ演習に流入する */}
            {speakFirst && (
              <div className="flex items-center gap-2">
                <button
                  onClick={() =>
                    persist(q.id, { last_spoken_ok: p.last_spoken_ok === false ? true : false })
                  }
                  className="rounded-lg border px-3 py-1.5 text-xs transition"
                  style={{
                    borderColor: p.last_spoken_ok === false ? "#f59e0b" : "#2a2f3f",
                    background: p.last_spoken_ok === false ? "#f59e0b18" : "transparent",
                    color: p.last_spoken_ok === false ? "#f59e0b" : "#8892a4",
                  }}
                >
                  口では言えなかった
                </button>
                <span className="text-[10px] text-[#555e70]">
                  {p.last_spoken_ok === false ? "苦手だけ演習に入ります" : "3秒で言えなかったら押す"}
                </span>
              </div>
            )}

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
