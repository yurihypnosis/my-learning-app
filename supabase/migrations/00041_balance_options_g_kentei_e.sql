-- Set E: 正解が単独最長だった5問の選択肢を均す（順序維持、optは既存のまま整合）
BEGIN;
UPDATE public.questions q SET options = '["自己注意", "プーリング", "ドロップアウト", "バッチ正規化"]'::jsonb
FROM public.subjects s
WHERE q.subject_id=s.id AND s.slug='g-kentei-e' AND q.source_ref='g-kentei-e-q27';
UPDATE public.questions q SET options = '["サポートベクターマシン", "k近傍法（k-NN）", "決定木（条件分岐）", "主成分分析（PCA）"]'::jsonb
FROM public.subjects s
WHERE q.subject_id=s.id AND s.slug='g-kentei-e' AND q.source_ref='g-kentei-e-q12';
UPDATE public.questions q SET options = '["セマンティックセグメンテーション", "物体検出（枠で位置を示す）", "画像分類（写真全体に1ラベル）", "超解像（画像の高解像度化）"]'::jsonb
FROM public.subjects s
WHERE q.subject_id=s.id AND s.slug='g-kentei-e' AND q.source_ref='g-kentei-e-q31';
UPDATE public.questions q SET options = '["敵対的生成ネットワーク（GAN）", "オートエンコーダ（圧縮と復元）", "決定木（条件分岐で予測）", "サポートベクターマシン"]'::jsonb
FROM public.subjects s
WHERE q.subject_id=s.id AND s.slug='g-kentei-e' AND q.source_ref='g-kentei-e-q34';
UPDATE public.questions q SET options = '["知識獲得のボトルネック", "フレーム問題（考慮範囲の壁）", "組合せ爆発（場合の数の増大）", "次元の呪い（高次元の疎化）"]'::jsonb
FROM public.subjects s
WHERE q.subject_id=s.id AND s.slug='g-kentei-e' AND q.source_ref='g-kentei-e-q9';
COMMIT;
