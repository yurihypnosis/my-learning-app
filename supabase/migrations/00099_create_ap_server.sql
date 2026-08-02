BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('ap-server', '応用情報技術者試験 サーバー・インフラ系対策',
        '応用情報技術者試験（AP）のサーバー・インフラ分野に絞った対策問題集。稼働率計算・RAID・負荷分散/高可用性設計・ネットワークプロトコル・セキュリティの数理・データベース基礎の6分野。linux-basicsドリルと重複しない領域（Linux固有でない、応用情報特有の知識）に特化。学習用オリジナル。',
        '#5a7fb0', 160)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('稼働率とシステムの信頼性', '#5a7fb0', 0),
  ('RAIDの仕組みと計算', '#6f95c4', 1),
  ('負荷分散と高可用性設計', '#84abd8', 2),
  ('ネットワークプロトコルの基礎', '#4a7a9e', 3),
  ('セキュリティの数理と認証', '#8a6fb0', 4),
  ('データベースの基礎', '#5fa88a', 5)
) AS v(name, color, sort_order)
WHERE s.slug = 'ap-server'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
