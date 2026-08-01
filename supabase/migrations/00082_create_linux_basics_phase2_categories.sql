BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('テキスト処理の基本', '#4fb3bf', 10),
  ('パッケージ管理の考え方', '#5fb0e0', 11),
  ('シェルスクリプトの入り口', '#7fae6a', 12),
  ('ログとトラブルシューティング', '#c9a04a', 13),
  ('ディスクとストレージの基礎', '#a08fd8', 14)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
