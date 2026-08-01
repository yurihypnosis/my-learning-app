BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('linux-q228', '["un（否定）＋mount の組み合わせ","unique（唯一の）＋mount の組み合わせ","under（下に）＋mount の組み合わせ","update（更新する）＋mount の組み合わせ"]'),
  ('linux-q230', '["fixed disk（固定ディスク）のf","file（ファイル）のf","fast（高速）のf","full（全体）のf"]'),
  ('linux-q232', '["ls＋block devices の組み合わせ","list＋black（黒）の組み合わせ","less＋block（塊）の組み合わせ","local＋block（塊）の組み合わせ"]'),
  ('linux-q239', '["internet protocol（通信の約束事）","internal process（内部処理）","input port（入力の窓口）","instant ping（即時のping）"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'linux-basics');

COMMIT;
