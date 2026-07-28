"use client";

import { useMemo } from "react";
import { createClient } from "@/shared/lib/supabase/client";

// 画面内の複数 hook から使うが、ブラウザクライアントは 1 つで足りる。
let cached: ReturnType<typeof createClient> | null = null;

export function useSupabaseClient() {
  return useMemo(() => (cached ??= createClient()), []);
}
