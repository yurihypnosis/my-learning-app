BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('よく使うコマンドの覚え方（テキスト処理）', '#a3d37d', 32),
  ('よく使うコマンドの覚え方（ネットワーク）', '#7d9bd3', 33),
  ('よく使うコマンドの覚え方（システム管理）', '#d3a07d', 34)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
