BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('多変量解析', '#f2a65a', 14),
  ('時系列解析', '#5ac8c8', 15),
  ('標本調査法', '#c9a0dc', 16),
  ('実験計画法', '#8bc34a', 17),
  ('品質管理', '#e57373', 18),
  ('確率過程とシミュレーション', '#4fc3f7', 19)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'stats-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
