// 最終学習日を「今日 / 昨日 / N日前 / M/D」の短い表記にする。
function fmtLastStudied(iso: string | null, now: number): string {
  if (!iso) return "未学習";
  const t = Date.parse(iso);
  if (Number.isNaN(t)) return "未学習";
  const days = Math.floor((now - t) / 86_400_000);
  if (days <= 0) return "今日";
  if (days === 1) return "昨日";
  if (days < 7) return `${days}日前`;
  const d = new Date(iso);
  return `${d.getMonth() + 1}/${d.getDate()}`;
}

const accColor = (acc: number, answers: number): string =>
  answers === 0 ? "#555e70" : acc >= 0.7 ? "#22c55e" : acc >= 0.5 ? "#f59e0b" : "#ef4444";

// 得点率＋演習量・最終学習日をまとめた右端の統計セル（試験行・セット行で共用）。
export function StatCell({
  accuracy,
  answers,
  attempted,
  total,
  last,
  now,
}: {
  accuracy: number;
  answers: number;
  attempted: number;
  total: number;
  last: string | null;
  now: number;
}) {
  return (
    <span className="shrink-0 text-right leading-tight">
      <span
        className="block font-mono text-[11px] tabular-nums"
        style={{ color: accColor(accuracy, answers) }}
      >
        {answers === 0 ? "—" : `${Math.round(accuracy * 100)}%`}
      </span>
      <span className="block text-[9px] text-[#555e70]">
        {attempted}/{total} · {fmtLastStudied(last, now)}
      </span>
    </span>
  );
}
