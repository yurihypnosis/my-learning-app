-- =============================================================
-- 00016_user_textbooks.sql
-- 試験区分(exam group)ごとに「教科書」リンク（Claude アーティテクトの公開ページ等）を
-- ユーザー単位で保存する。1 試験区分に複数リンクを持てる（1 リンク = 1 行）。
--
-- exam_key は アプリの examGroupKey(slug) と同じ値（例: 'gcp-pcde', 'ctal-ta'）。
-- 表示順は sort_order 昇順。RLS は本人の行のみ（user_exam_goals と同じ方針）。
-- =============================================================

CREATE TABLE IF NOT EXISTS public.user_textbooks (
    id          UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    exam_key    TEXT NOT NULL,
    label       TEXT NOT NULL DEFAULT '',
    url         TEXT NOT NULL,
    sort_order  INT  NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_user_textbooks_user_exam
    ON public.user_textbooks(user_id, exam_key, sort_order);

-- updated_at 自動更新（既存の共通トリガ関数を再利用）
DROP TRIGGER IF EXISTS set_updated_at ON public.user_textbooks;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_textbooks
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- RLS: 本人の行のみ読み書き可
ALTER TABLE public.user_textbooks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own textbook read"   ON public.user_textbooks;
DROP POLICY IF EXISTS "own textbook insert" ON public.user_textbooks;
DROP POLICY IF EXISTS "own textbook update" ON public.user_textbooks;
DROP POLICY IF EXISTS "own textbook delete" ON public.user_textbooks;

CREATE POLICY "own textbook read"   ON public.user_textbooks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "own textbook insert" ON public.user_textbooks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own textbook update" ON public.user_textbooks FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own textbook delete" ON public.user_textbooks FOR DELETE USING (auth.uid() = user_id);
