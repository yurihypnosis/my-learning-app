"use client";

import type { ExamGroup } from "@/features/quiz/lib/stats";
import { accuracyColor, fmtLastStudied, statusOf } from "@/features/quiz/lib/format";

export interface WeeklyBar {
  dow: string;
  total: number;
  correct: number;
}

export function Ico({ children }: { children: React.ReactNode }) {
  return (
    <svg
      width="17"
      height="17"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {children}
    </svg>
  );
}

export function StatCard({
  icon,
  color,
  soft,
  trend,
  value,
  label,
  pct,
}: {
  icon: React.ReactNode;
  color: string;
  soft: string;
  trend: string;
  value: string;
  label: string;
  pct: number;
}) {
  return (
    <div className="stat-card">
      <div className="stat-top">
        <div className="stat-icon" style={{ background: soft, color }}>
          {icon}
        </div>
        <span className="stat-trend" style={{ color }}>
          {trend}
        </span>
      </div>
      <div className="stat-value">{value}</div>
      <div className="stat-label">{label}</div>
      <div className="stat-bar">
        <span style={{ width: `${Math.min(100, Math.max(0, pct))}%`, background: color }} />
      </div>
    </div>
  );
}

export interface Totals {
  total: number;
  attempted: number;
  answers: number;
  correct: number;
}

/** 4枚のサマリカード。全体ビューでも問題集スコープでも同じ形で使う。 */
export function StatGrid({
  totals,
  streak,
  weekAnswers,
  firstTrend,
  accuracyTrend,
}: {
  totals: Totals;
  streak: number;
  weekAnswers: number;
  // 1枚目・3枚目の右上に出す文言だけ、全体/スコープで意味が変わる。
  firstTrend: string;
  accuracyTrend: string;
}) {
  const accuracy = totals.answers > 0 ? totals.correct / totals.answers : 0;
  const coverage = totals.total > 0 ? totals.attempted / totals.total : 0;

  return (
    <div className="stat-grid">
      <StatCard
        color="var(--orange)"
        soft="var(--orange-soft)"
        trend={firstTrend}
        value={totals.total.toLocaleString()}
        label="収録されている問題"
        pct={coverage * 100}
        icon={
          <Ico>
            <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
            <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
          </Ico>
        }
      />
      <StatCard
        color="var(--green)"
        soft="var(--green-soft)"
        trend={weekAnswers > 0 ? `+${weekAnswers} 今週` : "今週はまだ"}
        value={totals.attempted.toLocaleString()}
        label={`着手した問題（カバー率 ${Math.round(coverage * 100)}%）`}
        pct={coverage * 100}
        icon={
          <Ico>
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
            <path d="M22 4L12 14.01l-3-3" />
          </Ico>
        }
      />
      <StatCard
        color="var(--primary2)"
        soft="var(--primary-soft)"
        trend={accuracyTrend}
        value={totals.answers > 0 ? `${Math.round(accuracy * 100)}%` : "—"}
        label="正答率"
        pct={accuracy * 100}
        icon={
          <Ico>
            <circle cx="12" cy="8" r="6" />
            <path d="M9 14l-3 7 6-3 6 3-3-7" />
          </Ico>
        }
      />
      <StatCard
        color="var(--purple)"
        soft="var(--purple-soft)"
        trend={streak > 0 ? `${streak}日連続` : "今日から"}
        value={totals.answers.toLocaleString()}
        label="累計解答数"
        pct={Math.min(100, (totals.answers / 2000) * 100)}
        icon={
          <Ico>
            <path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z" />
          </Ico>
        }
      />
    </div>
  );
}

