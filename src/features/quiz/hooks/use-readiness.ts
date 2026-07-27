"use client";

import { useMemo } from "react";
import type { QuizQuestion } from "@/lib/quiz/types";
import { getProgress, type ProgressMap } from "@/lib/quiz/selection";
import type { SectionQuestionRef, UserGoal } from "@/lib/quiz/stats";
import {
  type Readiness,
  computeReadiness,
  estimatePassProbability,
  examItemProb,
  passLineFor,
  retentionEstimate,
} from "@/lib/quiz/readiness";

function daysUntilDate(dateStr: string, nowMs: number): number {
  const target = new Date(dateStr + "T00:00:00");
  if (Number.isNaN(target.getTime())) return 0;
  const today = new Date(nowMs);
  today.setHours(0, 0, 0, 0);
  return Math.round((target.getTime() - today.getTime()) / 86_400_000);
}

type Params = {
  examSections: SectionQuestionRef[];
  examQuestions: QuizQuestion[];
  progressMap: ProgressMap;
  goal: UserGoal | null;
  now: number;
  dailyCapacity: number;
  goalExamKey: string;
};

// 合格ナビの派生値（state は持たない）。
export function useReadiness({
  examSections,
  examQuestions,
  progressMap,
  goal,
  now,
  dailyCapacity,
  goalExamKey,
}: Params) {
  // 合格ナビ: 試験全体（examSections=全Set）× 定着度 × 試験日 から着地予測。
  const readiness = useMemo<Readiness | null>(() => {
    if (now === 0 || examSections.length === 0) return null;
    const ids = [...new Set(examSections.map((s) => s.id))];
    const retentions = ids.map((id) => retentionEstimate(getProgress(progressMap, id), now));
    const attempted = ids.reduce((n, id) => {
      const p = getProgress(progressMap, id);
      return n + (p.correct_count + p.wrong_count > 0 ? 1 : 0);
    }, 0);
    const daysLeft = goal?.examDate ? daysUntilDate(goal.examDate, now) : null;
    return computeReadiness({
      retentions,
      total: ids.length,
      attempted,
      daysLeft,
      capacity: dailyCapacity,
      passLine: passLineFor(goalExamKey),
    });
  }, [examSections, progressMap, goal, now, dailyCapacity, goalExamKey]);

  // 本日時点の合格確率（ポアソン二項）。試験区分の全問を per-item 正答確率にし、
  // 未見問題は「その分野の能力」で汎化予測 → 正答数が合格ラインを超える確率。
  const passEstimate = useMemo(() => {
    if (now === 0 || examQuestions.length === 0) return null;
    const items = examQuestions.map((q) => {
      const guess = 1 / Math.max(2, q.options.length);
      return {
        prob: examItemProb(getProgress(progressMap, q.id), now, guess),
        guess,
        category: q.category_name,
      };
    });
    return estimatePassProbability(items, passLineFor(goalExamKey));
  }, [examQuestions, progressMap, now, goalExamKey]);

  return { readiness, passEstimate };
}
