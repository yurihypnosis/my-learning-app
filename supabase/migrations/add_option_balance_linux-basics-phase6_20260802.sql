BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('linux-q195', '["edエディタの操作「g/re/p」（global regular expression print）に由来する説","get repeated pattern（繰り返しのパターンをすべて取得する、の意味）の略という説","green paper（初期のマニュアルに使われていた紙の色）に由来する説","great performance（検索の高速さをアピールした表現）の略という説"]'),
  ('linux-q188', '["print working directory（作業中ディレクトリの表示）の意味","password（合言葉）の意味","path with directory（パス付きのディレクトリ）の意味","print with data（データ付きで表示する）の意味"]'),
  ('linux-q192', '["concatenate（つなぎ合わせる）の意味","category（種類ごとに分類する）の意味","catch（途中でつかまえる）の意味","catalog（目録にまとめる）の意味"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'linux-basics');

COMMIT;
