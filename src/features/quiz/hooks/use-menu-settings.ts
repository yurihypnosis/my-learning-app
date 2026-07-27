"use client";

import { useMemo, useState } from "react";
import type { QuizMode, QuizQuestion } from "@/lib/quiz/types";
import {
  eligibleQuestions,
  getProgress,
  isResting,
  type ProgressMap,
} from "@/lib/quiz/selection";

type Params = {
  categories: { id: string; name: string; color: string }[];
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  now: number;
  // 問題集ピッカーで初期展開しておく試験（学習中の試験）
  currentExamKey: string | null;
};

// メニュー画面の出題設定（分野・問題数・モード）と、そこから決まる出題対象。
export function useMenuSettings({
  categories,
  questions,
  progressMap,
  now,
  currentExamKey,
}: Params) {
  // 問題集ピッカーは試験単位に折りたたみ、1試験だけ展開する（学習中の試験を初期展開）。
  const [expandedExam, setExpandedExam] = useState<string | null>(currentExamKey);
  const [selCats, setSelCats] = useState<Set<string>>(
    () => new Set(categories.map((c) => c.id))
  );
  const [count, setCount] = useState(10);
  const [mode, setMode] = useState<QuizMode>("shuffle");
  const [recallMode, setRecallMode] = useState(false);
  // 休眠中（復習日がまだ来ていない）の問題も出題対象に含めるか。手動復習用。
  const [includeResting, setIncludeResting] = useState(false);

  const restingCount = useMemo(
    () => questions.filter((q) => isResting(getProgress(progressMap, q.id), now)).length,
    [questions, progressMap, now]
  );

  const eligible = useMemo(
    () => eligibleQuestions(questions, progressMap, selCats, now, includeResting),
    [questions, progressMap, selCats, now, includeResting]
  );
  // 休眠を無視した出題対象。全問休眠でスタートが空のとき、脱出口を出すかの判定に使う。
  const eligibleWithResting = useMemo(
    () => eligibleQuestions(questions, progressMap, selCats, now, true),
    [questions, progressMap, selCats, now]
  );

  return {
    expandedExam,
    setExpandedExam,
    selCats,
    setSelCats,
    count,
    setCount,
    mode,
    setMode,
    recallMode,
    setRecallMode,
    includeResting,
    setIncludeResting,
    restingCount,
    eligible,
    eligibleWithResting,
  };
}
