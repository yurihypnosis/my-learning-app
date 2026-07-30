BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('python-drill-q05',
   '[".items()が各要素を(key, value)のタプルとして返すため、k, vにアンパックできる","辞書は自動的にキーと値の2列に分かれているため、そのままアンパックできる","Pythonの辞書は常に順序を持たないため、どんな順序で受け取っても動作に影響しない","kとvという変数名がPythonの予約語として特別に扱われ、自動的に分解されるため"]'),
  ('python-drill-q13',
   '["1行目は find が -1 を返し、2行目は index が ValueError を送出する","1行目も2行目も find と同様に -1 を返す","1行目も2行目も見つからない場合は None を返す","1行目も2行目も見つからない場合に ValueError を送出する"]'),
  ('python-drill-q22',
   '["1回目の呼び出しは [''x''] に、2回目の呼び出しは [''x'', ''y''] になる","1回目の呼び出しは [''x''] に、2回目の呼び出しは [''y''] になる（毎回空リストからやり直る想定）","1回目・2回目とも [''x'', ''y''] になる（呼び出し前に両方の値が渡されている）","デフォルト引数にリストを使うと、関数定義そのものがエラーになる"]'),
  ('python-drill-q25',
   '["genは値を必要になるまで計算しないため省メモリ、lstは全要素を即座にメモリ上へ展開する","genもlstもどちらも即座に100万個の要素をメモリ上に展開するため、メモリ使用量に差は生まれない","genの方は文法エラーになる。丸括弧を使った内包表記はPythonには存在しないため","lstの方が省メモリで済み、genの方はメモリを多く消費してしまう仕組みになっている"]'),
  ('python-drill-q32',
   '["False True False True False True False という並びになる","True True True True True True True という並びになる","False True False True True True False という並びになる","エラーになる（0や空文字、空リストにboolを適用できないため）"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'python-drill');

COMMIT;
