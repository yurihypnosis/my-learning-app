BEGIN;

INSERT INTO public.categories (subject_id, name, sort_order)
SELECT s.id, v.name, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('OSI参照モデルとTCP/IP階層', 10),
  ('IPアドレスとサブネット設計', 11),
  ('LAN構成とネットワーク機器', 12),
  ('ネットワークセキュリティ技術', 13)
) AS v(name, sort_order) ON true
WHERE s.slug = 'ap-server'
ON CONFLICT DO NOTHING;

COMMIT;
