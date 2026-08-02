import { useState } from "react";
import { type useRouter } from "next/navigation";
import { getProgress, isResting, type ProgressMap } from "@/features/quiz/lib/selection";
import {
  type ExamGroup,
  type SectionQuestionRef,
  type UserGoal,
} from "@/features/quiz/lib/stats";
import { ThemePractice } from "@/features/quiz/components/theme-practice";
import { type Readiness, type estimatePassProbability } from "@/features/quiz/lib/readiness";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { type Screen } from "@/features/quiz/hooks/use-screen";
import { useMenuSettings } from "@/features/quiz/hooks/use-menu-settings";
import { useTextbooks } from "@/features/quiz/hooks/use-textbooks";
import { StatCell } from "@/features/quiz/components/stat-cell";
import { VERDICT_META, WEAK_SESSION_MAX } from "@/features/quiz/lib/constants";

interface MenuScreenProps {
  subjectName: string;
  subjects: { slug: string; name: string }[];
  currentSubjectSlug: string;
  examGroups: ExamGroup[];
  examName: string;
  questions: QuizQuestion[];
  categories: { id: string; name: string; color: string }[];
  progressMap: ProgressMap;
  now: number;
  dailyCapacity: number;
  goal: UserGoal | null;
  readiness: Readiness | null;
  passEstimate: ReturnType<typeof estimatePassProbability> | null;
  menu: ReturnType<typeof useMenuSettings>;
  textbooks: ReturnType<typeof useTextbooks>;
  examWeakPool: QuizQuestion[];
  examFirstTimePool: QuizQuestion[];
  isMultiSet: boolean;
  // テーマ横断演習（全セット横断・複数テーマ選択可）
  examQuestions: QuizQuestion[];
  examSections: SectionQuestionRef[];
  startThemeQuiz: (names: Set<string>, count: number, force?: boolean) => void;
  pickerOpen: boolean;
  setPickerOpen: React.Dispatch<React.SetStateAction<boolean>>;
  setScreen: (s: Screen) => void;
  startQuiz: (force?: boolean) => void;
  startReview: (qs: QuizQuestion[]) => void;
  switchSubject: (slug: string) => void;
  csvRefresh: () => void;
  router: ReturnType<typeof useRouter>;
}

