import { useMemo, useState } from "react";
import { getProgress, totalCorrect, totalWrong, type ProgressMap } from "@/features/quiz/lib/selection";
import {
  type ExamGroup,
  type SectionQuestionRef,
  analyzeSections,
  sectionOverview,
  weakReviewPool,
} from "@/features/quiz/lib/stats";
import { type QuizQuestion } from "@/features/quiz/lib/types";
import { type Screen } from "@/features/quiz/hooks/use-screen";
import {
  CONFIDENCE_COLORS,
  CONFIDENCE_LABELS,
  COMPREHENSION_LEVELS,
  WEAK_SESSION_MAX,
} from "@/features/quiz/lib/constants";

// 「弱点問題」の絞り込み条件。既定は正誤・演習量から出す弱点順、
// 残り3つは不正解時に自己申告した理解度（1..3）で絞る（旧「理解度で見直す」画面を統合）。
type WeakFilter = "all" | 1 | 2 | 3;
const WEAK_FILTERS: { key: WeakFilter; label: string; color: string }[] = [
  { key: "all", label: "弱点順", color: "#8892a4" },
  ...COMPREHENSION_LEVELS.map((c) => ({ key: c.level as WeakFilter, label: c.label, color: c.color })),
];

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
  const [weakFilter, setWeakFilter] = useState<WeakFilter>("all");

  // 試験全体（全Set合算）の分野別分析。547問ぶんの集計なので、
  // フィルタ切り替えや分野の開閉で作り直さないよう memo 化する。
  const sections = useMemo(
    () => analyzeSections(examSections, progressMap),
    [examSections, progressMap]
  );
  const overview = useMemo(() => sectionOverview(sections), [sections]);
  const examName =
    examGroups.find((g) => g.examKey === currentExamKey)?.examName ?? subjectName;
  const setNameOf = new Map(examGroups.flatMap((g) => g.sets).map((s) => [s.slug, s.name]));
  const shortSet = (slug: string): string => {
    const n = setNameOf.get(slug) ?? slug;
    const s = n.replace(examName, "").replace(/[（()）]/g, "").trim();
    return s || n;
  };
  // 弱点順に並べる: 演習済みは習熟度が低い順、未着手は末尾
  const ranked = useMemo(
    () =>
      [...sections].sort((a, b) => {
        const aa = a.attempted > 0;
        const bb = b.attempted > 0;
        if (aa !== bb) return aa ? -1 : 1;
        if (aa) return a.mastery - b.mastery;
        return a.sort - b.sort;
      }),
    [sections]
  );
  const secColor = (pct: number, attempted: number): string =>
    attempted === 0 ? "#59627a" : pct >= 70 ? "#22c55e" : pct >= 40 ? "#f59e0b" : "#ef4444";
  const overPct = Math.round(overview.mastery * 100);

  // 自己申告した理解度（1..3）が付いている問題（不正解時にクイズ画面から申告）
  const ratedQuestions = useMemo(
    () =>
      examQuestions.filter((q) => {
        const lv = getProgress(progressMap, q.id).understanding_level;
        return lv >= 1 && lv <= 3;
      }),
    [examQuestions, progressMap]
  );
  const countOfLevel = (level: number) =>
    ratedQuestions.filter((q) => getProgress(progressMap, q.id).understanding_level === level).length;

  // 弱点問題（試験区分の全セット横断）。既定は弱点順（正誤・演習量ベース）に上位8問、
  // 理解度フィルタを選ぶと自己申告「わからない」順に切り替わる。
  const worst = useMemo(
    () =>
      weakFilter === "all"
        ? weakReviewPool(examQuestions, progressMap, { limit: 8 })
        : ratedQuestions
            .filter((q) => getProgress(progressMap, q.id).understanding_level === weakFilter)
            .sort(
              (a, b) =>
                totalWrong(b, getProgress(progressMap, b.id)) -
                totalWrong(a, getProgress(progressMap, a.id))
            ),
    [weakFilter, examQuestions, progressMap, ratedQuestions]
  );

  // 確信度キャリブレーション（直近の解答: 自信度 × 正誤・全セット横断）。
  // 「自信あり」なのに誤答 = 思い込みの危険ゾーン（最優先で復習すべき）。
  const { cal, dangerQs } = useMemo(() => {
    const c = { sureCorrect: 0, sureWrong: 0, unsureCorrect: 0, unsureWrong: 0 };
    const danger: QuizQuestion[] = [];
    for (const q of examQuestions) {
      const p = getProgress(progressMap, q.id);
      if (p.last_confidence === null || p.last_is_correct === null) continue;
      const sure = p.last_confidence === 1;
      if (p.last_is_correct) sure ? c.sureCorrect++ : c.unsureCorrect++;
      else if (sure) {
        c.sureWrong++;
        danger.push(q);
      } else c.unsureWrong++;
    }
    return { cal: c, dangerQs: danger };
  }, [examQuestions, progressMap]);

  return (
    <div className="max-w-[900px]">
      {/* 試験全体サマリ（全Set合算） */}
      <div className="card overview-card">
        <div>
          <div className="card-sub" style={{ marginBottom: 2 }}>
            試験全体{isMultiSet && "・全セット横断"}
          </div>
          <div className="card-title" style={{ fontSize: 15 }}>
            {examName}
          </div>
          <div className="overview-meta">
            <span>
              カバー率 {Math.round(overview.coverage * 100)}%（{overview.attempted}/{overview.total}）
            </span>
            <span>分野 {overview.sectionCount}</span>
            {overview.weakSections > 0 && (
              <span>
                弱点分野 <b>{overview.weakSections}</b>
              </span>
            )}
          </div>
        </div>
        <div className="overview-score">
          <div className="big" style={{ color: secColor(overPct, overview.attempted) }}>
            {overview.attempted === 0 ? "—" : `${overPct}%`}
          </div>
          <div className="overview-score-track">
            <div
              className="h-full rounded-full transition-all"
              style={{
                width: `${overview.attempted === 0 ? 0 : overPct}%`,
                background: secColor(overPct, overview.attempted),
              }}
            />
          </div>
        </div>
      </div>

      {/* 分野別 苦手マップ（弱点順・全Set合算・タップでSet別内訳） */}
      <div className="card-title" style={{ marginBottom: 2 }}>
        分野別 苦手マップ
      </div>
      <div className="card-sub" style={{ marginBottom: 12 }}>
        弱点が上・クリックでセット別内訳
      </div>

      {ranked.length === 0 && <p className="mb-5 text-xs text-muted2">まだデータがありません</p>}
      {ranked.map((sec) => {
        const pct = Math.round(sec.mastery * 100);
        const open = expandedSection === sec.name;
        const color = secColor(pct, sec.attempted);
        return (
          <div
            key={sec.name}
            role="button"
            tabIndex={0}
            className={`section-row ${open ? "open" : ""}`}
            onClick={() => setExpandedSection(open ? null : sec.name)}
            onKeyDown={(e) => {
              if (e.key === "Enter" || e.key === " ") setExpandedSection(open ? null : sec.name);
            }}
          >
            <div className="srow-top">
              <div className="srow-left">
                <svg width="9" height="9" viewBox="0 0 10 10" fill="none">
                  <path
                    d="M3.5 2L6.5 5L3.5 8"
                    stroke="currentColor"
                    strokeWidth="1.5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
                <span
                  className="h-2 w-2 shrink-0 rounded-full"
                  style={{ background: sec.color }}
                />
                <span className="sname truncate">{sec.name}</span>
              </div>
              <div className="sright">
                <span>
                  {sec.attempted}/{sec.total}
                </span>
                <span className="spct" style={{ color }}>
                  {sec.attempted === 0 ? "未着" : `${pct}%`}
                </span>
              </div>
            </div>
            <div className="strack">
              <div
                className="sfill"
                style={{ width: `${sec.attempted === 0 ? 0 : pct}%`, background: color }}
              />
            </div>

            {open && (
              <div className="set-list">
                {sec.sets.map((st) => {
                  const sp = Math.round(st.mastery * 100);
                  const sc = secColor(sp, st.attempted);
                  return (
                    <div key={st.slug} className="set-row">
                      <b>{shortSet(st.slug)}</b>
                      <span style={{ color: sc }}>
                        {st.attempted}/{st.total} ・ {st.attempted === 0 ? "未着" : `${sp}%`}
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        );
      })}

      {/* 弱点問題 */}
      <div className="catalog-toolbar" style={{ marginTop: 20, marginBottom: 12 }}>
        <div className="card-title">{isMultiSet ? "弱点問題（全セット）" : "弱点問題"}</div>
        {worst.length > 0 && (
          <button
            className="btn-ghost btn-sm"
            onClick={() => startReview(worst.slice(0, WEAK_SESSION_MAX))}
          >
            まとめて復習 →
          </button>
        )}
      </div>

      {/* 絞り込み: 既定は弱点順、または不正解時に申告した理解度で絞る */}
      <div className="filter-chips" style={{ marginBottom: 14 }}>
        {WEAK_FILTERS.map(({ key, label, color }) => {
          const on = weakFilter === key;
          const n = key === "all" ? undefined : countOfLevel(key as number);
          return (
            <button
              key={String(key)}
              onClick={() => setWeakFilter(key)}
              className="filter-chip"
              style={{
                borderColor: on ? color + "55" : undefined,
                color: on ? color : undefined,
                background: on ? color + "14" : undefined,
              }}
            >
              <span
                className="h-1.5 w-1.5 shrink-0 rounded-full"
                style={{ background: on ? color : "#343a4a" }}
              />
              {label}
              {n !== undefined && <span className="n">{n}</span>}
            </button>
          );
        })}
      </div>

      <p className="mb-2.5 text-[10.5px] text-muted2">クリックするとその問題だけを復習できます</p>

      <div className="mb-6">
        {worst.length === 0 && (
          <p className="text-xs text-muted2">
            {weakFilter === "all"
              ? "弱点問題はありません（演習するとここに出ます）"
              : "この理解度で申告した問題はありません（不正解時に解説の下で申告できます）"}
          </p>
        )}
        {worst.map((q) => {
          const p = getProgress(progressMap, q.id);
          const understandingMeta =
            p.understanding_level >= 1 && p.understanding_level <= 3
              ? COMPREHENSION_LEVELS.find((c) => c.level === p.understanding_level)
              : undefined;
          return (
            <button key={q.id} onClick={() => startReview([q])} className="weak-q-row">
              <span className="qdot" style={{ background: q.category_color }} />
              <div className="min-w-0 flex-1">
                <p className="qtext">{q.question_text}</p>
                <p className="qmeta">
                  {isMultiSet && <span>{shortSet(examQuestionSlug[q.id] ?? "")}</span>}
                  <span>
                    誤 {totalWrong(q, p)} 正 {totalCorrect(p)}
                  </span>
                  {p.last_confidence !== null && (
                    <span style={{ color: CONFIDENCE_COLORS[(p.last_confidence ?? 1) - 1] }}>
                      {CONFIDENCE_LABELS[(p.last_confidence ?? 1) - 1]}
                    </span>
                  )}
                  {understandingMeta && (
                    <span style={{ color: understandingMeta.color }}>{understandingMeta.label}</span>
                  )}
                </p>
              </div>
              <span className="arrow">→</span>
            </button>
          );
        })}
      </div>

      {/* 確信度キャリブレーション */}
      <div className="card-title" style={{ marginBottom: 2 }}>
        確信度キャリブレーション
      </div>
      <div className="card-sub" style={{ marginBottom: 12 }}>
        「自信あり」なのに誤答＝思い込みの危険ゾーン
      </div>

      {cal.sureWrong > 0 && (
        <div className="danger-banner">
          <div>
            <p className="m-0 text-[12.5px] font-bold text-[#f87171]">
              「自信あり」なのに誤答 {cal.sureWrong}問
            </p>
            <p className="m-0 mt-0.5 text-[11px] text-muted">最優先で復習を。</p>
          </div>
          <button
            className="btn-ghost btn-sm"
            style={{ borderColor: "rgba(239,68,68,.4)", color: "var(--red)" }}
            onClick={() => startReview(dangerQs)}
          >
            復習 →
          </button>
        </div>
      )}

      <div className="cal-grid" style={{ marginBottom: 20 }}>
        <div />
        <div className="hd">正解</div>
        <div className="hd">誤答</div>
        <div className="rl">自信あり</div>
        <div className="cell">
          <b style={{ color: "var(--green)" }}>{cal.sureCorrect}</b>
        </div>
        <div className={`cell ${cal.sureWrong > 0 ? "danger" : ""}`}>
          <b style={{ color: cal.sureWrong > 0 ? undefined : "#343a4a" }}>{cal.sureWrong}</b>
        </div>
        <div className="rl">自信なし</div>
        <div className="cell">
          <b style={{ color: "var(--muted)" }}>{cal.unsureCorrect}</b>
        </div>
        <div className="cell">
          <b style={{ color: "var(--muted)" }}>{cal.unsureWrong}</b>
        </div>
      </div>

      {/* FSRS 再構築（過去の解答から記憶エンジンを一括計算） */}
      <div className="card flex items-center justify-between gap-3">
        <div className="min-w-0">
          <p className="m-0 text-[12.5px] font-semibold">記憶エンジンを再構築</p>
          <p className="m-0 mt-0.5 text-[11px] text-muted2">
            過去の解答から復習間隔・合格ナビの精度を作り直します
          </p>
          {backfillMsg && <p className="mt-2 text-[11px] text-[#3E8E6E]">{backfillMsg}</p>}
        </div>
        <button
          className="btn-ghost btn-sm shrink-0"
          onClick={runBackfill}
          disabled={backfilling}
          style={backfilling ? { opacity: 0.5 } : undefined}
        >
          {backfilling ? "計算中…" : "⟳ 再構築"}
        </button>
      </div>

      <div className="mt-4">
        <button className="btn-ghost btn-sm" onClick={() => setScreen("menu")}>
          ← ダッシュボードへ戻る
        </button>
      </div>
    </div>
  );
}
