-- =============================================================
-- 00015_user_exam_goals.sql
-- 試験日（目標）を「セット(subject)ごと」ではなく「試験区分(exam group)ごと」に
-- ユーザー単位で保存する。localStorage をやめ、PC/モバイルで同期できるようにする。
--
-- exam_key は アプリの examGroupKey(slug) と同じ値（例: 'ctal-ta', 'gcp-pcde'）。
-- 同一試験の全セットで 1 行を共有する。
-- =============================================================

CREATE TABLE IF NOT EXISTS public.user_exam_goals (
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    exam_key    TEXT NOT NULL,
    exam_date   DATE,
    target_name TEXT NOT NULL DEFAULT '',
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, exam_key)
);

CREATE INDEX IF NOT EXISTS idx_user_exam_goals_user ON public.user_exam_goals(user_id);

-- updated_at 自動更新（既存の共通トリガ関数を再利用）
DROP TRIGGER IF EXISTS set_updated_at ON public.user_exam_goals;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_exam_goals
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- RLS: 本人の行のみ読み書き可（user_question_progress と同じ方針）
ALTER TABLE public.user_exam_goals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own exam goal read"   ON public.user_exam_goals;
DROP POLICY IF EXISTS "own exam goal insert" ON public.user_exam_goals;
DROP POLICY IF EXISTS "own exam goal update" ON public.user_exam_goals;
DROP POLICY IF EXISTS "own exam goal delete" ON public.user_exam_goals;

CREATE POLICY "own exam goal read"   ON public.user_exam_goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "own exam goal insert" ON public.user_exam_goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own exam goal update" ON public.user_exam_goals FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own exam goal delete" ON public.user_exam_goals FOR DELETE USING (auth.uid() = user_id);
