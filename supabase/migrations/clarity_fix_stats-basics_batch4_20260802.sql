BEGIN;

-- stats13-q02: point の矢印(→)多用を節に展開
-- 「単純すぎる→毎回同じようにズレる(バイアス大)。複雑すぎる→…」
-- →「単純すぎるモデルは毎回同じようにズレ(バイアス大)、複雑すぎるモデルは…」
UPDATE public.questions
SET explanation_data = explanation_data || '{"point": "単純すぎるモデルは毎回同じようにズレ(バイアス大)、複雑すぎるモデルはデータが変わるたびに予測がブレる(バリアンス大)。"}'::jsonb
WHERE source_ref = 'stats13-q02'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats15-q05: think 内の記号 → を残さず文で書く（「矢印」という語自体は概念装置として維持）
UPDATE public.questions
SET explanation_data = explanation_data || '{"think": "なぜ同じ「複数の変数を扱う手法」なのに目的が正反対になるのかがカギ。主成分分析は、手元にある変数(身長・体重など)を出発点にして、そこから情報をなるべく保ちながら少ない数の合成変数を作り出す。つまり矢印は、変数から合成変数へ向かう向き。因子分析は逆に、手元にある変数(点数)を「結果」とみなし、その結果を生み出した見えない原因(因子)を出発点として想定し、そこから変数へ矢印が伸びていると考える。同じように複数の変数を扱っていても、矢印がどちら向きかで、要約したいのか(主成分分析)、原因を探りたいのか(因子分析)という目的が入れ替わる。"}'::jsonb
WHERE source_ref = 'stats15-q05'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats16-q05: point が viz より先に表示される描画順のため、未定義の図中ラベル「B」への空振り参照を削除
UPDATE public.questions
SET explanation_data = explanation_data || '{"point": "平均も分散もずっと同じ水準のまま上下しているのが定常。反対に、平均そのものが右肩上がりに動いていくのは非定常。"}'::jsonb
WHERE source_ref = 'stats16-q05'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

COMMIT;