/** 直近7日の解答数。スコープ時は対象の問題集だけを数えた値が渡る。 */
export function ActivityCard({
  weekly,
  sub,
  onOpenLog,
}: {
  weekly: WeeklyBar[];
  sub: string;
  onOpenLog: () => void;
}) {
  const weekAnswers = weekly.reduce((n, d) => n + d.total, 0);
  const weekCorrect = weekly.reduce((n, d) => n + d.correct, 0);
  const weekDays = weekly.filter((d) => d.total > 0).length;
  const max = Math.max(...weekly.map((d) => d.total), 1);

  return (
    <div className="card">
      <div className="card-head">
        <div>
          <div className="card-title">学習アクティビティ</div>
          <div className="card-sub">{sub}</div>
        </div>
        <button onClick={onOpenLog} className="btn-ghost btn-sm">
          学習ログ
        </button>
      </div>
      <div className="bars">
        {weekly.map((d, i) => (
          <div key={i} className="bar-col">
            <div className="bar-track">
              <div
                className={`bar-fill ${i === weekly.length - 1 ? "today" : ""}`}
                style={{ height: d.total > 0 ? `${Math.max(8, (d.total / max) * 100)}%` : "0%" }}
              />
            </div>
            <span
              className="bar-label"
              style={
                i === weekly.length - 1 ? { color: "var(--purple)", fontWeight: 700 } : undefined
              }
            >
              {d.dow}
            </span>
          </div>
        ))}
      </div>
      <div className="stat-mini-row">
        <div className="stat-mini">
          <span className="l">解答数</span>
          <span className="r">{weekAnswers}</span>
        </div>
        <div className="stat-mini">
          <span className="l">学習日数</span>
          <span className="r">{weekDays} / 7日</span>
        </div>
        <div className="stat-mini">
          <span className="l">正答率</span>
          <span className="r">
            {weekAnswers > 0 ? `${Math.round((weekCorrect / weekAnswers) * 100)}%` : "—"}
          </span>
        </div>
      </div>
    </div>
  );
}

const PROGRESS_ROWS = 6;

/** 問題集の進捗テーブル。行クリックでその問題集のダッシュボードへ。 */
export function ProgressTable({
  examGroups,
  currentSubjectSlug,
  now,
  onSelect,
  onSeeAll,
}: {
  examGroups: ExamGroup[];
  currentSubjectSlug: string | null;
  now: number;
  onSelect: (slug: string) => void;
  onSeeAll: () => void;
}) {
  // 「いま開いている試験＋最近やった順」で先頭6件だけ。全件は問題集一覧へ。
  const rows = [...examGroups]
    .sort((a, b) => {
      const ac = a.sets.some((s) => s.slug === currentSubjectSlug);
      const bc = b.sets.some((s) => s.slug === currentSubjectSlug);
      if (ac !== bc) return ac ? -1 : 1;
      return (b.lastAnsweredAt ?? "").localeCompare(a.lastAnsweredAt ?? "");
    })
    .slice(0, PROGRESS_ROWS);

  return (
    <div className="card">
      <div className="card-head">
        <div>
          <div className="card-title">問題集の進捗</div>
          <div className="card-sub">
            最近やった順に {rows.length} 件（行をクリックでその問題集を開く）
          </div>
        </div>
        <button onClick={onSeeAll} className="btn-ghost btn-sm">
          すべて見る（{examGroups.length}）
        </button>
      </div>
      <div className="table-scroll">
        <table className="table" style={{ minWidth: 520 }}>
          <thead>
            <tr>
              <th>問題集</th>
              <th>正答率</th>
              <th>最終演習</th>
              <th>状況</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((g) => {
              const st = statusOf(g.accuracy, g.answers);
              const isCurrent = g.sets.some((s) => s.slug === currentSubjectSlug);
              const target = g.sets.find((s) => s.slug === currentSubjectSlug)?.slug ?? g.sets[0].slug;
              return (
                <tr
                  key={g.examKey}
                  className={isCurrent ? "current-row" : ""}
                  style={{ cursor: "pointer" }}
                  onClick={() => onSelect(target)}
                >
                  <td>
                    <div className="row-subject">
                      <span className="row-dot" style={{ background: st.color }} />
                      <div>
                        <div className="row-name">{g.examName}</div>
                        <div className="row-sub">
                          全{g.total}問 ・ {g.attempted}問着手
                          {g.sets.length > 1 && ` ・ ${g.sets.length}セット`}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <div className="accuracy-track">
                        <div
                          className="accuracy-fill"
                          style={{
                            width: `${Math.round(g.accuracy * 100)}%`,
                            background: accuracyColor(g.accuracy, g.answers),
                          }}
                        />
                      </div>
                      <span className="text-[11.5px] text-muted">
                        {g.answers === 0 ? "—" : `${Math.round(g.accuracy * 100)}%`}
                      </span>
                    </div>
                  </td>
                  <td className="text-[12px] text-muted2">{fmtLastStudied(g.lastAnsweredAt, now)}</td>
                  <td>
                    <span className="status-pill" style={{ color: st.color, background: st.bg }}>
                      {st.label}
                    </span>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
