import { lbl, wrap, container, MASTERED, WEAK } from "@/features/flashcards/lib/constants";
import type { useDeckFilter } from "@/features/flashcards/hooks/use-deck-filter";
import type { useFlashcardSession } from "@/features/flashcards/hooks/use-flashcard-session";

interface DoneScreenProps {
  filter: ReturnType<typeof useDeckFilter>;
  session: ReturnType<typeof useFlashcardSession>;
}

export function DoneScreen({ filter, session }: DoneScreenProps) {
  const { selCat, counts } = filter;
  const { known, weakCards, masteredAtStart, repeatWeak, backToSetup } = session;

  const weak = weakCards.length;
  const gained = Math.max(0, counts.mastered - masteredAtStart);

  return (
    <div className={wrap}>
      <div className={container}>
        <div className="pt-6 text-center">
          <p className={`mb-4 ${lbl}`}>学習の定着{selCat ? `（${selCat}）` : ""}</p>
          <div className="text-[52px] font-extralight leading-none tracking-[-0.03em] tabular-nums text-[#e8eaf0]">
            {counts.mastered}
            <span className="font-thin text-[#555e70]"> / {counts.total}</span>
          </div>
          <p className="mt-2 text-xs text-[#555e70]">
            語 定着
            {gained > 0 && (
              <span style={{ color: MASTERED }}> ・ 今回 +{gained}</span>
            )}
          </p>

          <div className="my-8 flex justify-center gap-8">
            <div className="text-center">
              <div className="text-2xl font-light tabular-nums" style={{ color: MASTERED }}>
                {known}
              </div>
              <div className="mt-1 text-[11px] text-[#555e70]">覚えていた</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-light tabular-nums" style={{ color: WEAK }}>
                {weak}
              </div>
              <div className="mt-1 text-[11px] text-[#555e70]">あやしい</div>
            </div>
          </div>

          {weak > 0 && (
            <button
              onClick={() => repeatWeak(counts.mastered)}
              className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
            >
              あやしい {weak} 語をもう一周
            </button>
          )}
          <button
            onClick={backToSetup}
            className="mt-2.5 w-full rounded-xl border border-[#2a2f3f] py-4 text-sm font-medium text-[#8892a4] transition hover:border-[#3a4050] hover:text-[#e8eaf0]"
          >
            メニューに戻る
          </button>
        </div>
      </div>
    </div>
  );
}
