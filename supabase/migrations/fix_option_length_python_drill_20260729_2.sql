BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('python-drill-q05',
   '[".items()が(key, value)のタプルを返すため、k, vに分解代入できる","辞書は自動的にキーと値の2列に分かれているため、そのままアンパックできる","Pythonの辞書は常に順序を持たないため、どんな順序で受け取ってもforループの動作にはまったく影響しない","kとvという変数名がPythonの予約語として特別に扱われ、自動的に分解されるため"]'),
  ('python-drill-q13',
   '["1行目は -1 を返し、2行目は ValueError を送出する","1行目も2行目も find と同様に -1 を返す","1行目も2行目も見つからない場合は None を返す","1行目も2行目も見つからない場合には同じように ValueError が送出される仕組みになっている"]'),
  ('python-drill-q32',
   '["False True False True False True False という並びになる","True True True True True True True という並びになる","False True False True True True False という結果の並びになる","エラーになる（0や空文字、空リストにboolを適用できないため）"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'python-drill');

COMMIT;
