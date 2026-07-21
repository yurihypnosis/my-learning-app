-- Speak-First（英語・句動詞 文産出ドリル）: 口頭産出の自己申告フラグ。
-- null=未記録, false=口で言えなかった（苦手だけ演習に流入）, true=言えた。
-- pv-* 科目のクライアントだけが書く。既存科目には無影響。
ALTER TABLE public.user_question_progress
  ADD COLUMN IF NOT EXISTS last_spoken_ok BOOLEAN;
