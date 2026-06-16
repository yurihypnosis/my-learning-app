-- =============================================================
-- 00001_initial_schema.sql
-- my-learning-app: 拡張可能な学習アプリの初期スキーマ
-- subjects(科目) -> categories(分野) -> questions(問題)
-- user_question_progress でユーザーごとの進捗・理解度・メモを管理
-- =============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================
-- 1. profiles (auth.users 拡張)
-- =============================================================
CREATE TABLE public.profiles (
    id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================
-- 2. subjects (科目: GCP-ACE, 将来 AWS など)
-- =============================================================
CREATE TABLE public.subjects (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug        TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    description TEXT,
    color       TEXT NOT NULL DEFAULT '#2563eb',
    sort_order  INTEGER NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_subjects_slug ON public.subjects(slug);

-- =============================================================
-- 3. categories (分野: IAM, GKE ...)
-- =============================================================
CREATE TABLE public.categories (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    name       TEXT NOT NULL,
    color      TEXT NOT NULL DEFAULT '#64748b',
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (subject_id, name)
);

CREATE INDEX idx_categories_subject_id ON public.categories(subject_id);

-- =============================================================
-- 4. questions (4択問題)
-- options は ["A","B","C","D"] の JSONB 配列、correct_index は 0..3
-- initial_wrong_weight: 模試での初期誤答回数(旧 w)。弱点優先の重み付けに使う
-- =============================================================
CREATE TABLE public.questions (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id           UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    category_id          UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
    source_ref           TEXT,
    question_text        TEXT NOT NULL,
    options              JSONB NOT NULL,
    correct_index        INTEGER NOT NULL CHECK (correct_index >= 0),
    explanation          TEXT NOT NULL DEFAULT '',
    initial_wrong_weight INTEGER NOT NULL DEFAULT 0,
    is_active            BOOLEAN NOT NULL DEFAULT true,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (subject_id, source_ref)
);

CREATE INDEX idx_questions_subject_id ON public.questions(subject_id);
CREATE INDEX idx_questions_category_id ON public.questions(category_id);
CREATE INDEX idx_questions_is_active ON public.questions(is_active);

-- =============================================================
-- 5. user_question_progress (ユーザー x 問題の進捗・中核テーブル)
-- understanding_level: 0=未評価, 1=全く分からない, 2=怪しい, 3=だいたい理解, 4=完璧
-- =============================================================
CREATE TABLE public.user_question_progress (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    question_id         UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
    correct_count       INTEGER NOT NULL DEFAULT 0,
    wrong_count         INTEGER NOT NULL DEFAULT 0,
    consecutive_correct INTEGER NOT NULL DEFAULT 0,
    last_is_correct     BOOLEAN,
    last_selected_index INTEGER,
    last_answered_at    TIMESTAMPTZ,
    understanding_level INTEGER NOT NULL DEFAULT 0 CHECK (understanding_level BETWEEN 0 AND 4),
    memo                TEXT NOT NULL DEFAULT '',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, question_id)
);

CREATE INDEX idx_uqp_user_id ON public.user_question_progress(user_id);
CREATE INDEX idx_uqp_question_id ON public.user_question_progress(question_id);

-- =============================================================
-- updated_at 自動更新トリガ
-- =============================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.subjects
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.questions
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_question_progress
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================
-- サインアップ時に profile を自動作成
-- =============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data ->> 'display_name', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================================
-- Row Level Security
-- 教材(subjects/categories/questions)は全員読み取り可。
-- 進捗(profiles/user_question_progress)は本人のみ。
-- =============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own profile read"   ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "own profile update" ON public.profiles FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "subjects read" ON public.subjects FOR SELECT USING (true);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories read" ON public.categories FOR SELECT USING (true);

ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "questions read" ON public.questions FOR SELECT USING (is_active = true);

ALTER TABLE public.user_question_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own progress read"   ON public.user_question_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "own progress insert" ON public.user_question_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own progress update" ON public.user_question_progress FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
