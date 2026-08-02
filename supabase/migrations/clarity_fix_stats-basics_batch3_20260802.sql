-- stats-basics 監査（数学の部品箱／手で計算する統計／分散分析と多重比較／ノンパラメトリック検定）
-- nice指摘5件の非破壊マージ修正。既存キーは維持し、変更するキーのみ || でマージする。
-- 対象: stats9-q04(eg), stats9-q08(eg), stats11-q01(eg), stats11-q03(vs), stats11-q08(think)

BEGIN;

-- stats9-q04: eg（レシピの空欄）が kid（空っぽの箱）と同じ「入れ物メタファー」だったため、
-- 「同じ手順を毎回繰り返す仕組み」という別角度（自動販売機）に差し替え。
UPDATE public.questions
SET explanation_data = explanation_data || '{"eg": "自動販売機は、押したボタンの番号によって出てくる商品が変わるだけで、お金を入れて商品を出すという仕組みそのものはいつも同じ。文字式も同じで、xに入れる数字が変わるだけで、計算の手順（2倍して1を足す）はいつも同じ。xに3を入れれば、その手順どおりに7が出てくる。"}'::jsonb
WHERE source_ref = 'stats9-q04'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats9-q08: eg（出席番号）が kid（出席番号のようなもの）と同一比喩だったため、
-- 別角度（郵便受けの部屋番号）に差し替え。
UPDATE public.questions
SET explanation_data = explanation_data || '{"eg": "マンションの郵便受けに101号室、102号室と部屋番号が振ってあるのと同じ。x₃と書けば「xという棚の3号室」だとすぐ分かる。番号（添字）がなければ、どの部屋（何番目のデータ）を指しているのか区別がつかない。"}'::jsonb
WHERE source_ref = 'stats9-q08'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats11-q01: eg（くじを3回引く）が kid（コインを何回も投げる）と同じ「反復試行の確率」の
-- 小道具違いだったため、別角度（天気予報の的中/外れ）に差し替え。
UPDATE public.questions
SET explanation_data = explanation_data || '{"eg": "天気予報が「明日は晴れ」と言って外れる確率が1回なら5%だとしても、3日連続の予報を見れば、そのうちどれか1日は外れてしまう確率は5%よりずっと高くなる。t検定を3回繰り返すのも同じで、判定を重ねるほど、どこかで偶然「差がある」と誤ってしまう危険が高まる。"}'::jsonb
WHERE source_ref = 'stats11-q01'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats11-q03: vs が未提示のq04（F値）を先出し参照していたため、
-- 設問番号を名指しせず「この先F値と呼ばれる」という接地のみに書き換え。
UPDATE public.questions
SET explanation_data = explanation_data || '{"vs": "「群間分散が大きい」ことと「群内分散が小さい」ことは別の情報。片方だけを見ても「差があるか」は判断できず、必ず両方を比べて初めて意味を持つ。この2つを比べた値は、この先F値と呼ばれる統計量になる。"}'::jsonb
WHERE source_ref = 'stats11-q03'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats11-q08: think が「q01・q09で見たように」と、まだ未提示のq09を過去形で参照していたため、
-- 既出のq01のみの参照に修正（内部矛盾の解消）。
UPDATE public.questions
SET explanation_data = explanation_data || '{"think": "なぜ割り算で厳しくできるのかがカギ。q01で見たように、比較の回数が増えるほど、どこかで偶然「差あり」と誤ってしまう危険は積み重なる。ボンフェローニ補正は、1回あたりの有意水準を比べる回数ぶん小さくしておくことで、全体としての誤りの危険をもとの0.05くらいに抑え直す、という考え方。3ペア比べるなら、1ペアあたりの基準を0.05÷3=0.0166…と、もとより厳しくしておく。"}'::jsonb
WHERE source_ref = 'stats11-q08'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

COMMIT;
