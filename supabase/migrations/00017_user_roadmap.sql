-- =============================================================
-- 00017_user_roadmap.sql
-- ロードマップ本体（フェーズ/マイルストン）をユーザーが編集できるよう、
-- 1ユーザー1ドキュメント(jsonb)で保存する。完了状態(done)も doc 内に持つ。
-- （旧 user_roadmap_items は初回シードで完了状態を引き継ぐためだけに参照する）
-- =============================================================

CREATE TABLE IF NOT EXISTS public.user_roadmap (
    user_id    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    doc        JSONB NOT NULL DEFAULT '{"phases":[]}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS set_updated_at ON public.user_roadmap;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_roadmap
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.user_roadmap ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own roadmap doc read"   ON public.user_roadmap;
DROP POLICY IF EXISTS "own roadmap doc insert" ON public.user_roadmap;
DROP POLICY IF EXISTS "own roadmap doc update" ON public.user_roadmap;
DROP POLICY IF EXISTS "own roadmap doc delete" ON public.user_roadmap;

CREATE POLICY "own roadmap doc read"   ON public.user_roadmap FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "own roadmap doc insert" ON public.user_roadmap FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own roadmap doc update" ON public.user_roadmap FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own roadmap doc delete" ON public.user_roadmap FOR DELETE USING (auth.uid() = user_id);
