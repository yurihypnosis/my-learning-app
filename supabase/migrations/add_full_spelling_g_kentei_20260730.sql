BEGIN;

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["教師なし学習", "正解ラベルを使わず、データ自体のまとまりや特徴を見つける学び方"], ["教師あり学習", "入力と正解のセットを見せて、分類や数値予測を覚えさせる学び方"], ["PCA（Principal Component Analysis）", "直訳は「主成分分析」。主成分＝データが一番散らばる方向。データが一番散らばる方向を見つけて次元を減らす手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-q11' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["k-means法", "データをk個のグループに分ける（正解ラベル不要の教師なし）"], ["k近傍法（k-NN）", "直訳は「k個の最も近いご近所」。近くのk個の多数決で決める。近くにあるk個の“正解つき”データの多数決で当てる（教師あり）"]]'::jsonb)
WHERE source_ref = 'g-kentei-q13' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["主成分分析（PCA）", "直訳は「主成分分析」。主成分＝データが一番散らばる方向。データのばらつきをできるだけ保ちながら、たくさんの項目を少ない軸にまとめて減らす手法"], ["次元の呪い", "項目が多すぎるとデータがスカスカになり学習が難しくなる現象。PCAはこれを和らげる"]]'::jsonb)
WHERE source_ref = 'g-kentei-q14' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["勾配消失問題", "学習の信号（勾配）が層をさかのぼるほど小さくなり、手前の層がなかなか更新されない問題"], ["ReLU（Rectified Linear Unit）", "rectify＝整流する。マイナスを0に切りそろえ、プラスはそのまま通す。勾配消失を和らげるために広く使われる活性化関数"]]'::jsonb)
WHERE source_ref = 'g-kentei-q18' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["モメンタム", "前に進んだ勢いを引き継いで、ムダな揺れを抑えつつ速く進む工夫"], ["RMSProp（Root Mean Square Propagation）", "直訳は「2乗平均平方根の伝播」。最近の勾配の大きさに合わせて歩幅を自動調整。方向ごとに歩幅（学習率）を自動で調整する工夫"], ["Adam（Adaptive Moment Estimation）", "直訳は「適応的な・勢い（moment）の・推定」。モメンタムとRMSPropの合わせ技。勢いと歩幅の自動調整を組み合わせた定番の最適化手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-q20' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["畳み込み層", "小さなフィルタを画像全体で使い回し、場所によらず線や角などの局所的な特徴を拾う層"], ["重み共有", "同じフィルタを全体で使い回すことで、覚える数（パラメータ）を少なく抑える仕組み"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。畳み込みで画像の特徴を拾うニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q24' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["最大値プーリング", "小さな領域の中の一番大きい値で代表させ、特徴マップを縮めつつ位置ズレに強くする操作"], ["位置ズレへの強さ", "入力が少しズレても、出力があまり変わらない性質"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。畳み込みで画像の特徴を拾うニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q25' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。覚える/忘れる/出すの門と記憶用の入れ物で、長い系列でも情報を保てるようにしたRNNの改良版"], ["GRU（Gated Recurrent Unit）", "直訳は「ゲート付きの再帰ユニット」。LSTMを簡単にして、少ない門で似た効果をねらった手法"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。順番のあるデータを前から一つずつ読むニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q26' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["Transformer", "注意の仕組みだけで文を処理し、まとめて計算できて長い関係も扱えるつくり"], ["位置エンコーディング", "一度に処理すると失われる語順を補うため、位置の情報を加える工夫"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。順番のあるデータを前から一つずつ読むニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-q28' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["オートエンコーダ", "入力を小さくまとめ、そこから元に戻すよう学んで、データの特徴をつかむネットワーク"], ["VAE（Variational Autoencoder）", "variational＝変分。圧縮した特徴を1点でなく「ゆらぎ付き」で持つ。中身を確率の形で扱い、新しいデータ生成にも使えるようにした発展版"]]'::jsonb)
WHERE source_ref = 'g-kentei-q29' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["BERT（Bidirectional Encoder Representations from Transformers）", "直訳は「Transformerによる双方向（bidirectional）の符号化表現」。前と後ろの両方を同時に見る。文の意味を理解するタスクに強い"], ["GPT（Generative Pre-trained Transformer）", "直訳は「生成（generate）のために事前学習（pre-train）したTransformer」。前の言葉から次の言葉を予想していく。文を作る（生成）のに強い"]]'::jsonb)
WHERE source_ref = 'g-kentei-q32' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["word2vec（word to vector）", "直訳は「単語をベクトル（数の並び）へ」。周りにどんな語が来るかから単語を数値の並びにして、意味の近さを距離で表す手法"], ["one-hotベクトル", "1語につき1か所だけ1にする表し方。意味の近さは表せない"]]'::jsonb)
WHERE source_ref = 'g-kentei-q33' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["GAN（Generative Adversarial Network）", "adversarial＝敵対的。作る側と見破る側を競わせて鍛える。作る側（生成器）と見破る側（識別器）を競わせ、本物そっくりのデータを作らせるモデル"], ["識別器", "入力が本物か偽物かを見分ける役。作る側と競い合う"]]'::jsonb)
WHERE source_ref = 'g-kentei-q34' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["PoC（Proof of Concept）（概念実証）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本格開発の前に、小さく試して実現できるか・効果があるかを確かめる工程"], ["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。作ったモデルを運用しながら、監視や作り直しを継続的に回す実践"]]'::jsonb)
WHERE source_ref = 'g-kentei-q37' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。開発と運用をつなぎ、公開・監視・再学習を継続的に回す実践や仕組み"], ["PoC（Proof of Concept）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本開発の前に小さく試す工程。MLOpsより手前の段階"]]'::jsonb)
WHERE source_ref = 'g-kentei-q39' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["ROC（Receiver Operating Characteristic）曲線", "直訳は「受信者動作特性」。由来はレーダー受信兵の腕前評価。判定のさじ加減を動かしたときの、空振り率と当たり率の関係を描いた曲線"], ["AUC（Area Under the Curve）", "直訳は「曲線の下の面積」。ROC曲線の下の面積が広いほど良い判別。ROC曲線の下側の面積。1に近いほど分類の総合力が高い"]]'::jsonb)
WHERE source_ref = 'g-kentei-q43' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["XAI（Explainable AI）（説明可能なAI）", "直訳は「説明可能なAI」。AIの判断理由を、人に分かる形で示そうとする取り組み"], ["SHAP（SHapley Additive exPlanations）", "ゲーム理論のShapley値（貢献度の公平な山分け）で各項目の貢献を測る。どの特徴が予測にどれだけ効いたかを計算して説明する、代表的な手法"], ["LIME（Local Interpretable Model-agnostic Explanations）", "直訳は「局所的で・解釈可能な・モデルを問わない説明」。1件の予測の近くだけ単純なモデルで真似て理由を示す説明手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-q48' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["サポートベクターマシン(SVM（Support Vector Machine）)", "support vector＝境界を支える点。境界のすぐそばの点だけが境界を決める。2グループを分ける境界を、最も近い点との距離が最大になるように引く分類手法"], ["マージン", "境界と、それに最も近いデータ点との距離。これを最大化する"], ["サポートベクター", "境界に最も近く、境界の位置を決めている数点。残りの点は境界を動かさない"], ["カーネル法", "そのままでは直線で分けられないデータを、高次元に写して分けやすくするSVMの拡張"]]'::jsonb)
WHERE source_ref = 'g-kentei-q51' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["AlexNet（作者 Alex Krizhevsky の名前から）", "2012年のILSVRC(画像認識コンテスト)でディープラーニングを使い圧勝したモデル。第3次ブームの契機"], ["ILSVRC（ImageNet Large Scale Visual Recognition Challenge）", "直訳は「ImageNet大規模画像認識チャレンジ」。大量の画像を何のクラスか当てさせる、画像認識の有名なコンテスト"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q10' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["サポートベクターマシン（SVM）", "support vector＝境界を支える点。境界のすぐそばの点だけが境界を決める。境界と最も近いデータとの余白(マージン)が最大になるよう分ける分類手法"], ["マージン", "境界と、一番近いデータとの間の余白。これを最大にするのがSVMの狙い"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q14' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["ReLU（Rectified Linear Unit）", "rectify＝整流する。マイナスを0に切りそろえ、プラスはそのまま通す。入力がマイナスなら0、プラスならそのまま通す活性化関数。勾配消失に強い"], ["シグモイド", "出力を0〜1に押し込む活性化関数。傾きが小さく深い層で勾配が消えやすい"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q18' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["確率的勾配降下法（SGD）", "stochastic＝確率的。ランダムに選んだ一部のデータだけで坂を下る。データを小分けにして、少しずつ何度も重みを更新する基本の最適化"], ["ミニバッチ", "一度の更新に使うデータの小さなかたまり"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q20' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["回帰結合層（RNN）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。前の時点の出力を次の入力に回し、順番のあるデータを順に処理する層"], ["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。RNNに記憶の門を足して、長い系列でも前の情報を保てるようにした改良版"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q24' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["残差接続（スキップ結合）", "層を飛び越えて入力を先の層へ足す近道。深いネットワークの学習を可能にした"], ["ResNet（Residual Network）", "residual＝残差。学ぶのを「差分だけ」にして深い層を可能にした。残差接続を使い、100層を超える深さでも学習できるようにした画像認識モデル"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q25' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["GRU（Gated Recurrent Unit）", "直訳は「ゲート付きの再帰ユニット」。LSTMより門(ゲート)を減らして簡単にした、系列を扱う手法。計算が軽い"], ["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。門と記憶で長い系列の情報を保つ、RNNの改良版"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q29' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["マルチモーダル", "画像・文章・音声など、種類の違う情報を組み合わせて扱うこと"], ["CLIP（Contrastive Language-Image Pre-training）", "直訳は「言語と画像を対比（contrast）させる事前学習」。画像と説明文を結びつけて学習した代表的なマルチモーダルモデル"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q34' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["CRISP-DM（Cross-Industry Standard Process for Data Mining）", "直訳は「業界を横断するデータマイニングの標準手順」。データ分析プロジェクトを6段階で進める代表的な標準プロセス"], ["PoC（Proof of Concept）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本開発の前に小さく試して実現性を確かめる工程。CRISP-DMより手前の位置づけ"]]'::jsonb)
WHERE source_ref = 'g-kentei-b-q37' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["t-SNE（t-distributed Stochastic Neighbor Embedding）", "直訳は「t分布を使った、確率的なご近所関係の埋め込み」。高次元データを、点どうしの近さを保ちつつ2次元などに落として可視化する手法"], ["次元削減", "項目(次元)を減らす手法の総称。t-SNEは可視化に特化した一種"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q14' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["多層パーセプトロン", "入力層と出力層の間に隠れ層を持つニューラルネット。XORなど複雑な問題も解ける"], ["単純パーセプトロン", "隠れ層のない最も単純なモデル。直線でしか分けられずXORは解けない"], ["XOR（eXclusive OR）", "直訳は「排他的な『または』」。どちらか片方だけのとき真。2つの入力のどちらか片方だけが1のとき1を返す論理演算"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q18' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["モメンタム", "前回までの更新方向の勢いを引き継ぎ、揺れを抑えて収束を速める最適化の工夫"], ["Adam（Adaptive Moment Estimation）", "直訳は「適応的な・勢い（moment）の・推定」。モメンタムとRMSPropの合わせ技。モメンタムと、方向ごとの歩幅調整(RMSProp)を組み合わせた最適化"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q20' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["変分オートエンコーダ（VAE）", "variational＝変分。圧縮した特徴を1点でなく「ゆらぎ付き」で持つ。特徴を確率分布として捉え、そこから新しいデータも生成できるオートエンコーダの発展形"], ["オートエンコーダ", "入力を圧縮し復元するよう学ぶネットワーク。VAEはその生成向けの発展形"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q24' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["双方向RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。系列を前からと後ろからの両方向で読み、前後の文脈を使えるようにしたRNN"], ["単方向RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。前から一方向にしか読まない通常のRNN。後ろの文脈は使えない"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q28' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["RLHF（Reinforcement Learning from Human Feedback）", "直訳は「人間の感想（feedback）から学ぶ強化学習」。人間のフィードバック(好みの評価)を報酬にして、生成AIを人の好みに沿うよう調整する手法"], ["強化学習", "報酬を手がかりに試行錯誤で行動を学ぶ方法。RLHFの土台"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q36' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["ハルシネーション", "生成AIが事実に反する内容を、もっともらしく出力してしまう現象"], ["RAG（Retrieval-Augmented Generation）（検索拡張生成）", "直訳は「検索（retrieval）で補強した生成」。外部の正しい情報を参照させて答えさせ、ハルシネーションを減らす工夫"]]'::jsonb)
WHERE source_ref = 'g-kentei-c-q47' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["汎用人工知能（AGI）", "直訳は「人工的な・汎用の・知能」。特定の作業に限らず、人間のように幅広い課題に対応できるとされるAI。まだ実現していない"], ["特化型AI", "特定の作業だけに特化したAI。現状のAIの大半がこれ"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q1' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["k近傍法（k-NN）", "直訳は「k個の最も近いご近所」。近くのk個の多数決で決める。予測時に近くのk個の学習データの多数決で分類する手法。怠惰学習とも呼ばれる"], ["怠惰学習", "学習時にはモデルを作らず、予測時に計算する方式。k-NNが代表"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q12' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["RMSProp（Root Mean Square Propagation）", "直訳は「2乗平均平方根の伝播」。最近の勾配の大きさに合わせて歩幅を自動調整。勾配の大きさに応じて、方向ごとに学習率(歩幅)を自動調整する最適化の工夫"], ["Adam（Adaptive Moment Estimation）", "直訳は「適応的な・勢い（moment）の・推定」。モメンタムとRMSPropの合わせ技。モメンタム(勢い)とRMSProp(歩幅調整)を組み合わせた最適化"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q22' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["勾配降下法", "誤差が小さくなる方向へ重みを少しずつ動かし、誤差を減らす最適化の基本"], ["確率的勾配降下法（SGD）", "stochastic＝確率的。ランダムに選んだ一部のデータだけで坂を下る。データを小分けにして勾配降下を行う、実用的な発展形"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q23' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["CNN（Convolutional Neural Network）（畳み込みニューラルネットワーク）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。畳み込み層・プーリング層で特徴を抽出し、全結合層で分類する、画像認識向けのネットワーク"], ["畳み込み層／プーリング層", "特徴を拾う層と、縮めて位置ずれに強くする層"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q29' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["OCR（Optical Character Recognition）（光学的文字認識）", "直訳は「光学的な文字認識」。画像中の文字を読み取り、編集できるテキストデータに変換する技術"], ["音声認識", "音声を文字にする別のタスク。OCRは画像から文字を読み取る"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q35' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["特化型AI", "決められた一つの作業に特化して力を発揮するAI。現状の大半がこれ"], ["汎用人工知能（AGI）", "直訳は「人工的な・汎用の・知能」。幅広い課題に柔軟に対応できるとされるAI。まだ実現していない"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q4' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["平均二乗誤差（MSE）", "直訳は「誤差を2乗した平均」。予測と正解の差を二乗して平均した、回帰の誤差指標。小さいほど良い"], ["決定係数（R²）", "回帰モデルがデータの動きをどれだけ説明できるかを表す指標。1に近いほど良い"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q40' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["決定係数（R²）", "回帰モデルがデータの動き(ばらつき)をどれだけ説明できるかを表す指標。1に近いほど良い"], ["平均二乗誤差（MSE）", "直訳は「誤差を2乗した平均」。予測と正解の差を二乗して平均した誤差。小さいほど良い"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q41' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["探索的段階型の開発方式", "AI開発を、アセスメント・PoC・開発・追加学習などの段階に分けて契約を進める考え方"], ["PoC（Proof of Concept）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本開発の前に小さく試して実現性を確かめる工程。この段階の一つ"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q46' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["透明性", "AIの作られ方や判断の仕組みを開示し、利用者や社会が検証できるようにする考え方"], ["説明可能なAI（XAI）", "直訳は「説明可能なAI」。判断根拠を人に分かる形で示す技術。透明性を支える"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q47' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["GPU（Graphics Processing Unit）", "直訳は「画像処理装置」。単純な計算を大人数で一斉にやるのが得意。単純な計算を大量に同時並行でこなす演算装置。ディープラーニングの学習を高速化した"], ["CPU（Central Processing Unit）", "直訳は「中央処理装置」。少数精鋭で順番に処理するのが得意。複雑な処理を順にこなす汎用の演算装置。並列の単純計算はGPUが得意"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q8' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["ビッグデータ", "量・種類・発生速度の大きい、大量で多様なデータ。ディープラーニング普及の一因"], ["GPU（Graphics Processing Unit）", "直訳は「画像処理装置」。単純な計算を大人数で一斉にやるのが得意。大量の計算を並列でこなす装置。ビッグデータと並ぶDL普及の立役者"]]'::jsonb)
WHERE source_ref = 'g-kentei-d-q9' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["特化型AI", "一つの決まった作業に特化して力を発揮するAI。現状の大半"], ["汎用人工知能(AGI（Artificial General Intelligence）)", "直訳は「人工的な・汎用の・知能」。人間のように幅広い課題に柔軟に対応できる、まだ実現していないAI"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q1' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["AlexNet（作者 Alex Krizhevsky の名前から）", "2012年の画像認識コンテストで圧勝し、第3次AIブームの起点となったCNN"], ["ILSVRC（ImageNet Large Scale Visual Recognition Challenge）", "直訳は「ImageNet大規模画像認識チャレンジ」。大規模画像認識の競技会。AlexNetが従来手法に大差をつけた"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q10' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["サポートベクターマシン(SVM（Support Vector Machine）)", "support vector＝境界を支える点。境界のすぐそばの点だけが境界を決める。最も近い点との距離が最大になるように境界を引く分類手法"], ["マージン", "境界と、それに最も近いデータ点との距離。これを最大化する"], ["サポートベクター", "境界に最も近く、境界の位置を決めている数点"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q12' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["主成分分析(PCA（Principal Component Analysis）)", "直訳は「主成分分析」。主成分＝データが一番散らばる方向。分散をできるだけ保ちつつ次元を減らす手法"], ["次元削減", "項目（次元）の数を減らして扱いやすくすること"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q14' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["勾配消失", "勾配（学習の信号）が層を伝わるうちに小さくなり、手前の層が学べなくなる問題"], ["ReLU（Rectified Linear Unit）", "rectify＝整流する。マイナスを0に切りそろえ、プラスはそのまま通す。プラスはそのまま通し、勾配が消えにくい活性化関数"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q19' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["Adam（Adaptive Moment Estimation）", "直訳は「適応的な・勢い（moment）の・推定」。モメンタムとRMSPropの合わせ技。モメンタムとRMSPropの利点を組み合わせた最適化手法"], ["モメンタム", "過去の進行方向を引き継ぎ、揺れを抑えて速く進む工夫"], ["RMSProp（Root Mean Square Propagation）", "直訳は「2乗平均平方根の伝播」。最近の勾配の大きさに合わせて歩幅を自動調整。最近の勾配の大きさに合わせて学習の歩幅を自動調整する最適化手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q21' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["畳み込み層", "フィルタを画像全体でずらし、局所的な特徴を捉える層"], ["フィルタ", "特徴（線・角など）を検出する小さな重みの窓"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。畳み込みで画像の特徴を拾うニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q24' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["プーリング層", "小領域を代表値でまとめ、特徴マップを縮小する層"], ["最大値プーリング", "小領域の最大値だけを残す代表的なプーリング"], ["CNN（Convolutional Neural Network）", "convolution＝畳み込み。小さな窓を画像の上でスライドさせて特徴を拾う。畳み込みで画像の特徴を拾うニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q25' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["LSTM（Long Short-Term Memory）", "直訳は「長い・短い期間の記憶」。ゲートと記憶セルで長い系列の依存を保てるようにしたRNN"], ["ゲート", "何を覚え・忘れ・出すかを調整する仕組み"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。順番のあるデータを前から一つずつ読むニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q26' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["Transformer", "自己注意を用い、系列全体を並列処理する言語モデルの基盤"], ["自己注意", "系列内の要素どうしの関係を測る仕組み。Transformerの中核"], ["RNN（Recurrent Neural Network）", "recurrent＝繰り返し戻ってくる。前の結果を次の入力に戻しながら読む。順番のあるデータを前から一つずつ読むニューラルネットワーク"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q28' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["オートエンコーダ", "入力を圧縮し、そこから元に戻すよう学んで特徴を捉えるネットワーク"], ["VAE（Variational Autoencoder）", "variational＝変分。圧縮した特徴を1点でなく「ゆらぎ付き」で持つ。中身を確率分布として扱い、生成にも使えるようにした発展版"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q29' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["BERT（Bidirectional Encoder Representations from Transformers）", "直訳は「Transformerによる双方向（bidirectional）の符号化表現」。文の前後両方を見て意味を理解する双方向の言語モデル"], ["GPT（Generative Pre-trained Transformer）", "直訳は「生成（generate）のために事前学習（pre-train）したTransformer」。前から次の語を予測して文章を生成する言語モデル"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q32' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["word2vec（word to vector）", "直訳は「単語をベクトル（数の並び）へ」。意味の近さが距離に表れる、単語の分散表現を学ぶ代表的手法"], ["分散表現", "単語を密なベクトルで表し、意味の近さを距離で扱えるようにしたもの"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q33' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["敵対的生成ネットワーク(GAN（Generative Adversarial Network）)", "adversarial＝敵対的。作る側と見破る側を競わせて鍛える。生成器と識別器を競わせ、本物そっくりのデータを作らせるモデル"], ["識別器", "入力が本物か偽物かを見分ける役。生成器と競う"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q34' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["PoC（Proof of Concept）（概念実証）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本格開発の前に小規模に実現性・効果を検証する工程"], ["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。開発から運用・監視・再学習まで継続的に回す実践"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q37' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["MLOps（Machine Learning Operations）", "直訳は「機械学習の運用」。開発（Dev）と運用（Ops）をつなぐDevOpsの機械学習版。開発・デプロイ・監視・再学習を継続的に回し、開発と運用を連携させる実践"], ["コンセプトドリフト", "運用中に傾向が変わり、モデルの精度が徐々に落ちる現象"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q39' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["探索的段階型の開発契約", "AIの不確実性をふまえ、段階に分けて進める契約の考え方"], ["一括請負契約", "成果物の完成を固く約束する契約"], ["PoC（Proof of Concept）", "直訳は「概念の証明」。アイデアが本当に成り立つか小さく試す。本格開発の前に、アイデアが成り立つか小さく試す検証"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q46' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

UPDATE public.questions SET explanation_data = explanation_data || jsonb_build_object('terms', '[["XAI（Explainable AI）", "直訳は「説明可能なAI」。AIの判断根拠を人が理解できる形で示す取り組み"], ["LIME（Local Interpretable Model-agnostic Explanations）/SHAP（SHapley Additive exPlanations）", "ゲーム理論のShapley値（貢献度の公平な山分け）で各項目の貢献を測る。直訳は「局所的で・解釈可能な・モデルを問わない説明」。どの特徴が判断にどれだけ効いたかを説明する代表的手法"]]'::jsonb)
WHERE source_ref = 'g-kentei-e-q48' AND subject_id IN (SELECT id FROM public.subjects WHERE slug LIKE 'g-kentei%');

COMMIT;