export function MenuScreen({
  subjectName,
  subjects,
  currentSubjectSlug,
  examGroups,
  examName,
  questions,
  categories,
  progressMap,
  now,
  dailyCapacity,
  goal,
  readiness,
  passEstimate,
  menu,
  textbooks: tb,
  examWeakPool,
  examFirstTimePool,
  isMultiSet,
  examQuestions,
  examSections,
  startThemeQuiz,
  pickerOpen,
  setPickerOpen,
  setScreen,
  startQuiz,
  startReview,
  switchSubject,
  csvRefresh,
  router,
}: MenuScreenProps) {
  const {
    selCats,
    setSelCats,
    count,
    setCount,
    mode,
    setMode,
    recallMode,
    setRecallMode,
    includeResting,
    setIncludeResting,
    expandedExam,
    setExpandedExam,
    restingCount,
    eligible,
    eligibleWithResting,
  } = menu;
  const {
    textbooks,
    tbEditing,
    setTbEditing,
    tbDraft,
    setTbDraft,
    tbError,
    setTbError,
    addTextbook,
    deleteTextbook,
  } = tb;

  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  const answeredCount = questions.filter((q) => {
    const p = getProgress(progressMap, q.id);
    return p.correct_count + p.wrong_count > 0;
  }).length;
  const countOptions = [5, 10, 20, eligible.length];

  // 初めての問題だけ演習の出題数（既定は WEAK_SESSION_MAX 相当、明示的に選び直せる）
  const [firstTimeCount, setFirstTimeCount] = useState(WEAK_SESSION_MAX);
  const firstTimeCountOptions = [10, 20, WEAK_SESSION_MAX, examFirstTimePool.length];

  return (
    <div className={wrap}>
      <div className={container}>
        {/* Header */}
        <div className="mb-6 flex items-start justify-between">
          <div>
            <h1 className="text-base font-semibold text-white">{subjectName}</h1>
            <p className="text-xs text-[#555e70]">
              全 {questions.length} 問
              {answeredCount > 0 && <span> · 演習済み {answeredCount}</span>}
              {restingCount > 0 && <span> · 休眠 {restingCount}</span>}
            </p>
          </div>
          {subjects.length > 1 && (
            <div className="relative shrink-0">
              <button
                onClick={() => setPickerOpen((o) => !o)}
                className="flex items-center gap-1.5 rounded-lg border border-[#2a2f3f] bg-[#1a1d27] px-3 py-1.5 text-xs text-[#8892a4] outline-none transition hover:border-[#3a4055]"
              >
                <span className="max-w-[180px] truncate">問題集を選ぶ</span>
                <svg width="9" height="9" viewBox="0 0 10 10" fill="none">
                  <path d="M2 3.5L5 6.5L8 3.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </button>

              {pickerOpen && (
                <>
                  <button
                    aria-label="閉じる"
                    onClick={() => setPickerOpen(false)}
                    className="fixed inset-0 z-40 cursor-default"
                  />
                  <div className="absolute right-0 z-50 mt-2 max-h-[70vh] w-[340px] overflow-auto rounded-xl border border-[#2a2f3f] bg-[#12141c] p-1.5 shadow-2xl">
                    {examGroups.map((g) => {
                      // 単一セットの試験はそのまま1行で選択可能にする。
                      if (g.sets.length === 1) {
                        const s = g.sets[0];
                        const active = s.slug === currentSubjectSlug;
                        return (
                          <button
                            key={g.examKey}
                            onClick={() => {
                              setPickerOpen(false);
                              if (!active) switchSubject(s.slug);
                            }}
                            className={`flex w-full items-center gap-2 rounded-lg px-2 py-2 text-left transition ${
                              active ? "bg-[#1e2230]" : "hover:bg-[#1a1d27]"
                            }`}
                          >
                            <span
                              className={`min-w-0 flex-1 truncate text-xs ${
                                active ? "font-medium text-white" : "text-[#c0c8d8]"
                              }`}
                            >
                              {g.examName}
                            </span>
                            <StatCell
                              accuracy={s.accuracy}
                              answers={s.answers}
                              attempted={s.attempted}
                              total={s.total}
                              last={s.lastAnsweredAt}
                              now={now}
                            />
                          </button>
                        );
                      }

                      // 複数セットの試験は「試験見出し（集計）」を1行に折りたたみ、
                      // クリックで展開してセット一覧を表示する。
                      const open = expandedExam === g.examKey;
                      const hasCurrent = g.sets.some((s) => s.slug === currentSubjectSlug);
                      return (
                        <div key={g.examKey}>
                          <button
                            onClick={() => setExpandedExam(open ? null : g.examKey)}
                            className={`flex w-full items-center gap-2 rounded-lg px-2 py-2 text-left transition hover:bg-[#1a1d27] ${
                              hasCurrent && !open ? "bg-[#161922]" : ""
                            }`}
                          >
                            <svg
                              width="9"
                              height="9"
                              viewBox="0 0 10 10"
                              fill="none"
                              className="shrink-0 transition-transform"
                              style={{ transform: open ? "rotate(90deg)" : "none", color: "#8892a4" }}
                            >
                              <path d="M3.5 2L6.5 5L3.5 8" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                            <span className="min-w-0 flex-1 truncate text-xs font-semibold text-[#c0c8d8]">
                              {g.examName}
                              <span className="ml-1.5 font-normal text-[#555e70]">{g.sets.length}セット</span>
                            </span>
                            <StatCell
                              accuracy={g.accuracy}
                              answers={g.answers}
                              attempted={g.attempted}
                              total={g.total}
                              last={g.lastAnsweredAt}
                              now={now}
                            />
                          </button>

                          {open && (
                            <div className="mb-1 ml-3.5 space-y-0.5 border-l border-[#2a2f3f] pl-2">
                              {g.sets.map((s) => {
                                const active = s.slug === currentSubjectSlug;
                                return (
                                  <button
                                    key={s.slug}
                                    onClick={() => {
                                      setPickerOpen(false);
                                      if (!active) switchSubject(s.slug);
                                    }}
                                    className={`flex w-full items-center gap-2 rounded-lg px-2 py-1.5 text-left transition ${
                                      active ? "bg-[#1e2230]" : "hover:bg-[#1a1d27]"
                                    }`}
                                  >
                                    <span
                                      className={`min-w-0 flex-1 truncate text-xs ${
                                        active ? "font-medium text-white" : "text-[#c0c8d8]"
                                      }`}
                                    >
                                      {s.name}
                                    </span>
                                    <StatCell
                                      accuracy={s.accuracy}
                                      answers={s.answers}
                                      attempted={s.attempted}
                                      total={s.total}
                                      last={s.lastAnsweredAt}
                                      now={now}
                                    />
                                  </button>
                                );
                              })}
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                </>
              )}
            </div>
          )}
        </div>

        {/* 合格ナビ card — 本日時点の合格可能性は試験日と独立に常時表示。
            試験日があれば加えて着地予測・ノルマも出す。 */}
        {readiness &&
          (() => {
            const hasDate = readiness.verdict !== "no-date";
            const passPct = Math.round(readiness.passLine * 100);
            // 本日時点の合格確率（ポアソン二項）と推定得点率。未計算時は定着で代替。
            const passProb = passEstimate ? passEstimate.passProbability : readiness.readinessNow;
            const passProbPct = Math.round(passProb * 100);
            const scorePct = Math.round(
              (passEstimate ? passEstimate.expectedScore : readiness.readinessNow) * 100
            );
            const scoreReached = scorePct >= passPct;
            // 合格確率の色: 高いほど緑、中位は琥珀、低位は学習中のアクセント青。
            const probColor = passProb >= 0.7 ? "#22c55e" : passProb >= 0.4 ? "#f59e0b" : "#3b82f6";
            const barColor = scoreReached ? "#22c55e" : "#3b82f6";
            // 試験日の推定得点率（＝残り日数で全範囲を仕上げた場合の見込み得点）。
            // 触れられる割合 = (着手 + 残日×1日量)/全問。仕上げた分は skill 0.82、残りは推測床。
            const reachCov = Math.min(
              1,
              (readiness.attempted + readiness.daysLeft * dailyCapacity) /
                Math.max(1, readiness.total)
            );
            const projScore = 0.82 * reachCov + 0.25 * (1 - reachCov);
            const projScorePct = Math.round(projScore * 100);
            const projColor =
              projScorePct >= passPct ? "#22c55e" : projScorePct >= passPct - 8 ? "#f59e0b" : "#8892a4";
            // ヘッダーのバッジ: 本日すでに合格圏なら合格圏内、そうでなければ試験日見込みで判定。
            const chip =
              passProb >= 0.7
                ? VERDICT_META.passed
                : hasDate
                  ? projScore >= readiness.passLine
                    ? VERDICT_META["on-track"]
                    : projScore >= readiness.passLine - 0.08
                      ? VERDICT_META.tight
                      : VERDICT_META["at-risk"]
                  : null;
            return (
              <div className="mb-6 rounded-xl border border-[#2a2f3f] bg-[#1a1d27] p-4">
                <div className="mb-3 flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="truncate text-sm font-medium text-white">
                      {goal?.targetName || examName}
                    </p>
                    <p className="text-xs text-[#555e70]">
                      {hasDate ? `試験まで残り ${readiness.daysLeft} 日` : "試験日は未設定"}
                    </p>
                  </div>
                  {chip && (
                    <span
                      className="shrink-0 rounded-full px-2.5 py-1 text-[11px] font-semibold"
                      style={{ color: chip.color, background: chip.color + "22" }}
                    >
                      {chip.label}
                    </span>
                  )}
                </div>

                <div className="mb-2 flex items-end justify-between gap-3">
                  <div className="min-w-0">
                    <p className="text-[10px] uppercase tracking-widest text-[#555e70]">
                      本日時点の合格確率
                    </p>
                    <p
                      className="tabular-nums text-3xl font-light leading-tight"
                      style={{ color: probColor, letterSpacing: "-.03em" }}
                    >
                      {passProbPct}%
                    </p>
                  </div>
                  {hasDate && (
                    <span className="shrink-0 pb-1 text-right text-xs text-[#8892a4]">
                      試験日の推定得点率<span className="text-[#3a4050]">*</span>{" "}
                      <b className="tabular-nums" style={{ color: projColor }}>
                        {projScorePct}%
                      </b>
                    </span>
                  )}
                </div>
                <div className="relative mb-1 h-2 overflow-hidden rounded-full bg-[#2a2f3f]">
                  <div
                    className="h-full rounded-full transition-all duration-500"
                    style={{ width: `${scorePct}%`, background: barColor }}
                  />
                  <div
                    className="absolute -top-0.5 bottom-[-2px] w-px bg-white/70"
                    style={{ left: `${passPct}%` }}
                    title={`合格ライン ${passPct}%`}
                  />
                </div>
                <p className="mb-3 text-[10px] text-[#3a4050]">
                  推定得点率 {scorePct}% ／ 白線 = 合格ライン {passPct}%
                </p>

                <div className="flex items-center justify-between gap-3">
                  <p className="min-w-0 text-xs" style={{ color: scoreReached ? "#22c55e" : "#8892a4" }}>
                    {scoreReached
                      ? "推定得点が合格ラインに到達。維持しよう"
                      : `推定得点をあと ${Math.max(0, passPct - scorePct)}% 上げれば合格ライン` +
                        (hasDate && readiness.neededPerDayForPass > 0
                          ? ` · 1日 ${readiness.neededPerDayForPass} 問`
                          : "")}
                  </p>
                  <button
                    onClick={() => setScreen("goal")}
                    className="shrink-0 text-xs text-[#555e70] transition hover:text-[#8892a4]"
                  >
                    {hasDate ? "編集" : "試験日を設定"}
                  </button>
                </div>
                {hasDate && (
                  <p className="mt-2 text-[10px] text-[#3a4050]">
                    * 残り日数で全範囲をひととおり仕上げた場合の推定得点（まぐれ当たりは実力に数えません）
                  </p>
                )}
              </div>
            );
          })()}

        {/* 教科書リンク（試験区分ごと・クリックで外部ページへ） */}
        <section className="mb-6">
          <div className="mb-2 flex items-center justify-between">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
              教科書
            </p>
            {(textbooks.length > 0 || tbEditing) && (
              <button
                onClick={() => {
                  setTbEditing((v) => !v);
                  setTbError(null);
                }}
                className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
              >
                {tbEditing ? "完了" : "編集"}
              </button>
            )}
          </div>

          {textbooks.length > 0 && (
            <div className="overflow-hidden rounded-xl border border-[#2a2f3f] bg-[#1a1d27]">
              {textbooks.map((tb, i) => (
                <div
                  key={tb.id}
                  className={`flex items-center ${i > 0 ? "border-t border-[#20242e]" : ""}`}
                >
                  <a
                    href={tb.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="group flex min-w-0 flex-1 items-center gap-2.5 px-3.5 py-3 transition hover:bg-[#1e2230]"
                  >
                    <svg
                      width="15"
                      height="15"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      className="shrink-0 text-[#555e70]"
                    >
                      <path d="M4 5a2 2 0 0 1 2-2h12v16H6a2 2 0 0 0-2 2V5Z" />
                      <path d="M4 19a2 2 0 0 0 2 2h12" />
                    </svg>
                    <span className="min-w-0 flex-1 truncate text-sm text-[#c0c8d8] transition group-hover:text-white">
                      {tb.label || tb.url}
                    </span>
                    <svg
                      width="13"
                      height="13"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      className="shrink-0 text-[#555e70] transition group-hover:text-[#8892a4]"
                    >
                      <path d="M7 17 17 7M9 7h8v8" />
                    </svg>
                  </a>
                  {tbEditing && (
                    <button
                      onClick={() => deleteTextbook(tb.id)}
                      aria-label="削除"
                      className="mr-1.5 shrink-0 rounded-md px-2 py-2 text-[#555e70] transition hover:bg-[#ef4444]/15 hover:text-[#ef4444]"
                    >
                      <svg
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                      >
                        <path d="M6 6l12 12M18 6 6 18" />
                      </svg>
                    </button>
                  )}
                </div>
              ))}
            </div>
          )}

          {textbooks.length === 0 && !tbEditing && (
            <button
              onClick={() => setTbEditing(true)}
              className="w-full rounded-xl border border-dashed border-[#2a2f3f] px-4 py-3.5 text-left transition hover:border-[#3a4050]"
            >
              <p className="text-sm text-[#8892a4]">教科書リンクを追加</p>
              <p className="text-xs text-[#555e70]">Claude アーティファクト等の公開ページ URL を貼る</p>
            </button>
          )}

          {tbEditing && (
            <div className="mt-2 rounded-xl border border-[#2a2f3f] bg-[#14161d] p-3">
              <input
                type="text"
                value={tbDraft.label}
                onChange={(e) => setTbDraft((d) => ({ ...d, label: e.target.value }))}
                placeholder="タイトル（例: 公式ドキュメントまとめ）"
                className="mb-2 w-full rounded-lg border border-[#2a2f3f] bg-[#1a1d27] px-3 py-2 text-sm text-white outline-none transition-colors placeholder:text-[#555e70] focus:border-[#3b82f6]"
              />
              <input
                type="url"
                value={tbDraft.url}
                onChange={(e) => setTbDraft((d) => ({ ...d, url: e.target.value }))}
                onKeyDown={(e) => {
                  if (e.key === "Enter") addTextbook();
                }}
                placeholder="https://claude.ai/public/artifacts/..."
                className="w-full rounded-lg border border-[#2a2f3f] bg-[#1a1d27] px-3 py-2 text-sm text-white outline-none transition-colors placeholder:text-[#555e70] focus:border-[#3b82f6]"
              />
              {tbError && <p className="mt-1.5 text-[11px] text-[#ef4444]">{tbError}</p>}
              <button
                onClick={addTextbook}
                disabled={!tbDraft.url.trim()}
                className="mt-2.5 w-full rounded-lg bg-[#3b82f6] px-4 py-2 text-sm font-medium text-white transition hover:bg-[#3b82f6]/90 disabled:cursor-not-allowed disabled:opacity-40"
              >
                追加
              </button>
            </div>
          )}
        </section>

        {/* 苦手だけ演習（試験区分の全セット横断・弱点順） */}
        {examWeakPool.length > 0 && (
          <button
            onClick={() => startReview(examWeakPool.slice(0, WEAK_SESSION_MAX))}
            className="mb-6 flex w-full items-center justify-between gap-3 rounded-xl border border-[#3a1d1d] bg-[#181215] px-4 py-3.5 text-left transition hover:border-[#ef4444]"
          >
            <div className="min-w-0">
              <p className="text-sm font-medium text-white">苦手だけ演習</p>
              <p className="text-xs text-[#8892a4]">
                {isMultiSet ? "全セット横断・" : ""}間違えた・苦手な問題を弱点順に
              </p>
            </div>
            <span className="shrink-0 rounded-lg bg-[#ef4444]/15 px-3 py-1.5 text-xs font-semibold tabular-nums text-[#f87171]">
              {examWeakPool.length > WEAK_SESSION_MAX
                ? `上位${WEAK_SESSION_MAX} / ${examWeakPool.length}問`
                : `${examWeakPool.length}問`}
            </span>
          </button>
        )}

        {/* 初めての問題だけ演習（試験区分の全セット横断・未着手のみ・順不同・件数を選べる） */}
        {examFirstTimePool.length > 0 && (
          <section className="mb-6 rounded-xl border border-[#1a2b3a] bg-[#0f171d] px-4 py-3.5">
            <div className="mb-3 flex items-center justify-between gap-3">
              <div className="min-w-0">
                <p className="text-sm font-medium text-white">初めての問題だけ演習</p>
                <p className="text-xs text-[#8892a4]">
                  {isMultiSet ? "全セット横断・" : ""}まだ一度も解いていない問題だけ
                </p>
              </div>
              <span className="shrink-0 rounded-lg bg-[#3b82f6]/15 px-3 py-1.5 text-xs font-semibold tabular-nums text-[#60a5fa]">
                {examFirstTimePool.length}問
              </span>
            </div>

            <div className="mb-3 flex overflow-hidden rounded-xl border border-[#2a2f3f]">
              {firstTimeCountOptions.map((n, i) => {
                const on = firstTimeCount === n;
                return (
                  <button
                    key={i}
                    onClick={() => setFirstTimeCount(n)}
                    className="flex-1 border-r border-[#2a2f3f] py-2 text-xs font-medium last:border-r-0 transition"
                    style={{
                      background: on ? "#1e2230" : "transparent",
                      color: on ? "#e8eaf0" : "#8892a4",
                    }}
                  >
                    {i === firstTimeCountOptions.length - 1 ? `全部 ${n}` : n}
                  </button>
                );
              })}
            </div>

            <button
              onClick={() =>
                startReview(examFirstTimePool.slice(0, firstTimeCount || examFirstTimePool.length))
              }
              className="w-full rounded-xl border border-[#2a2f3f] py-3 text-sm font-medium text-[#60a5fa] transition hover:border-[#3b82f6]"
            >
              スタート — {Math.min(firstTimeCount || examFirstTimePool.length, examFirstTimePool.length)} 問
            </button>
          </section>
        )}

        {/* テーマ横断演習（複数セット構成の試験のみ。セット内の分野選択とは独立） */}
        {isMultiSet && (
          <ThemePractice
            examQuestions={examQuestions}
            examSections={examSections}
            progressMap={progressMap}
            now={now}
            includeResting={includeResting}
            onStart={startThemeQuiz}
          />
        )}

        {/* Categories */}
        <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
          分野
        </p>
        <div className="mb-2 flex flex-wrap gap-1.5">
          {categories.map((c) => {
            const on = selCats.has(c.id);
            const all = questions.filter((q) => q.category_id === c.id);
            const rest = all.filter((q) =>
              isResting(getProgress(progressMap, q.id), now)
            ).length;
            return (
              <button
                key={c.id}
                onClick={() => {
                  const s = new Set(selCats);
                  s.has(c.id) ? s.delete(c.id) : s.add(c.id);
                  setSelCats(s);
                }}
                className="flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs transition"
                style={{
                  borderColor: on ? c.color + "55" : "#2a2f3f",
                  color: on ? c.color : "#8892a4",
                  background: on ? c.color + "0f" : "transparent",
                }}
              >
                <span
                  className="h-1.5 w-1.5 shrink-0 rounded-full"
                  style={{ background: on ? c.color : "#3a4050" }}
                />
                {c.name}
                <span className="text-[10px] opacity-60">{all.length - rest}</span>
              </button>
            );
          })}
        </div>
        <div className="mb-6 flex gap-3">
          <button
            onClick={() => setSelCats(new Set(categories.map((c) => c.id)))}
            className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
          >
            全選択
          </button>
          <span className="text-[#2a2f3f]">·</span>
          <button
            onClick={() => setSelCats(new Set())}
            className="text-xs text-[#555e70] transition hover:text-[#8892a4]"
          >
            全解除
          </button>
        </div>

        {/* Count */}
        <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
          問題数
        </p>
        <div className="mb-6 flex overflow-hidden rounded-xl border border-[#2a2f3f]">
          {countOptions.map((n, i) => {
            const on = count === n;
            return (
              <button
                key={i}
                onClick={() => setCount(n)}
                className="flex-1 border-r border-[#2a2f3f] py-2.5 text-sm font-medium last:border-r-0 transition"
                style={{
                  background: on ? "#3b82f6" : "transparent",
                  color: on ? "#fff" : "#8892a4",
                }}
              >
                {i === 3 ? eligible.length : n}
              </button>
            );
          })}
        </div>

        {/* Start CTA */}
        {eligible.length > 0 ? (
          <button
            onClick={() => startQuiz()}
            className="mb-6 w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
          >
            スタート — {Math.min(count, eligible.length)} 問
          </button>
        ) : eligibleWithResting.length > 0 ? (
          // 全問休眠でも「今すぐ復習したい」に応える脱出口。休眠を無視して出題する。
          <div className="mb-6">
            <button
              onClick={() => startQuiz(true)}
              className="w-full rounded-xl bg-[#3b82f6] py-4 text-sm font-semibold text-white transition hover:bg-[#60a5fa]"
            >
              休眠中も含めて復習 — {Math.min(count, eligibleWithResting.length)} 問
            </button>
            <p className="mt-1.5 text-center text-xs text-[#555e70]">
              いまは全問が休眠中（復習日は先）。それでも復習できます
            </p>
          </div>
        ) : (
          <button
            disabled
            className="mb-6 w-full rounded-xl bg-[#141720] py-4 text-sm font-semibold text-[#555e70]"
          >
            この分野に出題できる問題がありません
          </button>
        )}

        {/* Advanced settings */}
        <details className="mb-6 group" open={mode === "priority" || recallMode || includeResting}>
          <summary className="mb-3 cursor-pointer list-none text-xs text-[#555e70] transition hover:text-[#8892a4] group-open:text-[#8892a4]">
            詳細設定
          </summary>

          <div className="space-y-4">
            <div>
              <p className="mb-2 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
                出題モード
              </p>
              <div className="flex overflow-hidden rounded-xl border border-[#2a2f3f]">
                {([["shuffle", "シャッフル"], ["priority", "弱点優先"]] as const).map(
                  ([m, lbl], i) => (
                    <button
                      key={m}
                      onClick={() => setMode(m)}
                      className="flex-1 py-2.5 text-sm transition"
                      style={{
                        borderRight: i === 0 ? "1px solid #2a2f3f" : "none",
                        background:
                          mode === m
                            ? m === "priority"
                              ? "#1f0a0a"
                              : "#0d1f3c"
                            : "transparent",
                        color:
                          mode === m
                            ? m === "priority"
                              ? "#f87171"
                              : "#60a5fa"
                            : "#8892a4",
                      }}
                    >
                      {lbl}
                    </button>
                  )
                )}
              </div>
              <p className="mt-1.5 text-xs text-[#555e70]">
                3回連続正解は2週間休眠
              </p>
            </div>

            <div className="flex items-center justify-between rounded-xl border border-[#2a2f3f] px-4 py-3">
              <div>
                <p className="text-sm text-[#c0c8d8]">想起モード</p>
                <p className="text-xs text-[#555e70]">選択肢を隠して先に考える</p>
              </div>
              <button
                onClick={() => setRecallMode((v) => !v)}
                className="relative h-6 w-11 shrink-0 rounded-full transition-colors"
                style={{ background: recallMode ? "#3b82f6" : "#2a2f3f" }}
              >
                <span
                  className="absolute top-1 h-4 w-4 rounded-full bg-white shadow transition-all"
                  style={{ left: recallMode ? "calc(100% - 20px)" : "4px" }}
                />
              </button>
            </div>

            <div className="flex items-center justify-between rounded-xl border border-[#2a2f3f] px-4 py-3">
              <div>
                <p className="text-sm text-[#c0c8d8]">休眠中も出す</p>
                <p className="text-xs text-[#555e70]">復習日が来ていない問題も出題する</p>
              </div>
              <button
                onClick={() => setIncludeResting((v) => !v)}
                className="relative h-6 w-11 shrink-0 rounded-full transition-colors"
                style={{ background: includeResting ? "#3b82f6" : "#2a2f3f" }}
              >
                <span
                  className="absolute top-1 h-4 w-4 rounded-full bg-white shadow transition-all"
                  style={{ left: includeResting ? "calc(100% - 20px)" : "4px" }}
                />
              </button>
            </div>
          </div>
        </details>

        {/* Nav grid */}
        <div className="grid grid-cols-2 gap-2">
          {[
            { label: "単語カード",   action: () => router.push("/flashcards") },
            { label: "ロードマップ", action: () => router.push("/roadmap") },
            { label: "学習ログ",     action: () => router.push("/log") },
            { label: "思考フレーム", action: () => router.push("/mindset") },
            { label: "コードの読み方", action: () => router.push("/code-tour") },
            { label: "苦手分析",     action: () => setScreen("analysis") },
            {
              label: "書き出し",
              action: () => {
                csvRefresh();
                setScreen("export");
              },
            },
          ].map(({ label, action }) => (
            <button
              key={label}
              onClick={action}
              className="rounded-xl border border-[#2a2f3f] py-3 text-xs text-[#555e70] transition hover:border-[#3a4050] hover:text-[#8892a4]"
            >
              {label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
