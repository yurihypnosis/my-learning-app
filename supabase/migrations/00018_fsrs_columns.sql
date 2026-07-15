-- =============================================================
-- 00018_fsrs_columns.sql
-- FSRS(記憶エンジン)の状態を user_question_progress に持たせる。
-- 既存列は残す（mastery 表示・後方互換）。すべて追加のみ・非破壊。
--
-- ⚠ このマイグレーションは、FSRS 保存を行うコードをデプロイする「前」に
--   適用してください（列が無い状態で fsrs_* に書くと解答保存が失敗するため）。
-- =============================================================

ALTER TABLE public.user_question_progress
  ADD COLUMN IF NOT EXISTS fsrs_stability   DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS fsrs_difficulty  DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS fsrs_due         TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS fsrs_last_review TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS fsrs_reps        INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fsrs_lapses      INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fsrs_state       TEXT    NOT NULL DEFAULT 'new';

-- due による出題選択を速くする
CREATE INDEX IF NOT EXISTS idx_uqp_fsrs_due
  ON public.user_question_progress(user_id, fsrs_due);
