BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('python-drill', 'Pythonクイズ（通勤ドリル）', '通勤・移動時間に解く、Python文法の一問一答。リストや辞書の操作、内包表記、デコレータなど基礎〜応用の構文理解を確認する。', '#3776ab', 130, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('リストとタプル', '#58a6ff', 0),
  ('辞書とセット', '#3fb950', 1),
  ('文字列操作', '#d2a8ff', 2),
  ('制御構文と真偽値', '#e3a008', 3),
  ('関数型プログラミング', '#a5d6ff', 4),
  ('関数と引数', '#f778ba', 5),
  ('オブジェクトの同一性とコピー', '#ffa657', 6),
  ('ジェネレータとメモリ', '#7ee787', 7),
  ('例外処理', '#ff7b72', 8),
  ('クラスとオブジェクト指向', '#d29922', 9)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'python-drill'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('python-drill-q01', 'リストとタプル',
   'このコードを実行すると何が出力される？',
   'items = ["a", "b", "c"]
items.append("d")
removed = items.pop()
print(items, removed)',
   '["[''a'', ''b'', ''c'', ''d''] と ''d''","[''a'', ''b'', ''c''] と ''d''","[''d'', ''a'', ''b'', ''c''] と ''a''","エラーになる"]',
   0, '[0]', 'single',
   '{"asked":"このコードを実行すると何が出力される？（list.append / list.pop）","think":".append()は末尾に追加、引数なしの.pop()は末尾を取り出して削除するので、''d''を足してすぐ''d''を抜いた形になる。","opt":["正解。.append()は末尾に追加、引数なしの.pop()は末尾を取り出して削除するので、''d''を足してすぐ''d''を抜いた形になる。",".pop()はリストから要素を「削除して」返す破壊的操作。元のリストに''d''は残らない。",".append()は先頭ではなく末尾に追加する。先頭に足したいなら.insert(0, x)。","空リストで引数なし.pop()を呼ぶとエラーになるが、今回は要素があるので正常に動く。"]}'),

  ('python-drill-q02', 'リストとタプル',
   '出力される内容は？',
   'nums = [10, 20, 30]
nums.insert(1, 15)
nums.remove(30)
print(nums)',
   '["[10, 15, 20]","[10, 20, 15, 30]","[10, 15, 20, 30]","エラーになる"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（list.insert / list.remove）","think":".insert(1, 15)はインデックス1の位置に15を挿入→[10,15,20,30]。.remove(30)は「値30」を探して削除するので30が消える。","opt":["正解。.insert(1, 15)はインデックス1の位置に15を挿入→[10,15,20,30]。.remove(30)は「値30」を探して削除するので30が消える。",".insert(i, x)の第一引数はインデックス（挿入位置）。値の後ろに足すわけではない。",".remove(30)を実行しているので30は削除された状態が正しい。",".remove()はリストに存在する値なら正常に削除できる。"]}'),

  ('python-drill-q03', 'リストとタプル',
   '出力される内容は？',
   's = [0, 1, 2, 3, 4, 5]
print(s[1:4], s[-2:], s[::2])',
   '["[1, 2, 3] [4, 5] [0, 2, 4]","[1, 2, 3, 4] [4, 5] [0, 2, 4]","[1, 2, 3] [3, 4, 5] [0, 2, 4]","[1, 2, 3] [4, 5] [1, 3, 5]"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（スライス）","think":"s[1:4]はindex1〜3。s[-2:]は後ろから2つ。s[::2]は先頭から2個おき。","opt":["正解。s[1:4]はindex1〜3。s[-2:]は後ろから2つ。s[::2]は先頭から2個おき。","スライスの終端indexは「含まない」。s[1:4]はindex4の要素を含まないので[1,2,3]まで。","s[-2:]は「後ろから2番目〜末尾」＝[4,5]。-3ではなく-2から。","s[::2]はindex0から始まる（s[0], s[2], s[4]）。1から始まる場合はs[1::2]と書く。"]}'),

  ('python-drill-q04', '辞書とセット',
   '実行結果は？',
   'user = {"name": "Yu", "role": "engineer"}
print(user.get("age", 0))
print(user["age"])',
   '["0 の後にKeyError","0 の後に None","KeyError の後に 0","両方とも 0"]',
   0, '[0]', 'single',
   '{"asked":"実行結果は？（dict.get）","think":".get(key, default)はキーが無ければデフォルト値（ここは0）を返すだけでエラーにならない。一方user[\"age\"]は角括弧アクセスなのでキーが無いとKeyErrorで落ちる。","opt":["正解。.get(key, default)はキーが無ければデフォルト値（ここは0）を返すだけでエラーにならない。一方user[\"age\"]は角括弧アクセスなのでキーが無いとKeyErrorで落ちる。","角括弧[]でのアクセスはキーが無いと必ずKeyErrorを送出する。Noneを返すのは.get()で第二引数を省略した場合だけ。","先に実行される.get()はエラーにならない。落ちるのは2行目のuser[\"age\"]。","角括弧アクセスuser[\"age\"]にはデフォルト値の仕組みがなく、キーが無ければ即エラー。"]}'),

  ('python-drill-q05', '辞書とセット',
   'このループが正しく動く理由として適切なものは？',
   'prices = {"tea": 300, "coffee": 400}
for k, v in prices.items():
    print(k, v)',
   '[".items()が各要素を(key, value)のタプルとして返すため、k, vにアンパックできる","辞書は自動的にキーと値の2列に分かれているため","Pythonの辞書は常に順序を持たないため、どんな書き方でも動く","kとvという変数名がPythonの予約語だから"]',
   0, '[0]', 'single',
   '{"asked":"このループが正しく動く理由として適切なものは？（dict.items / for文）","think":"辞書の.items()は(キー, 値)のペアを順に返すview。forループのk, vはタプルの分解代入（アンパック）。","opt":["正解。辞書の.items()は(キー, 値)のペアを順に返すview。forループのk, vはタプルの分解代入（アンパック）。","辞書はキー→値のマッピングであり「2列」ではない。.items()がペアのタプルを生成しているだけ。","Python3.7以降、辞書は挿入順を保持する。また今回動く理由は順序ではなく.items()の返す形。","kやvに特別な意味はない、ただの変数名。"]}'),

  ('python-drill-q06', '文字列操作',
   '出力される内容は？',
   'line = "apple,banana,,cherry"
parts = line.split(",")
print(parts)
print("-".join(parts))',
   '["[''apple'', ''banana'', '''', ''cherry''] と ''apple-banana--cherry''","[''apple'', ''banana'', ''cherry''] と ''apple-banana-cherry''","エラーになる","[''apple'', ''banana'', '''', ''cherry''] と ''apple,banana,,cherry''"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（str.split / str.join）","think":".split(\",\")は区切り文字を明示すると連続する区切りの間に空文字''''を作る。.join()はそのリストを-で結合するので空文字の箇所は--になる。","opt":["正解。.split(\",\")は区切り文字を明示すると連続する区切りの間に空文字''''を作る。.join()はそのリストを-で結合するので空文字の箇所は--になる。","これは引数なしの.split()（空白区切り）の挙動と混同している。カンマを明示指定すると空要素は除去されない。",".split(\",\")も.join()も正常に動作する。空文字が混ざってもエラーにはならない。","joinは呼び出した文字列（ここでは\"-\"）を区切りに使う。元の区切り文字,には戻らない。"]}'),

  ('python-drill-q07', '文字列操作',
   '出力される内容は？',
   'name = "  Yu  "
age = 5
print(f"{name.strip()} has {age} year(s) of exp")',
   '["Yu has 5 year(s) of exp","  Yu   has 5 year(s) of exp","Yu has 5 year(s) of expのあとに空白付きの元の文字列も表示される","エラーになる（f-stringの中でメソッドは呼べない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（str.strip / f-string）","think":".strip()は前後の空白（両端のみ）を除去する。f-stringは{}内の式を評価して埋め込む。","opt":["正解。.strip()は前後の空白（両端のみ）を除去する。f-stringは{}内の式を評価して埋め込む。",".strip()を呼んでいるので前後の空白は除去された状態が正しい。","f-string内ではname.strip()の「戻り値」だけが埋め込まれる。元の変数は変わらないが、ここでは戻り値しか出力していない。","f-stringの{}内は通常のPython式として評価されるため、メソッド呼び出しも問題なく使える。"]}'),

  ('python-drill-q08', '制御構文と真偽値',
   '出力される数値の並びは？',
   'for i in range(2, 10, 3):
    print(i)',
   '["2, 5, 8","2, 3, 4, ..., 9","2, 5, 8, 11","3, 6, 9"]',
   0, '[0]', 'single',
   '{"asked":"出力される数値の並びは？（range）","think":"range(start, stop, step)はstartから始まり、stepずつ増え、stop未満で止まる。2→5→8→(11はstop10を超えるので終了)。","opt":["正解。range(start, stop, step)はstartから始まり、stepずつ増え、stop未満で止まる。2→5→8→(11はstop10を超えるので終了)。","これはrange(2, 10)（step省略＝1）の場合の挙動。今回は第三引数3がstepとして指定されている。","range(2, 10, 3)のstop=10は「含まれない」上限。11は10を超えているのでそもそも生成されない。","start=2なので最初の値は2。3の倍数ではなく「2から3ずつ増える」数列になる。"]}'),

  ('python-drill-q09', '制御構文と真偽値',
   '出力される内容は？',
   'fruits = ["apple", "banana"]
print("banana" in fruits)
print("banana" in "I like bananas")',
   '["True の後に True","True の後に False","False の後に True","エラーになる（文字列にinは使えない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（in演算子）","think":"リストへのinは要素の完全一致を調べる（\"banana\"はリストにある）。文字列へのinは部分文字列として含まれるかを調べる（\"bananas\"の中に\"banana\"は含まれる）。","opt":["正解。リストへのinは要素の完全一致を調べる（\"banana\"はリストにある）。文字列へのinは部分文字列として含まれるかを調べる（\"bananas\"の中に\"banana\"は含まれる）。","文字列のinは「部分一致」で判定される。\"I like bananas\"の中に\"banana\"という並びは含まれているのでTrueになる。","リストに\"banana\"という要素はそのまま存在するのでTrue。","文字列もin演算子に対応しており、部分文字列の判定として広く使われる。"]}'),

  ('python-drill-q10', '辞書とセット',
   '出力される内容は？',
   'config = {"debug": False, "retries": 3}
config.update({"retries": 5, "timeout": 10})
removed = config.pop("debug")
print(config, removed)',
   '["{''retries'': 5, ''timeout'': 10} と False","{''debug'': False, ''retries'': 5, ''timeout'': 10} と None","{''retries'': 3, ''timeout'': 10} と False","エラーになる"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（dict.update / dict.pop）","think":".update()は既存キーの値を上書きし新しいキーを追加する。.pop(\"debug\")はそのキーを削除しつつ値を返す。","opt":["正解。.update()は既存キーの値を上書きし新しいキーを追加する。.pop(\"debug\")はそのキーを削除しつつ値を返す。",".pop(\"debug\")を実行しているので\"debug\"キーは削除された状態になる。戻り値もNoneではなく削除された値False。",".update()は同じキー\"retries\"の値を新しい値5で上書きする。古い値3のままにはならない。",".update()も.pop()も、既存のキー操作として正常に動作する。"]}'),

  ('python-drill-q11', 'リストとタプル',
   '出力される内容は？',
   'a = [1, 2]
b = [1, 2]
a.append([3, 4])
b.extend([3, 4])
print(a, b)',
   '["[1, 2, [3, 4]] と [1, 2, 3, 4]","[1, 2, 3, 4] と [1, 2, 3, 4]","[1, 2, [3, 4]] と [1, 2, [3, 4]]","どちらもエラーになる"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（list.extend vs +=）","think":".append(x)はxを「1つの要素」として丸ごと追加する（リストがネストする）。.extend(x)はxの中身を1つずつ展開して追加する。","opt":["正解。.append(x)はxを「1つの要素」として丸ごと追加する（リストがネストする）。.extend(x)はxの中身を1つずつ展開して追加する。",".append()は引数を分解せず、そのまま1つの要素として追加するのでネストしたリストになる。",".extend()は.append()と違い、渡されたリストの中身を展開して追加する。ネストしない。",".append()も.extend()もリストに対する正常なメソッド呼び出し。"]}'),

  ('python-drill-q12', 'リストとタプル',
   '出力される内容は？',
   'nums = [3, 1, 2]
result = sorted(nums)
nums.sort(reverse=True)
print(nums, result)',
   '["[3, 2, 1] [1, 2, 3]","[1, 2, 3] [1, 2, 3]","[3, 2, 1] [3, 2, 1]","エラーになる（result = sorted(nums)はNoneになる）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（list.sort vs sorted）","think":"sorted(nums)は新しいソート済みリストを「返す」だけで元のリストは変えない。nums.sort(reverse=True)は元のリスト自体を降順に書き換える（戻り値はNone）。","opt":["正解。sorted(nums)は新しいソート済みリストを「返す」だけで元のリストは変えない。nums.sort(reverse=True)は元のリスト自体を降順に書き換える（戻り値はNone）。",".sort(reverse=True)を呼んでいるのでnums自体は降順[3,2,1]に書き換わる。","resultはsorted(nums)を呼んだ「その時点」の昇順コピー。あとからnumsを変更してもresultは影響を受けない。","sorted()は組み込み関数で新しいリストを返す。Noneを返すのはリストの.sort()メソッドの方。"]}'),

  ('python-drill-q13', '文字列操作',
   '実行結果は？',
   's = "hello world"
print(s.find("z"))
print(s.index("z"))',
   '["-1 の後に ValueError","-1 の後に -1","None の後に None","両方とも ValueError"]',
   0, '[0]', 'single',
   '{"asked":"実行結果は？（str.find vs str.index）","think":".find()は見つからない場合-1を返す（例外にならない）。.index()は見つからない場合ValueErrorを送出する。","opt":["正解。.find()は見つからない場合-1を返す（例外にならない）。.index()は見つからない場合ValueErrorを送出する。",".index()は.find()と違い、見つからないと静かに-1を返さず例外を送出する設計になっている。","どちらのメソッドも見つからない場合にNoneは返さない。.find()は-1、.index()は例外。",".find()は例外を出さない設計。見つからなければ-1を返すだけで処理は続行する。"]}'),

  ('python-drill-q14', '辞書とセット',
   '出力される内容は？',
   'a = {1, 2, 3}
b = {2, 3, 4}
print(a & b, a | b, a - b)',
   '["{2, 3} {1, 2, 3, 4} {1}","{1, 2, 3, 4} {2, 3} {1}","{2, 3} {1, 2, 3, 4} {4}","エラーになる（setには演算子は使えない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（set基本）","think":"&は積集合（共通要素）、|は和集合（すべて）、-は差集合（aにあってbにないもの）。","opt":["正解。&は積集合（共通要素）、|は和集合（すべて）、-は差集合（aにあってbにないもの）。","&と|の意味が逆になっている。&は「共通部分」で{2,3}、|は「全部まとめる」で{1,2,3,4}。","a - bは「aにあってbにない要素」。4はbにあってaに無いので、これはb - aの結果。","set型は& | - ^などの集合演算子を直接サポートしている。"]}'),

  ('python-drill-q15', 'リストとタプル',
   '出力される内容は？',
   'point = (3, 4)
x, y = point
print(x, y)
a, b, c = 1, 2, 3
print(a + b + c)',
   '["3 4 の後に 6","(3, 4) の後に 6","エラーになる（要素数が変数の数と一致しないため）","3 4 の後に 123"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（tuple / アンパック）","think":"タプルや複数値をまとめて代入する「アンパック」。x,y = pointはx=3, y=4に、a,b,c=1,2,3も同様に分解代入される。","opt":["正解。タプルや複数値をまとめて代入する「アンパック」。x,y = pointはx=3, y=4に、a,b,c=1,2,3も同様に分解代入される。","x, y = pointで個別の変数xとyに分解されるので、print(x, y)はタプルそのものではなく3 4と表示される。","pointは2要素のタプルで代入先もx, yの2変数、1,2,3も3値に3変数なので数は一致しており問題なく動く。","a + b + cは数値の加算として評価されるので1+2+3=6。文字列の連結（\"1\"+\"2\"+\"3\"）ではない。"]}'),

  ('python-drill-q16', 'リストとタプル',
   '出力される内容は？',
   'nums = [1, 2, 3, 4, 5, 6]
result = [n * n for n in nums if n % 2 == 0]
print(result)',
   '["[4, 16, 36]","[1, 4, 9, 16, 25, 36]","[2, 4, 6]","エラーになる"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（リスト内包表記）","think":"[式 for 変数 in 反復 if 条件]の形。偶数(2,4,6)だけを残し、それぞれ2乗している。","opt":["正解。[式 for 変数 in 反復 if 条件]の形。偶数(2,4,6)だけを残し、それぞれ2乗している。","if n % 2 == 0で偶数だけに絞り込んでいるため、奇数(1,3,5)の2乗は結果に含まれない。","内包表記の先頭n * nが「出力する式」。単にnではなくnの2乗が結果になる。","リスト内包表記にif条件を付ける書き方は文法的に正しい。"]}'),

  ('python-drill-q17', '辞書とセット',
   '出力される内容は？',
   'words = ["a", "bb", "ccc"]
lengths = {w: len(w) for w in words}
print(lengths)',
   '["{''a'': 1, ''bb'': 2, ''ccc'': 3}","[1, 2, 3]","{1: ''a'', 2: ''bb'', 3: ''ccc''}","エラーになる（辞書に内包表記は使えない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（辞書内包表記）","think":"辞書内包表記{key式: value式 for ...}で、各単語をキー、その長さを値にした辞書を作る。","opt":["正解。辞書内包表記{key式: value式 for ...}で、各単語をキー、その長さを値にした辞書を作る。","波括弧{}でkey: valueの形を書いているので結果はリストではなく辞書になる。","キーと値の順序が逆。{w: len(w)}は「単語がキー、長さが値」という意味。","{key: value for ...}という辞書内包表記はPythonの標準文法。"]}'),

  ('python-drill-q18', '関数型プログラミング',
   '出力される内容は？',
   'people = [("Yu", 34), ("Kei", 29), ("Rio", 41)]
result = sorted(people, key=lambda p: p[1])
print(result)',
   '["[(''Kei'', 29), (''Yu'', 34), (''Rio'', 41)]","[(''Yu'', 34), (''Kei'', 29), (''Rio'', 41)]","[(''Rio'', 41), (''Yu'', 34), (''Kei'', 29)]","[(''Yu'', 34), (''Rio'', 41), (''Kei'', 29)]"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（sorted + lambda）","think":"key=lambda p: p[1]は「各要素の2番目の値（年齢）」を比較基準にすると指定している。デフォルトは昇順なので年齢の低い順に並ぶ。","opt":["正解。key=lambda p: p[1]は「各要素の2番目の値（年齢）」を比較基準にすると指定している。デフォルトは昇順なので年齢の低い順に並ぶ。","元の順序のまま。sorted()はkeyで指定した基準で並び替えを行うので、この結果は「ソートされていない」状態と同じで誤り。","これは降順の結果。デフォルトのsorted()は昇順で、降順にするにはreverse=Trueが必要。","これは名前のアルファベット順に近い並びで、年齢基準のソート結果ではない。"]}'),

  ('python-drill-q19', '関数型プログラミング',
   '出力される内容は？',
   'nums = [1, 2, 3, 4, 5]
squares = list(map(lambda x: x * x, nums))
evens = list(filter(lambda x: x % 2 == 0, nums))
print(squares, evens)',
   '["[1, 4, 9, 16, 25] [2, 4]","[1, 4, 9, 16, 25] [1, 3, 5]","&lt;map object&gt; &lt;filter object&gt; がそのまま表示される","エラーになる（lambdaはmap/filterの引数にできない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（map / filter）","think":"map(f, iterable)は各要素にfを適用した結果を返す。filter(f, iterable)はfがTrueを返す要素だけを残す。","opt":["正解。map(f, iterable)は各要素にfを適用した結果を返す。filter(f, iterable)はfがTrueを返す要素だけを残す。","filterの条件はx % 2 == 0（偶数）。奇数(1,3,5)ではなく偶数(2,4)が残る。","map()とfilter()はイテレータを返すが、それぞれlist()で包んでリスト化しているので中身が展開されて表示される。","lambdaを関数として渡すのはmapやfilterの典型的な使い方で、正常に動作する。"]}'),

  ('python-drill-q20', '関数型プログラミング',
   '最初に出力される行は？',
   'names = ["a", "b", "c"]
scores = [90, 80, 70]
for i, (n, s) in enumerate(zip(names, scores)):
    print(i, n, s)',
   '["0 a 90","1 a 90","0 90 a","エラーになる（enumerateとzipは組み合わせられない）"]',
   0, '[0]', 'single',
   '{"asked":"最初に出力される行は？（zip / enumerate）","think":"zip(names, scores)は(\"a\",90),(\"b\",80),(\"c\",70)のペアを作り、enumerate()がそれぞれに0始まりの連番を付ける。最初の要素は(0, (\"a\", 90))を分解した形。","opt":["正解。zip(names, scores)は(\"a\",90),(\"b\",80),(\"c\",70)のペアを作り、enumerate()がそれぞれに0始まりの連番を付ける。最初の要素は(0, (\"a\", 90))を分解した形。","enumerate()のインデックスはデフォルトで0から始まる。1から始めたい場合はenumerate(x, start=1)が必要。","zip(names, scores)の順序は引数の順序どおり。先に渡したnamesの値が先に来るのでnが先、sが後。","enumerate(zip(...))はどちらもイテレータを返す関数どうしの組み合わせで、よく使われる正常なパターン。"]}'),

  ('python-drill-q21', '関数と引数',
   '出力される内容は？',
   'def summarize(*args, **kwargs):
    print(args, kwargs)

summarize(1, 2, name="Yu", age=34)',
   '["(1, 2) {''name'': ''Yu'', ''age'': 34}","[1, 2] [''name'', ''Yu'', ''age'', 34]","1 2 Yu 34","エラーになる（位置引数とキーワード引数は混在できない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（*args / **kwargs）","think":"*argsは位置引数をタプルとして、**kwargsはキーワード引数を辞書として受け取る。","opt":["正解。*argsは位置引数をタプルとして、**kwargsはキーワード引数を辞書として受け取る。","*argsが集めるのはリストではなく「タプル」。**kwargsもリストではなく「辞書」になる。","argsとkwargsはそれぞれタプルと辞書のオブジェクトとして丸ごとprintされるので、バラバラの値としては表示されない。","*args, **kwargsを両方定義すれば、位置引数とキーワード引数を同時に受け取ることができる。"]}'),

  ('python-drill-q22', '関数と引数',
   '出力される内容は？',
   'def add_item(item, bucket=[]):
    bucket.append(item)
    return bucket

print(add_item("x"))
print(add_item("y"))',
   '["[''x''] の後に [''x'', ''y'']","[''x''] の後に [''y'']","両方とも [''x'', ''y'']","エラーになる"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（ミュータブルなデフォルト引数の罠）","think":"デフォルト引数のリストは「関数定義時に1回だけ」作られ、呼び出しをまたいで使い回される。2回目の呼び出しでも同じbucketを参照しているため、''x''が残ったまま''y''が追加される。","opt":["正解。デフォルト引数のリストは「関数定義時に1回だけ」作られ、呼び出しをまたいで使い回される。2回目の呼び出しでも同じbucketを参照しているため、''x''が残ったまま''y''が追加される。","直感的には「毎回空リストから始まる」ように見えるが、Pythonのデフォルト引数は関数定義時に一度だけ評価されるため、呼び出しごとにリセットされない有名な罠。","1回目の呼び出し時点ではまだ''y''は追加されていないので、1回目の出力は[''x'']のみ。","この書き方は文法的にもエラーにはならない — むしろ「エラーにならず静かに意図と違う挙動をする」点が罠になっている。"]}'),

  ('python-drill-q23', 'オブジェクトの同一性とコピー',
   '出力される内容は？',
   'a = [1, 2, 3]
b = [1, 2, 3]
c = a
print(a == b, a is b, a is c)',
   '["True False True","True True True","True False False","False False True"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（is と == の違い）","think":"==は「値が等しいか」を比較する（内容が同じなのでTrue）。isは「同一オブジェクトか」を比較する。bは別のオブジェクトなのでFalse、cはaそのものを指しているのでTrue。","opt":["正解。==は「値が等しいか」を比較する（内容が同じなのでTrue）。isは「同一オブジェクトか」を比較する。bは別のオブジェクトなのでFalse、cはaそのものを指しているのでTrue。","aとbは値が同じでも別々に作られた「別のリストオブジェクト」。isで比較すると同一性はFalseになる。","c = aは「aと同じオブジェクトを指す」代入なので、a is cはTrueになる。新しいコピーを作っているわけではない。","aとbは中身の要素がすべて同じなので==比較はTrueになる。"]}'),

  ('python-drill-q24', 'オブジェクトの同一性とコピー',
   '出力される内容は？',
   'import copy
original = [[1, 2], [3, 4]]
shallow = original.copy()
shallow[0].append(99)
print(original)',
   '["[[1, 2, 99], [3, 4]]","[[1, 2], [3, 4]]（変更されない）","エラーになる","[[1, 2], [3, 4, 99]]"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（浅いコピー（copy）の罠）","think":".copy()は「浅い」コピーで、外側のリストは新しく作られるが、内部のリスト（[1,2]など）は元と同じオブジェクトを参照し続ける。そのためshallow[0]への変更がoriginal[0]にも反映される。","opt":["正解。.copy()は「浅い」コピーで、外側のリストは新しく作られるが、内部のリスト（[1,2]など）は元と同じオブジェクトを参照し続ける。そのためshallow[0]への変更がoriginal[0]にも反映される。","浅いコピーは内側のリストまでは複製しない。完全に独立させたい場合はcopy.deepcopy()を使う必要がある。",".copy()もその後の.append()も文法的・実行的に正常な操作。","変更したのはshallow[0]（1つ目の内側リスト）。2つ目の内側リスト[3,4]には影響しない。"]}'),

  ('python-drill-q25', 'ジェネレータとメモリ',
   'この2つの書き方（genとlst）の違いとして正しいものは？',
   'nums = range(1000000)
gen = (n * 2 for n in nums)
lst = [n * 2 for n in nums]',
   '["genは値を必要になるまで計算しないため省メモリ、lstは全要素を即座にメモリ上へ展開する","どちらも即座に100万個の要素をメモリに展開するため差はない","genの方は文法エラーになる（丸括弧の内包表記は存在しない）","lstの方が省メモリで、genの方がメモリを多く使う"]',
   0, '[0]', 'single',
   '{"asked":"この2つの書き方（genとlst）の違いとして正しいものは？（ジェネレータ式とメモリ）","think":"丸括弧()で書くとジェネレータ式になり、要素は1つずつ遅延評価される。角括弧[]のリスト内包表記は全要素をすぐに計算してメモリに保持する。","opt":["正解。丸括弧()で書くとジェネレータ式になり、要素は1つずつ遅延評価される。角括弧[]のリスト内包表記は全要素をすぐに計算してメモリに保持する。","ジェネレータ式は「必要なときに1つずつ」計算する遅延評価が最大の特徴で、リスト内包表記とはメモリ使用量が大きく異なる。","丸括弧()を使った内包表記は「ジェネレータ式」というPython標準の書き方。","実際は逆。lstは全要素を保持するのでメモリを多く使い、genは都度計算するので省メモリ。"]}'),

  ('python-drill-q26', '関数型プログラミング',
   '出力される内容は？',
   'data = [1, 2, 3, 4, 5, 6]
result = [y for x in data if (y := x * 2) > 6]
print(result)',
   '["[8, 10, 12]","[8, 10, 12, 14]のようにdata全要素分の2倍が入る","エラーになる（内包表記のif文の中で代入はできない）","[7, 9, 11, 13]"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（walrus演算子 :=）","think":":=（walrus演算子）は条件式の中で変数yにx*2を代入しつつ、その値を使って判定もできる。yが6より大きいのはx=4,5,6のとき（y=8,10,12）。","opt":["正解。:=（walrus演算子）は条件式の中で変数yにx*2を代入しつつ、その値を使って判定もできる。yが6より大きいのはx=4,5,6のとき（y=8,10,12）。","条件(y := x*2) > 6を満たさない要素（x=1,2,3のときy=2,4,6でいずれも6以下）は結果に含まれない。","walrus演算子はPython 3.8以降で導入され、if条件式の中で「代入しながら評価する」ことを可能にする正式な構文。","yはxそのものではなくx * 2の値。生成される数はすべて偶数になる。"]}'),

  ('python-drill-q27', 'リストとタプル',
   '出力される内容は？',
   'scores = [95, 60, 70, 85, 40]
first, *middle, last = scores
print(first, middle, last)',
   '["95 [60, 70, 85] 40","95 (60, 70, 85) 40","エラーになる（変数の数がリストの要素数と一致しない）","95 [60] 40"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（アンパックと*rest）","think":"*middleは「残り全部」をリストとしてまとめて受け取る。firstが先頭、lastが末尾、それ以外がmiddleに入る。","opt":["正解。*middleは「残り全部」をリストとしてまとめて受け取る。firstが先頭、lastが末尾、それ以外がmiddleに入る。","*変数でまとめて受け取った部分は「タプル」ではなく「リスト」になる。","*を付けた変数は「余った要素をまとめて受け取る」ので、要素数がぴったり一致しなくても正常に動く。","*middleは先頭と末尾を除いた「残り全部」を受け取る。60だけでなく70,85も含まれる。"]}'),

  ('python-drill-q28', '制御構文と真偽値',
   '出力される内容は？',
   'nums = [2, 4, 6, 7, 8]
print(all(n % 2 == 0 for n in nums))
print(any(n > 10 for n in nums))',
   '["False の後に False","True の後に False","False の後に True","エラーになる（all/allにジェネレータ式は渡せない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（any / all）","think":"all()は全要素が条件を満たす場合のみTrue。7が奇数なのでFalse。any()はいずれか1つでも条件を満たせばTrueだが、10より大きい要素は無いのでFalse。","opt":["正解。all()は全要素が条件を満たす場合のみTrue。7が奇数なのでFalse。any()はいずれか1つでも条件を満たせばTrueだが、10より大きい要素は無いのでFalse。","リストには奇数の7が含まれているため、all(n % 2 == 0 ...)は全要素が偶数という条件を満たさずFalseになる。","リストの最大値は8で、10より大きい要素は存在しないためany(n > 10 ...)はFalseになる。","all()とany()はイテラブルを受け取る組み込み関数で、ジェネレータ式を直接渡すのはごく一般的な使い方。"]}'),

  ('python-drill-q29', '制御構文と真偽値',
   '出力される内容は？',
   'def label(score):
    return "pass" if score >= 60 else "fail"

print([label(s) for s in [40, 60, 80]])',
   '["[''fail'', ''pass'', ''pass'']","[''fail'', ''fail'', ''pass'']","エラーになる（if-elseを1行で書くことはできない）","[''fail'', ''pass'', ''pass'']ではなく順序が逆になる"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（三項演算子（条件式））","think":"A if 条件 else Bは条件式（三項演算子）。60未満は\"fail\"、60以上は\"pass\"。境界値の60は「60 >= 60」でTrue側＝\"pass\"になる。","opt":["正解。A if 条件 else Bは条件式（三項演算子）。60未満は\"fail\"、60以上は\"pass\"。境界値の60は「60 >= 60」でTrue側＝\"pass\"になる。","境界値60の判定に注意。条件はscore >= 60（60を「含む」）なので、60はfailではなくpass側に入る。","値A if 条件 else 値Bという条件式は正式なPython文法で、1行で条件分岐の値を作れる。","リスト内包表記は[40, 60, 80]の順序どおりに処理するため、結果の順序も入力と同じ。"]}'),

  ('python-drill-q30', '文字列操作',
   '出力される内容は？',
   'line = "-" * 5
msg = "py" + "thon"
print(line, msg)',
   '["----- python","5 python","エラーになる（文字列に*は使えない）","----- pythonではなく-*5 pythonと表示される"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（文字列の乗算・連結）","think":"文字列に対する*は「繰り返し連結」、+は「連結」。\"-\" * 5は-を5回繰り返し、\"py\" + \"thon\"はそのままつながる。","opt":["正解。文字列に対する*は「繰り返し連結」、+は「連結」。\"-\" * 5は-を5回繰り返し、\"py\" + \"thon\"はそのままつながる。","数値の掛け算と混同している。文字列に対する*は数値化ではなく「繰り返し」の意味になる。","文字列と整数の*は「繰り返し」として定義された正式な演算。","*は実行前にPythonが評価する演算子であり、記号がそのまま文字として出力されることはない。"]}'),

  ('python-drill-q31', 'リストとタプル',
   '出力される内容は？',
   'grid = [[1, 2], [3, 4], [5, 6]]
print(grid[1][0])
print(len(grid))',
   '["3 の後に 3","2 の後に 6","3 の後に 6","エラーになる（二重の角括弧は使えない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（ネストしたリストへのアクセス）","think":"grid[1]は2番目の内側リスト[3, 4]、さらに[0]でその先頭要素3を取る。len(grid)は外側のリストの要素数（3つの内側リスト）。","opt":["正解。grid[1]は2番目の内側リスト[3, 4]、さらに[0]でその先頭要素3を取る。len(grid)は外側のリストの要素数（3つの内側リスト）。","これはgrid[0][1]（1番目のリストの2番目）と、全要素数を数えた場合の値。今回聞かれているのは違う位置とlen。","len(grid)は「外側のリストの長さ」を返す。中身の数値をすべて数えた個数（6個）ではない。","ネストしたリストへの[i][j]アクセスはPythonで一般的な書き方で、正常に動作する。"]}'),

  ('python-drill-q32', '制御構文と真偽値',
   '出力される内容は？',
   'values = [0, 1, "", "a", [], [1], None]
for v in values:
    print(bool(v), end=" ")',
   '["False True False True False True False","True True True True True True True","False True False True True True False","エラーになる（0や空文字にboolは使えない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（bool変換とtruthy/falsy）","think":"0・空文字\"\"・空リスト[]・Noneはfalsy（Falseとして扱われる）。それ以外の非ゼロ・非空の値はtruthy。","opt":["正解。0・空文字\"\"・空リスト[]・Noneはfalsy（Falseとして扱われる）。それ以外の非ゼロ・非空の値はtruthy。","0や空文字、空リスト、Noneなど「空・ゼロ・None」はPythonでは自動的にFalseとして扱われる。すべてTrueにはならない。","空リスト[]もfalsyの一員。要素が入っていない[]はbool([])でFalseになる。","bool()はどんな値も受け取れる組み込み関数で、値の「真偽らしさ」を判定する。"]}'),

  ('python-drill-q33', '制御構文と真偽値',
   '出力される内容は？',
   'i = 0
while i < 6:
    i += 1
    if i % 2 == 0:
        continue
    if i == 5:
        break
    print(i, end=" ")',
   '["1 3","1 3 5","1 2 3 4 5","無限ループになる"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（while文とbreak/continue）","think":"i=1で偶数でないので print(1)。i=2は偶数なのでcontinueでprintをスキップ。i=3で print(3)。i=4はcontinue。i=5でbreakするのでprintされる前にループを抜ける。","opt":["正解。i=1で偶数でないので print(1)。i=2は偶数なのでcontinueでprintをスキップ。i=3で print(3)。i=4はcontinue。i=5でbreakするのでprintされる前にループを抜ける。","i=5になった時点でif i == 5: breakがprintより先に実行されループを抜けるため、5は出力されない。","偶数のときcontinueでprint行がスキップされるため、2や4は出力されない。","毎回i += 1でiが増加し、i == 5でbreakする条件があるため、ループは必ず終了する。"]}'),

  ('python-drill-q34', '関数と引数',
   '出力される内容は？',
   'def greet(name, greeting="Hi"):
    return f"{greeting}, {name}!"

print(greet("Yu"))
print(greet("Yu", "Hello"))',
   '["Hi, Yu! の後に Hello, Yu!","Hi, Yu! の後に Hi, Yu!","エラーになる（1回目は引数が足りない）","Hello, Yu! の後に Hi, Yu!"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（関数のデフォルト引数）","think":"greetingにはデフォルト値\"Hi\"が設定されているので、省略すればそれが使われる。明示的に渡せばその値で上書きされる。","opt":["正解。greetingにはデフォルト値\"Hi\"が設定されているので、省略すればそれが使われる。明示的に渡せばその値で上書きされる。","2回目の呼び出しでは\"Hello\"を明示的に渡しているので、デフォルト値の\"Hi\"ではなく\"Hello\"が使われる。","greetingにはデフォルト値があるため省略可能。greet(\"Yu\")は正常に呼び出せる。","呼び出しの順序が逆。最初の呼び出しはデフォルト値\"Hi\"を使い、2番目で明示的な\"Hello\"を使う。"]}'),

  ('python-drill-q35', '辞書とセット',
   '出力される内容は？',
   'words = ["apple", "banana", "avocado", "kiwi"]
first_letters = {w[0] for w in words}
print(first_letters)',
   '["{''a'', ''b'', ''k''}","[''a'', ''b'', ''a'', ''k'']","{''a'', ''b'', ''a'', ''k''}","エラーになる（波括弧の内包表記はdict専用）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（集合内包表記）","think":"集合内包表記{式 for ...}はset（重複しない集合）を作る。\"apple\"と\"avocado\"は同じ頭文字''a''なので重複が自動的にまとめられる。","opt":["正解。集合内包表記{式 for ...}はset（重複しない集合）を作る。\"apple\"と\"avocado\"は同じ頭文字''a''なので重複が自動的にまとめられる。","波括弧{}で書いているのでリストではなくset。setは重複を持たないため''a''は1つにまとまる。","set自体が数学的な集合であり、同じ値''a''を2つ持つことはできない。表示上も重複は消える。","波括弧{}の内包表記は、key: value形式なら辞書、単一の式ならsetになる。今回は単一式なのでset内包表記。"]}'),

  ('python-drill-q36', '辞書とセット',
   '出力される内容は？',
   'from collections import Counter
words = ["a", "b", "a", "c", "b", "a"]
count = Counter(words)
print(count.most_common(2))',
   '["[(''a'', 3), (''b'', 2)]","[''a'', ''b'']","{''a'': 3, ''b'': 2, ''c'': 1}","エラーになる（Counterはリストを受け取れない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（collections.Counter）","think":"Counterは各要素の出現回数を数える。.most_common(2)は出現回数の多い順に上位2件を(値, 回数)のタプルで返す。\"a\"は3回、\"b\"は2回で最多。","opt":["正解。Counterは各要素の出現回数を数える。.most_common(2)は出現回数の多い順に上位2件を(値, 回数)のタプルで返す。\"a\"は3回、\"b\"は2回で最多。",".most_common()は値だけのリストではなく、「値と出現回数のペア」のタプルのリストを返す。","これはCounterそのものの中身に近いが、.most_common(2)は「上位2件だけ」をタプルのリストとして返す点が異なる。","Counter()はリストなどのイテラブルを受け取り、要素の出現回数を数えるのが標準的な使い方。"]}'),

  ('python-drill-q37', '辞書とセット',
   '出力される内容は？',
   'from collections import defaultdict
groups = defaultdict(list)
for word in ["ant", "bee", "ape", "bat"]:
    groups[word[0]].append(word)
print(dict(groups))',
   '["{''a'': [''ant'', ''ape''], ''b'': [''bee'', ''bat'']}","エラーになる（存在しないキーに.append()はできない）","{''a'': [''ant''], ''b'': [''bee''], ''a'': [''ape''], ''b'': [''bat'']}のように毎回新しいキーが増える","{''a'': 2, ''b'': 2}"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（collections.defaultdict）","think":"defaultdict(list)は存在しないキーへのアクセス時に自動で空リストを作る。そのためKeyErrorを気にせず.append()で頭文字ごとにグループ化できる。","opt":["正解。defaultdict(list)は存在しないキーへのアクセス時に自動で空リストを作る。そのためKeyErrorを気にせず.append()で頭文字ごとにグループ化できる。","通常のdictならKeyErrorになるが、defaultdict(list)はキーが無いとき自動的に空リストを用意するため、そのままappendできる。","辞書は同じキーを複数持てない。同じ頭文字は同じキーの下に集約され、値のリストに追加されていく。","defaultdict(list)の各値は個数ではなく「リスト」。実際の単語そのものが格納される。"]}'),

  ('python-drill-q38', '関数型プログラミング',
   '出力される内容は？',
   'from itertools import chain
a = [1, 2]
b = (3, 4)
c = "56"
print(list(chain(a, b, c)))',
   '["[1, 2, 3, 4, ''5'', ''6'']","[[1, 2], (3, 4), ''56'']","エラーになる（型の違うイテラブルは連結できない）","[1, 2, 3, 4, 56]"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（itertools.chain）","think":"chain()は複数のイテラブルを1つにつなげて順番に走査する。リスト・タプル・文字列いずれもイテラブルなので、要素単位で連結される（文字列は1文字ずつ）。","opt":["正解。chain()は複数のイテラブルを1つにつなげて順番に走査する。リスト・タプル・文字列いずれもイテラブルなので、要素単位で連結される（文字列は1文字ずつ）。","chain()は各イテラブルをそのまま並べるのではなく、「中身を1つずつ展開して」1本のイテレータにする。","chain()は型を問わず、イテラブルであれば何でも連結できる。リスト・タプル・文字列の混在も問題ない。","文字列\"56\"は数値の56に変換されるのではなく、1文字ずつの''5''と''6''として展開される。"]}'),

  ('python-drill-q39', '例外処理',
   '出力される順番は？',
   'def check(n):
    try:
        result = 10 / n
    except ZeroDivisionError:
        print("zero!")
    else:
        print("ok:", result)
    finally:
        print("done")

check(2)',
   '["ok: 5.0 → done","zero! → done","ok: 5.0のみ（finallyは実行されない）","done → ok: 5.0"]',
   0, '[0]', 'single',
   '{"asked":"出力される順番は？（try/except/else/finally）","think":"nが2なので例外は発生しない。exceptはスキップされ、正常終了時のみ実行されるelseブロックの\"ok: 5.0\"が出力され、最後に必ず実行されるfinallyの\"done\"が続く。","opt":["正解。nが2なので例外は発生しない。exceptはスキップされ、正常終了時のみ実行されるelseブロックの\"ok: 5.0\"が出力され、最後に必ず実行されるfinallyの\"done\"が続く。","except ZeroDivisionErrorはゼロ除算のときだけ実行される。check(2)は0で割っていないのでこのブロックは実行されない。","finallyブロックは例外の有無にかかわらず「必ず」実行される。","finallyは全ての処理の「最後」に実行される。elseの方が先に評価される。"]}'),

  ('python-drill-q40', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class Counter:
    def __init__(self, start=0):
        self.value = start

    def increment(self):
        self.value += 1
        return self.value

c = Counter()
print(c.increment(), c.increment())',
   '["1 2","0 1","1 1","エラーになる（Counter()に引数がない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（クラスの基本）","think":"Counter()でvalue=0のインスタンスが作られる。.increment()を呼ぶたびにself.valueが1増えてその値を返すので、1回目は1、2回目は2になる。","opt":["正解。Counter()でvalue=0のインスタンスが作られる。.increment()を呼ぶたびにself.valueが1増えてその値を返すので、1回目は1、2回目は2になる。","increment()は値を増やしてからself.valueを返す（先に+1してから返す）ので、最初の呼び出しから1が返る。0が返ることはない。","self.valueはインスタンス変数として状態を保持し続けるため、2回目の呼び出しでは1回目の結果（1）にさらに1が足された2になる。","start=0というデフォルト引数があるため、引数なしでCounter()を呼び出しても正常にインスタンス化できる。"]}'),

  ('python-drill-q41', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'def shout(func):
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return result.upper()
    return wrapper

@shout
def greet(name):
    return f"hello, {name}"

print(greet("yu"))',
   '["HELLO, YU","hello, yu","エラーになる（デコレータ付きの関数に引数は渡せない）","&lt;function wrapper at ...&gt;という関数オブジェクトが表示される"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（デコレータ）","think":"@shoutはgreet = shout(greet)と同じ意味。greet(\"yu\")を呼ぶと実際にはwrapperが実行され、元のgreetの結果を大文字化してから返す。","opt":["正解。@shoutはgreet = shout(greet)と同じ意味。greet(\"yu\")を呼ぶと実際にはwrapperが実行され、元のgreetの結果を大文字化してから返す。","デコレータ@shoutが適用されているため、元のgreet関数がそのまま呼ばれるのではなく、wrapperを経由して結果が大文字化される。","wrapper(*args, **kwargs)が任意の引数を受け取って元の関数へ渡しているため、引数付きの呼び出しも問題なく動く。","greet(\"yu\")は関数を「呼び出して」いるので、返ってくるのは関数オブジェクトではなく実行結果の文字列。"]}'),

  ('python-drill-q42', 'ジェネレータとメモリ',
   '出力される内容は？',
   'def countdown(n):
    while n > 0:
        yield n
        n -= 1

gen = countdown(3)
print(next(gen))
print(next(gen))
print(list(gen))',
   '["3 → 2 → [1]","3 → 2 → [3, 2, 1]","[1, 2, 3] → [1, 2, 3] → [1, 2, 3]","エラーになる（yieldとwhileは併用できない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（ジェネレータ関数とyield）","think":"yieldを含む関数はジェネレータを返す。next()を呼ぶたびに直前のyieldから再開して次の値まで実行される。1回目で3、2回目で2を消費し、残りは1だけなのでlist(gen)は[1]。","opt":["正解。yieldを含む関数はジェネレータを返す。next()を呼ぶたびに直前のyieldから再開して次の値まで実行される。1回目で3、2回目で2を消費し、残りは1だけなのでlist(gen)は[1]。","next()を呼ぶたびにジェネレータの内部状態は「先に進んで」しまう。一度消費した3と2はlist(gen)では戻ってこない。","ジェネレータは呼び出すたびに全体を再計算するリストではなく、状態を保持しながら1つずつ値を生成する「使い切り」のイテレータ。","yieldはループの中で複数回使うのが一般的なパターンで、whileとの併用に制約はない。"]}'),

  ('python-drill-q43', 'クラスとオブジェクト指向',
   '出力される順番は？',
   'class Resource:
    def __enter__(self):
        print("open")
        return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        print("close")
        return False

with Resource():
    print("using")',
   '["open → using → close","using → open → close","open → using（closeは呼ばれない）","エラーになる（クラスをwith文に使うには特別な継承が必要）"]',
   0, '[0]', 'single',
   '{"asked":"出力される順番は？（コンテキストマネージャ（with文））","think":"with文はブロックに入るときに__enter__を、ブロックを抜けるとき（正常終了でも例外でも）に__exit__を必ず呼ぶ。","opt":["正解。with文はブロックに入るときに__enter__を、ブロックを抜けるとき（正常終了でも例外でも）に__exit__を必ず呼ぶ。","__enter__はwithブロックの「中身が実行される前」に必ず呼ばれる。ブロック内の処理より先に来る。","__exit__はwithブロックを抜けるときに、例外の有無にかかわらず必ず呼ばれる。","特別な継承は不要。__enter__と__exit__という2つのメソッドを定義するだけで、どんなクラスでもwith文に対応できる。"]}'),

  ('python-drill-q44', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'def make_multiplier(factor):
    def multiply(x):
        return x * factor
    return multiply

double = make_multiplier(2)
triple = make_multiplier(3)
print(double(5), triple(5))',
   '["10 15","15 15","エラーになる（内側の関数は外側の変数にアクセスできない）","10 15ではなく毎回同じ関数を参照するため&lt;function&gt;が表示される"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（クロージャ）","think":"multiplyは外側の関数の変数factorを「覚えたまま」返される（クロージャ）。doubleはfactor=2を、tripleはfactor=3を覚えているので、それぞれ独立して計算される。","opt":["正解。multiplyは外側の関数の変数factorを「覚えたまま」返される（クロージャ）。doubleはfactor=2を、tripleはfactor=3を覚えているので、それぞれ独立して計算される。","doubleとtripleは別々の呼び出しで作られた別々のクロージャで、それぞれ異なるfactorの値を保持している。同じ値に上書きされることはない。","内側の関数は外側の関数のローカル変数を参照できる（クロージャ）。これはPythonの正式な仕様でエラーにはならない。","double(5)は関数を呼び出しているので、返ってくるのは関数オブジェクトではなく計算結果の数値。"]}'),

  ('python-drill-q45', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'def make_counter():
    count = 0
    def increment():
        nonlocal count
        count += 1
        return count
    return increment

c = make_counter()
print(c(), c(), c())',
   '["1 2 3","1 1 1","エラーになる（UnboundLocalError）","0 1 2"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（nonlocal）","think":"nonlocal countを宣言すると、内側の関数から外側の関数のローカル変数countを「書き換え」られるようになる。呼ぶたびに前回の値が引き継がれ増えていく。","opt":["正解。nonlocal countを宣言すると、内側の関数から外側の関数のローカル変数countを「書き換え」られるようになる。呼ぶたびに前回の値が引き継がれ増えていく。","nonlocalが無ければ内側でcountを書き換えようとしてエラーになるところだが、正しく宣言されているので毎回値が引き継がれ増加する。","nonlocalを宣言しなかった場合にこのエラーが起きる。今回は正しく宣言されているのでエラーは起きない。","count += 1を実行してからreturn countするため、最初の呼び出しから加算後の値である1が返る。"]}'),

  ('python-drill-q46', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class Temperature:
    unit = "C"

    @classmethod
    def describe(cls):
        return f"unit is {cls.unit}"

    @staticmethod
    def to_fahrenheit(c):
        return c * 9 / 5 + 32

print(Temperature.describe())
print(Temperature.to_fahrenheit(20))',
   '["unit is C の後に 68.0","エラーになる（インスタンスを作らないとメソッドは呼べない）","unit is cls.unit の後に 68.0","unit is C の後に 36.0"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（staticmethod / classmethod）","think":"@classmethodは第一引数に「クラス自身(cls)」を自動で受け取り、クラス変数にアクセスできる。@staticmethodはselfもclsも受け取らない普通の関数で、渡した引数だけで計算する。20*9/5+32=68.0。","opt":["正解。@classmethodは第一引数に「クラス自身(cls)」を自動で受け取り、クラス変数にアクセスできる。@staticmethodはselfもclsも受け取らない普通の関数で、渡した引数だけで計算する。20*9/5+32=68.0。","@classmethodと@staticmethodはどちらも「インスタンスを作らずに」クラス名から直接呼び出せるのが特徴。","f-string内の{cls.unit}は文字列としてではなく式として評価されるため、実際の値である\"C\"に置き換わって表示される。","華氏変換の式はc * 9 / 5 + 32。20 * 9 / 5は36だが、そこにさらに32を足す必要があるため68.0が正しい。"]}'),

  ('python-drill-q47', '例外処理',
   '出力される内容は？',
   'def parse(value):
    try:
        return int(value)
    except ValueError as e:
        raise RuntimeError("parse failed") from e

try:
    parse("abc")
except RuntimeError as err:
    print(type(err).__name__, "<-", type(err.__cause__).__name__)',
   '["RuntimeError &lt;- ValueError","ValueError &lt;- RuntimeError","RuntimeError &lt;- None","エラーになる（例外の中で新しい例外を送出できない）"]',
   0, '[0]', 'single',
   '{"asked":"出力される内容は？（例外の連鎖（raise ... from））","think":"raise X from eは新しい例外Xを送出しつつ、元の例外eを__cause__として保持する。ここでは元のValueErrorがRuntimeErrorの原因として記録される。","opt":["正解。raise X from eは新しい例外Xを送出しつつ、元の例外eを__cause__として保持する。ここでは元のValueErrorがRuntimeErrorの原因として記録される。","実際に外側のexceptで捕まえているのは新しく送出されたRuntimeError。__cause__の方が元のValueErrorになる。","from eを明示的に指定しているため、__cause__にはNoneではなく元のValueErrorインスタンスが記録される。","exceptブロックの中から別の例外をraiseするのは正式な文法で、元の例外情報を保ったまま新しい例外に変換する一般的なパターン。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'python-drill'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;