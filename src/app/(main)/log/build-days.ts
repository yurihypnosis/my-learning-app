// 学習ログの日別集計。サーバ側で組み立ててからクライアントへ渡すため、
// "use client" を持たない独立モジュールに置く（生イベントを送らずに済む）。

export interface AnswerEvent {
  answered_at: string;
  is_correct: boolean;
  confidence: number | null;
  category_name: string;
  category_color: string;
  subject_slug: string;
}

export interface DayEntry {
  dateKey: string;
  label: string;
  total: number;
  correct: number;
  categories: { name: string; color: string; count: number }[];
  subjects: { slug: string; count: number }[];
  firstAt: string;
  lastAt: string;
}

export const WEEKDAYS = ["日", "月", "火", "水", "木", "金", "土"];

function toJSTDate(iso: string): Date {
  return new Date(new Date(iso).getTime() + 9 * 60 * 60 * 1000);
}

export function toDateKey(iso: string): string {
  const d = toJSTDate(iso);
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, "0")}-${String(d.getUTCDate()).padStart(2, "0")}`;
}

function toTimeLabel(iso: string): string {
  const d = toJSTDate(iso);
  return `${String(d.getUTCHours()).padStart(2, "0")}:${String(d.getUTCMinutes()).padStart(2, "0")}`;
}

/** 暦日キー(YYYY-MM-DD)を days 日ずらす。UTC 基準で動かさないと toISOString でずれる。 */
export function shiftKey(key: string, days: number): string {
  const d = new Date(key + "T00:00:00Z");
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

export function buildDays(
  events: AnswerEvent[],
  todayKey: string,
  yesterdayKey: string
): DayEntry[] {
  const map = new Map<string, AnswerEvent[]>();
  for (const ev of events) {
    const key = toDateKey(ev.answered_at);
    if (!map.has(key)) map.set(key, []);
    map.get(key)!.push(ev);
  }

  return Array.from(map.entries())
    .sort(([a], [b]) => b.localeCompare(a))
    .map(([key, evs]) => {
      const d = new Date(key + "T00:00:00Z");
      const dow = WEEKDAYS[d.getUTCDay()];
      const mm = d.getUTCMonth() + 1;
      const dd = d.getUTCDate();
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
        // 表示は上位6件までなので、運ぶのもそこまでで足りる。
        categories: Array.from(catMap.entries())
          .map(([name, v]) => ({ name, color: v.color, count: v.count }))
          .sort((a, b) => b.count - a.count)
          .slice(0, 7),
        subjects: Array.from(subMap.entries())
          .map(([slug, count]) => ({ slug, count }))
          .sort((a, b) => b.count - a.count),
        firstAt: toTimeLabel(sorted[0]),
        lastAt: toTimeLabel(sorted[sorted.length - 1]),
      };
    });
}

/** 連続学習日数。今日に記録が無ければ昨日から数え始める。 */
export function calcStreak(days: DayEntry[], todayKey: string): number {
  const set = new Set(days.map((d) => d.dateKey));
  const start = set.has(todayKey) ? todayKey : shiftKey(todayKey, -1);
  if (!set.has(start)) return 0;
  let streak = 0;
  let cur = start;
  while (set.has(cur)) {
    streak++;
    cur = shiftKey(cur, -1);
  }
  return streak;
}
