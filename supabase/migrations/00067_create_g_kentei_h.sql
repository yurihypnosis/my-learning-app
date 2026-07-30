BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('g-kentei-h', 'G検定（JDLA ジェネラリスト検定） Set H',
        'JDLA G検定 対策 第8弾。ニューラルネットワークの概念・理論を集中増強（シラバス2024掲載でSet A〜G未出題のキーワード中心: RNNの原型、損失関数の発展形、正規化層の使い分け、CNNモデル系譜、深層強化学習の工夫、生成モデルファミリー等）。個人情報保護法は範囲外。本番の再現ではなく学習用オリジナル。',
        '#0B5CAB', 57)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('1. 人工知能とは', '#58a6ff', 0),
  ('2. 人工知能をめぐる動向', '#79c0ff', 1),
  ('3. 機械学習の概要', '#3fb950', 2),
  ('4. ディープラーニングの概要', '#a371f7', 3),
  ('5. ディープラーニングの要素技術', '#d2a8ff', 4),
  ('6. ディープラーニングの応用例', '#f0883e', 5),
  ('7. AIの社会実装に向けて', '#e3b341', 6),
  ('8. AIに必要な数理・統計知識', '#39c5cf', 7),
  ('9. AIに関する法律と契約', '#f85149', 8),
  ('10. AI倫理・AIガバナンス', '#ff7b72', 9)
) AS v(name, color, sort_order)
WHERE s.slug = 'g-kentei-h'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
