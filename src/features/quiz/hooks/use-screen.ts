"use client";

import { useEffect, useState } from "react";

export type Screen = "menu" | "quiz" | "done" | "analysis" | "export" | "goal" | "comprehension";

// 画面の切替と、問題集ピッカーの開閉。
// ヘッダの Home ボタンからの合図で、内部画面(クイズ/分析など)を
// トップ(メニュー)へ戻す。別ルートからの遷移は新規マウントで menu になる。
export function useScreen() {
  const [screen, setScreen] = useState<Screen>("menu");
  const [pickerOpen, setPickerOpen] = useState(false);

  useEffect(() => {
    const goMenu = () => {
      setScreen("menu");
      setPickerOpen(false);
      window.scrollTo({ top: 0 });
    };
    window.addEventListener("app:home", goMenu);
    return () => window.removeEventListener("app:home", goMenu);
  }, []);

  return { screen, setScreen, pickerOpen, setPickerOpen };
}
