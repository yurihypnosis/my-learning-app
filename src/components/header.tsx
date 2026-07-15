"use client";

import { useRouter } from "next/navigation";
import { Home, LogOut } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export function Header({ email }: { email: string | null }) {
  const router = useRouter();

  // どのページ・どの内部画面からでもトップ(/)へ戻る。
  // router.push は別ルートからの遷移を担い、"app:home" イベントは
  // 同一ルート(/)のサブ画面(クイズ/分析など)にリセットを伝える。
  const goHome = () => {
    if (typeof window !== "undefined") {
      window.dispatchEvent(new Event("app:home"));
    }
    router.push("/");
  };

  const logout = async () => {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  };

  return (
    <header className="sticky top-0 z-10 flex h-12 items-center justify-between border-b border-[#2a2f3f] bg-[#0f1117]/90 px-4 backdrop-blur">
      <button
        onClick={goHome}
        aria-label="ホームへ戻る"
        className="flex items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-semibold tracking-wide text-[#8892a4] transition hover:text-white"
      >
        <Home size={13} />
        <span>LEARNING</span>
      </button>
      <div className="flex items-center gap-3">
        {email && (
          <span className="hidden text-[11px] text-[#555e70] sm:inline">{email}</span>
        )}
        <button
          onClick={logout}
          className="flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-[11px] text-[#555e70] transition hover:text-[#8892a4]"
        >
          <LogOut size={12} />
          ログアウト
        </button>
      </div>
    </header>
  );
}
