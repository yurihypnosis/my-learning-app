-- 回答イベント履歴テーブル
-- 1問回答するたびに1行追加（last_answered_at と違い全履歴を保持）
CREATE TABLE IF NOT EXISTS public.answer_events (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL,
  question_id      UUID        NOT NULL,
  category_id      UUID        NOT NULL,
  category_name    TEXT        NOT NULL,
  category_color   TEXT        NOT NULL DEFAULT '#64748b',
  subject_slug     TEXT        NOT NULL,
  is_correct       BOOLEAN     NOT NULL,
  confidence       INTEGER,    -- 1=確信あり, 2=迷った, 3=勘
  answered_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.answer_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can insert own answer events"
  ON public.answer_events FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users can read own answer events"
  ON public.answer_events FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- user_id + answered_at での日付集計クエリを高速化
CREATE INDEX IF NOT EXISTS answer_events_user_date_idx
  ON public.answer_events (user_id, answered_at DESC);
