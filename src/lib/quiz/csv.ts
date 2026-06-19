import Papa from "papaparse";
import type { QuizQuestion } from "./types";
import { getProgress, isResting, type ProgressMap } from "./selection";
import { questionMastery } from "./stats";

export type ExportMode = "all" | "memo" | "weak";

const CONFIDENCE_LABELS: Record<number, string> = {
  1: "確信あり",
  2: "迷った",
  3: "勘",
};

function isWeak(q: QuizQuestion, p: ReturnType<typeof getProgress>): boolean {
  // 演習実績も模試誤答もない未着手問題は除外
  if (p.correct_count + p.wrong_count === 0 && q.initial_wrong_weight === 0) return false;
  return questionMastery(q, p) < 0.5;
}

// 問題・解答・確信度・メモを CSV 文字列にする
export function buildCSV(
  questions: QuizQuestion[],
  progressMap: ProgressMap,
  now: number,
  mode: ExportMode = "all"
): string {
  const list = questions.filter((q) => {
    const p = getProgress(progressMap, q.id);
    if (mode === "memo") return p.memo.trim().length > 0;
    if (mode === "weak") return isWeak(q, p);
    return true;
  });

  const rows = list.map((q) => {
    const p = getProgress(progressMap, q.id);
    const opts = q.options;
    const mastery = Math.round(questionMastery(q, p) * 100);
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
      "習得度(%)": mastery,
      確信度: CONFIDENCE_LABELS[p.last_confidence ?? 0] ?? "未回答",
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
