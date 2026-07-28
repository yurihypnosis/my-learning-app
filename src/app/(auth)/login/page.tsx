"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/shared/lib/supabase/client";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      setError("ログインに失敗しました。メールアドレスとパスワードを確認してください。");
      setLoading(false);
      return;
    }
    router.push("/");
    router.refresh();
  };

  return (
    <div className="rounded-2xl bg-card p-7 shadow-2xl">
      <h1 className="mb-1 text-center text-xl font-extrabold text-slate-100">My Learning App</h1>
      <p className="mb-6 text-center text-xs text-muted2">ログインして学習を続ける</p>

      <form onSubmit={onSubmit} className="space-y-3">
        <input
          type="email"
          required
          autoComplete="email"
          placeholder="メールアドレス"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full rounded-xl border border-border bg-card2 px-3 py-3 text-sm text-fg outline-none focus:border-primary2"
        />
        <input
          type="password"
          required
          autoComplete="current-password"
          placeholder="パスワード"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full rounded-xl border border-border bg-card2 px-3 py-3 text-sm text-fg outline-none focus:border-primary2"
        />
        {error && <p className="text-xs text-red-400">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-3 text-sm font-bold text-white disabled:opacity-50"
        >
          {loading ? "ログイン中…" : "ログイン"}
        </button>
      </form>

      <p className="mt-5 text-center text-xs text-muted2">
        アカウントがない？{" "}
        <Link href="/register" className="font-bold text-primary2">
          新規登録
        </Link>
      </p>
    </div>
  );
}
