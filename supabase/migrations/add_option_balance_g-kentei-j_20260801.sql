BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('g-kentei-j-q30', '["Depthwise Separable Convolution（深さ方向分離畳み込み）","Dilated Convolution（拡張畳み込み、フィルタの間隔を広げる）","Grouped Convolution（グループ畳み込み、チャネルを分割する）","Transposed Convolution（転置畳み込み、特徴マップを拡大する）"]'),
  ('g-kentei-j-q31', '["Squeeze-and-Excitation（SE）ブロック","スキップ結合（残差接続、層を飛び越えて足し込む仕組み）","バッチ正規化（層に入る値のばらつきをそろえる仕組み）","Global Average Pooling（特徴マップ全体を1つの値に平均する仕組み）"]'),
  ('g-kentei-j-q33', '["Highway Network（ゲートで素通しか変換かを選べる仕組み）","DenseNet（すべての層を密に結合する仕組み）","オートエンコーダ（入力を圧縮して復元する仕組み）","バッチ正規化（層に入る値のばらつきをそろえる仕組み）"]'),
  ('g-kentei-j-q7', '["マックスアウト（Maxout、複数の直線の最大値を採る活性化関数）","ソフトマックス関数（複数の値を合計1の確率に変換する関数）","GELU（正規分布に基づく確率的なゲート型の活性化関数）","バッチ正規化（層に入る値のばらつきをそろえる手法）"]'),
  ('g-kentei-j-q8', '["ハードシグモイド／ハードスウィッシュ（区分線形近似）","ELU（負の領域が指数的になめらかに飽和する活性化関数）","ソフトプラス関数（log(1+e^x)で表されるなめらかな関数）","PReLU（負の傾きを学習で決める活性化関数）"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei-j');

COMMIT;
