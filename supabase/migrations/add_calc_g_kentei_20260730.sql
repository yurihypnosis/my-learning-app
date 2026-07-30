BEGIN;

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "ソフトマックスが「合計1の確率」を作る手順。\n\n3クラスのスコア  猫 2、犬 1、鳥 0\n\n① それぞれを e の肩に乗せる（マイナスでもプラスになる）\n   e² ≒ 7.4    e¹ ≒ 2.7    e⁰ = 1\n② 合計を出す   7.4 + 2.7 + 1 = 11.1\n③ 各自を合計で割る\n   猫 7.4 ÷ 11.1 ≒ 0.67\n   犬 2.7 ÷ 11.1 ≒ 0.24\n   鳥 1.0 ÷ 11.1 ≒ 0.09\n確かめ: 0.67 + 0.24 + 0.09 = 1.00 ← 必ず合計1（100%）になる\n\n「割合にする」だけなら単純な割り算でもよいが、eを使うと\nスコアの差が確率の差として際立ち、マイナスのスコアも扱える。"}'::jsonb
WHERE source_ref = 'g-kentei-q19' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "なぜL1は重みをちょうど0にできるのか、罰の減り方を比べる。\n\nいま重みが 0.1。あと0.1減らして0にすると、罰はいくら減る？\n\nL2の罰（重みの2乗）: 0.1² = 0.01 → 0² = 0   罰の減り 0.01\nL1の罰（絶対値）   : 0.1 → 0                罰の減り 0.1（10倍）\n\nL2は0に近づくほど「減らす旨み」がしぼむ → 0の手前で止まる\nL1は0のそばでも旨みが一定 → 0まで押し切る\n\nだからL1は効かない項目の重みを0にして消し（スパース化）、\n効く項目だけが残る＝特徴選択にもなる。"}'::jsonb
WHERE source_ref = 'g-kentei-q22' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "再現率＝本当の患者のうち何人拾えたか。\n\nがん患者 10人を検査したら\n  陽性と当てた  9人\n  見落とした    1人 ← これを減らしたい\n\n再現率 = 9 ÷ 10 = 0.9\n\n見落としを減らす＝この0.9を1.0に近づけること。\nそのぶん健康な人への空振り（誤検出）は増えやすいが、\n「見落としたら命に関わる」場面では再現率を優先する。\n\n最後に記号版: 再現率(Recall) = TP ÷ (TP + FN)\n（TP=True Positive 正しく発見、FN=False Negative 見落とし）"}'::jsonb
WHERE source_ref = 'g-kentei-q40' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "F値がなぜ「ふつうの平均」ではだめかを計算で見る。\n\nモデル: 適合率 0.8、再現率 0.4\n\nふつうの平均  (0.8 + 0.4) ÷ 2 = 0.6\nF値（調和平均） 2 × 0.8 × 0.4 ÷ (0.8 + 0.4)\n             = 0.64 ÷ 1.2 ≒ 0.53  ← 低い方に引っぱられる\n\n極端な例: 全員に「陽性」と言えば再現率1.0。でも適合率0.02なら\n  ふつうの平均 = 0.51（そこそこに見えてしまう）\n  F値 = 2 × 1.0 × 0.02 ÷ 1.02 ≒ 0.04（ちゃんと落第点）\n\n片方をサボると急落する。だからバランスの指標になる。"}'::jsonb
WHERE source_ref = 'g-kentei-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "68%を実際の点数でつかむ。\n\nテストの点: 平均60点、標準偏差10点 の正規分布とする\n\n±1σ（1標準偏差）: 60−10 〜 60+10 = 50〜70点 → 約68%（約7割）\n±2σ            : 60−20 〜 60+20 = 40〜80点 → 約95%\n±3σ            : 60−30 〜 60+30 = 30〜90点 → 約99.7%\n\n覚え方は「68・95・99.7」。\n「50〜70点に7割、40〜80点にほぼ全員」という感覚で持っておく。\n（σ＝シグマ＝標準偏差。散らばりの物差し）"}'::jsonb
WHERE source_ref = 'g-kentei-q42' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "ROC曲線を、判定ライン3本ぶんの点で作ってみる。\n\n判定ライン（何%以上を陽性とするか）を動かすと:\n  厳しめ（90%以上）: 真陽性率 0.60 / 偽陽性率 0.10\n  中間  （50%以上）: 真陽性率 0.80 / 偽陽性率 0.30\n  ゆるめ（20%以上）: 真陽性率 0.95 / 偽陽性率 0.60\n\nゆるくするほど「拾える患者」も「健康な人への誤報」も増える。\nこの点たちを横軸=偽陽性率、縦軸=真陽性率に打って結ぶとROC曲線。\n\nAUC＝その曲線の下の面積\n  でたらめ判定 → 0.5（対角線）\n  完璧な判定   → 1.0\n面積が広い＝「誤報を増やさずに拾える」良いモデル。"}'::jsonb
WHERE source_ref = 'g-kentei-q43' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "学習率＝一歩の大きさ。実際に動かしてみる。\n\n今の重み          2.0\n坂の傾き（勾配）    4 （右へ行くほど誤差が増える坂）\n動かす向き        傾きと逆＝左へ\n\n学習率 0.1  のとき  2.0 − 0.1×4 = 2.0 − 0.4 = 1.6   ← 少しずつ谷へ\n学習率 1.0  のとき  2.0 − 1.0×4 = 2.0 − 4.0 → 谷を大きく飛び越す（発散のもと）\n学習率 0.001のとき  2.0 − 0.001×4 = 1.996           ← ほぼ進まない（遅い）\n\n最後に記号版: w ← w − η × 勾配\n（w＝重み、η＝イータ＝学習率。いまやった計算そのもの）"}'::jsonb
WHERE source_ref = 'g-kentei-b-q21' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "交差エントロピー＝「正解に付けた確率」で決まる罰。\n\n問題: 写真は猫。モデルが猫に付けた確率は？\nモデルA  猫に 80% → 罰 0.22 （小さい）\nモデルB  猫に 10% → 罰 2.30 （大きい）\n\n罰の増え方には規則がある:\n確率 100% → 罰 0\n確率  50% → 罰 0.69\n確率  25% → 罰 1.39   ← 半分になるたび、罰は同じ幅ずつ増える\n確率 12.5% → 罰 2.08\n\nこの「半分になるたび同じ幅ずつ」を作る道具が log（ログ）。\n最後に記号版: 損失 = −log(正解に付けた確率)\nlog＝「何回半分にしたか」を数える道具、と思えばよい"}'::jsonb
WHERE source_ref = 'g-kentei-b-q23' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "適合率＝「迷惑だ」と言った中の正解率。\n\n迷惑メールと判定した 10通の内訳\n  本当に迷惑     8通\n  実は正常メール  2通 ← 大事なメールが迷惑箱行きに！\n\n適合率 = 8 ÷ 10 = 0.8\n\nこの 0.8 を 1.0 に近づける＝正常メールを巻き込まない。\n「正常を誤って迷惑扱いしたくない」ときに見る指標が適合率。\n\n最後に記号版: 適合率(Precision) = TP ÷ (TP + FP)\n（TP=True Positive 本当に迷惑、FP=False Positive 濡れ衣）"}'::jsonb
WHERE source_ref = 'g-kentei-b-q40' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "混同行列＝当たり外れの内訳表。100通のメールで作ってみる。\n\n              予測:迷惑    予測:正常\n本当は迷惑      18通         2通（見逃し）\n本当は正常       5通（濡れ衣） 75通\n\n確かめ: 18 + 2 + 5 + 75 = 100 ← 全部でちょうど100通\n\n正解は「迷惑を迷惑と言えた18」と「正常を正常と言えた75」。\n正解率 = (18 + 75) ÷ 100 = 93%\nでも間違い方は2種類ある（見逃し2通と濡れ衣5通）。\nそれを分けて見られるのがこの表の価値。"}'::jsonb
WHERE source_ref = 'g-kentei-b-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "外れ値に強いのはどっちか、実際に比べる。\n\n5人の年収（万円）  300  320  340  360  3000\n\n平均   = (300+320+340+360+3000) ÷ 5\n       = 4320 ÷ 5 = 864万円\n中央値 = 小さい順に並べた真ん中の人 → 340万円\n\n864万円は5人中4人の実感とかけ離れている。\n1人の大金持ち（外れ値）が平均を引きずり上げた。\n中央値は「並べて真ん中」なので、端の極端な値に動かされない。"}'::jsonb
WHERE source_ref = 'g-kentei-b-q43' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "正解率99%のからくりを数える。\n\n100人のうち  陽性 1人 / 陰性 99人\nモデル: 何も考えず全員に「陰性」と言うだけ\n\n正解 = 陰性の99人ぶん当たり → 正解率 99 ÷ 100 = 99%\nでも肝心の陽性1人は 0人発見。\n再現率 = 0 ÷ 1 = 0 （患者を1人も拾えていない）\n\n偏ったデータでは正解率が仕事をしない。\nだから再現率・適合率・F値で「間違い方の中身」を見る。"}'::jsonb
WHERE source_ref = 'g-kentei-c-q40' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "散らばりを1つの数にするまでを、5人の点数でやってみる。\n\n点数        56   58   60   62   64\n平均        (56+58+60+62+64) ÷ 5 = 60\n平均との差   -4   -2    0   +2   +4\n2乗         16    4    0    4   16   ← マイナスが消える\n2乗の平均    (16+4+0+4+16) ÷ 5 = 8   …これが分散\n\n√をとる     √8 ≒ 2.83  …これが標準偏差\n（√＝ルート＝「2乗するとその数になる数」。\n  2乗した分を√で元の単位＝「点」に戻した）\n\n最後に記号版: 分散 σ² = Σ(x−x̄)² ÷ n、標準偏差 σ = √分散\n（σ＝シグマ、Σ＝ぜんぶ足す、x̄＝平均）"}'::jsonb
WHERE source_ref = 'g-kentei-c-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "確率が「証拠」で更新される様子を人数で見る。\n\n病気の人は 100人に1人（もともとの確率 1%）\n検査の性能: 病気の人の90%に陽性 / 健康な人にも9%誤って陽性\n\n1000人を検査すると\n  病気 10人 → 陽性  9人（10×0.9）\n  健康 990人 → 陽性 89人（990×0.09 ≒ 89。誤報）\n陽性は合計 9 + 89 = 98人\n\n陽性と出た人が本当に病気の確率\n  = 9 ÷ 98 ≒ 9%\n\nもともと1%だった確率が、「陽性」という証拠で9%に更新された。\nこれがベイズの考え方（事前確率 → 証拠 → 事後確率）。"}'::jsonb
WHERE source_ref = 'g-kentei-c-q42' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "相関係数の正体を小さな例で見る。\n\n勉強時間x    1    2    3    4    5     （平均3）\n点数y       40   50   60   70   80     （平均60）\nxの偏差     -2   -1    0   +1   +2\nyの偏差    -20  -10    0  +10  +20\n\n偏差どうしを掛ける\n（※マイナスどうしの掛け算はプラスになる。\n  「平均より下」×「平均より下」＝同じ向き、と覚えてよい）\n  (-2)×(-20)=40  (-1)×(-10)=10  0  (+1)×(+10)=10  (+2)×(+20)=40\n全部プラス ＝ xとyが同じ向きに動いている証拠\n\nこの積の平均を、xとyそれぞれの散らばりで割って\n-1〜+1の物差しに揃えたものが相関係数（この例はきれいな直線なので +1）。\n逆向きに動けばマイナス、バラバラなら0付近。"}'::jsonb
WHERE source_ref = 'g-kentei-c-q43' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "シグモイドに実際の数を入れてみる。\n\n入力     -3     0     +3\n出力    0.05   0.5   0.95\n\nどんな数を入れても出口は必ず0〜1の間。\n入力0のとき、ちょうど0.5（五分五分）。\nだから出力を「陽性である確率」として読める。\n\n最後に記号版: σ(x) = 1 ÷ (1 + e^(−x))\n（e ≒ 2.72 という決まった数）\n確かめ: x=0 のとき e^0 = 1 → 1÷(1+1) = 0.5 ✓"}'::jsonb
WHERE source_ref = 'g-kentei-d-q18' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "坂を下る1歩を実際に計算する。\n\n誤差の坂（重みをズラすと誤差がどう変わるか）\n  重み 1.0 → 誤差 9\n  重み 2.0 → 誤差 4\n  重み 3.0 → 誤差 1    …谷（誤差最小）は重み4のあたり\n\nいま重み2.0にいる。坂の傾きは「右へ行くほど誤差が減る」向き。\n勾配降下法の指示:「傾きと逆＝誤差が減る方へ、一歩の大きさ×傾きの分だけ動け」\n\n一歩の大きさ（学習率）0.5、傾きの大きさ 4 とすると\n  動く量 = 0.5 × 4 = 2.0\n  新しい重み = 2.0 + 2.0 = 4.0 → 谷に到着\n\nこれを何千回も繰り返すのがニューラルネットワークの学習。"}'::jsonb
WHERE source_ref = 'g-kentei-d-q23' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "MSE（平均二乗誤差）を3件で計算する。\n\n正解    10   20   30\n予測    12   18   33\n差      +2   -2   +3\n2乗      4    4    9   ← マイナスが消え、大外しほど重い罰\n\nMSE = (4 + 4 + 9) ÷ 3 = 17 ÷ 3 ≒ 5.7\n\n小さいほど良い。差3の1件（罰9）が差2（罰4）より\nずっと重く効くのが「2乗」の性質。\n\n最後に記号版: MSE = Σ(予測 − 正解)² ÷ n\n（Σ＝シグマ＝ぜんぶ足す、n＝件数）"}'::jsonb
WHERE source_ref = 'g-kentei-d-q40' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "決定係数R²＝「ばらつきのうち何割を説明できたか」。\n\n正解データのばらつき（平均からのズレの2乗の合計）  100\nモデルが外した分（予測とのズレの2乗の合計）        20\n\n説明できた割合 R² = 1 − 20 ÷ 100 = 0.8\n\n読み方:「データの動き100のうち80をモデルで説明できた」。\n完璧な予測なら外し0で R²=1。\n平均を言うだけのモデルなら外し100で R²=0。"}'::jsonb
WHERE source_ref = 'g-kentei-d-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "コサイン類似度＝長さではなく「向き」の近さ。\n\n文書を単語の出現回数で数の並びにする\n  文書A = (2, 1)   （「猫」2回、「犬」1回）\n  文書B = (4, 2)   （Aのちょうど2倍。長いだけで向きは同じ）\n  文書C = (1, 2)   （比率が逆。向きが違う）\n\nAとB: 向きが完全に同じ → 類似度 1（文書の長さの違いは無視される）\n\nAとCを計算する。矢印の長さ＝√(2²+1²)＝√5\n（√5＝「2乗すると5になる数」。√5×√5 = 5）\nAとC: (2×1 + 1×2) ÷ (√5 × √5) = 4 ÷ 5 = 0.8\n\n長い文書と短い文書でも「単語の使われ方の比率」が近ければ\n似ていると判定できるのがこの指標の強み。"}'::jsonb
WHERE source_ref = 'g-kentei-d-q42' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "期待値＝起こりやすさで重みを付けた平均。くじで計算する。\n\nくじ10本: 1等1000円が1本、はずれ0円が9本\n\n期待値 = 1000円 × 1/10 ＋ 0円 × 9/10\n       = 100円 ＋ 0円\n       = 100円\n\n読み方:「1回引くと平均100円もらえる見込み」。\nこのくじが1回150円で売られていたら、引くほど損と分かる。\n\n最後に記号版: 期待値 E = Σ(値 × その確率)\n（Σ＝シグマ＝ぜんぶ足す）"}'::jsonb
WHERE source_ref = 'g-kentei-d-q43' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "学習率＝一歩の大きさ。実際に動かしてみる。\n\n今の重み          2.0\n坂の傾き（勾配）    4 （右へ行くほど誤差が増える坂）\n動かす向き        傾きと逆＝左へ\n\n学習率 0.1  のとき  2.0 − 0.1×4 = 2.0 − 0.4 = 1.6   ← 少しずつ谷へ\n学習率 1.0  のとき  2.0 − 1.0×4 = 2.0 − 4.0 → 谷を大きく飛び越す（発散のもと）\n学習率 0.001のとき  2.0 − 0.001×4 = 1.996           ← ほぼ進まない（遅い）\n\n最後に記号版: w ← w − η × 勾配\n（w＝重み、η＝イータ＝学習率。いまやった計算そのもの）"}'::jsonb
WHERE source_ref = 'g-kentei-e-q23' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "再現率＝本当の患者のうち何人拾えたか。\n\nがん患者 10人を検査したら\n  陽性と当てた  9人\n  見落とした    1人 ← これを減らしたい\n\n再現率 = 9 ÷ 10 = 0.9\n\n見落としを減らす＝この0.9を1.0に近づけること。\nそのぶん健康な人への空振り（誤検出）は増えやすいが、\n「見落としたら命に関わる」場面では再現率を優先する。\n\n最後に記号版: 再現率(Recall) = TP ÷ (TP + FN)\n（TP=True Positive 正しく発見、FN=False Negative 見落とし）"}'::jsonb
WHERE source_ref = 'g-kentei-e-q40' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "F値がなぜ「ふつうの平均」ではだめかを計算で見る。\n\nモデル: 適合率 0.8、再現率 0.4\n\nふつうの平均  (0.8 + 0.4) ÷ 2 = 0.6\nF値（調和平均） 2 × 0.8 × 0.4 ÷ (0.8 + 0.4)\n             = 0.64 ÷ 1.2 ≒ 0.53  ← 低い方に引っぱられる\n\n極端な例: 全員に「陽性」と言えば再現率1.0。でも適合率0.02なら\n  ふつうの平均 = 0.51（そこそこに見えてしまう）\n  F値 = 2 × 1.0 × 0.02 ÷ 1.02 ≒ 0.04（ちゃんと落第点）\n\n片方をサボると急落する。だからバランスの指標になる。"}'::jsonb
WHERE source_ref = 'g-kentei-e-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || '{"calc": "68%を実際の点数でつかむ。\n\nテストの点: 平均60点、標準偏差10点 の正規分布とする\n\n±1σ（1標準偏差）: 60−10 〜 60+10 = 50〜70点 → 約68%（約7割）\n±2σ            : 60−20 〜 60+20 = 40〜80点 → 約95%\n±3σ            : 60−30 〜 60+30 = 30〜90点 → 約99.7%\n\n覚え方は「68・95・99.7」。\n「50〜70点に7割、40〜80点にほぼ全員」という感覚で持っておく。\n（σ＝シグマ＝標準偏差。散らばりの物差し）"}'::jsonb
WHERE source_ref = 'g-kentei-e-q42' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

COMMIT;
