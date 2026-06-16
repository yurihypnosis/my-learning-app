import Papa from "papaparse";
import { FLAGS, type QuizQuestion } from "./types";
import { getProgress, isResting, type ProgressMap } from "./selection";

// 問題・解答・フラグ・メモを CSV 文字列にする
export function buildCSV(
  questions: QuizQuestion[],
  progressMap: ProgressMap,
  now: number,
  onlyWithMemo = false
): string {
  const list = onlyWithMemo
    ? questions.filter((q) => getProgress(progressMap, q.id).memo.trim())
    : questions;

  const rows = list.map((q) => {
    const p = getProgress(progressMap, q.id);
    const opts = q.options;
    return {
      ID: q.source_ref ?? q.id,
      分野: q.category_name,
      問題: q.question_text,
      選択肢A: opts[0] ?? "",
      選択肢B: opts[1] ?? "",
      選択肢C: opts[2] ?? "",
      選択肢D: opts[3] ?? "",
      正解: "ABCD"[q.correct_index] ?? "",
      直近の自分の解答:
        p.last_selected_index != null ? ("ABCD"[p.last_selected_index] ?? "") : "",
      正答回数: p.correct_count,
      "誤答回数(模試含む)": q.initial_wrong_weight + p.wrong_count,
      連続正解: p.consecutive_correct,
      理解度: FLAGS[p.understanding_level] ?? FLAGS[0],
      メモ: p.memo,
      休眠中: isResting(p, now) ? "○" : "",
    };
  });

  return Papa.unparse(rows);
}

export function downloadCSV(filename: string, csv: string) {
  // UTF-8 BOM を付けて Excel で文字化けしないようにする
  const blob = new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
