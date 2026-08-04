BEGIN;

INSERT INTO public.categories (subject_id, name, sort_order)
SELECT s.id, v.name, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('データベース方式とデータモデル', 17),
  ('システムの構成方式', 18)
) AS v(name, sort_order) ON true
WHERE s.slug = 'ap-core'
ON CONFLICT DO NOTHING;

COMMIT;
