BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('linux-q230', '["fixed disk（固定ディスク）のf","file（ファイルの略）のf","fast（高速の意味）のf","full（全体の意味）のf"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'linux-basics');

COMMIT;
