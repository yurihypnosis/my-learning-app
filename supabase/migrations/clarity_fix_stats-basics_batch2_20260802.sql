BEGIN;

-- stats8-q04 (must): 「パラメータ」が point/terms/opt で未接地のまま使われている。
-- terms に「パラメータ」自体の説明を追加し、訓練データの定義もつまみの比喩で言い換える。
-- point・opt[1] も同じ比喩で接地する。
UPDATE public.questions
SET explanation_data = explanation_data || '{
  "point": "AIの調整つまみ(パラメータ)を合わせるのに使うのが訓練データ、一度も見せずに実力を測るのがテストデータ。",
  "terms": [
    ["パラメータ", "AIの中の「効き具合のつまみ」の数字"],
    ["訓練データ", "AIの調整つまみ(パラメータ)を合わせるために使う学習用のデータ"],
    ["テストデータ", "学習には使わず、仕上がったAIの実力を測るために取っておくデータ"]
  ],
  "opt": [
    "正解。学習には一度も使わず、仕上がったAIの本当の実力を測るために取っておくデータがテストデータ。",
    "訓練データはAIの調整つまみ(パラメータ)を合わせるための学習用データで、実力を測るために取っておく今回のデータとは役目が違う。",
    "交差検証は訓練とテストへの分け方を何通りも変えて確かめるやり方で、分け方そのものではなく、確かめる手順の名前。",
    "過剰適合は訓練データを丸暗記しすぎて本番で崩れる状態のことで、実力を測るためのデータそのものの名前ではない。"
  ]
}'::jsonb
WHERE source_ref = 'stats8-q04'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats8-q09 (nice): ROC曲線のviz。x軸ラベルはあるがy軸（見逃さない割合）の対応表示が無いので追記。
UPDATE public.questions
SET explanation_data = explanation_data || '{"viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\"><line x1=\"46\" y1=\"20\" x2=\"46\" y2=\"118\" stroke=\"#2a2f3f\" stroke-width=\"1.5\"/><line x1=\"46\" y1=\"118\" x2=\"300\" y2=\"118\" stroke=\"#2a2f3f\" stroke-width=\"1.5\"/><text x=\"46\" y=\"132\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">0</text><text x=\"300\" y=\"132\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">1 (誤検挙の割合)</text><text x=\"30\" y=\"118\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">0</text><text x=\"20\" y=\"24\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">1</text><text x=\"10\" y=\"70\" fill=\"#8892a4\" font-size=\"8\" text-anchor=\"middle\" transform=\"rotate(-90 10 70)\">見逃さない割合</text><line x1=\"46\" y1=\"118\" x2=\"300\" y2=\"20\" stroke=\"#8892a4\" stroke-dasharray=\"4 3\"/><text x=\"230\" y=\"60\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">当てずっぽう</text><path d=\"M46 118 C 90 50, 140 30, 300 20 L300 118 L46 118 Z\" fill=\"#3b82f6\" opacity=\"0.14\"/><path d=\"M46 118 C 90 50, 140 30, 300 20\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"2\"/><text x=\"150\" y=\"92\" fill=\"#60a5fa\" font-size=\"10\" text-anchor=\"middle\" font-weight=\"600\">AUC = 曲線の下の面積</text><text x=\"170\" y=\"12\" fill=\"#e8eaf0\" font-size=\"10.5\" text-anchor=\"middle\" font-weight=\"600\">判定ラインを動かしたときの性能を1枚に</text></svg>"}'::jsonb
WHERE source_ref = 'stats8-q09'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats8-q02 (nice): kid内の矢印「問題→正解」を節に展開。
UPDATE public.questions
SET explanation_data = explanation_data || '{"kid": "教師あり学習は、問題と正解がセットになったカードで勉強するやり方。何度も「問題と正解」のペアを見せて練習させると、正解が書いていない新しい問題を渡されても、近い答えを言えるようになる。"}'::jsonb
WHERE source_ref = 'stats8-q02'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats8-q10 (nice): think内の矢印「小雨で風は弱い→念のため持つ」を節に展開。
UPDATE public.questions
SET explanation_data = explanation_data || '{"think": "なぜ質問を1つで終わらせず、何段も重ねるのかがカギ。「雨が降りそうか」だけでは、小雨で風もない日と、大雨で風も強い日を同じ「傘がいる」に丸めてしまい、判断が粗くなる。そこで「風は強いか」という2つ目の質問を追加すると、小雨で風が弱いなら念のため持つ、のように、より細かく状況を分けて答えを出せる。質問を重ねるほど、状況を細かく分けて的確な答えに近づけられる。ただし重ねすぎると、細かく分けすぎて訓練データの丸暗記(過剰適合)に近づいてしまう点には注意がいる。"}'::jsonb
WHERE source_ref = 'stats8-q10'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats5-q08 (nice): vsで「r²=R²」が単回帰限定であることの留保が無いので一言足す（q09で重回帰が出るため）。
UPDATE public.questions
SET explanation_data = explanation_data || '{"vs": "決定係数R²は、説明変数が1つの単回帰のときは、実は相関係数rを2乗した値になっている（r²=R²）。だから相関係数0.64がそのままR²というわけではなく、相関係数の2乗がR²になる、という順番を混同しないこと。ただし説明変数が複数ある重回帰では、この単純な関係はそのままは成り立たない。"}'::jsonb
WHERE source_ref = 'stats5-q08'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

-- stats8-q12 (nice): thinkで「ばらつきが大きい向きほど違いを表す」がやや天下り的なので、
-- 小さい向き/大きい向きの対比を足して因果の鎖を一段強くする。
UPDATE public.questions
SET explanation_data = explanation_data || '{"think": "なぜ軸を減らしても情報が保てるのかがカギ。国語と英語のように、点数が高い生徒はどちらも高くなりがちな、たがいに似た動きをする科目の組がある。そうした似た動きをする軸をまとめて、「データが一番大きくばらついて見える向き」を新しい1本の軸(第1主成分)として選び直すと、5科目ぶんの違いのかなりの部分を、その1本の軸だけで表せてしまう。ばらつきが小さい向きでは、生徒の点数がほぼ同じ値に集まってしまい、生徒どうしの違いが見えにくい。逆にばらつきが大きい向きでは、生徒ごとの点数の差がはっきり表れる。だから、ばらつきが大きい向きほど生徒どうしの違いをよく表しており、その向きを優先して軸に選ぶことで、少ない軸でも元の様子をなるべく保てる。"}'::jsonb
WHERE source_ref = 'stats8-q12'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

COMMIT;
