-- =============================================================
-- seed_my_exam_goals.sql
-- 自分の試験日を user_exam_goals に投入する（手動UI入力の代わり）。
--
-- 実行方法: Supabase の SQL Editor に貼り付けて実行、または
--           psql "<DB接続文字列>" -f supabase/seed_my_exam_goals.sql
--
-- exam_key は アプリの examGroupKey(slug) と同じ値:
--   GCP Cloud Architect             → gcp-pca
--   GCP DevOps Engineer             → gcp-pcde
--   ISTQB CTAL-TA テストアナリスト  → ctal-ta
--
-- SQL Editor は superuser 実行で auth.uid() が使えないため email で本人を特定する。
-- 冪等: 再実行すると exam_date / target_name を上書きする。
--
-- ▼ 下の 'moonwalker1121@gmail.com' を、アプリのログイン email に置き換えてください。
--   （不明なら先に:  select id, email from auth.users;  で確認）
-- =============================================================

insert into public.user_exam_goals (user_id, exam_key, exam_date, target_name)
select u.id, v.exam_key, v.exam_date, v.target_name
from auth.users u
cross join (values
  ('gcp-pca',  date '2026-08-02', 'GCP Professional Cloud Architect'),
  ('gcp-pcde', date '2026-08-22', 'GCP Professional Cloud DevOps Engineer'),
  ('ctal-ta',  date '2026-09-01', 'ISTQB CTAL-TA テストアナリスト')
) as v(exam_key, exam_date, target_name)
where u.email = 'moonwalker1121@gmail.com'
on conflict (user_id, exam_key)
do update set exam_date = excluded.exam_date, target_name = excluded.target_name;

-- 確認用（任意）:
-- select g.exam_key, g.exam_date, g.target_name
-- from public.user_exam_goals g
-- join auth.users u on u.id = g.user_id
-- where u.email = 'moonwalker1121@gmail.com'
-- order by g.exam_date;
