// 最終学習日を「今日 / 昨日 / N日前 / M/D」の短い表記にする。
export function fmtLastStudied(iso: string | null, now: number): string {
  if (!iso) return "未演習";
  const t = Date.parse(iso);
  if (Number.isNaN(t)) return "未演習";
  const days = Math.floor((now - t) / 86_400_000);
  if (days <= 0) return "今日";
  if (days === 1) return "昨日";
  if (days < 7) return `${days}日前`;
  if (days < 30) return `${Math.floor(days / 7)}週間前`;
  const d = new Date(iso);
  return `${d.getMonth() + 1}/${d.getDate()}`;
}

// 得点率の色。未演習はグレー、70%以上は緑、50%以上は琥珀、それ未満は赤。
export function accuracyColor(accuracy: number, answers: number): string {
  if (answers === 0) return "#59627a";
  if (accuracy >= 0.7) return "#22c55e";
  if (accuracy >= 0.5) return "#f59e0b";
  return "#ef4444";
}

// 得点率から状況ラベルを決める（問題集一覧・進捗テーブルで共用）。
export function statusOf(
  accuracy: number,
  answers: number
): { label: string; color: string; bg: string } {
  if (answers === 0) return { label: "未着手", color: "#59627a", bg: "#141720" };
  if (accuracy >= 0.7) return { label: "合格圏", color: "#22c55e", bg: "rgba(34,197,94,.14)" };
  if (accuracy >= 0.5) return { label: "学習中", color: "#f59e0b", bg: "rgba(245,158,11,.14)" };
  return { label: "苦手", color: "#f87171", bg: "rgba(239,68,68,.14)" };
}
