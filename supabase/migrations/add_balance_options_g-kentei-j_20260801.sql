BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('g-kentei-j-q2', '["PReLU（Parametric ReLU）","ソフトプラス関数（Softplus）","ハードスウィッシュ（Hard-Swish）","マックスアウト（Maxout）"]'),
  ('g-kentei-j-q3', '["ELU（Exponential Linear Unit）","ReLU（Rectified Linear Unit）","ソフトマックス関数（Softmax Function）","シグモイド関数（Sigmoid Function）"]'),
  ('g-kentei-j-q4', '["GELU（Gaussian Error Linear Unit）","Leaky ReLU（Leaky Rectified Linear Unit）","ソフトマックス関数（Softmax Function）","恒等関数（Identity Function）"]'),
  ('g-kentei-j-q36', '["Mixture of Experts（MoE）","アンサンブル学習（Ensemble Learning）","ドロップアウト（Dropout）","バッチ正規化（Batch Normalization）"]'),
  ('g-kentei-j-q38', '["Siamese Network（シャムネットワーク）","オートエンコーダ（Autoencoder）","Highway Network（ハイウェイネットワーク）","Capsule Network（カプセルネットワーク）"]'),
  ('g-kentei-j-q41', '["文章の理解や分類にはEncoder-only、文章の生成にはDecoder-only、系列変換にはEncoder-Decoderが向いているとされる", "3つの型はすべて内部構造も得意なタスクも同じであり、Encoder-only・Decoder-only・Encoder-Decoderという名前は単なる呼び方の違いにすぎず、実質的な性能差は生まれない", "Encoder-onlyは次の単語を1つずつ予測する文章生成にのみ使われ、Decoder-onlyは入力全体を読み取る文章の理解や分類にのみ使われるとされる", "Encoder-Decoder型は入力を読み取るEncoder部分を持たず、あらかじめ用意した出力だけを一方向に生成し続ける構造であるとされる"]'),
  ('g-kentei-j-q42', '["Straight-Through Estimator","バッチ正規化（Batch Normalization）","重み減衰（Weight Decay）","アーリーストッピング（Early Stopping）"]'),
  ('g-kentei-j-q44', '["Neural ODE（ニューラル常微分方程式）","残差接続（スキップ結合、Residual Connection）","バッチ正規化（Batch Normalization）","ドロップアウト（Dropout）"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei-j');

COMMIT;
