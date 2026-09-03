import { useState } from "react";
import { type useRouter } from "next/navigation";
import { getProgress, isResting, type ProgressMap } from "@/features/quiz/lib/selection";
import {
  examGroupKey,
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
import { statusOf } from "@/features/quiz/lib/format";
import {
  ActivityCard,
  ProgressTable,
  StatGrid,
} from "@/features/quiz/components/dashboard-parts";
import { VERDICT_META, WEAK_SESSION_MAX } from "@/features/quiz/lib/constants";
import type { WeeklyBar } from "@/app/(main)/learning-app";
import { TrendCard, type TrendDay } from "@/features/quiz/components/trend-card";

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
  setScreen: (s: Screen) => void;
  startQuiz: (force?: boolean) => void;
  startReview: (qs: QuizQuestion[]) => void;
  switchSubject: (slug: string) => void;
  router: ReturnType<typeof useRouter>;
  streak: number;
  weekly: WeeklyBar[];
  trendDays: TrendDay[];
  todayKey: string;
}

const WEEKDAY_LABEL = ["日", "月", "火", "水", "木", "金", "土"];

// 円グラフ（合格確率ゲージ）の円周。r=52 の 2πr。
const GAUGE_CIRCUMFERENCE = 2 * Math.PI * 52;

export function MenuScreen({
  subjectName,
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
  setScreen,
  startQuiz,
  startReview,
  switchSubject,
  router,
  streak,
  weekly,
  trendDays,
  todayKey,
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

  // 「出題数・分野を調整」で開く出題設定パネル。
  const [tuning, setTuning] = useState(false);
  // 初めての問題だけ演習の出題数（既定は WEAK_SESSION_MAX 相当、明示的に選び直せる）
  const [firstTimeCount, setFirstTimeCount] = useState(WEAK_SESSION_MAX);

  const answeredCount = questions.filter((q) => {
    const p = getProgress(progressMap, q.id);
    return p.correct_count + p.wrong_count > 0;
  }).length;
  const countOptions = [5, 10, 20, eligible.length];
  const firstTimeCountOptions = [10, 20, WEAK_SESSION_MAX, examFirstTimePool.length];

  // ── サマリカード4枚: いま選んでいる試験区分の数字 ──
  const currentGroup = examGroups.find((g) =>
    g.sets.some((s) => s.slug === currentSubjectSlug)
  );
  const totals = {
    total: currentGroup?.total ?? 0,
    attempted: currentGroup?.attempted ?? 0,
    answers: currentGroup?.answers ?? 0,
    correct: currentGroup?.correct ?? 0,
  };
  const groupAccuracy = totals.answers > 0 ? totals.correct / totals.answers : 0;
  const groupStatus = statusOf(groupAccuracy, totals.answers);
  const weekAnswers = weekly.reduce((n, d) => n + d.total, 0);

  // ── 合格ナビ ──
  const nav = (() => {
    if (!readiness) return null;
    const hasDate = readiness.verdict !== "no-date";
    const passPct = Math.round(readiness.passLine * 100);
    // 本日時点の合格確率（ポアソン二項）と推定得点率。未計算時は定着で代替。
    const passProb = passEstimate ? passEstimate.passProbability : readiness.readinessNow;
    const passProbPct = Math.round(passProb * 100);
    const scorePct = Math.round(
      (passEstimate ? passEstimate.expectedScore : readiness.readinessNow) * 100
    );
    const scoreReached = scorePct >= passPct;
    // 試験日の推定得点率（＝残り日数で全範囲を仕上げた場合の見込み得点）。
    // 触れられる割合 = (着手 + 残日×1日量)/全問。仕上げた分は skill 0.82、残りは推測床。
    const reachCov = Math.min(
      1,
      (readiness.attempted + readiness.daysLeft * dailyCapacity) / Math.max(1, readiness.total)
    );
    const projScore = 0.82 * reachCov + 0.25 * (1 - reachCov);
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
    return {
      hasDate,
      passPct,
      passProbPct,
      scorePct,
      scoreReached,
      projScorePct: Math.round(projScore * 100),
      chip,
      daysLeft: readiness.daysLeft,
      neededPerDay: readiness.neededPerDayForPass,
    };
  })();

  // ── 試験日カレンダー（今日を中央に置いた7日ストリップ） ──
  const examDateKey = goal?.examDate || null;
  const calDays = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(now);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + i - 3);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
    return {
      key,
      dow: WEEKDAY_LABEL[d.getDay()],
      date: d.getDate(),
      today: i === 3,
      exam: examDateKey === key,
    };
  });

  return (
    <>
      {/* ---------- サマリ ---------- */}
      <StatGrid
        totals={totals}
        streak={streak}
        weekAnswers={weekAnswers}
        firstTrend={isMultiSet ? `${currentGroup?.sets.length ?? 1} セット` : "1 セット"}
        accuracyTrend={groupStatus.label}
      />

      <div className="content-grid">
        {/* ================= 左カラム ================= */}
        <div className="col-main">
          {/* 学習アクティビティ + 合格ナビ */}
          <div className="two-up">
            <ActivityCard
              weekly={weekly}
              sub={`直近7日間の解答数（${examName}）`}
              onOpenLog={() => router.push("/log")}
            />

            <div className="card">
              <div className="card-head">
                <div>
                  <div className="card-title">合格ナビ</div>
                  <div className="card-sub">{goal?.targetName || examName}・本日時点</div>
                </div>
                {nav?.chip && (
                  <span
                    className="status-pill"
                    style={{ color: nav.chip.color, background: nav.chip.color + "22" }}
                  >
                    {nav.chip.label}
                  </span>
                )}
              </div>

              {nav ? (
                <div className="gauge-wrap">
                  <div className="gauge">
                    <svg viewBox="0 0 120 120">
                      <circle cx="60" cy="60" r="52" fill="none" stroke="#232838" strokeWidth="12" />
                      <circle
                        cx="60"
                        cy="60"
                        r="52"
                        fill="none"
                        stroke="url(#navGauge)"
                        strokeWidth="12"
                        strokeLinecap="round"
                        strokeDasharray={GAUGE_CIRCUMFERENCE}
                        strokeDashoffset={GAUGE_CIRCUMFERENCE * (1 - nav.passProbPct / 100)}
                      />
                      <defs>
                        <linearGradient id="navGauge" x1="0%" y1="0%" x2="100%" y2="100%">
                          <stop offset="0%" stopColor="#60a5fa" />
                          <stop offset="100%" stopColor="#22c55e" />
                        </linearGradient>
                      </defs>
                    </svg>
                    <div className="gauge-center">
                      <div className="gauge-pct">{nav.passProbPct}%</div>
                      <div className="gauge-tag">合格確率</div>
                    </div>
                  </div>
                  <div className="gauge-foot">
                    {nav.hasDate ? (
                      <>
                        試験まで{" "}
                        <b style={{ color: "var(--green)" }}>{nav.daysLeft}日</b> ／ 合格ライン{" "}
                        {nav.passPct}%
                      </>
                    ) : (
                      <>試験日は未設定 ／ 合格ライン {nav.passPct}%</>
                    )}
                  </div>
                  <div className="mt-3 w-full">
                    <div className="relative h-1.5 overflow-hidden rounded-full bg-card2">
                      <div
                        className="h-full rounded-full transition-all duration-500"
                        style={{
                          width: `${nav.scorePct}%`,
                          background: nav.scoreReached ? "var(--green)" : "var(--primary)",
                        }}
                      />
                      <div
                        className="absolute -top-0.5 bottom-[-2px] w-px bg-white/70"
                        style={{ left: `${nav.passPct}%` }}
                        title={`合格ライン ${nav.passPct}%`}
                      />
                    </div>
                    <p className="mt-2 text-[11px] leading-relaxed text-muted2">
                      推定得点率 {nav.scorePct}%
                      {nav.hasDate && ` ／ 試験日の見込み ${nav.projScorePct}%`}
                    </p>
                    <div className="mt-2 flex items-center justify-between gap-2">
                      <p
                        className="min-w-0 text-[11px]"
                        style={{ color: nav.scoreReached ? "var(--green)" : "var(--muted)" }}
                      >
                        {nav.scoreReached
                          ? "合格ラインに到達。維持しよう"
                          : `あと ${Math.max(0, nav.passPct - nav.scorePct)}%` +
                            (nav.hasDate && nav.neededPerDay > 0
                              ? ` ・ 1日 ${nav.neededPerDay} 問`
                              : "")}
                      </p>
                      <button
                        onClick={() => setScreen("goal")}
                        className="shrink-0 text-[11px] text-muted2 transition hover:text-muted"
                      >
                        {nav.hasDate ? "編集" : "試験日を設定"}
                      </button>
                    </div>
                  </div>
                </div>
              ) : (
                <p className="py-8 text-center text-xs text-muted2">
                  演習を始めると合格確率を計算します
                </p>
              )}
            </div>
          </div>

          <TrendCard days={trendDays} todayKey={todayKey} examName={examName} />

          {/* 問題集の進捗（全区分。行クリックでその問題集へ切り替え） */}
          <ProgressTable
            examGroups={examGroups}
            currentSubjectSlug={currentSubjectSlug}
            now={now}
            onSelect={switchSubject}
            onSeeAll={() => router.push("/catalog")}
          />

          {/* 演習を始める */}
          <div className="card start-card">
            <div className="card-head">
              <div>
                <div className="card-title">演習を始める</div>
                <div className="card-sub">
                  {subjectName} ・ 全 {questions.length} 問
                  {answeredCount > 0 && ` ・ 演習済み ${answeredCount}`}
                  {restingCount > 0 && ` ・ 休眠 ${restingCount}`}
                </div>
              </div>
            </div>

            <div className="quick-actions">
              <button
                className="quick-action"
                disabled={examWeakPool.length === 0}
                style={examWeakPool.length === 0 ? { opacity: 0.45, cursor: "not-allowed" } : undefined}
                onClick={() => startReview(examWeakPool.slice(0, WEAK_SESSION_MAX))}
              >
                <div className="qa-icon" style={{ background: "var(--red-soft)", color: "var(--red)" }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 1 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
                  </svg>
                </div>
                <div className="qa-title">苦手だけ演習</div>
                <div className="qa-sub">
                  {examWeakPool.length === 0
                    ? "まだありません"
                    : `${Math.min(examWeakPool.length, WEAK_SESSION_MAX)}問 ・ 弱点順${isMultiSet ? "・横断" : ""}`}
                </div>
              </button>

              <button
                className="quick-action"
                disabled={examFirstTimePool.length === 0}
                style={examFirstTimePool.length === 0 ? { opacity: 0.45, cursor: "not-allowed" } : undefined}
                onClick={() =>
                  startReview(examFirstTimePool.slice(0, firstTimeCount || examFirstTimePool.length))
                }
              >
                <div className="qa-icon" style={{ background: "var(--primary-soft)", color: "var(--primary2)" }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M12 6v6l4 2" />
                  </svg>
                </div>
                <div className="qa-title">初めての問題</div>
                <div className="qa-sub">
                  {examFirstTimePool.length === 0
                    ? "すべて着手済み"
                    : `${Math.min(firstTimeCount || examFirstTimePool.length, examFirstTimePool.length)}問 ・ 未着手のみ`}
                </div>
              </button>

              <button
                className="quick-action"
                disabled={eligible.length === 0 && eligibleWithResting.length === 0}
                onClick={() => {
                  setMode("shuffle");
                  startQuiz(eligible.length === 0);
                }}
              >
                <div className="qa-icon" style={{ background: "var(--purple-soft)", color: "var(--purple)" }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M16 3h5v5M4 20L21 3M21 16v5h-5M15 15l6 6M4 4l5 5" />
                  </svg>
                </div>
                <div className="qa-title">シャッフル演習</div>
                <div className="qa-sub">この問題集からランダム</div>
              </button>
            </div>

            {examFirstTimePool.length > 0 && (
              <div className="mt-3">
                <p className="section-label">初めての問題の出題数</p>
                <div className="pill-row mt-1.5">
                  {firstTimeCountOptions.map((n, i) => (
                    <button
                      key={i}
                      onClick={() => setFirstTimeCount(n)}
                      className={firstTimeCount === n ? "on" : ""}
                      style={{ ["--pill-color" as string]: "#60a5fa" }}
                    >
                      {i === firstTimeCountOptions.length - 1 ? `全部 ${n}` : n}
                    </button>
                  ))}
                </div>
              </div>
            )}

            <div className="cta-row">
              {eligible.length > 0 ? (
                <button className="btn-primary" onClick={() => startQuiz()}>
                  スタート — {Math.min(count, eligible.length)} 問
                </button>
              ) : eligibleWithResting.length > 0 ? (
                // 全問休眠でも「今すぐ復習したい」に応える脱出口。休眠を無視して出題する。
                <button className="btn-primary" onClick={() => startQuiz(true)}>
                  休眠中も含めて復習 — {Math.min(count, eligibleWithResting.length)} 問
                </button>
              ) : (
                <button className="btn-primary" disabled>
                  出題できる問題がありません
                </button>
              )}
              <button className="btn-ghost" onClick={() => setTuning((v) => !v)}>
                {tuning ? "設定を閉じる" : "出題数・分野を調整"}
              </button>
            </div>

            {eligible.length === 0 && eligibleWithResting.length > 0 && (
              <p className="mt-2 text-[11px] text-muted2">
                いまは全問が休眠中（復習日は先）。それでも復習できます
              </p>
            )}
          </div>

          {/* 出題設定 */}
          {tuning && (
            <div className="card">
              <div className="card-head">
                <div>
                  <div className="card-title">出題設定</div>
                  <div className="card-sub">{subjectName} の分野・問題数・出題モード</div>
                </div>
              </div>

              <p className="section-label">分野</p>
              <div className="mb-3 mt-2 flex flex-wrap gap-1.5">
                {categories.map((c) => {
                  const on = selCats.has(c.id);
                  const inCat = questions.filter((q) => q.category_id === c.id);
                  const rest = inCat.filter((q) =>
                    isResting(getProgress(progressMap, q.id), now)
                  ).length;
                  return (
                    <button
                      key={c.id}
                      onClick={() => {
                        const s = new Set(selCats);
                        if (s.has(c.id)) s.delete(c.id);
                        else s.add(c.id);
                        setSelCats(s);
                      }}
                      className="filter-chip"
                      style={{
                        borderColor: on ? c.color + "55" : undefined,
                        color: on ? c.color : undefined,
                        background: on ? c.color + "14" : undefined,
                      }}
                    >
                      <span
                        className="h-1.5 w-1.5 shrink-0 rounded-full"
                        style={{ background: on ? c.color : "#343a4a" }}
                      />
                      {c.name}
                      <span className="n">{inCat.length - rest}</span>
                    </button>
                  );
                })}
              </div>
              <div className="mb-5 flex gap-3">
                <button
                  onClick={() => setSelCats(new Set(categories.map((c) => c.id)))}
                  className="text-xs text-muted2 transition hover:text-muted"
                >
                  全選択
                </button>
                <span className="text-border">·</span>
                <button
                  onClick={() => setSelCats(new Set())}
                  className="text-xs text-muted2 transition hover:text-muted"
                >
                  全解除
                </button>
              </div>

              <p className="section-label">問題数</p>
              <div className="pill-row mb-5 mt-2">
                {countOptions.map((n, i) => (
                  <button
                    key={i}
                    onClick={() => setCount(n)}
                    className={count === n ? "on" : ""}
                    style={{ ["--pill-color" as string]: "#60a5fa" }}
                  >
                    {i === countOptions.length - 1 ? `全部 ${eligible.length}` : n}
                  </button>
                ))}
              </div>

              <p className="section-label">出題モード</p>
              <div className="pill-row mb-1.5 mt-2">
                {([["shuffle", "シャッフル", "#60a5fa"], ["priority", "弱点優先", "#f87171"]] as const).map(
                  ([m, lbl, col]) => (
                    <button
                      key={m}
                      onClick={() => setMode(m)}
                      className={mode === m ? "on" : ""}
                      style={{ ["--pill-color" as string]: col }}
                    >
                      <span className="dot" />
                      {lbl}
                    </button>
                  )
                )}
              </div>
              <p className="mb-5 text-[11px] text-muted2">3回連続正解は2週間休眠</p>

              <div className="space-y-2">
                {(
                  [
                    ["想起モード", "選択肢を隠して先に考える", recallMode, () => setRecallMode((v) => !v)],
                    ["休眠中も出す", "復習日が来ていない問題も出題する", includeResting, () => setIncludeResting((v) => !v)],
                  ] as const
                ).map(([label, desc, on, toggle]) => (
                  <div
                    key={label}
                    className="flex items-center justify-between rounded-xl border border-border px-4 py-3"
                  >
                    <div>
                      <p className="text-sm text-fg">{label}</p>
                      <p className="text-xs text-muted2">{desc}</p>
                    </div>
                    <button
                      onClick={toggle}
                      aria-label={label}
                      className="relative h-6 w-11 shrink-0 rounded-full transition-colors"
                      style={{ background: on ? "#3b82f6" : "#262b38" }}
                    >
                      <span
                        className="absolute top-1 h-4 w-4 rounded-full bg-white shadow transition-all"
                        style={{ left: on ? "calc(100% - 20px)" : "4px" }}
                      />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* テーマ横断演習（複数セット構成の試験のみ。セット内の分野選択とは独立） */}
          {isMultiSet && (
            <div className="card">
              <ThemePractice
                examQuestions={examQuestions}
                examSections={examSections}
                progressMap={progressMap}
                now={now}
                includeResting={includeResting}
                onStart={startThemeQuiz}
              />
            </div>
          )}
        </div>

        {/* ================= 右カラム ================= */}
        <div className="col-side">
          <div className="card profile-card">
            <div className="profile-avatar">学</div>
            <div className="profile-name">{examName}</div>
            <div className="profile-role">
              {isMultiSet ? `${subjectName}（全セット横断で分析）` : subjectName}
            </div>
            <div className="profile-stats">
              <div className="profile-stat">
                <b>{currentGroup?.sets.length ?? 1}</b>
                <span>セット</span>
              </div>
              <div className="profile-stat">
                <b>{streak}</b>
                <span>連続学習日</span>
              </div>
              <div className="profile-stat">
                <b>{totals.answers > 0 ? `${Math.round(groupAccuracy * 100)}%` : "—"}</b>
                <span>正答率</span>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="card-head">
              <div className="card-title" style={{ fontSize: 13 }}>
                試験日カレンダー
              </div>
              <button onClick={() => setScreen("goal")} className="btn-ghost btn-sm">
                {examDateKey ? "変更" : "設定"}
              </button>
            </div>
            <div className="cal-strip">
              {calDays.map((d) => (
                <div
                  key={d.key}
                  className={`cal-day ${d.today ? "today" : ""} ${d.exam ? "exam" : ""}`}
                >
                  <span className="dow">{d.dow}</span>
                  {d.date}
                </div>
              ))}
            </div>
            <p className="mt-3 px-0.5 text-[11px] text-muted2">
              {examDateKey
                ? `${examDateKey.replaceAll("-", "/")} ${goal?.targetName || examName} 受験予定`
                : "試験日を設定すると、逆算した1日のノルマが出ます"}
            </p>
          </div>

          {/* 教科書リンク（試験区分ごと・クリックで外部ページへ） */}
          <div>
            <div className="mb-2 flex items-center justify-between">
              <p className="section-label">教科書・リソース</p>
              {(textbooks.length > 0 || tbEditing) && (
                <button
                  onClick={() => {
                    setTbEditing((v) => !v);
                    setTbError(null);
                  }}
                  className="text-xs text-muted2 transition hover:text-muted"
                >
                  {tbEditing ? "完了" : "編集"}
                </button>
              )}
            </div>

            <div className="card" style={{ padding: 12 }}>
              {textbooks.length > 0 ? (
                <div className="res-list">
                  {textbooks.map((t) => (
                    <div key={t.id} className="res-item">
                      <span className="res-tag" style={{ background: "var(--primary)" }} />
                      <a
                        href={t.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="group min-w-0 flex-1"
                      >
                        <div className="t truncate transition group-hover:text-white">
                          {t.label || t.url}
                        </div>
                        <div className="s truncate">{examName}</div>
                      </a>
                      {tbEditing ? (
                        <button
                          onClick={() => deleteTextbook(t.id)}
                          aria-label="削除"
                          className="shrink-0 rounded-md p-1 text-muted2 transition hover:text-[#ef4444]"
                        >
                          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                            <path d="M6 6l12 12M18 6 6 18" />
                          </svg>
                        </button>
                      ) : (
                        <svg
                          width="13"
                          height="13"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          className="shrink-0 text-muted2"
                        >
                          <path d="M7 17 17 7M9 7h8v8" />
                        </svg>
                      )}
                    </div>
                  ))}
                </div>
              ) : (
                !tbEditing && (
                  <button
                    onClick={() => setTbEditing(true)}
                    className="w-full rounded-xl border border-dashed border-border px-3 py-3 text-left transition hover:border-border2"
                  >
                    <p className="text-[12.5px] text-muted">教科書リンクを追加</p>
                    <p className="text-[10.5px] text-muted2">
                      Claude アーティファクト等の公開ページ URL を貼る
                    </p>
                  </button>
                )
              )}

              {tbEditing && (
                <div className="mt-2">
                  <input
                    type="text"
                    value={tbDraft.label}
                    onChange={(e) => setTbDraft((d) => ({ ...d, label: e.target.value }))}
                    placeholder="タイトル（例: 公式ドキュメントまとめ）"
                    className="mb-2 w-full rounded-lg border border-border bg-card2 px-3 py-2 text-xs text-white outline-none transition-colors placeholder:text-muted2 focus:border-primary"
                  />
                  <input
                    type="url"
                    value={tbDraft.url}
                    onChange={(e) => setTbDraft((d) => ({ ...d, url: e.target.value }))}
                    onKeyDown={(e) => {
                      if (e.key === "Enter") addTextbook();
                    }}
                    placeholder="https://claude.ai/public/artifacts/..."
                    className="w-full rounded-lg border border-border bg-card2 px-3 py-2 text-xs text-white outline-none transition-colors placeholder:text-muted2 focus:border-primary"
                  />
                  {tbError && <p className="mt-1.5 text-[11px] text-[#ef4444]">{tbError}</p>}
                  <button
                    onClick={addTextbook}
                    disabled={!tbDraft.url.trim()}
                    className="btn-primary mt-2.5 w-full"
                    style={{ padding: "9px 16px", fontSize: 12.5 }}
                  >
                    追加
                  </button>
                </div>
              )}
            </div>
          </div>

          <div className="card goal-card">
            <div className="goal-illustration">
              <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#a5b4fc" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
                <path d="M3 12l4-4 4 4 4-8 6 12" />
                <circle cx="7" cy="8" r="1.2" fill="#a5b4fc" stroke="none" />
                <circle cx="11" cy="12" r="1.2" fill="#a5b4fc" stroke="none" />
              </svg>
            </div>
            <h3>学習ロードマップ</h3>
            <p>フェーズごとのマイルストーンで、いまどこにいるかを確認できます。</p>
            <button className="btn-primary" onClick={() => router.push("/roadmap")}>
              ロードマップを見る
            </button>
          </div>

          <div className="card" style={{ padding: 12 }}>
            <div className="res-list">
              {[
                { label: "苦手分析", action: () => setScreen("analysis"), color: "#f87171" },
                ...(examGroupKey(currentSubjectSlug) === "g-kentei"
                  ? [
                      {
                        label: "G検定チートシート",
                        action: () => router.push("/g-kentei/cheatsheet"),
                        color: "#0B5CAB",
                      },
                    ]
                  : []),
                { label: "単語カード", action: () => router.push("/flashcards"), color: "#a78bfa" },
                { label: "思考フレーム", action: () => router.push("/mindset"), color: "#22c55e" },
                { label: "コードの読み方", action: () => router.push("/code-tour"), color: "#f97316" },
                { label: "書き出し（CSV）", action: () => setScreen("export"), color: "#60a5fa" },
              ].map(({ label, action, color }) => (
                <button key={label} onClick={action} className="res-item">
                  <span className="res-tag" style={{ background: color, height: 18 }} />
                  <div className="t">{label}</div>
                  <svg
                    width="13"
                    height="13"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="ml-auto shrink-0 text-muted2"
                  >
                    <path d="M9 18l6-6-6-6" />
                  </svg>
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
