BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('ap-core', '応用情報技術者試験 基礎理論・マネジメント系対策',
        '応用情報技術者試験（AP）のうち、離散数学・アルゴリズムとデータ構造などの言語非依存な基礎理論と、プロジェクトマネジメント・サービスマネジメント・システム戦略・経営戦略・技術戦略マネジメントといったマネジメント系/ストラテジ系分野に特化した対策問題集。AI/機械学習/深層学習(e-shikaku/g-kenteiが担当)、確率統計(stats-basics)、サーバー・インフラ/DB/ネットワーク(ap-server)、OS/Linux(linux-basics)とは重複しない領域に絞る。学習用オリジナル。',
        '#7a6bb0', 161)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, sort_order)
SELECT s.id, v.name, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('離散数学', 0),
  ('応用数学', 1),
  ('情報に関する理論', 2),
  ('アルゴリズムとデータ構造', 3),
  ('情報セキュリティ管理', 4),
  ('プロジェクトマネジメント', 5),
  ('サービスマネジメント', 6)
) AS v(name, sort_order) ON true
WHERE s.slug = 'ap-core'
ON CONFLICT DO NOTHING;

COMMIT;
