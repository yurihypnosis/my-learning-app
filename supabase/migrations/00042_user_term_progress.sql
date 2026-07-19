-- =============================================================
-- 00042_user_term_progress.sql
-- 単語カード（フラッシュカード）の学習進捗を、端末ローカル(localStorage)ではなく
-- ユーザー単位でDBに保存する。PC/モバイルで同期できるようにする（user_exam_goals と同方針）。
--
-- deck_key は アプリの examGroupKey と同じ値（例: 'g-kentei', 'dca', 'gcp-pcde'）。
-- term は用語カードの識別子（表示文字列そのもの）。
-- result は直近の自己採点: 'k'=覚えていた(定着) / 'w'=あやしい。
-- known_count / weak_count は累計。定着/あやしい/未学習の振り分けは result で行う。
-- =============================================================

CREATE TABLE IF NOT EXISTS public.user_term_progress (
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    deck_key    TEXT NOT NULL,
    term        TEXT NOT NULL,
    result      TEXT NOT NULL DEFAULT 'w' CHECK (result IN ('k', 'w')),
    known_count INTEGER NOT NULL DEFAULT 0,
    weak_count  INTEGER NOT NULL DEFAULT 0,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, deck_key, term)
);

CREATE INDEX IF NOT EXISTS idx_user_term_progress_user ON public.user_term_progress(user_id);

-- updated_at 自動更新（既存の共通トリガ関数を再利用）
DROP TRIGGER IF EXISTS set_updated_at ON public.user_term_progress;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_term_progress
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- RLS: 本人の行のみ読み書き可（user_exam_goals / user_question_progress と同じ方針）
ALTER TABLE public.user_term_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own term progress read"   ON public.user_term_progress;
DROP POLICY IF EXISTS "own term progress insert" ON public.user_term_progress;
DROP POLICY IF EXISTS "own term progress update" ON public.user_term_progress;
DROP POLICY IF EXISTS "own term progress delete" ON public.user_term_progress;

CREATE POLICY "own term progress read"   ON public.user_term_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "own term progress insert" ON public.user_term_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own term progress update" ON public.user_term_progress FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own term progress delete" ON public.user_term_progress FOR DELETE USING (auth.uid() = user_id);

-- 認証ユーザーにテーブル権限を付与（RLS が本人行に限定する）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_term_progress TO authenticated;
