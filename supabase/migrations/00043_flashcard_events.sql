-- =============================================================
-- 00043_flashcard_events.sql
-- 単語カード（フラッシュカード）の1採点ごとの履歴。学習ログに載せて、
-- 連続日数・日々の活動量に単語学習も反映させる（answer_events の単語版）。
--
-- answer_events は question_id/category_id が NOT NULL で単語は入らないため、
-- 別テーブルにして log 側でマージする。
-- deck_key は examGroupKey（'g-kentei' 等）、cat は分野ラベル。
-- result は 'k'=覚えていた / 'w'=あやしい。
-- =============================================================

CREATE TABLE IF NOT EXISTS public.flashcard_events (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL,
  deck_key       TEXT        NOT NULL,
  cat            TEXT        NOT NULL,
  category_color TEXT        NOT NULL DEFAULT '#8892a4',
  result         TEXT        NOT NULL CHECK (result IN ('k', 'w')),
  answered_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.flashcard_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own flashcard event insert" ON public.flashcard_events;
DROP POLICY IF EXISTS "own flashcard event read"   ON public.flashcard_events;

CREATE POLICY "own flashcard event insert"
  ON public.flashcard_events FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "own flashcard event read"
  ON public.flashcard_events FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS flashcard_events_user_date_idx
  ON public.flashcard_events (user_id, answered_at DESC);

GRANT SELECT, INSERT ON public.flashcard_events TO authenticated;
