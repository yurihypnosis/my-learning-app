import { categoryColor } from "@/features/flashcards/lib/flashcards";
import { wrap, container } from "@/features/flashcards/lib/constants";
import type { useDeckFilter } from "@/features/flashcards/hooks/use-deck-filter";
import type { useFlashcardSession } from "@/features/flashcards/hooks/use-flashcard-session";

interface SessionScreenProps {
  filter: ReturnType<typeof useDeckFilter>;
  session: ReturnType<typeof useFlashcardSession>;
}

export function SessionScreen({ filter, session }: SessionScreenProps) {
  const { selCat, scopeLabel } = filter;
  const { queue, idx, flipped, showPrecise, flip, togglePrecise, grade } = session;

  const card = queue[idx];
  const accent = categoryColor(card.cat);
  const progress = queue.length > 0 ? (idx / queue.length) * 100 : 0;

  return (
    <div className={wrap}>
      <div className={container}>
        {/* 進捗 */}
        <div className="mb-1 h-0.5 overflow-hidden rounded bg-[#2a2f3f]">
          <div
            className="h-full bg-[#3b82f6] transition-[width] duration-300 motion-reduce:transition-none"
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className="mb-6 flex items-center justify-between text-[11px] text-[#555e70]">
          <span className="tabular-nums">
            {idx + 1} / {queue.length}
          </span>
          <span>
            {scopeLabel}・{selCat ?? "全分野"}
          </span>
        </div>

        {/* カード（3Dフリップ） */}
        <div className="mb-6" style={{ perspective: "1600px" }}>
          <button
            onClick={() => !flipped && flip()}
            aria-label={flipped ? "答え" : "タップして意味を確認"}
            className="grid w-full text-left transition-transform duration-500 motion-reduce:transition-none"
            style={{
              transformStyle: "preserve-3d",
              transform: flipped ? "rotateY(180deg)" : "none",
              cursor: flipped ? "default" : "pointer",
            }}
          >
            {/* 2面をグリッドの同一セルに重ね、背の高い面がカード高を決める。
                こうすると「正確な定義」を開いてもカードが伸びて全文が読める。 */}
            {/* front */}
            <div
              className="flex min-h-[340px] flex-col rounded-[20px] border border-[#2a2f3f] bg-[#1a1d27] px-8 py-8"
              style={{ backfaceVisibility: "hidden", gridArea: "1 / 1" }}
            >
              <span
                className="text-[10px] font-semibold uppercase tracking-[0.16em]"
                style={{ color: accent }}
              >
                {card.cat}
              </span>
              <span
                className="my-auto font-extralight leading-tight tracking-[-0.02em] text-[#e8eaf0]"
                style={{
                  fontSize: card.term.length > 8 ? "29px" : "38px",
                  textWrap: "balance",
                }}
              >
                {card.term}
              </span>
              <span className="mt-auto text-center text-[11px] text-[#555e70]">
                タップして意味を確認
              </span>
            </div>

            {/* back — やさしく一言を先頭に */}
            <div
              className="flex min-h-[340px] flex-col rounded-[20px] border border-[#2a2f3f] bg-[#141720] px-8 py-8"
              style={{
                backfaceVisibility: "hidden",
                transform: "rotateY(180deg)",
                gridArea: "1 / 1",
              }}
            >
              <span className="text-[10px] font-semibold uppercase tracking-[0.16em] text-[#555e70]">
                {card.cat}
              </span>
              <span className="mb-5 mt-3.5 text-[15px] font-semibold text-[#e8eaf0]">
                {card.term}
              </span>
              <p
                className="text-[19px] font-normal leading-[1.7] tracking-[-0.01em] text-[#e8eaf0]"
                style={{ textWrap: "balance" }}
              >
                {card.gist}
              </p>
              {card.eg && (
                <div
                  className="mt-[18px] border-l-2 pl-3"
                  style={{ borderColor: "rgba(96,165,250,0.4)" }}
                >
                  <span className="mb-1.5 block text-[10px] font-semibold uppercase tracking-[0.14em] text-[#60a5fa]">
                    たとえると
                  </span>
                  <span className="text-[13.5px] leading-[1.7] text-[#8892a4]">
                    {card.eg}
                  </span>
                </div>
              )}
              {card.use && (
                <div className="mt-[18px]">
                  <span className="mb-1.5 block text-[10px] font-semibold uppercase tracking-[0.14em] text-[#7d8798]">
                    使いどころ
                  </span>
                  <span className="text-[13.5px] leading-[1.7] text-[#8892a4]">
                    {card.use}
                  </span>
                </div>
              )}

              <div className="mt-auto pt-4">
                <span
                  role="button"
                  tabIndex={0}
                  onClick={(e) => {
                    e.stopPropagation();
                    togglePrecise();
                  }}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" || e.code === "Space") {
                      e.preventDefault();
                      e.stopPropagation();
                      togglePrecise();
                    }
                  }}
                  className="inline-flex cursor-pointer items-center gap-1.5 text-[11px] text-[#555e70] transition hover:text-[#8892a4]"
                >
                  <svg
                    width="8"
                    height="8"
                    viewBox="0 0 10 10"
                    fill="none"
                    className="transition-transform"
                    style={{ transform: showPrecise ? "rotate(90deg)" : "none" }}
                  >
                    <path
                      d="M3.5 2L6.5 5L3.5 8"
                      stroke="currentColor"
                      strokeWidth="1.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                  正確な定義
                </span>
                {showPrecise && (
                  <p className="mt-2 text-[12.5px] leading-[1.75] text-[#555e70]">
                    {card.precise}
                  </p>
                )}
                <p className="mt-3 border-t border-[#2a2f3f] pt-3 text-[11px] text-[#555e70]">
                  {card.src}
                </p>
              </div>
            </div>
          </button>
        </div>

        {/* 自己採点 */}
        {flipped ? (
          <div className="flex gap-2.5">
            <button
              onClick={() => grade(false)}
              className="flex-1 rounded-xl border border-[#2a2f3f] py-3.5 text-sm text-[#8892a4] transition hover:border-[#d0a45c] hover:bg-[#d0a45c12] hover:text-[#d0a45c]"
            >
              あやしい
            </button>
            <button
              onClick={() => grade(true)}
              className="flex-1 rounded-xl border border-[#2a2f3f] py-3.5 text-sm text-[#8892a4] transition hover:border-[#6ab08d] hover:bg-[#6ab08d12] hover:text-[#6ab08d]"
            >
              覚えていた
            </button>
          </div>
        ) : (
          <p className="py-3.5 text-center text-xs text-[#555e70]">
            思い出せたか、自分に正直に
          </p>
        )}
      </div>
    </div>
  );
}
