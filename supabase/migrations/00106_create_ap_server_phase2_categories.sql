BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('キャパシティプランニングと性能評価', '#6c8ebf', 6),
  ('バックアップとディザスタリカバリ', '#82a67d', 7),
  ('ストレージ技術の基礎', '#b08968', 8),
  ('クラウドサービスモデル', '#9a7fb0', 9)
) AS v(name, color, sort_order)
WHERE s.slug = 'ap-server'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
