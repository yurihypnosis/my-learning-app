#!/usr/bin/env bash
# G検定チートシート（/g-kentei/cheatsheet）用の静的JSONを本番DBから再生成する。
# 読み取り専用（db.sh query）。問題集を更新したら再実行してコミットする。
# 出力は「用語辞書」(terms.json)と「紛らわしい概念の比較グループ」(comparisons.json)。
set -euo pipefail

cd "$(dirname "$0")/../../../.."

DIR="src/features/g-kentei-cheatsheet/data"
TERMS_OUT="$DIR/terms.json"
COMPARISONS_OUT="$DIR/comparisons.json"

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
" | node "$(dirname "$0")/build-cheatsheet.mjs" "$TERMS_OUT" "$COMPARISONS_OUT"
