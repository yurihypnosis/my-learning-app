import { useMemo, useState } from "react";
import { getProgress, totalWrong, type ProgressMap } from "@/features/quiz/lib/selection";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { type Screen } from "@/features/quiz/hooks/use-screen";
import { COMPREHENSION_LEVELS, WEAK_SESSION_MAX } from "@/features/quiz/lib/constants";

interface ComprehensionScreenProps {
  examQuestions: QuizQuestion[];
  progressMap: ProgressMap;
  isMultiSet: boolean;
  startReview: (qs: QuizQuestion[]) => void;
  setScreen: (s: Screen) => void;
}

// 不正解時に自己申告した理解度（understanding_level 1..3）で問題を絞り込み・
// 「わからない」順に並べて見直す画面。記録はクイズ画面の申告ボタンから入る。
export function ComprehensionScreen({
  examQuestions,
  progressMap,
  isMultiSet,
  startReview,
  setScreen,
}: ComprehensionScreenProps) {
  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  const [selLevels, setSelLevels] = useState<Set<number>>(
    () => new Set(COMPREHENSION_LEVELS.map((c) => c.level))
  );

  // 申告済み（1..3）の問題を、わからない順 → 誤答の多い順に並べる
  const rated = useMemo(() => {
    return examQuestions
      .filter((q) => {
        const lv = getProgress(progressMap, q.id).understanding_level;
        return lv >= 1 && lv <= 3;
      })
      .sort((a, b) => {
        const pa = getProgress(progressMap, a.id);
        const pb = getProgress(progressMap, b.id);
        if (pa.understanding_level !== pb.understanding_level)
          return pa.understanding_level - pb.understanding_level;
        return totalWrong(b, pb) - totalWrong(a, pa);
      });
  }, [examQuestions, progressMap]);

  const countOf = (level: number) =>
    rated.filter((q) => getProgress(progressMap, q.id).understanding_level === level).length;

  const filtered = rated.filter((q) =>
    selLevels.has(getProgress(progressMap, q.id).understanding_level)
  );

  return (
    <div className={wrap}>
      <div className={container}>
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-sm font-semibold text-white">理解度で見直す</h1>
          <button
            onClick={() => setScreen("menu")}
            className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
          >
            ← 戻る
          </button>
        </div>

        {rated.length === 0 ? (
          <div className="rounded-xl border border-dashed border-[#2a2f3f] px-4 py-10 text-center">
            <p className="mb-1 text-sm text-[#8892a4]">まだ理解度の記録がありません</p>
            <p className="text-xs text-[#555e70]">
              不正解のとき、解説の下の「いまの理解度は」で申告するとここに並びます
            </p>
          </div>
        ) : (
          <>
            {/* 理解度フィルタ */}
            <div className="mb-4 flex flex-wrap gap-1.5">
              {COMPREHENSION_LEVELS.map(({ level, label, color }) => {
                const on = selLevels.has(level);
                const n = countOf(level);
                return (
                  <button
                    key={level}
                    onClick={() => {
                      const s = new Set(selLevels);
                      s.has(level) ? s.delete(level) : s.add(level);
                      setSelLevels(s);
                    }}
                    className="flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs transition"
                    style={{
                      borderColor: on ? color + "55" : "#2a2f3f",
                      color: on ? color : "#8892a4",
                      background: on ? color + "0f" : "transparent",
                    }}
                  >
                    <span
                      className="h-1.5 w-1.5 shrink-0 rounded-full"
                      style={{ background: on ? color : "#3a4050" }}
                    />
                    {label}
                    <span className="text-[10px] tabular-nums opacity-60">{n}</span>
                  </button>
                );
              })}
            </div>

            {/* まとめて演習 */}
            {filtered.length > 0 && (
              <button
                onClick={() => startReview(filtered.slice(0, WEAK_SESSION_MAX))}
                className="mb-5 flex w-full items-center justify-between gap-3 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] px-4 py-3.5 text-left transition hover:border-[#3b82f6]"
              >
                <div className="min-w-0">
                  <p className="text-sm font-medium text-white">この条件で演習</p>
                  <p className="text-xs text-[#8892a4]">
                    {isMultiSet ? "全セット横断・" : ""}わからない順に出題
                  </p>
                </div>
                <span className="shrink-0 rounded-lg bg-[#3b82f6]/15 px-3 py-1.5 text-xs font-semibold tabular-nums text-[#60a5fa]">
                  {filtered.length > WEAK_SESSION_MAX
                    ? `上位${WEAK_SESSION_MAX} / ${filtered.length}問`
                    : `${filtered.length}問`}
                </span>
              </button>
            )}

            {/* 問題リスト（タップで1問だけ解き直す） */}
            <div className="space-y-2">
              {filtered.map((q) => {
                const p = getProgress(progressMap, q.id);
                const meta = COMPREHENSION_LEVELS.find(
                  (c) => c.level === p.understanding_level
                );
                return (
                  <button
                    key={q.id}
                    onClick={() => startReview([q])}
                    className="block w-full rounded-xl border border-[#2a2f3f] px-4 py-3 text-left transition hover:border-[#3a4050]"
                  >
                    <div className="mb-1 flex items-center gap-2">
                      <span
                        className="h-1.5 w-1.5 shrink-0 rounded-full"
                        style={{ background: meta?.color ?? "#555e70" }}
                      />
                      <span className="text-[10px]" style={{ color: meta?.color ?? "#555e70" }}>
                        {meta?.label}
                      </span>
                      <span className="ml-auto shrink-0 text-[10px] tabular-nums text-[#555e70]">
                        {q.category_name} · 誤 {totalWrong(q, p)}
                      </span>
                    </div>
                    <p className="line-clamp-2 text-xs leading-5 text-[#c0c8d8]">
                      {q.question_text}
                    </p>
                  </button>
                );
              })}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
