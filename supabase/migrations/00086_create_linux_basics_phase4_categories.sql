BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('ブートプロセスの流れ', '#58a6ff', 20),
  ('リソース監視の基礎', '#79c0ff', 21),
  ('ファイル検索とfind/xargsの考え方', '#3fb950', 22),
  ('セキュリティの基礎', '#f85149', 23),
  ('Gitとバージョン管理の基礎', '#e3b341', 24)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
