"use client";

import { useMemo } from "react";

export interface TrendDay {
  day: string;
  total: number;
  correct: number;
  c1: number;
  c2: number;
  c3: number;
}

// 2本とも「率(%)」なので同じ1本の軸に載せられる（軸を2本持つのは誤読のもと）。
// 青=正答率 / teal=確信あり率。teal は他画面の「確信あり」と同じ色に揃えてある。
const ACCURACY = "#60a5fa";
const SURE = "#14b8a6";

const W = 720;
const PAD = { top: 12, right: 14, left: 34 };
const PLOT_W = W - PAD.left - PAD.right;
const PLOT_H = 148;
const PLOT_BOTTOM = PAD.top + PLOT_H;
// 週ラベル → 解答数の帯 の順に下へ積む（重ならないよう位置を固定する）
const X_LABEL_Y = PLOT_BOTTOM + 14;
const BAR_LABEL_Y = PLOT_BOTTOM + 30;
const BAR_TOP = PLOT_BOTTOM + 34;
const BAR_H = 20;
const H = BAR_TOP + BAR_H + 4;

const MAX_WEEKS = 16;

function shift(key: string, days: number): string {
  const d = new Date(key + "T00:00:00Z");
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}
function dowOf(key: string): number {
  return new Date(key + "T00:00:00Z").getUTCDay();
}
function mmdd(key: string): string {
  const [, mm, dd] = key.split("-");
  return `${Number(mm)}/${Number(dd)}`;
}

interface Week {
  key: string; // 週の始まり(日曜)
  label: string;
  total: number;
  correct: number;
  rated: number;
  sure: number;
  accuracy: number | null;
  sureRate: number | null;
  x: number;
}

/** 日別データを週（日曜始まり）に畳む。記録のある最初の週から今週までを並べる。 */
function toWeeks(days: TrendDay[], todayKey: string): Week[] {
  const byDay = new Map(days.map((d) => [d.day, d]));
  const thisWeek = shift(todayKey, -dowOf(todayKey));
  const active = days.filter((d) => d.total > 0).map((d) => shift(d.day, -dowOf(d.day)));
  if (active.length === 0) return [];

  const earliest = active.reduce((a, b) => (a < b ? a : b));
  const floor = shift(thisWeek, -7 * (MAX_WEEKS - 1));
  const start = earliest > floor ? earliest : floor;

  const keys: string[] = [];
  for (let k = start; k <= thisWeek; k = shift(k, 7)) keys.push(k);

  return keys.map((k, i) => {
    let total = 0;
    let correct = 0;
    let sure = 0;
    let rated = 0;
    for (let d = 0; d < 7; d++) {
      const rec = byDay.get(shift(k, d));
      if (!rec) continue;
      total += rec.total;
      correct += rec.correct;
      sure += rec.c1;
      rated += rec.c1 + rec.c2 + rec.c3;
    }
    return {
      key: k,
      label: mmdd(k),
      total,
      correct,
      rated,
      sure,
      accuracy: total > 0 ? (correct / total) * 100 : null,
      sureRate: rated > 0 ? (sure / rated) * 100 : null,
      x: PAD.left + (keys.length === 1 ? PLOT_W / 2 : (PLOT_W * i) / (keys.length - 1)),
    };
  });
}

const yOf = (pct: number) => PAD.top + PLOT_H - (pct / 100) * PLOT_H;

/**
 * 値のある週だけを線でつなぐ。隣り合う週が飛んでいる場合は実線を切り、
 * 点線で渡す（記録のない週を実測値のように見せないため）。
 */
function segments(weeks: Week[], pick: (w: Week) => number | null) {
  const pts = weeks
    .map((w, i) => ({ i, x: w.x, v: pick(w) }))
    .filter((p): p is { i: number; x: number; v: number } => p.v !== null);
  const solid: string[] = [];
  const dashed: string[] = [];
  for (let n = 1; n < pts.length; n++) {
    const a = pts[n - 1];
    const b = pts[n];
    const d = `M${a.x} ${yOf(a.v)} L${b.x} ${yOf(b.v)}`;
    (b.i - a.i === 1 ? solid : dashed).push(d);
  }
  return { pts, solid: solid.join(" "), dashed: dashed.join(" ") };
}

