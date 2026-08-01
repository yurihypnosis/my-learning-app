BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('よく使うコマンドの覚え方（ファイル操作）', '#7dd3c0', 30),
  ('よく使うコマンドの覚え方（プロセス・検索・権限）', '#7dc0d3', 31)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
