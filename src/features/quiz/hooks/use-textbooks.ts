"use client";

import { useEffect, useState } from "react";
import type { Textbook } from "@/features/quiz/lib/stats";
import { useSupabaseClient } from "./use-supabase-client";

type Params = {
  userId: string;
  goalExamKey: string;
  initialTextbooks: Textbook[];
};

// 試験区分ごとの教科書リンク CRUD（楽観的更新）。
// goal と同様、区分が変わったらサーバの新しい値へ同期する。
export function useTextbooks({ userId, goalExamKey, initialTextbooks }: Params) {
  const supabase = useSupabaseClient();
  const [textbooks, setTextbooks] = useState<Textbook[]>(initialTextbooks);
  const [tbEditing, setTbEditing] = useState(false);
  const [tbDraft, setTbDraft] = useState<{ label: string; url: string }>({ label: "", url: "" });
  const [tbError, setTbError] = useState<string | null>(null);

  useEffect(() => {
    // サーバから来た別試験の値へ差し替える意図的な setState。
    /* eslint-disable react-hooks/set-state-in-effect */
    setTextbooks(initialTextbooks);
    setTbEditing(false);
    setTbDraft({ label: "", url: "" });
    setTbError(null);
    /* eslint-enable react-hooks/set-state-in-effect */
    // 試験区分キーが変わったときだけ同期（同一試験内のセット切替では維持）。
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [goalExamKey]);

  const addTextbook = async () => {
    const url = tbDraft.url.trim();
    const label = tbDraft.label.trim();
    if (!/^https?:\/\//i.test(url)) {
      setTbError("URL は http:// または https:// で始めてください");
      return;
    }
    const id = crypto.randomUUID();
    setTextbooks((list) => [...list, { id, label, url }]);
    setTbDraft({ label: "", url: "" });
    setTbError(null);
    const { error } = await supabase.from("user_textbooks").insert({
      id,
      user_id: userId,
      exam_key: goalExamKey,
      label,
      url,
      sort_order: textbooks.length,
    });
    if (error) {
      console.error("[user_textbooks] add failed:", error.code, error.message);
      setTextbooks((list) => list.filter((t) => t.id !== id)); // ロールバック
      setTbError("保存に失敗しました");
    }
  };

  const deleteTextbook = async (id: string) => {
    const prev = textbooks;
    setTextbooks((list) => list.filter((t) => t.id !== id));
    const { error } = await supabase
      .from("user_textbooks")
      .delete()
      .eq("user_id", userId)
      .eq("id", id);
    if (error) {
      console.error("[user_textbooks] delete failed:", error.code, error.message);
      setTextbooks(prev); // ロールバック
    }
  };

  return {
    textbooks,
    tbEditing,
    setTbEditing,
    tbDraft,
    setTbDraft,
    tbError,
    setTbError,
    addTextbook,
    deleteTextbook,
  };
}
