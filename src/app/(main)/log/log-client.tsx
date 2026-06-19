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
  dateKey: string;
  label: string;
  total: number;
  correct: number;
  categories: { name: string; color: string; count: number }[];
  subjects: { slug: string; count: number }[];
  firstAt: string;
  lastAt: string;
}

const SUBJECT_LABELS: Record<string, string> = {
  "gcp-ace": "GCP ACE",
  "gh-200":  "GH-200",
  "dca":     "DCA",
};

const WEEKDAYS = ["日", "月", "火", "水", "木", "金", "土"];

function toJSTDate(iso: string): Date {
  const d = new Date(iso);
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
        key === todayKey ? `今日 ${mm}/${dd}（${dow}）`
          : key === yesterdayKey ? `昨日 ${mm}/${dd}（${dow}）`
            : `${mm}/${dd}（${dow}）`;

      const catMap = new Map<string, { color: string; count: number }>();
      const subMap = new Map<string, number>();
      let correct = 0;

      for (const ev of evs) {
        if (ev.is_correct) correct++;
        const prev = catMap.get(ev.category_name);
        catMap.set(ev.category_name, { color: ev.category_color, count: (prev?.count ?? 0) + 1 });
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
    return { key, dow: WEEKDAYS[d.getDay()], count: dayMap.get(key) ?? 0 };
  });
  const max = Math.max(...bars.map((b) => b.count), 1);

  return (
    <div className="flex h-16 items-end gap-1">
      {bars.map((b) => {
        const isToday = b.key === todayKey;
        const pct = b.count > 0 ? Math.max((b.count / max) * 100, 8) : 0;
        return (
          <div key={b.key} className="flex flex-1 flex-col items-center gap-1">
            <span className="text-[9px] text-[#333]">{b.count > 0 ? b.count : ""}</span>
            <div className="flex w-full flex-1 items-end">
              <div
                className="w-full rounded-sm transition-all"
                style={{
                  height: `${pct}%`,
                  minHeight: b.count > 0 ? 4 : 0,
                  background: isToday ? "#3b82f6" : b.count > 0 ? "#1e3a5f" : "transparent",
                }}
              />
            </div>
            <span
              className="text-[9px] font-medium"
              style={{ color: isToday ? "#3b82f6" : "#333" }}
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

export function LogClient({ events, todayKey, yesterdayKey }: Props) {
  const days = buildDays(events, todayKey, yesterdayKey);
  const streak = calcStreak(days, todayKey);

  const wrap = "flex flex-col items-center px-4 pb-28 pt-8";
  const container = "w-full max-w-[520px]";

  return (
    <div className={wrap}>
      <div className={container}>
        {/* Header */}
        <div className="mb-6 flex items-center justify-between">
          <div>
            <h1 className="text-base font-semibold text-white">学習ログ</h1>
            <p className="text-xs text-[#444]">直近 90 日</p>
          </div>
          <Link
            href="/"
            className="text-xs text-[#444] transition hover:text-[#888]"
          >
            ← 戻る
          </Link>
        </div>

        {/* Stats */}
        <div className="mb-6 grid grid-cols-3 gap-2">
          <div className="rounded-xl border border-[#1a1a1a] bg-[#0d0d0d] py-4 text-center">
            <p className="text-xl font-bold tabular-nums text-white">
              {streak > 0 ? streak : "—"}
            </p>
            <p className="text-[10px] text-[#333]">日連続</p>
          </div>
          <div className="rounded-xl border border-[#1a1a1a] bg-[#0d0d0d] py-4 text-center">
            <p className="text-xl font-bold tabular-nums text-white">{days.length}</p>
            <p className="text-[10px] text-[#333]">日間</p>
          </div>
          <div className="rounded-xl border border-[#1a1a1a] bg-[#0d0d0d] py-4 text-center">
            <p className="text-xl font-bold tabular-nums text-white">{events.length}</p>
            <p className="text-[10px] text-[#333]">問演習</p>
          </div>
        </div>

        {/* Weekly chart */}
        {days.length > 0 && (
          <div className="mb-6 rounded-xl border border-[#1a1a1a] bg-[#0d0d0d] px-4 py-4">
            <p className="mb-3 text-[10px] font-semibold uppercase tracking-widest text-[#3a3a3a]">
              直近 7 日間
            </p>
            <WeeklyBar days={days} todayKey={todayKey} />
          </div>
        )}

        {/* Daily list */}
        {days.length === 0 ? (
          <div className="rounded-xl border border-[#1a1a1a] py-12 text-center">
            <p className="text-sm text-[#333]">まだ記録がありません</p>
            <p className="mt-1 text-xs text-[#222]">問題を解くと自動的に記録されます</p>
          </div>
        ) : (
          <div className="space-y-2">
            {days.map((day) => {
              const acc = Math.round((day.correct / day.total) * 100);
              const accColor = acc >= 70 ? "#22c55e" : acc >= 50 ? "#f59e0b" : "#ef4444";
              return (
                <div key={day.dateKey} className="rounded-xl border border-[#1a1a1a] bg-[#0d0d0d] px-4 py-3.5">
                  {/* Day header */}
                  <div className="mb-2.5 flex items-center justify-between">
                    <p className="text-xs font-medium text-[#ccc]">{day.label}</p>
                    <p className="text-[10px] text-[#333]">
                      {day.firstAt} — {day.lastAt}
                    </p>
                  </div>

                  {/* Stats row */}
                  <div className="mb-2.5 flex items-center gap-4">
                    <span className="text-sm font-semibold text-white">{day.total} 問</span>
                    <div className="flex items-center gap-2">
                      <div className="h-px w-16 overflow-hidden rounded-full bg-[#1a1a1a]">
                        <div
                          className="h-full rounded-full"
                          style={{ width: `${acc}%`, background: accColor }}
                        />
                      </div>
                      <span className="text-xs font-semibold tabular-nums" style={{ color: accColor }}>
                        {acc}%
                      </span>
                    </div>
                    <span className="text-[10px] text-[#333]">
                      ✓{day.correct} ✗{day.total - day.correct}
                    </span>
                  </div>

                  {/* Subject tags */}
                  {day.subjects.length > 0 && (
                    <div className="mb-2 flex flex-wrap gap-1">
                      {day.subjects.map((s) => (
                        <span
                          key={s.slug}
                          className="rounded-md border border-[#1e1e1e] px-2 py-0.5 text-[10px] text-[#444]"
                        >
                          {SUBJECT_LABELS[s.slug] ?? s.slug} {s.count}
                        </span>
                      ))}
                    </div>
                  )}

                  {/* Category dots */}
                  <div className="flex flex-wrap gap-2">
                    {day.categories.slice(0, 6).map((c) => (
                      <div key={c.name} className="flex items-center gap-1.5">
                        <span
                          className="h-1.5 w-1.5 shrink-0 rounded-full"
                          style={{ background: c.color }}
                        />
                        <span className="text-[10px] text-[#555]">
                          {c.name} {c.count}
                        </span>
                      </div>
                    ))}
                    {day.categories.length > 6 && (
                      <span className="text-[10px] text-[#333]">
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
          className="mt-4 block w-full rounded-xl border border-[#1a1a1a] py-3 text-center text-sm text-[#444] transition hover:border-[#333] hover:text-[#888]"
        >
          メニューに戻る
        </Link>
      </div>
    </div>
  );
}
