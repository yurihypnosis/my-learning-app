BEGIN;

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["ソフトマックス関数", "複数の出力を、合計が1（100%）になる確率に変える。多クラス分類の出口で使う"], ["シグモイド関数", "1つの値を0〜1に押し込む関数。イエス/ノーの二択の出口で使う"], ["ReLU（Rectified Linear Unit）", "rectify＝整流する。マイナスを0に切りそろえ、プラスはそのまま通す。勾配消失を起こしにくく、深いネットワークで標準の活性化関数"]]'::jsonb)
WHERE source_ref = 'g-kentei-q19' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["誤差逆伝播法", "出力のズレを後ろの層から前へ伝えて、各重みの直し方（勾配）を効率よく求める方法"], ["連鎖律", "掛け算のようにつなげて微分する数学の規則。誤差逆伝播の土台"], ["PCA（Principal Component Analysis）", "直訳は「主成分分析」。主成分＝データが一番散らばる方向。データが一番散らばる方向を見つけて次元を減らす手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-q21' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["畳み込み層", "小さなフィルタを画像全体で使い回し、場所によらず線や角などの局所的な特徴を拾う層"], ["重み共有", "同じフィルタを全体で使い回すことで、覚える数（パラメータ）を少なく抑える仕組み"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。画像認識で標準のニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q24' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["最大値プーリング", "小さな領域の中の一番大きい値で代表させ、特徴マップを縮めつつ位置ズレに強くする操作"], ["位置ズレへの強さ", "入力が少しズレても、出力があまり変わらない性質"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。画像認識で標準のニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q25' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。覚える/忘れる/出すの門と記憶用の入れ物で、長い系列でも情報を保てるようにしたRNNの改良版"], ["GRU（Gated Recurrent Unit）", "直訳は「ゲート付きの再帰ユニット」。LSTMを簡単にして、少ない門で似た効果をねらった手法"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。文章や音声など、順番が意味を持つデータ向きのネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q26' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["Transformer", "注意の仕組みだけで文を処理し、まとめて計算できて長い関係も扱えるつくり"], ["位置エンコーディング", "一度に処理すると失われる語順を補うため、位置の情報を加える工夫"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。文章や音声など、順番が意味を持つデータ向きのネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q28' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["word2vec（word to vector）", "直訳は「単語をベクトル（数の並び）へ」。周りにどんな語が来るかから単語を数値の並びにして、意味の近さを距離で表す手法"], ["one-hotベクトル", "1語につき1か所だけ1にする表し方。意味の近さは表せない"], ["BoW（Bag-of-Words）", "直訳は「単語の袋」。語順を捨てて、どの単語が何回出たかだけ数える。簡単で速いが語順の意味は失われる、古典的な文書の表し方"]]'::jsonb)
WHERE source_ref = 'g-kentei-q33' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["拡散モデル", "わざとノイズを加える手順を逆にたどり、ノイズから少しずつ画像を作り出すモデル"], ["ノイズ除去", "拡散モデルの学習の要。各段階で加わったノイズを予想して取り除く"], ["SVM（Support Vector Machine）", "support vector＝境界を支える点。境界のすぐそばの点だけが境界を決める。境界と点の余白（マージン）を最大にして分類する手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-q35' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["PoC（Proof of Concept＝概念実証）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本格開発の前に、小さく試して実現できるか・効果があるかを確かめる工程"], ["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。作ったモデルを運用しながら、監視や作り直しを継続的に回す実践"]]'::jsonb)
WHERE source_ref = 'g-kentei-q37' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["F値（F1スコア）", "適合率と再現率を1つにまとめた成績（調和平均）。両方のバランスを表す"], ["正解率（Accuracy）", "全体のうち当たった割合。ただしデータの数が偏ると当てにならない"], ["MSE（Mean Squared Error）", "直訳は「誤差を2乗した平均」。予測と正解のズレを2乗して平均した誤差の物差し"]]'::jsonb)
WHERE source_ref = 'g-kentei-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["XAI（Explainable AI＝説明可能なAI）", "直訳は「説明可能なAI」。AIの判断理由を、人に分かる形で示そうとする取り組み"], ["SHAP（SHapley Additive exPlanations）", "ゲーム理論のShapley値（貢献度の公平な山分け）で各項目の貢献を測る。どの特徴が予測にどれだけ効いたかを計算して説明する、代表的な手法"], ["LIME（Local Interpretable Model-agnostic Explanations）", "直訳は「局所的で・解釈可能な・モデルを問わない説明」。1件の予測の近くだけ単純なモデルで真似て理由を示す説明手法"], ["BERT（Bidirectional Encoder Representations from Transformers）", "直訳は「Transformerによる双方向（bidirectional）の符号化表現」。文の前後両方を見て意味を理解する言語モデル"], ["GPT（Generative Pre-trained Transformer）", "直訳は「生成（generate）のために事前学習（pre-train）したTransformer」。前から次の語を予測して文章を生成する言語モデル"], ["ResNet（Residual Network）", "residual＝残差。学ぶのを「差分だけ」にして深い層を可能にした。スキップ結合で超深層を学習可能にしたネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q48' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["ダートマス会議", "1956年、マッカーシーらが開いた会議。ここで「人工知能」という言葉が初めて使われた"], ["第1次AIブーム", "この会議の後に始まった、探索や推論で問題を解く最初のブーム"], ["ILSVRC（ImageNet Large Scale Visual Recognition Challenge）", "直訳は「ImageNet大規模画像認識チャレンジ」。画像認識の精度を競う大会。2012年にディープラーニングが圧勝した舞台"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q2' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["GRU（Gated Recurrent Unit）", "直訳は「ゲート付きの再帰ユニット」。LSTMより門(ゲート)を減らして簡単にした、系列を扱う手法。計算が軽い"], ["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。門と記憶で長い系列の情報を保つ、RNNの改良版"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。画像認識で標準のニューラルネットワーク"], ["PCA（Principal Component Analysis）", "直訳は「主成分分析」。主成分＝データが一番散らばる方向。データが一番散らばる方向を見つけて次元を減らす手法"], ["SVM（Support Vector Machine）", "support vector＝境界を支える点。境界のすぐそばの点だけが境界を決める。境界と点の余白（マージン）を最大にして分類する手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q29' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["CRISP-DM（Cross-Industry Standard Process for Data Mining）", "直訳は「業界を横断するデータマイニングの標準手順」。データ分析プロジェクトを6段階で進める代表的な標準プロセス"], ["PoC（Proof of Concept）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本開発の前に小さく試して実現性を確かめる工程。CRISP-DMより手前の位置づけ"], ["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。機械学習モデルを作って終わりにせず、運用し続けるための仕組み"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q37' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["混同行列", "正解と予測を陽性/陰性で掛け合わせた4マスの表。当たり外れの内訳を示す"], ["適合率・再現率", "混同行列の4マスの数から計算する評価指標"], ["ROC（Receiver Operating Characteristic）", "直訳は「受信者動作特性」。由来はレーダー受信兵の腕前評価。判定ラインを動かしながら見逃しと空振りのバランスを描いた曲線"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["Cyc（サイク）プロジェクト", "1984年開始。人間の一般常識を膨大なルールとして記述しようとした長期プロジェクト"], ["知識獲得のボトルネック", "知識を人手でルールにする作業が重すぎて詰まる、という第2次ブームの壁"], ["GPT（Generative Pre-trained Transformer）", "直訳は「生成（generate）のために事前学習（pre-train）したTransformer」。前から次の語を予測して文章を生成する言語モデル"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q9' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["AlphaGo", "2016年に囲碁のトップ棋士に勝ったAI。深層学習とモンテカルロ木探索を組み合わせた"], ["モンテカルロ木探索", "ランダムな試行を重ねて手の勝率を見積もる探索。AlphaGoの中核の一つ"], ["BERT（Bidirectional Encoder Representations from Transformers）", "直訳は「Transformerによる双方向（bidirectional）の符号化表現」。文の前後両方を見て意味を理解する言語モデル"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q10' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["多層パーセプトロン", "入力層と出力層の間に隠れ層を持つニューラルネット。XORなど複雑な問題も解ける"], ["単純パーセプトロン", "隠れ層のない最も単純なモデル。直線でしか分けられずXORは解けない"], ["XOR（eXclusive OR）", "直訳は「排他的な『または』」。どちらか片方だけのとき真。単純パーセプトロンでは解けない代表例として有名"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q18' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["変分オートエンコーダ（VAE）", "variational＝変分。圧縮した特徴を1点でなく「ゆらぎ付き」で持つ。特徴を確率分布として捉え、そこから新しいデータも生成できるオートエンコーダの発展形"], ["オートエンコーダ", "入力を圧縮し復元するよう学ぶネットワーク。VAEはその生成向けの発展形"], ["GAN（Generative Adversarial Network）", "adversarial＝敵対的。作る側と見破る側を競わせて鍛える。本物そっくりの画像などを作れる代表的な生成モデル"], ["word2vec（word to vector）", "直訳は「単語をベクトル（数の並び）へ」。単語を意味の近さが距離に表れる数の並びに変換する手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q24' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["ハルシネーション", "生成AIが事実に反する内容を、もっともらしく出力してしまう現象"], ["RAG（Retrieval-Augmented Generation＝検索拡張生成）", "直訳は「検索（retrieval）で補強した生成」。外部の正しい情報を参照させて答えさせ、ハルシネーションを減らす工夫"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q47' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["MYCIN", "患者の症状から感染症を診断し治療を提案した、代表的なエキスパートシステム"], ["エキスパートシステム", "専門家の知識をルールとして詰め込み、判断をまねる仕組み"], ["word2vec（word to vector）", "直訳は「単語をベクトル（数の並び）へ」。単語を意味の近さが距離に表れる数の並びに変換する手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q5' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["第五世代コンピュータ", "1980年代に日本が推進した、論理推論を高速に行うコンピュータの国家開発計画"], ["第2次AIブーム", "知識をルール化するエキスパートシステムが盛んだった時期。この計画もその流れにある"], ["GPU（Graphics Processing Unit）", "直訳は「画像処理装置」。単純な計算を大人数で一斉にやるのが得意。ディープラーニングの学習を桁違いに速くした立役者"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q8' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["シグモイド関数", "1つの値を0〜1に押し込む関数。二値分類の確率出力に使う。深い層では勾配が消えやすい"], ["ソフトマックス関数", "複数の出力を合計1の確率に変える関数。3つ以上のクラス(多クラス)の出力に使う"], ["ReLU（Rectified Linear Unit）", "rectify＝整流する。マイナスを0に切りそろえ、プラスはそのまま通す。勾配消失を起こしにくく、深いネットワークで標準の活性化関数"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q18' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["CNN（Convolutional Neural Network＝畳み込みニューラルネットワーク）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。畳み込み層・プーリング層で特徴を抽出し、全結合層で分類する、画像認識向けのネットワーク"], ["畳み込み層／プーリング層", "特徴を拾う層と、縮めて位置ずれに強くする層"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q29' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["OCR（Optical Character Recognition＝光学的文字認識）", "直訳は「光学的な文字認識」。画像中の文字を読み取り、編集できるテキストデータに変換する技術"], ["音声認識", "音声を文字にする別のタスク。OCRは画像から文字を読み取る"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q35' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["平均二乗誤差（MSE）", "直訳は「誤差を2乗した平均」。予測と正解の差を二乗して平均した、回帰の誤差指標。小さいほど良い"], ["決定係数（R²）", "回帰モデルがデータの動きをどれだけ説明できるかを表す指標。1に近いほど良い"], ["AUC（Area Under the Curve）", "直訳は「曲線の下の面積」。ROC曲線の下の面積が広いほど良い判別。ROC曲線の下の面積。1に近いほど見分けが上手"], ["ROC（Receiver Operating Characteristic）", "直訳は「受信者動作特性」。由来はレーダー受信兵の腕前評価。判定ラインを動かしながら見逃しと空振りのバランスを描いた曲線"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q40' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["GPU（Graphics Processing Unit）", "直訳は「画像処理装置」。単純な計算を大人数で一斉にやるのが得意。単純な計算を大量に同時並行でこなす演算装置。ディープラーニングの学習を高速化した"], ["CPU（Central Processing Unit）", "直訳は「中央処理装置」。少数精鋭で順番に処理するのが得意。複雑な処理を順にこなす汎用の演算装置。並列の単純計算はGPUが得意"], ["SSD（Solid State Drive）", "直訳は「固体状態のドライブ」＝記憶装置。データを保存するだけで、計算はしない。演算装置のGPUとは役割が別"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q8' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["AlexNet（作者 Alex Krizhevsky の名前から）", "2012年の画像認識コンテストで圧勝し、第3次AIブームの起点となったCNN"], ["ILSVRC（ImageNet Large Scale Visual Recognition Challenge）", "直訳は「ImageNet大規模画像認識チャレンジ」。大規模画像認識の競技会。AlexNetが従来手法に大差をつけた"], ["ResNet（Residual Network）", "residual＝残差。学ぶのを「差分だけ」にして深い層を可能にした。スキップ結合で超深層を学習可能にしたネットワーク"], ["LeNet（作者 Yann LeCun の名前から）", "手書き数字認識のために作られた初期のCNN"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q10' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["サポートベクターマシン(SVM（Support Vector Machine）)", "support vector＝境界を支える点。境界のすぐそばの点だけが境界を決める。最も近い点との距離が最大になるように境界を引く分類手法"], ["マージン", "境界と、それに最も近いデータ点との距離。これを最大化する"], ["サポートベクター", "境界に最も近く、境界の位置を決めている数点"], ["k-NN（k-Nearest Neighbors）", "直訳は「k個の最も近いご近所」。近くのk個の多数決で決める。学習らしい学習をせず、覚えたデータとの近さだけで判断する分類手法"], ["PCA（Principal Component Analysis）", "直訳は「主成分分析」。主成分＝データが一番散らばる方向。データが一番散らばる方向を見つけて次元を減らす手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q12' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["畳み込み層", "フィルタを画像全体でずらし、局所的な特徴を捉える層"], ["フィルタ", "特徴（線・角など）を検出する小さな重みの窓"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。画像認識で標準のニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q24' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["プーリング層", "小領域を代表値でまとめ、特徴マップを縮小する層"], ["最大値プーリング", "小領域の最大値だけを残す代表的なプーリング"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。画像認識で標準のニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q25' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。ゲートと記憶セルで長い系列の依存を保てるようにしたRNN"], ["ゲート", "何を覚え・忘れ・出すかを調整する仕組み"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。文章や音声など、順番が意味を持つデータ向きのネットワーク"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。画像認識で標準のニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q26' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["Transformer", "自己注意を用い、系列全体を並列処理する言語モデルの基盤"], ["自己注意", "系列内の要素どうしの関係を測る仕組み。Transformerの中核"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。文章や音声など、順番が意味を持つデータ向きのネットワーク"], ["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。ゲートと記憶セルで長い系列の依存を保てるようにしたRNN"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q28' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["BERT（Bidirectional Encoder Representations from Transformers）", "直訳は「Transformerによる双方向（bidirectional）の符号化表現」。文の前後両方を見て意味を理解する双方向の言語モデル"], ["GPT（Generative Pre-trained Transformer）", "直訳は「生成（generate）のために事前学習（pre-train）したTransformer」。前から次の語を予測して文章を生成する言語モデル"], ["ResNet（Residual Network）", "residual＝残差。学ぶのを「差分だけ」にして深い層を可能にした。スキップ結合で超深層を学習可能にしたネットワーク"], ["word2vec（word to vector）", "直訳は「単語をベクトル（数の並び）へ」。単語を意味の近さが距離に表れる数の並びに変換する手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q32' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["PoC（Proof of Concept＝概念実証）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本格開発の前に小規模に実現性・効果を検証する工程"], ["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。開発から運用・監視・再学習まで継続的に回す実践"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q37' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。開発・デプロイ・監視・再学習を継続的に回し、開発と運用を連携させる実践"], ["コンセプトドリフト", "運用中に傾向が変わり、モデルの精度が徐々に落ちる現象"], ["PoC（Proof of Concept）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。AIプロジェクトで本格開発の前に挟む小さな実験段階"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q39' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["F値", "適合率と再現率の調和平均。両者のバランスを1数値で表す"], ["正解率", "全体の当たり具合。データが偏ると当てにならない"], ["AUC（Area Under the Curve）", "直訳は「曲線の下の面積」。ROC曲線の下の面積が広いほど良い判別。ROC曲線の下の面積。1に近いほど見分けが上手"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["探索的段階型の開発契約", "AIの不確実性をふまえ、段階に分けて進める契約の考え方"], ["一括請負契約", "成果物の完成を固く約束する契約"], ["PoC（Proof of Concept）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。AIプロジェクトで本格開発の前に挟む小さな実験段階"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q46' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["XAI（Explainable AI）", "直訳は「説明可能なAI」。AIの判断根拠を人が理解できる形で示す取り組み"], ["LIME（Local Interpretable Model-agnostic Explanations）/SHAP（SHapley Additive exPlanations）", "ゲーム理論のShapley値（貢献度の公平な山分け）で各項目の貢献を測る。直訳は「局所的で・解釈可能な・モデルを問わない説明」。どの特徴が判断にどれだけ効いたかを説明する代表的手法"], ["BERT（Bidirectional Encoder Representations from Transformers）", "直訳は「Transformerによる双方向（bidirectional）の符号化表現」。文の前後両方を見て意味を理解する言語モデル"], ["GPT（Generative Pre-trained Transformer）", "直訳は「生成（generate）のために事前学習（pre-train）したTransformer」。前から次の語を予測して文章を生成する言語モデル"], ["ResNet（Residual Network）", "residual＝残差。学ぶのを「差分だけ」にして深い層を可能にした。スキップ結合で超深層を学習可能にしたネットワーク"], ["SGD（Stochastic Gradient Descent）", "stochastic＝確率的。ランダムに選んだ一部のデータだけで坂を下る。全データを毎回使うより速く、大規模データ学習の基本"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q48' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

COMMIT;
