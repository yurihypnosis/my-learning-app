BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('linux-q203', '["head（頭・先頭）", "heading（見出し）", "header（先頭情報）", "heap（山積み）"]'),
  ('linux-q204', '["tail（尻尾・末尾）", "trail（跡）", "table（表）", "total（合計）"]'),
  ('linux-q206', '["3人の開発者の名字の頭文字", "「配列」を意味する英単語の略", "「自動」を意味する英単語の略", "「解析」を意味する英単語の略"]'),
  ('linux-q207', '["「URLを見る」の言葉遊びに由来", "「巻く・丸める」という英単語そのまま", "「通信を暗号化する」を意味する略語", "開発者の出身地の名前に由来"]'),
  ('linux-q209', '["ソナーの「ピン」という音に由来", "「経路」を意味する英単語の略", "「接続」を意味する英単語の略", "特定の開発者の名字に由来する"]'),
  ('linux-q213', '["top（上位）という英単語そのまま", "sum（合計）を意味する英単語の略", "time（時刻）を意味する英単語の略", "特定の開発者の名字に由来する"]'),
  ('linux-q216', '["free（空いている）という英単語そのまま", "frequency（頻度）の略", "「解放する」という動詞の過去分詞形", "特に意味を持たない開発者の造語"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'linux-basics');

COMMIT;
