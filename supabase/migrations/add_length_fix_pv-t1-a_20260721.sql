-- 長さリーク自己チェックで検出された2問の直訳肢を、意味を変えずに冗長化して修正
BEGIN;

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}',
  '"The new regulation was the reason that made the supply chain change a great deal."')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'pv-t1-a' AND q.source_ref = 'pv-t1a-q02';

UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}',
  '"Employees are expected to make the theory that they learned in training into the practice."')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'pv-t1-a' AND q.source_ref = 'pv-t1a-q13';

COMMIT;
