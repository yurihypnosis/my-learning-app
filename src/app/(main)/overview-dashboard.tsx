"use client";

import { useRouter } from "next/navigation";
import type { ExamGroup } from "@/features/quiz/lib/stats";
import { useNow } from "@/features/quiz/hooks/use-now";
import { fmtLastStudied } from "@/features/quiz/lib/format";
import {
  ActivityCard,
  ProgressTable,
  StatGrid,
  type WeeklyBar,
} from "@/features/quiz/components/dashboard-parts";
import { usePageHeader, useCurrentSubject } from "@/shared/components/app-shell";

interface Props {
  examGroups: ExamGroup[];
  streak: number;
  weekly: WeeklyBar[];
  // 直近の試験日（全区分から一番近いもの）。無ければ null。
  nextExam: { examKey: string; examDate: string; targetName: string; slug: string } | null;
  // 前回学習した問題集（「続きから」導線用）
  lastStudied: { slug: string; name: string } | null;
}

// 問題集を選ぶ前のダッシュボード。全試験区分を合算した「見渡す」ビュー。
// 合格ナビ・演習・教科書は試験区分が決まらないと意味を持たないので出さない。
export function OverviewDashboard({ examGroups, streak, weekly, nextExam, lastStudied }: Props) {
  const router = useRouter();
  const now = useNow();

  usePageHeader("ダッシュボード", "すべての問題集の合計。問題集を選ぶと、その問題集の状況に切り替わります。", "/");
  useCurrentSubject("", "");

  const totals = examGroups.reduce(
    (a, g) => ({
      total: a.total + g.total,
      attempted: a.attempted + g.attempted,
      answers: a.answers + g.answers,
      correct: a.correct + g.correct,
    }),
    { total: 0, attempted: 0, answers: 0, correct: 0 }
  );
  const accuracy = totals.answers > 0 ? totals.correct / totals.answers : 0;
  const passingExams = examGroups.filter((g) => g.answers > 0 && g.accuracy >= 0.7).length;
  const weekAnswers = weekly.reduce((n, d) => n + d.total, 0);
  const daysLeft =
    nextExam && now > 0
      ? Math.ceil((Date.parse(nextExam.examDate + "T00:00:00+09:00") - now) / 86_400_000)
      : null;

  const open = (slug: string) => router.push(`/?subject=${slug}`);

  return (
    <>
      <StatGrid
        totals={totals}
        streak={streak}
        weekAnswers={weekAnswers}
        firstTrend={`${examGroups.length} 試験区分`}
        accuracyTrend={`合格圏 ${passingExams} 区分`}
      />

      <div className="content-grid">
        <div className="col-main">
          <div className="two-up">
            <ActivityCard
              weekly={weekly}
              sub="直近7日間の解答数（全問題集）"
              onOpenLog={() => router.push("/log")}
            />

            {/* 試験区分に依存するカードの代わりに、選択への導線を置く */}
            <div className="card start-card flex flex-col justify-center text-center">
              <div className="goal-illustration">
                <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#a5b4fc" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M12 2 2 7l10 5 10-5-10-5z" />
                  <path d="M2 17l10 5 10-5M2 12l10 5 10-5" />
                </svg>
              </div>
              <div className="card-title">問題集を選ぶ</div>
              <p className="mx-auto mt-1.5 max-w-[260px] text-[11.5px] leading-relaxed text-muted">
                選ぶと、その問題集の合格ナビ・演習・苦手分析が使えるようになります。
              </p>
              <div className="mt-4 flex flex-col gap-2">
                {lastStudied && (
                  <button className="btn-primary" onClick={() => open(lastStudied.slug)}>
                    続きから — {lastStudied.name}
                  </button>
                )}
                <button className="btn-ghost" onClick={() => router.push("/catalog")}>
                  問題集一覧から選ぶ
                </button>
              </div>
            </div>
          </div>

          <ProgressTable
            examGroups={examGroups}
            currentSubjectSlug={null}
            now={now}
            onSelect={open}
            onSeeAll={() => router.push("/catalog")}
          />
        </div>

        <div className="col-side">
          <div className="card profile-card">
            <div className="profile-avatar">学</div>
            <div className="profile-name">すべての問題集</div>
            <div className="profile-role">{examGroups.length} 試験区分の合計</div>
            <div className="profile-stats">
              <div className="profile-stat">
                <b>{examGroups.length}</b>
                <span>受験区分</span>
              </div>
              <div className="profile-stat">
                <b>{streak}</b>
                <span>連続学習日</span>
              </div>
              <div className="profile-stat">
                <b>{totals.answers > 0 ? `${Math.round(accuracy * 100)}%` : "—"}</b>
                <span>平均正答率</span>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="card-head">
              <div className="card-title" style={{ fontSize: 13 }}>
                次の試験
              </div>
            </div>
            {nextExam ? (
              <button className="res-item w-full" onClick={() => open(nextExam.slug)}>
                <span className="res-tag" style={{ background: "var(--red)" }} />
                <div className="min-w-0 flex-1 text-left">
                  <div className="t truncate">{nextExam.targetName}</div>
                  <div className="s">{nextExam.examDate.replaceAll("-", "/")}</div>
                </div>
                {daysLeft !== null && (
                  <span className="shrink-0 text-[12px] font-bold text-[#f87171]">
                    {daysLeft >= 0 ? `残り${daysLeft}日` : "終了"}
                  </span>
                )}
              </button>
            ) : (
              <p className="text-[11px] text-muted2">
                試験日はまだ設定されていません。問題集を開いて設定できます。
              </p>
            )}
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
                { label: "問題集一覧", href: "/catalog", color: "#60a5fa" },
                { label: "単語カード", href: "/flashcards", color: "#a78bfa" },
                { label: "学習ログ", href: "/log", color: "#22c55e" },
                { label: "思考フレーム", href: "/mindset", color: "#f59e0b" },
                { label: "コードの読み方", href: "/code-tour", color: "#f97316" },
              ].map(({ label, href, color }) => (
                <button key={href} onClick={() => router.push(href)} className="res-item">
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
            <p className="mt-2 px-1 text-[10.5px] leading-relaxed text-muted2">
              苦手分析・書き出しは問題集ごとの機能です。
              {lastStudied && (
                <>
                  {" "}
                  <button
                    className="underline decoration-dotted hover:text-muted"
                    onClick={() => router.push(`/?subject=${lastStudied.slug}&screen=analysis`)}
                  >
                    {lastStudied.name} の苦手分析を開く
                  </button>
                </>
              )}
            </p>
          </div>
        </div>
      </div>

      {examGroups.length > 0 && (
        <p className="mt-4 text-[11px] text-muted2">
          最終学習: {fmtLastStudied(
            examGroups.reduce<string | null>(
              (acc, g) => (g.lastAnsweredAt && (!acc || g.lastAnsweredAt > acc) ? g.lastAnsweredAt : acc),
              null
            ),
            now
          )}
        </p>
      )}
    </>
  );
}
