"use client";

import { useMemo, useState } from "react";
import type { QuizQuestion } from "@/features/quiz/lib/types";
import type { ProgressMap } from "@/features/quiz/lib/selection";
import { buildCSV, type ExportMode } from "@/features/quiz/lib/csv";

type Params = {
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  now: number;
  // 書き出し画面を開いているときだけ CSV を組み立てる。
  enabled: boolean;
};

// 書き出し画面の表示状態（対象モード・生成済み CSV・コピー結果）。
export function useCsvExport({ questions, progressMap, now, enabled }: Params) {
  const [exportMode, setExportMode] = useState<ExportMode>("weak");
  const [copyMsg, setCopyMsg] = useState("");

  // CSV は状態ではなく導出値にする。以前は refresh() を呼び忘れると
  // 画面が空のままになっていた（サイドバーから直接開いた場合など）。
  const csvText = useMemo(
    () => (enabled ? buildCSV(questions, progressMap, now, exportMode) : ""),
    [enabled, questions, progressMap, now, exportMode]
  );

  // 対象モードを切り替える（CSV は上の useMemo が作り直す）
  const rebuild = (m: ExportMode) => {
    setExportMode(m);
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

  return { csvText, exportMode, copyMsg, rebuild, copyToClipboard };
}
