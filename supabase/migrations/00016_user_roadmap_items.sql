-- =============================================================
-- 00016_user_roadmap_items.sql
-- 学習ロードマップの各項目（マイルストン等）の「完了したか」をユーザー単位で
-- 保存する。item_key はクライアント側で決まる安定キー（例: 'C.m1', 'B.b0'）。
-- localStorage をやめ、PC/モバイルで同期できるようにする。
-- =============================================================

CREATE TABLE IF NOT EXISTS public.user_roadmap_items (
    user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_key   TEXT NOT NULL,
    done       BOOLEAN NOT NULL DEFAULT false,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, item_key)
);

CREATE INDEX IF NOT EXISTS idx_user_roadmap_items_user ON public.user_roadmap_items(user_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.user_roadmap_items;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_roadmap_items
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- RLS: 本人の行のみ読み書き可
ALTER TABLE public.user_roadmap_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own roadmap read"   ON public.user_roadmap_items;
DROP POLICY IF EXISTS "own roadmap insert" ON public.user_roadmap_items;
DROP POLICY IF EXISTS "own roadmap update" ON public.user_roadmap_items;
DROP POLICY IF EXISTS "own roadmap delete" ON public.user_roadmap_items;

CREATE POLICY "own roadmap read"   ON public.user_roadmap_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "own roadmap insert" ON public.user_roadmap_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own roadmap update" ON public.user_roadmap_items FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own roadmap delete" ON public.user_roadmap_items FOR DELETE USING (auth.uid() = user_id);
