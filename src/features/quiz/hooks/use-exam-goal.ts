"use client";

import { useEffect, useState } from "react";
import type { UserGoal } from "@/features/quiz/lib/stats";
import { useSupabaseClient } from "./use-supabase-client";

type Params = {
  userId: string;
  goalExamKey: string;
  initialGoal: UserGoal | null;
};

// 試験区分ごとの試験日。サーバ(DB)由来の initialGoal を初期値にし、
// 試験区分が変わったら（別試験へ切替）サーバの新しい値へ同期する。
export function useExamGoal({ userId, goalExamKey, initialGoal }: Params) {
  const supabase = useSupabaseClient();
  const [goal, setGoal] = useState<UserGoal | null>(initialGoal);
  const [goalDraft, setGoalDraft] = useState<{ examDate: string; targetName: string }>({
    examDate: initialGoal?.examDate ?? "",
    targetName: initialGoal?.targetName ?? "",
  });

  useEffect(() => {
    // サーバから来た別試験の値へ差し替える意図的な setState。
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setGoal(initialGoal);
    setGoalDraft({
      examDate: initialGoal?.examDate ?? "",
      targetName: initialGoal?.targetName ?? "",
    });
    // 試験区分キーが変わったときだけ同期（同一試験内のセット切替では維持）。
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [goalExamKey]);

  // after: ローカル反映の直後（DB 書き込みの待ちには入らない）に呼ぶ画面遷移など。
  const saveGoal = async (after?: () => void) => {
    if (!goalDraft.examDate) return;
    const g: UserGoal = { examDate: goalDraft.examDate, targetName: goalDraft.targetName };
    setGoal(g);
    after?.();
    const { error } = await supabase.from("user_exam_goals").upsert(
      {
        user_id: userId,
        exam_key: goalExamKey,
        exam_date: g.examDate,
        target_name: g.targetName,
      },
      { onConflict: "user_id,exam_key" }
    );
    if (error) console.error("[user_exam_goals] save failed:", error.code, error.message);
  };

  const clearGoal = async (after?: () => void) => {
    setGoal(null);
    setGoalDraft({ examDate: "", targetName: "" });
    after?.();
    const { error } = await supabase
      .from("user_exam_goals")
      .delete()
      .eq("user_id", userId)
      .eq("exam_key", goalExamKey);
    if (error) console.error("[user_exam_goals] clear failed:", error.code, error.message);
  };

  return { goal, goalDraft, setGoalDraft, saveGoal, clearGoal };
}
