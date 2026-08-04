BEGIN;

INSERT INTO public.categories (subject_id, name, sort_order)
SELECT s.id, v.name, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('計測・制御に関する理論', 13),
  ('コンパイラ理論とプログラミング言語論', 14),
  ('システム企画', 15),
  ('システム監査', 16)
) AS v(name, sort_order) ON true
WHERE s.slug = 'ap-core'
ON CONFLICT DO NOTHING;

COMMIT;
