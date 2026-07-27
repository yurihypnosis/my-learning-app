"use client";

import { useEffect, useState } from "react";

// SSR とクライアントで時刻がずれないよう、マウント後に一度だけ現在時刻を入れる。
// 0 の間は「読み込み中」を出す合図として使う。
export function useNow(): number {
  const [now, setNow] = useState(0);
  useEffect(() => {
    // マウント後に一度だけ。ハイドレーション不一致を避けるための意図的な setState。
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setNow(Date.now());
  }, []);
  return now;
}
