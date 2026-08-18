import { getProgress, totalWrong, type ProgressMap } from "@/features/quiz/lib/selection";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { arraysEqual } from "@/features/quiz/lib/grading";
import { useQuizSession } from "@/features/quiz/hooks/use-quiz-session";
import type { PersistFn } from "@/features/quiz/hooks/use-progress";
import { RichExplanation } from "@/features/quiz/components/rich-explanation";
import {
  COMPREHENSION_LEVELS,
  CONFIDENCE_COLORS,
  CONFIDENCE_LABELS,
} from "@/features/quiz/lib/constants";

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

  // 選択肢の状態クラス。回答前は選択の有無、回答後は正誤で色分けする。
  const choiceClass = (i: number): string => {
    const selected = q.question_type === "multi" ? multiSelected.has(i) : i === picked;
    if (!answered) return selected ? "quiz-choice selected" : "quiz-choice";
    const isCorrectOption = correctSet.has(i);
    if (isCorrectOption && selected) return "quiz-choice locked correct";
    if (isCorrectOption && !selected) return "quiz-choice locked missed";
    if (!isCorrectOption && selected) return "quiz-choice locked wrong";
    return "quiz-choice locked dim";
  };

  const canSubmit =
    confidence !== null &&
    (q.question_type === "multi" ? multiSelected.size > 0 : picked !== null);

  return (
    <div className="quiz-shell">
      <div className="quiz-progress">
        <button
          className="btn-ghost btn-sm"
          onClick={() => goToIndex(idx - 1)}
          disabled={idx === 0}
          style={idx === 0 ? { opacity: 0.35, cursor: "default" } : undefined}
          aria-label="前の問題へ戻る"
        >
          ← 前へ
        </button>
        <div className="track">
          <div className="fill" style={{ width: `${((idx + 1) / deck.length) * 100}%` }} />
        </div>
        <span className="min-w-[44px] text-[11.5px] tabular-nums text-muted2">
          {idx + 1} / {deck.length}
        </span>
      </div>

      <div className="quiz-card">
        <div className="quiz-meta-row">
          <span
            className="h-[7px] w-[7px] shrink-0 rounded-full"
            style={{ background: q.category_color }}
          />
          <span>{q.category_name}</span>
          {q.question_type === "multi" && <span className="text-muted2">・複数選択</span>}
          <span className="ml-auto text-muted2">
            {p.correct_count + p.wrong_count === 0
              ? "初挑戦"
              : `誤 ${totalWrong(q, p)} 連 ${p.consecutive_correct}`}
          </span>
        </div>

        <p className="quiz-question">{q.question_text}</p>

        {q.code && (
          <pre className="quiz-code">
            <code>{q.code}</code>
          </pre>
        )}

        {choicesHidden ? (
          <div className="mb-5 rounded-xl border border-dashed border-border py-8 text-center">
            <p className="mb-1 text-sm text-muted">
              {speakFirst ? "声に出して英文を言ってみよう" : "まず自分で考えてみよう"}
            </p>
            <p className="mb-4 text-xs tabular-nums text-muted2">
              {speakFirst
                ? speakCue > 0
                  ? `${speakCue} 秒以内に言い切る`
                  : "言い終えたら選択肢を表示する"
                : "答えが浮かんだら選択肢を表示する"}
            </p>
            <button className="btn-primary" style={{ padding: "10px 20px" }} onClick={revealChoices}>
              選択肢を表示
            </button>
          </div>
        ) : (
          <>
            <div className="quiz-choices">
              {q.options.map((choice, i) => (
                <button
                  key={i}
                  onClick={() =>
                    answered ? undefined : q.question_type === "multi" ? toggleMulti(i) : pick(i)
                  }
                  disabled={answered}
                  className={choiceClass(i)}
                >
                  <span className="lt">{"ABCD"[i]}.</span>
                  <span>{choice}</span>
                </button>
              ))}
            </div>

            {!answered && (
              <>
                <div className="pill-row mb-3.5">
                  {CONFIDENCE_LABELS.map((label, i) => {
                    const level = i + 1;
                    return (
                      <button
                        key={level}
                        onClick={() => setConfidence(level)}
                        className={confidence === level ? "on" : ""}
                        style={{ ["--pill-color" as string]: CONFIDENCE_COLORS[i] }}
                      >
                        <span className="dot" />
                        {label}
                      </button>
                    );
                  })}
                </div>
                <button
                  className="btn-primary w-full"
                  onClick={session.submitAnswer}
                  disabled={!canSubmit}
                >
                  {q.question_type === "multi"
                    ? `回答する（${multiSelected.size} 選択中）`
                    : "回答する"}
                </button>
              </>
            )}
          </>
        )}

        {answered && (
          <div className="mt-5">
            <div
              className="result-banner"
              style={{
                borderColor: isCorrect ? "#14532d" : "#7f1d1d",
                background: isCorrect ? "rgba(5,46,22,.5)" : "rgba(28,6,6,.5)",
              }}
            >
              <span className="verdict" style={{ color: isCorrect ? "#86efac" : "#f87171" }}>
                {isCorrect ? "正解" : "不正解"}
              </span>
              {confidence !== null && (
                <span className="text-xs" style={{ color: CONFIDENCE_COLORS[confidence - 1] }}>
                  ・{CONFIDENCE_LABELS[confidence - 1]}
                </span>
              )}
              {confidence === 3 && isCorrect && (
                <span className="ml-auto text-[10px] text-[#92400e]">まぐれ当たり</span>
              )}
            </div>

            {/* 確信を持って正解した問題は、これ以上出す意味が薄いので任意で除外できる */}
            {isCorrect && confidence === 1 && (
              <div className="mb-4 flex items-center gap-2">
                {p.excluded ? (
                  <>
                    <span className="rounded-lg border border-[#22c55e] bg-[#22c55e18] px-3 py-1.5 text-xs text-[#22c55e]">
                      もう出題しません
                    </span>
                    <button
                      onClick={() => persist(q.id, { excluded: false })}
                      className="text-[10px] text-muted2 underline decoration-dotted transition hover:text-muted"
                    >
                      取り消す
                    </button>
                  </>
                ) : (
                  <button
                    onClick={() => persist(q.id, { excluded: true })}
                    className="rounded-lg border border-border px-3 py-1.5 text-xs text-muted transition hover:border-[#22c55e] hover:text-[#22c55e]"
                  >
                    もう出題しない
                  </button>
                )}
              </div>
            )}

            {/* Speak-First: 口頭産出の自己申告。false の問題は苦手だけ演習に流入する */}
            {speakFirst && (
              <div className="mb-4 flex items-center gap-2">
                <button
                  onClick={() =>
                    persist(q.id, { last_spoken_ok: p.last_spoken_ok === false ? true : false })
                  }
                  className="rounded-lg border px-3 py-1.5 text-xs transition"
                  style={{
                    borderColor: p.last_spoken_ok === false ? "#f59e0b" : "#262b38",
                    background: p.last_spoken_ok === false ? "#f59e0b18" : "transparent",
                    color: p.last_spoken_ok === false ? "#f59e0b" : "#8892a4",
                  }}
                >
                  口では言えなかった
                </button>
                <span className="text-[10px] text-muted2">
                  {p.last_spoken_ok === false ? "苦手だけ演習に入ります" : "3秒で言えなかったら押す"}
                </span>
              </div>
            )}

            <div className="explain-card">
              {q.explanation_data ? (
                <RichExplanation data={q.explanation_data} />
              ) : (
                <p className="text-sm leading-7 text-[#c0c8d8]">{q.explanation}</p>
              )}
            </div>

            {/* 不正解時の理解度の自己申告。「理解度で見直す」の並び替えに使う */}
            {!isCorrect && (
              <div className="mb-4">
                <p className="section-label mb-2">解説を読んで、いまの理解度は</p>
                <div className="pill-row">
                  {COMPREHENSION_LEVELS.map(({ level, label, color }) => {
                    const on = p.understanding_level === level;
                    return (
                      <button
                        key={level}
                        onClick={() => persist(q.id, { understanding_level: on ? 0 : level })}
                        className={on ? "on" : ""}
                        style={{ ["--pill-color" as string]: color }}
                      >
                        <span className="dot" />
                        {label}
                      </button>
                    );
                  })}
                </div>
              </div>
            )}

            <textarea
              value={memoText}
              onChange={(e) => setMemoText(e.target.value)}
              placeholder="気づき・覚え方・自分の言葉でのメモ"
              className="quiz-memo"
              rows={3}
            />

            <button className="btn-primary w-full" onClick={saveMemoAndNext}>
              {idx + 1 >= deck.length ? "結果を見る" : "次へ →"}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
