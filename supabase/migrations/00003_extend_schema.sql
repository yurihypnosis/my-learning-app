-- =============================================================
-- 00003_extend_schema.sql
-- questions: code block / multi-answer / rich explanation
-- user_question_progress: confidence level
-- =============================================================

ALTER TABLE public.questions
  ADD COLUMN IF NOT EXISTS code TEXT,
  ADD COLUMN IF NOT EXISTS question_type TEXT NOT NULL DEFAULT 'single',
  ADD COLUMN IF NOT EXISTS correct_indices JSONB,
  ADD COLUMN IF NOT EXISTS explanation_data JSONB;

ALTER TABLE public.user_question_progress
  ADD COLUMN IF NOT EXISTS last_confidence INTEGER; -- 1=確信あり, 2=迷った, 3=勘
