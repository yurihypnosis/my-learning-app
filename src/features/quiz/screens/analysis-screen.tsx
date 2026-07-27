import { getProgress, totalCorrect, totalWrong, type ProgressMap } from "@/lib/quiz/selection";
import {
  type ExamGroup,
  type SectionQuestionRef,
  analyzeSections,
  sectionOverview,
  weakReviewPool,
} from "@/lib/quiz/stats";
import { type QuizQuestion } from "@/lib/quiz/types";
import { type Screen } from "@/features/quiz/hooks/use-screen";
import { CONFIDENCE_COLORS, CONFIDENCE_LABELS } from "@/features/quiz/lib/constants";

interface AnalysisScreenProps {
  examSections: SectionQuestionRef[];
  progressMap: ProgressMap;
  examGroups: ExamGroup[];
  currentExamKey: string | null;
  subjectName: string;
  examQuestions: QuizQuestion[];
  examQuestionSlug: Record<string, string>;
  isMultiSet: boolean;
  expandedSection: string | null;
  setExpandedSection: (name: string | null) => void;
  startReview: (qs: QuizQuestion[]) => void;
  backfilling: boolean;
  backfillMsg: string;
  runBackfill: () => void;
  setScreen: (s: Screen) => void;
}

export function AnalysisScreen({
  examSections,
  progressMap,
  examGroups,
  currentExamKey,
  subjectName,
  examQuestions,
  examQuestionSlug,
  isMultiSet,
  expandedSection,
  setExpandedSection,
  startReview,
  backfilling,
  backfillMsg,
  runBackfill,
  setScreen,
}: AnalysisScreenProps) {
  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  // 試験全体（全Set合算）の分野別分析
  const sections = analyzeSections(examSections, progressMap);
  const overview = sectionOverview(sections);
  const examName =
    examGroups.find((g) => g.examKey === currentExamKey)?.examName ?? subjectName;
  const setNameOf = new Map(examGroups.flatMap((g) => g.sets).map((s) => [s.slug, s.name]));
  const shortSet = (slug: string): string => {
    const n = setNameOf.get(slug) ?? slug;
    const s = n.replace(examName, "").replace(/[（()）]/g, "").trim();
    return s || n;
  };
  // 弱点順に並べる: 演習済みは習熟度が低い順、未着手は末尾
  const ranked = [...sections].sort((a, b) => {
    const aa = a.attempted > 0;
    const bb = b.attempted > 0;
    if (aa !== bb) return aa ? -1 : 1;
    if (aa) return a.mastery - b.mastery;
    return a.sort - b.sort;
  });
  const secColor = (pct: number, attempted: number): string =>
    attempted === 0 ? "#555e70" : pct >= 70 ? "#22c55e" : pct >= 40 ? "#f59e0b" : "#ef4444";
  const overPct = Math.round(overview.mastery * 100);

  // 弱点問題（試験区分の全セット横断・弱点順に上位8問）
  const worst = weakReviewPool(examQuestions, progressMap, { limit: 8 });

  // 確信度キャリブレーション（直近の解答: 自信度 × 正誤・全セット横断）。
  // 「自信あり」なのに誤答 = 思い込みの危険ゾーン（最優先で復習すべき）。
  const cal = { sureCorrect: 0, sureWrong: 0, unsureCorrect: 0, unsureWrong: 0 };
  const dangerQs: QuizQuestion[] = [];
  for (const q of examQuestions) {
    const p = getProgress(progressMap, q.id);
    if (p.last_confidence === null || p.last_is_correct === null) continue;
    const sure = p.last_confidence === 1;
    if (p.last_is_correct) sure ? cal.sureCorrect++ : cal.unsureCorrect++;
    else if (sure) {
      cal.sureWrong++;
      dangerQs.push(q);
    } else cal.unsureWrong++;
  }

  return (
    <div className={wrap}>
      <div className={container}>
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-sm font-semibold text-white">苦手分析</h1>
          <button
            onClick={() => setScreen("menu")}
            className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
          >
            ← 戻る
          </button>
        </div>

        {/* 試験全体サマリ（全Set合算） */}
        <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-4">
          <div className="mb-3 flex items-end justify-between gap-3">
            <div className="min-w-0">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
                試験全体
              </p>
              <p className="truncate text-sm font-medium text-white">{examName}</p>
            </div>
            <p
              className="shrink-0 text-3xl font-bold tabular-nums"
              style={{ color: secColor(overPct, overview.attempted) }}
            >
              {overview.attempted === 0 ? "—" : `${overPct}%`}
            </p>
          </div>
          <div className="mb-3 h-1.5 overflow-hidden rounded-full bg-[#2a2f3f]">
            <div
              className="h-full rounded-full transition-all"
              style={{
                width: `${overview.attempted === 0 ? 0 : overPct}%`,
                background: secColor(overPct, overview.attempted),
              }}
            />
          </div>
          <div className="flex flex-wrap gap-4 text-xs text-[#555e70]">
            <span>
              カバー {Math.round(overview.coverage * 100)}%（{overview.attempted}/{overview.total}）
            </span>
            <span>分野 {overview.sectionCount}</span>
            {overview.weakSections > 0 && (
              <span className="text-[#ef4444]">弱点分野 {overview.weakSections}</span>
            )}
          </div>
        </div>

        {/* 分野別 苦手マップ（弱点順・全Set合算・タップでSet別内訳） */}
        <div className="mb-3 flex items-baseline justify-between">
          <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            分野別 苦手マップ
          </p>
          <span className="text-[10px] text-[#3a4050]">弱点が上・タップでSet別内訳</span>
        </div>
        <div className="mb-6 space-y-2">
          {ranked.length === 0 && (
            <p className="text-xs text-[#555e70]">まだデータがありません</p>
          )}
          {ranked.map((sec) => {
            const pct = Math.round(sec.mastery * 100);
            const open = expandedSection === sec.name;
            const color = secColor(pct, sec.attempted);
            return (
              <div key={sec.name} className="rounded-xl border border-[#2a2f3f] bg-[#141720] p-3.5">
                <button
                  onClick={() => setExpandedSection(open ? null : sec.name)}
                  className="w-full text-left"
                >
                  <div className="mb-2 flex items-center justify-between gap-2">
                    <div className="flex min-w-0 items-center gap-2">
                      <svg
                        width="8"
                        height="8"
                        viewBox="0 0 10 10"
                        fill="none"
                        className="shrink-0 transition-transform"
                        style={{ transform: open ? "rotate(90deg)" : "none", color: "#555e70" }}
                      >
                        <path d="M3.5 2L6.5 5L3.5 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                      <span className="h-2 w-2 shrink-0 rounded-full" style={{ background: sec.color }} />
                      <span className="truncate text-xs font-medium text-[#c0c8d8]">{sec.name}</span>
                    </div>
                    <div className="flex shrink-0 items-center gap-3 text-[10px] text-[#555e70]">
                      <span>{sec.attempted}/{sec.total}</span>
                      <span className="w-9 text-right font-semibold" style={{ color }}>
                        {sec.attempted === 0 ? "未着" : `${pct}%`}
                      </span>
                    </div>
                  </div>
                  <div className="h-1.5 overflow-hidden rounded-full bg-[#2a2f3f]">
                    <div
                      className="h-full rounded-full transition-all"
                      style={{ width: `${sec.attempted === 0 ? 0 : pct}%`, background: color }}
                    />
                  </div>
                </button>

                {open && (
                  <div className="mt-3 space-y-1.5 border-t border-[#2a2f3f] pt-3">
                    {sec.sets.map((st) => {
                      const sp = Math.round(st.mastery * 100);
                      const sc = secColor(sp, st.attempted);
                      return (
                        <div key={st.slug} className="flex items-center gap-2">
                          <span className="w-24 shrink-0 truncate text-[10px] text-[#8892a4]">
                            {shortSet(st.slug)}
                          </span>
                          <div className="h-1 flex-1 overflow-hidden rounded-full bg-[#2a2f3f]">
                            <div
                              className="h-full rounded-full"
                              style={{ width: `${st.attempted === 0 ? 0 : sp}%`, background: sc }}
                            />
                          </div>
                          <span className="w-16 shrink-0 text-right text-[10px] tabular-nums" style={{ color: sc }}>
                            {st.attempted === 0 ? "未着" : `${sp}%`}
                            <span className="ml-1 text-[#3a4050]">{st.attempted}/{st.total}</span>
                          </span>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Worst questions */}
        <div className="mb-3 flex items-center justify-between">
          <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
            {isMultiSet ? "弱点問題（全セット）" : "弱点問題"}
          </p>
          {worst.length > 0 && (
            <button
              onClick={() => startReview(worst)}
              className="rounded-lg border border-[#2a2f3f] px-3 py-1 text-[11px] font-medium text-[#8892a4] transition hover:border-[#3b82f6] hover:text-white"
            >
              まとめて復習 →
            </button>
          )}
        </div>
        <p className="mb-3 text-[10px] text-[#3a4050]">
          タップするとその問題だけを復習できます
        </p>
        <div className="mb-6 space-y-1.5">
          {worst.length === 0 && (
            <p className="text-xs text-[#555e70]">弱点問題はありません（演習するとここに出ます）</p>
          )}
          {worst.map((q) => {
            const p = getProgress(progressMap, q.id);
            return (
              <button
                key={q.id}
                onClick={() => startReview([q])}
                className="flex w-full items-start gap-3 rounded-xl border border-[#2a2f3f] px-3.5 py-3 text-left transition hover:border-[#3b82f6] hover:bg-[#141720]"
              >
                <span
                  className="mt-0.5 h-2 w-2 shrink-0 rounded-full"
                  style={{ background: q.category_color }}
                />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-xs text-[#8892a4]">
                    {q.question_text.slice(0, 55)}…
                  </p>
                  <p className="mt-0.5 text-[10px] text-[#555e70]">
                    {isMultiSet && (
                      <span className="mr-2 rounded bg-[#1e2230] px-1.5 py-px text-[#8892a4]">
                        {shortSet(examQuestionSlug[q.id] ?? "")}
                      </span>
                    )}
                    誤 {totalWrong(q, p)} 正 {totalCorrect(p)}
                    {p.last_confidence !== null && (
                      <span className="ml-2" style={{ color: CONFIDENCE_COLORS[(p.last_confidence ?? 1) - 1] }}>
                        {CONFIDENCE_LABELS[(p.last_confidence ?? 1) - 1]}
                      </span>
                    )}
                  </p>
                </div>
                <span className="mt-0.5 shrink-0 text-xs text-[#3a4050]">→</span>
              </button>
            );
          })}
        </div>

        {/* 確信度キャリブレーション */}
        <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
          確信度キャリブレーション
        </p>
        {cal.sureWrong > 0 && (
          <div className="mb-3 flex items-center justify-between gap-3 rounded-xl border border-[#3f1515] bg-[#160606] px-4 py-3">
            <div className="min-w-0">
              <p className="text-xs font-semibold text-[#ef4444]">
                「自信あり」なのに誤答 {cal.sureWrong}問
              </p>
              <p className="text-[11px] text-[#8892a4]">思い込みの危険ゾーン。最優先で復習を。</p>
            </div>
            <button
              onClick={() => startReview(dangerQs)}
              className="shrink-0 rounded-lg border border-[#3f1515] px-3 py-1.5 text-[11px] font-medium text-[#ef4444] transition hover:bg-[#1a0808]"
            >
              復習 →
            </button>
          </div>
        )}
        <div className="mb-6 grid grid-cols-[56px_1fr_1fr] gap-1.5">
          <div />
          <div className="text-center text-[10px] font-mono text-[#555e70]">正解</div>
          <div className="text-center text-[10px] font-mono text-[#555e70]">誤答</div>

          <div className="flex items-center text-[10px] font-mono text-[#555e70]">自信あり</div>
          <div className="rounded-lg border border-[#2a2f3f] bg-[#141720] py-2.5 text-center">
            <span className="text-lg font-bold tabular-nums text-[#22c55e]">{cal.sureCorrect}</span>
          </div>
          <div
            className="rounded-lg border py-2.5 text-center"
            style={{ borderColor: cal.sureWrong > 0 ? "#ef4444" : "#2a2f3f", background: cal.sureWrong > 0 ? "#160606" : "#141720" }}
          >
            <span className="text-lg font-bold tabular-nums" style={{ color: cal.sureWrong > 0 ? "#ef4444" : "#3a4050" }}>
              {cal.sureWrong}
            </span>
          </div>

          <div className="flex items-center text-[10px] font-mono text-[#555e70]">自信なし</div>
          <div className="rounded-lg border border-[#2a2f3f] bg-[#141720] py-2.5 text-center">
            <span className="text-lg font-bold tabular-nums text-[#8892a4]">{cal.unsureCorrect}</span>
          </div>
          <div className="rounded-lg border border-[#2a2f3f] bg-[#141720] py-2.5 text-center">
            <span className="text-lg font-bold tabular-nums text-[#8892a4]">{cal.unsureWrong}</span>
          </div>
        </div>

        {/* FSRS 再構築（過去の解答から記憶エンジンを一括計算） */}
        <div className="mt-2 rounded-xl border border-[#2a2f3f] bg-[#141720] p-3.5">
          <div className="flex items-center justify-between gap-3">
            <div className="min-w-0">
              <p className="text-xs font-medium text-[#c0c8d8]">記憶エンジンを再構築</p>
              <p className="text-[11px] text-[#555e70]">
                過去の解答から復習間隔・合格ナビの精度を作り直します
              </p>
            </div>
            <button
              onClick={runBackfill}
              disabled={backfilling}
              className="shrink-0 rounded-lg border border-[#2a2f3f] px-3 py-1.5 text-[11px] font-medium text-[#8892a4] transition hover:border-[#3b82f6] hover:text-white disabled:opacity-50"
            >
              {backfilling ? "計算中…" : "⟳ 再構築"}
            </button>
          </div>
          {backfillMsg && <p className="mt-2 text-[11px] text-[#3E8E6E]">{backfillMsg}</p>}
        </div>
      </div>
    </div>
  );
}
