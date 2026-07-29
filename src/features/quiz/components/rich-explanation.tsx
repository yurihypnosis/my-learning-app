import { type ExplanationData } from "@/features/quiz/lib/types";

export function RichExplanation({ data }: { data: ExplanationData }) {
  const lbl = "mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]";
  return (
    <div className="space-y-5 text-sm leading-7 text-[#c0c8d8]">
      <div>
        <p className={lbl}>何を問われているか</p>
        <p>{data.asked}</p>
      </div>

      {data.point && (
        <div className="border-l-2 border-[#3b82f6]/60 pl-3.5">
          <p className={lbl}>決め手</p>
          <p className="text-[15px] text-[#e8eaf0]">{data.point}</p>
        </div>
      )}

      {data.kid && (
        <div>
          <p className={lbl}>ざっくり言うと</p>
          <p>{data.kid}</p>
        </div>
      )}

      {data.eg && (
        <div>
          <p className={lbl}>たとえると</p>
          <p>{data.eg}</p>
        </div>
      )}

      {data.viz && (
        <div>
          <p className={lbl}>図で見る</p>
          <div
            className="overflow-x-auto rounded-xl bg-[#141720] px-4 py-4 [&_svg]:h-auto [&_svg]:w-full [&_svg]:max-w-[420px]"
            dangerouslySetInnerHTML={{ __html: data.viz }}
          />
        </div>
      )}

      {data.terms && data.terms.length > 0 && (
        <div>
          <p className={lbl}>キーワード</p>
          <div className="space-y-2">
            {data.terms.map(([term, def], i) => (
              <div key={i} className="flex flex-wrap gap-x-2">
                <span className="font-semibold text-[#e8eaf0]">{term}</span>
                <span className="text-[#8892a4]">—</span>
                <span className="text-[#8892a4]">{def}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div>
        <p className={lbl}>考え方</p>
        <p>{data.think}</p>
      </div>

      {data.snippet && (
        <div>
          <p className={lbl}>正しい書き方</p>
          <pre className="overflow-x-auto rounded-xl bg-[#141720] px-4 py-3.5 font-mono text-xs leading-6 text-[#8892a4]">
            <code>{data.snippet}</code>
          </pre>
        </div>
      )}

      {data.vs && (
        <div>
          <p className={lbl}>混同ポイント</p>
          <p>{data.vs}</p>
        </div>
      )}

      {data.why_asked && (
        <div>
          <p className={lbl}>なぜ問われるか</p>
          <p>{data.why_asked}</p>
        </div>
      )}

      {data.usecase && (
        <div className="rounded-xl border border-[#1e2530] bg-[#12151d] px-4 py-3">
          <p className={lbl}>使いどころ・どう役立つか</p>
          <p>{data.usecase}</p>
        </div>
      )}

      {data.opt && data.opt.length > 0 && (
        <div>
          <p className={lbl}>選択肢の解説</p>
          <div className="space-y-2">
            {data.opt.map((o, i) => (
              <div key={i} className="flex gap-3">
                <span className="w-4 shrink-0 font-semibold text-[#555e70]">{"ABCD"[i]}.</span>
                <span>{o}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
