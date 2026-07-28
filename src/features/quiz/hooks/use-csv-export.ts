"use client";

import { useState } from "react";
import type { QuizQuestion } from "@/features/quiz/lib/types";
import type { ProgressMap } from "@/features/quiz/lib/selection";
import { buildCSV, type ExportMode } from "@/features/quiz/lib/csv";

type Params = {
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  now: number;
};

// 書き出し画面の表示状態（対象モード・生成済み CSV・コピー結果）。
export function useCsvExport({ questions, progressMap, now }: Params) {
  const [csvText, setCsvText] = useState("");
  const [exportMode, setExportMode] = useState<ExportMode>("weak");
  const [copyMsg, setCopyMsg] = useState("");

  // 現在の対象モードで作り直す（書き出し画面を開くとき）
  const refresh = () => {
    setCsvText(buildCSV(questions, progressMap, now, exportMode));
    setCopyMsg("");
  };

  // 対象モードを切り替えて作り直す
  const rebuild = (m: ExportMode) => {
    setExportMode(m);
    setCsvText(buildCSV(questions, progressMap, now, m));
    setCopyMsg("");
  };

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(csvText);
      setCopyMsg("コピーしました");
    } catch {
      setCopyMsg("コピー不可 — テキストを手動で選択してください");
    }
  };

  return { csvText, exportMode, copyMsg, refresh, rebuild, copyToClipboard };
}
