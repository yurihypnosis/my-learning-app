"use client";

import { usePageHeader } from "@/shared/components/app-shell";
import { shiftKey, WEEKDAYS, type DayEntry } from "./build-days";

const SUBJECT_LABELS: Record<string, string> = {
  "gcp-ace":       "GCP ACE",
  "gh-200":        "GH-200",
  "dca":           "DCA",
  "istqb-ctal-ta": "ISTQB TA",
  "g-kentei":      "G検定",
  "gcp-pcde":      "Cloud DevOps",
};

// ヒートマップの5段階。0 は枠だけの空セル、以降は解答数に応じて青が濃くなる。
const HEAT_STEPS = [
  "var(--card2)",
  "rgba(59,130,246,.25)",
  "rgba(59,130,246,.45)",
  "rgba(59,130,246,.7)",
  "var(--primary2)",
];

function WeeklyBars({ days, todayKey }: { days: DayEntry[]; todayKey: string }) {
  const dayMap = new Map(days.map((d) => [d.dateKey, d.total]));
  const bars = Array.from({ length: 7 }, (_, i) => {
    const key = shiftKey(todayKey, i - 6);
    return {
      key,
      dow: WEEKDAYS[new Date(key + "T00:00:00Z").getUTCDay()],
      count: dayMap.get(key) ?? 0,
    };
  });
  const max = Math.max(...bars.map((b) => b.count), 1);

  return (
    <div className="bars" style={{ height: 100 }}>
      {bars.map((b, i) => (
        <div key={b.key} className="bar-col">
          <div className="bar-track">
            <div
              className={`bar-fill ${i === 6 ? "today" : ""}`}
              style={{ height: b.count > 0 ? `${Math.max(8, (b.count / max) * 100)}%` : "0%" }}
            />
          </div>
          <span
            className="bar-label"
            style={i === 6 ? { color: "var(--purple)", fontWeight: 700 } : undefined}
          >
            {b.dow}
          </span>
        </div>
      ))}
    </div>
  );
}

// 直近90日を GitHub の草のように7行×週列で並べる。列は日曜始まり。
function Heatmap({ days, todayKey }: { days: DayEntry[]; todayKey: string }) {
  const dayMap = new Map(days.map((d) => [d.dateKey, d.total]));
  const max = Math.max(...days.map((d) => d.total), 1);

  // 列を「日曜〜土曜」でそろえるため、90日前の直前の日曜から今週の土曜までを描く。
  const dowOf = (key: string) => new Date(key + "T00:00:00Z").getUTCDay();
  const rawStart = shiftKey(todayKey, -89);
  const start = shiftKey(rawStart, -dowOf(rawStart));
  const end = shiftKey(todayKey, 6 - dowOf(todayKey));
  const length = (Date.parse(end) - Date.parse(start)) / 86_400_000 + 1;

  const cells = Array.from({ length }, (_, i) => {
    const key = shiftKey(start, i);
    const count = dayMap.get(key) ?? 0;
    const future = key > todayKey;
    const level = count === 0 ? 0 : Math.min(4, Math.ceil((count / max) * 4));
    const [, mm, dd] = key.split("-");
    return { key, count, future, level, tip: `${Number(mm)}/${Number(dd)} ・ ${count}問` };
  });

  return (
    <div className="heatmap-wrap">
      <div className="heatmap-grid">
        {cells.map((c) => (
          <div
            key={c.key}
            className="heatmap-cell"
            data-tip={c.future ? undefined : c.tip}
            style={{
              background: c.future ? "transparent" : HEAT_STEPS[c.level],
              border: c.level === 0 && !c.future ? "1px solid var(--border)" : undefined,
              opacity: c.future ? 0.25 : 1,
            }}
          />
        ))}
      </div>
    </div>
  );
}

interface Props {
  // 日別集計はサーバで済ませてある（生イベントは運ばない）。
  days: DayEntry[];
  streak: number;
  totalEvents: number;
  todayKey: string;
}

export function LogClient({ days, streak, totalEvents, todayKey }: Props) {

  usePageHeader("学習ログ", "直近90日の学習記録");

  return (
    <>
      <div className="log-stat-row">
        <div className="log-stat">
          <b>{streak > 0 ? streak : "—"}</b>
          <span>日連続</span>
        </div>
        <div className="log-stat">
          <b>{days.length}</b>
          <span>学習日数 / 90日</span>
        </div>
        <div className="log-stat">
          <b>{totalEvents.toLocaleString()}</b>
          <span>累計解答数</span>
        </div>
      </div>

      {days.length > 0 && (
        <>
          <div className="card" style={{ marginBottom: 16 }}>
            <div className="card-head">
              <div>
                <div className="card-title">直近7日間</div>
                <div className="card-sub">日別の解答数</div>
              </div>
            </div>
            <WeeklyBars days={days} todayKey={todayKey} />
          </div>

          <div className="card" style={{ marginBottom: 16 }}>
            <div className="card-head">
              <div>
                <div className="card-title">学習ヒートマップ</div>
                <div className="card-sub">直近90日の解答数（セルにカーソルを乗せると内訳）</div>
              </div>
              <div className="heatmap-legend">
                少ない
                {HEAT_STEPS.map((bg, i) => (
                  <span
                    key={i}
                    className="sw"
                    style={{ background: bg, border: i === 0 ? "1px solid var(--border)" : undefined }}
                  />
                ))}
                多い
              </div>
            </div>
            <Heatmap days={days} todayKey={todayKey} />
          </div>
        </>
      )}

      <div className="card-title" style={{ marginBottom: 10 }}>
        日別の記録
      </div>

      {days.length === 0 ? (
        <div className="card py-12 text-center">
          <p className="text-sm text-muted">まだ記録がありません</p>
          <p className="mt-1 text-xs text-muted2">
            問題を解く・単語カードをめくると自動的に記録されます
          </p>
        </div>
      ) : (
        days.map((day) => {
          const acc = Math.round((day.correct / day.total) * 100);
          const accColor = acc >= 70 ? "var(--green)" : acc >= 50 ? "var(--amber)" : "var(--red)";
          return (
            <div key={day.dateKey} className="day-card">
              <div className="day-head">
                <span className="lbl">{day.label}</span>
                <span className="time">
                  {day.firstAt} — {day.lastAt}
                </span>
              </div>

              <div className="day-stats">
                <span className="cnt">{day.total} 問</span>
                <div className="acc-track">
                  <div className="acc-fill" style={{ width: `${acc}%`, background: accColor }} />
                </div>
                <span className="acc-pct" style={{ color: accColor }}>
                  {acc}%
                </span>
                <span className="marks">
                  ✓{day.correct} ✗{day.total - day.correct}
                </span>
              </div>

              {day.subjects.length > 0 && (
                <div className="tag-row">
                  {day.subjects.map((s) => (
                    <span key={s.slug} className="tag-chip">
                      {SUBJECT_LABELS[s.slug] ?? s.slug} {s.count}
                    </span>
                  ))}
                </div>
              )}

              <div className="cat-row">
                {day.categories.slice(0, 6).map((c) => (
                  <div key={c.name} className="item">
                    <span className="dot" style={{ background: c.color }} />
                    {c.name} {c.count}
                  </div>
                ))}
                {day.categories.length > 6 && (
                  <div className="item text-muted2">+{day.categories.length - 6}</div>
                )}
              </div>
            </div>
          );
        })
      )}
    </>
  );
}
