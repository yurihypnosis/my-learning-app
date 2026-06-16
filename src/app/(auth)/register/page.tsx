"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";

export default function RegisterPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setMessage("");
    if (password.length < 6) {
      setError("パスワードは6文字以上にしてください。");
      return;
    }
    setLoading(true);
    const supabase = createClient();
    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) {
      setError("登録に失敗しました: " + error.message);
      setLoading(false);
      return;
    }
    // メール確認が無効ならセッションが張られるのでそのまま遷移
    if (data.session) {
      router.push("/");
      router.refresh();
      return;
    }
    setMessage("確認メールを送信しました。メール内のリンクから認証後にログインしてください。");
    setLoading(false);
  };

  return (
    <div className="rounded-2xl bg-card p-7 shadow-2xl">
      <h1 className="mb-1 text-center text-xl font-extrabold text-slate-100">新規登録</h1>
      <p className="mb-6 text-center text-xs text-muted2">アカウントを作成して学習を始める</p>

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
          autoComplete="new-password"
          placeholder="パスワード（6文字以上）"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full rounded-xl border border-border bg-card2 px-3 py-3 text-sm text-fg outline-none focus:border-primary2"
        />
        {error && <p className="text-xs text-red-400">{error}</p>}
        {message && <p className="text-xs text-emerald-300">{message}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-xl bg-gradient-to-br from-primary to-primary2 py-3 text-sm font-bold text-white disabled:opacity-50"
        >
          {loading ? "登録中…" : "登録"}
        </button>
      </form>

      <p className="mt-5 text-center text-xs text-muted2">
        すでにアカウントがある？{" "}
        <Link href="/login" className="font-bold text-primary2">
          ログイン
        </Link>
      </p>
    </div>
  );
}
