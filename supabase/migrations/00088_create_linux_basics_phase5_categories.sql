BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('リンクという考え方', '#6ab08d', 25),
  ('DNSの仕組み', '#3b82f6', 26),
  ('viエディタの考え方', '#c9a04a', 27),
  ('仮想化とクラウドの基礎', '#60a5fa', 28),
  ('スワップメモリと仮想メモリの仕組み', '#c47070', 29)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
