-- 選択肢の長さ均し（G検定 Set A）。
-- 「正解が単独最長」だと問題文を読まずに当てられるため、誤答にも同等の長さを持たせる。
-- 用語識別問題は誤答側にも英語/補足を併記、長文型は誤答を正解と同程度の情報量に。
-- correct_index は全て 0 のまま（要素の並びは変えていない）。opt 配列の対応も不変。

BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('g-kentei-q21',
   '["誤差逆伝播法（バックプロパゲーション）","主成分分析（PCA・次元削減）","焼きなまし法（シミュレーテッドアニーリング）","ブートストラップ法（復元抽出）"]'),
  ('g-kentei-q27',
   '["自己注意（Self-Attention）","プーリング（Pooling）","スキップ結合（Skip Connection）","バッチ正規化（Batch Normalization）"]'),
  ('g-kentei-q31',
   '["セマンティックセグメンテーション（画素単位の分類）","物体検出（Object Detection）","画像分類（Image Classification）","画像生成（Image Generation）"]'),
  ('g-kentei-q35',
   '["拡散モデル（Diffusion Model）","サポートベクターマシン（SVM）","ランダムフォレスト（Random Forest）","ロジスティック回帰（Logistic Regression）"]'),
  ('g-kentei-q47',
   '["敵対的サンプル（Adversarial Examples）","ディープフェイク（Deepfake）","データポイズニング（Data Poisoning）","モデル蒸留（Knowledge Distillation）"]'),
  ('g-kentei-q36',
   '["転移学習は学習済みの知識を別タスクに活かす総称であり、ファインチューニングはその重みを追加調整する具体手法を指す","ファインチューニングが学習済みの知識を別タスクに活かす総称であり、転移学習はその中の一手法に当たる","転移学習もファインチューニングも、重みをゼロから初期化して一から学習し直すことを指している","転移学習もファインチューニングも、学習済みの重みを固定したまま一切更新せずに使うことを指す"]'),
  ('g-kentei-q46',
   '["法律で一律に決まるものではなく、契約当事者間の取り決めによって帰属を明確にしておく必要がある","開発を担当したベンダ側に必ず帰属し、契約によっても委託者へ移転することはできないとされる","開発費用を負担した発注者側に、契約の内容にかかわらず当然に帰属することになると定められている","学習済みモデルには知的財産権がそもそも発生しないため、帰属をあえて定める必要はないとされる"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

COMMIT;
