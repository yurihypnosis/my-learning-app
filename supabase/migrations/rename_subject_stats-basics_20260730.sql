BEGIN;

UPDATE public.subjects
SET name = '統計学の基礎（図解ドリル）',
    description = '統計の用語を、前提知識ゼロでも分かる解説と1枚の図で腹落ちさせる図解ドリル。問題は入口、主役は解説。記述統計から検定・ベイズ・機械学習まで8テーマを積み上げる。'
WHERE slug = 'stats-basics';

COMMIT;
