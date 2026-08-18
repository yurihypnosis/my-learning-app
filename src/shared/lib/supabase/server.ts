import { cache } from "react";
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { Database } from "@/types/database";

export async function createServerSupabaseClient() {
  const cookieStore = await cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // Server Component から呼ばれた場合は middleware がセッションを更新するので無視
          }
        },
      },
    }
  );
}

// レイアウトとページの両方が同じリクエスト内でクライアントとユーザーを必要とする。
// React の cache() で1リクエスト1回に畳み、auth.getUser() の往復を重複させない。
export const getServerSupabase = cache(createServerSupabaseClient);

/**
 * ページ描画用のユーザー識別。
 *
 * getUser() は毎回 Auth サーバへ往復する（実測 60〜80ms）。このプロジェクトは
 * JWT を ES256（非対称鍵）で署名しているので、getClaims() なら JWKS を使って
 * ローカルで署名検証でき、往復が要らない（キャッシュ後 1〜2ms）。
 *
 * 「本当にログインしているか」の権威ある確認は proxy.ts の middleware が
 * 引き続き getUser() で行い、そこを通らないリクエストは無い。ここはその後段で
 * 誰のデータを読むかを決めるだけなので、ローカル検証で足りる。
 */
export const getSessionUser = cache(async () => {
  const supabase = await getServerSupabase();
  const { data } = await supabase.auth.getClaims();
  const claims = data?.claims;
  if (!claims?.sub) return null;
  return { id: claims.sub, email: (claims.email as string | undefined) ?? null };
});
