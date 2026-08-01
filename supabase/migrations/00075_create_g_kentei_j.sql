BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('g-kentei-j', 'G検定（JDLA ジェネラリスト検定） Set J 関数・NN超強化',
        'JDLA G検定 対策 第10弾。ディープラーニングの概要（活性化関数・誤差関数・最適化手法）とディープラーニングの要素技術（ネットワーク構造）の2分野に絞った超強化セット。A〜I で扱っていない活性化関数・損失関数・最適化手法・軽量化/解釈性/転移学習の周辺論点を補う。学習用オリジナル。',
        '#0B5CAB', 59)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('4. ディープラーニングの概要', '#a371f7', 0),
  ('5. ディープラーニングの要素技術', '#d2a8ff', 1)
) AS v(name, color, sort_order)
WHERE s.slug = 'g-kentei-j'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
