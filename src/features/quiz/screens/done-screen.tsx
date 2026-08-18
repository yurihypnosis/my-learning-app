import { type ProgressMap } from "@/features/quiz/lib/selection";
import { calcMasteryStats } from "@/features/quiz/lib/stats";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { type Screen } from "@/features/quiz/hooks/use-screen";
import { useQuizSession } from "@/features/quiz/hooks/use-quiz-session";
import { WEAK_SESSION_MAX } from "@/features/quiz/lib/constants";

interface DoneScreenProps {
  session: ReturnType<typeof useQuizSession>;
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  examWeakPool: QuizQuestion[];
  setScreen: (s: Screen) => void;
}

export function DoneScreen({
  session,
  questions,
  progressMap,
  examWeakPool,
  setScreen,
}: DoneScreenProps) {
  const { deck, sessionResults, sessionStartPassProb, startReview } = session;
  const wrap = "flex flex-col items-center pb-16";
  const container = "w-full max-w-[560px]";

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

        {/* 周回導線: このセッションの「間違い＋勘」をすぐ再挑戦 → 続けて苦手を回す */}
        {(() => {
          const againIds = new Set(
            sessionResults.filter((r) => !r.correct || r.confidence === 3).map((r) => r.id)
          );
          const again = deck.filter((qq) => againIds.has(qq.id));
          const nextWeak = examWeakPool.slice(0, WEAK_SESSION_MAX);
          return (
            <div className="space-y-2">
              {again.length > 0 && (
                <button
                  onClick={() => startReview(again)}
                  className="w-full rounded-xl bg-[#3b82f6] py-3.5 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
                >
                  間違い・勘の {again.length}問 をもう一周
                </button>
              )}
              {nextWeak.length > 0 && (
                <button
                  onClick={() => startReview(nextWeak)}
                  className="w-full rounded-xl border border-[#2a2f3f] py-3 text-sm text-[#c0c8d8] transition hover:border-[#3a4050]"
                >
                  {again.length > 0 ? "続けて苦手を" : "苦手をもう一周 "}
                  {Math.min(WEAK_SESSION_MAX, examWeakPool.length)}問
                </button>
              )}
              <div className="flex gap-2 pt-1">
                <button
                  onClick={() => setScreen("analysis")}
                  className="flex-1 rounded-xl border border-[#2a2f3f] py-2.5 text-xs text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#c0c8d8]"
                >
                  分析
                </button>
                <button
                  onClick={() => setScreen("menu")}
                  className={
                    again.length === 0 && nextWeak.length === 0
                      ? "flex-1 rounded-xl bg-[#3b82f6] py-2.5 text-xs font-medium text-white transition hover:bg-[#60a5fa]"
                      : "flex-1 rounded-xl border border-[#2a2f3f] py-2.5 text-xs text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#c0c8d8]"
                  }
                >
                  メニュー
                </button>
              </div>
            </div>
          );
        })()}
      </div>
    </div>
  );
}
