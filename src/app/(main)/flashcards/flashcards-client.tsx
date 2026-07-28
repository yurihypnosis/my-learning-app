"use client";

import { useTermProgress, type TermRow } from "@/features/flashcards/hooks/use-term-progress";
import { useDeckFilter } from "@/features/flashcards/hooks/use-deck-filter";
import { useFlashcardSession } from "@/features/flashcards/hooks/use-flashcard-session";
import { SetupScreen } from "@/features/flashcards/screens/setup-screen";
import { SessionScreen } from "@/features/flashcards/screens/session-screen";
import { DoneScreen } from "@/features/flashcards/screens/done-screen";

export type { TermRow };

export function FlashcardsClient({
  userId,
  initialProgress,
}: {
  userId: string | null;
  initialProgress: TermRow[];
}) {
  const { store, record, logEvent } = useTermProgress({ userId, initialProgress });
  const filter = useDeckFilter({ store });
  const session = useFlashcardSession({ deckKey: filter.deck.key, record, logEvent });

  if (session.phase === "setup") {
    return <SetupScreen filter={filter} onStart={session.start} />;
  }

  if (session.phase === "done") {
    return <DoneScreen filter={filter} session={session} />;
  }

  return <SessionScreen filter={filter} session={session} />;
}
