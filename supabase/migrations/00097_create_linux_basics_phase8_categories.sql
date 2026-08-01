BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('よく使うコマンドの覚え方（基本操作の続き）', '#d37da3', 35),
  ('よく使うコマンドの覚え方（ディスク・マウント）', '#a37dd3', 36),
  ('よく使うコマンドの覚え方（ネットワーク診断）', '#7d8fd3', 37)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
