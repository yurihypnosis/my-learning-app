import { type UserGoal } from "@/features/quiz/lib/stats";
import { type Screen } from "@/features/quiz/hooks/use-screen";

interface GoalScreenProps {
  examName: string;
  goal: UserGoal | null;
  goalDraft: { examDate: string; targetName: string };
  setGoalDraft: React.Dispatch<React.SetStateAction<{ examDate: string; targetName: string }>>;
  saveGoal: (after?: () => void) => void;
  clearGoal: (after?: () => void) => void;
  setScreen: (s: Screen) => void;
}

export function GoalScreen({
  examName,
  goal,
  goalDraft,
  setGoalDraft,
  saveGoal,
  clearGoal,
  setScreen,
}: GoalScreenProps) {
  const wrap = "flex flex-col items-center pb-16";
  const container = "w-full max-w-[560px]";

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
          placeholder={`例: ${examName} 合格`}
          className="mb-6 w-full rounded-xl border border-[#2a2f3f] bg-[#1a1d27] px-4 py-3 text-sm text-white outline-none placeholder:text-[#555e70] focus:border-[#3b82f6] transition-colors"
        />

        <button
          onClick={() => saveGoal(() => setScreen("menu"))}
          disabled={!goalDraft.examDate}
          className="mb-2 w-full rounded-xl bg-[#3b82f6] py-3 text-sm font-medium text-white transition hover:bg-[#60a5fa] disabled:bg-[#1a1d27] disabled:text-[#555e70]"
        >
          保存
        </button>
        {goal && (
          <button
            onClick={() => clearGoal(() => setScreen("menu"))}
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
