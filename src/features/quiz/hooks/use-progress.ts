"use client";

import { useState } from "react";
import type { Progress, QuizQuestion } from "@/features/quiz/lib/types";
import { getProgress, type ProgressMap } from "@/features/quiz/lib/selection";
import { useSupabaseClient } from "./use-supabase-client";

type Params = {
  userId: string;
  initialProgress: ProgressMap;
  // 横断デッキでは問題ごとに由来セットが違うため、id → slug の対応を持つ。
  examQuestionSlug: Record<string, string>;
  currentSubjectSlug: string;
};

// 解答進捗（メモリ上の ProgressMap）と、その DB 書き込みを担う。
export function useProgress({
  userId,
  initialProgress,
  examQuestionSlug,
  currentSubjectSlug,
}: Params) {
  const supabase = useSupabaseClient();
  const [progressMap, setProgressMap] = useState<ProgressMap>(initialProgress);

  const recordAnswer = (q: QuizQuestion, isCorrect: boolean, conf: number | null) => {
    supabase.from("answer_events").insert({
      user_id: userId,
      question_id: q.id,
      category_id: q.category_id,
      category_name: q.category_name,
      category_color: q.category_color,
      subject_slug: examQuestionSlug[q.id] ?? currentSubjectSlug,
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

    // 1) 中核カラム（必ず保存する。ここは常に成功させたい）
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
        excluded: next.excluded,
      },
      { onConflict: "user_id,question_id" }
    );
    if (error) console.error("save failed", error);

    // 2) FSRS カラム（解答時のみ・別クエリ）。列が無い環境ではここだけ失敗し、
    //    中核の保存は守られる（マイグレーション適用前にデプロイしても壊れない）。
    if (partial.fsrs_state !== undefined) {
      const { error: e2 } = await supabase
        .from("user_question_progress")
        .update({
          fsrs_stability: next.fsrs_stability ?? null,
          fsrs_difficulty: next.fsrs_difficulty ?? null,
          fsrs_due: next.fsrs_due ?? null,
          fsrs_last_review: next.fsrs_last_review ?? null,
          fsrs_reps: next.fsrs_reps ?? 0,
          fsrs_lapses: next.fsrs_lapses ?? 0,
          fsrs_state: next.fsrs_state ?? "new",
        })
        .eq("user_id", userId)
        .eq("question_id", qid);
      if (e2) console.error("[fsrs] save skipped:", e2.code, e2.message);
    }

    // 3) Speak-First の口頭産出フラグ（別クエリ）。FSRS と同じく、列が無い環境でも
    //    中核の保存は守られる。
    if (partial.last_spoken_ok !== undefined) {
      const { error: e3 } = await supabase
        .from("user_question_progress")
        .update({ last_spoken_ok: next.last_spoken_ok ?? null })
        .eq("user_id", userId)
        .eq("question_id", qid);
      if (e3) console.error("[speak] save skipped:", e3.code, e3.message);
    }
  };

  return { progressMap, persist, recordAnswer };
}

export type PersistFn = ReturnType<typeof useProgress>["persist"];
export type RecordAnswerFn = ReturnType<typeof useProgress>["recordAnswer"];
