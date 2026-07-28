export function FilterChip({
  label,
  color,
  count,
  active,
  onClick,
}: {
  label: string;
  color: string;
  count: number;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className="rounded-lg border px-2.5 py-1.5 text-[11px] font-medium transition"
      style={{
        borderColor: active ? color : "#2a2f3f",
        color: active ? color : "#8892a4",
        background: active ? color + "1a" : "transparent",
      }}
    >
      {label}
      <span className="ml-1.5 opacity-50 tabular-nums">{count}</span>
    </button>
  );
}
