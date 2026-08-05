BEGIN;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('python-drill-q115', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'x = "global"

def outer():
    x = "outer"
    def middle():
        def inner():
            print(x)
        inner()
    middle()

outer()',
   '["outer", "global", "エラーになる（xが未定義になる）", "None"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（3段ネストの中でどの階層のxが使われるか）", "point": "変数を探すときは、自分のいる関数の中→1つ外側の関数の中→…→一番外側（モジュール全体）→Pythonに最初から用意された名前、の順に一番近い場所から探す。途中で見つかった時点でそこに確定する。", "why_asked": "関数を入れ子にして書くと「このxはどこの値？」を勘違いしやすい。特に3段以上ネストすると『一番近い場所から順に探す』ルールを忘れて、『必ず一番外側(グローバル)の値になる』と思い込んでバグに気づけないことがある。", "kid": "inner()の中にはxが無い。1つ外側のmiddle()の中にもxが無い。さらに1つ外側のouter()の中にx=\"outer\"がある。ここで見つかるので\"outer\"が使われる。一番外側のx=\"global\"までは探しに行かない。", "eg": "駅で忘れ物をしたとき、まず自分のカバンの中を探し、次に隣の座席、それでも無ければ車両全体、最後に駅の忘れ物センターを探す。途中で見つかったらそこで探すのをやめる。middle()の座席には無かったが、その次のouter()の車両で見つかったので、そこで探索は終わる。", "terms": [["LEGBルール", "Local(自分の関数)→Enclosing(外側の関数)→Global(モジュール全体)→Built-in(Python組み込み)の順で変数を探すルール"], ["エンクロージングスコープ", "自分を囲んでいる、1つ以上外側の関数が持つスコープ（変数の見える範囲）"]], "think": "1行目でグローバルのx=\"global\"が作られる。outer()が呼ばれるとローカルのx=\"outer\"が作られる。その中でmiddle()が呼ばれるが、middle()の中にxの代入は無い。さらにinner()が呼ばれるが、inner()の中にもxの代入は無い。print(x)を実行するとき、まずinner自身の中を探し（無い）、次に1つ外側のmiddleの中を探し（無い）、さらに1つ外側のouterの中を探すとx=\"outer\"が見つかるので、それが使われる。", "vs": "もしmiddle()の中にもx = \"middle\"という代入があれば、inner()から見て一番近い外側はmiddleになるので\"middle\"が出力される。今回はmiddleにxが無いので、その1つ外側のouterまで探しに行く点が違う。", "opt": ["正解。inner()にもmiddle()にもxは無いので、1つずつ外側へ探しに行き、outer()のx=\"outer\"が最初に見つかった時点でそれが使われる。", "一番外側のグローバル変数を常に優先すると考えるとglobalになるが、実際は自分に近い方から順に探すので、途中のouter()で見つかった\"outer\"が優先される。", "inner()やmiddle()にxが無いだけでエラーになるわけではない。エンクロージングスコープやグローバルスコープまで探しに行けるので、outer()のxが見つかる。", "xにNoneが代入されている箇所は無い。outer()にはっきりx = \"outer\"という代入があるので、Noneにはならない。"], "calc": "呼び出しの流れと変数探索を1つずつ追う。\n\n【1行目】グローバル領域にx=\"global\"ができる。\n\n【outer()を呼ぶ】outerのローカル領域にx=\"outer\"ができる（グローバルのxとは別物、名前が同じだけの2つ目の箱）。\n\n【middle()を呼ぶ】middleのローカル領域にxの代入は無い（空っぽ）。\n\n【inner()を呼ぶ】innerのローカル領域にもxの代入は無い（空っぽ）。\n\n【print(x)を実行】xを探す順番は「inner自身→1つ外側のmiddle→さらに外側のouter→一番外側のglobal→組み込み」。①innerの中を見る→無い　②middleの中を見る→無い　③outerの中を見る→x=\"outer\"がある→見つかったのでここで探索終了。→出力は outer", "viz": "<svg viewBox=\"0 0 340 200\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"90\" y=\"10\" width=\"160\" height=\"32\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"170\" y=\"30\" text-anchor=\"middle\" font-size=\"10\" fill=\"#8892a4\">global: x=\"global\"</text><rect x=\"90\" y=\"58\" width=\"160\" height=\"32\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\"/><text x=\"170\" y=\"78\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">outer(): x=\"outer\"</text><rect x=\"90\" y=\"106\" width=\"160\" height=\"32\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"170\" y=\"126\" text-anchor=\"middle\" font-size=\"10\" fill=\"#8892a4\">middle(): xなし</text><rect x=\"90\" y=\"154\" width=\"160\" height=\"32\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"170\" y=\"174\" text-anchor=\"middle\" font-size=\"10\" fill=\"#8892a4\">inner(): xなし print(x)</text><line x1=\"260\" y1=\"160\" x2=\"260\" y2=\"70\" stroke=\"#60a5fa\" stroke-width=\"1.5\" marker-end=\"url(#arrow115)\"/><text x=\"300\" y=\"116\" text-anchor=\"middle\" font-size=\"9\" fill=\"#60a5fa\">探索順</text><defs><marker id=\"arrow115\" markerWidth=\"6\" markerHeight=\"6\" refX=\"5\" refY=\"3\" orient=\"auto\"><path d=\"M0,0 L6,3 L0,6 z\" fill=\"#60a5fa\"/></marker></defs></svg>"}'),

  ('python-drill-q116', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'def make_funcs():
    items = []
    total = 0

    def add_item(x):
        items.append(x)
        return items

    def add_total(x):
        total += x
        return total

    return add_item, add_total

add_item, add_total = make_funcs()
print(add_item("a"))
print(add_total(5))',
   '["[''a''] の後にエラーになる（UnboundLocalErrorになる）", "[''a''] の後に5（外側のtotalがそのまま返ってくる）", "[''a''] の後にエラーになる（NameErrorになる）", "[''a''] の後に[''a'', 5]（totalの値もitemsに追加される）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（クロージャが可変オブジェクトを参照する場合と不変オブジェクトを参照する場合の違い）", "point": "外側の変数の「中身を変更する」だけ（.append()など）ならnonlocalは要らないが、「その変数名に新しい値を代入し直す」（+=を含む）にはnonlocalが必要。付け忘れると、代入のある変数は関数の中で最初からローカル扱いになり、読もうとした瞬間にUnboundLocalErrorになる。", "why_asked": "リストや辞書はappendやupdateで書き換えるだけなら気軽に外側の変数を触れてしまうので、数値のカウントも同じ感覚で+=すると突然エラーになり、なぜappendは平気だったのに+=はダメなのか分からず混乱しやすい。", "kid": "add_item()はitemsというリストの中身をappendで足すだけなので、外側のitemsをそのまま書き換えられて[''a'']が返る。add_total()はtotal += xを実行しようとするが、これは新しい値をtotalに代入する操作にあたり、nonlocal宣言が無いのでこのtotalはadd_total専用のローカル変数として扱われる。ところが代入する前に右辺のtotal（古い値）を読もうとしてしまうため、まだ値が無いローカル変数を読むことになりエラーになる。", "eg": "共有ノートに書き込むのと、自分の手帳に書き写すのの違いに似ている。items.append(x)は共有ノートに直接1行足す作業なので、誰でも自由にできる。一方total += xは『いったん自分の手帳にtotalという項目を新しく作ってから、共有ノートの値を書き写そうとする』ようなもので、まだ何も書いていない自分の手帳の項目を読もうとして詰まってしまう。", "terms": [["nonlocal", "入れ子関数の中から、1つ外側の関数のローカル変数を書き換えるための宣言"], ["UnboundLocalError", "代入されるはずの変数を、代入が終わる前に読もうとしたときに出るエラー"], ["ミュータブル/イミュータブル", "ミュータブルはリストや辞書のように中身を後から書き換えられる型、イミュータブルは整数や文字列のように書き換えられず作り直すしかない型"]], "think": "make_funcs()が呼ばれるとitems=[]とtotal=0が作られる。add_item(\"a\")を呼ぶと、items.append(\"a\")はitemsという同じリストの中身に\"a\"を追加するだけの操作なので、外側のitemsがそのまま書き換わり[''a'']が返る。次にadd_total(5)を呼ぶと、total += xはtotal = total + xと同じ意味で、totalに新しい値を代入する操作になる。add_total()の中にtotalへの代入があるため、Pythonはこの時点でtotalをadd_total専用のローカル変数とみなす。ところが右辺のtotal（古い値）を読もうとした時点で、そのローカル変数にはまだ何も入っていないため、UnboundLocalErrorになる。", "vs": "もしadd_total()の先頭にnonlocal totalと書いていれば、totalはmake_funcs()側の変数を指すことになり、5が返って外側のtotalも5になる。可変オブジェクトのappendは中身の変更なのでnonlocal無しでも動くが、+=のような代入操作は再代入なのでnonlocalが要る、という違いがこの問題の核心。", "opt": ["正解。add_item()はitems.append(x)でリストの中身を変更するだけなので[''a'']が返る。add_total()はtotal += xで新しい値を代入しようとするが、nonlocal宣言が無いためtotalはこの関数専用のローカル変数扱いになり、代入前に読もうとしてUnboundLocalErrorになる。", "total += xがそのまま外側のtotalを書き換えて5になると考えるとこうなるが、nonlocal宣言が無い代入操作はローカル変数を新しく作ろうとするだけで外側のtotalは書き換わらず、そもそも代入前に読む時点でエラーになる。", "変数が見つからないことが原因でNameErrorになると考えるとこうなるが、totalという名前自体はadd_total()のローカル変数として存在しているので、見つからないNameErrorではなく、値が代入される前に読んでしまうUnboundLocalErrorになる。", "add_total()の戻り値5がitemsに追加されると考えるとこうなるが、add_item()とadd_total()は別々の変数（itemsとtotal）を扱っており、add_total()の戻り値がitemsに影響することは無い。"], "calc": "呼び出しを1つずつ追う。\n\n【make_funcs()を呼ぶ瞬間】items=[]（空リスト）とtotal=0が1個ずつ作られる。add_item, add_totalはどちらもこの同じitems・totalを見に行けるクロージャになる。\n\n【1回目: add_item(\"a\")】\n・items.append(\"a\") は「中身の変更」なので、外側のitemsそのものに\"a\"が追加される → itemsは[''a'']になる\n・戻り値: [''a''] → 1行目の出力は [''a'']\n\n【2回目: add_total(5)】\n・total += x は total = total + x と同じで「totalへの代入」にあたる\n・add_total()の中にtotalへの代入があるので、Pythonはこの関数全体でtotalをローカル変数として扱うと決める（nonlocal宣言が無いため、外側のtotalとは別物）\n・ところが右辺のtotal（まだ何も代入されていないローカルのtotal）を読もうとした時点で値が無いので、UnboundLocalErrorになる\n・→ 2行目は[''a'']の後にエラーになる", "viz": "<svg viewBox=\"0 0 340 150\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">make_funcs() が持つ2つの変数</text><rect x=\"15\" y=\"32\" width=\"140\" height=\"56\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\"/><text x=\"85\" y=\"50\" text-anchor=\"middle\" font-size=\"10\" fill=\"#8892a4\">items（リスト＝可変）</text><text x=\"85\" y=\"68\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">append で中身だけ変更</text><text x=\"85\" y=\"82\" text-anchor=\"middle\" font-size=\"10\" fill=\"#60a5fa\">→ nonlocal 不要・成功</text><rect x=\"185\" y=\"32\" width=\"140\" height=\"56\" rx=\"4\" fill=\"none\" stroke=\"#ff7b72\"/><text x=\"255\" y=\"50\" text-anchor=\"middle\" font-size=\"10\" fill=\"#8892a4\">total（整数＝不変）</text><text x=\"255\" y=\"68\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">+= は再代入にあたる</text><text x=\"255\" y=\"82\" text-anchor=\"middle\" font-size=\"10\" fill=\"#ff7b72\">→ nonlocal 無しでエラー</text><text x=\"170\" y=\"108\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">「中身の変更」と「名前への再代入」で明暗が分かれる</text></svg>"}'),

  ('python-drill-q117', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'def setup():
    global list
    list = [1, 2, 3]

setup()
print(list)
print(list(range(3)))',
   '["[1, 2, 3] の後にエラーになる（TypeErrorになる）", "[1, 2, 3] の後に[0, 1, 2]", "[1, 2, 3] の後にエラーになる（NameErrorになる）", "エラーになる（1行目のglobal listの時点でエラーになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（globalで宣言した変数名が組み込み関数名とかぶる場合）", "point": "listのような組み込み関数の名前でも、変数名として自由に使えてしまう。一度その名前に値を代入すると、その名前は組み込み関数ではなく代入した値を指すようになり、以後は組み込み関数として呼べなくなる（シャドーイング）。", "why_asked": "list, dict, str, id, type, sumなど、Pythonの組み込み関数と同じ名前は変数名としてもエラーにならず使えてしまう。うっかりlist = [...]のように使うと、その後のコードでlist(...)と書いた瞬間に『listはさっき代入したリストのはずなのに関数として呼べない』という分かりにくいエラーに突き当たる。", "kid": "setup()の中でglobal listと宣言してからlist = [1, 2, 3]を代入しているので、モジュール全体のlistという名前がこのリストを指すようになる。print(list)はこのリストをそのまま表示するので[1, 2, 3]になる。次にlist(range(3))を実行しようとすると、この時点でlistはもう組み込みの変換関数ではなくただのリストなので、リストを関数のように呼び出そうとしてエラーになる。", "eg": "「係長」という呼び方を、本来の役職の人ではなく飼っている犬の名前として使い始めるようなもの。一度「係長」を犬の名前として登録してしまうと、その後『係長に承認をお願いします』と言っても、もう本来の係長（役職の人）を指せなくなってしまう。", "terms": [["global", "関数の中で、モジュール全体（グローバル）のその名前の変数に代入するための宣言"], ["シャドーイング", "元々あった名前（ここでは組み込み関数list）を、同じ名前の別の値で覆い隠して見えなくすること"], ["組み込み関数", "print, len, listのように、importしなくても最初から使えるPython標準の関数"]], "think": "setup()を呼ぶと、global listの宣言によりモジュール全体のlistという名前に[1, 2, 3]が代入される。print(list)はこの時点のlist（＝[1, 2, 3]というリスト）をそのまま表示するので[1, 2, 3]が出力される。次にlist(range(3))を実行しようとすると、Pythonはlistという名前を探すが、もはや組み込み関数のlistではなく、さっき代入した[1, 2, 3]というリストを指している。リスト自体は関数ではなく呼び出せないので、TypeErrorになる。", "vs": "もしsetup()の中でglobalを付けずにlistという名前をローカル変数として使っていれば、モジュール全体のlistには影響せず、関数の外ではlist(range(3))は普段通り組み込み関数として動く。global宣言があるからこそ、モジュール全体のlistが上書きされてしまう点が今回の核心。", "opt": ["正解。global listの宣言によりモジュール全体のlistが[1, 2, 3]を指すようになるのでprint(list)は[1, 2, 3]。その後list(range(3))を呼ぼうとしても、listはもう組み込み関数ではなくリストそのものなので、関数のように呼び出せずTypeErrorになる。", "list(range(3))が組み込みのlist関数として動くと考えるとこうなるが、global listの代入によってlistという名前はすでに[1, 2, 3]というリストに上書きされており、組み込み関数としては使えなくなっている。", "listという名前が見つからないと考えるとNameErrorになりそうだが、listという名前自体はモジュール全体に存在している（[1, 2, 3]というリストとして）。名前が見つからないのではなく、見つかった値が関数として呼び出せない型であることが原因なのでTypeErrorになる。", "global listの宣言自体は、ただ『この名前はモジュール全体の変数を指す』と伝えるだけの文であり、その時点では代入も呼び出しも起きないのでエラーにはならない。実際にエラーになるのは、上書きされたlistを関数として呼び出そうとした最後の行。"], "calc": "実行順を1つずつ追う。\n\n【setup()を呼ぶ】global listと宣言されているので、以後このsetup()内のlist = ...はモジュール全体（グローバル）のlistという名前への代入になる。list = [1, 2, 3]が実行され、グローバルのlistは組み込み関数から[1, 2, 3]というリストに上書きされる。\n\n【print(list)】グローバルのlistを見に行くと、上書きされた[1, 2, 3]が見つかる → 1行目の出力は[1, 2, 3]\n\n【list(range(3))】listという名前をまた探しに行くと、やはり上書きされた[1, 2, 3]（リスト型のオブジェクト）が見つかる。リストは関数ではないため()を付けて呼び出すことができず、TypeError: ''list'' object is not callable になる → 2行目はエラーになる"}'),

  ('python-drill-q118', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'def make_counter():
    count = 0
    def increment():
        nonlocal count
        count += 1
        return count
    return increment

counter_a = make_counter()
counter_b = make_counter()

print(counter_a(), counter_a(), counter_b())',
   '["1 2 1", "1 1 1", "1 2 3", "エラーになる（counter_bはcounter_aと同じcountを共有しようとして衝突する）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（make_counter()を2回呼んで、独立したクロージャを2つ作る）", "point": "同じファクトリ関数を呼ぶたびに、count = 0という代入が毎回新しく実行されて、そのたびに新しいcountの箱が作られる。だから同じmake_counter()から作ったincrementでも、呼び出しごとに別々の独立したcountを持つ。", "why_asked": "クロージャの中身が『前に見た変数をそのまま覚えている』とだけ理解していると、同じ関数から作った別のインクリメンタ同士が値を共有すると勘違いしやすい。実務でも『複数のカウンタやキャッシュを同じ工場関数から作る』場面でこの独立性の理解が要る。", "kid": "counter_aとcounter_bは、どちらもmake_counter()を呼んで作られたincrement関数だが、呼び出しのたびにcount = 0が新しく実行されるので、それぞれ別々のcountを持っている。counter_a()を2回呼ぶとcounter_a専用のcountが1→2と増え、counter_b()を1回呼んでもcounter_b専用のcountは影響を受けず1のまま。", "eg": "同じ型の万歩計を2個買うようなもの。同じ工場（make_counter）の同じ設計図から作られていても、1個目の万歩計をいくら歩いてカウントを進めても、2個目の万歩計の歩数は0からしか始まらない。それぞれが自分の中に別々のカウンタを持っているから。", "terms": [["ファクトリ関数", "呼ばれるたびに新しい関数（や独立した状態）を作って返す関数。ここではmake_counter()がそれにあたる"], ["nonlocal", "入れ子関数の中から、1つ外側の関数のローカル変数を書き換えるための宣言"]], "think": "1回目のmake_counter()呼び出しでcount=0が作られ、それを覚えたincrementがcounter_aに入る。2回目のmake_counter()呼び出しでも同じようにcount=0が新しく作られ、それを覚えた別のincrementがcounter_bに入る。この2つのcountは名前は同じでも別々の箱。print(counter_a(), counter_a(), counter_b())では、まずcounter_a()が呼ばれてcounter_a側のcountが0→1になり1が返る。次のcounter_a()でさらに1→2になり2が返る。最後のcounter_b()はcounter_b側のcountが0→1になり1が返る。print()はこの3つをスペース区切りで並べるので1 2 1になる。", "vs": "もしmake_counter()の外にcount = 0を1つだけ書いて、counter_aとcounter_bの両方がその1つのcountをnonlocalで共有するように書けば、counter_a()を呼ぶたびにcounter_b側のcountも一緒に増えていく。今回はmake_counter()を呼ぶたびにcount = 0が新しく実行される作りなので、独立したカウンタになる点が違う。", "opt": ["正解。make_counter()を呼ぶたびにcount=0が新しく作られるので、counter_aとcounter_bは別々のcountを持つ。counter_a()を2回呼ぶと1→2、counter_b()を1回呼ぶと1になり、1 2 1と出力される。", "counter_aとcounter_bが同じcountを共有していると考えると、counter_b()を呼ぶ頃にはcountが2になっていそうだが、make_counter()を呼ぶたびに別々のcountが作られるため、counter_b側のcountは0からのスタートで1になる。", "呼び出しの回数がそのまま全体で積み上がっていくと考えるとこうなるが、増えているのはそれぞれのクロージャが持つ別々のcountであり、counter_bのcountはcounter_aの回数を引き継がない。", "counter_aとcounter_bはどちらもmake_counter()から作られた別々の呼び出し結果であり、それぞれが自分専用のcountを持つので衝突は起きない。nonlocalは1つ外側のローカル変数を指すだけで、他のクロージャ同士を結び付けるものではない。"], "calc": "呼び出しを1つずつ追う。\n\n【1回目のmake_counter()呼び出し】count=0が1個作られる。これを覚えたincrementがcounter_aになる。\n\n【2回目のmake_counter()呼び出し】count=0がまた新しく1個作られる（1回目のcountとは別の箱）。これを覚えたincrementがcounter_bになる。この時点でcounter_a用のcountとcounter_b用のcountは完全に別物。\n\n【print(counter_a(), counter_a(), counter_b())の評価】\n・1つ目のcounter_a() → counter_a用のcountが0→1になり、1を返す\n・2つ目のcounter_a() → 同じcounter_a用のcountが1→2になり、2を返す\n・counter_b() → counter_b用のcount（まだ0のまま）が0→1になり、1を返す\n\n【print()の出力】3つの値をスペース区切りで並べる → 1 2 1", "viz": "<svg viewBox=\"0 0 340 150\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">make_counter() を呼ぶたびに新しいcountが1個できる</text><rect x=\"20\" y=\"36\" width=\"140\" height=\"64\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\"/><text x=\"90\" y=\"54\" text-anchor=\"middle\" font-size=\"10\" fill=\"#8892a4\">counter_a の環境</text><text x=\"90\" y=\"72\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">count: 0 → 1 → 2</text><text x=\"90\" y=\"90\" text-anchor=\"middle\" font-size=\"10\" fill=\"#60a5fa\">2回呼ぶので2</text><rect x=\"180\" y=\"36\" width=\"140\" height=\"64\" rx=\"4\" fill=\"none\" stroke=\"#c9a04a\"/><text x=\"250\" y=\"54\" text-anchor=\"middle\" font-size=\"10\" fill=\"#8892a4\">counter_b の環境</text><text x=\"250\" y=\"72\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">count: 0 → 1</text><text x=\"250\" y=\"90\" text-anchor=\"middle\" font-size=\"10\" fill=\"#c9a04a\">1回呼ぶので1</text><line x1=\"160\" y1=\"68\" x2=\"180\" y2=\"68\" stroke=\"#2a2f3f\" stroke-width=\"1.5\" stroke-dasharray=\"3,3\"/><text x=\"170\" y=\"120\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">互いに独立した別々の箱（共有しない）</text></svg>"}'),

  ('python-drill-q119', 'スコープとクロージャ',
   'このコードを実行すると何が出力される？',
   'config = {"mode": "dev", "retries": 3}

def bump_retries():
    config["retries"] += 1

bump_retries()
bump_retries()
print(config)',
   '["{''mode'': ''dev'', ''retries'': 5}", "エラーになる（UnboundLocalErrorになる）", "{''mode'': ''dev'', ''retries'': 3}", "{''mode'': ''dev'', ''retries'': 4}"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（globalを使わずに、関数の外の辞書の中身を書き換える）", "point": "config = {...}のようにconfigという名前そのものに代入し直すのは『代入』なのでglobal宣言が要るが、config[\"retries\"] += 1のように中身の一部を書き換えるのは『変更』なので、globalが無くても関数の外のconfigをそのまま書き換えられる。", "why_asked": "『関数の中でグローバル変数を触るにはglobalが要る』とだけ覚えていると、辞書やリストの中身を変更しているだけの場面でも毎回globalを書こうとして混乱したり、逆に必要な場面でglobalを付け忘れてUnboundLocalErrorに驚いたりする。『代入』と『中身の変更』を区別することが要点。", "kid": "bump_retries()の中にあるconfig[\"retries\"] += 1は、configという名前に新しい辞書を代入し直しているのではなく、configが指している辞書の中の\"retries\"というキーの値を書き換えているだけ。だからglobal宣言が無くても、関数の外のconfigの中身がそのまま変わる。2回呼ぶので3→4→5になる。", "eg": "会社の共有ロッカーの中の書類を書き換えるようなもの。ロッカーの鍵（configという名前）を新しいロッカーに交換するわけではなく、同じロッカーを開けて中の書類の数字を書き直しているだけなので、特別な許可（global宣言）は要らない。", "terms": [["global", "関数の中で、名前そのものへの代入先をモジュール全体の変数に切り替える宣言"], ["ミュータブル", "辞書やリストのように、中身を後から書き換えられる型"]], "think": "config = {\"mode\": \"dev\", \"retries\": 3}でグローバルにconfigという辞書ができる。bump_retries()の中のconfig[\"retries\"] += 1は、configという名前への代入ではなく、configが指す辞書オブジェクトの中の\"retries\"キーの値を書き換える操作なので、global宣言が無くても関数の外のconfigの中身がそのまま変わる。1回目の呼び出しで3→4、2回目の呼び出しで4→5になる。print(config)の時点でretriesは5になっている。", "vs": "もしbump_retries()の中でconfig = {\"retries\": 1}のようにconfigという名前そのものに新しい辞書を代入しようとしていたら、それは『代入』なのでglobalが無いとUnboundLocalErrorになる（このconfigは関数専用のローカル変数として扱われてしまう）。今回はキーの値を書き換えているだけなので、その心配は無い。", "opt": ["正解。config[\"retries\"] += 1はconfigという名前への代入ではなく、configが指す辞書の中身の書き換えなので、global宣言が無くても関数の外のconfigがそのまま変わる。2回呼ぶので3→4→5になる。", "config[\"retries\"] += 1をconfigという名前への代入だと考えるとglobal宣言が無いためエラーになりそうだが、これは辞書の中身の書き換えであり、名前そのものへの代入ではないのでエラーにはならない。", "global宣言が無いので関数の外のconfigは変わらないと考えるとこうなるが、中身の書き換えはglobal宣言が無くても反映されるので、実際にはretriesの値は増えている。", "bump_retries()を1回しか呼んでいないと考えるとこうなるが、実際には2回呼ばれているので、3→4→5と2回分増える。"], "calc": "呼び出しを1つずつ追う。\n\n【1行目】グローバル領域にconfig = {\"mode\": \"dev\", \"retries\": 3}という1個の辞書ができる。\n\n【1回目のbump_retries()】config[\"retries\"] += 1はconfig[\"retries\"] = config[\"retries\"] + 1と同じ意味。これは\"retries\"というキーの値を書き換える操作であり、configという名前自体への代入ではないので、global宣言が無くてもこの1個の辞書がそのまま書き換わる。retriesは3→4になる。\n\n【2回目のbump_retries()】同じ辞書のretriesがさらに4→5になる。\n\n【print(config)】書き換わった同じ辞書を参照するので、{''mode'': ''dev'', ''retries'': 5}が出力される。"}'),

  ('python-drill-q120', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'def repeat(n):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(n):
                func(*args, **kwargs)
        return wrapper
    return decorator

@repeat(3)
def greet():
    print("hi")

greet()',
   '["''hi''が3回、1行ずつ出力される", "''hi''が1回だけ出力される", "''hi''が2回、1行ずつ出力される", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（引数を取るデコレータ＝デコレータファクトリ）", "point": "デコレータに引数を渡したいなら、関数を3階層（引数を受け取る関数→デコレータ本体→wrapper）にネストする。@repeat(3)は先にrepeat(3)が呼ばれてdecoratorが返り、それがgreetに適用される。", "why_asked": "「N回リトライする」「タイムアウトをX秒にする」のように、デコレータの動作を呼び出し側で調整したい場面は実務でよくある。デコレータファクトリの3階層構造を知らないと、引数付きデコレータを自分で書けず、なぜ動くのかも読めない。", "kid": "@repeat(3)はまずrepeat(3)が実行されてdecoratorが返り、それがgreetに@として適用される。greet()を呼ぶと実際にはwrapperが動き、for文でfunc()（元のgreet）をn回＝3回呼ぶので、''hi''が3回出力される。", "eg": "『3回コールしてください』とあらかじめ回数を指定してから電話係を雇うようなもの。雇う時点（repeat(3)）で回数を約束し、実際に電話をかける段になったら（greet()を呼ぶ段になったら）その約束通りの回数だけ動く。", "terms": [["デコレータファクトリ", "デコレータ自体に引数を渡せるようにするため、デコレータを返す関数のこと。関数を1階層余計にネストする"], ["wrapper", "デコレータの中で定義される、元の関数を実際に呼び出す関数"], ["*args, **kwargs", "位置引数とキーワード引数をまとめて受け取り、そのまま別の関数に渡すための書き方"]], "think": "①@repeat(3)が付いた時点で、まずrepeat(3)が呼ばれてdecorator関数が返る。②そのdecoratorがgreetに適用され、decorator(greet)が実行されてwrapperが返る。③greetという名前には実際にはこのwrapperが入る。④greet()を呼ぶと実際にはwrapper()が動き、for _ in range(3)でfunc()（元のgreet、中身はprint(''hi'')）を3回呼ぶ。⑤結果として''hi''が3回、1行ずつ出力される。", "vs": "引数を取らない普通のデコレータ（@loggerのような書き方）は関数を2階層（decorator→wrapper）で作れば足りるが、@repeat(3)のように呼び出し時に()を付けて引数を渡す形にしたい場合は、その外側にもう1階層（引数を受け取ってdecoratorを返す関数）が必要になる。", "opt": ["正解。repeat(3)がまず実行されてdecoratorが返り、それがgreetに適用されてwrapperになる。greet()を呼ぶとwrapperの中のfor文がfunc()を3回呼ぶので、''hi''が3回出力される。", "for _ in range(n)のnには3が渡っているので、func()は1回ではなく3回呼ばれる。デコレータファクトリの引数はきちんとwrapperの中のループ回数に反映される。", "for _ in range(3)は3回繰り返す。2回で止まる理由はどこにもない。", "@repeat(3)のように()を付けてデコレータに引数を渡す書き方自体は、repeat(3)がdecorator関数を返す形にしてあれば正しく動く構文で、エラーにはならない。"], "calc": "デコレータの適用（定義時に実際に起きる順）:\n①@repeat(3)が評価され、まずrepeat(3)が呼ばれる。nに3が入った状態でdecorator関数が返る。\n②続けてこのdecoratorがgreetに適用され、decorator(greet)が実行される。中でwrapperが定義され、そのwrapperが返る。\n③この時点でgreetという名前に入っているのは、元のgreetではなくこのwrapper。\n\n呼び出し（greet()を実行したとき）:\n④greet()を呼ぶと実際にはwrapper()が動く。\n⑤for _ in range(3):のループが回り、1周ごとにfunc()（＝元のgreet、中身はprint(''hi'')）が呼ばれる。\n⑥3周分実行されるので、''hi''が3回、1行ずつ出力される。"}'),

  ('python-drill-q121', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'def logger(func):
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        print("called with", args, kwargs)
        return result
    return wrapper

@logger
def add(a, b, c=0):
    return a + b + c

print(add(1, 2, c=3))',
   '["1行目に called with (1, 2) {''c'': 3}、2行目に 6 が出力される", "1行目に called with (1, 2, 3) {}、2行目に 6 が出力される", "エラーになる（wrapperの引数とaddの引数の数が一致しない）", "1行目に 6、2行目に called with (1, 2) {''c'': 3} が出力される"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（*args, **kwargsを素通しするデコレータ）", "point": "wrapperを*args, **kwargsで受け取ってfunc(*args, **kwargs)とそのまま渡せば、元の関数がどんな引数を取っても（位置引数でもキーワード引数でも）デコレータは対応できる。", "why_asked": "実務で書くデコレータの多くは、対象の関数の引数の形を知らずに使い回せる必要がある。wrapper()のように引数無しで固定してしまうと、引数を取る関数に付けた瞬間にエラーになる。*args, **kwargsで素通しする形が事実上の標準になっている。", "kid": "add(1, 2, c=3)を呼ぶと実際にはwrapper(1, 2, c=3)が動く。argsには位置引数の(1, 2)が、kwargsにはキーワード引数の{''c'': 3}が入る。func(*args, **kwargs)でそのままadd(1, 2, c=3)として呼ばれるので結果は6。呼び出し直後にprintでargsとkwargsの中身が出力される。", "eg": "宅配の中継業者が、荷物の中身を開けずにそのまま次の配送員に渡すようなもの。中継業者（wrapper）は荷物の形（引数の種類や数）を知らなくても、そのまま右から左に渡せる。", "terms": [["*args", "関数呼び出し時の位置引数をまとめてタプルとして受け取る書き方"], ["**kwargs", "関数呼び出し時のキーワード引数をまとめて辞書として受け取る書き方"], ["素通し", "wrapperが受け取った引数を加工せず、そのままの形で元の関数に渡すこと"]], "think": "①add(1, 2, c=3)を呼ぶと、@loggerによって実際にはwrapper(1, 2, c=3)が実行される。②wrapperの引数はargs=(1, 2)、kwargs={''c'': 3}として受け取られる。③result = func(*args, **kwargs)により、add(1, 2, c=3)が実際に呼ばれ、a=1, b=2, c=3として計算されて6が返る。④print(''called with'', args, kwargs)が実行され、\"called with (1, 2) {''c'': 3}\"が出力される。⑤wrapperがresult（6）をreturnし、外側のprint(add(1, 2, c=3))がその6を出力する。", "vs": "もしwrapper()を引数無しで定義していたら、add(1, 2, c=3)のように引数を渡した瞬間にTypeErrorになる。固定の引数だけで受けるwrapper(a, b)のような書き方も、キーワード引数cを渡された時点でまた別のエラーになる。*args, **kwargsは『何が来ても受け止める』ための書き方。", "opt": ["正解。argsには位置引数(1, 2)が、kwargsにはキーワード引数{''c'': 3}が入るので、まずcalled with (1, 2) {''c'': 3}が出力され、続けてadd(1, 2, c=3)の戻り値6が出力される。", "c=3はキーワード引数として渡されているので、argsではなくkwargsに{''c'': 3}として入る。位置引数のargsに3が紛れ込むことはない。", "wrapperの引数の数がadd側と一致している必要はない。*args, **kwargsはどんな組み合わせの引数でも受け止められるので、この呼び出しでエラーにはならない。", "result = func(*args, **kwargs)の直後にprintを実行しているので、まずcalled withの行が出力され、その後にwrapperがresultをreturnして外側のprintが6を出力する順番になる。"], "calc": "呼び出し（add(1, 2, c=3)を実行したとき）:\n①@loggerによってaddという名前には実際にはwrapperが入っている。add(1, 2, c=3)を呼ぶと実際にはwrapper(1, 2, c=3)が動く。\n②wrapperの引数はargs=(1, 2)（位置引数分）、kwargs={''c'': 3}（キーワード引数分）として受け取られる。\n③result = func(*args, **kwargs)により、元のadd(1, 2, c=3)が実行され、a=1, b=2, c=3として1+2+3=6が計算され、resultに入る。\n④print(''called with'', args, kwargs)が実行され、1行目に\"called with (1, 2) {''c'': 3}\"が出力される。\n⑤wrapperがresult（6）をreturnし、外側のprint(add(1, 2, c=3))が2行目に6を出力する。"}'),

  ('python-drill-q122', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'class A:
    def __enter__(self):
        print("A enter")
        return self
    def __exit__(self, *a):
        print("A exit")

class B:
    def __enter__(self):
        print("B enter")
        return self
    def __exit__(self, *a):
        print("B exit")

with A() as a, B() as b:
    print("inside")',
   '["1行目''A enter''、2行目''B enter''、3行目''inside''、4行目''B exit''、5行目''A exit''の順で出力される", "1行目''A enter''、2行目''B enter''、3行目''inside''、4行目''A exit''、5行目''B exit''の順で出力される", "1行目''B enter''、2行目''A enter''、3行目''inside''、4行目''A exit''、5行目''B exit''の順で出力される", "1行目''A enter''、2行目''B enter''、3行目''inside''、4行目''A exit''のみが出力される（B exitは呼ばれない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（1つのwith文に複数のコンテキストマネージャをまとめて書く）", "point": "with A() as a, B() as b: のようにカンマで並べると、__enter__は書いた順（A→B）で呼ばれ、__exit__はその逆順（B→A）で呼ばれる。", "why_asked": "複数のリソース（ファイルとロック、DB接続とトランザクションなど）を1つのwith文でまとめて開閉するのは実務でよくある書き方。開いた順と逆順で閉じるという保証を知らないと、依存関係のあるリソースを安全な順番で後片付けできているか確信が持てない。", "kid": "with A() as a, B() as b: に入ると、まずAの__enter__が呼ばれて''A enter''、続けてBの__enter__が呼ばれて''B enter''が出る。ブロックの中で''inside''が出た後、withを抜けるときは開いた順とは逆に、先にBの__exit__で''B exit''、最後にAの__exit__で''A exit''が出る。", "eg": "後から乗った人が先に降りるエレベーターのようなもの。A（1階で乗った人）→B（2階で乗った人）の順で乗り込み（enter順）、降りるときはB（先に降りる）→A（最後に降りる）の順になる。", "terms": [["with A() as a, B() as b:", "1つのwith文にカンマ区切りで複数のコンテキストマネージャを並べる書き方"], ["__enter__", "withに入るときに呼ばれる準備処理"], ["__exit__", "withを抜けるときに呼ばれる後片付け処理"]], "think": "①with A() as a, B() as b: に入る瞬間、まずAの__enter__が呼ばれ、1行目に''A enter''が出力される。②続けてBの__enter__が呼ばれ、2行目に''B enter''が出力される（Aの後片付けが終わってからBが始まるのではなく、Aの準備が終わった直後にBの準備に進む）。③withブロックの中身print(''inside'')が実行され、3行目に''inside''が出力される。④withを抜けるとき、後片付けは開いた順の逆で行われるので、先にBの__exit__が呼ばれて4行目に''B exit''、続けてAの__exit__が呼ばれて5行目に''A exit''が出力される。", "vs": "もしwith A(): の中でwith B(): と別々に入れ子で書いても、enter/exitの順番自体はwith A() as a, B() as b:とまったく同じ（A enter→B enter→B exit→A exit）になる。カンマ区切りは、入れ子のwithを1行にまとめて書ける省略記法。", "opt": ["正解。__enter__は書いた順（A→B）で呼ばれ、__exit__はその逆順（B→A）で呼ばれるので、A enter→B enter→inside→B exit→A exitの順になる。", "__exit__は__enter__と同じ順番で呼ばれるわけではない。後片付けは開いた順の逆（後から開けたものを先に閉じる）で行われるので、Aの__exit__が先に呼ばれることはない。", "__enter__はwith文に書かれた順（A→B）で呼ばれる。Bが先に書かれていないので、B enterがA enterより先に出力されることはない。", "Bの__exit__もAの__exit__と同様に必ず呼ばれる。with文で複数のコンテキストマネージャを開いても、それぞれの__exit__は省略されずにきちんと呼ばれる。"], "calc": "呼び出し順（with A() as a, B() as b: に入るとき）:\n①先に書かれたAの__enter__が呼ばれ、1行目に''A enter''が出力される。\n②続けてBの__enter__が呼ばれ、2行目に''B enter''が出力される。\n③withブロックの中身print(''inside'')が実行され、3行目に''inside''が出力される。\n\n後片付け（withブロックを抜けるとき、開いた順の逆で実行される）:\n④後から開いたBの__exit__が先に呼ばれ、4行目に''B exit''が出力される。\n⑤最後に、先に開いたAの__exit__が呼ばれ、5行目に''A exit''が出力される。"}'),

  ('python-drill-q123', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'import contextlib

with contextlib.suppress(ZeroDivisionError):
    print("before")
    1/0
    print("after")
print("done")',
   '["1行目''before''、2行目''done''の順で出力される", "1行目''before''、2行目''after''、3行目''done''の順で出力される", "エラーになる（ZeroDivisionErrorが発生した時点でプログラムが停止する）", "1行目''before''が出力されるだけで、その後は何も出力されない（doneも出ない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（contextlib.suppressで特定の例外を握りつぶす）", "point": "with contextlib.suppress(例外クラス): の中でその例外が起きると、そこでwithブロックの残りをスキップしてブロックを正常に抜ける。プログラムは止まらず、withの次の行から普通に続く。", "why_asked": "「ファイルが無ければ無視する」「キャッシュの削除に失敗しても気にしない」のように、特定の例外だけは無視して処理を続けたい場面がある。try/except/passを3行書く代わりに1行で書けるので実務で使われるが、その例外が起きた行より後のwithブロックの中身が実行されないという挙動は誤解しやすい。", "kid": "with contextlib.suppress(ZeroDivisionError): に入るとprint(''before'')が実行される。次の1/0でZeroDivisionErrorが起きるが、suppressがこの例外を握りつぶすので、プログラムは止まらずwithブロックを抜ける。ただしwithブロックの残り（print(''after'')）は実行されないままブロックを抜け、続くprint(''done'')だけが実行される。", "eg": "『この種類の忘れ物だけは届け出なくていい』という規則があるロッカー室のようなもの。指定した忘れ物（ZeroDivisionError）が起きても大騒ぎ（プログラム停止）にはならないが、その場でやりかけだった作業の続き（print(''after'')）はやらずに、そのままロッカー室を出て次の用事（print(''done'')）に進む。", "terms": [["contextlib.suppress", "指定した例外クラスが起きてもプログラムを止めず、withブロックを抜けるだけにするコンテキストマネージャ"], ["ZeroDivisionError", "0で割り算をしたときに発生する例外"]], "think": "①with contextlib.suppress(ZeroDivisionError): に入り、print(''before'')が実行されて1行目に''before''が出力される。②次の1/0でZeroDivisionErrorが発生する。③suppressはこの例外を検知すると、プログラムを止めずにwithブロックをそこで打ち切って正常に抜ける。④打ち切られたのでwithブロックの残りのprint(''after'')は実行されない。⑤withの外にあるprint(''done'')は普通に実行され、2行目に''done''が出力される。", "vs": "try: ... except ZeroDivisionError: pass と書いた場合も似た結果になるが、suppressは『この例外が起きたらブロックを抜ける』という1行で書ける省略形。exceptと違って、例外の情報（メッセージなど）を変数で受け取ることはできない。", "opt": ["正解。1/0でZeroDivisionErrorが起きるとsuppressがそれを握りつぶしてwithブロックを抜けるので、''before''の後は''after''を飛ばしていきなり''done''が出力される。", "例外が起きた時点でwithブロックの残りは実行されずにブロックを抜ける。suppressは例外を無視してブロックの続きを最後まで実行するわけではないので、''after''は出力されない。", "suppressは指定した例外を実際に握りつぶすので、そこでプログラムが停止することはない。''before''の後、withの外のprint(''done'')まで普通に実行が進む。", "suppressが握りつぶすのはwithブロックの中で起きた例外だけで、withの外にあるprint(''done'')の実行そのものが妨げられることはない。"], "calc": "①with contextlib.suppress(ZeroDivisionError): に入り、print(''before'')が実行されて1行目に''before''が出力される。\n②次の行1/0が実行され、ZeroDivisionErrorが発生する。\n③suppressに指定した例外クラスと一致するので、この例外はここで握りつぶされる。\n④例外が起きた時点でwithブロックの残り（print(''after'')）はスキップされ、withブロックを正常に抜ける。\n⑤withの外にあるprint(''done'')が実行され、2行目に''done''が出力される。"}'),

  ('python-drill-q124', 'デコレータとコンテキストマネージャ',
   'このコードを実行すると何が出力される？',
   'def safe(func):
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except ZeroDivisionError:
            return -1
    return wrapper

@safe
def divide(a, b):
    return a / b

print(divide(10, 0))
print(divide(10, 2))',
   '["1行目に -1、2行目に 5.0 が出力される", "エラーになる（ZeroDivisionErrorがそのまま外に伝わる）", "1行目に 5.0、2行目に -1 が出力される", "1行目に None、2行目に 5.0 が出力される"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（デコレータのwrapperでtry/exceptを挟み、元の関数の例外を処理してから返す）", "point": "wrapperの中でfunc(*args, **kwargs)をtryで囲み、対象の例外をexceptで受けてreturnすれば、元の関数が例外を投げても呼び出し元にはその例外が伝わらず、代わりにexceptで返した値が返る。", "why_asked": "外部APIの呼び出しやDBアクセスなど『失敗してもデフォルト値で処理を続けたい』場面で、呼び出す側のコードを毎回try/exceptで囲む代わりに、デコレータ側で一括して例外処理をまとめる書き方がよく使われる。この場合、元の関数を呼ぶ側からは例外が起きたことすら見えなくなる点を理解しておく必要がある。", "kid": "divide(10, 0)を呼ぶと実際にはwrapperが動き、中でdivide(10, 0)を実行しようとしてZeroDivisionErrorが起きるが、wrapperのexceptがそれを捕まえて-1を返す。だから最初のprintは-1。次のdivide(10, 2)は例外が起きずに10/2=5.0がそのまま返るので、2番目のprintは5.0。", "eg": "窓口の担当者が、裏で処理に失敗しても『規定のエラー番号（-1）』を渡して対応するようなもの。窓口に来た客（呼び出し元）には裏で何が起きて失敗したのかは伝わらず、規定の代わりの結果だけが渡される。", "terms": [["try/except", "例外が起きそうな処理をtryで囲み、指定した種類の例外が起きたときだけexceptの中身を実行する構文"], ["ZeroDivisionError", "0で割り算をしたときに発生する例外"], ["デフォルト値を返す", "例外が起きた場合に、処理を止める代わりにあらかじめ決めた値を代わりの結果として返すこと"]], "think": "①print(divide(10, 0))を実行すると、実際にはwrapper(10, 0)が動く。②tryの中でfunc(10, 0)＝元のdivide(10, 0)が呼ばれ、10/0でZeroDivisionErrorが発生する。③exceptがこれを捕まえ、return -1が実行される。例外はここで処理し切られ、呼び出し元には伝わらない。④結果として1行目に-1が出力される。⑤続くprint(divide(10, 2))では、func(10, 2)＝10/2が例外なく計算されて5.0が返り、tryの中のreturnがそのままwrapperの戻り値になる。⑥2行目に5.0が出力される。", "vs": "もしexcept節を書かずにwrapperを書いていたら、divide(10, 0)のZeroDivisionErrorはそのまま呼び出し元まで伝わり、print(divide(10, 0))の行でプログラムが止まっていた。exceptで捕まえてreturnする一手間があるかどうかが、例外を外に見せるか隠すかの分かれ目になる。", "opt": ["正解。divide(10, 0)はwrapperのtry内でZeroDivisionErrorが起き、exceptが-1を返す。divide(10, 2)は例外なく5.0が計算されてそのまま返る。", "wrapperのtry/exceptがZeroDivisionErrorを捕まえてreturn -1しているので、この例外がそのまま呼び出し元のprintまで伝わることはない。", "1回目の呼び出しdivide(10, 0)は0除算でexceptに入って-1を返し、2回目のdivide(10, 2)は例外なく5.0を返す。呼び出した順番のまま1行目に-1、2行目に5.0が出力される。", "exceptブロックにはreturn -1と明示されているので、wrapperはNoneではなく-1を返す。"], "calc": "1回目の呼び出し（divide(10, 0)）:\n①print(divide(10, 0))を実行すると、実際にはwrapper(10, 0)が動く。\n②tryの中でfunc(10, 0)＝元のdivide(10, 0)が呼ばれ、10/0が計算されようとしてZeroDivisionErrorが発生する。\n③except ZeroDivisionError:がこれを捕まえ、return -1が実行される。例外はここで処理され、外には伝わらない。\n④wrapperの戻り値-1が1行目に出力される。\n\n2回目の呼び出し（divide(10, 2)）:\n⑤tryの中でfunc(10, 2)＝10/2が例外なく計算され、5.0が返る。exceptには入らない。\n⑥wrapperの戻り値5.0が2行目に出力される。"}'),

  ('python-drill-q125', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def move(src, dst, /, count=1):
    return f"{src}->{dst} x{count}"

print(move(src="A", dst="B", count=2))',
   '["エラーになる（TypeError: srcとdstをキーワードで渡しているため）", "A->B x2", "エラーになる（TypeError: countの前にも*が必要なため位置引数が渡せない）", "A->B x1"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（/より前にある位置専用引数）", "point": "定義の引数リストに/があると、それより前の引数は位置引数としてしか渡せない。キーワードで渡すとエラーになる。", "why_asked": "ライブラリのAPI設計で「この引数名は将来変わるかもしれないので名前を指定させたくない」という意図で使われる書き方。知らないとsrc=\"A\"のように名前を書いて渡してTypeErrorに戸惑う。", "kid": "def move(src, dst, /, count=1)の/より前にあるsrcとdstは、呼び出すときに必ず位置（順番）で渡さなければならない決まり。move(src=\"A\", dst=\"B\", count=2)はsrcとdstをキーワードで渡そうとしているので、この決まりに反してエラーになる。", "eg": "受付で「番号札の順番どおりに進んでください、名前を呼ばれてから進んではいけません」という窓口のようなもの。番号（位置）でしか案内を受け付けておらず、名前（キーワード）を名乗っても通してもらえない。", "terms": [["位置専用引数", "/より前に書かれた引数。呼び出し時に必ず位置（順番）で渡す必要があり、キーワードでは渡せない"], ["/（スラッシュ）", "それより前が位置専用引数、後ろが通常の引数であることを区切る印。Python 3.8以降で使える"]], "think": "def move(src, dst, /, count=1)の/は「これより前の引数は位置専用」という区切りを表す。srcとdstはこの/より前にあるので、呼び出し時は必ずmove(\"A\", \"B\", ...)のように順番で渡さなければならない。move(src=\"A\", dst=\"B\", count=2)はsrcとdstをキーワードで渡そうとしているが、位置専用引数はキーワードでは受け取れないため、TypeErrorになる。countは/より後ろにあるので通常どおりキーワードで渡せる。", "vs": "*より後ろの引数（キーワード専用引数）はキーワードでしか渡せないのに対し、/より前の引数（位置専用引数）は逆に位置でしか渡せない。向きが正反対の制約であることに注意。", "opt": ["正解。srcとdstは/より前にある位置専用引数なので、move(src=\"A\", dst=\"B\", count=2)のようにキーワードで渡すとTypeErrorになる。", "srcとdstを位置引数として渡せば\"A->B x2\"になるが、このコードはキーワードで渡しているためエラーになる。", "/より後ろにあるcountの渡し方には*は関係ない。エラーの原因は/より前にあるsrcとdstをキーワードで渡していることで、countの渡し方が原因ではない。", "countにキーワードでcount=2を渡すこと自体は/より後ろの引数なので問題ない。エラーの原因は/より前にあるsrcとdstの渡し方。"]}'),

  ('python-drill-q126', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def apply_discount(price, *, rate=0.1):
    return price - price * rate

print(apply_discount(1000))
print(apply_discount(1000, rate=0.2))',
   '["900.0 の後に 800.0", "900 の後に 800", "エラーになる（*の後のrateは呼び出し時に必ず値を指定しなければならないため）", "800.0 の後に 900.0"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（*だけを書いてキーワード専用を区切る書き方）", "point": "def apply_discount(price, *, rate=0.1)の*は「ここから先はキーワード専用」という区切りにすぎず、rateにはデフォルト値があるので省略して呼び出しても構わない。", "why_asked": "*args（可変長引数として値を集める書き方）と、区切りだけのための単独の*を混同しやすい。単独の*は値を集めず、その後ろの引数を「名前を書いて渡す専用」にするだけという違いを知らないと、デフォルト値付きのキーワード専用引数を省略していいのか判断に迷う。", "kid": "apply_discount(1000)はrateを省略しているのでデフォルト値の0.1が使われ、1000 - 1000*0.1で900.0になる。apply_discount(1000, rate=0.2)はrateにキーワードで0.2を渡しているので、1000 - 1000*0.2で800.0になる。", "eg": "「デフォルトは並盛りですが、大盛りにしたい人は『大盛りで』と口頭で伝えてください」という注文ルールのようなもの。何も言わなければ自動で並盛り（デフォルト値）になり、変えたいときだけ名前を言って指定する。", "terms": [["*（単独のアスタリスク）", "それより前が通常の引数、後ろがキーワード専用引数であることを区切る印。*args（可変長引数を集める書き方）とは別物で、それ自体は値を受け取らない"], ["キーワード専用引数のデフォルト値", "*より後ろの引数でも、他の引数と同じようにデフォルト値を設定でき、省略時はそのデフォルト値が使われる"]], "think": "1行目のprint(apply_discount(1000))はrateを渡していないので、キーワード専用引数rateのデフォルト値0.1が使われる。1000 - 1000*0.1 = 1000 - 100.0 = 900.0。2行目のprint(apply_discount(1000, rate=0.2))はrate=0.2をキーワードで渡しているので、1000 - 1000*0.2 = 1000 - 200.0 = 800.0。掛け算の結果は浮動小数点数なので、差の結果も900.0や800.0のように小数点付きで表示される。", "vs": "qty（デフォルト値の無いキーワード専用引数）を位置引数で渡すと必ずエラーになる書き方とは違い、今回のrateにはデフォルト値0.1があるため、キーワード専用でも省略が許される点が違う。", "opt": ["正解。rateを省略した1回目はデフォルト値0.1が使われ900.0、rate=0.2を渡した2回目は800.0になる。", "1000*0.1や1000*0.2の掛け算部分が浮動小数点数になるため、差の結果も900.0・800.0のように小数点付きで表示される。900・800のような整数表示にはならない。", "*の後ろのrateにはデフォルト値0.1が設定されているので、1回目の呼び出しでrateを省略してもエラーにはならない。", "1回目はrateを省略しているのでデフォルト値0.1が使われて900.0、2回目はrate=0.2が使われて800.0になる。呼び出した順番のとおりに900.0が先、800.0が後で出力される。"]}'),

  ('python-drill-q127', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def label(a, b, c):
    return f"{a}-{b}-{c}"

nums = [10, 20]
print(label(*nums, 30))',
   '["10-20-30", "エラーになる（*numsの後に30を続けて書くと引数の数が合わないため）", "30-10-20", "エラーになる（*numsはリストのまま1つの引数として渡されるため）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（呼び出し側での*によるリストのアンパック）", "point": "関数を呼び出す側で*リストと書くと、リストの中身が順番どおりに個別の位置引数として展開されて渡される。", "why_asked": "リストの中身を1個ずつ手で取り出してf(nums[0], nums[1], ...)と書く代わりに*numsとまとめて書けるが、書いた本人でも「リストが1つの塊のまま渡っている」のか「中身がバラされて渡っている」のか混同しやすく、可変長のデータを関数に渡すコードで誤解が起きやすい。", "kid": "label(*nums, 30)のnumsは[10, 20]。*を付けて渡しているので、リストの中身10と20が展開されて先頭からa, bに入り、続けて書いた30がcに入る。だから\"10-20-30\"になる。", "eg": "宅配便の詰め合わせ箱（リスト）を、受け取り口の前で開けて中身を1個ずつ順番に並べ直してから渡すようなもの。*を付けなければ箱ごとひとつのモノとして渡ってしまうが、*を付けると中身がバラされて1個ずつ受け取ってもらえる。", "terms": [["*によるアンパック（呼び出し側）", "関数を呼ぶときに*リストと書くと、リストの要素が順番どおりに展開されて複数の位置引数として渡される"], ["位置引数", "呼び出し時に順番で渡す引数。*numsで展開された値も、その後ろに書いた30も、どちらも順番どおりにa, b, cへ位置引数として渡る"]], "think": "nums = [10, 20]。label(*nums, 30)の*numsは、リスト[10, 20]の中身を展開して先頭から順に位置引数として渡す、という意味。つまりlabel(10, 20, 30)と書いたのと同じことになる。関数の定義はdef label(a, b, c)なので、a=10, b=20, c=30が代入され、f\"{a}-{b}-{c}\"は\"10-20-30\"になる。", "vs": "*を付けずにlabel(nums, 30)と書くと、numsはリストのまま1つの塊としてaに渡ってしまい、bに30、cには何も渡されずTypeErrorになる（引数が足りない）。*の有無でリストが展開されるかどうかがまったく変わる。", "opt": ["正解。*numsでリスト[10, 20]の中身が展開されてa, bに10, 20が渡り、続けて書いた30がcに渡るので\"10-20-30\"になる。", "*numsで展開された10, 20と、続けて書いた30を合わせるとちょうどa, b, cの3つ分の位置引数になるので、引数の数は過不足なく一致する。エラーにはならない。", "*numsは先頭から順番にa, bへ展開され、その後ろに書いた30が最後のcに入る。展開された値と後ろの値の順番が入れ替わることはない。", "*を付けているのでnumsはリストのまま1つの引数として渡るわけではなく、中身の10, 20が展開されて別々の位置引数になる。"]}'),

  ('python-drill-q128', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def countdown(n, log=[]):
    if n == 0:
        return log
    log.append(n)
    return countdown(n - 1, log)

print(countdown(3))
print(countdown(2))',
   '["[3, 2, 1] の後に [3, 2, 1, 2, 1]", "[3, 2, 1] の後に [2, 1]", "[2, 1, 0] の後に [1, 0, -1]", "[3, 2, 1] の後に [3, 2, 1, 2, 1, 0]"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（再帰関数とミュータブルなデフォルト引数の組み合わせ）", "point": "logのデフォルト値[]は関数を定義した瞬間に1回だけ作られる。再帰呼び出しの中ではlogを都度引き継いで正しく動くが、logを省略して呼び出した回どうしは同じあの1個のリストを共有し続ける。", "why_asked": "「再帰の中でちゃんとlogを引数として渡しているから大丈夫」と思い込みやすいが、危ないのは再帰の内側ではなく外側。一番外側の最初の呼び出しでlogを省略していると、別のタイミングで行った別の呼び出しの結果が残ったまま積み上がってしまう。", "kid": "countdown(3)は最初の呼び出しでlogを省略しているので、定義時に作られたあの1個の共有リストを使う。3, 2, 1の順にappendされて[3, 2, 1]になり、これが返る。次のcountdown(2)も最初の呼び出しでlogを省略しているので、また同じ共有リスト（すでに[3, 2, 1]になっている）を使う。2, 1の順にappendされて[3, 2, 1, 2, 1]になる。", "eg": "職場の共有ホワイトボード（デフォルトのlog）に、作業の途中経過を書き足していく係のようなもの。1つの作業（1回の再帰）の中で書き足していく分には問題ないが、前の作業で書いた内容を消さずに次の作業を始めてしまうと、前の作業のメモが残ったまま新しいメモが混ざってしまう。", "terms": [["ミュータブルなデフォルト引数", "リストのような書き換え可能なオブジェクトを関数のデフォルト値にすること。関数定義時に1回だけ作られ、以後の呼び出しで使い回される"], ["再帰呼び出し", "関数が自分自身を呼び出すこと。countdownの中でcountdown(n - 1, log)と自分自身を呼んでいる部分がそれにあたる"]], "think": "1回目のprint(countdown(3))。最初の呼び出しcountdown(3)はlogを省略しているので、定義時に作られた共有リスト（最初は[]）が使われる。n=3でlog.append(3)→[3]、再帰でcountdown(2, log)を呼ぶ（このときはlogを明示的に渡しているので同じリストを引き継ぐ）→append(2)→[3, 2]、countdown(1, log)→append(1)→[3, 2, 1]、countdown(0, log)でn==0になりlogをそのまま返す。よって1回目の出力は[3, 2, 1]。2回目のprint(countdown(2))。この最初の呼び出しも再びlogを省略しているので、また同じ共有リスト（すでに[3, 2, 1]になっている）が使われる。n=2でappend(2)→[3, 2, 1, 2]、countdown(1, log)→append(1)→[3, 2, 1, 2, 1]、countdown(0, log)で返る。よって2回目の出力は[3, 2, 1, 2, 1]。", "vs": "再帰の内側の呼び出し（countdown(n - 1, log)）はlogを明示的に渡しているので、1回のcountdown呼び出しの中では正しく1本の同じリストが引き継がれる。問題が起きるのは、一番外側の最初の呼び出し（countdown(3)やcountdown(2)）でlogを省略した場合で、これらは互いに独立したリストにはならず、あの共有リストを使い回してしまう。", "opt": ["正解。1回目のcountdown(3)は共有のデフォルトリストに3, 2, 1を積んで[3, 2, 1]を返す。2回目のcountdown(2)も最初の呼び出しでlogを省略しているので、[3, 2, 1]になっている同じ共有リストに2, 1をさらに積み、[3, 2, 1, 2, 1]になる。", "2回目のcountdown(2)も最初の呼び出しでlogを省略しているため、1回目とは別の新しい空リストが用意されるわけではない。1回目で[3, 2, 1]になった共有リストがそのまま引き継がれ、2, 1が追加される。", "log.append(n)はnをそのまま積んでいるのであって、n-1を積んでいるわけではない。n==0になった時点でappendせずにlogを返すので、0や-1が積まれることもない。", "n==0になった時点でif n == 0: return logによってappendせずにそのまま返るので、0が余分に積まれることはない。1回目は[3, 2, 1]で止まる。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"10\" y=\"16\" font-size=\"10\" fill=\"#8892a4\">logを省略すると定義時に作られた同じリストを使う</text><rect x=\"90\" y=\"30\" width=\"160\" height=\"40\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"170\" y=\"46\" font-size=\"10\" fill=\"#e8eaf0\" text-anchor=\"middle\">共有log（定義時に1個だけ）</text><text x=\"170\" y=\"62\" font-size=\"9\" fill=\"#60a5fa\" text-anchor=\"middle\">最初は []</text><line x1=\"170\" y1=\"70\" x2=\"170\" y2=\"86\" stroke=\"#2a2f3f\"/><text x=\"20\" y=\"100\" font-size=\"9\" fill=\"#c9a04a\">countdown(3) → append 3,2,1 → [3, 2, 1]</text><text x=\"20\" y=\"118\" font-size=\"9\" fill=\"#c9a04a\">countdown(2) → append 2,1 → [3, 2, 1, 2, 1]</text><text x=\"20\" y=\"134\" font-size=\"9\" fill=\"#8892a4\">2回とも同じ共有logを書き換えている</text></svg>"}'),

  ('python-drill-q129', '関数と引数',
   'このコードを実行すると何が出力される？',
   'def describe(x: int) -> str:
    return f"value={x}"

print(describe("hello"))',
   '["value=hello", "エラーになる（TypeError: xにはint型の値を渡さなければならないため）", "エラーになる（型ヒントに反する引数が渡されたため実行前にチェックではじかれる）", "エラーになる（アノテーション付きの関数は呼び出し時に自動で型チェックされるため）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（型ヒントは実行時にチェックされない）", "point": "x: intやdef describe(x: int) -> strのような型ヒント（アノテーション）は、Python自体には強制力が無い。実行時にstrを渡してもエラーにならず、そのまま実行される。", "why_asked": "型ヒントを書くとmypyのような静的解析ツールや、コードを読む人にとっては「この引数はint型を想定している」という情報になるが、Pythonのインタプリタ自身はその情報を見て止めてはくれない。型ヒントがあるから安全、と思い込んでいると、実行時に想定外の型が渡ってきて別の場所でエラーになったときに原因を見誤る。", "kid": "def describe(x: int) -> strのx: intやint) -> strはただのメモ書きのようなもので、Pythonはこれを見て呼び出しを止めたりしない。describe(\"hello\")は文字列を渡しているが、xにそのまま\"hello\"が代入され、f\"value={x}\"は\"value=hello\"になる。", "eg": "「未成年者立入禁止」という貼り紙のあるお店のようなもの。貼り紙（型ヒント）は目印として貼ってあるだけで、貼り紙自体には人を止める力はない。実際に見て判断して止めるのは店員（=型チェックツールや読む人）であって、貼り紙そのものが自動でドアをロックするわけではない。", "terms": [["型ヒント（アノテーション）", "def describe(x: int) -> strのx: intやint) -> strのように、引数や戻り値に想定する型を書き添える記法。実行時の動作には影響しない"], ["静的解析ツール", "mypyなどの、型ヒントを読んでコードを実行せずに型の矛盾を検出してくれる別のツール。Python本体の実行エンジンとは別物"]], "think": "def describe(x: int) -> strのx: intは「xにはint型を想定している」という注釈であって、Pythonのインタプリタに強制力を持たせるものではない。describe(\"hello\")を呼ぶと、xの型がintかどうかはチェックされずにそのままx=\"hello\"が代入される。関数の中身はf\"value={x}\"を返すだけなので、xが文字列であっても普通に文字列として埋め込まれ、\"value=hello\"が返る。それをprintするので画面には\"value=hello\"と表示される。", "vs": "型ヒントは、実行時に型を検査して合わなければ弾く機構（バリデーション）とは別物。実行時に本当に型をチェックしたい場合は、isinstance(x, int)のように自分でコードを書いて確認する必要がある。", "opt": ["正解。型ヒントint/strはPythonの実行時には強制力を持たないので、describe(\"hello\")は普通に実行され\"value=hello\"が返る。", "型ヒントはPython自体を止める仕組みではないので、int型以外の値を渡してもTypeErrorにはならない。", "型ヒントに反する値が渡っても、Pythonのインタプリタが実行前に自動でチェックして弾くような仕組みは無い。", "型ヒントを書いた関数であっても、呼び出し時にPython自身が型チェックを行うわけではない。型チェックが必要ならisinstance()などを自分で書くか、別途mypyのような静的解析ツールを使う必要がある。"]}'),

  ('python-drill-q130', '例外処理',
   'このコードを実行すると何が出力される？',
   'def normalize(value):
    try:
        return int(value) / 2
    except (TypeError, ValueError):
        return 0

print(normalize("abc"), normalize(None))',
   '["0 0", "エラーになる", "0 None", "0.0 0.0"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問う問題。", "point": "exceptにタプル(TypeError, ValueError)を書いたら、そのどちらが起きても同じexcept節1つだけで受け止められる。", "why_asked": "実務では「型が違う」「値が変換できない」の両方が起こりうる入力チェックがよくある。exceptを2回書かずに1行でまとめられることを知らないと、無駄に長いtry/exceptを書いてしまう。", "kid": "int(\"abc\")もint(None)もどちらもエラーになるが、exceptのカッコの中に2つの例外クラスを並べているので、どちらのエラーも同じ1つのexcept節で受け止められて0を返す。", "eg": "受付窓口に「風邪の人」「腹痛の人」どちらも同じ問診票（同じ対応）で受け付けるようなもの。症状（例外の種類）が違っても、窓口（except節）が1つで済む。", "terms": [["except (A, B):", "カッコで複数の例外クラスをタプルにまとめて書くと、そのどれか1つでも発生すればこのexcept節にマッチする、という意味になる"], ["TypeError", "そもそも渡した型が処理できない型のときに起きる例外。int(None)はNoneという型そのものが変換不能なので起きる"], ["ValueError", "型自体は正しいが、値の中身が変換できないときに起きる例外。int(\"abc\")は文字列という型は正しいが中身が数字でないので起きる"]], "think": "1行目: normalize(\"abc\") → try内でint(\"abc\")を実行 → \"abc\"は数字に変換できないのでValueErrorが発生 → exceptの(TypeError, ValueError)のうちValueErrorに一致 → 0を返す。\n2行目: normalize(None) → try内でint(None)を実行 → Noneという型そのものがintに変換できないのでTypeErrorが発生 → 同じexcept節の(TypeError, ValueError)のうちTypeErrorに一致 → 0を返す。\nどちらの呼び出しも例外は起きるが同じexcept節で受け止められて0が返るので、print(0, 0)となり「0 0」が出力される。", "vs": "except TypeError:とexcept ValueError:を別々に2つ書いても同じ結果になるが、処理内容が同じなら1つのexcept (TypeError, ValueError):にまとめた方が短く書ける。逆に型エラーと値エラーで違う処理をしたいなら、あえて2つの別々のexcept節に分けるべき。", "opt": ["正解。int(\"abc\")はValueError、int(None)はTypeErrorが起きるが、どちらもexcept (TypeError, ValueError):という1つのexcept節にまとまってマッチし、それぞれ0を返す。", "except節にタプルで複数の例外クラスを並べる書き方は正式な文法。どちらの例外が起きてもこのexcept節が正しく受け止めるので、プログラムが止まることはない。", "except節に一致した場合は必ず0を返すようにコードが書かれている。値がNoneだからといって特別にNoneがそのまま返るわけではない。", "except節に入った時点でtry内のint(value) / 2という計算は実行されずreturn 0だけが実行される。計算結果が浮動小数点になることはない。"], "calc": "1行ずつ確かめる。\n\n1回目の呼び出し: normalize(\"abc\")\n  try内: int(\"abc\") → \"abc\"は数字として解釈できない → ValueError発生\n  except (TypeError, ValueError): → ValueErrorはタプルに含まれるので一致 → return 0\n\n2回目の呼び出し: normalize(None)\n  try内: int(None) → Noneという型はintに変換できない → TypeError発生\n  except (TypeError, ValueError): → TypeErrorはタプルに含まれるので一致 → return 0\n\nprint(normalize(\"abc\"), normalize(None)) → 0 0"}'),

  ('python-drill-q131', '例外処理',
   'このコードを実行すると何が出力される？',
   'def check_age(age):
    assert age >= 0, f"age must be non-negative, got {age}"
    return "ok"

try:
    check_age(-5)
except AssertionError as e:
    print("caught:", e)',
   '["caught: age must be non-negative, got -5", "caught: age must be non-negative, got {age}", "age must be non-negative, got -5", "エラーになる（assertは通常のexceptでは捕まえられない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問う問題。", "point": "assert 条件, メッセージは、条件がFalseのときだけAssertionErrorを起こし、そのメッセージを例外の中身として持つ。AssertionErrorも他の例外と同じくexceptで捕まえられる。", "why_asked": "assertは「ここは絶対に成り立つはず」という前提チェックによく使われる。AssertionErrorが普通の例外として捕まえられることを知らないと、assertが失敗したときに何が起きるか予想できず、デバッグで混乱する。", "kid": "check_age(-5)を呼ぶとassertの条件age >= 0がFalseになるのでAssertionErrorが起き、そのメッセージ文字列を持ったままexcept AssertionErrorに捕まって、\"caught: \"に続けてメッセージが表示される。", "eg": "「持ち物検査で禁止物が見つかったら、理由を書いた紙を添えて呼び出される」ようなもの。assertが検査、メッセージが理由の紙、exceptが呼び出し窓口にあたる。", "terms": [["assert 条件, メッセージ", "条件がFalseのときだけ、メッセージを添えてAssertionErrorを送出する文。条件がTrueなら何も起きずに次の行に進む"], ["AssertionError", "assert文の条件が満たされなかったときに送出される例外クラス。他の例外と同様にexceptで捕まえられる"], ["f\"...{age}...\"", "f-string。文字列の中の{}にage変数の値をそのまま埋め込む書き方"]], "think": "1行目: check_age(-5)を呼ぶ → 関数内でassert age >= 0が評価される → age は -5 なので age >= 0 はFalse → 条件がFalseなのでAssertionErrorが送出され、その中身はf-stringで組み立てられた\"age must be non-negative, got -5\"というメッセージになる。\n2行目: この時点でreturn \"ok\"には到達しない。\n3行目: 呼び出し元のtry/exceptがAssertionErrorを捕まえ、except AssertionError as e:のeにこの例外オブジェクトが入る。\n4行目: print(\"caught:\", e)が実行される。print(\"caught:\", e)はeをprintに渡すとstr(e)、つまりassertに書いたメッセージ文字列が表示される仕組みなので、\"caught: age must be non-negative, got -5\"が出力される。", "vs": "assertにメッセージを書かなかった場合（assert age >= 0のみ）はAssertionErrorのメッセージが空になり、print(\"caught:\", e)は\"caught: \"の後ろに何も続かない。また、raise ValueError(...)と違い、assertはPythonの起動オプション（-O）で丸ごと無効化できる点も異なる。", "opt": ["正解。age >= 0がFalseになるのでassertの後ろに書いたメッセージ付きでAssertionErrorが送出され、except AssertionError as eがそれを捕まえてeの中身（メッセージ全文）が\"caught: \"の後に表示される。", "assertのメッセージ部分にはf\"...\"とf-stringが使われているので、{age}という書き方は実行時にageの値-5へときちんと置き換わる。波かっこのまま文字として残ることはない。", "eにはAssertionErrorオブジェクト全体が入り、print(\"caught:\", e)はそのstr表現、つまりassertに書いたメッセージ全文を表示する。\"caught: \"というprintの最初の引数が消えることはない。", "AssertionErrorは他の例外と同じ仕組みでexcept節に捕まえられる。except AssertionError as e:で明示的に指定しているので、プログラムが異常終了することはない。"], "calc": "1行ずつ確かめる。\n\ncheck_age(-5)を呼ぶ\n  assert age >= 0, f\"...\" → age = -5 なので age >= 0 は False → 条件不成立\n  → AssertionError(\"age must be non-negative, got -5\") が送出される（return \"ok\"には到達しない）\n\nexcept AssertionError as e: → 送出された例外に一致 → eに例外オブジェクトが入る\nprint(\"caught:\", e) → eをprintに渡すとstr(e)＝メッセージ文字列になる → \"caught: age must be non-negative, got -5\""}'),

  ('python-drill-q132', '例外処理',
   'このコードを実行すると何が出力される？',
   'class ApiError(Exception):
    def __init__(self, message, code):
        super().__init__(message)
        self.code = code

def call_api(status):
    if status != 200:
        raise ApiError("request failed", status)
    return "ok"

try:
    call_api(404)
except ApiError as e:
    print(e, e.code)',
   '["request failed 404", "request failed None", "404 request failed", "ApiError: request failed"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問う問題。", "point": "自作の例外クラスに__init__を定義して追加の引数（ここではcode）を持たせると、except節でe.codeのようにその追加情報にアクセスできる。super().__init__(message)を呼んでおけば、print(e)ではmessageの方だけが表示される。", "why_asked": "実務のAPIエラーやDBエラーでは「メッセージ」だけでなく「エラーコード」「HTTPステータス」など追加情報を例外に持たせたいことがよくある。組み込みのExceptionをそのまま継承しても、__init__を上書きすれば自由に属性を追加できることを知らないと、エラー情報をタプルやグローバル変数で無理やり受け渡す羽目になる。", "kid": "ApiErrorはExceptionを継承しつつ、メッセージに加えてcode（ここでは404）という自分だけの属性を持てるようにしている。call_api(404)がApiError(\"request failed\", 404)を投げると、except節でeからe.codeとして404を取り出せる。", "eg": "宅配便の不在票に「理由（不在でした）」だけでなく「追跡番号」も書いてあるようなもの。理由（message）は誰でも見る欄、追跡番号（code）は必要なときだけ問い合わせに使う追加情報にあたる。", "terms": [["__init__", "クラスからインスタンスを作るときに自動で呼ばれる初期化メソッド。ここではmessageとcodeという2つの引数を受け取れるようにしている"], ["super().__init__(message)", "親クラス（Exception）の初期化処理を呼び出す書き方。これによりmessageがExceptionの標準の仕組み（str(e)で表示される部分）にきちんと登録される"], ["self.code = code", "受け取ったcodeをインスタンス自身の属性として保存する行。これにより例外オブジェクトeからe.codeで後から取り出せるようになる"]], "think": "1行目: call_api(404)を呼ぶ → status(404)は200と一致しないので if文の中に入る → raise ApiError(\"request failed\", 404)が実行される。\n2行目: ApiErrorの__init__(self, message, code)がmessage=\"request failed\", code=404で呼ばれる → super().__init__(message)でExceptionの側に\"request failed\"が登録される → self.code = 404で追加のcode属性が保存される。\n3行目: except ApiError as e:がこの例外を捕まえる → eはApiErrorインスタンスで、e自体をprintするとstr(e)、つまりExceptionに登録した\"request failed\"が表示される。さらにe.codeで404が取り出せる。\n4行目: print(e, e.code)は\"request failed\"と404をスペース区切りで表示するので、\"request failed 404\"が出力される。", "vs": "もしsuper().__init__(message)を呼ばずにself.message = messageのように自分で属性を作るだけだと、print(e)はメッセージを表示せず空文字になる（Exceptionの標準の仕組みに登録されないため）。super().__init__()をきちんと呼んでおくことが、print(e)でメッセージが正しく表示されるための条件になる。", "opt": ["正解。super().__init__(message)によりmessage(\"request failed\")がExceptionの標準の仕組みに登録されるのでprint(e)は\"request failed\"を表示し、e.codeで追加属性の404も取り出せるので\"request failed 404\"となる。", "self.code = codeという行でself.codeにはraise ApiError(\"request failed\", status)で渡した404という値がそのまま保存される。Noneのままになることはない。", "print(e, e.code)はコードに書かれた順の通りeが先、e.codeが後に表示される。e.codeの数値の方が先に表示されるわけではない。", "print(e)はstr(e)の結果、つまりsuper().__init__(message)で登録した\"request failed\"というメッセージそのものを表示する。例外のクラス名は自動的には付かない。"], "calc": "1行ずつ確かめる。\n\ncall_api(404)を呼ぶ\n  status(404) != 200 → True → raise ApiError(\"request failed\", 404)\n\nApiError.__init__(self, \"request failed\", 404)\n  super().__init__(\"request failed\") → Exception側に\"request failed\"を登録（str(e)の元になる）\n  self.code = 404 → 追加属性codeに404を保存\n\nexcept ApiError as e: → eにこの例外オブジェクトが入る\nprint(e, e.code) → eはstr(e)＝\"request failed\"、e.code＝404 → \"request failed 404\""}'),

  ('python-drill-q133', '例外処理',
   'このコードを実行すると何が出力される？',
   'class ConfigError(Exception):
    pass

def load(config, key):
    try:
        return config[key]
    except KeyError as e:
        raise ConfigError(f"missing setting: {key}") from e

try:
    load({"a": 1}, "b")
except ConfigError as e:
    print(e)
    print(e.__cause__)',
   '["missing setting: b\n''b''", "missing setting: b\nb", "missing setting: b\nKeyError(''b'')", "missing setting: b\nNone"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問う問題。", "point": "raise 新しい例外 from 元の例外と書くと、新しい例外の__cause__属性に元の例外オブジェクトそのものが保存される。print(e.__cause__)はその元の例外のstr表現を表示するが、KeyErrorのstr表現はキーをクォート付きの''b''のような形で返す点に注意。", "why_asked": "実務では「低レベルの例外（KeyErrorなど）を、意味のある独自例外（ConfigErrorなど）に変換して投げ直す」パターンがよく使われる。このとき元のエラー情報を握りつぶさずfromで連鎖させておくと、後からe.__cause__でデバッグ時に元の原因を追跡できる。KeyErrorのstr表現にクォートが付くことを知らないと、ログ出力で意図しない見た目になって驚くことがある。", "kid": "load({\"a\": 1}, \"b\")は\"b\"というキーが辞書に無いのでKeyErrorが起き、それをexcept節がConfigErrorに変換してfrom eで元のKeyErrorを連鎖情報として持たせて投げ直す。外側でprint(e)はConfigErrorのメッセージ、print(e.__cause__)は元のKeyErrorそのものを表示し、KeyErrorはstrにするとキーをクォートで囲んだ''b''という形になる。", "eg": "警察の調書で「事件の直接の原因（本件）」と「その背後にある動機（原因となった別件）」を分けて記録するようなもの。ConfigErrorが本件、__cause__（KeyError）が動機にあたり、動機の記録の中にはキーである\"b\"が引用符付きの証拠品番号のような形で残っている。", "terms": [["raise X from e", "新しい例外Xを送出しつつ、eを新しい例外の__cause__属性として明示的に紐づける書き方。「eが原因でXが起きた」という連鎖情報が保持される"], ["__cause__", "raise ... from ...で明示的に指定された、元になった例外オブジェクトが格納される属性。except節で捕まえた例外eからe.__cause__としてアクセスできる"], ["KeyErrorのstr表現", "他の例外は通常メッセージ文字列がそのまま表示されるが、KeyErrorだけは存在しなかったキーをrepr（クォート付き）にした形で表示される、という特有の癖がある"]], "think": "1行目: load({\"a\": 1}, \"b\")を呼ぶ → try内でconfig[\"b\"]を実行 → \"a\"しかない辞書に\"b\"キーは無いのでKeyError(\"b\")が発生。\n2行目: except KeyError as e:がこれを捕まえる → raise ConfigError(f\"missing setting: b\") from eを実行 → 新しいConfigErrorを送出しつつ、その__cause__属性に元のKeyError(\"b\")オブジェクトを紐づける。\n3行目: 呼び出し元のexcept ConfigError as e:がこのConfigErrorを捕まえる。\n4行目: print(e) → ConfigErrorのstr表現、つまりコンストラクタに渡した\"missing setting: b\"がそのまま表示される。\n5行目: print(e.__cause__) → e.__cause__は元のKeyError(\"b\")オブジェクト → KeyErrorをstrにすると中身のキーをクォートで囲んだ形になるという特有の仕様があるため、''b''（クォート付き）が表示される。\nしたがって出力は1行目が\"missing setting: b\"、2行目が\"''b''\"の2行になる。", "vs": "raise ConfigError(...) from None と書くと連鎖情報を明示的に断ち切れるので、e.__cause__はNoneになる（このコードのように from e と書いた場合のみ元の例外がそのまま保存される）。またprint(e.__cause__)は__cause__オブジェクトのstr表現であってrepr表現ではないので、KeyError(''b'')のようにクラス名まで表示されるわけではなく、中身の''b''だけが表示される。", "opt": ["正解。raise ConfigError(...) from eによってConfigErrorの__cause__に元のKeyError(\"b\")が保存され、print(e.__cause__)はそのstr表現を表示する。KeyErrorのstr表現はキーをクォート付きにする仕様があるため''b''となる。", "KeyErrorのstr表現には他の例外に無い特有の仕様があり、存在しなかったキーをクォート付きの''b''という形で表示する。クォートなしのbになるわけではない。", "print(e.__cause__)はe.__cause__のstr表現であって、\"クラス名(引数)\"の形（repr表現）ではない。したがってKeyError(''b'')のようにクラス名が付いた形では表示されない。", "raise ConfigError(...) from eとfromを明示的に指定しているため、__cause__にはNoneではなく元のKeyErrorオブジェクトがそのまま保存される。"], "calc": "1行ずつ確かめる。\n\nload({\"a\": 1}, \"b\")を呼ぶ\n  try内: config[\"b\"] → 辞書に\"b\"キーが無い → KeyError(\"b\") 発生\n  except KeyError as e: → 一致 → raise ConfigError(\"missing setting: b\") from e\n    → 新しいConfigErrorを送出し、その__cause__属性に元のKeyError(\"b\")オブジェクトを紐づける\n\nexcept ConfigError as e: → 呼び出し元でConfigErrorを捕まえる\nprint(e) → ConfigErrorのstr表現＝\"missing setting: b\"\nprint(e.__cause__) → __cause__は元のKeyError(\"b\")オブジェクト → KeyErrorのstr表現はクォート付きの''b''\n\nよって出力は2行:\nmissing setting: b\n''b''", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n  <rect x=\"20\" y=\"45\" width=\"120\" height=\"46\" rx=\"6\" fill=\"none\" stroke=\"#2a2f3f\" stroke-width=\"1.5\"/>\n  <text x=\"80\" y=\"64\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">KeyError(''b'')</text>\n  <text x=\"80\" y=\"79\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">元の例外</text>\n  <rect x=\"200\" y=\"45\" width=\"120\" height=\"46\" rx=\"6\" fill=\"none\" stroke=\"#2a2f3f\" stroke-width=\"1.5\"/>\n  <text x=\"260\" y=\"64\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">ConfigError</text>\n  <text x=\"260\" y=\"79\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">新しい例外</text>\n  <line x1=\"140\" y1=\"60\" x2=\"198\" y2=\"60\" stroke=\"#60a5fa\" stroke-width=\"1.5\" marker-end=\"url(#arrow1)\"/>\n  <text x=\"170\" y=\"52\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">raise ... from e</text>\n  <line x1=\"198\" y1=\"110\" x2=\"140\" y2=\"110\" stroke=\"#c9a04a\" stroke-width=\"1.5\" marker-end=\"url(#arrow2)\"/>\n  <text x=\"170\" y=\"126\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">e.__cause__ で参照</text>\n  <defs>\n    <marker id=\"arrow1\" markerWidth=\"8\" markerHeight=\"8\" refX=\"6\" refY=\"3\" orient=\"auto\"><path d=\"M0,0 L6,3 L0,6 Z\" fill=\"#60a5fa\"/></marker>\n    <marker id=\"arrow2\" markerWidth=\"8\" markerHeight=\"8\" refX=\"6\" refY=\"3\" orient=\"auto\"><path d=\"M0,0 L6,3 L0,6 Z\" fill=\"#c9a04a\"/></marker>\n  </defs>\n</svg>"}'),

  ('python-drill-q134', '例外処理',
   'このコードを実行すると何が出力される？',
   'def cleanup():
    try:
        raise SystemExit("stop")
    except:
        print("cleanup ran, exception suppressed")

cleanup()
print("continues")',
   '["cleanup ran, exception suppressed\ncontinues", "continues\ncleanup ran, exception suppressed", "cleanup ran, exception suppressed", "エラーになる（SystemExitはexceptで止められないため）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問う問題。", "point": "例外クラスを指定しない裸のexcept:は、Exceptionを継承しないSystemExitやKeyboardInterruptのような「プログラムを終了させるための特別な例外」まで全部つかまえてしまう。except Exception:ならSystemExitはすり抜けてプログラムは意図通り終了する。", "why_asked": "裸のexcept:は「とにかく全部エラーを握りつぶす」書き方として一見便利に見えるが、Ctrl+Cによる中断(KeyboardInterrupt)や本来止めたいsys.exit()(SystemExit)まで握りつぶしてしまい、プログラムが止めたいのに止まらないという事故につながる。この違いを知らずに裸のexcept:を書き続けると、本番運用で「終了させたいのに終了しないプロセス」に悩まされる。", "kid": "SystemExitは通常の異常ではなく「プログラムを終了させてください」という合図の例外だが、except:に例外クラスを何も書かないと、この合図の例外まで区別なく捕まえてしまう。だからcleanup()の中でSystemExitが握りつぶされ、続くprint(\"continues\")までそのまま実行されてしまう。", "eg": "非常口の「避難してください」という館内放送を、雑音扱いにして無視してしまう受付係のようなもの。裸のexcept:はどんな放送（例外）も区別せず「とりあえず対応しました」で済ませてしまい、本当に避難すべき合図（SystemExit）まで見逃してしまう。", "terms": [["BaseException", "Pythonの全ての例外の一番の親クラス。SystemExitやKeyboardInterruptはこのBaseExceptionを直接継承しており、Exceptionは継承していない"], ["Exception", "通常のプログラムエラー（ValueErrorやKeyErrorなど）が継承する基底クラス。BaseExceptionのサブクラスの1つで、SystemExitやKeyboardInterruptはこの下には含まれない"], ["except:（裸のexcept）", "例外クラスを何も指定しないexcept節。Exceptionの範囲を超えて、BaseExceptionを継承する全ての例外（SystemExitやKeyboardInterruptも含む）を捕まえてしまう"], ["SystemExit", "sys.exit()を呼んだときなどに送出される、プログラムを終了させるための例外。あえてExceptionを継承しない設計になっており、通常のexcept Exception:では捕まらない"]], "think": "1行目: cleanup()を呼ぶ → try内でraise SystemExit(\"stop\")が実行される → 本来これはプログラムを終了させるための例外。\n2行目: 続くexcept:には例外クラスが何も書かれていない（裸のexcept） → 裸のexcept:はBaseExceptionを継承する例外なら何でも捕まえるので、Exceptionを継承していないSystemExitもこの節にマッチしてしまう。\n3行目: except節の中のprint(\"cleanup ran, exception suppressed\")が実行される → SystemExitはここで握りつぶされ、プログラムは終了しない。\n4行目: cleanup()の呼び出しが（例外を投げずに）普通に終わるので、続くprint(\"continues\")もそのまま実行される。\nしたがって出力は1行目が\"cleanup ran, exception suppressed\"、2行目が\"continues\"の2行になる。", "vs": "もしexcept:の代わりにexcept Exception:と書いていたら、SystemExitはExceptionを継承していないのでこの節には一致せず、SystemExitはcleanup()の外へそのまま伝播してプログラムを終了させる（continuesは出力されない）。「なんでも捕まえたい」ときでも、裸のexcept:ではなくexcept Exception:を使うのが安全とされる理由がこの違いにある。", "opt": ["正解。裸のexcept:はExceptionを継承しないSystemExitも含めて全ての例外を捕まえてしまうため、SystemExitは握りつぶされてcleanup()内のprintが実行され、その後プログラムは終了せずにcontinuesも出力される。", "cleanup()内のprintが先に実行され、cleanup()の呼び出しが終わってから次の行のprint(\"continues\")が実行される、というコードに書かれた順番が出力の順番になる。順序が入れ替わることはない。", "裸のexcept:がSystemExitを握りつぶしてしまうため、cleanup()の呼び出しはエラーを投げずに正常終了する。続くprint(\"continues\")の行が実行されないと考えるのは誤り。", "裸のexcept:はExceptionのサブクラスに限らずBaseExceptionを継承する例外全般を捕まえる、という正式な文法として動作しており、SystemExitを送出しても構文エラーにはならない。"], "calc": "1行ずつ確かめる。\n\ncleanup()を呼ぶ\n  try内: raise SystemExit(\"stop\") → SystemExit発生（BaseExceptionを継承、Exceptionは継承していない）\n  except: （裸のexcept、例外クラス指定なし）→ BaseException全般を捕まえるためSystemExitにも一致 → マッチする\n    → print(\"cleanup ran, exception suppressed\") 実行\n  → cleanup()は例外を投げずに正常終了\n\nprint(\"continues\") → cleanup()が正常終了したのでこの行にも到達 → 実行される\n\nよって出力は2行:\ncleanup ran, exception suppressed\ncontinues", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\">\n  <rect x=\"110\" y=\"10\" width=\"120\" height=\"28\" rx=\"5\" fill=\"none\" stroke=\"#2a2f3f\" stroke-width=\"1.5\"/>\n  <text x=\"170\" y=\"28\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">BaseException</text>\n  <line x1=\"170\" y1=\"38\" x2=\"70\" y2=\"70\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/>\n  <line x1=\"170\" y1=\"38\" x2=\"170\" y2=\"70\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/>\n  <line x1=\"170\" y1=\"38\" x2=\"270\" y2=\"70\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/>\n  <rect x=\"15\" y=\"70\" width=\"110\" height=\"28\" rx=\"5\" fill=\"none\" stroke=\"#60a5fa\" stroke-width=\"1.5\"/>\n  <text x=\"70\" y=\"88\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">Exception</text>\n  <rect x=\"115\" y=\"70\" width=\"110\" height=\"28\" rx=\"5\" fill=\"none\" stroke=\"#c9a04a\" stroke-width=\"1.5\"/>\n  <text x=\"170\" y=\"88\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">SystemExit</text>\n  <rect x=\"215\" y=\"70\" width=\"110\" height=\"28\" rx=\"5\" fill=\"none\" stroke=\"#c9a04a\" stroke-width=\"1.5\"/>\n  <text x=\"270\" y=\"88\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">KeyboardInterrupt</text>\n  <rect x=\"5\" y=\"110\" width=\"330\" height=\"22\" rx=\"4\" fill=\"none\" stroke=\"#8892a4\" stroke-width=\"1\" stroke-dasharray=\"3,3\"/>\n  <text x=\"170\" y=\"125\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">except: （裸）はこの3つ全部を捕まえる／except Exception: は左端だけ</text>\n</svg>"}'),

  ('python-drill-q135', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'def inner_gen():
    yield ''a''
    yield ''b''

def outer_gen():
    yield 1
    yield from inner_gen()
    yield 2

for value in outer_gen():
    print(value)',
   '["1 → a → b → 2", "1 → [''a'', ''b''] → 2", "1 → a → b", "1 → 2 → a → b"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（yield fromによるサブジェネレータへの委譲）", "point": "yield from 内側のジェネレータ() と書くと、内側のジェネレータが生成する値を1つずつそのまま外側に渡す。外側から見ると、内側のyield文がその場に展開されたのと同じ動きになる。", "why_asked": "大きなジェネレータを部品ごとに分割して書きたいとき、yield fromを知らないとfor文で回してyieldし直す冗長なコードを書いてしまう。逆に知っていれば1行でサブジェネレータに処理を委譲でき、コードの見通しが良くなる。", "kid": "outer_genはまず1を返し、次にyield from inner_gen()でinner_genが作る''a''と''b''をそのまま順番に返し、最後に2を返す。だから1→a→b→2の順に表示される。", "eg": "yield fromは、司会者（外側の関数）が「ここから先はゲストスピーカー（内側の関数）にマイクを渡します」と言って、ゲストの話が終わるまで黙って待ち、終わったら自分の話に戻る、というようなもの。聞いている側（呼び出し元）にはゲストの話も司会者の話も同じマイク（forループ）を通して届く。", "terms": [["yield from", "内側のジェネレータ（イテラブル）が生成する値を1つずつそのまま呼び出し元に渡す構文。forループでyieldし直すのと同じ効果を1行で書ける"], ["ジェネレータ関数", "yieldを含む関数。呼び出しただけでは中身は実行されず、ジェネレータオブジェクトが作られるだけ"], ["委譲（delegation）", "処理の一部を別の関数・オブジェクトに任せること。ここではouter_genが値を作る仕事をinner_genに任せている"]], "think": "for value in outer_gen(): の1周目でouter_genの中身が動く。まずyield 1で1が返り、表示は「1」。2周目でyield from inner_gen()に入り、inner_gen()が新しく動き出してそのyield ''a''がそのまま外側の値として返る。表示は「a」。3周目もinner_genの続きが動き、yield ''b''が返る。表示は「b」。inner_genの中身が尽きるとyield fromの行が終わり、outer_genの次の行yield 2に進む。表示は「2」。よって1→a→b→2の順になる。", "vs": "for x in inner_gen(): yield x と書いても同じ結果になるが、yield fromはこれを1行にまとめた書き方。さらにyield fromは内側のジェネレータのreturn値やsend()で送った値の橋渡しもできる点で、単純なforループより高機能（このコードではreturn値を使っていないので違いは表面化しない）。", "opt": ["正解。outer_genはyield 1→yield from inner_gen()で''a''と''b''をそのまま順に渡す→yield 2の順に値を返すので、1 → a → b → 2 の順に表示される。", "yield from inner_gen()が、内側のジェネレータが生成した値をまとめて1つのリストとして外側に渡すと誤解した場合の答え。実際にはyield fromはinner_genの値を1つずつバラして渡すので、[''a'', ''b'']のような塊としては出てこない。", "yield from の行に到達すると、そこでouter_gen自体の実行が終わる（returnのような働きをする）と誤解した場合の答え。実際にはinner_genの値を渡し終えたあと、outer_genの続き（yield 2）にちゃんと戻ってくる。", "yield fromで委譲された値は、outer_gen自身のyieldより後にまとめて出てくると誤解した場合の答え。実際には値が生成される順番どおりに1つずつ外へ渡るので、1の直後にa、bが続き、2は最後になる。"], "viz": "<svg viewBox=\"0 0 340 150\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">yield from による委譲の流れ</text><rect x=\"15\" y=\"30\" width=\"310\" height=\"34\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"170\" y=\"51\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">outer_gen: yield 1 → yield from inner_gen() → yield 2</text><rect x=\"70\" y=\"80\" width=\"200\" height=\"34\" rx=\"4\" fill=\"#232838\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/><text x=\"170\" y=\"101\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">inner_gen: yield ''a'' → yield ''b''</text><line x1=\"170\" y1=\"64\" x2=\"170\" y2=\"78\" stroke=\"#c9a04a\" stroke-width=\"1.4\"/><text x=\"290\" y=\"101\" font-size=\"9\" fill=\"#8892a4\">委譲中</text><text x=\"170\" y=\"128\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">呼び出し側には 1 → a → b → 2 の順で届く</text></svg>"}'),

  ('python-drill-q136', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'import itertools

counter = itertools.count(10, 5)
first_three = list(itertools.islice(counter, 3))
print(first_three)',
   '["[10, 15, 20]", "[10, 11, 12]", "[15, 20, 25]", "無限ループになり終わらない（プログラムが停止しない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（itertools.countとitertools.isliceの組み合わせ）", "point": "itertools.count(start, step)は無限に値を作り続けるジェネレータ。そのままlist()にすると終わらないが、itertools.islice(イテラブル, 件数)で先頭から件数分だけ切り出せば安全にlist化できる。", "why_asked": "無限に値を作るジェネレータ（count()やcycle()）をうっかりlist()やforループの外側でそのまま全部使おうとすると、プログラムが固まって二度と終わらない。islice等で件数を区切る組み合わせは、IDの連番採番やページングの先読みなど実務でもよく使う形。", "kid": "counterは10から5ずつ増える無限の数列(10,15,20,25,...)を作るジェネレータ。islice(counter, 3)でそこから先頭3個だけを取り出すので、[10, 15, 20]になる。", "eg": "ベルトコンベアで無限に流れてくる商品（count）から、最初の3個だけをカゴに取る（islice）ようなもの。ベルトコンベア自体は止まらなくても、カゴが3個でいっぱいになったらそこで手を止めれば安全に必要な分だけ手に入る。", "terms": [["itertools.count(start, step)", "startから始めてstepずつ増える値を無限に生成するジェネレータ。終わりがないのでそのままlist()にすると止まらない"], ["itertools.islice(iterable, 件数)", "イテラブルの先頭から指定した件数分だけを切り出す。無限のイテラブルでも件数を指定すれば有限にできる"], ["list()", "イテラブルの要素をすべて取り出してリストに変換する組み込み関数。無限のイテラブルに直接使うと終わらない"]], "think": "itertools.count(10, 5)は10, 15, 20, 25, ...と5ずつ増える値を無限に作るジェネレータを返す（この時点ではまだ何も計算されていない）。次にitertools.islice(counter, 3)で、そのジェネレータから先頭3個だけを取り出す指定をする。list()で実際に展開すると、10→15→20の3個が取り出されたところでislice側が「もう十分」と判断し打ち切る。よってfirst_threeは[10, 15, 20]になる。", "vs": "counterをそのままlist(counter)としてしまうと、count()は自分から終わることのない無限のジェネレータなので永久に値を作り続けプログラムが固まる。islice(counter, 3)を挟むことで「先頭3個だけ」という終わりを外側から与えている点が違う。", "opt": ["正解。counterは10, 15, 20, 25, ...と5ずつ増える無限の数列で、islice(counter, 3)がそこから先頭3個だけを取り出すので[10, 15, 20]になる。", "itertools.count(10, 5)の第2引数を「生成する個数」と誤解し、既定のステップ1で10, 11, 12, ...と1ずつ増える数列を作ってしまったと誤解した場合の答え。実際には第2引数は「増える幅（ステップ）」であり、生成する個数を制限するのはislice側の役割。", "islice(counter, 3)を「最初の1個を飛ばしてから3個取る」と誤解した場合の答え。実際にはisliceは先頭（0番目）から指定件数を取るので、最初の10も含まれる。", "itertools.countが無限に値を作り続けることだけに気を取られ、islice(counter, 3)が件数を区切っていることを見落とした場合の答え。実際にはisliceが3個取り出した時点でそこから先はcounterを呼ばなくなるので、プログラムは正常に終了する。"], "viz": "<svg viewBox=\"0 0 340 130\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">無限のベルトコンベアから3個だけ取る</text><line x1=\"15\" y1=\"55\" x2=\"325\" y2=\"55\" stroke=\"#2a2f3f\" stroke-width=\"1.4\"/><circle cx=\"40\" cy=\"55\" r=\"10\" fill=\"#232838\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/><text x=\"40\" y=\"59\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">10</text><circle cx=\"75\" cy=\"55\" r=\"10\" fill=\"#232838\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/><text x=\"75\" y=\"59\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">15</text><circle cx=\"110\" cy=\"55\" r=\"10\" fill=\"#232838\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/><text x=\"110\" y=\"59\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">20</text><circle cx=\"145\" cy=\"55\" r=\"10\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1\" stroke-dasharray=\"2,2\"/><text x=\"145\" y=\"59\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">25</text><text x=\"200\" y=\"59\" font-size=\"12\" fill=\"#8892a4\">…（無限に続く）</text><rect x=\"25\" y=\"40\" width=\"100\" height=\"30\" rx=\"4\" fill=\"none\" stroke=\"#c9a04a\" stroke-width=\"1.4\" stroke-dasharray=\"4,2\"/><text x=\"75\" y=\"95\" text-anchor=\"middle\" font-size=\"9\" fill=\"#c9a04a\">islice(counter, 3) がここで区切る</text><text x=\"170\" y=\"118\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">first_three = [10, 15, 20]</text></svg>"}'),

  ('python-drill-q137', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'def echo():
    while True:
        x = yield
        print("got", x)

g = echo()
next(g)
g.send("A")
g.send("B")',
   '["got A → got B", "got None → got A → got B", "got A", "エラーになる（2回目のsend()の前にnext()を挟まないとTypeErrorになる）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（ジェネレータのsend()による値の送り込み）", "point": "x = yield と書いた行は、next()で進めると「yieldの位置で一時停止」するだけで代入はまだ起きない。次にg.send(値)を呼ぶと、その値がxに代入されてから続きが実行される。", "why_asked": "next()とsend(None)は実は同じ動きだが、send(値)は「一時停止中のジェネレータに外から値を渡す」という双方向のやり取りができる。コルーチン的にジェネレータを使うコードで、いつ値が代入されいつ止まるのかを取り違えるとハマる。", "kid": "next(g)で最初のyieldまで進めて一時停止させ、g.send(\"A\")でその一時停止中のxに\"A\"を代入して続きを動かすとprint(\"got\", \"A\")が実行される。同じ流れがもう一度あってg.send(\"B\")でも「got B」が出る。", "eg": "yieldは「値を受け取るまで待っている窓口」のようなもの。next(g)は窓口を開けて待たせるだけの動作で、まだ誰も何も渡していない。g.send(\"A\")で初めて窓口に\"A\"という荷物を渡し、それを受け取った後の処理（printする）が動き出す。", "terms": [["x = yield", "ジェネレータの中でyieldをそのまま代入の右辺に書く形。next()で進めるとここで一時停止し、send()で渡された値がxに入って続きが動く"], ["g.send(値)", "一時停止中のジェネレータに値を渡して再開させるメソッド。渡した値がyield式の結果としてxに代入される"], ["next(g)", "g.send(None)と同じ動き。一時停止中のジェネレータを次のyieldまで進めるが、送り込む値がないのでxにはNoneが入る（ここではまだ何も代入されていない最初の起動）"]], "think": "g = echo()の時点では中身は未実行。next(g)を呼ぶと関数の先頭からwhile True:に入り、x = yieldの行で一時停止する（xへの代入はまだ行われていない）。次にg.send(\"A\")を呼ぶと、そこで初めて\"A\"がxに代入されて実行が再開し、print(\"got\", \"A\")で「got A」と表示される。その後whileの先頭に戻り、再びx = yieldで一時停止する。続けてg.send(\"B\")を呼ぶと同様に\"B\"がxに代入され、print(\"got\", \"B\")で「got B」と表示される。よって出力は got A → got B の順。", "vs": "next(g)はsend(None)と同じ効果だが、まだ誰もyieldの右側に値を渡していない「最初の起動（プライミング）」に使うのが一般的。send(値)は既に一時停止しているジェネレータに実際の値を渡すときに使う。最初にnext()で1回進めておかないと、まだ実行が始まっていないジェネレータにいきなりsend(値以外のNone以外)を呼ぶとTypeErrorになる点も違いの一つ。", "opt": ["正解。next(g)は最初のyieldまで進めて一時停止させるだけ。g.send(\"A\")でそのxに\"A\"が入りprintが動いて「got A」、同様にg.send(\"B\")で「got B」が出る。", "next(g)を呼んだ時点で、xにNoneが代入されてprint(\"got\", None)まで実行されると誤解した場合の答え。実際にはnext(g)はyieldの位置で止まるだけで、その行の代入・print自体はまだ実行されない。", "2回目のg.send(\"B\")を呼ぶとジェネレータが終わってしまう（StopIterationになる）と誤解した場合の答え。実際にはwhile True:で無限に繰り返すので、send()を呼ぶたびに同じ流れが何度でも動く。", "send()はジェネレータの生涯で1回しか呼べないと誤解した場合の答え。実際には一時停止のたびに何度でもsend()で値を渡せる。next(g)は最初の一時停止までジェネレータを進めるための呼び出しであり、既に一時停止しているジェネレータへの2回目以降のsend()にnext()を挟む必要はない。"], "viz": "<svg viewBox=\"0 0 340 160\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">send() による値の往復</text><rect x=\"15\" y=\"30\" width=\"120\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"75\" y=\"48\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">next(g) → 最初のyieldで停止</text><rect x=\"15\" y=\"70\" width=\"120\" height=\"28\" rx=\"4\" fill=\"#232838\" stroke=\"#60a5fa\" stroke-width=\"1.2\"/><text x=\"75\" y=\"88\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">g.send(\"A\") → x=\"A\"</text><rect x=\"185\" y=\"70\" width=\"140\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"255\" y=\"88\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">print(\"got\", \"A\") → got A</text><line x1=\"135\" y1=\"84\" x2=\"183\" y2=\"84\" stroke=\"#60a5fa\" stroke-width=\"1.4\"/><rect x=\"15\" y=\"110\" width=\"120\" height=\"28\" rx=\"4\" fill=\"#232838\" stroke=\"#c9a04a\" stroke-width=\"1.2\"/><text x=\"75\" y=\"128\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">g.send(\"B\") → x=\"B\"</text><rect x=\"185\" y=\"110\" width=\"140\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"255\" y=\"128\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">print(\"got\", \"B\") → got B</text><line x1=\"135\" y1=\"124\" x2=\"183\" y2=\"124\" stroke=\"#c9a04a\" stroke-width=\"1.4\"/></svg>"}'),

  ('python-drill-q138', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'result = sum((x for x in range(5)), 100)
print(result)',
   '["110", "10", "エラーになる（SyntaxError: 引数が2つあるのにジェネレータ式に丸括弧が付いている）", "エラーになる（TypeError: sum()は引数を2つ受け取れない）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（ジェネレータ式の丸括弧省略が使えない場合）", "point": "ジェネレータ式の外側の丸括弧を省略できるのは、それが関数呼び出しの唯一の引数のときだけ。他にも引数がある場合（このコードのsum(iterable, start)の第2引数100のように）は、ジェネレータ式を(x for x in range(5))と丸括弧でくくって他の引数とはっきり区切る必要がある。", "why_asked": "sum(x * x for x in range(5))のように丸括弧を1つ省略できる書き方に慣れていると、開始値や比較キーなど他の引数を追加したときにも省略できると思い込みがちだが、引数が2つ以上になった瞬間にジェネレータ式は必ず丸括弧で囲まないとPython自体が構文を解釈できない。この境界線を知らないと、書き換えのたびにSyntaxErrorの原因が分からず詰まる。", "kid": "(x for x in range(5))は0,1,2,3,4を1つずつ生成するジェネレータ式。sum()の第1引数としてそれを渡し、第2引数の100を合計の開始値にしているので、0+1+2+3+4=10に100を足して110になる。", "eg": "会計で「レシート1枚だけならそのまま渡していい」が「レシートと一緒に領収書も出すなら、レシートは封筒に入れて区別してください」と言われるようなもの。渡すものが1つだけなら簡易に渡せても、他にも一緒に渡すものがあると、どれがどれか分かるようにきちんと区切って渡す必要がある。", "terms": [["ジェネレータ式", "(x for x in range(5)) のように書く、値を1つずつ生成する式。ここでは丸括弧で囲んだ形がそのままsum()の第1引数になっている"], ["sum(iterable, start)", "第1引数のイテラブルの合計に、第2引数startの値を足し合わせて返す組み込み関数。startを省略すると0からの合計になる"], ["丸括弧の省略", "ジェネレータ式が関数呼び出しの唯一の引数のときだけ使える省略記法。第2引数以降がある場合は使えず、ジェネレータ式は必ず( )で囲む"]], "think": "(x for x in range(5))がジェネレータ式で、range(5)の0,1,2,3,4を1つずつ生成する。sum()には引数が2つ渡されている（第1引数がこのジェネレータ式、第2引数が100）ため、ジェネレータ式は丸括弧で囲んで他の引数と区切る必要があり、実際にそう書かれているのでSyntaxErrorにはならない。sum()はまず0+1+2+3+4=10を計算し、そこに開始値の100を足して110を返す。resultに110が入り、print(result)で「110」と表示される。", "vs": "sum(x * x for x in range(5))のように引数がジェネレータ式1つだけなら、外側の丸括弧を省略してsum(x * x for x in range(5))と書ける。しかしこのコードのように第2引数（開始値100）を渡す場合は省略できず、sum((x for x in range(5)), 100)と明示的に丸括弧で囲む必要がある。引数の個数がこの2つの書き方を分ける境界線。", "opt": ["正解。(x for x in range(5))は0,1,2,3,4を生成するジェネレータ式で、sum()の第1引数として渡され、第2引数の100が開始値になる。0+1+2+3+4=10に100を足して110になる。", "第2引数の100を開始値として使わず無視し、range(5)の合計0+1+2+3+4=10だけを答えた場合の誤り。実際にはsum(iterable, start)のstartはちゃんと合計に加算される。", "引数が2つあるときはジェネレータ式に丸括弧を付けてはいけない（付けると構文エラーになる）と誤解した場合の答え。実際には引数が2つ以上あるときこそジェネレータ式を丸括弧で囲む必要があり、このコードはその書き方を正しく満たしているのでエラーにはならない。", "sum()は引数を1つしか受け取れない関数だと誤解した場合の答え。実際にはsum(iterable, start)のように合計対象と開始値の2つの引数を受け取れる。"]}'),

  ('python-drill-q139', 'ジェネレータとメモリ',
   'このコードを実行すると何が出力される？',
   'def gen():
    yield 1
    yield 2
    raise ValueError("boom")
    yield 3

g = gen()
print(next(g))
print(next(g))
print(next(g))',
   '["1 → 2 → エラーになる（ValueError）", "1 → 2 → None", "1 → 2 → 3", "1 → 2 → エラーになる（StopIteration）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（ジェネレータ内で発生した例外の伝播）", "point": "ジェネレータの中でraiseが実行されると、そこで実行が止まり、その例外が呼び出し側（next()を呼んだ場所）にそのまま伝わる。値を使い切ったときに自動で出るStopIterationとは別物の「本物の」例外。", "why_asked": "ジェネレータは「値がなくなったらStopIterationで終わる」というイメージが強いせいで、ジェネレータの中で起きた別種の例外（ファイルが開けない、辞書のキーがない等）まで全部StopIterationとして飲み込まれると誤解しやすい。実際には普通の関数と同じように、発生した例外の種類のまま呼び出し側に飛んでくるので、try/exceptで捕まえる型を間違えるとハマる。", "kid": "1回目・2回目のnext(g)ではyield 1とyield 2でそれぞれ1と2が返る。3回目のnext(g)ではyield 3にたどり着く前にraise ValueError(\"boom\")が実行されるので、そこでValueErrorが発生してプログラムが止まる。", "eg": "工場のベルトコンベア（ジェネレータ）が、3個目の部品を作ろうとした瞬間に機械が故障して止まったようなもの。「部品がもう無いので終わります」（StopIteration）という穏やかな終わり方ではなく、「故障しました」（ValueError）という別種の警報が現場（呼び出し側）にそのまま鳴り響く。", "terms": [["raise", "その場で例外を発生させる文。実行中の関数（ジェネレータも含む）はそこで中断され、例外が呼び出し元に伝わっていく"], ["StopIteration", "ジェネレータがyieldをすべて実行し終えて自然に終了したときに、next()の呼び出し側へ自動的に送出される特別な例外。ここでのValueErrorのように「途中で問題が起きた」ことを示すものではない"], ["例外の伝播", "関数の中で発生した例外が、それを捕まえるtry/exceptが無い限り、呼び出し元へ次々と伝わっていくこと。ジェネレータでも通常の関数と同じ仕組みで伝播する"]], "think": "1回目のnext(g)はgenの先頭から実行され、yield 1で止まって1を返す。print(next(g))は「1」と表示する。2回目のnext(g)は続きから再開し、yield 2で止まって2を返す。print(next(g))は「2」と表示する。3回目のnext(g)は続きから再開し、次の行raise ValueError(\"boom\")が実行される。この行はyield 3より前にあるため、yield 3には決して到達しない。ValueErrorはgenの中でキャッチされていないので、next(g)を呼んだ3回目のprint(next(g))の場所までそのまま伝わり、そこでプログラムはValueError: boomを出して止まる（3回目のprintの丸括弧の中身が確定しないので「2」より後には何も表示されない）。", "vs": "ジェネレータの値をすべて使い切ったときに出るStopIterationは、forループなどが「もう終わりだな」と判断するために使う正常終了のサインで、通常はエラーとして表面化しない（for文が自動で処理する）。一方このコードのValueErrorは、genの中身が自分の意思でraiseした「異常」を示す例外であり、forループやnext()はそれを揉み消さずにそのまま呼び出し側へ伝える。", "opt": ["正解。1回目・2回目のnext(g)でyield 1、yield 2の1、2が返る。3回目はyield 3に到達する前のraise ValueError(\"boom\")が実行され、ValueErrorが呼び出し側にそのまま伝わってプログラムが止まる。", "ジェネレータの中で何か問題が起きても、返り値がNoneになるだけで処理は止まらずに続くと誤解した場合の答え。実際にはraiseされた例外は握りつぶされず、そのままnext()の呼び出し元まで伝わってプログラムを止める。", "raiseの行を見落とし、その次のyield 3がそのまま実行されて3が返ってくると誤解した場合の答え。実際にはraiseの行がyield 3より先に実行されるため、そこで処理が止まりyield 3には到達しない。", "ジェネレータの中で起きた例外は種類に関わらずすべてStopIterationに変換されると誤解した場合の答え。実際にはStopIterationは値を使い切って自然に終了したときだけ自動的に送出されるものであり、ここで実際に発生するのはgenが自分でraiseしたValueErrorそのもの。"], "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"170\" y=\"16\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">例外の伝播（StopIterationとは別物）</text><rect x=\"15\" y=\"30\" width=\"90\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"60\" y=\"48\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">yield 1 → 1</text><rect x=\"125\" y=\"30\" width=\"90\" height=\"28\" rx=\"4\" fill=\"#1b1f2a\" stroke=\"#2a2f3f\" stroke-width=\"1.2\"/><text x=\"170\" y=\"48\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">yield 2 → 2</text><rect x=\"235\" y=\"30\" width=\"90\" height=\"28\" rx=\"4\" fill=\"#2a1418\" stroke=\"#ff7b72\" stroke-width=\"1.4\"/><text x=\"280\" y=\"48\" text-anchor=\"middle\" font-size=\"9\" fill=\"#ff7b72\">raise ValueError</text><line x1=\"105\" y1=\"44\" x2=\"123\" y2=\"44\" stroke=\"#60a5fa\" stroke-width=\"1.4\"/><line x1=\"215\" y1=\"44\" x2=\"233\" y2=\"44\" stroke=\"#60a5fa\" stroke-width=\"1.4\"/><text x=\"280\" y=\"70\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">yield 3 には到達しない</text><line x1=\"280\" y1=\"58\" x2=\"280\" y2=\"90\" stroke=\"#ff7b72\" stroke-width=\"1.4\"/><rect x=\"185\" y=\"92\" width=\"190\" height=\"28\" rx=\"4\" fill=\"#2a1418\" stroke=\"#ff7b72\" stroke-width=\"1.4\"/><text x=\"280\" y=\"110\" text-anchor=\"middle\" font-size=\"9\" fill=\"#ff7b72\">呼び出し側にValueErrorが伝わり停止</text></svg>"}'),

  ('python-drill-q140', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'a = int(''100'')
b = int(''100'')
c = int(''300'')
d = int(''300'')
print(a is b, c is d)',
   '["True False", "True True", "False False", "False True"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問うている。", "point": "整数の値が-5〜256の範囲に収まっているなら、CPythonはあらかじめ用意しておいた同じオブジェクトを使い回すのでisはTrueになる。範囲外の整数は毎回新しく作られるのでisはFalse。", "why_asked": "小さい整数の一致をたまたま確認できてしまうと『isで値の一致を調べても大丈夫そうだ』と誤解しやすい。だが範囲外の整数や他の型では同じ保証はなく、値の比較には常に==を使うべきという原則を体で覚えておく必要がある。", "kid": "100はキャッシュ範囲内なのでaとbは同じオブジェクトを指しis はTrue、300は範囲外なのでcとdは別オブジェクトになりis はFalse。", "eg": "小さいサイズの定規（よく使う100mmなど）は文房具屋があらかじめ棚に並べておいて、誰が頼んでも同じ棚の同じ定規を渡す。でも300mmの特注定規は毎回別注文になるので、同じサイズを2回頼んでも毎回別の実物が届く、というようなイメージ。", "terms": [["is演算子", "2つの変数が同じオブジェクト（メモリ上の同じ実体）を指しているかどうかを調べる演算子"], ["small int cache（整数キャッシュ）", "CPythonが起動時に-5から256までの整数オブジェクトをあらかじめ作っておき、使い回す最適化"], ["int()", "文字列などを整数に変換する組み込み関数"]], "think": "1行目でint(''100'')が実行され、文字列''100''から整数100が作られてaに代入される。2行目でも同じくint(''100'')が実行され100が作られるが、100は-5〜256のキャッシュ範囲内なので、CPythonは新しいオブジェクトを作らずあらかじめ用意されている100のオブジェクトを返す。よってa is bはTrue。3行目・4行目はint(''300'')で300を作るが、300はキャッシュ範囲外なので毎回新しいオブジェクトが作られる。よってc is dはFalse。", "vs": "ここが決め手: これはPythonの言語仕様として保証された挙動ではなく、CPython（標準の処理系）固有の実装上の最適化にすぎない。他の処理系や将来のCPythonのバージョンで同じ保証があるとは限らない。似た紛らわしい話として、リテラルで a = 100; b = 100 と直接書いた場合も同じ結果になるが、それは同じコードの中でコンパイラが同じ値をひとつの定数にまとめる最適化も同時に働くため、整数キャッシュ由来なのかコンパイラの最適化由来なのか区別が付きにくい。この問題ではint(''100'')のように文字列から変換することで、コンパイル時にまとめられない『実行時に生成された整数』同士を比較しており、-5〜256のキャッシュ挙動そのものを確認できる。値が同じかどうかを調べたいときは、常に==を使うのが安全。", "opt": ["正解。100は-5〜256のキャッシュ範囲内なので同じオブジェクトが再利用されis はTrue。300は範囲外なので毎回新しいオブジェクトが作られis はFalse。", "全ての整数が値さえ同じなら常に同じオブジェクトになると考えると出てくる誤り。キャッシュされるのは-5〜256の範囲だけで、300のような大きい整数には及ばない。", "整数は常に別オブジェクトになると考えると出てくる誤り。実際には-5〜256の範囲内の整数はCPythonにあらかじめ用意されておりis はTrueになる。", "キャッシュの範囲を逆に覚えていると出てくる誤り。小さい整数がキャッシュされ大きい整数はキャッシュされない、という向きであって逆ではない。"], "calc": "1行ずつisの判定を追う。\n\na = int(''100'')\n・文字列''100''を整数に変換して100を作る\n\nb = int(''100'')\n・同じく100を作るが、100は-5〜256のキャッシュ範囲内なのでCPythonは新しいオブジェクトを作らず、あらかじめ用意されている100のオブジェクトを返す\n・つまりaとbは同じオブジェクト → a is b は True\n\nc = int(''300'')\n・300を作る。300はキャッシュ範囲外なので普通に新しいオブジェクトが作られる\n\nd = int(''300'')\n・こちらも300を作るが、キャッシュされていないので、cとは別の新しいオブジェクトが作られる\n・つまりcとdは別オブジェクト → c is d は False", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"10\" y=\"14\" font-size=\"10\" fill=\"#8892a4\">キャッシュ範囲内 (-5〜256)</text><rect x=\"10\" y=\"22\" width=\"60\" height=\"28\" rx=\"4\" fill=\"#2a2f3f\" stroke=\"#60a5fa\"/><text x=\"40\" y=\"41\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\">100</text><text x=\"14\" y=\"70\" font-size=\"10\" fill=\"#8892a4\">a</text><text x=\"34\" y=\"70\" font-size=\"10\" fill=\"#8892a4\">b</text><line x1=\"17\" y1=\"64\" x2=\"32\" y2=\"50\" stroke=\"#60a5fa\"/><line x1=\"37\" y1=\"64\" x2=\"40\" y2=\"50\" stroke=\"#60a5fa\"/><text x=\"150\" y=\"14\" font-size=\"10\" fill=\"#8892a4\">キャッシュ範囲外 (300)</text><rect x=\"150\" y=\"22\" width=\"60\" height=\"28\" rx=\"4\" fill=\"#2a2f3f\" stroke=\"#c9a04a\"/><text x=\"180\" y=\"41\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\">300</text><text x=\"154\" y=\"70\" font-size=\"10\" fill=\"#8892a4\">c</text><line x1=\"157\" y1=\"64\" x2=\"175\" y2=\"50\" stroke=\"#c9a04a\"/><rect x=\"250\" y=\"22\" width=\"60\" height=\"28\" rx=\"4\" fill=\"#2a2f3f\" stroke=\"#c9a04a\"/><text x=\"280\" y=\"41\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\">300</text><text x=\"254\" y=\"70\" font-size=\"10\" fill=\"#8892a4\">d</text><line x1=\"257\" y1=\"64\" x2=\"275\" y2=\"50\" stroke=\"#c9a04a\"/></svg>"}'),

  ('python-drill-q141', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'import copy

class Counter:
    def __init__(self, n):
        self.n = n
    def __copy__(self):
        return Counter(0)

c1 = Counter(5)
c2 = copy.copy(c1)
print(c1.n, c2.n)',
   '["5 0", "5 5", "0 0", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問うている。", "point": "copy.copy()はまずオブジェクトに__copy__メソッドが定義されていないか確認し、あればデフォルトの浅いコピー処理の代わりにそちらを使う。", "why_asked": "自作クラスで『コピーのたびに初期化し直したいフィールド』や『参照を共有してはいけないフィールド』がある場合、__copy__を自分で定義してコピーの挙動を制御できる。これを知らないと、copy.copy()は常に同じ浅いコピーしかしないと思い込み、意図しない参照共有バグを埋め込んでしまう。", "kid": "c1.nは5のまま変わらず、c2は__copy__が作ったCounter(0)という別インスタンスになるのでc2.nは0になる。", "eg": "名刺をコピー機でコピーするとき、普通のコピー機ならそのまま複製する。でも『コピーするたびに通し番号を0にリセットする特注コピー機』を用意していたら、原本の番号はそのままで、コピーされた方だけ番号が0から始まる、というようなイメージ。", "terms": [["__copy__", "copy.copy()が呼ばれたときに、デフォルトの浅いコピー処理の代わりに実行される特殊メソッド（自分で定義できる）"], ["copy.copy()", "オブジェクトの浅いコピーを作る標準ライブラリの関数"], ["インスタンス", "クラスから作られた実体のオブジェクト"]], "think": "1行目でCounter(5)によりc1が作られ、c1.nは5になる。2行目のcopy.copy(c1)は、まずc1のクラスに__copy__メソッドが定義されているかを確認する。定義されているのでデフォルトの浅いコピー処理は使われず、代わりにc1.__copy__()が呼ばれる。このメソッドの中身はCounter(0)を新しく作って返すだけなので、c2はnが0の新しいCounterインスタンスになる。c1自身は一切変更されないので、c1.nは5のまま。よってprintはc1.n=5とc2.n=0を出力する。", "vs": "デフォルトのcopy.copy()は、__copy__が定義されていなければインスタンスの__dict__（属性の集まり）をそのままコピーして新しいオブジェクトの属性にする浅いコピーを行う。__copy__を定義すると、その自動処理を完全に上書きできる。似た仕組みにcopy.deepcopy()用の__deepcopy__もあり、こちらは深いコピーの挙動だけを個別に上書きできる。", "opt": ["正解。__copy__が定義されているのでcopy.copy(c1)はそれを呼び出し、nが0の新しいCounterを返す。c1自身は変わらない。", "__copy__を定義してもcopy.copy()には反映されず、デフォルトの浅いコピー（属性をそのまま複製）が使われると考えると出てくる誤り。実際にはcopy.copy()は__copy__があればそちらを優先して使う。", "copy.copy(c1)を呼ぶとc1自身の中身まで書き換わると考えると出てくる誤り。__copy__は新しいオブジェクトを作って返すだけで、元のc1には影響しない。", "__copy__のような特殊メソッドを自作するとcopy.copy()と名前が衝突してエラーになると考えると出てくる誤り。__copy__はcopy.copy()から呼ばれるために用意されているフックであり、衝突ではなく想定された使い方。"], "calc": "copy.copy(c1)の中で何が起きているかを追う。\n\nc1 = Counter(5)\n・c1.nは5\n\nc2 = copy.copy(c1)\n・copy.copy()はまずc1のクラスCounterに__copy__メソッドがあるか確認する\n・あるので、デフォルトの浅いコピー処理はスキップされ、代わりにc1.__copy__()が呼ばれる\n・__copy__の中身はCounter(0)を新しく作って返すだけ\n・つまりc2はc1とは無関係の新しいインスタンスで、nは0\n\nprint(c1.n, c2.n)\n・c1.nは最初のまま5、c2.nは__copy__が作った0"}'),

  ('python-drill-q142', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'a = (1, [2, 3])
b = (1, [2, 3])
print(a == b, a is b)',
   '["True False", "True True", "False False", "False True"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問うている。", "point": "==は中身の値を再帰的に比較する（タプルの中のリストの中身まで見る）が、isは同じオブジェクトかどうかしか見ない。別々に作った2つのタプルは中身が全く同じでも別オブジェクトなのでisはFalse。", "why_asked": "値が等しいかを調べたいのに誤ってisを使うと、別々に生成されたデータが偶然の一致を除いて常にFalse扱いになりバグの温床になる。逆にキャッシュされた小さい整数などでうっかりisがTrueになることを見て『isでも値比較できそうだ』と誤解する人もいるため、==とisの使い分けを正しく理解しておく必要がある。", "kid": "aとbは別々に作られた見た目が同じタプルなので、中身を比べる==はTrue、でも同じ実体かを聞くisはFalse。", "eg": "双子の兄弟がいて、顔や持ち物（中身）が全く同じでも『同一人物ですか』と聞かれたら別人だからNo、『見た目・中身は同じですか』と聞かれたらYes、というようなイメージ。", "terms": [["==", "両辺の値（中身）が等しいかどうかを比較する演算子。リストやタプルなどのコンテナ型では中身を再帰的に比較する"], ["is", "両辺が同じオブジェクト（メモリ上の同じ実体）かどうかを比較する演算子"], ["ネストしたタプル", "タプルの要素としてリストなど別のコンテナが入っている、入れ子構造のタプル"]], "think": "1行目でaが(1, [2, 3])という新しいタプルとして作られる。2行目でbも同じ値の(1, [2, 3])として作られるが、aとは別に新しく作られたものなのでメモリ上は別のオブジェクト。a == bは、まず1番目の要素同士（1と1）を比較し、次に2番目の要素同士（[2, 3]と[2, 3]）をリストの==で比較する。リストの==も中身を再帰的に比較するので、[2, 3]同士も値が同じならTrue。全要素が一致したのでタプル全体としてもTrueになる。一方a is bは、aとbが同じオブジェクトかどうかしか見ないので、別々に作られた以上False。", "vs": "似ているようで見ている観点がまったく違う: ==は『中身が等しいか』というデータの一致を、isは『同じ実体かどうか』というメモリ上の同一性を判定する。リストのようなミュータブルな要素をネストしていても、==はその中まで再帰的に降りて比較するのでこの違いに影響はない。isを値の比較に使ってしまうミスは、小さい整数や一部の文字列がキャッシュされてたまたまTrueになる場合があるため気づきにくい。", "opt": ["正解。==は中身を再帰的に比較するので値が同じ2つのタプルはTrue。isは別々に作られた別オブジェクトかどうかを見るのでFalse。", "==とisを混同し、値が同じなら同じオブジェクトのはずだと考えると出てくる誤り。値が同じでも別々に作られたオブジェクトはisでは別物として扱われる。", "リストを含むタプルは==で正しく比較できないと考えると出てくる誤り。==はネストした要素の中身まで再帰的に比較するので、リストが入っていても問題なくTrueになる。", "==とisの役割を逆に覚えていると出てくる誤り。中身を比較するのは==、同じオブジェクトかを見るのはisであり、逆ではない。"], "calc": "a == b と a is b、それぞれの判定を追う。\n\na = (1, [2, 3])\n・新しいタプルが作られる。中に1という整数と[2, 3]というリストが入っている\n\nb = (1, [2, 3])\n・aとは別に、同じ値を持つ新しいタプルが作られる。aとbはメモリ上の別オブジェクト\n\na == b\n・タプルの==は要素ごとに値を比較する\n・1番目: 1 == 1 → True\n・2番目: [2, 3] == [2, 3] → リストの==も中身を比較するのでTrue\n・全要素が一致したのでタプル全体としてTrue\n\na is b\n・aとbが同じオブジェクトかどうかだけを見る\n・別々に作られたオブジェクトなのでFalse", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"10\" y=\"14\" font-size=\"10\" fill=\"#8892a4\">a と b は別オブジェクト・同じ中身</text><rect x=\"20\" y=\"24\" width=\"110\" height=\"30\" rx=\"4\" fill=\"#2a2f3f\" stroke=\"#60a5fa\"/><text x=\"75\" y=\"44\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\">a: (1, [2, 3])</text><rect x=\"190\" y=\"24\" width=\"110\" height=\"30\" rx=\"4\" fill=\"#2a2f3f\" stroke=\"#60a5fa\"/><text x=\"245\" y=\"44\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\">b: (1, [2, 3])</text><line x1=\"130\" y1=\"39\" x2=\"190\" y2=\"39\" stroke=\"#c9a04a\" stroke-dasharray=\"3,2\"/><text x=\"160\" y=\"34\" font-size=\"9\" fill=\"#c9a04a\" text-anchor=\"middle\">==</text><text x=\"160\" y=\"70\" font-size=\"9\" fill=\"#8892a4\" text-anchor=\"middle\">is は矢印なし(別実体)</text></svg>"}'),

  ('python-drill-q143', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'a = frozenset({1, 2, 3})
b = frozenset({1, 2, 3})
print(a == b, a is b)',
   '["True False", "True True", "False False", "False True"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問うている。", "point": "frozensetは不変（中身を変更できない）だが、不変だからといって同じ内容の別々のfrozensetが自動的に同一オブジェクトになるわけではない。中身が同じなら==はTrueだが、別々に作った以上isはFalse。", "why_asked": "整数の小さい値がキャッシュされてisがTrueになる挙動を見て、『不変な型は同じ内容なら常に同じオブジェクトになる』と一般化してしまう誤解が起きやすい。set/frozensetを比較や重複排除に使う場面で、値の比較には常に==を使うべきという原則を再確認する。", "kid": "中身が同じ集合を持つ2つのfrozensetを別々に作ると、比較（==）は一致するが、実体としては別物（isはFalse）。", "eg": "2つの別々の工場で、同じ材料・同じレシピで作ったおにぎりが2個あるとする。中身（具材）は同じだから『同じ内容だね』とは言えるが、それぞれ別の工場で握られた『別の個体』なので『これは同一のおにぎりですか』と聞かれたら違う、というようなイメージ。", "terms": [["frozenset", "中身を変更できない（不変な）集合型。setと違って要素の追加・削除ができない"], ["集合（set）", "重複のない要素の集まり。順序を持たない"], ["不変（immutable）", "一度作られたら中身を変更できない性質。文字列・タプル・frozensetなどが該当"]], "think": "1行目でaが{1, 2, 3}という中身を持つfrozensetとして新しく作られる。2行目でbも同じ中身の{1, 2, 3}を持つfrozensetとして、aとは別に新しく作られる。frozensetは不変だが、それは中身を変更できないという性質であって、同じ内容なら自動的に同じオブジェクトを使い回すという意味ではない（それは整数の小さい値のキャッシュのような、一部の型に限られた特別な最適化の話）。a == bは中身の要素を集合として比較し、{1, 2, 3}同士は要素が完全に一致するのでTrue。a is bはaとbが同じオブジェクトかどうかを見るが、別々に作られているのでFalse。", "vs": "不変（immutable）であることと、同じ内容なら同じオブジェクトとして再利用される（キャッシュ・インターン）ことは別の話。整数の-5〜256や一部の短い文字列はCPythonが特別にキャッシュしているためisがTrueになることがあるが、それは一部の型に限られた実装上の最適化であり、frozensetには基本的に及ばない。不変な型でも、値の比較をしたいときは常に==を使うのが安全。", "opt": ["正解。frozensetの==は中身の要素を集合として比較するのでTrue。別々に作られたオブジェクトなのでisはFalse。", "frozensetは不変だから同じ内容なら自動的に同じオブジェクトになると考えると出てくる誤り。不変であることと同一オブジェクトとして再利用されることは別で、frozensetにはそのようなキャッシュはない。", "frozenset同士は==で正しく比較できないと考えると出てくる誤り。frozensetの==は中身の要素をきちんと比較でき、同じ要素を持つならTrueになる。", "==とisの役割を逆に覚えていると出てくる誤り。中身を比較するのは==、同じオブジェクトかを見るのはisであり、逆ではない。"], "calc": "a == b と a is b、それぞれの判定を追う。\n\na = frozenset({1, 2, 3})\n・{1, 2, 3}という中身を持つ新しいfrozensetが作られる\n\nb = frozenset({1, 2, 3})\n・aとは別に、同じ中身を持つ新しいfrozensetが作られる。frozensetは不変だが、これは『中身を変更できない』という性質であって『同じ中身なら同じオブジェクトを使い回す』という意味ではない\n\na == b\n・frozensetの==は中身の要素を集合として比較する\n・{1, 2, 3}と{1, 2, 3}は要素が完全に一致するのでTrue\n\na is b\n・aとbが同じオブジェクトかどうかだけを見る\n・別々に作られたオブジェクトなのでFalse"}'),

  ('python-drill-q144', 'オブジェクトの同一性とコピー',
   'このコードを実行すると何が出力される？',
   'def add_item(item, lst=None):
    lst = lst if lst is not None else []
    lst.append(item)
    return lst

print(add_item("x"))
print(add_item("y"))',
   '["1回目の呼び出しは [''x''] に、2回目の呼び出しは [''y''] になる（毎回新しい空リストから始まる）", "1回目の呼び出しは [''x''] に、2回目の呼び出しは [''x'', ''y''] になる（前回の中身が引き継がれる）", "1回目の呼び出しで lst が None のままappendされようとして、その場でエラーになる", "1回目も2回目も [] が出力される（appendの結果が返り値に反映されないと考えると）"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力されるかを問うている。", "point": "デフォルト引数にミュータブルなオブジェクトを直接書かず、Noneをデフォルトにして関数の中でlst is not Noneを判定し、Noneのときだけ新しいリストを作る書き方にすると、呼び出しをまたいでデフォルト値が使い回されることを防げる。", "why_asked": "可変デフォルト引数の罠（def f(x, lst=[])）はよく知られたPythonのハマりどころだが、『知っている』だけでなく実際に安全なコードを書けるかが実務では問われる。lst=Noneパターンは定番の防御策で、このイディオムを覚えておくとレビューでも自信を持って書ける。", "kid": "引数を渡さなかったときはNoneがlstに入るので、関数の中で『Noneならその場で新しい空リストを作る』ようにしてあるため、毎回まっさらなリストからappendされる。", "eg": "旅行のたびに『荷物リストの用紙』を毎回新しく用意して書き込むようにしておけば、前回の旅行の荷物が残ったままになることはない。逆に1枚だけ用意した紙を使い回すと、前回書いた内容が消えずに残ってしまう。", "terms": [["ミュータブルデフォルト引数の罠", "def f(x, lst=[])のようにデフォルト引数に直接可変オブジェクトを書くと、そのオブジェクトが関数定義時に1回だけ作られ、以後の全呼び出しで使い回されてしまう問題"], ["None", "『値が無い』ことを表す特別な値"], ["条件式（三項演算子）", "A if 条件 else B の形で、条件が真ならA、偽ならBを返す式"]], "think": "1回目の呼び出しadd_item(\"x\")では、lstを渡していないのでデフォルトのNoneが使われる。関数の中でlst = lst if lst is not None else []が実行され、lstはNoneなので新しい空リスト[]が作られてlstに代入される。そこにappend(\"x\")されるのでlstは[''x'']になり、それが返される。2回目の呼び出しadd_item(\"y\")でも同様に、lstを渡していないので再びNoneがデフォルトとして使われる（1回目に作った[''x'']とは無関係）。関数の中で同じ判定が行われ、Noneなのでまた新しい空リストが作られる。そこにappend(\"y\")されるので[''y'']になる。1回目のリストの中身が2回目に持ち越されることはない。", "vs": "従来の罠のパターンdef f(x, lst=[])との違いが決め手: lst=[]と書くと、その空リストは関数定義の時点で1回だけ作られ、以後すべての呼び出しで同じオブジェクトが使い回されるため、appendするたびに中身が蓄積されていく。一方lst=Noneにしておけば、デフォルト値そのものはNoneという不変な値なので使い回されても問題なく、関数が呼ばれるたびにlst is not Noneの判定を経て新しいリストを作り直せる。", "opt": ["正解。lstがNone（デフォルトのまま呼ばれた）の場合は、その都度新しい空リストが作られてからappendされるので、呼び出しをまたいで前回の中身が持ち越されることはない。", "従来の可変デフォルト引数の罠（lst=[]と書いてしまうケース）がまだ起きていると考えると出てくる誤り。この書き方はlst=Noneをデフォルトにし、関数の中で毎回新しいリストを作り直しているので罠は起きない。", "lst = lst if lst is not None else [] の一行を素通りしてlstが常にNoneのままだと考えると出てくる誤り。この式はNoneでなければそのまま、Noneなら新しい空リストを使うようlstを更新しており、appendはNoneではなく新しく作られたリストに対して行われる。", "appendの結果が変数に反映されないと考えると出てくる誤り。appendはリストの中身を直接変更する破壊的メソッドであり、返り値を使わなくてもlst自身が更新される。"], "calc": "2回の呼び出しを1行ずつ追う。\n\nadd_item(\"x\") 1回目\n・lstを渡していないのでデフォルトのNoneが使われる\n・lst = lst if lst is not None else [] → lstはNoneなので新しい空リスト[]が作られてlstに入る\n・lst.append(\"x\") → lstは[''x'']になる\n・[''x'']が返る\n\nadd_item(\"y\") 2回目\n・こちらもlstを渡していないので、再びデフォルトのNoneが使われる（1回目の[''x'']とは無関係）\n・lst = lst if lst is not None else [] → lstはNoneなのでまた新しい空リスト[]が作られる\n・lst.append(\"y\") → lstは[''y'']になる\n・[''y'']が返る", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"10\" y=\"14\" font-size=\"10\" fill=\"#8892a4\">呼び出し1: lst=None → 新しい[]</text><rect x=\"10\" y=\"22\" width=\"90\" height=\"28\" rx=\"4\" fill=\"#2a2f3f\" stroke=\"#60a5fa\"/><text x=\"55\" y=\"41\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\">[''x'']</text><text x=\"10\" y=\"70\" font-size=\"10\" fill=\"#8892a4\">呼び出し2: lst=None → 新しい[]</text><rect x=\"10\" y=\"78\" width=\"90\" height=\"28\" rx=\"4\" fill=\"#2a2f3f\" stroke=\"#60a5fa\"/><text x=\"55\" y=\"97\" font-size=\"11\" fill=\"#e8eaf0\" text-anchor=\"middle\">[''y'']</text><text x=\"140\" y=\"14\" font-size=\"9\" fill=\"#8892a4\">箱がそれぞれ別なので中身は混ざらない</text><line x1=\"100\" y1=\"36\" x2=\"140\" y2=\"36\" stroke=\"#c9a04a\" stroke-dasharray=\"2,2\"/><line x1=\"100\" y1=\"92\" x2=\"140\" y2=\"92\" stroke=\"#c9a04a\" stroke-dasharray=\"2,2\"/></svg>"}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'python-drill'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
