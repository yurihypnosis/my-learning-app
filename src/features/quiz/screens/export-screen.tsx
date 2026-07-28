import { getProgress, type ProgressMap } from "@/features/quiz/lib/selection";
import { downloadCSV, type ExportMode } from "@/features/quiz/lib/csv";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { type Screen } from "@/features/quiz/hooks/use-screen";
import { useCsvExport } from "@/features/quiz/hooks/use-csv-export";

interface ExportScreenProps {
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  currentSubjectSlug: string;
  csv: ReturnType<typeof useCsvExport>;
  setScreen: (s: Screen) => void;
}

export function ExportScreen({
  questions,
  progressMap,
  currentSubjectSlug,
  csv,
  setScreen,
}: ExportScreenProps) {
  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

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
            const on = csv.exportMode === key;
            return (
              <button
                key={key}
                onClick={() => csv.rebuild(key)}
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

        {csv.exportMode === "weak" && weakCount === 0 && (
          <div className="mb-5 rounded-xl border border-[#0a2a1a] bg-[#061510] p-4 text-center">
            <p className="text-sm text-[#22c55e]">苦手問題なし</p>
            <p className="text-xs text-[#1a5a2a]">習得度 50% 以上の問題のみです</p>
          </div>
        )}

        <button
          onClick={() => downloadCSV(`${currentSubjectSlug}-${csv.exportMode}.csv`, csv.csvText)}
          className="mb-2 w-full rounded-xl bg-[#3b82f6] py-3.5 text-sm font-medium text-white transition hover:bg-[#60a5fa]"
        >
          ダウンロード
        </button>
        <button
          onClick={csv.copyToClipboard}
          className="mb-2 w-full rounded-xl border border-[#2a2f3f] py-3 text-sm text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#c0c8d8]"
        >
          クリップボードにコピー
        </button>
        {csv.copyMsg && (
          <p className="mb-3 text-center text-xs text-[#8892a4]">{csv.copyMsg}</p>
        )}

        <textarea
          readOnly
          value={csv.csvText}
          onFocus={(e) => e.target.select()}
          className="mb-4 min-h-[180px] w-full resize-y overflow-x-auto rounded-xl border border-[#2a2f3f] bg-[#141720] px-3 py-2.5 font-mono text-[11px] text-[#8892a4]"
        />
      </div>
    </div>
  );
}
