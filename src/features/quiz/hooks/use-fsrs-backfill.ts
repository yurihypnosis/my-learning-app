"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

// 過去の解答から FSRS 状態を一括再構築（合格ナビ/復習間隔を正確化）
export function useFsrsBackfill() {
  const router = useRouter();
  const [backfilling, setBackfilling] = useState(false);
  const [backfillMsg, setBackfillMsg] = useState("");

  const runBackfill = async () => {
    setBackfilling(true);
    setBackfillMsg("");
    try {
      const res = await fetch("/api/fsrs/backfill", { method: "POST" });
      const j = await res.json();
      if (!res.ok) throw new Error(j.error || "失敗");
      setBackfillMsg(`${j.updated} 問を過去の解答から再構築しました`);
      router.refresh();
    } catch (e) {
      setBackfillMsg("再構築に失敗しました: " + (e as Error).message);
    } finally {
      setBackfilling(false);
    }
  };

  return { backfilling, backfillMsg, runBackfill };
}
