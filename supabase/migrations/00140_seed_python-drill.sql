BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('スコープとクロージャ', '#79c0ff', 10),
  ('デコレータとコンテキストマネージャ', '#f0883e', 11)
) AS v(name, color, sort_order)
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

  ('python-drill-q48', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

p1 = Point(1, 2)
p2 = Point(1, 2)
p3 = p1
print(id(p1) == id(p2), id(p1) == id(p3))',
   '["False True", "True True", "True False", "エラーになる（id()はカスタムクラスのインスタンスには使えない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（id()とオブジェクトの同一性）", "point": "id()は「メモリ上の置き場所（同一性）」を返す。値が同じでも別々に作ったオブジェクトはid()が異なり、代入でコピーした変数は同じid()になる。", "why_asked": "「同じ値だから同じもの」という思い込みでオブジェクトを書き換えると、意図しない箇所まで変わってしまう。id()やisで同一性を確認できることを知らないと、バグの原因を追えない。", "kid": "p1とp2は同じ値(x=1,y=2)を持つけど、別々に作った2つの箱。p3はp1そのものを指す別名なので、p1とp3は同じ箱を指している。", "eg": "同じ住所に見える家を新しく2軒建てても別の家であるのに対し、「実家」と「じいちゃんの家」が同じ1軒を指す呼び名なら、それは同一の家を指している、というようなもの。", "terms": [["id()", "オブジェクトが置かれているメモリ上の場所を表す一意な整数値を返す組み込み関数"], ["Point(1, 2)", "同じ引数で呼んでも、呼ぶたびに新しいインスタンス（別オブジェクト）が作られる"], ["p3 = p1", "新しいオブジェクトを作らず、p1と同じオブジェクトを指す別名（参照）を作るだけの代入"]], "think": "1〜2行目でPoint(1,2)がp1に対して1回、p2に対してもう1回呼ばれる。呼ぶたびに新しいオブジェクトが作られるので、値が同じでもp1とp2は別のオブジェクト。id(p1) == id(p2)はFalse。4行目のp3 = p1はp1と同じオブジェクトを指すだけなので、id(p1) == id(p3)はTrue。", "vs": "==は値が等しいかを比較し、is（やid()同士の比較）はメモリ上の同一オブジェクトかを比較する。p1 == p2は値が同じなのでTrueになるが、id(p1)==id(p2)（実質p1 is p2と同じ意味）はFalseになる、という食い違いに注意。", "opt": ["正解。Point(1,2)はp1用とp2用でそれぞれ新しいインスタンスが作られるので値が同じでも別オブジェクト（id()が異なりFalse）。p3 = p1はp1と同じオブジェクトを指すだけなのでid()は一致しTrueになる。", "値が同じだからといって同じオブジェクトとは限らない。Point(1,2)はp1とp2それぞれのために別々に作られたインスタンスなので、id()は異なる。", "p3 = p1は新しいオブジェクトを作る操作ではなく、p1と同じオブジェクトへの別名を作るだけ。だからp1とp3のid()は一致する。", "id()はどんなオブジェクトにも使える組み込み関数。カスタムクラスのインスタンスであっても問題なくメモリ上の識別値を返す。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><rect x=\"20\" y=\"20\" width=\"46\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"43.0\" y=\"38.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">p1</text><rect x=\"20\" y=\"58\" width=\"46\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"43.0\" y=\"76.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">p2</text><rect x=\"20\" y=\"96\" width=\"46\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"43.0\" y=\"114.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">p3</text><rect x=\"190\" y=\"15\" width=\"130\" height=\"38\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"255.0\" y=\"31.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">Point(1, 2)</text><text x=\"255.0\" y=\"44.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">id = A</text><rect x=\"190\" y=\"88\" width=\"130\" height=\"38\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"255.0\" y=\"104.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">Point(1, 2)</text><text x=\"255.0\" y=\"117.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">id = B</text><line x1=\"66\" y1=\"34\" x2=\"188\" y2=\"32\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"66\" y1=\"110\" x2=\"188\" y2=\"40\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"66\" y1=\"72\" x2=\"188\" y2=\"107\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><text x=\"255\" y=\"60\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">p1 と p3 は同じ箱 / p2 は別の箱</text></svg>"}'),

  ('python-drill-q49', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'a = [1, 2, 3]
b = a
c = a[:]
b.append(4)
c.append(5)
print(a, c)',
   '["[1, 2, 3, 4] [1, 2, 3, 5]", "[1, 2, 3, 4, 5] [1, 2, 3, 4, 5]", "[1, 2, 3] [1, 2, 3, 5]", "エラーになる（一度別名(b=a)を作った変数に対して、別の変数からスライスコピー(a[:])を取ることはできない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（b = a と c = a[:] の違い）", "point": "b = aは同じリストへの別名（参照渡し）、a[:]は独立した新しいリストを作るコピー。前者への変更は元に響き、後者への変更は響かない。", "why_asked": "「= で代入すればコピーされる」という思い込みは非常に多い。関数に渡したリストを書き換えるとき、意図せず呼び出し元まで変わってしまう根本原因がここにある。", "kid": "b = aはaと全く同じ箱を指すただの別名なので、bをいじるとaも変わる。c = a[:]はaの中身を新しい別の箱にコピーするので、cをいじってもaは変わらない。", "eg": "b = aは「実家」と呼び方を変えただけで家そのものは1軒しかないのと同じ。a[:]は実家の中身を新しい別の家にそっくり引っ越したようなもので、新しい家をいじっても元の実家は変わらない。", "terms": [["b = a", "新しいリストを作らず、aと同じリストを指す別名を作る代入"], ["a[:]", "先頭から末尾までをスライスして、中身が同じ新しいリストを作るコピー"], [".append(x)", "リストの末尾にxを追加する破壊的メソッド"]], "think": "1行目でa=[1,2,3]。2行目b=aでbはaと同じリストを指す。3行目c=a[:]でcは中身が同じだが別の新しいリスト。4行目b.append(4)はbが指すリスト（aと同じ）に4を追加するので、aも[1,2,3,4]になる。5行目c.append(5)はcという別のリストに5を追加するだけなので、aには影響しない。よってprint(a, c)は[1,2,3,4]と[1,2,3,5]。", "vs": "見た目は同じ「変数 = 何か」型の代入でも、b = aは「同じリストを指す別名」、c = a[:]は「新しいリストを作るコピー」で全く別の挙動になる。list(a)やa.copy()もa[:]と同じく新しいリストを作るコピーになる。", "opt": ["正解。b = aはaと同じリストへの別名なのでb.append(4)はaにも反映される。c = a[:]は独立した新しいリストなのでc.append(5)はaに影響しない。", "a[:]はb = aと同じ「別名」を作るだけでコピーにはならないと誤解した場合の答え。実際にはスライスa[:]は中身が同じ新しいリストを作るコピーであり、cへの変更はaに影響しない。", "b = aを「新しいリストを作るコピー」だと誤解した場合の答え。実際にはb = aは代入時に新しいリストを作らず、aと全く同じオブジェクトを指す別名になる。", "b = aとa[:]はどちらも文法として正常な操作で、混在させても何のエラーも起きない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><rect x=\"15\" y=\"15\" width=\"40\" height=\"26\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"35.0\" y=\"32.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">a</text><rect x=\"15\" y=\"48\" width=\"40\" height=\"26\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"35.0\" y=\"65.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">b</text><rect x=\"15\" y=\"95\" width=\"40\" height=\"26\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"35.0\" y=\"112.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">c</text><rect x=\"150\" y=\"12\" width=\"170\" height=\"34\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"235.0\" y=\"26.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[1, 2, 3, 4]</text><text x=\"235.0\" y=\"39.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">b.append(4) が反映</text><rect x=\"150\" y=\"85\" width=\"170\" height=\"34\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"235.0\" y=\"99.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[1, 2, 3, 5]</text><text x=\"235.0\" y=\"112.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">c だけの新しいリスト</text><line x1=\"55\" y1=\"28\" x2=\"148\" y2=\"25\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"55\" y1=\"61\" x2=\"148\" y2=\"30\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"55\" y1=\"108\" x2=\"148\" y2=\"100\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><text x=\"235\" y=\"70\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">a と b は同じ箱 / c は別の箱</text></svg>"}'),

  ('python-drill-q50', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'import copy
original = [[1, 2], [3, 4]]
shallow = copy.copy(original)
shallow.append([5, 6])
shallow[0][0] = 99
print(original)
print(shallow)',
   '["[[99, 2], [3, 4]] の後に [[99, 2], [3, 4], [5, 6]]", "[[1, 2], [3, 4]] の後に [[99, 2], [3, 4], [5, 6]]", "[[99, 2], [3, 4], [5, 6]] の後に [[99, 2], [3, 4], [5, 6]]", "[[1, 2], [3, 4], [5, 6]] の後に [[99, 2], [3, 4], [5, 6]]"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（copy.copy()の浅いコピーとネストしたリスト）", "point": "copy.copy()は「外側の入れ物だけ」新しく作る浅いコピー。外側へのappendはコピー先にしか響かないが、内側の可変オブジェクト（リストなど）は元と共有されたままなので、内側を書き換えると両方に響く。", "why_asked": "「copyという名前がついているから完全に独立したはず」という思い込みで、内側のリストや辞書を書き換えると、元のデータまで意図せず壊れる典型的なバグ源。", "kid": "shallowはoriginalとは別の箱（リストそのもの）としてコピーされるので、箱に新しい要素を追加してもoriginalには影響しない。でも箱の中に入っている[1,2]や[3,4]という「中身のリスト」自体はoriginalと同じものを共有しているので、中身を書き換えると両方に反映される。", "eg": "本棚（外側のリスト）を新しく用意してコピーしても、そこに並べる本（内側のリスト）自体は同じ本を共有しているようなもの。新しい本棚に本を追加しても元の本棚は増えないが、共有している本のページを書き換えたら、どちらの本棚から見ても書き換わって見える。", "terms": [["copy.copy(x)", "xの「一番外側」だけを新しく複製する浅いコピー用の関数"], ["shallow[0][0] = 99", "shallowの1つ目の内側リストの0番目の要素を書き換える操作"], [".append(x)", "リストの末尾にxを追加する破壊的メソッド"]], "think": "original=[[1,2],[3,4]]。shallow = copy.copy(original)でshallowという新しい外側のリストができるが、中の[1,2]と[3,4]はoriginalと同じオブジェクトを指したまま。shallow.append([5,6])は新しい外側のリストshallowにだけ[5,6]を追加するのでoriginalには影響しない。shallow[0][0] = 99は共有されている内側の[1,2]というリストそのものを書き換えるので、originalの1つ目の要素も99に変わる。よってoriginal=[[99,2],[3,4]]、shallow=[[99,2],[3,4],[5,6]]。", "vs": "copy.copy()（浅いコピー）は外側だけ独立、中身は共有。copy.deepcopy()なら内側の[1,2]や[3,4]までそれぞれ新しく複製されるので、shallow[0][0]=99を書き換えてもoriginalには一切影響しなくなる。", "opt": ["正解。copy.copy()は外側のリストだけ新しく作るので、shallow.append([5,6])はshallowだけに反映される。一方、内側の[1,2]や[3,4]はoriginalと共有されたままなので、shallow[0][0]=99の書き換えはoriginalにも反映される。", "copy.copy()が内側のリストまで独立にコピーする（copy.deepcopy()と同じ）と誤解した場合の答え。実際には浅いコピーなので、内側の書き換えはoriginalにも反映される。", "copy.copy()がb = aの代入と同じで、そもそも新しいリストを作らず同じオブジェクトを指すだけだと誤解した場合の答え。実際には外側のリストはoriginalとは別物として複製されるので、shallow.append()はoriginalに影響しない。", "浅いコピーの「浅さ」の向きを逆に理解し、外側への追加が共有され、内側の書き換えは共有されないと誤解した場合の答え。実際は逆で、外側は独立、内側が共有される。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><rect x=\"10\" y=\"55\" width=\"60\" height=\"26\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"40.0\" y=\"72.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">original</text><rect x=\"10\" y=\"100\" width=\"60\" height=\"26\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"40.0\" y=\"117.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">shallow</text><rect x=\"110\" y=\"15\" width=\"60\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"140.0\" y=\"27.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[1, 2]</text><text x=\"140.0\" y=\"40.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">→[99, 2]</text><rect x=\"110\" y=\"55\" width=\"60\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"140.0\" y=\"74.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[3, 4]</text><rect x=\"200\" y=\"100\" width=\"60\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"230.0\" y=\"112.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[5, 6]</text><text x=\"230.0\" y=\"125.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">shallowのみ</text><line x1=\"70\" y1=\"65\" x2=\"108\" y2=\"30\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"70\" y1=\"68\" x2=\"108\" y2=\"68\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"70\" y1=\"108\" x2=\"108\" y2=\"32\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><line x1=\"70\" y1=\"112\" x2=\"108\" y2=\"70\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><line x1=\"70\" y1=\"116\" x2=\"198\" y2=\"112\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><text x=\"170\" y=\"128\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">外側は別々の箱、内側は共有</text></svg>"}'),

  ('python-drill-q51', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'import copy
original = [[1, 2], [3, 4]]
deep = copy.deepcopy(original)
deep[0][0] = 99
print(original)
print(deep)',
   '["[[1, 2], [3, 4]] の後に [[99, 2], [3, 4]]", "[[99, 2], [3, 4]] の後に [[99, 2], [3, 4]]", "[[1, 2], [3, 4]] の後に [[1, 2], [3, 4]]", "エラーになる（copy.deepcopy()はネストしたリストには使えない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（copy.deepcopy()で内側まで独立にコピー）", "point": "copy.deepcopy()は外側だけでなく、内側にネストしたリストや辞書などもすべて再帰的に複製する。だからコピー後にどれだけ内側を書き換えても元とは完全に無関係になる。", "why_asked": "設定値やテンプレートのような「他の処理に絶対書き換えられたくないデータ」を安全に複製したいとき、copy.copy()では不十分でdeepcopy()が必要になる場面を見極める判断材料になる。", "kid": "deep = copy.deepcopy(original)で、外側のリストだけでなく中の[1,2]や[3,4]まで、まるごと新しく作り直したコピーになる。だからdeep[0][0]=99と書き換えてもoriginalは一切影響を受けない。", "eg": "本棚だけでなく、そこに並んでいる本まで1冊1冊すべてコピー機で複製して新しい本棚に並べ直すようなもの。新しい本のページをどれだけ書き換えても、元の本棚の本は無傷のまま。", "terms": [["copy.deepcopy(x)", "xの中にネストしているリストや辞書なども含めて、すべて再帰的に新しく複製する関数"], ["copy.copy(x)", "外側の入れ物だけを複製し、内側の可変オブジェクトは元と共有したままにする浅いコピー"]], "think": "original=[[1,2],[3,4]]。deep = copy.deepcopy(original)で、外側のリストも内側の[1,2]・[3,4]もすべて新しく複製される。deep[0][0] = 99はdeepだけが持つ独立した[1,2]（コピー後のもの）を書き換えるので、originalの[1,2]には一切影響しない。よってoriginalは[[1,2],[3,4]]のまま、deepは[[99,2],[3,4]]になる。", "vs": "copy.copy()（浅いコピー）だと内側のリストは共有されたままなので、deep[0][0]=99のような内側の書き換えが元にも反映されてしまう。deepcopy()はその共有を断ち切って、内側まで完全に独立させる点が違う。", "opt": ["正解。copy.deepcopy()は内側の[1,2]や[3,4]までそれぞれ新しく複製するので、deep[0][0]=99の書き換えはdeepだけに反映され、originalには一切影響しない。", "copy.deepcopy()がcopy.copy()と同じ「浅い」コピーで、内側のリストを共有すると誤解した場合の答え。実際にはdeepcopy()は内側まで独立に複製するので、originalは変わらない。", "deep[0][0] = 99という代入自体が実行されない、もしくはdeepにも反映されないと誤解した場合の答え。実際にはdeep自身への書き換えは当然deepに反映される。", "copy.deepcopy()はリストがネストしていても問題なく使える標準ライブラリの関数で、むしろネストした構造を再帰的にたどって複製するために作られている。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><rect x=\"10\" y=\"55\" width=\"60\" height=\"26\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"40.0\" y=\"72.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">original</text><rect x=\"110\" y=\"20\" width=\"70\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"145.0\" y=\"38.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[1, 2]</text><rect x=\"110\" y=\"58\" width=\"70\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"145.0\" y=\"76.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[3, 4]</text><line x1=\"70\" y1=\"65\" x2=\"108\" y2=\"34\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"70\" y1=\"68\" x2=\"108\" y2=\"70\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><rect x=\"10\" y=\"105\" width=\"60\" height=\"26\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"40.0\" y=\"122.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">deep</text><rect x=\"230\" y=\"20\" width=\"70\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"265.0\" y=\"38.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[99, 2]</text><rect x=\"230\" y=\"58\" width=\"70\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"265.0\" y=\"76.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[3, 4]</text><line x1=\"70\" y1=\"115\" x2=\"228\" y2=\"34\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><line x1=\"70\" y1=\"118\" x2=\"228\" y2=\"70\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><text x=\"175\" y=\"118\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">内側まで完全に別々の箱</text></svg>"}'),

  ('python-drill-q52', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   't = (1, [2, 3], 4)
t[1].append(99)
print(t)',
   '["(1, [2, 3, 99], 4)", "エラーになる（タプルの要素は変更できないため）", "(1, [2, 3], 4, 99)", "(1, 99, 4)"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（タプルの中の可変オブジェクト）", "point": "タプル自体が不変(immutable)なのは「タプルが持つ各スロットの参照先を変えられない」という意味であり、そのスロットの中身が可変オブジェクト（リストなど）なら、中身自体を書き換えることは普通にできる。", "why_asked": "「タプルは変更できない」という説明を字面どおり覚えていると、タプルの中にリストを入れて中身を書き換えるコードに出会ったときに混乱する。設定用のタプルの中にリストを仕込んで、うっかり書き換えてしまう事故にもつながる。", "kid": "tというタプル自体の3つのスロット（1番目・2番目・3番目に何を入れるか）は後から変更できないけど、2番目のスロットに入っている[2, 3]というリストの中身を書き換えることはできる。t[1]はそのリストを指しているので、appendで99を追加すると[2, 3, 99]になる。", "eg": "3つの引き出し（タプル）自体は取り替えられない棚だけど、真ん中の引き出しの中に「メモ帳（リスト）」が入っていたら、そのメモ帳に新しいメモを書き足すことはできる、というようなもの。棚（引き出しの数と配置）は変わらないが、中のメモ帳の中身は変わる。", "terms": [["タプル (tuple)", "()で作る、要素の入れ替え・追加・削除ができない不変(immutable)なシーケンス"], ["t[1]", "タプルtの2番目（インデックス1）の要素を取り出す"], [".append(x)", "リストの末尾にxを追加する破壊的メソッド。リスト自体は可変(mutable)なので使える"]], "think": "t = (1, [2, 3], 4)で、tの2番目の要素t[1]は[2, 3]というリストオブジェクト。t[1].append(99)は「tの2番目の要素を差し替える」操作ではなく、「t[1]が指しているリストそのものに99を追加する」操作。リストは可変なのでこの操作は問題なく成功し、[2, 3, 99]になる。タプルtが指す3つのスロット（1, リスト, 4）自体は変わっていないので、print(t)は(1, [2, 3, 99], 4)。", "vs": "t[1] = [9, 9]のように「スロットの中身を別のオブジェクトに差し替える」操作はタプルが不変なのでエラーになる。一方t[1].append(99)のように「スロットが指しているリストの中身を書き換える」操作はリスト側が可変なので成功する、という違いに注意。", "opt": ["正解。t[1]は[2, 3]というリストを指しており、リストは可変なのでappend(99)は成功する。タプル自体の3つのスロットの並びは変わっていないので、(1, [2, 3, 99], 4)になる。", "タプルが不変なのは「スロットの参照先を差し替えられない」という意味で、スロットが指すリストの中身まで凍結するわけではない。t[1].append(99)はリスト自身への操作なので成功する。", ".append()はtの末尾ではなく、t[1]が指しているリスト（[2, 3]）の末尾に99を追加する。タプル全体の要素数が増えるわけではない。", "t[1].append(99)はt[1]を99という値に置き換える代入ではない。.append()はリストの末尾に要素を追加するメソッドであり、リストの中身が[2, 3, 99]に変わるだけ。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">t = (1, [2, 3], 4) ― タプルの3つのスロット</text><rect x=\"20\" y=\"30\" width=\"60\" height=\"32\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"50.0\" y=\"50.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">1</text><rect x=\"90\" y=\"30\" width=\"90\" height=\"32\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"135.0\" y=\"50.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">→ list</text><rect x=\"190\" y=\"30\" width=\"60\" height=\"32\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"220.0\" y=\"50.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">4</text><rect x=\"90\" y=\"85\" width=\"150\" height=\"32\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"165.0\" y=\"98.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[2, 3, 99]</text><text x=\"165.0\" y=\"111.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">append(99)で書き換え</text><line x1=\"135\" y1=\"62\" x2=\"165\" y2=\"85\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><text x=\"170\" y=\"130\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">スロットの並び自体は不変のまま</text></svg>"}'),

  ('python-drill-q53', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'def add_item(lst, item):
    lst.append(item)

basket = ["apple"]
add_item(basket, "banana")
print(basket)',
   '["[''apple'', ''banana'']", "[''apple'']", "エラーになる（関数の外の変数を関数内で書き換えることはできない）", "None"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（関数に可変オブジェクトを渡したときの挙動）", "point": "Pythonでは関数にリストや辞書のような可変オブジェクトを渡すと、関数の外の変数と関数内の引数は同じオブジェクトを指す。関数内でその中身を書き換えると、呼び出し元の変数からも変更後の状態が見える。", "why_asked": "「引数は関数の中だけの話」という思い込みで関数にリストを渡すと、意図せず呼び出し元のデータまで書き換えてしまう事故につながる。副作用のある関数を書くときに必ず意識する必要がある。", "kid": "add_item(basket, \"banana\")を呼ぶと、関数の中のlstはbasketと同じリストを指す。lst.append(item)でそのリストに\"banana\"を追加すると、lstもbasketも同じリストなので、関数の外のbasketにも\"banana\"が増えて見える。", "eg": "友達に自分のノート（リスト）を貸して、友達がそのノートに書き込んだら、返ってきたノート（＝自分のノートそのもの）にも書き込みが残っている、というようなもの。コピーを渡したわけではないので、中身の変更がそのまま伝わる。", "terms": [["lst", "add_item関数の引数名。呼び出し時に渡されたオブジェクト（ここではbasketと同じリスト）を指す"], [".append(x)", "リストの末尾にxを追加する破壊的メソッド。呼び出し元のリストそのものを書き換える"]], "think": "basket = [\"apple\"]でbasketは1要素のリスト。add_item(basket, \"banana\")を呼ぶと、関数内のlstはbasketと同じオブジェクトを指す（コピーは作られない）。lst.append(\"banana\")でそのリストに\"banana\"が追加される。lstとbasketは同じオブジェクトなので、関数を抜けた後のbasketも[\"apple\", \"banana\"]になっている。", "vs": "数値や文字列のようなイミュータブルな値を関数に渡して関数内で再代入しても、呼び出し元の変数は変わらない。可変オブジェクト（リストや辞書）を渡して中身を書き換えた場合だけ、呼び出し元にも影響するという違いに注意。", "opt": ["正解。関数に渡したリストはコピーされず、lstとbasketは同じオブジェクトを指す。lst.append()での変更はそのままbasketにも反映される。", "関数に渡したリストは関数の外には影響しないと誤解した場合の答え。実際には可変オブジェクトはコピーされずに渡されるため、関数内での.append()は呼び出し元のリストにも反映される。", "関数の引数として渡されたオブジェクトの中身を書き換えること自体は、Pythonの通常の挙動として問題なく行える。エラーにはならない。", "print(basket)はadd_item()の戻り値ではなく、basketという変数の中身をそのまま表示している。add_item()はreturn文を持たずNoneを返すが、それはこのprintとは無関係。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><rect x=\"20\" y=\"20\" width=\"70\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"55.0\" y=\"38.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">basket</text><rect x=\"20\" y=\"90\" width=\"70\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#8892a4\" stroke-width=\"1.2\"/><text x=\"55.0\" y=\"108.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">lst（引数）</text><rect x=\"180\" y=\"50\" width=\"130\" height=\"34\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"245.0\" y=\"64.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">[''apple'', ''banana'']</text><text x=\"245.0\" y=\"77.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">append(\"banana\")</text><line x1=\"90\" y1=\"34\" x2=\"178\" y2=\"60\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"90\" y1=\"104\" x2=\"178\" y2=\"72\" stroke=\"#c9a04a\" stroke-width=\"1.4\" marker-end=\"url(#arG)\"/><text x=\"245\" y=\"105\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">同じリストを指すので変更が伝わる</text></svg>"}'),

  ('python-drill-q54', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'def steps():
    print("A")
    yield 1
    print("B")
    yield 2

g = steps()
print("created")
value = next(g)
print(value)',
   '["created → A → 1", "A → created → 1", "created → A → B → 1", "エラーになる（yieldを含む関数はふつうの関数のように呼び出せない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（ジェネレータ関数の遅延評価）", "point": "yieldを含む関数を呼び出しても、その場では中身は一切実行されない。next()（やforループ）で実際に値を取り出そうとした瞬間に、初めて直前のyieldの続きから実行が始まる（遅延評価）。", "why_asked": "「関数を呼んだら中身がすぐ動く」という前提でジェネレータを使うと、print()やログ出力・重い初期化処理が「呼んだ直後」ではなく「実際に使われた瞬間」まで遅れることに気づかず、実行順序を読み違える。", "kid": "g = steps()と書いた時点では、まだ関数の中身は何も動いていない。「created」と表示された後、next(g)を呼んで初めて関数の中身が動き出し、print(\"A\")が実行されてから最初のyield 1で止まって1を返す。", "eg": "レシピカード（ジェネレータ関数）を受け取っただけでは料理は始まらず、実際に「作って」と頼んだ瞬間（next()）に初めて最初の工程が動き出す、というようなもの。レシピを受け取っただけで勝手に鍋が火にかかったりはしない。", "terms": [["yield", "関数の実行をそこで一時停止し、値を呼び出し側に返すキーワード。この関数を「ジェネレータ関数」にする"], ["steps()", "ジェネレータ関数を呼ぶとジェネレータオブジェクトが作られるだけで、中身のコードはまだ実行されない"], ["next(g)", "ジェネレータの実行を（前回止まった場所、または最初から）次のyieldまで進める組み込み関数"]], "think": "g = steps()を実行しても、ジェネレータオブジェクトが作られるだけで中身のprint(\"A\")はまだ動かない。print(\"created\")で「created」が表示される。次にnext(g)を呼んだ瞬間、初めて関数の中身が動き出し、print(\"A\")で「A」が表示され、その直後のyield 1で実行が止まって1がvalueに入る。最後にprint(value)で「1」が表示される。よって表示順はcreated → A → 1。", "vs": "ふつうの関数はcall（呼び出し）した瞬間に中身が最後まで実行される。ジェネレータ関数はyieldがあるため、呼んだだけでは1行も実行されず、next()やforで「進める」たびに次のyieldまでだけ実行される点が根本的に違う。", "opt": ["正解。g = steps()の時点では中身は未実行。next(g)を呼んで初めてprint(\"A\")が動き、yield 1で止まって1を返す。表示順はcreated → A → 1。", "steps()を呼んだ瞬間に関数の中身（print(\"A\")）まで実行されると誤解した場合の答え。実際にはジェネレータ関数は呼んだだけでは1行も実行されない。", "next()を1回呼んだだけでジェネレータが最後まで一気に実行されると誤解した場合の答え。実際にはnext()は次のyieldまでしか進めないので、2つ目のprint(\"B\")はまだ実行されない。", "yieldを含む関数もふつうの関数と同じようにsteps()の形で呼び出せる。呼び出した戻り値がジェネレータオブジェクトになるだけで、呼び出し自体はエラーにならない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">呼び出しと next() のタイムライン</text><rect x=\"15\" y=\"30\" width=\"90\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"60.0\" y=\"42.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">g = steps()</text><text x=\"60.0\" y=\"55.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">本体は未実行</text><rect x=\"125\" y=\"30\" width=\"90\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"170.0\" y=\"49.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">next(g) 呼び出し</text><rect x=\"230\" y=\"30\" width=\"95\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"277.5\" y=\"49.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">\"A\" → yield 1</text><line x1=\"105\" y1=\"45\" x2=\"123\" y2=\"45\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><line x1=\"215\" y1=\"45\" x2=\"228\" y2=\"45\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><text x=\"170\" y=\"90\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">next()するまで print(\"A\") は実行されない</text><text x=\"170\" y=\"105\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">created が先に表示され、その後A・1が続く</text></svg>"}'),

  ('python-drill-q55', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'g = (x for x in [1, 2, 3])
print(list(g))
print(list(g))',
   '["[1, 2, 3] の後に []", "[1, 2, 3] の後に [1, 2, 3]", "エラーになる（2回目のlist(g)でStopIterationが発生する）", "[] の後に [1, 2, 3]"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（使い切ったジェネレータの再利用）", "point": "ジェネレータは一度最後まで値を取り出す（使い切る）と、内部の状態はそこで終わったまま。同じジェネレータオブジェクトに対してもう一度list()やforで回しても、二度と値は出てこない。", "why_asked": "「一度for文で回したジェネレータを、別の処理でもう一度使い回そうとしたら何も出てこなかった」という事故は非常によくある。ジェネレータがリストと違って「使い切り」であることを知らないとハマる。", "kid": "1回目のlist(g)でジェネレータgの中身[1, 2, 3]が全部取り出されて空っぽになる。2回目にlist(g)を呼んでも、もう取り出せる値が残っていないので空リスト[]になる。", "eg": "1回きりの回数券のようなもの。改札で3回分使い切ったら、同じ回数券をもう一度改札に通しても何も通過できない（新しい回数券を買い直す＝新しくジェネレータを作り直す必要がある）。", "terms": [["(x for x in [1, 2, 3])", "ジェネレータ式。呼ぶたびに新しく作られる、1回だけ使い切りのイテレータを返す"], ["list(g)", "ジェネレータgが持つ残りの値をすべて取り出してリストにする。取り出した値はgの中から無くなる"]], "think": "g = (x for x in [1, 2, 3])でジェネレータオブジェクトgができる（まだ何も取り出されていない）。1回目のprint(list(g))でgの中身が1, 2, 3の順にすべて取り出され、[1, 2, 3]が表示される。この時点でgはすでに空っぽ（使い切り済み）。2回目のprint(list(g))を呼んでも、もう取り出せる値がないので空リスト[]が表示される。", "vs": "リストなら[1, 2, 3]を何度for文で回しても毎回同じ中身が得られるが、ジェネレータは「今どこまで進んだか」という状態を内部に1つしか持たないため、一度使い切ると同じ内容をもう一度取り出すことはできない。もう一度使いたい場合は(x for x in [1, 2, 3])を新しく作り直す必要がある。", "opt": ["正解。1回目のlist(g)でgの中身が全部取り出され[1, 2, 3]になる。gはその時点で空になっているので、2回目のlist(g)は空リスト[]になる。", "list()で取り出してもジェネレータ自体はリストのように何度でも同じ中身を返すと誤解した場合の答え。実際には一度使い切ったジェネレータから、同じ値を再び取り出すことはできない。", "使い切ったジェネレータにlist()を渡すと例外が表に出てくると誤解した場合の答え。実際にはlist()は内部でStopIterationを自動的に受け止めて処理を終えるだけで、単に空のリストが返る。", "1回目のlist(g)の時点ではまだ何も生成されていないと誤解した場合の答え。実際にはgは作られた瞬間から順番に値を取り出せる状態にあり、1回目のlist(g)で[1, 2, 3]がすべて取り出される。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">g = (x for x in [1, 2, 3]) のカーソル</text><rect x=\"20\" y=\"35\" width=\"40\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"40.0\" y=\"53.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">1</text><rect x=\"65\" y=\"35\" width=\"40\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"85.0\" y=\"53.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">2</text><rect x=\"110\" y=\"35\" width=\"40\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"130.0\" y=\"53.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">3</text><text x=\"50\" y=\"30\" text-anchor=\"start\" font-size=\"8\" fill=\"#60a5fa\">1回目 list(g)</text><line x1=\"20\" y1=\"80\" x2=\"155\" y2=\"80\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><text x=\"230\" y=\"84\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">カーソルは末尾へ</text><rect x=\"190\" y=\"35\" width=\"100\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"240.0\" y=\"53.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">取り出す値なし</text><text x=\"240\" y=\"30\" text-anchor=\"middle\" font-size=\"8\" fill=\"#c9a04a\">2回目 list(g) → []</text></svg>"}'),

  ('python-drill-q56', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'nums = [1, 2, 3]
squares_list = [x * x for x in nums]
squares_gen = (x * x for x in nums)
print(type(squares_list).__name__, type(squares_gen).__name__)',
   '["list generator", "list list", "generator generator", "エラーになる（type()にジェネレータ式を渡すことはできない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（リスト内包表記とジェネレータ式の型の違い）", "point": "角括弧[]のリスト内包表記はその場で全要素を計算してlist型を作る。丸括弧()のジェネレータ式は中身をまだ計算せず、generator型のオブジェクトを作るだけ。", "why_asked": "見た目がほぼ同じ（角括弧か丸括弧かだけ）なのに、できあがるオブジェクトの型も、メモリの使われ方も別物になる。うっかり丸括弧で書いて「あれ、中身が全部入っているはずなのに値が取り出せない」と混乱する原因になる。", "kid": "squares_listは[]で書いているので、その場で1,4,9をすべて計算した「リスト」ができる。squares_genは()で書いているので、まだ何も計算されていない「ジェネレータ」というオブジェクトができるだけ。だからtype()で調べるとlistとgeneratorという別の型になる。", "eg": "squares_listは注文した料理が全部お皿に盛られて出てくる定食、squares_genは「頼まれたら1品ずつ作りますよ」という調理券のようなもの。お皿（list）と調理券（generator）は見た目も性質も別物。", "terms": [["[x * x for x in nums]", "リスト内包表記。その場で全要素を計算してlist型のオブジェクトを作る"], ["(x * x for x in nums)", "ジェネレータ式。角括弧をただ丸括弧に変えただけに見えるが、generator型の遅延評価オブジェクトを作る"], ["type(x).__name__", "オブジェクトxの型名を文字列で取得する"]], "think": "squares_list = [x * x for x in nums]は角括弧なので、その場でnumsの各要素を2乗した値をすべて計算し、[1, 4, 9]というlist型のオブジェクトを作る。squares_gen = (x * x for x in nums)は丸括弧なので、まだ何も計算せず、必要なときに1つずつ計算する準備だけをしたgenerator型のオブジェクトを作る。type(...).__name__でそれぞれの型名を取り出すと''list''と''generator''。", "vs": "実際に計算された値の中身（[1,4,9]など）を見比べる問題ではなく、そもそも「できあがるオブジェクトの型そのもの」が違う、という点に注目する問題。list(...)で明示的に囲めば(x * x for x in nums)をlist型に変換できるが、素の丸括弧のままではgenerator型のまま。", "opt": ["正解。角括弧[]のリスト内包表記はlist型を、丸括弧()のジェネレータ式はgenerator型を作る。type().__name__の結果は''list''と''generator''。", "丸括弧()を使っても結局リストが作られると誤解した場合の答え。実際には()で書くとlist型ではなくgenerator型のオブジェクトになる。", "リスト内包表記も遅延評価される「ジェネレータ」の一種だと誤解した場合の答え。実際には[]のリスト内包表記はその場で全要素を計算し、list型を作る。", "type()はどんなオブジェクトにも使える組み込み関数で、ジェネレータオブジェクトの型を調べることも問題なくできる。"]}'),

  ('python-drill-q57', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'def gen():
    yield 10
    yield 3

g = gen()
print(next(g) - next(g))',
   '["7", "-7", "0", "エラーになる（同じ式の中で同じジェネレータのnext()を2回呼ぶことはできない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（next()を複数回呼んだときの進み方）", "point": "1つの式の中でnext(g)を2回書いても、Pythonは左から右の順に評価する。1回目のnext(g)がyield 10、2回目のnext(g)がyield 3を受け取るので、10 - 3 = 7になる。", "why_asked": "「同じ関数呼び出しを2回書いたら同じ値が返るはず」という思い込みは、状態を持つイテレータ・ジェネレータには通用しない。同じ式の中で複数回next()を呼ぶコードを読むとき、呼ぶたびに「状態が1つ進む」ことを追えないと計算結果を誤読する。", "kid": "next(g) - next(g)の左側のnext(g)が先に評価されてyield 10の10を受け取り、その後右側のnext(g)が評価されてyield 3の3を受け取る。だから10 - 3で7になる。", "eg": "1つのくじ引き箱（ジェネレータ）から順番に2回くじを引くようなもの。1回目に引いた「10」のくじは箱に戻らないので、2回目には次の「3」のくじが出てくる。同じ「10」が2回出てくるわけではない。", "terms": [["next(g)", "ジェネレータgの実行を次のyieldまで進め、その値を返す。呼ぶたびに内部の状態が1つ先に進む"], ["左から右の評価順", "Pythonの式の中の関数呼び出しは、基本的に書かれた順（左から右）に評価される"]], "think": "gen()はyield 10とyield 3を持つジェネレータ。g = gen()でgができる。print(next(g) - next(g))の中身が評価されるとき、まず左側のnext(g)が評価されて10を取り出す（gの状態はyield 10の位置まで進む）。次に右側のnext(g)が評価されて、続きから3を取り出す（gの状態はyield 3の位置まで進む）。10 - 3 = 7が計算され、printで7が表示される。", "vs": "next(g) + next(g)のように可換な演算（足し算など）では評価順が違っても結果は同じに見えてしまうが、引き算のように順序に意味がある演算にすると、「左のnext(g)が先に評価される＝先にyieldされた値を受け取る」ことがはっきり分かる。", "opt": ["正解。左側のnext(g)が先に評価されて10を取り出し、続いて右側のnext(g)が3を取り出す。10 - 3 = 7になる。", "式の中の関数呼び出しが右から左の順に評価されると誤解した場合の答え。実際にはPythonは左から右の順に評価するので、先に10、次に3が取り出される。", "同じジェネレータへのnext()は毎回同じ値（最初のyieldの値）を返すと誤解した場合の答え。実際にはnext()を呼ぶたびに内部の状態が1つ先に進み、次のyieldの値が返る。", "同じ式の中で同じオブジェクトのメソッドや関数を2回呼び出すこと自体は、Pythonの文法として何の問題もない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><defs><marker id=\"arB\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#60a5fa\"/></marker><marker id=\"arG\" viewBox=\"0 0 8 8\" refX=\"7\" refY=\"4\" markerWidth=\"6\" markerHeight=\"6\" orient=\"auto\"><path d=\"M0,0 L8,4 L0,8 z\" fill=\"#c9a04a\"/></marker></defs><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">next(g) を2回呼んだときの進み方</text><rect x=\"30\" y=\"40\" width=\"80\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"70.0\" y=\"52.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">yield 10</text><text x=\"70.0\" y=\"65.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">1回目のnext</text><rect x=\"140\" y=\"40\" width=\"80\" height=\"30\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"180.0\" y=\"52.0\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">yield 3</text><text x=\"180.0\" y=\"65.0\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">2回目のnext</text><line x1=\"110\" y1=\"55\" x2=\"138\" y2=\"55\" stroke=\"#60a5fa\" stroke-width=\"1.4\" marker-end=\"url(#arB)\"/><text x=\"230\" y=\"55\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">10 → 3 の順に消費</text><text x=\"170\" y=\"110\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">next(g) - next(g) は 10 - 3 = 7</text></svg>"}'),

  ('python-drill-q58', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'def gen():
    yield 1
    yield 2

g = gen()
print(next(g))
print(next(g))
print(next(g))',
   '["1 → 2 → エラーになる（StopIterationが送出される）", "1 → 2 → 1", "1 → 2 → None", "エラーになる（yieldは1つの関数の中で2回までしか書けない構文エラー）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（StopIterationが発生する場面）", "point": "ジェネレータが持つyieldの数を超えてnext()を呼ぶと、StopIterationという例外が発生する。for文はこれを裏側で自動的に受け止めて静かにループを終えるが、next()を直接呼んでいる場合は例外がそのまま表に出てくる。", "why_asked": "for文でジェネレータを回している限りStopIterationを意識することはないが、next()を手動で呼ぶコード（イテレータを自作するときなど）ではこの例外を自分でtry/exceptして扱う必要があり、知らないとプログラムが落ちる。", "kid": "gen()はyield 1とyield 2の2回分しか値を持っていない。next(g)を1回目は1、2回目は2を返すが、3回目はもう返す値がないので、StopIterationという例外が発生してプログラムがそこで止まる。", "eg": "2個しか入っていない飴の缶から、1個目、2個目と順に取り出した後、3個目を取り出そうとしたら「もう入っていません」というエラーの札が出てくる、というようなもの。", "terms": [["StopIteration", "イテレータ・ジェネレータの中身を使い切った後、next()を呼んだときに発生する例外"], ["next(g)", "ジェネレータgの続きの値を1つ取り出す。取り出す値がなくなるとStopIterationを送出する"], ["for文", "内部でnext()を繰り返し呼び、StopIterationを受け取ったら自動的にループを終える（例外がユーザーコードには表れない）"]], "think": "gen()はyield 1、yield 2の2つの値しか生成しない。1回目のnext(g)で1が返り表示される。2回目のnext(g)で2が返り表示される。この時点でgは持っている値をすべて使い切っている。3回目のnext(g)を呼ぶと、もう返す値がないためStopIteration例外が発生し、そこで処理が止まる（try/exceptで捕まえていないのでエラーとして表示される）。", "vs": "for x in gen():のようにfor文でジェネレータを回した場合は、StopIterationが発生した時点でPythonが自動的にそれを検知してループを静かに終了させるため、例外は表に出てこない。next()を直接手で呼んでいる今回のコードでは、その「自動で受け止める」仕組みが働かないため、例外がそのまま表面化する。", "opt": ["正解。1回目・2回目のnext(g)はそれぞれ1、2を返すが、gはそこで使い切られている。3回目のnext(g)は返す値がないためStopIteration例外が発生する。", "使い切ったジェネレータにnext()を呼ぶと最初に戻ってループすると誤解した場合の答え。実際にはジェネレータは自動的に先頭へは戻らず、StopIteration例外が発生する。", "使い切ったジェネレータにnext()を呼ぶと、例外ではなく静かにNoneが返ると誤解した場合の答え。実際にはNoneではなく、明示的なStopIteration例外が発生する。", "yieldの数に上限はなく、何回書いてもよい。3回目のnext(g)がエラーになるのは構文の問題ではなく、実行時にもう返す値が残っていないために発生するStopIteration例外（実行時エラー）。"]}'),

  ('python-drill-q59', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'nums = [1, 2, 3, 4]
total = sum(x * x for x in nums)
print(total)',
   '["30", "エラーになる（sum()にジェネレータ式を渡すときは丸括弧を二重に書く必要がある）", "[1, 4, 9, 16]", "10"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（関数の唯一の引数ならジェネレータ式の丸括弧を省略できる）", "point": "関数の引数が1つだけで、それがジェネレータ式である場合に限り、外側の丸括弧を省略して書ける。sum(x * x for x in nums)はsum((x * x for x in nums))と同じ意味。", "why_asked": "sum()やmax()、any()などにジェネレータ式を渡すとき、丸括弧を二重に書くべきか省略していいのか迷いやすい。省略できる条件（引数がそのジェネレータ式1つだけ）を知らないと、不要な丸括弧を書いたり、逆に必要な場面で書き忘れて構文エラーにしたりする。", "kid": "x * x for x in numsの部分は「ジェネレータ式」で、numsの各要素を2乗した1, 4, 9, 16を順に作る。sum()の引数がこのジェネレータ式1つだけなので、丸括弧を省略してsum(x * x for x in nums)と書ける。sum()がそれを1つずつ受け取って合計すると1+4+9+16=30になる。", "eg": "カッコの中に「1個だけの品物」を渡すとき、外側の買い物袋（関数の丸括弧）がそのまま品物の入れ物を兼ねてくれるので、二重に袋を用意しなくていい、というようなもの。", "terms": [["sum(x * x for x in nums)", "ジェネレータ式x * x for x in numsを、丸括弧を省略してsum()に直接渡す書き方"], ["sum(iterable)", "渡された反復可能オブジェクトの要素をすべて合計する組み込み関数"]], "think": "numsは[1, 2, 3, 4]。x * x for x in numsは各要素を2乗したジェネレータ式で、1, 4, 9, 16を順に生成する。sum()の唯一の引数としてこのジェネレータ式を渡しているので、丸括弧の省略が許され、sum(x * x for x in nums)はsum((x * x for x in nums))と同じ意味になる。sum()はこれらを1つずつ受け取って合計するので1+4+9+16=30。print(total)で30が表示される。", "vs": "sum(x * x for x in nums, start=100)のように他の引数も一緒に渡す場合は、ジェネレータ式だけを丸括弧で囲む必要がある（sum((x * x for x in nums), start=100)）。「関数の引数がジェネレータ式1つだけ」のときに限って省略できる、という条件に注意。", "opt": ["正解。sum()の引数がジェネレータ式1つだけなので丸括弧を省略でき、numsの各要素を2乗した1+4+9+16=30が合計される。", "ジェネレータ式を関数に渡すときは常に丸括弧を二重に書く必要があると誤解した場合の答え。実際には関数の唯一の引数である場合に限り、外側の丸括弧を省略できる。", "sum()がジェネレータの中身をそのままリストのように返すと誤解した場合の答え。実際にはsum()は要素を1つずつ受け取って合計した数値を返す。", "x * xの2乗計算を見落とし、xそのものを合計してしまった場合の答え（1+2+3+4=10）。実際にはx * xで各要素の2乗を合計するので、より大きい値になる。"]}'),

  ('python-drill-q60', '例外処理',
   'このコードを実行すると何が出力される？',
   'def convert(text):
    try:
        n = int(text)
    except ValueError:
        print("invalid")
    else:
        print("valid:", n)
    finally:
        print("checked")

convert("abc")',
   '["invalid → checked", "invalid → valid: abc → checked", "invalidのみ（exceptで例外を捕まえるとfinallyは実行されない）", "エラーになる（int(\"abc\")の例外はexceptで捕まえられない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（try/except/else/finallyの実行順序）", "point": "elseは例外が起きなかったときだけ、finallyは例外の有無にかかわらず必ず実行される。", "why_asked": "「例外が起きたらfinallyは飛ばされる」と思い込んでリソース解放処理をfinallyに書いても実行されないと誤解しがちだが、実際はfinallyは例外があっても無くても必ず走る。この前提を誤ると後片付け処理の設計を誤る。", "kid": "int(\"abc\")で変換に失敗して例外が起きるので、exceptで\"invalid\"が出て、elseは実行されずスキップされ、最後にfinallyの\"checked\"が必ず出る。", "eg": "料理中に鍋を焦がしても焦がさなくても、最後に必ず火を消す（finally）のと同じ。うまく作れたときだけ盛り付ける（else）工程は失敗したら飛ばされる。", "terms": [["else節", "tryブロックで例外が一切起きなかったときだけ実行される節"], ["finally節", "例外の有無にかかわらず必ず最後に実行される節"], ["ValueError", "型変換などで値が不正なときに送出される標準例外"]], "think": "text=\"abc\"に対してint(text)を実行すると変換できずValueErrorが送出される。tryブロックの残りはスキップされ、except ValueErrorにマッチして\"invalid\"が出力される。例外が起きたのでelse節（\"valid: n\"を出す節）は実行されない。最後にfinally節は例外の有無に関係なく必ず実行されるので\"checked\"が出力される。よって出力は\"invalid\"の後に\"checked\"。", "vs": "正常系（例外が起きない場合）はelseが実行されfinallyも続けて実行される。今回のような例外系ではelseだけが飛ばされ、finallyは正常系・例外系どちらでも必ず実行される点が違う。", "opt": ["正解。int(\"abc\")で例外が起きるのでexceptの\"invalid\"が出力され、elseはスキップ、finallyの\"checked\"は例外の有無に関係なく必ず実行される。", "elseはtryブロックが例外なく成功したときだけ実行される節。exceptで例外を捕まえた場合、elseは実行されない。", "finallyは例外を捕まえたかどうかに関係なく必ず実行される節。exceptで捕まえたからといって省略されることはない。", "except ValueErrorは指定した例外クラス（またはそのサブクラス）を捕まえる節。int(\"abc\")が送出するのはValueErrorそのものなので問題なく捕まえられる。"]}'),

  ('python-drill-q61', '例外処理',
   'このコードを実行すると何が出力される？',
   'def divide(a, b):
    try:
        return a / b
    except Exception:
        return "generic"
    except ZeroDivisionError:
        return "zero"

print(divide(10, 0))',
   '["generic", "zero", "generic の後に zero", "エラーになる（ZeroDivisionErrorはExceptionでは捕まえられない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（複数except節のマッチ順序）", "point": "except節は上から順に調べられ、最初にマッチした節だけが実行される。ZeroDivisionErrorはExceptionのサブクラスなので、先に書かれたexcept Exceptionにマッチしてしまう。", "why_asked": "「一番具体的な例外クラスの節が優先される」と思い込みがちだが、実際は書いた順番が全て。広い例外クラスを先に書くと、後ろに書いた具体的な例外の節が永久に実行されなくなるバグを生む。", "kid": "a/bで10/0を計算しようとしてZeroDivisionErrorが起きるが、最初に書かれているexcept Exceptionが先にマッチしてしまうので\"generic\"が返る。2つ目のexcept ZeroDivisionErrorは出番が来ない。", "eg": "受付窓口が「なんでも相談」と「ゼロ除算専用」の2つあって、「なんでも相談」を先に並べてしまうと、ゼロ除算の相談者も先に「なんでも相談」に案内されてしまい、専用窓口には誰も辿り着かないのと同じ。", "terms": [["except節のマッチ順序", "tryブロックで例外が起きたとき、except節は上から順に調べられ最初に一致した節だけが実行される"], ["Exception", "ほとんどの組み込み例外の親クラス。ZeroDivisionErrorなど具体的な例外もExceptionのサブクラスにあたる"], ["ZeroDivisionError", "ゼロで割り算しようとしたときに送出される例外"]], "think": "divide(10, 0)を呼ぶとa/bは10/0となりZeroDivisionErrorが送出される。except節は上から順に調べられ、最初のexcept ExceptionはZeroDivisionErrorの親クラスにあたるためここでマッチしてしまい、\"generic\"がreturnされる。2つ目のexcept ZeroDivisionErrorは、そもそも最初の節で例外処理が完了してしまっているため実行されない。よって出力は\"generic\"。", "vs": "except節の順序を逆にしてexcept ZeroDivisionErrorを先に書けば、ゼロ除算のときは\"zero\"、それ以外のExceptionは\"generic\"と使い分けられる。具体的な例外ほど先に書くのが正しい書き方。", "opt": ["正解。except節は上から順にマッチが調べられ、最初に一致した節だけが実行される。ZeroDivisionErrorはExceptionのサブクラスなので、先に書かれたexcept Exceptionで捕まってしまう。", "except ZeroDivisionErrorの方が具体的なクラスだが、Pythonのexcept節は「具体性」ではなく「書かれた順番」でマッチする。先に書いたexcept Exceptionが優先されてしまう。", "マッチした時点でexcept節の処理は完了しreturnされるため、後ろのexcept節は実行されない。両方が動くことはない。", "ZeroDivisionErrorはExceptionを継承した例外クラスの一つなので、except Exceptionで問題なく捕まえられる。"]}'),

  ('python-drill-q62', '例外処理',
   'このコードを実行すると何が出力される？',
   'def safe_divide(a, b):
    try:
        return a / b
    except Exception as e:
        print("error:", str(e))
        return None

safe_divide(10, 0)',
   '["error: division by zero", "error: ZeroDivisionError", "error: 0", "エラーになる（str(e)は例外オブジェクトを文字列化できない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（except Exception as e とstr(e)）", "point": "except ... as eで受け取ったeは例外オブジェクトそのもので、str(e)とするとその例外が持つメッセージ文字列が取れる。", "why_asked": "例外をログに出すときstr(e)でメッセージだけを取り出すのは実務で頻出するが、str(e)がクラス名を返すと勘違いしていると、ログに\"ZeroDivisionError\"としか出ず何が起きたのか本文が分からなくなる。", "kid": "10/0でZeroDivisionErrorが起き、exceptのasでそのエラーオブジェクトがeに入る。str(e)はエラーの中身のメッセージ文字列を取り出すので、Pythonが用意した\"division by zero\"という説明文が出力される。", "eg": "エラーオブジェクトは「事故報告書」そのもので、str(e)はその報告書の「本文」を読み上げること。事故の種類（クラス名）ではなく、何が起きたかの説明文が読み上げられる。", "terms": [["except ... as e", "捕まえた例外オブジェクトを変数eに束縛する書き方"], ["str(e)", "例外オブジェクトeをその説明メッセージの文字列に変換する呼び出し"], ["ZeroDivisionError", "ゼロで割り算しようとしたときに送出される例外"]], "think": "a/bで10/0を計算しようとするとZeroDivisionErrorが送出される。except Exception as eでこの例外オブジェクトがeに束縛される。str(e)はeの持つメッセージ文字列を返すので、Pythonが自動生成した\"division by zero\"という文字列になる。print(\"error:\", str(e))はこれをスペース区切りで出力するので、\"error: division by zero\"となる。", "vs": "str(e)はメッセージ文字列を返すのに対し、type(e).__name__は\"ZeroDivisionError\"というクラス名を返す。両者は別物で、混同するとログの内容が意図と変わる。", "opt": ["正解。str(e)は例外オブジェクトが持つメッセージ文字列を返す。10/0が送出するZeroDivisionErrorのメッセージ\"division by zero\"がそのまま文字列化される。", "\"ZeroDivisionError\"のようなクラス名が返るのはtype(e).__name__。str(e)が返すのはクラス名ではなくメッセージ本文。", "str(e)は計算に使った値（0など）ではなく、例外オブジェクトが保持しているエラーメッセージを返す。原因の値がそのまま出るわけではない。", "str()は組み込み型だけでなく例外オブジェクトにも使え、__str__メソッドを通じてメッセージ文字列に変換できる。"]}'),

  ('python-drill-q63', '例外処理',
   'このコードを実行すると何が出力される？',
   'def validate(n):
    try:
        if n < 0:
            raise ValueError("negative")
        return n
    except ValueError:
        print("caught inside")
        raise

try:
    validate(-5)
except ValueError as e:
    print("caught outside:", e)',
   '["caught inside → caught outside: negative", "caught insideのみ（raiseだけでは例外は外に伝わらない）", "caught inside → caught outside: None", "エラーになる（exceptブロックの中でraiseだけを書くと文法エラーになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（exceptの中でraiseだけ書いて再送出する）", "point": "except節の中で引数なしのraiseを書くと、今捕まえている例外をそのまま外側に投げ直す。", "why_asked": "「ログだけ出してエラーを揉み消したいわけではなく、呼び出し元にも知らせたい」場面で使うが、raiseだけで元の例外情報（型・メッセージ）がそのまま保たれることを知らないと、わざわざ同じ例外を作り直すような冗長なコードを書いてしまう。", "kid": "validate(-5)はn<0なのでValueError(\"negative\")を送出し、内側のexceptがまず捕まえて\"caught inside\"を出す。そのあとraiseだけを書いているので同じ例外がそのまま外に投げ直され、外側のtryのexceptがもう一度捕まえて\"caught outside: negative\"を出す。", "eg": "受け取った荷物（例外）を一度開けて中身を確認してから（print）、そのまま元の梱包のまま次の人に転送するようなもの。中身（メッセージ）は変わらず\"negative\"のまま次の受け手に届く。", "terms": [["bare raise", "except節の中で引数なしで書くraise。今処理中の例外をそのまま再送出する"], ["例外の伝播", "捕まえずに（または再送出して）上位の呼び出し元まで例外が届くこと"]], "think": "validate(-5)が呼ばれるとn<0が真になりValueError(\"negative\")が送出される。内側のexcept ValueErrorがこれを捕まえ、まず\"caught inside\"を出力する。次の行のraiseは引数なしなので、今捕まえているValueError(\"negative\")をそのまま再送出する。この再送出された例外はvalidate関数の外に伝播し、外側のtry/exceptのexcept ValueError as eで捕まる。eには元と同じメッセージ\"negative\"が入っているので、print(\"caught outside:\", e)は\"caught outside: negative\"を出力する。", "vs": "raise 新しい例外(...)やraise 新しい例外(...) from eは別の例外に変換して送出する書き方だが、引数なしのbare raiseは変換せず今の例外をそのまま投げ直す点が違う。", "opt": ["正解。内側のexceptで一度\"caught inside\"を出したあと、引数なしのraiseで同じValueError(\"negative\")をそのまま再送出し、外側のexceptが\"caught outside: negative\"を出す。", "raiseだけでも今捕まえている例外はそのまま外側に伝播する。何も起きずに終わることはない。", "bare raiseは元の例外オブジェクトをそのまま投げ直すので、メッセージ\"negative\"も保たれたまま外側に届く。Noneにはならない。", "except節の中で引数なしのraiseを書くのは正式な文法で、「今捕まえている例外を再送出する」という決まった意味を持つ。"]}'),

  ('python-drill-q64', '例外処理',
   'このコードを実行すると何が出力される？',
   'class InsufficientFundsError(Exception):
    pass

def withdraw(balance, amount):
    if amount > balance:
        raise InsufficientFundsError(f"{amount} exceeds balance {balance}")
    return balance - amount

try:
    withdraw(1000, 1500)
except InsufficientFundsError as e:
    print("blocked:", e)',
   '["blocked: 1500 exceeds balance 1000", "blocked: InsufficientFundsError", "blocked: -500", "エラーになる（Exceptionを継承した独自クラスはexceptで捕まえられない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（Exceptionを継承したカスタム例外クラス）", "point": "Exceptionを継承したクラスは、組み込みの例外クラスと同じようにraiseで送出しexceptで捕まえられる。", "why_asked": "業務エラー（残高不足・在庫切れなど）をValueErrorのような汎用例外で表すと呼び出し元が種類を区別しづらい。独自の例外クラスを作れることを知らないと、エラーの種類分けをif文の戻り値やエラーコードで頑張ってしまう。", "kid": "amount(1500)がbalance(1000)を超えているのでInsufficientFundsErrorを送出する。exceptはこの独自クラスをそのまま指定して捕まえられるので、\"blocked:\"の後にエラーメッセージ\"1500 exceeds balance 1000\"が出力される。", "eg": "会社独自の「残高不足報告書」という書式を新しく作って、受付窓口にはその書式の報告書だけを受け取る係を置くようなもの。書式（クラス）さえ合っていれば、既製の書式（組み込み例外）でなくても正しく受け取ってもらえる。", "terms": [["class InsufficientFundsError(Exception)", "Exceptionを継承して作る独自の例外クラス"], ["raise", "例外オブジェクトを送出する文"], ["except InsufficientFundsError as e", "独自クラスを指定して例外を捕まえ、eに例外オブジェクトを束縛する"]], "think": "withdraw(1000, 1500)が呼ばれるとamount(1500) > balance(1000)が真になり、InsufficientFundsError(f\"1500 exceeds balance 1000\")が送出される。これはExceptionを継承しているので、except InsufficientFundsError as eで問題なく捕まえられ、eにはこの例外オブジェクトが入る。print(\"blocked:\", e)はeを文字列化してメッセージを表示するので、\"blocked: 1500 exceeds balance 1000\"が出力される。", "vs": "組み込みのValueErrorやTypeErrorで代用することもできるが、独自クラスにすることで「この業務エラーだけを狙って捕まえる」ことができ、他の予期しない例外まで一緒に握りつぶしてしまう事故を防げる。", "opt": ["正解。InsufficientFundsErrorはExceptionを継承した正式な例外クラスなので、raiseで送出しexceptでそのまま捕まえられる。eにはメッセージ\"1500 exceeds balance 1000\"が入っている。", "\"InsufficientFundsError\"のようなクラス名が出るのはtype(e).__name__の場合。print(\"blocked:\", e)のeはメッセージ文字列として表示される。", "amount > balanceが真になった時点でInsufficientFundsErrorが送出され、return文には到達しない。balance - amountの計算結果が出ることはない。", "Exceptionを継承したクラスは組み込みの例外と同じ扱いを受ける。exceptにそのクラス名を指定すれば普通に捕まえられる。"]}'),

  ('python-drill-q65', '例外処理',
   'このコードを実行すると何が出力される？',
   'def risky_division(a, b):
    return a / b

def safe_calc(a, b):
    try:
        result = risky_division(a, b)
        print("result:", result)
    except ZeroDivisionError:
        print("caught in safe_calc")

safe_calc(10, 0)',
   '["caught in safe_calc", "エラーになる（risky_division内で発生した例外は呼び出し元のtryでは捕まえられない）", "result: inf の後に caught in safe_calc", "result: None の後に caught in safe_calc"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（別の関数の中で起きた例外がtryに伝わる）", "point": "関数の中でtryを付けずに例外が起きても、その関数の呼び出し元がtryで囲んでいればそこで捕まえられる。", "why_asked": "「例外はその例外が起きた関数のtryでしか捕まえられない」と思い込みがちだが、実際は例外は捕まえられるまで呼び出し元へ呼び出し元へと伝播していく。この性質を知らないと、末端の小さな関数一つ一つに律儀にtryを書いてしまい、コードが冗長になる。", "kid": "risky_division自体にはtryが無いので、10/0で起きたZeroDivisionErrorはそのまま関数の外に飛び出す。呼び出し元のsafe_calcがtryでrisky_divisionの呼び出しを囲んでいるので、そこで例外を受け止めて\"caught in safe_calc\"を出す。", "eg": "1階（risky_division）で発生した火災報知器（例外）が1階では消し止められなくても、2階（呼び出し元のsafe_calc）に警報が伝わって、2階の消火設備（try/except）が対応するようなもの。発生場所と対応場所が別の階でもよい。", "terms": [["例外の伝播", "関数の中で捕まえられなかった例外が、呼び出し元の呼び出し元へと順番に伝わっていく仕組み"], ["ZeroDivisionError", "ゼロで割り算しようとしたときに送出される例外"]], "think": "risky_division(10, 0)はa/bを計算しようとして10/0となりZeroDivisionErrorを送出するが、この関数自身にはtryが無いので、例外はそのままrisky_divisionの外に伝播する。この呼び出しはsafe_calc内のtryブロックの中で行われているので、safe_calcのexcept ZeroDivisionErrorがこの例外を受け止め、\"caught in safe_calc\"を出力する。例外はresult = risky_division(a, b)の代入が完了する前に発生するので、resultへの代入もprint(\"result:\", result)も実行されない。", "vs": "risky_division自身にtry/exceptを書けばその場で処理を完結させられるが、今回のように呼び出し元にtryを置くと「複数の呼び出し方をまとめて1箇所でエラー処理する」という設計ができる。どちらも正しい書き方で、責務をどこに置くかの違い。", "opt": ["正解。risky_division自身にはtryが無いので例外はそのまま呼び出し元に伝播し、safe_calcのtry/exceptがそれを捕まえて\"caught in safe_calc\"を出力する。", "例外はその場で捕まえられなくても、呼び出し元がtryで囲んでいればそこまで伝わって捕まえられる。risky_division内にtryが無いから捕まえられない、ということはない。", "Pythonのゼロ除算は無限大を返す言語仕様ではなく、ZeroDivisionErrorという例外を送出する。resultへの代入自体が行われないので\"result:\"の行は出力されない。", "例外が発生した時点でresult = risky_division(a, b)の代入は完了しないため、resultにNoneが入ることもなく\"result:\"の行自体が出力されない。"]}'),

  ('python-drill-q66', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def collect(x, lst=[]):
    lst.append(x)
    return lst

collect(1)
print(collect(2, []))
print(collect(3))',
   '["[2] → [1, 3]", "[2] → [3]", "[2] → [1, 2, 3]", "[1, 2] → [1, 2, 3]"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（可変デフォルト引数と明示的な引数の使い分け）", "point": "lstを省略した呼び出しは全て同じデフォルトリストを共有するが、明示的に別のリストを渡した呼び出しはそのデフォルトリストに影響しない。", "why_asked": "デフォルト引数が使い回されること自体は知っていても、「たまに明示的にリストを渡す」呼び出しが混ざったときにデフォルト側のリストがどう変化するかは見落としやすく、意図せず古いデータが混入するバグの原因になる。", "kid": "1回目のcollect(1)はデフォルトの共有リストに1を追加する。2回目は明示的に新しい空リストを渡しているので共有リストとは別物になり、2だけが入った[2]になる。3回目は再びデフォルトの共有リストを使うので、1回目で追加された1が残ったまま3が足され[1, 3]になる。", "eg": "職場の共有ノート（デフォルトのlst）と、自分専用の新しいメモ用紙（明示的に渡した[]）の違いのようなもの。共有ノートに書き込んだ内容は次に共有ノートを使う人にも見えるが、自分専用のメモ用紙に書いたことは共有ノートには反映されない。", "terms": [["ミュータブルなデフォルト引数", "リストや辞書のような書き換え可能なオブジェクトを関数のデフォルト値にすること"], ["関数定義時の1回だけの評価", "デフォルト引数の式は関数を定義した瞬間に1回だけ評価され、以後の呼び出しではその同じオブジェクトが使い回される"]], "think": "collect(1)はlstを省略しているのでデフォルトの共有リスト（最初は[]）が使われ、append(1)で[1]になる（printしていないので表示されない）。print(collect(2, []))は明示的に新しい空リスト[]を渡しているので、これはデフォルトの共有リストとは別物。append(2)で[2]になり、これがそのまま出力される。共有リストは[1]のまま変化していない。print(collect(3))は再びlstを省略するのでデフォルトの共有リスト（[1]のまま）が使われ、append(3)で[1, 3]になりこれが出力される。よって出力は[2]の後に[1, 3]。", "vs": "毎回同じように省略して呼び出し続ける場合（既存の罠の典型例）は単純に値が積み上がっていくだけだが、今回のように途中で明示的な引数を挟むと、その回だけは共有リストから切り離される点が違う。", "opt": ["正解。lstを省略した呼び出しは共通のデフォルトリストを共有し積み上がっていくが、明示的に[]を渡した呼び出しはそのデフォルトリストとは別物になる。", "明示的に[]を渡した2回目の呼び出しは正しく[2]になるが、3回目は再びデフォルトの共有リストを使うため、1回目で追加された1が残ったまま[1, 3]になる。3回目だけが独立した新しいリストから始まるわけではない。", "2回目に明示的に渡した[]は共有リストとは別のオブジェクトなので、共有リスト側に2が紛れ込むことはない。", "1回目の呼び出しはprintされていないので、その時点の共有リストの中身が直接出力に現れることはない。2回目の出力は明示的に渡した空リストに2を足しただけの[2]。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"10\" y=\"16\" font-size=\"10\" fill=\"#8892a4\">lstを省略すると同じデフォルトリストを共有する</text><rect x=\"16\" y=\"32\" width=\"140\" height=\"64\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"86\" y=\"50\" font-size=\"10\" fill=\"#e8eaf0\" text-anchor=\"middle\">デフォルトのlst</text><text x=\"86\" y=\"68\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\">collect(1) → [1]</text><text x=\"86\" y=\"84\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\">collect(3) → [1, 3]</text><rect x=\"190\" y=\"32\" width=\"140\" height=\"40\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"260\" y=\"50\" font-size=\"10\" fill=\"#e8eaf0\" text-anchor=\"middle\">明示的に渡した []</text><text x=\"260\" y=\"66\" font-size=\"9\" fill=\"#c9a04a\" text-anchor=\"middle\">collect(2, []) → [2]</text><text x=\"16\" y=\"118\" font-size=\"9\" fill=\"#8892a4\">省略した呼び出しどうしだけが同じ実体を共有する</text></svg>"}'),

  ('python-drill-q67', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def introduce(name, age, job):
    return f"{name}({age}) is a {job}"

info = {"job": "QA", "name": "Yu", "age": 34}
print(introduce(**info))',
   '["Yu(34) is a QA", "QA(Yu) is a 34", "{''job'': ''QA'', ''name'': ''Yu'', ''age'': 34} is a QA", "エラーになる（辞書のキー順が関数の引数順と一致していない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（**による辞書のキーワード引数展開）", "point": "**を付けて辞書を展開すると、辞書のキー名と関数の引数名で対応付けられる。辞書に書いた順番は結果に影響しない。", "why_asked": "*で展開するときは値の並び順（位置）が引数の順番に対応するのに対し、**で展開するときは順番ではなく「名前」で対応する。この違いを取り違えると、辞書の並びを気にして無駄に順番を揃えようとしたり、逆に順番が違うだけでバグだと勘違いしたりする。", "kid": "info={\"job\": \"QA\", \"name\": \"Yu\", \"age\": 34}という辞書を**で展開すると、job=\"QA\", name=\"Yu\", age=34というキーワード引数として渡される。関数側はnameという名前の引数にはnameというキーの値が入るので、辞書に書いた順番がjob→name→ageでも結果は変わらず\"Yu(34) is a QA\"になる。", "eg": "宛名シールを名前で仕分ける郵便局員のようなもの。荷物が積まれている順番（辞書に書いた順）がバラバラでも、宛名（キー名）さえ合っていれば正しい人（引数）に届く。", "terms": [["**による辞書の展開", "辞書のキーを引数名、値を引数の値としてキーワード引数に変換して渡す書き方"], ["*による展開", "リストやタプルの要素を順番通りに位置引数として渡す書き方。**とは対応のさせ方が違う"]], "think": "info辞書は{\"job\": \"QA\", \"name\": \"Yu\", \"age\": 34}という順番で定義されているが、introduce(**info)は**によってキーワード引数展開されるので、実際にはintroduce(job=\"QA\", name=\"Yu\", age=34)と同じ意味になる。関数側の引数はname, age, jobという名前で受け取るので、辞書の書かれた順番に関係なくname=\"Yu\", age=34, job=\"QA\"が正しく対応する。f文字列はf\"{name}({age}) is a {job}\"なので、\"Yu(34) is a QA\"が出力される。", "vs": "もしinfoがリストやタプルで*info（アスタリスク1つ）による展開だったら、要素の並び順がそのまま引数の順番に対応するので、辞書のような順番を入れ替えた例では意図しない値の対応付けになっていた。**は名前ベース、*は順番ベースという違いが決め手。", "opt": ["正解。**による辞書展開はキー名で引数に対応付けられるので、辞書に書いた順番に関係なくname=\"Yu\", age=34, job=\"QA\"として渡される。", "この対応付けは辞書に書いた順番ではなく、辞書のキー名と関数の引数名の一致で決まる。*（アスタリスク1つ）でリストを展開する場合は順番が意味を持つが、**（2つ）は名前で対応する。", "**を付けているので辞書はキーワード引数へと展開され、辞書オブジェクトそのものが1つの引数として渡されるわけではない。", "**による展開は辞書のキー名と関数の引数名を突き合わせて対応付けるので、辞書に書く順番と関数の引数の並び順が一致している必要はない。"]}'),

  ('python-drill-q68', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def order(item, *, qty):
    return f"{item} x{qty}"

print(order("apple", 3))',
   '["エラーになる（qtyはキーワード引数でしか渡せない）", "apple x3", "apple xNone", "エラーになる（*の後に引数を書くとその関数定義自体がSyntaxErrorになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（*の後のキーワード専用引数）", "point": "引数リストの*より後ろにある引数は、呼び出すときに必ずキーワード（引数名=値）で渡さなければならない。位置引数として渡すとエラーになる。", "why_asked": "APIの設計で「この引数は名前を書いて渡してほしい（呼び出し側のコードを読みやすくしたい）」という意図を*で強制できるが、この文法を知らないと、いつも通り位置引数で渡してTypeErrorに遭遇し、原因がわからず戸惑う。", "kid": "def order(item, *, qty)の*より後ろにあるqtyは、呼び出すときに必ずqty=のようにキーワードで渡さないといけない決まり。order(\"apple\", 3)は3を位置引数として渡そうとしているので、この決まりに反してエラーになる。", "eg": "受付で「名前（qty）を名乗ってから渡してください」というルールの窓口のようなもの。名乗らずに黙って差し出しても（位置引数として渡しても）受け取ってもらえない。", "terms": [["キーワード専用引数", "*より後ろに書かれた引数。呼び出し時に必ずキーワード（引数名=値）で渡す必要がある"], ["*（単独のアスタリスク）", "それより前が位置引数、後ろがキーワード専用引数であることを区切る印。それ自体は引数を受け取らない"]], "think": "def order(item, *, qty)の*は「これより後ろの引数はキーワード専用」という区切りを表す。qtyはこの*より後ろにあるので、呼び出し時は必ずqty=3のようにキーワードで渡さなければならない。order(\"apple\", 3)は2つ目の3を位置引数として渡そうとしているが、qtyはキーワード専用なので位置引数としては受け取れず、TypeErrorになる。", "vs": "*を付けずにdef order(item, qty)と書けば、qtyは位置引数としてもキーワード引数としても渡せる。*を挟むことで「名前を書かないと渡せない」という制約を意図的に加えている点が違う。", "opt": ["正解。*より後ろのqtyはキーワード専用引数なので、order(\"apple\", 3)のように位置引数として3を渡すことはできずエラーになる。", "qtyは*より後ろにあるキーワード専用引数なので、位置引数として渡すとエラーになる。正常に\"apple x3\"が返ることはない。", "qtyにはデフォルト値が設定されていないので、渡し方が正しくてもNoneになることはなく、そもそも今回はエラーになる。", "*を関数定義の引数リストの途中に置くこと自体は正式な文法で、SyntaxErrorにはならない。エラーになるのは呼び出し側の渡し方が原因。"]}'),

  ('python-drill-q69', '関数と引数',
   'このコードを実行すると何が出力される？',
   'counter = [1, 2, 3]

def describe(x=len(counter)):
    return f"x is {x}"

counter.append(4)
counter.append(5)

print(describe())',
   '["x is 3", "x is 5", "x is [1, 2, 3, 4, 5]", "エラーになる（デフォルト引数にlen()のような関数呼び出しの結果は使えない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（デフォルト引数の式が評価されるタイミング）", "point": "デフォルト引数の式は関数を呼び出すたびにではなく、defで関数を定義した瞬間に1回だけ評価される。", "why_asked": "「デフォルト値は呼び出すたびに計算し直される」と思い込んでいると、今回のように後から元の変数を変更しても、既に確定したデフォルト値には反映されないという食い違いに気づけず、バグの原因を追えなくなる。", "kid": "def describe(x=len(counter))と書いた瞬間、その時点のcounterの長さ（3）がデフォルト値として確定する。あとからcounterに4や5を追加しても、確定済みのデフォルト値3には影響しない。", "eg": "写真を撮った瞬間（def実行時）の光景がそのまま焼き付けられる（デフォルト値が確定する）ようなもの。写真を撮ったあとで実際の景色（counter）が変わっても、すでに現像された写真の中身は変わらない。", "terms": [["デフォルト引数の評価タイミング", "デフォルト値の式はdefが実行される瞬間に1回だけ評価され、その結果の値が固定される"], ["len()", "リストなどの要素数を数える組み込み関数"]], "think": "counter = [1, 2, 3]が実行された後、def describe(x=len(counter)):が実行される。このとき、デフォルト値の式len(counter)がその場で1回だけ評価され、結果の3という整数がデフォルト値として確定する。そのあとcounter.append(4)とcounter.append(5)を実行してもcounterの中身は[1, 2, 3, 4, 5]に変わるが、describeのデフォルト値は既に3という整数として固定済みなので影響を受けない。print(describe())は引数を省略しているのでこの固定された3が使われ、\"x is 3\"が出力される。", "vs": "リストや辞書をデフォルト値にする「可変デフォルト引数の罠」は、確定した1つのオブジェクトを複数回の呼び出しで書き換えてしまう話。今回はlen()の戻り値という不変な整数が一度だけ計算されて固定される話で、「呼び出しをまたいで共有される」ではなく「呼び出しのたびに再計算されない」という別の側面を問うている。", "opt": ["正解。デフォルト値の式len(counter)はdefが実行された瞬間に1回だけ評価され3に固定される。あとからcounterを変更しても再計算されない。", "デフォルト値の式は関数の呼び出しごとに再評価されるわけではない。counterへの追加はdescribeのデフォルト値には反映されない。", "xにはlen(counter)の結果である整数が入るのであって、counterのリストそのものが入るわけではない。", "デフォルト引数には変数だけでなく関数呼び出しの結果を式として書くことができ、これは正式な文法でエラーにはならない。"]}'),

  ('python-drill-q70', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def compute(a, b, c=10):
    return a * b + c

print(compute(2, c=5, b=3))',
   '["11", "13", "エラーになる（位置引数の後にキーワード引数を書くことはできない）", "エラーになる（bとcの割り当てが重複してしまう）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（位置引数とキーワード引数を混在させた呼び出し）", "point": "キーワード引数は書いた順番に関係なく引数名で対応付けられる。位置引数の後にキーワード引数を続けるのは正式な書き方。", "why_asked": "「呼び出しに書いた順番通りに引数が割り当てられる」と思い込んでいると、キーワード引数をb、cの順で書かずc、bの順で書いたときに割り当てを誤解してしまう。位置引数とキーワード引数は仕組みが別ということを理解しておく必要がある。", "kid": "compute(2, c=5, b=3)は最初の2が位置引数としてaに入り、残りのc=5とb=3は書いた順番に関係なく名前でcとbにそれぞれ対応する。結局a=2, b=3, c=5となり、a*b+cは2*3+5で11になる。", "eg": "宅配便で、最初の荷物だけ「1番目の人へ」と番号で指定し、残りの荷物は宛名（引数名）を書いて渡すようなもの。宛名さえ書いてあれば、荷物を積んだ順番に関係なく正しい人に届く。", "terms": [["位置引数", "呼び出し時に書いた順番で対応付けられる引数"], ["キーワード引数", "引数名=値の形で書き、名前で対応付けられる引数。書く順番は結果に影響しない"]], "think": "compute(2, c=5, b=3)を呼び出すと、最初の2は名前を指定していない位置引数なので先頭のaに対応する。残りのc=5とb=3はどちらもキーワード引数で、名前で対応付けられるので書かれた順番に関係なくb=3, c=5となる。結果としてa=2, b=3, c=5が確定し、a * b + cは2 * 3 + 5で11になる。", "vs": "位置引数のみでcompute(2, 3, 5)と書けば書いた順番がそのままa, b, cに対応するが、今回のように一部をキーワード引数にすると、その部分は順番ではなく名前で対応する。位置引数の後にキーワード引数を続けるのは問題ないが、逆にキーワード引数の後に位置引数を書くとSyntaxErrorになる。", "opt": ["正解。位置引数の2はaに、キーワード引数のc=5とb=3は書かれた順番に関係なく名前でbとcに対応する。a=2, b=3, c=5なので2*3+5=11。", "キーワード引数は書かれた順番ではなく引数名で対応付けられる。c=5と書かれているからといって2番目に登場するbに5が入るわけではない。", "位置引数の後にキーワード引数を続けて書くのは正式な文法。位置引数(2)の後にキーワード引数(c=5, b=3)を続けても問題なく呼び出せる。", "aは位置引数の2、bとcはそれぞれ名前で指定されたキーワード引数なので、同じ引数に2回値を渡すような重複は起きていない。"]}'),

  ('python-drill-q71', '関数型プログラミング',
   'このコードを実行すると何が出力される？',
   'people = [("Yu", 34), ("Kei", 29), ("Rio", 34)]
result = sorted(people, key=lambda p: (-p[1], p[0]))
print(result)',
   '["[(''Rio'', 34), (''Yu'', 34), (''Kei'', 29)]", "[(''Yu'', 34), (''Rio'', 34), (''Kei'', 29)]", "[(''Kei'', 29), (''Yu'', 34), (''Rio'', 34)]", "エラーになる（key引数にタプルを返すことはできない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（sorted関数のkey引数とタプルによる複数キーソート）", "point": "key引数のタプルは前の要素が優先。マイナスを付ければ降順、そのままなら昇順で使い分けられる。", "why_asked": "sorted()のkey引数にタプルを渡す「複数キーソート」は実務でも頻出だが、符号の意味とタプルの優先順位を誤解しやすい。", "kid": "sorted()のkeyに(-p[1], p[0])というタプルを渡すと、まず年齢の大きい順（マイナスを付けているので降順）で並べ、年齢が同じ人がいたら名前のアルファベット順で並べ直す、という2段階の並べ替えになる。", "eg": "たとえるなら、テストの順位づけで「点数が高い順、同点なら名前順」という2段階のルールを1回の指示でまとめて伝えているようなもの。", "terms": [["sorted(iterable, key=...)", "keyに渡した関数の戻り値を基準に並べ替える。元のリストは変更されない"], ["タプルでの複数キー", "keyがタプルを返すと、1番目の要素を優先し、同じ場合だけ2番目の要素で比較する"], ["負号による降順", "数値の前に-を付けると、その項目だけ昇順を降順に反転できる"]], "think": "1行目でpeopleは3つのタプル。2行目のkey=lambda p: (-p[1], p[0])は各人を(-年齢, 名前)というタプルに変換する。Yuは(-34,''Yu'')、Keiは(-29,''Kei'')、Rioは(-34,''Rio'')。sorted()はこのタプルを小さい順に並べる。まず1番目の要素(-年齢)を比較すると、-34 < -29なので、年齢34の2人(Yu,Rio)が先、年齢29のKeiが最後。年齢34の2人は1番目の要素が同じ(-34)なので、2番目の要素(名前)で比較し、''Rio'' < ''Yu''なのでRioが先。よって[(''Rio'',34),(''Yu'',34),(''Kei'',29)]。", "vs": "符号を付け忘れてkey=lambda p: (p[1], p[0])と書くと、年齢が小さい順（昇順）になってしまう。降順にしたい列だけ選んでマイナスを付けるのがコツ。", "opt": ["正解。(-年齢, 名前)のタプルで比較するので、年齢降順→同年齢は名前昇順の順に並ぶ。", "同じ年齢の2人(Yu, Rio)について、元のリストの並び順がそのまま保たれると勘違いした場合の順序。実際にはp[0]による名前順の比較が働く。", "マイナスを付け忘れて年齢を昇順で比較した場合の順序。", "sorted()のkey関数はタプルを返してもエラーにはならず、要素ごとに順番に比較される。"]}'),

  ('python-drill-q72', '関数型プログラミング',
   'このコードを実行すると何が出力される？',
   'from functools import reduce
nums = [1, 2, 3, 4]
result1 = reduce(lambda acc, x: acc * x, nums)
result2 = reduce(lambda acc, x: acc * x, nums, 0)
print(result1, result2)',
   '["24 0", "24 24", "0 0", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（functools.reduceの初期値あり・なし）", "point": "reduceは初期値を省略するとリストの先頭要素を初期値として使う。初期値を明示すると、その値からスタートしてリストの全要素と演算する。", "why_asked": "reduceに初期値を渡すかどうかで結果が大きく変わる。特に掛け算で初期値に0を渡すと全部0になってしまうミスは実務でも起きやすい。", "kid": "result1は初期値なしなので1から始めて1×2×3×4=24。result2は初期値0からスタートするので0に何を掛けても0のまま、結局0になる。", "eg": "result1は『最初の箱の中身(1)から始めて残りを次々掛け合わせる』、result2は『空っぽの箱(0)から始めて掛け合わせる』ようなもの。0を種にすると何を掛けても0のままなのは当然。", "terms": [["functools.reduce(f, iterable, [初期値])", "iterableの要素を左から順にfで累積していく関数。初期値を省略すると先頭要素が初期値になる"], ["acc", "accumulatorの略。累積していく途中結果を表す慣習的な変数名"]], "think": "result1: 初期値省略なのでacc=1(先頭要素)からスタート。x=2でacc=1*2=2、x=3でacc=2*3=6、x=4でacc=6*4=24。result1=24。result2: 初期値0が明示されているのでacc=0からスタート。x=1でacc=0*1=0、以降ずっと0のまま。result2=0。print(result1, result2)は''24 0''。", "vs": "足し算(+)ならreduceの初期値を0にしても結果は変わらない(0は加算の単位元)が、掛け算(*)の単位元は1なので、初期値に0を渡すと結果が必ず0になってしまう。演算に応じて初期値の意味が変わることに注意。", "opt": ["正解。初期値省略のresult1は先頭の1から掛け始めて1×2×3×4=24。初期値0のresult2は0に何を掛けても0のままなので0になる。", "初期値の有無にかかわらず同じ結果になると考えると出てくる答えだが、初期値0を渡すと『0×1×2×3×4』を計算することになり、必ず0になってしまう。", "reduceは常に0から計算を始めると考えると出てくる答えだが、初期値を省略した場合はリストの先頭要素(1)が初期値として使われる。", "reduceに初期値を追加で渡す書き方(第3引数)は正しい文法で、エラーにはならない。"]}'),

  ('python-drill-q73', '関数型プログラミング',
   'このコードを実行すると何が出力される？',
   'def check(x):
    print(f"check({x})")
    return x > 2

nums = [1, 2, 3, 4]
result = any(check(n) for n in nums)
print(result)',
   '["check(1) → check(2) → check(3) → True", "check(1) → check(2) → check(3) → check(4) → True", "check(1) → check(2) → True", "True"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（any()の短絡評価）", "point": "any()はTrueを返す要素が見つかった時点でそれ以降の要素の評価を打ち切る(短絡評価)。check(4)は呼ばれない。", "why_asked": "any()/all()はジェネレータ式を渡すと要素を1つずつ評価しながら判定するため、途中で結果が確定した瞬間に残りの処理をスキップする。副作用(print、DBアクセスなど)がある関数と組み合わせると『全部の要素で処理が走る』と思い込むと痛い目を見る。", "kid": "any()はcheck(n)がTrueになった時点で残りを調べるのをやめる。check(1)とcheck(2)はFalse、check(3)でTrueになるので、check(4)は呼ばれずにresultはTrueになる。", "eg": "宝探しで箱を順番に開けて、当たりが1個見つかったらそこで探すのをやめるようなもの。当たりが3番目の箱に入っていたら、4番目の箱は開けずに終わる。", "terms": [["any(iterable)", "iterableの要素のどれか1つでもTrueならTrueを返す関数。Trueが見つかった時点で残りの評価をやめる短絡評価をする"], ["ジェネレータ式", "(check(n) for n in nums)のように、リストを作らずに1つずつ値を生成する式"], ["短絡評価", "結果が確定した時点で残りの評価を省略すること"]], "think": "any()はジェネレータ式の要素を1つずつ取り出しながら評価する。n=1: check(1)が呼ばれ''check(1)''と表示、1>2はFalse。n=2: check(2)が呼ばれ''check(2)''と表示、2>2はFalse。n=3: check(3)が呼ばれ''check(3)''と表示、3>2はTrue。ここでany()は『真の要素が見つかった』と確定するので、n=4は評価されずcheck(4)は呼ばれない。any()の戻り値Trueがresultに入り、print(result)で''True''が表示される。", "vs": "もしlist(check(n) for n in nums)のように先にリスト化してからany()に渡すと、リスト作成の時点で全要素のcheck()が呼ばれてしまい、check(4)も実行される。ジェネレータ式をそのままany()に渡すからこそ短絡評価が効く。", "opt": ["正解。any()はTrueが見つかった時点で打ち切る短絡評価をするので、check(3)がTrueを返した時点でcheck(4)は呼ばれない。", "any()がジェネレータ式の全要素を先に評価してから判定すると考えると出てくる答えだが、実際は要素を1つずつ評価しながら、Trueが見つかった時点で残りをスキップする。", "Trueを返したcheck(3)自体の呼び出し(と中のprint)がスキップされると考えると出てくる答えだが、check(3)はTrueを返す直前にちゃんと呼ばれてprintも実行される。スキップされるのはその後のcheck(4)だけ。", "any()がジェネレータ式そのものを評価せず、常に真として扱うと考えると出てくる答えだが、実際にはcheck()が呼ばれて中のprintも実行される。"]}'),

  ('python-drill-q74', '関数型プログラミング',
   'このコードを実行すると何が出力される？',
   'nums = [1, 2, 3]
doubled = map(lambda x: x * 2, nums)
print(list(doubled))
print(list(doubled))',
   '["[2, 4, 6] と []", "[2, 4, 6] と [2, 4, 6]", "エラーになる", "[] と []"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（mapオブジェクトは一度しか消費できないイテレータ）", "point": "mapはリストではなく、一度しか進めないイテレータを返す。list()で最後まで読み切ると、次にlist()しても中身は空になる。", "why_asked": "mapやfilter、zipの戻り値はイテレータであり、リストのように何度も使い回せると思い込むと、2回目のループやlist化で空の結果になって混乱する。", "kid": "最初のlist(doubled)でdoubledの中身を全部読み切って[2, 4, 6]を作る。2回目のlist(doubled)のときにはもう読み切った後で中身が残っていないので、空リスト[]になる。", "eg": "ベルトコンベアの上を一度だけ流れてくる荷物のようなもの。1回目に全部受け取ってしまったら、2回目にコンベアの前に立っても、もう流れてくる荷物は残っていない。", "terms": [["map(f, iterable)", "iterableの各要素にfを適用した結果を1つずつ生成するイテレータを返す関数(リストそのものではない)"], ["イテレータ", "要素を1つずつ順番にしか取り出せず、一度最後まで取り出すと空になる仕組み"], ["list(...)", "イテレータやその他のiterableから全要素を取り出してリストに変換する"]], "think": "1行目でdoubled = map(...)により、まだ何も計算されていないイテレータが作られる。2行目のprint(list(doubled))でイテレータが先頭から最後まで読み進められ、1,2,3それぞれを2倍した[2, 4, 6]が作られて表示される。この時点でdoubledは最後まで読み切られた状態になる。3行目のprint(list(doubled))では、doubledはもう読み進める要素が残っていないため、list()は空リスト[]を返す。", "vs": "リストにmap()の結果をあらかじめ変換してdoubled = list(map(lambda x: x * 2, nums))としておけば、doubledは普通のリストになり、何度使っても中身は減らない。map自体を使い回したいなら、都度list(map(...))を作り直す必要がある。", "opt": ["正解。mapは一度しか読み切れないイテレータを返すので、1回目のlist()で全部消費してしまうと、2回目のlist()は空リストになる。", "mapの結果がリストのように何度でも使い回せると考えると出てくる答えだが、実際にはmapは一度読み切ると空になるイテレータを返す。", "2回目にlist()を呼ぶとエラーになると考えると出てくる答えだが、空になったイテレータをlist()に渡してもエラーにはならず、単に空リストが返る。", "map()を作った時点で中身が失われると考えると出てくる答えだが、実際には1回目のlist(doubled)でちゃんと[2, 4, 6]が得られる。空になるのは2回目以降。"]}'),

  ('python-drill-q75', '文字列操作',
   'このコードを実行すると何が出力される？',
   'price = 1234.5
print(f"{price:,.2f}")
print(f"{42:05d}")',
   '["1,234.50 と 00042", "1234.50 と 00042", "1,234.5 と 00042", "1,234.50 と 42"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（f-stringの書式指定子）", "point": "書式指定子の,は3桁区切りのカンマを入れ、.2fは小数点以下を2桁に揃える。05dは全体を5桁にして空いた桁を0で埋める。", "why_asked": "f-stringの書式指定(:,.2fや:05dなど)は金額表示や桁揃えの出力で頻出だが、記号の意味(カンマ区切り、小数桁、ゼロ埋め幅)を覚えていないと出力の見た目を誤読しやすい。", "kid": "1つ目はprice(1234.5)を『3桁区切りのカンマ入り・小数点以下2桁』で表示するので1,234.50になる。2つ目は42を『5桁でゼロ埋め』するので00042になる。", "eg": "1つ目はレシートの金額表示のように桁区切りを入れて見やすくするようなもの。2つ目は駐車場のチケット番号を必ず5桁の数字で表示するために、足りない桁を0で埋めるようなもの。", "terms": [["f-string", "f\"...{式}...\"の形で、文字列の中に式の値を直接埋め込む書き方"], [":,.2f", "3桁区切りのカンマを入れ、小数点以下を2桁に固定する書式指定子"], [":05d", "整数を5桁の幅で表示し、空いた桁を0で埋める書式指定子"]], "think": "1行目、price=1234.5に対して{price:,.2f}が適用される。,は3桁ごとにカンマを入れる指定なので1234→1,234。.2fは小数点以下を2桁にする指定なので.5→.50。合わせて''1,234.50''。2行目、{42:05d}は42を10進整数(d)として全体を5桁の幅で表示し、足りない桁を0で埋める指定なので、42の前に0を3つ足して''00042''。", "vs": "カンマ区切りなしの.2fだけなら''1234.50''になり、桁区切りのカンマは入らない。また05dのd(整数)を忘れて05のように書くと構文エラーになるため、型指定子dは省略できない。", "opt": ["正解。,.2fで3桁区切りのカンマと小数点以下2桁を指定し、05dで5桁ゼロ埋めの整数を指定しているので、''1,234.50''と''00042''になる。", ",区切りが無視されると考えると出てくる答えだが、,.2fの,はちゃんと3桁ごとにカンマを入れる指定として効く。", ".2fが小数点以下の桁数を揃えないと考えると出てくる答えだが、.2fは小数点以下をちょうど2桁にする指定なので、1234.5は1,234.50と表示される。", "05dのゼロ埋めが効かないと考えると出てくる答えだが、05dは全体を5桁にして空いた桁を0で埋める指定なので、42は00042になる。"]}'),

  ('python-drill-q76', '文字列操作',
   'このコードを実行すると何が出力される？',
   'def add_exclaim(text):
    text += "!"
    return text

msg = "hello"
result = add_exclaim(msg)
print(msg, result)',
   '["hello hello!", "hello! hello!", "hello! hello", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（文字列の不変性と関数への値渡し）", "point": "文字列はイミュータブル(変更不可)なので、text += \"!\"はtextが指す文字列自体を書き換えるのではなく、新しい文字列を作ってtextに再代入するだけ。呼び出し元のmsgには影響しない。", "why_asked": "リストや辞書は関数の中で中身を変更すると呼び出し元にも影響する(ミュータブル)が、文字列は同じように渡してもイミュータブルなので影響しない。この違いを知らないと、関数の中で変数を書き換えたつもりが呼び出し元に反映されずハマる。", "kid": "add_exclaim関数の中でtext += \"!\"をしても、それは関数の中だけの新しい文字列を作っているだけで、呼び出し元のmsgはそのまま''hello''。関数が返した新しい文字列''hello!''だけがresultに入る。", "eg": "友達に手紙のコピーを渡して、友達がそのコピーに書き込みを足しても、あなたの手元の原本は書き換わらないようなもの。友達は自分の手元で新しい紙(新しい文字列)を作っているだけ。", "terms": [["イミュータブル", "一度作られたら中身を直接書き換えられない性質。文字列・数値・タプルなどが該当"], ["text += \"!\"", "text = text + \"!\"の省略形。文字列の場合は新しい文字列オブジェクトを作ってtextに代入し直す"]], "think": "msg = \"hello\"でmsgは''hello''を指す。add_exclaim(msg)が呼ばれると、関数内のtextという別名がmsgと同じ''hello''を指す状態で始まる。text += \"!\"は文字列がイミュータブルなため、''hello''を書き換えるのではなく新しく''hello!''という文字列を作り、それをtextに代入し直す。この時点でtextとmsgは別々の文字列を指すことになる。returnでtextの中身''hello!''が返され、resultに入る。msgは最初のまま''hello''なので、print(msg, result)は''hello hello!''。", "vs": "もし引数がリストで、関数内でtext.append(...)のようにミュータブルな操作をしていたら、呼び出し元のリストも一緒に変更される。文字列の+=は見た目が『書き換え』に見えても、実際は新しいオブジェクトへの代入なので呼び出し元には影響しない。", "opt": ["正解。文字列はイミュータブルなのでtext += \"!\"は新しい文字列を作ってtextに代入し直すだけで、呼び出し元のmsgには影響しない。msgは''hello''のまま、返り値のresultだけが''hello!''になる。", "関数の中でtextを変更すると呼び出し元のmsgも一緒に書き換わると考えると出てくる答えだが、それはリストなどミュータブルな型の場合の話。文字列はイミュータブルなのでmsgは変わらない。", "resultには変更前の値が返り、msgの方が書き換わると考えると出てくる答えだが、実際は逆で、関数の外のmsgは変わらず、関数が新しく作った文字列がresultとして返る。", "text += \"!\"のようにローカル変数に再代入する操作は文法的に正しく、エラーにはならない。"]}'),

  ('python-drill-q77', '文字列操作',
   'このコードを実行すると何が出力される？',
   'text = "  Hello, World!  "
text.strip()
text.replace("World", "Python")
print(repr(text))',
   '["''  Hello, World!  ''", "''Hello, World!''", "''  Hello, Python!  ''", "''Hello, Python!''"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（.strip()と.replace()の非破壊性）", "point": ".strip()も.replace()も元の文字列を変更せず、変更後の新しい文字列を戻り値として返すだけ。戻り値を変数に代入し直さない限り、元の変数の中身は変わらない。", "why_asked": "リストの.append()のように元のオブジェクトを直接書き換える(破壊的)メソッドと違い、文字列のメソッドはすべて新しい文字列を返すだけで元は変えない。戻り値を代入し忘れると『メソッドを呼んだのに変化していない』というバグになる。", "kid": "text.strip()もtext.replace(...)も、それぞれ変更後の新しい文字列をその場で作って返しているだけで、textには代入し直していない。だからtextは最初に作ったときのまま、前後にスペースが残り''World''のままの文字列になる。", "eg": "紙に書かれた文章のコピーを取って、コピーの方だけ手直しするようなもの。コピー(戻り値)がどれだけ修正されても、原本(text)はそのまま手つかずで残る。", "terms": [[".strip()", "文字列の前後の空白を取り除いた新しい文字列を返す。元の文字列は変更しない"], [".replace(old, new)", "oldをnewに置き換えた新しい文字列を返す。元の文字列は変更しない"], ["repr(text)", "文字列を引用符付きでそのまま表示する関数。前後の空白の有無がわかりやすい"]], "think": "1行目でtextは''  Hello, World!  ''(前後に半角スペース2個ずつ)。2行目text.strip()は前後の空白を除いた新しい文字列''Hello, World!''を作って返すが、その戻り値をどこにも代入していないので捨てられ、textは変わらない。3行目text.replace(\"World\", \"Python\")も同様に''  Hello, Python!  ''という新しい文字列を作って返すだけで、これも代入されず捨てられる。結局textは1行目のまま変化しておらず、print(repr(text))は元の''  Hello, World!  ''を表示する。", "vs": "リストの.sort()や.append()は元のリストを直接書き換える破壊的メソッドで戻り値はNoneだが、文字列のメソッドは逆に『戻り値を使う』ことが前提で、元の文字列自体は絶対に変更されない。text = text.strip()のように代入し直して初めてtextの中身が変わる。", "opt": ["正解。.strip()も.replace()も新しい文字列を返すだけで元のtextを書き換えないので、戻り値を代入し直していないtextは最初のまま前後のスペースと''World''を含んだ文字列になる。", ".strip()が元の文字列を直接書き換えると考えると出てくる答えだが、文字列はイミュータブルなので.strip()は新しい文字列を返すだけで元のtextの前後のスペースは残ったまま。", ".replace()が元の文字列を直接書き換えると考えると出てくる答えだが、.replace()も新しい文字列を返すだけで、代入し直していないtextの中身は''World''のままで変わらない。", ".strip()も.replace()も両方が元のtextを直接書き換えると考えると出てくる答えだが、どちらも新しい文字列を返すだけの非破壊的なメソッドなので、textはどちらの影響も受けない。"]}'),

  ('python-drill-q78', '文字列操作',
   'このコードを実行すると何が出力される？',
   's = "python"
print(s[1:4])
print(s[::-1])
print(s[::2])',
   '["yth と nohtyp と pto", "ytho と nohtyp と pto", "yth と python と pto", "yth と nohtyp と yhn"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（文字列のスライスと逆順[::-1]）", "point": "s[start:stop]はstop側のインデックスを含まない。s[::-1]はstepに-1を指定することで文字列全体を逆順にする。", "why_asked": "スライスの終端が『含まれない』ことと、step引数が負の値だと逆方向に進むことは、どちらも初見だと直感に反しやすく、コードレビューでバグの温床になりやすい。", "kid": "s[1:4]はインデックス1から3まで(4は含まない)の''yth''。s[::-1]はstepを-1にして文字列全体を後ろから前に並べ直した''nohtyp''。s[::2]は0から2つ飛ばしで拾った''pto''。", "eg": "s[1:4]は棚の1番目から3番目までの本を取り出して4番目は取らない、という『片方だけ開いた区間』の考え方。s[::-1]は本棚を逆向きに並べ替えるようなもの。", "terms": [["s[start:stop]", "startから始まりstopの1つ手前までの部分文字列を取り出す(stopのインデックスは含まれない)"], ["s[::-1]", "start・stopを省略し、step(歩幅)に-1を指定することで文字列を逆順にする書き方"], ["s[::2]", "start・stopを省略し、step(歩幅)に2を指定して1つ飛ばしに文字を拾う書き方"]], "think": "s=''python''は先頭からp(0) y(1) t(2) h(3) o(4) n(5)のインデックス。s[1:4]はインデックス1,2,3を取り出すのでy,t,h→''yth''(4番目のoは含まれない)。s[::-1]はstepが-1なので末尾から先頭に向かって全部の文字を拾い、n,o,h,t,y,p→''nohtyp''。s[::2]はインデックス0,2,4を2つ飛ばしで拾うのでp,t,o→''pto''。", "vs": "s[1:4]のように正のstepでの範囲指定は『stop側を含まない半開区間』だが、s[::-1]はstart・stopを省略してstepだけを負にすることで方向そのものを反転させる、まったく別の指定方法。両者を混同して[4:1:-1]のような書き方と勘違いしないよう注意。", "opt": ["正解。s[1:4]はインデックス4を含まない''yth''、s[::-1]は全体を逆順にした''nohtyp''、s[::2]は1つ飛ばしの''pto''になる。", "s[1:4]の終端インデックス4も含まれると考えると出てくる答えだが、スライスのstop側は含まれないので、4番目の文字''o''は取り出されず''yth''までになる。", "start・stopを省略してstepだけ指定しても向きは変わらないと考えると出てくる答えだが、stepに-1を指定すると文字列を逆順にたどるため、''nohtyp''になる。", "s[::2]が1番目のインデックスから2つ飛ばしで始まると考えると出てくる答えだが、start省略時は0番目から始まるため、0,2,4番目の''p'',''t'',''o''を拾った''pto''になる。"]}'),

  ('python-drill-q79', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'x = 10

def show():
    print(x)

show()',
   '["10", "エラーになる（UnboundLocalErrorになる）", "None", "エラーになる（NameErrorになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（関数内から外側の変数を参照するだけの場合のスコープ）", "point": "関数の中で代入をせず読み取るだけなら、Pythonはそのまま外側（グローバル）の変数を探しにいく。", "why_asked": "『関数の中でxを使っている＝xはローカル変数』と思い込みがちだが、実際は代入の有無でPythonの扱いが変わる。この基本を誤解していると、次のような『代入があるとエラーになるケース』で混乱する。", "kid": "showの中にはxを作る代入文が無いので、print(x)は外側で定義されたx=10をそのまま見にいって10と表示する。", "eg": "自分の部屋に無いものを借りたいとき、わざわざ買わずに家族の部屋（外側のスコープ）に見に行くようなもの。取りに行くだけなら誰の持ち物かは変わらない。", "terms": [["ローカル変数", "関数の中だけで有効な変数。関数の中で代入されると作られる"], ["グローバル変数", "モジュールの一番外側で定義された、どこからでも参照できる変数"], ["スコープ", "変数がどこから見えるかという有効範囲のルール"]], "think": "1行目でグローバル変数xに10が代入される。show()が呼ばれると、関数の中にxへの代入文が無いので、Pythonはxをローカル変数とは判断しない。print(x)はローカルスコープにxが無いことを確認してから外側のグローバルスコープを探し、そこにあるx=10を見つけて10を表示する。", "vs": "関数の中のどこかにx = ...という代入文が1行でもあると、Pythonはxを関数全体でローカル変数として扱うようになる。読むだけか代入もあるかで挙動が変わる点が最大の罠。", "opt": ["正解。関数の中でxへの代入が無いので、Pythonはそのまま外側のグローバル変数x=10を参照しにいく。", "代入文が無ければローカル変数は作られない。UnboundLocalErrorが起きるのは、関数の中に代入文があるのに代入前に参照した場合。", "xという名前の変数自体は存在しており、Noneではなく10という値が入っている。", "xはグローバルスコープに10として定義されているので、参照できずにNameErrorになることはない。"]}'),

  ('python-drill-q80', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'x = 10

def show():
    print(x)
    x = 20

show()',
   '["エラーになる（UnboundLocalErrorになる）", "10", "20", "エラーになる（NameErrorになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（関数内で同名変数に代入があるときのスコープの罠）", "point": "関数の中でどこか1行でもxに代入していると、その関数全体でxはローカル変数として扱われる。代入より前の行で読もうとするとUnboundLocalErrorになる。", "why_asked": "『関数の中に代入文がある』というだけで、Pythonはその行より前の参照も含めて関数全体をローカル扱いに切り替える。この『代入があると丸ごとローカル扱いになる』仕様を知らないと、動いていたはずのコードが急にエラーになって混乱する。", "kid": "showの中に x = 20 という代入文があるせいで、Pythonはxを関数全体でローカル変数だと判断する。ところがprint(x)はその代入より前に書かれているので、ローカル変数xはまだ値を持っておらず、参照しようとした瞬間にエラーになる。", "eg": "『これから自分の部屋に置く予定の本』を、置く前に本棚から取ろうとするようなもの。まだ自分の部屋には無いのに、家族の部屋（外側）を探しにいくことはせず、『自分の部屋にあるはず』で止まってしまう。", "terms": [["UnboundLocalError", "ローカル変数と判断された変数を、代入する前に参照しようとしたときに出るエラー"], ["ローカル変数", "関数の中で代入されると作られる、その関数の中だけで有効な変数"]], "think": "Pythonは関数を実行する前に関数全体を静的に見て、代入文がある変数をまとめてローカル変数として扱うと決める。showの中には x = 20 があるので、xはshow全体でローカル変数として扱われる。1行目のprint(x)が実行される時点では、まだ x = 20 が実行されておらずローカルのxには値が入っていない。代入前のローカル変数を参照しようとするのでUnboundLocalErrorになる。", "vs": "関数内にxへの代入が一切無ければ、print(x)は外側のグローバル変数を素直に参照して10になる。1行でも代入文が追加されるだけで挙動がガラッと変わるのがこの罠の本質。", "opt": ["正解。x = 20という代入文があるせいでxは関数全体でローカル変数として扱われ、代入より前のprint(x)は値の無いローカル変数を参照しようとしてUnboundLocalErrorになる。", "この10はグローバル変数の値だが、関数内に代入文があるためprint(x)はグローバル変数ではなくローカル変数のxを参照しようとしてエラーになる。", "x = 20はprint(x)より後に実行されるので、print(x)が呼ばれる時点ではまだxに20は入っていない。", "xという名前自体はグローバルスコープに存在しており、名前が見つからないNameErrorではない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" fill=\"#e8eaf0\" font-size=\"11\" text-anchor=\"middle\" font-weight=\"600\">代入が1つでもあると関数全体がローカル扱い</text>\n<rect x=\"30\" y=\"26\" width=\"280\" height=\"24\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/>\n<text x=\"170\" y=\"42\" fill=\"#8892a4\" font-size=\"9.5\" text-anchor=\"middle\">グローバル: x = 10</text>\n<rect x=\"30\" y=\"66\" width=\"280\" height=\"56\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.3\"/>\n<text x=\"170\" y=\"80\" fill=\"#60a5fa\" font-size=\"9.5\" text-anchor=\"middle\" font-weight=\"600\">show() のローカルスコープ</text>\n<text x=\"45\" y=\"98\" fill=\"#e8eaf0\" font-size=\"9\">① print(x) ← ここではまだ空</text>\n<text x=\"45\" y=\"112\" fill=\"#e8eaf0\" font-size=\"9\">② x = 20 ← この代入でローカル確定</text>\n<line x1=\"170\" y1=\"66\" x2=\"170\" y2=\"52\" stroke=\"#c9a04a\" stroke-width=\"1.3\"/>\n<text x=\"235\" y=\"60\" fill=\"#c9a04a\" font-size=\"9\" text-anchor=\"middle\">外へは出られない×</text>\n</svg>"}'),

  ('python-drill-q81', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'x = 10

def update():
    global x
    x = 20

update()
print(x)',
   '["20", "10", "エラーになる（UnboundLocalErrorになる）", "エラーになる（xは関数の外では未定義になる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（globalキーワードで外側の変数を書き換える）", "point": "関数の中でglobal xと宣言すると、そのxはローカル変数ではなく外側のグローバル変数そのものを指すようになり、代入すると外側の値も変わる。", "why_asked": "globalを付け忘れると前の問題のようにUnboundLocalErrorになるし、globalを使えば逆に外側の値を書き換えられる。この対称性を理解していないと、状態を持つ関数を書くときに意図せず変数がローカルとグローバルの間で食い違う。", "kid": "update()の中でglobal xと宣言しているので、x = 20はローカル変数を新しく作るのではなく、外側のグローバル変数xそのものを20に書き換える。だからupdate()を呼んだ後にグローバルのxを見ると20になっている。", "eg": "『これは自分の部屋の本ではなく、共有本棚の本として扱います』と宣言してから本を入れ替えるようなもの。宣言した後の変更は共有本棚（グローバル）に反映される。", "terms": [["global", "関数の中で、指定した変数をローカル変数ではなく外側のグローバル変数として扱う宣言"], ["グローバル変数", "モジュールの一番外側で定義された、どこからでも参照・書き換えできる変数"]], "think": "1行目でグローバル変数xに10が入る。update()の中でglobal xと宣言しているので、この関数の中のxはローカル変数ではなくグローバル変数xそのものを指す。x = 20が実行されると、グローバルのxが20に書き換わる。update()を呼び出した後にprint(x)を実行すると、書き換わった後の20が表示される。", "vs": "globalが無い状態でx = 20とだけ書くと、xはローカル変数として扱われてしまい外側のxには影響しない（しかも代入より前に参照するとUnboundLocalErrorにもなる）。globalの有無で『別のローカル変数を作るだけ』か『外側を書き換える』かが完全に変わる。", "opt": ["正解。global xと宣言しているので、x = 20は新しいローカル変数ではなく外側のグローバル変数xを書き換える。update()の後にxを見ると20になっている。", "globalが無ければxはローカル変数として扱われ外側には影響しないが、この問題ではglobal xと宣言しているので外側のxが書き換わる。", "global xと宣言してから代入しているので、参照前に代入されていないという状況にはならずエラーにはならない。", "global宣言によって関数の中からグローバル変数を書き換えられるので、関数の外でxが未定義になることはない。"]}'),

  ('python-drill-q82', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'def outer():
    msg = "hello"
    def inner():
        print(msg)
    inner()

outer()',
   '["hello", "エラーになる（msgが定義されていない）", "None", "エラーになる（NameErrorになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（入れ子関数＝クロージャが外側のローカル変数を参照する）", "point": "内側の関数は、自分のローカル変数に無い名前を、外側の関数のローカル変数まで遡って探しにいける。これがクロージャの基本。", "why_asked": "『関数の中の変数は他の関数から見えない』と思い込んでいると、入れ子関数を使ったコード（デコレータやコールバックなど）でどの変数がどこまで見えるのか判断できなくなる。", "kid": "outer()の中でmsgに''hello''が入る。inner()はouter()の内側で定義された関数なので、自分自身の中にmsgという変数が無くても、外側のouter()が持つmsgをそのまま覗きにいって''hello''を表示できる。", "eg": "子部屋（inner）に自分の持ち物が無くても、親部屋（outer）に置いてあるものはドアを開けて覗きにいける、というイメージ。孫部屋があればさらにその外も辿れる。", "terms": [["クロージャ", "外側の関数が持つ変数を覚えたまま動く、入れ子になった内側の関数"], ["スコープチェーン", "変数を探すときにローカル→外側の関数→グローバル→組み込みの順に遡っていく仕組み"]], "think": "outer()が呼ばれるとローカル変数msgに''hello''が入る。続いてouter()の中でinner()が定義され、すぐに呼び出される。inner()の中にはmsgという名前のローカル変数の定義が無いので、Pythonはinner自身のローカルスコープに無いと分かった時点で1つ外側、つまりouter()のローカルスコープを探しにいき、そこにあるmsg=''hello''を見つけてprintする。", "vs": "もしinner()の中でmsg = ''bye''のような代入文があると、『代入があるとローカル扱いになる』ルールにより、inner()の中のmsgはouter()のmsgとは別の新しいローカル変数になってしまい、outer()側のmsgは覗きにいけなくなる（この場合はnonlocalが必要）。", "opt": ["正解。inner()は自分の中にmsgが無いので、1つ外側のouter()が持つローカル変数msg=''hello''を探しにいって表示する。", "inner()はouter()の内側で定義された関数なので、outer()のローカル変数msgをそのまま参照できる。定義されていないという扱いにはならない。", "msgという変数自体は外側のouter()のスコープにきちんと存在しており、値がNoneになることはない。", "inner()は自分のスコープに無い名前を、外側の関数のスコープまで遡って探すので、見つからずにNameErrorになることはない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" fill=\"#e8eaf0\" font-size=\"11\" text-anchor=\"middle\" font-weight=\"600\">内側の関数は外側のローカル変数を覗ける</text>\n<rect x=\"20\" y=\"30\" width=\"300\" height=\"90\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/>\n<text x=\"35\" y=\"46\" fill=\"#8892a4\" font-size=\"9.5\">outer() のスコープ</text>\n<text x=\"35\" y=\"62\" fill=\"#e8eaf0\" font-size=\"9.5\">msg = \"hello\"</text>\n<rect x=\"45\" y=\"72\" width=\"250\" height=\"38\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.3\"/>\n<text x=\"60\" y=\"88\" fill=\"#60a5fa\" font-size=\"9.5\" font-weight=\"600\">inner() のスコープ</text>\n<text x=\"60\" y=\"102\" fill=\"#e8eaf0\" font-size=\"9.5\">print(msg) ← 外側を覗きに行く</text>\n<line x1=\"90\" y1=\"72\" x2=\"90\" y2=\"62\" stroke=\"#c9a04a\" stroke-width=\"1.3\"/>\n</svg>"}'),

  ('python-drill-q83', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'def counter():
    count = 0
    def increment():
        nonlocal count
        count += 1
        return count
    increment()
    increment()
    print(count)

counter()',
   '["2", "0", "1", "エラーになる（UnboundLocalErrorになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（nonlocalで外側の関数のローカル変数を書き換える）", "point": "入れ子関数の中から一つ外側の関数のローカル変数を書き換えたいときは、nonlocalで宣言する。globalとは違い『外側の関数のローカル変数』を指す点が違う。", "why_asked": "クロージャで『外側の値を数えて増やしていく』ようなコードを書くとき、nonlocalを付け忘れるとincrement()の中でcountがローカル変数扱いになり、代入前に参照してUnboundLocalErrorになる。globalと混同して外側がグローバル変数の場合しか効かないと思い込むのもよくある勘違い。", "kid": "counter()の中のcountは0からスタートする。increment()の中でnonlocal countと宣言しているので、count += 1は外側のcounter()が持つcountそのものを書き換える。increment()を2回呼ぶたびに1ずつ増えるので、2回呼んだ後のcountは2になる。", "eg": "一つ外の部屋にあるホワイトボードの数字を、自分の部屋からペンで書き換えにいくようなもの。自分の部屋に同じ名前の新しいホワイトボードを作るのではなく、外の部屋のものを直接書き換える。", "terms": [["nonlocal", "入れ子関数の中から、1つ外側の関数のローカル変数を参照・書き換えるための宣言"], ["クロージャ", "外側の関数の変数を覚えたまま動く内側の関数"]], "think": "counter()が呼ばれるとcountが0で作られる。1回目のincrement()の呼び出しでは、nonlocal countのおかげでcount += 1が外側のcounterのcountを1に書き換える。2回目のincrement()の呼び出しで、同じcountが1から2に書き換わる。最後のprint(count)はcounter()自身のcountを参照するので2が表示される。", "vs": "increment()の中にnonlocal countが無いと、count += 1はincrement()専用の新しいローカル変数を作ろうとする挙動になり、右辺のcountを読む時点でまだローカルのcountに値が無いためUnboundLocalErrorになる（globalではなく外側の関数のローカル変数を指すのがnonlocalの役目）。", "opt": ["正解。nonlocal countによってincrement()の中のcount += 1はcounter()側のcountを直接書き換える。2回呼ぶので0→1→2と増えて最終的に2になる。", "nonlocalが無ければ外側は書き換わらずcountは0のままだが、この問題ではnonlocal countがあるので外側のcountが増えていく。", "1回分の増加しか反映されていないと考えると1になるが、increment()は2回呼ばれておりnonlocalのおかげで両方とも外側のcountに反映される。", "nonlocalは1つ外側の関数のローカル変数を指す宣言であり、UnboundLocalErrorが起きるのはこの宣言を書き忘れた場合。"]}'),

  ('python-drill-q84', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'funcs = [lambda: i for i in range(3)]
print([f() for f in funcs])',
   '["[2, 2, 2]", "[0, 1, 2]", "[0, 0, 0]", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（ループでlambdaを複数作るときの変数の遅延束縛）", "point": "lambdaは変数iの『その時点の値』ではなく『変数iそのもの』を覚える。呼び出す時点で改めてiの値を見にいくので、ループが終わった後の最後の値（2）が全員分共通で使われる。", "why_asked": "『for文の中でlambdaやコールバックを作れば、その時のループ変数の値がそれぞれ個別に固定される』という思い込みは非常に多い勘違いで、実際は全部が同じ変数を共有してしまう。イベントハンドラやコールバックのリストを作るコードで実際にバグになりやすい。", "kid": "range(3)でiが0,1,2と変わりながらlambda: iが3個作られるが、どのlambdaも自分専用のiを持つのではなく、同じ1つのiという変数を見ている。ループが終わった時点でiは最後の値2になっているので、後からどのlambdaを呼んでも2が返ってくる。", "eg": "3人にそれぞれ『今の時刻を教えて』と頼むのではなく、3人に同じ時計を指し示して『後で見て教えて』と頼むようなもの。実際に見るタイミングが全員同じなら、答えも全員同じになる。", "terms": [["遅延束縛", "変数の値をその場でコピーするのではなく、実際に使われる時点で改めて変数を見にいく仕組み"], ["リスト内包表記", "[式 for 変数 in 反復可能オブジェクト]の形で新しいリストを作る書き方"]], "think": "funcsを作る内包表記の中で、iはrange(3)の中で0→1→2と変わっていく1つの変数として扱われる。lambda: iはその時点のiの値をコピーするのではなく、iという変数そのものを覚える。内包表記が終わった時点でiの値は2になっている。その後[f() for f in funcs]で3つのlambdaを順に呼び出すと、どれも同じ変数iを見にいくので、全部2という値が返ってくる。結果は[2, 2, 2]になる。", "vs": "この問題を回避したいときは、lambda i=i: iのようにデフォルト引数として現在の値を都度コピーして固定する書き方がよく使われる。デフォルト引数の値は定義時に評価される（別の問題のテーマ）ので、iの値がその瞬間にスナップショットされる。", "opt": ["正解。すべてのlambdaは同じ変数iを見にいく形で作られており、呼び出される時点でiはループが終わった後の最後の値2になっているので、全部2が返ってくる。", "各lambdaがその時点のiの値を個別にコピーして持っていると考えるとこうなるが、実際はどのlambdaも同じ変数iを共有して見にいく。", "iの最終値が2であって0ではないので、全部0になることはない。", "lambdaを定義する時点でも呼び出す時点でも、iという変数の参照自体は問題なく行えるのでエラーにはならない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" fill=\"#e8eaf0\" font-size=\"11\" text-anchor=\"middle\" font-weight=\"600\">3つのlambdaが同じiを共有して覗いている</text>\n<rect x=\"130\" y=\"30\" width=\"80\" height=\"26\" rx=\"4\" fill=\"none\" stroke=\"#c9a04a\" stroke-width=\"1.3\"/>\n<text x=\"170\" y=\"47\" fill=\"#c9a04a\" font-size=\"10\" text-anchor=\"middle\" font-weight=\"600\">i（最終値=2）</text>\n<rect x=\"20\" y=\"80\" width=\"80\" height=\"30\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/>\n<text x=\"60\" y=\"99\" fill=\"#e8eaf0\" font-size=\"9\" text-anchor=\"middle\">lambda: i</text>\n<rect x=\"130\" y=\"80\" width=\"80\" height=\"30\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/>\n<text x=\"170\" y=\"99\" fill=\"#e8eaf0\" font-size=\"9\" text-anchor=\"middle\">lambda: i</text>\n<rect x=\"240\" y=\"80\" width=\"80\" height=\"30\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/>\n<text x=\"280\" y=\"99\" fill=\"#e8eaf0\" font-size=\"9\" text-anchor=\"middle\">lambda: i</text>\n<line x1=\"60\" y1=\"80\" x2=\"160\" y2=\"56\" stroke=\"#8892a4\" stroke-width=\"1\"/>\n<line x1=\"170\" y1=\"80\" x2=\"170\" y2=\"56\" stroke=\"#8892a4\" stroke-width=\"1\"/>\n<line x1=\"280\" y1=\"80\" x2=\"180\" y2=\"56\" stroke=\"#8892a4\" stroke-width=\"1\"/>\n<text x=\"170\" y=\"128\" fill=\"#8892a4\" font-size=\"9.5\" text-anchor=\"middle\">呼び出す時にはループが終わりiは2 → 全部2</text>\n</svg>"}'),

  ('python-drill-q85', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'counter = 100

def show(x=counter):
    print(x)

counter = 200
show()',
   '["100", "200", "エラーになる", "None"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（デフォルト引数は関数定義時に評価される）", "point": "デフォルト引数x=counterのcounterは、def showが実行された瞬間（定義時）に評価されてその値がコピーされる。後でcounterを再代入しても、既に確定した既定値には影響しない。", "why_asked": "『デフォルト引数はshow()を呼ぶたびに、その時点の変数の値を見にいく』と思い込みがちだが、実際は定義された1回だけ評価される。設定値やタイムスタンプをデフォルト引数にしたコードで、値が更新されないバグの典型原因になる。", "kid": "def show(x=counter)の行が実行された時点でcounterは100なので、xの既定値は100として確定する。その後counterを200に変えても、確定済みの既定値100は変わらないので、show()を呼ぶとxには100が入る。", "eg": "写真を撮った瞬間の景色をそのまま額縁に入れて飾るようなもの。撮った後に実際の景色が変わっても、額縁の中の写真（確定した既定値）は変わらない。", "terms": [["デフォルト引数", "関数を呼ぶときに値を省略した場合に使われる、あらかじめ決めておく引数の値"], ["定義時に評価", "関数の本体とは違い、デフォルト引数の値は関数を定義した瞬間に1回だけ計算されて確定すること"]], "think": "1行目でcounterに100が入る。def show(x=counter)が実行される時点で、Pythonはcounterの現在の値100を読み取ってxの既定値として確定させる。この時点でdef自体は関数の本体（print(x)）をまだ実行しない。次にcounter = 200でグローバル変数counterが200に変わるが、これは既に確定した既定値には影響しない。show()を引数無しで呼ぶと、確定済みの既定値100がxに入り、print(x)は100を表示する。", "vs": "関数の本体（この場合print(x)）は呼び出されるたびに毎回実行され、その時点の変数の値を見にいく。デフォルト引数の値だけが例外的に定義時に1回だけ確定する点が、通常の変数参照との違い。", "opt": ["正解。x=counterのcounterはdef showが実行された定義時に100として確定するので、後でcounterを200に変えてもxの既定値は100のまま。", "デフォルト引数が呼び出しのたびに再評価されると考えるとこうなるが、実際は定義時の1回だけ評価されて確定する。", "xの既定値の参照自体はエラーになる操作ではなく、確定済みの100が問題なくxに入る。", "xには確定済みの数値100が入っており、Noneが入ることはない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" fill=\"#e8eaf0\" font-size=\"11\" text-anchor=\"middle\" font-weight=\"600\">デフォルト引数は定義した瞬間に値が固定される</text>\n<line x1=\"30\" y1=\"70\" x2=\"310\" y2=\"70\" stroke=\"#2a2f3f\" stroke-width=\"1.3\"/>\n<circle cx=\"60\" cy=\"70\" r=\"4\" fill=\"#c9a04a\"/>\n<text x=\"60\" y=\"55\" fill=\"#c9a04a\" font-size=\"9\" text-anchor=\"middle\">def show(x=counter)</text>\n<text x=\"60\" y=\"90\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">counter=100を確定</text>\n<circle cx=\"170\" cy=\"70\" r=\"4\" fill=\"#e8eaf0\"/>\n<text x=\"170\" y=\"55\" fill=\"#e8eaf0\" font-size=\"9\" text-anchor=\"middle\">counter = 200</text>\n<text x=\"170\" y=\"90\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">xには影響しない</text>\n<circle cx=\"280\" cy=\"70\" r=\"4\" fill=\"#60a5fa\"/>\n<text x=\"280\" y=\"55\" fill=\"#60a5fa\" font-size=\"9\" text-anchor=\"middle\">show()</text>\n<text x=\"280\" y=\"90\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">x=100のまま出力</text>\n</svg>"}'),

  ('python-drill-q86', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'def loud(func):
    def wrapper():
        return func().upper()
    return wrapper

@loud
def greet():
    return "hello"

print(greet())',
   '["HELLO", "hello", "None", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（デコレータの基本＝関数をラップした別の関数に置き換える）", "point": "@loudを付けると、greetという名前には元のgreet関数ではなく、loud(greet)が返したwrapper関数が入る。greet()を呼ぶと実際にはwrapperが動き、元のgreet()の戻り値を加工してから返す。", "why_asked": "デコレータは『元の関数の前後に処理を足すもの』とだけ覚えていると、戻り値そのものを加工して別の値に差し替えるタイプのデコレータ（今回のように大文字化する等）に出会ったときに、何が返ってくるか判断できなくなる。", "kid": "@loudのおかげで、greetという名前には実際にはloud(greet)が返したwrapper関数が入っている。greet()を呼ぶとwrapperが動き、その中で元のgreet関数を呼んで''hello''を受け取り、それを.upper()で大文字にした''HELLO''を返す。", "eg": "翻訳者(wrapper)が元のスピーカー(greet)の発言を受け取ってから、大きな声で言い直して伝えるようなもの。聞こえてくるのは翻訳者が言い直した後の声。", "terms": [["デコレータ", "@名前という書き方で関数を受け取り、別の関数に置き換える仕組み"], [".upper()", "文字列のメソッドで、アルファベットをすべて大文字にした新しい文字列を返す"]], "think": "@loudはgreetをloud(greet)の戻り値であるwrapper関数に置き換える。print(greet())を実行すると、実際にはwrapper()が呼ばれる。wrapperの中身はfunc().upper()で、funcは元のgreet関数なのでfunc()を呼ぶと''hello''が返る。それに.upper()を適用すると''HELLO''になり、これがwrapperの戻り値としてprintに渡される。", "vs": "デコレータが値を返さず、元の関数の実行前後にprintだけ挟むタイプとは違い、このloudは元の戻り値そのものを受け取って加工してから返している点が特徴。デコレータは『前後に処理を挟む』だけでなく『戻り値を差し替える』こともできる。", "opt": ["正解。greet()の実体はwrapperになっており、wrapperは元のgreet()の戻り値''hello''を受け取って.upper()で大文字にした''HELLO''を返す。", "greetという名前に入っているのは実際にはwrapper関数なので、元のgreet()がそのまま返す''hello''ではなく、wrapperが加工した後の値が返る。", "wrapperはfunc().upper()の結果をきちんとreturnしているので、戻り値が無いNoneにはならない。", "func()もupper()も正常に動作する通常の関数呼び出しとメソッド呼び出しなので、エラーにはならない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" fill=\"#e8eaf0\" font-size=\"11\" text-anchor=\"middle\" font-weight=\"600\">@loud は greet を wrapper に置き換える</text>\n<rect x=\"30\" y=\"35\" width=\"110\" height=\"34\" rx=\"4\" fill=\"none\" stroke=\"#8892a4\" stroke-width=\"1.2\"/>\n<text x=\"85\" y=\"56\" fill=\"#e8eaf0\" font-size=\"9.5\" text-anchor=\"middle\">元のgreet()</text>\n<text x=\"150\" y=\"56\" fill=\"#c9a04a\" font-size=\"14\" text-anchor=\"middle\">→</text>\n<rect x=\"165\" y=\"30\" width=\"145\" height=\"60\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.3\"/>\n<text x=\"237\" y=\"46\" fill=\"#60a5fa\" font-size=\"9.5\" text-anchor=\"middle\" font-weight=\"600\">wrapper()</text>\n<text x=\"237\" y=\"62\" fill=\"#e8eaf0\" font-size=\"9\" text-anchor=\"middle\">func().upper()</text>\n<text x=\"237\" y=\"76\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">を実行して返す</text>\n<text x=\"170\" y=\"112\" fill=\"#8892a4\" font-size=\"9.5\" text-anchor=\"middle\">greet という名前には wrapper が入る</text>\n</svg>"}'),

  ('python-drill-q87', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'def logger(func):
    def wrapper():
        print("start")
        func()
        print("end")
    return wrapper

@logger
def task():
    print("working")

task()',
   '["1行目に''start''、2行目に''working''、3行目に''end''が出力される", "1行目に''working''、2行目に''start''、3行目に''end''が出力される", "1行目に''start''、2行目に''end''、3行目に''working''が出力される", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（デコレータが関数の実行前後に処理を挟む）", "point": "@loggerによってtask()の実体はwrapper()に置き換わっている。wrapperの中でfunc()（元のtask）を呼ぶ前後にprintを挟んでいるので、その順番どおりに出力される。", "why_asked": "デコレータの中身がいつ実行されるかを誤解していると、『前処理・本体・後処理』を挟むログ出力やタイマー計測のようなデコレータを書いたときに、狙った順序で処理が挟まっているか確認できなくなる。", "kid": "task()を呼ぶと、実際にはwrapper()が動く。wrapperはまず''start''を表示し、その後にfunc()＝元のtaskを実行して''working''を表示し、最後に''end''を表示する。だから3行がstart→working→endの順で出る。", "eg": "受付で『開始しました』と声をかけてから作業員が仕事をして、終わったら『終了しました』と声をかけるようなもの。声かけ（デコレータの処理）が作業の前後を挟む。", "terms": [["デコレータ", "関数を受け取り、別の関数（ラップした関数）に置き換える仕組み"], ["wrapper", "デコレータの中で定義される、元の関数を呼び出しつつ前後に処理を追加する関数"]], "think": "@loggerが付いているので、taskという名前には実際にはlogger(task)の戻り値であるwrapperが入っている。task()を呼ぶと実際にはwrapper()が実行される。wrapperの中身は上から順に実行され、まずprint(''start'')、次にfunc()つまり元のtaskが呼ばれてprint(''working'')、最後にprint(''end'')が実行される。", "vs": "もしfunc()の呼び出しをwrapperの一番最初に書いていたら、''working''が最初に出力されていた。前処理と後処理をどこに書くかで出力順が変わる点が、デコレータを書くときの実務上の注意点。", "opt": ["正解。wrapper()の中でprint(''start'')→func()（元のtaskで''working''を出力）→print(''end'')の順に実行されるので、start・working・endの順で出力される。", "task()を呼んでもtaskという名前に入っているのは実際にはwrapperなので、元のtaskの中身（''working''）が先に動くわけではない。", "func()の呼び出しはwrapperの中の2番目に書かれているので、''end''よりも先に''working''が出力される。", "wrapperの中身は全て通常のprintと関数呼び出しで、例外は発生しないのでエラーにはならない。"]}'),

  ('python-drill-q88', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'def logger(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@logger
def greet():
    """Say hello"""
    pass

print(greet.__name__)',
   '["wrapper", "greet", "logger", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（functools.wrapsを使わないデコレータの副作用）", "point": "デコレータを付けると、元の関数名（greet）には実際にはデコレータが返したwrapper関数が入る。functools.wrapsで元の情報をコピーしない限り、__name__もwrapperのままになる。", "why_asked": "デバッグやログ出力、ドキュメント生成のツールは関数の__name__を頼りにすることが多い。functools.wrapsを付け忘れると、エラーログやドキュメントに本来の関数名ではなく''wrapper''とだけ表示されてしまい、原因調査が難航する。", "kid": "@loggerを付けると、greetという名前には実際にはlogger(greet)が返したwrapper関数が入る。wrapper関数自体の名前は''wrapper''なので、greet.__name__を見ると元のgreetではなく''wrapper''と表示される。", "eg": "代理人（wrapper）が本人（greet）の名刺を持たずに窓口対応するようなもの。名刺（__name__）を確認すると、本人の名前ではなく代理人の名前が出てくる。", "terms": [["__name__", "関数オブジェクトが持つ、その関数の名前を表す属性"], ["functools.wraps", "デコレータの中でwrapper関数に元の関数の__name__などの情報をコピーするための道具"]], "think": "@loggerはgreetをlogger(greet)の戻り値に置き換える。logger関数はwrapperという名前の内側の関数を定義してそれをreturnしているので、greetという名前が指す先は実際にはwrapper関数のオブジェクトになる。greet.__name__はそのオブジェクト自身の__name__属性を見るので、''wrapper''という文字列が表示される。", "vs": "logger関数の中でfunctools.wraps(func)をwrapperに付けると、wrapperの__name__や__doc__が元のfunc（ここではgreet）のものにコピーされ、greet.__name__は本来の''greet''に戻る。名前を変えたくないなら忘れずに付けるべき仕組み。", "opt": ["正解。デコレータによってgreetという名前には実際にはwrapper関数が入っており、functools.wrapsを使っていないのでwrapperの__name__である''wrapper''がそのまま表示される。", "functools.wrapsで元の名前をコピーしていれば''greet''になるが、このコードにはfunctools.wrapsが無いので元の名前は引き継がれない。", "wrapperの名前がloggerに変わるわけではない。__name__はwrapper自身の関数名を指す。", "__name__属性の参照自体はエラーにならない普通の操作なので、実行時エラーにはならない。"]}'),

  ('python-drill-q89', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'def bold(func):
    def wrapper():
        return "<b>" + func() + "</b>"
    return wrapper

def italic(func):
    def wrapper():
        return "<i>" + func() + "</i>"
    return wrapper

@bold
@italic
def text():
    return "hi"

print(text())',
   '["<b><i>hi</i></b>", "<i><b>hi</b></i>", "<b>hi</b>", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（複数のデコレータを重ねたときの適用順序）", "point": "デコレータが複数重なっているとき、関数に近い（下にある）デコレータから先に適用され、その結果をさらに上のデコレータが包む。", "why_asked": "@bold @italicと縦に並んでいると上から順に効くと思いがちだが、実際は関数に一番近い下側から適用される。ログ出力用と認証用のデコレータを重ねるようなコードでは、この順序を誤解しているとどちらの処理が先に走るか読み間違える。", "kid": "text関数に一番近いのは@italicなので、まずitalicがtextを包んで''<i>hi</i>''を作る関数になる。その結果をさらに外側の@boldが包んで''<b><i>hi</i></b>''にする。", "eg": "服を着るときに、体に近い下着（italic）を先に着てから、その上に上着（bold）を羽織るようなもの。一番近くにあるものが先に体を包む。", "terms": [["デコレータの重ね掛け", "1つの関数に複数の@デコレータを縦に並べて付けること"], ["適用順序", "重ねたデコレータのうち、関数に近い（下の）ものから先に効いていく順番"]], "think": "@bold @italicが付いたtextは、italic(text)が先に評価され、それをさらにbold(...)が包む形、つまりbold(italic(text))になる。text()を呼ぶと、まず一番外側のbold用wrapperが動き、その中でfunc()つまりitalic用wrapperを呼ぶ。italic用wrapperは元のtext()を呼んで''hi''を受け取り、それを''<i>''と''</i>''で囲んで''<i>hi</i>''を返す。それを受け取ったbold用wrapperが''<b>''と''</b>''で囲んで''<b><i>hi</i></b>''にする。", "vs": "並び順を逆にして@italic @boldと書けば、今度はboldが先に効いて''<i><b>hi</b></i>''になる。デコレータを重ねる順番を入れ替えると結果も入れ替わる点が、この仕組みの実務上の要注意ポイント。", "opt": ["正解。関数に近い@italicが先に適用されて''<i>hi</i>''になり、それを外側の@boldがさらに包んで''<b><i>hi</i></b>''になる。", "上から順に適用されると考えるとこうなるが、実際は関数に近い下側の@italicが先に適用される。", "italicによる装飾が省略されるわけではなく、boldとitalicの両方が結果に反映される。", "文字列の連結だけで構成された通常の処理であり、実行時エラーにはならない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" fill=\"#e8eaf0\" font-size=\"11\" text-anchor=\"middle\" font-weight=\"600\">デコレータは下から上へ適用される</text>\n<text x=\"170\" y=\"34\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">@bold ← ②外側から2番目に適用</text>\n<text x=\"170\" y=\"47\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">@italic ← ①先に内側で適用</text>\n<rect x=\"55\" y=\"58\" width=\"230\" height=\"38\" rx=\"19\" fill=\"none\" stroke=\"#c9a04a\" stroke-width=\"1.3\"/>\n<text x=\"170\" y=\"70\" fill=\"#c9a04a\" font-size=\"9\" text-anchor=\"middle\">bold(...)</text>\n<rect x=\"90\" y=\"74\" width=\"160\" height=\"18\" rx=\"9\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.1\"/>\n<text x=\"170\" y=\"87\" fill=\"#60a5fa\" font-size=\"8.5\" text-anchor=\"middle\">italic(\"hi\")</text>\n<text x=\"170\" y=\"118\" fill=\"#e8eaf0\" font-size=\"10\" text-anchor=\"middle\">結果: &lt;b&gt;&lt;i&gt;hi&lt;/i&gt;&lt;/b&gt;</text>\n</svg>"}'),

  ('python-drill-q90', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'class Resource:
    def __enter__(self):
        print("open")
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        print("close")

with Resource():
    print("using")',
   '["1行目に''open''、2行目に''using''、3行目に''close''が出力される", "1行目に''using''、2行目に''open''、3行目に''close''が出力される", "1行目に''open''、2行目に''close''、3行目に''using''が出力される", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（with文が__enter__と__exit__を呼ぶタイミング）", "point": "withブロックに入るときに__enter__が呼ばれ、ブロックの中身が実行された後、ブロックを抜けるときに__exit__が呼ばれる。", "why_asked": "ファイルやDB接続、ロックの取得・解放をwithに任せるとき、__enter__と__exit__がいつ呼ばれるかを知らないと、後片付けのタイミング（ブロックを抜けた直後）がいつなのか説明できなくなる。", "kid": "with Resource():に入る瞬間に__enter__が呼ばれて''open''が出る。次にブロックの中身のprint(''using'')が実行される。ブロックを抜けるときに__exit__が呼ばれて''close''が出る。", "eg": "部屋に入るときに受付で開場処理をしてもらい（open）、部屋の中で用事を済ませ（using）、退室するときに受付が閉場処理をする（close）ようなもの。", "terms": [["__enter__", "withブロックに入るときに自動で呼ばれるメソッド。返り値がas変数に入る"], ["__exit__", "withブロックを抜けるときに自動で呼ばれる、後片付け用のメソッド"]], "think": "with Resource():という行が実行されると、まずResource()でインスタンスが作られ、そのインスタンスの__enter__が呼ばれて''open''が表示される。続いてwithブロックの中身であるprint(''using'')が実行されて''using''が表示される。ブロックの中身を実行し終えると、withブロックを抜ける処理として__exit__が呼ばれて''close''が表示される。", "vs": "try/finallyで同じことを手動で書くと、tryの直前にopen処理、finallyの中にclose処理を書く形になる。withはこの『開始処理→本体→終了処理は必ず実行』という型をenter/exitとしてまとめて表現したもの。", "opt": ["正解。withブロックに入るときに__enter__が呼ばれて''open''、ブロックの中身で''using''、ブロックを抜けるときに__exit__が呼ばれて''close''の順で出力される。", "__enter__はwithブロックに入る前に呼ばれるので、ブロックの中身の''using''より先に''open''が出力される。", "__exit__はブロックの中身を実行し終えてから呼ばれるので、''using''より先に''close''が出力されることはない。", "__enter__・__exit__・ブロックの中身のいずれも通常のメソッド呼び出しであり、エラーにはならない。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n<text x=\"170\" y=\"16\" fill=\"#e8eaf0\" font-size=\"11\" text-anchor=\"middle\" font-weight=\"600\">with は __enter__ と __exit__ を自動で呼ぶ</text>\n<line x1=\"30\" y1=\"70\" x2=\"310\" y2=\"70\" stroke=\"#2a2f3f\" stroke-width=\"1.3\"/>\n<circle cx=\"60\" cy=\"70\" r=\"4\" fill=\"#60a5fa\"/>\n<text x=\"60\" y=\"55\" fill=\"#60a5fa\" font-size=\"9\" text-anchor=\"middle\">__enter__</text>\n<text x=\"60\" y=\"90\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">\"open\"</text>\n<circle cx=\"170\" cy=\"70\" r=\"4\" fill=\"#e8eaf0\"/>\n<text x=\"170\" y=\"55\" fill=\"#e8eaf0\" font-size=\"9\" text-anchor=\"middle\">withブロックの中身</text>\n<text x=\"170\" y=\"90\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">\"using\"</text>\n<circle cx=\"280\" cy=\"70\" r=\"4\" fill=\"#c9a04a\"/>\n<text x=\"280\" y=\"55\" fill=\"#c9a04a\" font-size=\"9\" text-anchor=\"middle\">__exit__</text>\n<text x=\"280\" y=\"90\" fill=\"#8892a4\" font-size=\"9\" text-anchor=\"middle\">\"close\"</text>\n</svg>"}'),

  ('python-drill-q91', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'class Resource:
    def __enter__(self):
        print("open")
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        print("close")
        return False

try:
    with Resource():
        print("using")
        raise ValueError("boom")
except ValueError:
    print("caught")',
   '["1行目''open''、2行目''using''、3行目''close''、4行目''caught''の順で出力される", "1行目''open''、2行目''using''、3行目''caught''の順で出力される（closeは呼ばれない）", "1行目''open''、2行目''using''、3行目''close''の順で出力され、そこでプログラムが終了する（例外は外に伝わらない）", "エラーになる（withブロックの中で例外が起きるとその場でプログラムが停止する）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（withブロックで例外が起きても__exit__は必ず呼ばれる）", "point": "withブロックの中で例外が発生しても、__exit__は必ず呼ばれてから例外が外に伝わる。__exit__がFalseを返す限り、例外はそのまま外側に伝わり続ける。", "why_asked": "ファイルやDB接続の後片付けをwithに任せるのは、例外が起きてもこの『__exit__は必ず呼ばれる』という保証があるから。この保証を知らないと、例外処理付きのコードで後片付けが本当に行われているか自信が持てなくなる。", "kid": "with Resource(): に入る時に__enter__が呼ばれて''open''が出る。ブロックの中で''using''を出した直後にValueErrorが発生する。ここで例外が起きてもwithは__exit__を呼ぶことを保証しているので''close''が出る。__exit__がFalseを返しているので例外は消されずに外側のtry/exceptまで伝わり、exceptが''caught''を出す。", "eg": "会議室を借りるときに、途中でトラブルが起きても退室手続き（鍵を返す等）は必ず行ってから、そのトラブルの報告は上に上げるようなもの。片付けをすっ飛ばして放置しない。", "terms": [["__exit__", "withブロックを抜けるときに必ず呼ばれる後片付け用のメソッド。例外の有無に関わらず呼ばれる"], ["例外の伝播", "exceptで捕まえられるまで、発生した例外が呼び出し元に向かって伝わっていくこと"]], "think": "with Resource():に入るとき__enter__が実行され''open''が出力される。ブロックの中でprint(''using'')が実行された直後にraise ValueErrorで例外が発生する。Pythonはブロックを異常終了させる前に必ず__exit__を呼ぶので''close''が出力される。__exit__はFalseを返しており、これは『この例外を消さずにそのまま外に伝えてください』という意味になるので、ValueErrorはwithの外まで伝わり、try/exceptのexceptブロックに捕まって''caught''が出力される。", "vs": "もし__exit__がTrueを返していたら、例外はそこで揉み消され外側のexceptには届かず''caught''は出力されない。__exit__の戻り値のTrue/Falseが、例外を外に伝えるか揉み消すかを分ける。", "opt": ["正解。__enter__で''open''、ブロック内で''using''、例外発生後も__exit__は必ず呼ばれて''close''、__exit__がFalseを返しているので例外は外に伝わりexceptで''caught''が出る。", "with文の中で例外が起きても__exit__は省略されずに必ず呼ばれる。後片付けをせずに例外だけ外に伝わることはない。", "__exit__がFalseを返しているのは『例外を揉み消さず外に伝える』という意味なので、tryのexceptまで例外が伝わり''caught''が出力される。", "withブロックの中で例外が起きても、Pythonはその場でプログラムを止めるのではなく__exit__を呼んでから通常の例外処理の流れに乗せる。"]}'),

  ('python-drill-q92', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'from contextlib import contextmanager

@contextmanager
def resource():
    print("open")
    yield "handle"
    print("close")

with resource() as r:
    print("using", r)',
   '["1行目''open''、2行目''using handle''、3行目''close''の順で出力される", "1行目''open''、2行目''using handle''の順で出力される（closeは呼ばれない）", "1行目''using handle''、2行目''open''、3行目''close''の順で出力される", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（@contextmanagerでyieldを使った関数ベースのコンテキストマネージャ）", "point": "@contextmanagerを付けた関数は、yieldより前が__enter__、yieldの値がwith ... as rの値、yieldより後が__exit__に相当する。", "why_asked": "クラスで__enter__/__exit__を書かなくても、@contextmanagerとyieldだけで同じ後片付け保証を手に入れられる。この対応関係を知らないと、withブロックの中身がyieldの後に自動で続きから実行されることに気づけない。", "kid": "resource()を呼ぶとyieldの手前まで実行されて''open''が出力され、yieldの値''handle''がrに入る。withブロックの中でprint(''using'', r)が実行されて''using handle''が出る。withブロックを抜けると、resource()の続き（yieldの後）が実行されて''close''が出力される。", "eg": "旅館のチェックインからチェックアウトまでを1つの関数の中で表現するようなもの。チェックイン処理（yieldの前）をしてから客に部屋の鍵（yieldの値）を渡し、客が部屋を使い終えたらチェックアウト処理（yieldの後）が続きから動き出す。", "terms": [["@contextmanager", "yieldを1回だけ含む関数を、with文で使えるコンテキストマネージャに変換するデコレータ"], ["yield", "この行までを__enter__、値をas変数に渡し、withブロックを抜けた後にこの行の続きを__exit__として実行する境目"]], "think": "with resource() as r:に入ると、resource()の実行がyieldの手前まで進み、print(''open'')が実行される。yield ''handle''でいったん関数の実行が止まり、''handle''という値がasの右辺rに渡される。withブロックの中でprint(''using'', r)が実行され''using handle''と表示される。withブロックを抜けると、止まっていたyieldの続きから実行が再開し、print(''close'')が実行される。", "vs": "クラスで書くなら__enter__の中にopen相当の処理、__exit__の中にclose相当の処理を書くのと同じ内容を、@contextmanagerならyieldを境にした1つの関数で書ける。ジェネレータのyieldとは違い、値を複数回返し続けるためではなく、enter/exitの境目を表すために1回だけ使う。", "opt": ["正解。yieldの前で''open''、yieldの値''handle''を使って''using handle''、withを抜けた後にyieldの続きが実行されて''close''が出力される。", "withブロックを抜けると、止まっていたyieldの続き（''close''を出力する部分）が必ず実行されるので、closeが呼ばれないことはない。", "resource()の実行はyieldの手前から始まるので、''open''より先に''using handle''が出力されることはない。", "yieldを使った関数とas変数への受け渡し、withブロックを抜けた後の再開はすべて@contextmanagerが正しく処理する通常の流れであり、エラーにはならない。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'python-drill'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
