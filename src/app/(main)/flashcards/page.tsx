import { createServerSupabaseClient } from "@/shared/lib/supabase/server";
import { FlashcardsClient, type TermRow } from "./flashcards-client";

export const dynamic = "force-dynamic";

export default async function FlashcardsPage() {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  let initialProgress: TermRow[] = [];
  if (user) {
    const { data } = await supabase
      .from("user_term_progress")
      .select("deck_key, term, result, known_count, weak_count")
      .eq("user_id", user.id);
    initialProgress = (data ?? []) as TermRow[];
  }

  return (
    <FlashcardsClient userId={user?.id ?? null} initialProgress={initialProgress} />
  );
}
