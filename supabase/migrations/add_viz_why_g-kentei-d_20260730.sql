BEGIN;

-- g-kentei-d: 仕組み系問題への viz(SVG図解) 後付け + why_asked 全問補完
-- 既存キーは維持したまま || でマージする

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "AGIと特化型AI、エキスパートシステムを混同しやすいため、それぞれの定義の違いを問う定番の出題。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q1';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "AIの能力段階(レベル1〜4)の順序と、どこまでを人が設計しどこから機械が学ぶかの境目を問う定番の出題。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q2';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "記号主義と結合主義という2大アプローチの対比は頻出で、ディープラーニングがどちらの系譜かを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q3';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "AGIとの対比で問われる定番の用語で、現状のAIがどちらに属するかの理解を確かめる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q4';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "シンギュラリティやムーアの法則など紛らわしい用語と並べて問われやすい、AIの歴史の節目。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q5';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "日本発のAIプロジェクトの限界事例として頻出で、AlphaGoやWatsonとの混同を狙われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q6';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "ニューラルネットワークの起源として、年代や後続の手法とセットで問われやすい。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q7';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "ディープラーニング普及を支えた技術要因の一つとして、ビッグデータ・アルゴリズムの進歩と並べて問われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q8';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "オープンデータやメタデータなど似た響きの語との混同を狙われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q9';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "第1次AIブームの中心概念として、機械学習が中心の第3次ブームとの時代の違いを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q10';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "k-meansやランダムフォレストなど他の手法名と混同されやすく、「特徴が独立」という前提が問われる。", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">各特徴は独立と仮定して確率を掛け合わせる</text>\n<rect x=\"20\" y=\"35\" width=\"70\" height=\"24\" rx=\"3\" fill=\"none\" stroke=\"#60a5fa\"/>\n<text x=\"55\" y=\"51\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">P(単語A|スパム)</text>\n<text x=\"95\" y=\"51\" font-size=\"12\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">×</text>\n<rect x=\"105\" y=\"35\" width=\"70\" height=\"24\" rx=\"3\" fill=\"none\" stroke=\"#60a5fa\"/>\n<text x=\"140\" y=\"51\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">P(単語B|スパム)</text>\n<text x=\"180\" y=\"51\" font-size=\"12\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">×</text>\n<rect x=\"190\" y=\"35\" width=\"70\" height=\"24\" rx=\"3\" fill=\"none\" stroke=\"#60a5fa\"/>\n<text x=\"225\" y=\"51\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">P(単語C|スパム)</text>\n<line x1=\"170\" y1=\"70\" x2=\"170\" y2=\"88\" stroke=\"#2a2f3f\"/>\n<polygon points=\"170,90 165,82 175,82\" fill=\"#2a2f3f\"/>\n<rect x=\"110\" y=\"93\" width=\"120\" height=\"26\" rx=\"3\" fill=\"none\" stroke=\"#6ab08d\"/>\n<text x=\"170\" y=\"110\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"bold\">スパムらしさの確率(高い)</text>\n<text x=\"170\" y=\"132\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">本来は単語どうしの組み合わせも考えたいが、独立と割り切ると計算が軽くなる</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q11';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "k-means法(教師なしのクラスタリング)との混同が、この試験で最も定番の引っかけの一つ。", "viz": "<svg viewBox=\"0 0 340 150\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">予測時に近くのk個を見て多数決する</text>\n<circle cx=\"170\" cy=\"85\" r=\"46\" fill=\"none\" stroke=\"#2a2f3f\" stroke-dasharray=\"3,3\"/>\n<circle cx=\"170\" cy=\"85\" r=\"4\" fill=\"#e8eaf0\"/>\n<text x=\"170\" y=\"70\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">新しいデータ</text>\n<circle cx=\"150\" cy=\"70\" r=\"5\" fill=\"#60a5fa\"/>\n<circle cx=\"195\" cy=\"75\" r=\"5\" fill=\"#60a5fa\"/>\n<circle cx=\"145\" cy=\"100\" r=\"5\" fill=\"#c9a04a\"/>\n<circle cx=\"225\" cy=\"110\" r=\"5\" fill=\"#60a5fa\"/>\n<circle cx=\"280\" cy=\"120\" r=\"5\" fill=\"#c9a04a\"/>\n<circle cx=\"255\" cy=\"45\" r=\"5\" fill=\"#c9a04a\"/>\n<text x=\"170\" y=\"138\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">近い3個のうち2個が水色→水色クラスと判定(k=3)</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q12';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "ラベルエンコーディングとの違い(順序を持たせるかどうか)がよく問われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q13';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "データ拡張・次元削減など似た前処理用語との弁別を問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q14';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "アンダーサンプリングとの逆方向の混同が狙われやすい。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q15';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "過学習対策の代表として、標準化や次元削減との目的の違いが問われる。", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">重みが大きいほどペナルティを課す</text>\n<text x=\"80\" y=\"30\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">正則化なし</text>\n<rect x=\"50\" y=\"36\" width=\"14\" height=\"55\" fill=\"#c47070\"/>\n<rect x=\"70\" y=\"60\" width=\"14\" height=\"31\" fill=\"#c47070\"/>\n<rect x=\"90\" y=\"45\" width=\"14\" height=\"46\" fill=\"#c47070\"/>\n<text x=\"80\" y=\"105\" font-size=\"8\" fill=\"#c47070\" text-anchor=\"middle\" font-weight=\"normal\">重みが暴れる→過学習</text>\n<line x1=\"170\" y1=\"60\" x2=\"200\" y2=\"60\" stroke=\"#2a2f3f\"/>\n<polygon points=\"205,60 197,55 197,65\" fill=\"#2a2f3f\"/>\n<text x=\"265\" y=\"30\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">正則化あり</text>\n<rect x=\"240\" y=\"70\" width=\"14\" height=\"21\" fill=\"#6ab08d\"/>\n<rect x=\"260\" y=\"75\" width=\"14\" height=\"16\" fill=\"#6ab08d\"/>\n<rect x=\"280\" y=\"72\" width=\"14\" height=\"19\" fill=\"#6ab08d\"/>\n<text x=\"265\" y=\"105\" font-size=\"8\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">小さく揃う→なめらか</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q16';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "過学習との対比が最頻出で、訓練データでの成績から見分ける判断力が問われる。", "viz": "<svg viewBox=\"0 0 340 145\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">モデルの当てはまり方の3パターン</text>\n<circle cx=\"45\" cy=\"45\" r=\"3\" fill=\"#8892a4\"/><circle cx=\"65\" cy=\"35\" r=\"3\" fill=\"#8892a4\"/>\n<circle cx=\"85\" cy=\"50\" r=\"3\" fill=\"#8892a4\"/><circle cx=\"105\" cy=\"38\" r=\"3\" fill=\"#8892a4\"/>\n<line x1=\"35\" y1=\"55\" x2=\"115\" y2=\"30\" stroke=\"#c47070\" stroke-width=\"2\"/>\n<text x=\"75\" y=\"75\" font-size=\"9\" fill=\"#c47070\" text-anchor=\"middle\" font-weight=\"bold\">未学習</text>\n<text x=\"75\" y=\"87\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">単純すぎて外す</text>\n\n<circle cx=\"155\" cy=\"45\" r=\"3\" fill=\"#8892a4\"/><circle cx=\"175\" cy=\"35\" r=\"3\" fill=\"#8892a4\"/>\n<circle cx=\"195\" cy=\"50\" r=\"3\" fill=\"#8892a4\"/><circle cx=\"215\" cy=\"38\" r=\"3\" fill=\"#8892a4\"/>\n<path d=\"M145,52 Q180,25 225,42\" fill=\"none\" stroke=\"#6ab08d\" stroke-width=\"2\"/>\n<text x=\"185\" y=\"75\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"bold\">ちょうど良い</text>\n<text x=\"185\" y=\"87\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">初見にも強い</text>\n\n<circle cx=\"265\" cy=\"45\" r=\"3\" fill=\"#8892a4\"/><circle cx=\"285\" cy=\"35\" r=\"3\" fill=\"#8892a4\"/>\n<circle cx=\"305\" cy=\"50\" r=\"3\" fill=\"#8892a4\"/><circle cx=\"325\" cy=\"38\" r=\"3\" fill=\"#8892a4\"/>\n<path d=\"M255,52 Q265,30 285,45 Q295,25 305,52 Q315,20 335,42\" fill=\"none\" stroke=\"#c9a04a\" stroke-width=\"2\"/>\n<text x=\"295\" y=\"75\" font-size=\"9\" fill=\"#c9a04a\" text-anchor=\"middle\" font-weight=\"bold\">過学習</text>\n<text x=\"295\" y=\"87\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">点を暗記して外す</text>\n<text x=\"170\" y=\"120\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">訓練でも本番でも精度が低いのが未学習、訓練だけ良いのが過学習</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q17';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "ソフトマックス関数やReLU関数との使い分け(二値か多クラスか、出力層か中間層か)が定番。", "viz": "<svg viewBox=\"0 0 340 130\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">シグモイド関数：0〜1に押し込む</text>\n<line x1=\"40\" y1=\"100\" x2=\"300\" y2=\"100\" stroke=\"#2a2f3f\"/>\n<line x1=\"170\" y1=\"20\" x2=\"170\" y2=\"105\" stroke=\"#2a2f3f\" stroke-dasharray=\"2,2\"/>\n<path d=\"M40,98 C90,98 130,60 170,60 C210,60 250,22 300,22\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"2\"/>\n<text x=\"35\" y=\"25\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"end\" font-weight=\"normal\">1</text>\n<text x=\"35\" y=\"100\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"end\" font-weight=\"normal\">0</text>\n<text x=\"170\" y=\"115\" font-size=\"9\" fill=\"#c9a04a\" text-anchor=\"middle\" font-weight=\"normal\">0.5(境目)</text>\n<text x=\"170\" y=\"128\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">陽性である確率のような、二値の確率出力に使う</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q18';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "シグモイド関数との範囲・出力の中心の違いが問われる。", "viz": "<svg viewBox=\"0 0 340 130\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">tanh関数：-1〜+1、中心は0</text>\n<line x1=\"40\" y1=\"65\" x2=\"300\" y2=\"65\" stroke=\"#2a2f3f\"/>\n<line x1=\"170\" y1=\"20\" x2=\"170\" y2=\"105\" stroke=\"#2a2f3f\" stroke-dasharray=\"2,2\"/>\n<path d=\"M40,105 C90,105 130,65 170,65 C210,65 250,25 300,25\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"2\"/>\n<text x=\"35\" y=\"28\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"end\" font-weight=\"normal\">+1</text>\n<text x=\"35\" y=\"65\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"end\" font-weight=\"normal\">0</text>\n<text x=\"35\" y=\"105\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"end\" font-weight=\"normal\">-1</text>\n<text x=\"170\" y=\"118\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">中心が0なので、0〜1に偏るシグモイドより学習が偏りにくい</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q19';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "勾配消失・勾配爆発の原因としてセットで問われやすい。", "viz": "<svg viewBox=\"0 0 340 145\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">初期値しだいで信号の伝わり方が変わる</text>\n<text x=\"70\" y=\"30\" font-size=\"9\" fill=\"#c47070\" text-anchor=\"middle\" font-weight=\"normal\">不適切な初期化</text>\n<rect x=\"30\" y=\"40\" width=\"26\" height=\"26\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"70\" y=\"40\" width=\"26\" height=\"18\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"110\" y=\"45\" width=\"26\" height=\"10\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<line x1=\"56\" y1=\"53\" x2=\"70\" y2=\"49\" stroke=\"#c47070\" stroke-width=\"3\"/>\n<line x1=\"96\" y1=\"49\" x2=\"110\" y2=\"50\" stroke=\"#c47070\" stroke-width=\"1\"/>\n<text x=\"80\" y=\"78\" font-size=\"8\" fill=\"#c47070\" text-anchor=\"middle\" font-weight=\"normal\">層を通るたび信号が消える(勾配消失)</text>\n\n<text x=\"250\" y=\"30\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">適切な初期化</text>\n<rect x=\"210\" y=\"40\" width=\"26\" height=\"22\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"250\" y=\"40\" width=\"26\" height=\"22\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"290\" y=\"40\" width=\"26\" height=\"22\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<line x1=\"236\" y1=\"51\" x2=\"250\" y2=\"51\" stroke=\"#6ab08d\" stroke-width=\"2\"/>\n<line x1=\"276\" y1=\"51\" x2=\"290\" y2=\"51\" stroke=\"#6ab08d\" stroke-width=\"2\"/>\n<text x=\"260\" y=\"78\" font-size=\"8\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">信号の大きさが保たれ、学習が進む</text>\n<text x=\"170\" y=\"115\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">全部同じ値だと、どのノードも同じ計算しかできず学習が進まない</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q20';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "バッチサイズや学習率など似た響きの用語の中で、単位の定義を混同しないかを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q21';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "モメンタムやAdamとの違い、最適化手法の進化の順序を問う定番の出題。", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">方向ごとに歩幅を自動で変える</text>\n<ellipse cx=\"170\" cy=\"75\" rx=\"120\" ry=\"40\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<ellipse cx=\"170\" cy=\"75\" rx=\"75\" ry=\"25\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<circle cx=\"170\" cy=\"75\" r=\"3\" fill=\"#e8eaf0\"/>\n<line x1=\"105\" y1=\"75\" x2=\"120\" y2=\"75\" stroke=\"#c47070\" stroke-width=\"2\"/>\n<polygon points=\"123,75 115,71 115,79\" fill=\"#c47070\"/>\n<text x=\"85\" y=\"65\" font-size=\"8\" fill=\"#c47070\" text-anchor=\"middle\" font-weight=\"normal\">急な方向：歩幅を小さく</text>\n<line x1=\"170\" y1=\"15\" x2=\"170\" y2=\"55\" stroke=\"#6ab08d\" stroke-width=\"2\"/>\n<polygon points=\"170,58 166,50 174,50\" fill=\"#6ab08d\"/>\n<text x=\"230\" y=\"45\" font-size=\"8\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">緩い方向：歩幅を大きく</text>\n<text x=\"170\" y=\"128\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">勾配の大きさに応じて、方向ごとに学習率を自動調整する</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q22';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "最適化の最も基本的な考え方として、SGDやAdamの土台にある概念を問う。", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">誤差が減る方向へ重みを動かす</text>\n<path d=\"M40,50 Q170,130 300,50\" fill=\"none\" stroke=\"#2a2f3f\" stroke-width=\"2\"/>\n<circle cx=\"90\" cy=\"72\" r=\"5\" fill=\"#60a5fa\"/>\n<circle cx=\"150\" cy=\"102\" r=\"5\" fill=\"#60a5fa\"/>\n<circle cx=\"170\" cy=\"112\" r=\"5\" fill=\"#6ab08d\"/>\n<line x1=\"90\" y1=\"72\" x2=\"140\" y2=\"98\" stroke=\"#60a5fa\" stroke-dasharray=\"2,2\"/>\n<line x1=\"150\" y1=\"102\" x2=\"165\" y2=\"110\" stroke=\"#60a5fa\" stroke-dasharray=\"2,2\"/>\n<text x=\"60\" y=\"30\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"start\" font-weight=\"normal\">誤差(高さ)</text>\n<text x=\"170\" y=\"128\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">谷底(誤差が最小)に向かって少しずつ下る</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q23';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "自己注意(Self-Attention)との違いを問う、Transformerの中核部品として頻出。", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">複数の観点の注意を同時に計算して束ねる</text>\n<rect x=\"35\" y=\"30\" width=\"60\" height=\"26\" rx=\"3\" fill=\"none\" stroke=\"#60a5fa\"/>\n<text x=\"65\" y=\"47\" font-size=\"8\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">文法の観点</text>\n<rect x=\"140\" y=\"30\" width=\"60\" height=\"26\" rx=\"3\" fill=\"none\" stroke=\"#6ab08d\"/>\n<text x=\"170\" y=\"47\" font-size=\"8\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">意味の観点</text>\n<rect x=\"245\" y=\"30\" width=\"60\" height=\"26\" rx=\"3\" fill=\"none\" stroke=\"#c9a04a\"/>\n<text x=\"275\" y=\"47\" font-size=\"8\" fill=\"#c9a04a\" text-anchor=\"middle\" font-weight=\"normal\">指示語の観点</text>\n<line x1=\"65\" y1=\"60\" x2=\"150\" y2=\"85\" stroke=\"#2a2f3f\"/>\n<line x1=\"170\" y1=\"60\" x2=\"170\" y2=\"85\" stroke=\"#2a2f3f\"/>\n<line x1=\"275\" y1=\"60\" x2=\"190\" y2=\"85\" stroke=\"#2a2f3f\"/>\n<rect x=\"120\" y=\"88\" width=\"100\" height=\"26\" rx=\"3\" fill=\"none\" stroke=\"#e8eaf0\"/>\n<text x=\"170\" y=\"105\" font-size=\"9\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">まとめて豊かな文脈表現</text>\n<text x=\"170\" y=\"130\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">1種類の注意だけより、多面的に単語どうしの関係を捉えられる</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q24';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "プーリング層・畳み込み層など他の層名との混同を狙われる。", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">意味が近い語ほど近くに配置する</text>\n<line x1=\"30\" y1=\"70\" x2=\"310\" y2=\"70\" stroke=\"#2a2f3f\"/>\n<line x1=\"170\" y1=\"20\" x2=\"170\" y2=\"120\" stroke=\"#2a2f3f\"/>\n<line x1=\"130\" y1=\"50\" x2=\"150\" y2=\"90\" stroke=\"#2a2f3f\" stroke-dasharray=\"3,3\"/>\n<line x1=\"230\" y1=\"48\" x2=\"248\" y2=\"88\" stroke=\"#2a2f3f\" stroke-dasharray=\"3,3\"/>\n<circle cx=\"130\" cy=\"50\" r=\"4\" fill=\"#60a5fa\"/><text x=\"130\" y=\"40\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">王</text>\n<circle cx=\"150\" cy=\"90\" r=\"4\" fill=\"#60a5fa\"/><text x=\"150\" y=\"105\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">女王</text>\n<circle cx=\"230\" cy=\"48\" r=\"4\" fill=\"#6ab08d\"/><text x=\"230\" y=\"38\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">男性</text>\n<circle cx=\"248\" cy=\"88\" r=\"4\" fill=\"#6ab08d\"/><text x=\"248\" y=\"103\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">女性</text>\n<text x=\"170\" y=\"132\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">単語を意味の近さが距離に表れる密なベクトルに変換し、変換自体も学習する</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q25';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "プーリングと逆方向の操作であることを問う、CNN応用の定番。", "viz": "<svg viewBox=\"0 0 340 130\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">小さな特徴マップを引き伸ばす</text>\n<rect x=\"40\" y=\"45\" width=\"30\" height=\"30\" fill=\"none\" stroke=\"#60a5fa\"/>\n<line x1=\"8\" y1=\"15\" x2=\"8\" y2=\"105\" stroke=\"none\"/>\n<text x=\"55\" y=\"40\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">小</text>\n<line x1=\"75\" y1=\"60\" x2=\"145\" y2=\"60\" stroke=\"#2a2f3f\"/>\n<polygon points=\"150,60 140,54 140,66\" fill=\"#2a2f3f\"/>\n<text x=\"112\" y=\"50\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">転置畳み込み</text>\n<rect x=\"155\" y=\"30\" width=\"120\" height=\"65\" fill=\"none\" stroke=\"#6ab08d\"/>\n<text x=\"215\" y=\"22\" font-size=\"8\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">大(元の大きさ)</text>\n<text x=\"170\" y=\"120\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">画像生成やセグメンテーションで、小さな特徴を元の大きさに戻すのに使う</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q26';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "ワンホットエンコーディングなど別の前処理との混同を狙われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q27';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "バッチ正規化との違い(そろえる範囲がバッチ全体か1サンプル内か)が頻出の引っかけ。", "viz": "<svg viewBox=\"0 0 340 145\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">どの範囲でそろえるかが違う</text>\n<text x=\"85\" y=\"28\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">バッチ正規化</text>\n<rect x=\"45\" y=\"35\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"65\" y=\"35\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"85\" y=\"35\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"45\" y=\"51\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"65\" y=\"51\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"85\" y=\"51\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"43\" y=\"33\" width=\"18\" height=\"34\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"2\"/>\n<text x=\"85\" y=\"78\" font-size=\"8\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">同じ特徴を、まとまり(バッチ)全体でそろえる</text>\n\n<text x=\"260\" y=\"28\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">レイヤー正規化</text>\n<rect x=\"220\" y=\"35\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"240\" y=\"35\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"260\" y=\"35\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"220\" y=\"51\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"240\" y=\"51\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/><rect x=\"260\" y=\"51\" width=\"18\" height=\"14\" fill=\"none\" stroke=\"#2a2f3f\"/>\n<rect x=\"218\" y=\"49\" width=\"64\" height=\"18\" fill=\"none\" stroke=\"#6ab08d\" stroke-width=\"2\"/>\n<text x=\"255\" y=\"78\" font-size=\"8\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">1サンプル内の特徴どうしでそろえる</text>\n<text x=\"170\" y=\"105\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">バッチが小さいと不安定になりやすいのがバッチ正規化</text>\n<text x=\"170\" y=\"120\" font-size=\"8\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">系列データやTransformerはレイヤー正規化と相性がよい</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q28';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "全結合層だけ・回帰結合層だけの構成との違いを問う、CNNの基本理解。", "viz": "<svg viewBox=\"0 0 340 120\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">CNNの典型的な流れ</text>\n<rect x=\"15\" y=\"40\" width=\"55\" height=\"30\" rx=\"3\" fill=\"none\" stroke=\"#60a5fa\"/><text x=\"42\" y=\"58\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\" font-weight=\"normal\">入力画像</text>\n<line x1=\"70\" y1=\"55\" x2=\"85\" y2=\"55\" stroke=\"#2a2f3f\"/><polygon points=\"88,55 80,50 80,60\" fill=\"#2a2f3f\"/>\n<rect x=\"90\" y=\"40\" width=\"55\" height=\"30\" rx=\"3\" fill=\"none\" stroke=\"#6ab08d\"/><text x=\"117\" y=\"55\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">畳み込み</text><text x=\"117\" y=\"65\" font-size=\"7\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">+プーリング</text>\n<line x1=\"145\" y1=\"55\" x2=\"160\" y2=\"55\" stroke=\"#2a2f3f\"/><polygon points=\"163,55 155,50 155,60\" fill=\"#2a2f3f\"/>\n<rect x=\"165\" y=\"40\" width=\"55\" height=\"30\" rx=\"3\" fill=\"none\" stroke=\"#6ab08d\"/><text x=\"192\" y=\"55\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"middle\" font-weight=\"normal\">(繰り返し)</text>\n<line x1=\"220\" y1=\"55\" x2=\"235\" y2=\"55\" stroke=\"#2a2f3f\"/><polygon points=\"238,55 230,50 230,60\" fill=\"#2a2f3f\"/>\n<rect x=\"240\" y=\"40\" width=\"85\" height=\"30\" rx=\"3\" fill=\"none\" stroke=\"#c9a04a\"/><text x=\"282\" y=\"55\" font-size=\"9\" fill=\"#c9a04a\" text-anchor=\"middle\" font-weight=\"normal\">全結合層で分類</text>\n<text x=\"170\" y=\"100\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">特徴を抽出してから、最後にまとめて判定する流れ</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q29';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "画像分類や異常検知など他の画像タスクとの弁別を問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q30';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "物体検出やセグメンテーションとの違いを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q31';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "音声認識との向きの逆転(テキスト→音声か音声→テキストか)が最頻出の引っかけ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q32';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "感情分析や機械翻訳など他のNLPタスクとの弁別を問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q33';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "異常検知や固有表現抽出との混同を狙われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q34';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "音声認識や画像生成との違いを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q35';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "逆方向のタスク(画像からの説明文生成)との混同が定番。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q36';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "交差検証やグリッドサーチとの違い(実運用での比較か、モデル選定かの目的の違い)を問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q37';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "フルオートメーションとの対比で、AIの社会実装の考え方として問われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q38';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "学習・デプロイとの段階の違いを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q39';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "混同行列やROC曲線など分類指標との混同(回帰指標か分類指標かの違い)を狙われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q40';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "再現率や標準偏差との混同を狙われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q41';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "平均二乗誤差など他の指標との違い(向きの近さを測るか、値の差を測るか)を問う。", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"14\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\" font-weight=\"bold\">同じ向きをどれだけ向いているか</text>\n<line x1=\"90\" y1=\"105\" x2=\"230\" y2=\"105\" stroke=\"#2a2f3f\"/>\n<line x1=\"90\" y1=\"105\" x2=\"200\" y2=\"35\" stroke=\"#60a5fa\" stroke-width=\"2\"/>\n<polygon points=\"200,35 191,42 197,47\" fill=\"#60a5fa\"/>\n<text x=\"205\" y=\"30\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"start\" font-weight=\"normal\">単語A</text>\n<line x1=\"90\" y1=\"105\" x2=\"215\" y2=\"45\" stroke=\"#6ab08d\" stroke-width=\"2\"/>\n<polygon points=\"215,45 204,47 209,53\" fill=\"#6ab08d\"/>\n<text x=\"220\" y=\"42\" font-size=\"9\" fill=\"#6ab08d\" text-anchor=\"start\" font-weight=\"normal\">単語B</text>\n<path d=\"M120,90 A30,30 0 0,1 130,75\" fill=\"none\" stroke=\"#c9a04a\"/>\n<text x=\"140\" y=\"88\" font-size=\"10\" fill=\"#c9a04a\" text-anchor=\"middle\" font-weight=\"normal\">θ</text>\n<text x=\"170\" y=\"128\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\" font-weight=\"normal\">向きが近い(θが小さい)ほどコサイン類似度は1に近づく</text>\n</svg>"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q42';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "中央値・最頻値・標準偏差との違いを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q43';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "著作権が保護する対象について、アイデアと表現の区別が最頻出の論点。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q44';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "作成した従業員個人が著作者になると誤解しやすいため、原則を確認する狙い。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q45';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "完成保証型の一括請負との違いを問う、AI開発特有の契約形態として頻出。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q46';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "公平性や頑健性など他のAI倫理原則との弁別を問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q47';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "スケーラビリティなど無関係な語と並べて紛らわしさを狙われる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q48';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "データポイズニングや敵対的サンプルとの攻撃手法の違いを問う。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q49';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"why_asked": "日本の「人間中心のAI社会原則」との国・性質の違いが頻出の引っかけ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q50';

COMMIT;
