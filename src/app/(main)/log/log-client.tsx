"use client";

import Link from "next/link";

export interface AnswerEvent {
  answered_at: string;
  is_correct: boolean;
  confidence: number | null;
  category_name: string;
  category_color: string;
  subject_slug: string;
}

interface DayEntry {
  dateKey: string;       // YYYY-MM-DD (JST)
  label: string;         // 今日 / 昨日 / MM/DD (曜)
  total: number;
  correct: number;
  categories: { name: string; color: string; count: number }[];
  subjects: { slug: string; count: number }[];
  firstAt: string;       // 最初の回答時刻 HH:mm
  lastAt: string;        // 最後の回答時刻 HH:mm
}

const SUBJECT_LABELS: Record<string, string> = {
  "gcp-ace": "GCP ACE",
  "gh-200":  "GH-200",
  "dca":     "DCA",
};

const WEEKDAYS = ["日", "月", "火", "水", "木", "金", "土"];

function toJSTDate(iso: string): Date {
  const d = new Date(iso);
  // UTC+9
  return new Date(d.getTime() + 9 * 60 * 60 * 1000);
}

function toDateKey(iso: string): string {
  const d = toJSTDate(iso);
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, "0")}-${String(d.getUTCDate()).padStart(2, "0")}`;
}

function toTimeLabel(iso: string): string {
  const d = toJSTDate(iso);
  return `${String(d.getUTCHours()).padStart(2, "0")}:${String(d.getUTCMinutes()).padStart(2, "0")}`;
}

function buildDays(events: AnswerEvent[], todayKey: string, yesterdayKey: string): DayEntry[] {
  const map = new Map<string, AnswerEvent[]>();
  for (const ev of events) {
    const key = toDateKey(ev.answered_at);
    if (!map.has(key)) map.set(key, []);
    map.get(key)!.push(ev);
  }

  return Array.from(map.entries())
    .sort(([a], [b]) => b.localeCompare(a))
    .map(([key, evs]) => {
      const d = new Date(key + "T00:00:00+09:00");
      const dow = WEEKDAYS[d.getDay()];
      const mm = d.getMonth() + 1;
      const dd = d.getDate();

      const label =
        key === todayKey
          ? `今日 (${mm}/${dd}・${dow})`
          : key === yesterdayKey
            ? `昨日 (${mm}/${dd}・${dow})`
            : `${mm}/${dd}（${dow}）`;

      const catMap = new Map<string, { color: string; count: number }>();
      const subMap = new Map<string, number>();
      let correct = 0;

      for (const ev of evs) {
        if (ev.is_correct) correct++;
        const prev = catMap.get(ev.category_name);
        catMap.set(ev.category_name, {
          color: ev.category_color,
          count: (prev?.count ?? 0) + 1,
        });
        subMap.set(ev.subject_slug, (subMap.get(ev.subject_slug) ?? 0) + 1);
      }

      const sorted = evs.map((e) => e.answered_at).sort();

      return {
        dateKey: key,
        label,
        total: evs.length,
        correct,
        categories: Array.from(catMap.entries())
          .map(([name, v]) => ({ name, color: v.color, count: v.count }))
          .sort((a, b) => b.count - a.count),
        subjects: Array.from(subMap.entries())
          .map(([slug, count]) => ({ slug, count }))
          .sort((a, b) => b.count - a.count),
        firstAt: toTimeLabel(sorted[0]),
        lastAt: toTimeLabel(sorted[sorted.length - 1]),
      };
    });
}

function calcStreak(days: DayEntry[], todayKey: string): number {
  const set = new Set(days.map((d) => d.dateKey));
  const start = set.has(todayKey) ? todayKey : (() => {
    const d = new Date(todayKey + "T00:00:00+09:00");
    d.setDate(d.getDate() - 1);
    const y = d.toISOString().slice(0, 10);
    return set.has(y) ? y : null;
  })();
  if (!start) return 0;

  let streak = 0;
  const cur = new Date(start + "T00:00:00+09:00");
  while (set.has(cur.toISOString().slice(0, 10))) {
    streak++;
    cur.setDate(cur.getDate() - 1);
  }
  return streak;
}

function WeeklyBar({ days, todayKey }: { days: DayEntry[]; todayKey: string }) {
  const dayMap = new Map(days.map((d) => [d.dateKey, d.total]));
  const bars = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(todayKey + "T00:00:00+09:00");
    d.setDate(d.getDate() - (6 - i));
    const key = d.toISOString().slice(0, 10);
    const dow = WEEKDAYS[d.getDay()];
    const mm = d.getMonth() + 1;
    const dd = d.getDate();
    return { key, label: `${mm}/${dd}`, dow, count: dayMap.get(key) ?? 0 };
  });
  const max = Math.max(...bars.map((b) => b.count), 1);

  return (
    <div className="flex items-end justify-between gap-1">
      {bars.map((b) => {
        const isToday = b.key === todayKey;
        const pct = (b.count / max) * 100;
        return (
          <div key={b.key} className="flex flex-1 flex-col items-center gap-1">
            <span className="text-[9px] text-muted2">{b.count > 0 ? b.count : ""}</span>
            <div className="w-full overflow-hidden rounded-t" style={{ height: 40 }}>
              <div
                className="w-full rounded-t transition-all"
                style={{
                  height: `${Math.max(pct, b.count > 0 ? 8 : 0)}%`,
                  background: isToday
                    ? "linear-gradient(to top, #2563eb, #60a5fa)"
                    : b.count > 0
                      ? "#1e3a5f"
                      : "transparent",
                  marginTop: `${100 - Math.max(pct, b.count > 0 ? 8 : 0)}%`,
                }}
              />
            </div>
            <span
              className="text-[9px] font-bold"
              style={{ color: isToday ? "#60a5fa" : "#475569" }}
            >
              {b.dow}
            </span>
          </div>
        );
      })}
    </div>
  );
}

interface Props {
  events: AnswerEvent[];
  todayKey: string;
  yesterdayKey: string;
  totalEvents: number;
}

export function LogClient({ events, todayKey, yesterdayKey, totalEvents }: Props) {
  const days = buildDays(events, todayKey, yesterdayKey);
  const streak = calcStreak(days, todayKey);
  const totalDays = days.length;
  const totalCorrect = events.filter((e) => e.is_correct).length;

  const page = "flex flex-col items-center px-3.5 pb-24 pt-5";
  const card = "w-full max-w-[560px] rounded-2xl bg-card p-5 shadow-2xl sm:p-6";

  return (
    <div className={page}>
      <div className={card}>
        {/* Header */}
        <div className="mb-4">
          <h2 className="text-lg font-extrabold text-slate-100">📅 学習ログ</h2>
        </div>

        {/* Stats */}
        <div className="mb-4 grid grid-cols-3 gap-2">
          <div className="rounded-xl bg-card2 px-3 py-3 text-center">
            <p className="text-xl font-extrabold text-orange-400">
              {streak > 0 ? `🔥 ${streak}` : "—"}
            </p>
            <p className="text-[9px] text-muted2">日連続</p>
          </div>
          <div className="rounded-xl bg-card2 px-3 py-3 text-center">
            <p className="text-xl font-extrabold text-sky-400">{totalDays}</p>
            <p className="text-[9px] text-muted2">日間学習</p>
          </div>
          <div className="rounded-xl bg-card2 px-3 py-3 text-center">
            <p className="text-xl font-extrabold text-slate-200">{events.length}</p>
            <p className="text-[9px] text-muted2">問演習</p>
          </div>
        </div>

        {/* Weekly bar chart */}
        {days.length > 0 && (
          <div className="mb-5 rounded-xl bg-card2 px-4 py-3">
            <p className="mb-3 text-[11px] font-bold text-slate-400">直近7日間</p>
            <WeeklyBar days={days} todayKey={todayKey} />
          </div>
        )}

        {/* Daily list */}
        {days.length === 0 ? (
          <div className="rounded-xl bg-card2 px-4 py-8 text-center">
            <p className="text-sm text-muted2">まだ学習記録がありません</p>
            <p className="mt-1 text-[11px] text-muted2">問題を解くと自動的に記録されます</p>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {days.map((day) => {
              const acc = Math.round((day.correct / day.total) * 100);
              return (
                <div key={day.dateKey} className="rounded-xl bg-card2 px-4 py-3">
                  {/* Day header */}
                  <div className="mb-2 flex items-center justify-between">
                    <p className="text-[13px] font-bold text-slate-200">{day.label}</p>
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] text-muted2">
                        {day.firstAt} 〜 {day.lastAt}
                      </span>
                    </div>
                  </div>

                  {/* Count + accuracy */}
                  <div className="mb-2.5 flex items-center gap-3">
                    <span className="text-[13px] font-extrabold text-slate-100">
                      {day.total}問
                    </span>
                    <div className="flex items-center gap-1.5">
                      <div className="h-1.5 w-20 overflow-hidden rounded-full bg-black/30">
                        <div
                          className="h-full rounded-full"
                          style={{
                            width: `${acc}%`,
                            background:
                              acc >= 70 ? "#16a34a" : acc >= 50 ? "#d97706" : "#dc2626",
                          }}
                        />
                      </div>
                      <span
                        className="text-[11px] font-bold"
                        style={{
                          color:
                            acc >= 70 ? "#86efac" : acc >= 50 ? "#fcd34d" : "#f87171",
                        }}
                      >
                        {acc}%
                      </span>
                    </div>
                    <span className="text-[10px] text-muted2">
                      ✓{day.correct} / ✗{day.total - day.correct}
                    </span>
                  </div>

                  {/* Subject chips */}
                  <div className="mb-2 flex flex-wrap gap-1">
                    {day.subjects.map((s) => (
                      <span
                        key={s.slug}
                        className="rounded-md bg-black/20 px-2 py-0.5 text-[10px] font-bold text-slate-400"
                      >
                        {SUBJECT_LABELS[s.slug] ?? s.slug} {s.count}問
                      </span>
                    ))}
                  </div>

                  {/* Category chips */}
                  <div className="flex flex-wrap gap-1">
                    {day.categories.slice(0, 6).map((c) => (
                      <span
                        key={c.name}
                        className="rounded-full px-2 py-0.5 text-[10px] font-bold"
                        style={{
                          background: c.color + "22",
                          color: c.color,
                          border: `1px solid ${c.color}44`,
                        }}
                      >
                        {c.name} {c.count}
                      </span>
                    ))}
                    {day.categories.length > 6 && (
                      <span className="rounded-full bg-card px-2 py-0.5 text-[10px] text-muted2">
                        +{day.categories.length - 6}
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}

        <Link
          href="/"
          className="mt-4 block w-full rounded-xl bg-card2 py-3 text-center text-sm font-bold text-muted"
        >
          メニューに戻る
        </Link>
      </div>
    </div>
  );
}