export function TrendCard({
  days,
  todayKey,
  examName,
}: {
  days: TrendDay[];
  todayKey: string;
  examName: string;
}) {
  const weeks = useMemo(() => toWeeks(days, todayKey), [days, todayKey]);
  const acc = useMemo(() => segments(weeks, (w) => w.accuracy), [weeks]);
  const sure = useMemo(() => segments(weeks, (w) => w.sureRate), [weeks]);
  const maxTotal = Math.max(...weeks.map((w) => w.total), 1);

  if (weeks.length === 0) {
    return (
      <div className="card">
        <div className="card-head">
          <div>
            <div className="card-title">正答率と確信度の推移</div>
            <div className="card-sub">{examName}</div>
          </div>
        </div>
        <p className="py-8 text-center text-xs text-muted2">
          まだ解答の記録がありません。演習すると週ごとの推移がここに出ます。
        </p>
      </div>
    );
  }

  // x 目盛りが詰まりすぎないよう間引く（最初と最後は必ず出す）
  const tickEvery = Math.max(1, Math.ceil(weeks.length / 8));
  const showTick = (i: number) => i === 0 || i === weeks.length - 1 || i % tickEvery === 0;

  const lastOf = (s: { pts: { v: number }[] }) => s.pts[s.pts.length - 1];
  const lastAcc = lastOf(acc);
  const lastSure = lastOf(sure);

  return (
    <div className="card">
      <div className="card-head">
        <div>
          <div className="card-title">正答率と確信度の推移</div>
          <div className="card-sub">
            {examName}・週ごと（{weeks.length}週）
          </div>
        </div>
        <div className="trend-legend">
          <span className="trend-legend-item">
            <span className="sw" style={{ background: ACCURACY }} />
            正答率
            {lastAcc && <b>{Math.round(lastAcc.v)}%</b>}
          </span>
          <span className="trend-legend-item">
            <span className="sw sw-dash" style={{ borderColor: SURE }} />
            「確信あり」の割合
            {lastSure && <b>{Math.round(lastSure.v)}%</b>}
          </span>
        </div>
      </div>

      <div className="trend-chart">
        <svg
          viewBox={`0 0 ${W} ${H}`}
          className="trend-svg"
          role="img"
          aria-label={`週ごとの正答率と確信あり率の推移。直近の正答率 ${lastAcc ? Math.round(lastAcc.v) : "—"}%`}
        >
          {/* 横の目盛り（0/25/50/75/100%） */}
          {[0, 25, 50, 75, 100].map((v) => (
            <g key={v}>
              <line
                x1={PAD.left}
                x2={W - PAD.right}
                y1={yOf(v)}
                y2={yOf(v)}
                stroke="var(--border)"
                strokeWidth="1"
                vectorEffect="non-scaling-stroke"
              />
              <text x={PAD.left - 6} y={yOf(v) + 3.5} textAnchor="end" className="trend-axis">
                {v === 100 ? "100%" : v}
              </text>
            </g>
          ))}

          {/* 週の目盛りとラベル */}
          {weeks.map((w, i) =>
            showTick(i) ? (
              <g key={w.key}>
                <line
                  x1={w.x}
                  x2={w.x}
                  y1={PAD.top}
                  y2={PAD.top + PLOT_H}
                  stroke="var(--border)"
                  strokeWidth="1"
                  opacity="0.45"
                  vectorEffect="non-scaling-stroke"
                />
                <text x={w.x} y={X_LABEL_Y} textAnchor="middle" className="trend-axis">
                  {w.label}
                </text>
              </g>
            ) : null
          )}

          {/* 記録の飛んでいる区間は点線で渡す（実測ではないことを示す） */}
          {acc.dashed && (
            <path d={acc.dashed} fill="none" stroke={ACCURACY} strokeWidth="2" strokeDasharray="2 4" opacity="0.4" vectorEffect="non-scaling-stroke" />
          )}
          {sure.dashed && (
            <path d={sure.dashed} fill="none" stroke={SURE} strokeWidth="2" strokeDasharray="2 4" opacity="0.4" vectorEffect="non-scaling-stroke" />
          )}

          <path d={acc.solid} fill="none" stroke={ACCURACY} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" vectorEffect="non-scaling-stroke" />
          {/* 確信あり率は破線。色以外でも見分けられるようにする */}
          <path d={sure.solid} fill="none" stroke={SURE} strokeWidth="2" strokeDasharray="6 4" strokeLinecap="round" strokeLinejoin="round" vectorEffect="non-scaling-stroke" />

          {acc.pts.map((p) => (
            <circle key={p.i} cx={p.x} cy={yOf(p.v)} r="4" fill={ACCURACY} stroke="var(--card)" strokeWidth="2" />
          ))}
          {sure.pts.map((p) => (
            <rect key={p.i} x={p.x - 3.5} y={yOf(p.v) - 3.5} width="7" height="7" rx="1.5" fill={SURE} stroke="var(--card)" strokeWidth="2" />
          ))}

          {/* 解答数は単位が違うので同じ軸に載せず、下に別の帯として置く */}
          <text x={PAD.left} y={BAR_LABEL_Y} className="trend-axis">
            解答数（最大 {maxTotal}問）
          </text>
          {weeks.map((w) => {
            if (w.total === 0) return null;
            const h = Math.max(2, (w.total / maxTotal) * BAR_H);
            const bw = Math.max(4, Math.min(12, PLOT_W / weeks.length - 6));
            return (
              <rect
                key={w.key}
                x={w.x - bw / 2}
                y={BAR_TOP + BAR_H - h}
                width={bw}
                height={h}
                rx="2"
                fill="var(--border2)"
                opacity="0.85"
              />
            );
          })}
        </svg>

        {/* ツールチップ用の当たり判定。SVG に ::after は使えないので HTML を重ねる。 */}
        <div className="trend-hit">
          {weeks.map((w) => (
            <div
              key={w.key}
              className="trend-hit-col"
              data-tip={
                w.total > 0
                  ? `${w.label}の週｜${w.correct}/${w.total}問正解（${Math.round(w.accuracy!)}%）` +
                    (w.rated > 0 ? `・確信あり ${Math.round(w.sureRate!)}%` : "")
                  : `${w.label}の週｜記録なし`
              }
            />
          ))}
        </div>
      </div>
    </div>
  );
}
