BEGIN;

ALTER TABLE public.user_question_progress
  ADD COLUMN IF NOT EXISTS excluded boolean NOT NULL DEFAULT false;

COMMIT;
