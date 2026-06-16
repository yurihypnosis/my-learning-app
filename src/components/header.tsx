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
    <header className="sticky top-0 z-10 flex items-center justify-between border-b border-border/60 bg-bg/80 px-4 py-3 backdrop-blur">
      <span className="text-sm font-extrabold text-slate-100">My Learning App</span>
      <div className="flex items-center gap-3">
        {email && <span className="hidden text-xs text-muted2 sm:inline">{email}</span>}
        <button
          onClick={logout}
          className="flex items-center gap-1 rounded-lg bg-card2 px-3 py-1.5 text-xs font-bold text-muted hover:text-fg"
        >
          <LogOut size={13} /> ログアウト
        </button>
      </div>
    </header>
  );
}
