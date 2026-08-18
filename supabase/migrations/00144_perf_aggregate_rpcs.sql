-- =============================================================
-- 00144_perf_aggregate_rpcs.sql
-- ダッシュボードの集計を DB 側に寄せるための RPC 群。
--
-- 背景: PostgREST の 1行あたり返却上限（既定 1000行）により、
--   questions / user_question_progress / answer_events の全件取得が
--   黙って 1000 行で打ち切られ、収録問題数・カバー率・累計解答数・
--   連続学習日数が実データと合わなくなっていた。
--   （実測: questions 3,451 / progress 1,355 / events 1,844 に対し各 1,000 件）
--
-- 対策: 行を全部クライアントまで運ばず、集計結果だけを返す。
--   subject_stats()        → 科目数ぶんの行（十数行）
--   daily_answer_counts()  → 日数ぶんの行（既定120行）
--   progress_for_subjects()→ 現在の試験区分の問題だけの進捗
--
-- すべて SECURITY INVOKER。RLS はそのまま効き、auth.uid() で本人に限定する。
-- =============================================================

-- -------------------------------------------------------------
-- 1. 科目(セット)ごとの学習統計
--    total     : 出題可能な問題数
--    attempted : 1回以上解答した問題数
--    answers   : 総解答回数, correct: 正解回数
-- -------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.subject_stats()
RETURNS TABLE (
  subject_id       UUID,
  total            BIGINT,
  attempted        BIGINT,
  answers          BIGINT,
  correct          BIGINT,
  last_answered_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    q.subject_id,
    count(*)::BIGINT,
    count(*) FILTER (
      WHERE coalesce(p.correct_count, 0) + coalesce(p.wrong_count, 0) > 0
    )::BIGINT,
    coalesce(sum(coalesce(p.correct_count, 0) + coalesce(p.wrong_count, 0)), 0)::BIGINT,
    coalesce(sum(coalesce(p.correct_count, 0)), 0)::BIGINT,
    max(p.last_answered_at)
  FROM public.questions q
  LEFT JOIN public.user_question_progress p
    ON p.question_id = q.id
   AND p.user_id = auth.uid()
  WHERE q.is_active
  GROUP BY q.subject_id;
$$;

-- -------------------------------------------------------------
-- 2. 日別の解答数（JST の暦日で集計）
--    学習アクティビティ・連続学習日数・1日capacity の推定に使う。
-- -------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.daily_answer_counts(p_days INTEGER DEFAULT 120)
RETURNS TABLE (
  day     DATE,
  total   BIGINT,
  correct BIGINT
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    ((e.answered_at AT TIME ZONE 'Asia/Tokyo')::DATE) AS day,
    count(*)::BIGINT,
    count(*) FILTER (WHERE e.is_correct)::BIGINT
  FROM public.answer_events e
  WHERE e.user_id = auth.uid()
    AND e.answered_at >= now() - make_interval(days => greatest(p_days, 1))
  GROUP BY 1
  ORDER BY 1 DESC;
$$;

-- -------------------------------------------------------------
-- 3. 指定した科目(セット)群に属する問題の進捗だけを返す
--    いま開いている試験区分ぶんに絞ることで、全進捗を運ばずに済む。
-- -------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.progress_for_subjects(p_subject_ids UUID[])
RETURNS SETOF public.user_question_progress
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT p.*
  FROM public.user_question_progress p
  JOIN public.questions q ON q.id = p.question_id
  WHERE p.user_id = auth.uid()
    AND q.subject_id = ANY (p_subject_ids);
$$;

GRANT EXECUTE ON FUNCTION public.subject_stats()                    TO authenticated;
GRANT EXECUTE ON FUNCTION public.daily_answer_counts(INTEGER)       TO authenticated;
GRANT EXECUTE ON FUNCTION public.progress_for_subjects(UUID[])      TO authenticated;

-- 集計で毎回 questions 全体を走るので、subject_id の被覆インデックスを足しておく。
CREATE INDEX IF NOT EXISTS idx_questions_subject_active
  ON public.questions (subject_id) WHERE is_active;
