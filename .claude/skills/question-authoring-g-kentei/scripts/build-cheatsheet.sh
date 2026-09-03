#!/usr/bin/env bash
# G検定チートシート（/g-kentei/cheatsheet）用の静的JSONを本番DBから再生成する。
# 読み取り専用（db.sh query）。問題集を更新したら再実行してコミットする。
set -euo pipefail

cd "$(dirname "$0")/../../../.."

OUT="src/features/g-kentei-cheatsheet/data/cheatsheet.json"

./.claude/skills/question-authoring/scripts/db.sh query "
select
  s.slug as subject_slug,
  q.source_ref,
  c.name as category,
  c.sort_order as category_sort,
  q.explanation_data->>'asked' as asked,
  q.explanation_data->>'point' as point,
  q.explanation_data->>'why_asked' as why_asked,
  q.explanation_data->>'eg' as eg,
  q.explanation_data->>'vs' as vs,
  q.explanation_data->>'think' as think,
  q.explanation_data->>'calc' as calc,
  coalesce(q.explanation_data->'terms', '[]'::jsonb) as terms
from questions q
join subjects s on s.id = q.subject_id
join categories c on c.id = q.category_id
where s.slug like 'g-kentei%' and q.is_active
order by c.sort_order, s.slug, q.source_ref;
" | jq '[.[] | {
  id: .source_ref,
  category,
  asked,
  point,
  whyAsked: .why_asked,
  eg,
  vs,
  think,
  calc,
  terms
}]' > "$OUT"

echo "書き出し完了: $OUT ($(jq length "$OUT") 件)"
