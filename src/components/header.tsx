"use client";

import { useRouter } from "next/navigation";
import { LogOut } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export function Header({ email }: { email: string | null }) {
  const router = useRouter();

  const logout = async () => {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  };

  return (
    <header className="sticky top-0 z-10 flex h-12 items-center justify-between border-b border-[#1a1a1a] bg-[#0a0a0a]/90 px-4 backdrop-blur">
      <span className="text-xs font-semibold tracking-wide text-[#444]">LEARNING</span>
      <div className="flex items-center gap-3">
        {email && (
          <span className="hidden text-[11px] text-[#333] sm:inline">{email}</span>
        )}
        <button
          onClick={logout}
          className="flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-[11px] text-[#444] transition hover:text-[#888]"
        >
          <LogOut size={12} />
          ログアウト
        </button>
      </div>
    </header>
  );
}
