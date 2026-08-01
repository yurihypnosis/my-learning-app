BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('分散分析と多重比較', '#ff8080', 10),
  ('ノンパラメトリック検定', '#56d4dd', 11),
  ('モデル選択と正則化', '#d4a72c', 12),
  ('ベイズ統計の応用', '#b392f0', 13)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'stats-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
