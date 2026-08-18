"use client";

import { useEffect, useState } from "react";

export type Screen = "menu" | "quiz" | "done" | "analysis" | "export" | "goal";

// サイドバーから直接開ける画面だけ URL(?screen=) で指定できる。
// クイズ/結果は演習の流れの中でしか入らないので対象外。
const LINKABLE: Screen[] = ["analysis", "export", "goal"];

function toScreen(requested?: string): Screen {
  return LINKABLE.includes(requested as Screen) ? (requested as Screen) : "menu";
}

// 画面の切替と、問題集ピッカーの開閉。
// サイドバーの「ダッシュボード」からの合図で、内部画面(クイズ/分析など)を
// トップ(メニュー)へ戻す。?screen= 指定はサイドバーからの直接遷移に使う。
export function useScreen(requested?: string) {
  const [screen, setScreen] = useState<Screen>(() => toScreen(requested));

  // ?screen= が変わったとき（サイドバーから苦手分析などへ飛んだとき）に追随する。
  // 同一ルートへの soft navigation ではクライアント状態が残るので初期値だけでは足りず、
  // かといって effect で書くと余計な再描画を挟むため、描画中に調整する公式パターンを使う。
  const [seen, setSeen] = useState(requested);
  if (requested !== seen) {
    setSeen(requested);
    setScreen(toScreen(requested));
  }

  // 画面が変わったら先頭へ。表示位置の同期なので effect が正しい置き場所。
  useEffect(() => {
    window.scrollTo({ top: 0 });
  }, [screen]);

  useEffect(() => {
    const goMenu = () => setScreen("menu");
    // サイドバーから同一ページ内の画面へ移るときの合図。
    // ルート遷移を挟まないので、読み込み済みのデータでそのまま描ける。
    const goScreen = (e: Event) => {
      const s = (e as CustomEvent<string>).detail;
      if (LINKABLE.includes(s as Screen)) setScreen(s as Screen);
    };
    window.addEventListener("app:home", goMenu);
    window.addEventListener("app:screen", goScreen);
    return () => {
      window.removeEventListener("app:home", goMenu);
      window.removeEventListener("app:screen", goScreen);
    };
  }, []);

  return { screen, setScreen };
}
