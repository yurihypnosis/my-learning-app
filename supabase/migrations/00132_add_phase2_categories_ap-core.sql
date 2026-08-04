BEGIN;

INSERT INTO public.categories (subject_id, name, sort_order)
SELECT s.id, v.name, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('システム戦略と経営戦略', 7),
  ('技術戦略マネジメント', 8),
  ('システム開発技術とソフトウェア開発管理技術', 9),
  ('通信に関する理論', 10),
  ('ヒューマンインタフェースとマルチメディア', 11),
  ('セキュリティ実装技術', 12)
) AS v(name, sort_order) ON true
WHERE s.slug = 'ap-core'
ON CONFLICT DO NOTHING;

COMMIT;
