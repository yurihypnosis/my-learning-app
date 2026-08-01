BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('g-kentei-k', 'G検定（JDLA ジェネラリスト検定） Set K 数理・統計知識強化',
        'JDLA G検定 対策 第11弾。「8. AIに必要な数理・統計知識」1分野に絞った超強化セット。確率分布・ベイズの定理・情報理論（エントロピー/KLダイバージェンス）・推測統計・線形代数（内積・ノルム・固有値/固有ベクトル）・微分の基礎（偏微分・連鎖律）など、A〜J で扱っていない数理の周辺論点を補う。学習用オリジナル。',
        '#0B5CAB', 60)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('8. AIに必要な数理・統計知識', '#39c5cf', 0)
) AS v(name, color, sort_order)
WHERE s.slug = 'g-kentei-k'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
