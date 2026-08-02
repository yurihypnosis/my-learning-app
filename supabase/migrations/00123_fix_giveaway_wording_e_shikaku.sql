-- =============================================================
-- 00123_fix_giveaway_wording_e_shikaku.sql
-- E資格 Set A/B: 選択肢が自分の誤りを自白する表現(てしまっている・にすぎない・
-- あえて・わざわざ・無理やり・都合よく等)を除去し、中立的な言い回しに書き換え。
-- 長さバランス(正解が単独最長にならない)は維持したまま修正。
-- =============================================================

BEGIN;

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"低次元に写した後、すべての点が完全に1本の一直線上に並ぶ配置へと固定され、クラスタ同士の区別がまったくつかなくなるという、これもまた別種の可視化上の問題である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q11';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"PCAと組み合わせて使うと、必ず計算がエラーで停止するという実装上の制約。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q11';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"ホールドアウト法はデータをk個に分割して複数回検証を繰り返す方式であり、k分割交差検証法はデータを1回だけ分割してそのまま1回きりの検証で結果を確定させる、より手軽な方式である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q13';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"tanhの出力範囲は0〜1で常に正の値を取る関数であり、シグモイドの出力範囲は-1〜1で0を中心にした関数である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q16';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"入力画像をすべて0の値で最初から丸ごと埋め尽くしたうえで、その状態のまま畳み込み演算を省略してそのまま次の層に渡していく処理である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q19';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"入力画像の画素をランダムにシャッフルし直し、位置の情報を完全に入れ替える処理である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q19';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"入力画像を1ピクセルだけ残してすべて削除し、極端に軽量化する処理である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q19';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"1/8。表が2回連続で出る1通りの並びの確率だけを求めた値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q2';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"1/2。1回の試行で表が出る確率pの値を、そのまま3回中2回表が出る確率として扱った値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q2';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"2/3。表が出る回数2を試行回数3で割った割合を、そのまま確率として扱った値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q2';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"6×6。カーネルサイズ3を2層分そのまま足し合わせた値を、受容野のサイズとして使う計算方法である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q20';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"depth-wise畳み込みでチャネル同士の情報を混ぜ合わせる処理を行い、point-wise畳み込みのほうで空間方向の特徴をあらためて抽出する、通常の畳み込みとは役割がちょうど逆になった設計である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q21';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"depth-wise畳み込みとpoint-wise畳み込みを組み合わせると、通常の畳み込みよりも必ず計算量が増える設計になっている。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q21';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"入力系列と出力系列の両方をまとめて1つの同じRNNだけを使いながら、エンコーダ・デコーダという役割の区別を一切設けないまま処理していく構成である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q23';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"計算を複数のヘッドに分けることで、Attentionの計算そのものを丸ごと省略できるようにする、計算コスト削減のための工夫である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q25';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"あらかじめ用意しておいた候補枠(Anchor box)の種類や数をさらに大幅に増やしたうえで、より多くの候補の中から時間をかけてじっくりと選べるようにする方式である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q27';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"候補領域の特徴マップを固定サイズに切り出すROI Poolingを、複数の解像度で組み合わせて使う方式。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q27';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"未来の時刻の情報も含めて先取りしてかなり自由に使いながら、畳み込みのマス目の間隔を層を重ねるごとにどんどん狭めていくことで、直前のごく短い範囲の情報だけに絞り込んで参照するようにする仕組みである。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q29';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"すべての時刻の情報を平等に1つの値に平均する処理を行い、時系列の順序に関する情報を完全に無視する。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q29';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"2つのネットワーク(生成器と識別器)を互いに競わせながら段階的に学習を進めていく、GANとほとんど基本的にまったく完全に同じ仕組みだけを土台にして作られたモデルである。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q30';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"行動を選ぶ役割と評価する役割の両方をひとまとめにして1つの同じネットワークにきっちり統合し、常に全く同じたった1つの出力を両方の目的にそのままずっと使い回していく構成である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q32';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"過学習。訓練データを細部まで記憶し、新しいデータへの性能が落ちる現象を指す言葉。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q33';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"モード崩壊。GANの生成結果の多様性が失われる現象を指す言葉。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q33';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"ラベルなしデータの中から、モデルが最も自信を持って正確に答えられる簡単で判断しやすいデータのほうを優先的にどんどん選び出して、あらためてラベル付けの依頼をしていく。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q35';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"複雑なモデルの内部の重みを直接すべて書き換え、単純な線形モデルそのものに置き換える手法である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q38';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"SIMDは複数のスレッドを自由に組み合わせてかなり柔軟に使う方式であり、SIMTのほうは1つのデータだけをひたすら地道に処理する、まったく逆の限定的な方式にあたる。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q40';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"SIMDとSIMTはどちらも、1つの命令で1つのデータだけを処理する、逐次処理を基本とした方式である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q40';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"エッジ推論とクラウド推論は、モデルの精度にも速度にも消費電力にも通信環境への依存度にも実質的には全くこれといった違いを生まない、実質的にはまったくもって単なる呼び方だけの違いにしかとどまらない。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q42';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"L1ノルムは5、L2ノルムは7。2乗して足してから平方根を取る計算をL1、絶対値の和をL2として使った値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q5';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"L1ノルムもL2ノルムも同じ12になる。どちらも各成分同士を単純に掛け合わせた値を使う計算方法である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q5';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"L1ノルムは25、L2ノルムは25。2乗して足した値を、平方根を取らずにそのまま両方のノルムとして使った値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q5';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"対数を取ると確率の値がちょうど0〜1の範囲にきれいに収まるように自動的にうまく変換され、そのまま正しい確率としてすぐに解釈しやすくなるから。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q6';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"行列積とアダマール積とは、同じ形の行列同士であれば呼び方が違うだけで計算の手順も結果も実際には一致する、表記上の使い分けである。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q1';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"ユークリッド距離は7、マンハッタン距離は5。差の絶対値の和をユークリッド距離、2乗和の平方根をマンハッタン距離として使った値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q10';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"ユークリッド距離もマンハッタン距離も同じ7になる。2つの距離を区別せず、同じ式で両方を求めた値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q10';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"ユークリッド距離は25、マンハッタン距離は7。2乗して足した値を、そのまま距離の値として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q10';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"バリアンスが大きく過剰適合(overfitting)になりやすい。モデルの表現力が高すぎて、訓練データに含まれる細かいノイズまで含めて学習が進む。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q12';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"0。ロジットzの値がちょうど0のとき、シグモイド関数の出力もそのまま0になるという考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q13';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"1。zが0のときシグモイドの出力がそのまま1になるという考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q13';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"無限大。z=0のとき分母が0になり、計算結果が発散するという考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q13';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"0.6。クラスAの割合をそのまま、2乗も1からの引き算も行わずにGini係数の値として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q15';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"1.0。2つのクラスが混ざっている状態を、常に最大の不純度として扱う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q15';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"12%。分散の値をそのままパーセントの数値として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q16';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"20%。合計の分散の値をそのままパーセントの数値として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q16';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"40%。第一主成分以外の分散(6+2=8)の割合を寄与率として求める考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q16';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"適合率は67%、再現率は80%。TP÷(TP+FN)を適合率、TP÷(TP+FP)を再現率として求めた値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q18';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"適合率も再現率も同じ57%になる。TPを全体(TP+FP+FN+TN)で割った正解率の考え方を両方に使った値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q18';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"適合率は40%、再現率は40%。TPの値をそのまま件数のまま両方の指標に使った値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q18';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"[1, 2]。バイアスbを足す手順を省略したうえで、Wxの値をそのまま出力とする考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q19';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"[1, 1]。入力xを使わず、バイアスbだけを出力とする考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q19';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"[2, 2]。x1の値だけを両方の出力に使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q19';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"シグモイド関数の出力が常に負の値だけを取るため、そのままでは損失関数(クロスエントロピー等)がそもそも定義できなくなるから。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q21';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"5.8。学習率×勾配を、引く代わりに足して更新する考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q22';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"13。θと勾配をそのまま足し、学習率は掛けずに更新する考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q22';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"0.8。学習率×勾配の値そのものを、更新後のθの値として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q22';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"L1/L2正則化は学習のたびごとに一部のニューロンをランダムに無効化していく方法であり、ドロップアウトは損失関数に重みの大きさに応じたペナルティ項を足す方法である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q26';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"4。ストライドで割る前の(7-3+0)=4の値を、そのまま出力サイズとして使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q28';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"2。最後の+1を行わずに求めた値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q28';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"5。パディングの値を2として計算した結果である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q28';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"Max poolingはチャネル全体の特徴マップの値をすべて平均してまとめて1つの値にまとめる演算であり、GAPは小さな窓ごとに最大値だけを残す演算である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q29';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"Self-AttentionはDecoder側のトークンがEncoder側の出力を参照して計算する仕組みであり、Source Target Attentionは同じ系列内のトークン同士だけで計算する仕組みである。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q31';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"Batch Normalizationは1つのサンプル内にある全チャネルをまたいでまとめて正規化していく手法であり、Layer Normalizationはミニバッチ内にある同じチャネルをまたいでまとめて正規化していく手法である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q32';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"Faster R-CNNは1回だけのネットワーク通過で候補領域の提案と分類を両方まとめて行う方式であり、YOLOはその候補領域の提案とクラス分類をあらためて2段階に分けて丁寧に行う方式である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q35';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"Global Average Pooling。各チャネルの特徴マップ全体を平均して1つの値に要約する演算であり、解像度をまたいだ位置情報の橋渡しには使われない。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q37';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"skip-gramは周囲にある複数の単語から中心にある単語をまとめて予測する方式であり、CBOWは中心の単語から周囲にある単語を予測する方式である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q38';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"モデルのパラメータそのものを、少数の追加データを使って改めて再学習(ファインチューニング)することを指す言葉である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q40';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"16kHz。記録したい最大周波数とちょうど同じ値を、2倍せずにそのままサンプリング周波数として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q41';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"8kHz。記録したい最大周波数を半分にした値を、サンプリング周波数として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q41';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"160kHz。記録したい最大周波数に10倍の安全率を掛けて求めた値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q41';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"通常のオートエンコーダは潜在変数を平均や分散を持つ確率分布としてそのまま学習していく手法であり、VAEのほうは入力をただの1点のベクトルへと圧縮するだけの単純な手法である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q43';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"過学習。訓練データの細部まで丸暗記した結果、新しいデータに対する性能が落ちる現象であり、多様性の欠如そのものを指す専用の語ではない。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q44';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"共変量シフト。訓練時とテスト時でデータの分布が変化する現象であり、GAN特有の多様性の問題ではない。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q44';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"報酬が得られた成功体験の経験だけをあらかじめ選んで学習に使い、報酬が0だった失敗の経験のほうはメモリーにすら一切残さず、その場ですぐさま完全に捨て去る工夫。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q45';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"プルーニングはモデルが持つパラメータのビット数を減らす手法、蒸留は重要度の低い重みを丁寧に削り落としていく手法、量子化は教師モデルから生徒モデルを学習させていく手法である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q47';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"プルーニング・蒸留・量子化はすべて同じ処理を呼び方だけ変えて呼んでいるだけであり、実装方法にも軽量化の仕組みにも違いはない。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q47';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"モデル並列化は複数のデバイスにまったく同じモデルのコピーをそれぞれ置いてデータを分担させる方式であり、データ並列化は1つの巨大なモデルを複数のデバイスに分割してそれぞれ配置する方式である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q48';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"2ビット。出目の数の値を、そのままビット数として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q7';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"0.5ビット。確率1/2の値を、そのままビット数として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q7';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', '"-log(0.2) - log(0.5) - log(0.3) の3項をすべて足した値。正解でないクラスの項もそのまま式に残した計算である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q8';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{2}', '"0.5そのもの。正解クラスの予測確率の値を、そのまま誤差として使う考え方である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q8';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{3}', '"1 - 0.5 = 0.5。正解確率との差を1から単純に引き算しただけの値である。"'::jsonb)
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q8';

COMMIT;
