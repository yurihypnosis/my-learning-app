BEGIN;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('python-drill-q93', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class PointA:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class PointB:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

a1 = PointA(1, 2)
a2 = PointA(1, 2)
b1 = PointB(1, 2)
b2 = PointB(1, 2)
print(a1 == a2, b1 == b2)',
   '["False True", "True True", "False False", "True False"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（__eq__のオーバーライド）", "point": "__eq__を定義していないクラスの==はidが同じかどうか（同一のオブジェクトか）を比較するが、__eq__を定義すると中身の値が同じかどうかで比較するように変えられる。", "why_asked": "同じ値を持つ別々のオブジェクトを==で比較したときに意図通りTrueになるかどうかは、__eq__を定義しているかどうかで決まる。データを表すクラスを自作するときに必ず関わってくる。", "kid": "PointAは__eq__を定義していないので、a1とa2は値が同じでも別々のオブジェクトだからFalse。PointBは__eq__を定義していて中身のx, yが同じかどうかで判定するので、b1とb2は値が同じだからTrue。", "eg": "双子のきょうだいを「同一人物かどうか」で判定するか、「顔つきが同じかどうか」で判定するかの違いのようなもの。前者だと双子は別人（False）、後者だと双子は同じ判定（True）になる。", "terms": [["__eq__", "==で比較されたときに呼ばれる特殊メソッド。定義すると値による比較に変えられる"], ["同一性", "同じメモリ上の同じオブジェクトかどうか。__eq__を定義しない場合、==はこれを比較する"], ["値による比較", "属性（この例ではx, y）の中身が等しいかどうかで比較すること"]], "think": "1行目でa1とa2はどちらもPointAのインスタンスで、x=1, y=2という同じ値を持つが、PointAは__eq__を定義していないのでa1 == a2はデフォルトの動作（idが同じかどうか）になる。a1とa2は別々に作られた別オブジェクトなのでFalse。2行目でb1とb2はどちらもPointBのインスタンスで、PointBは__eq__を定義しているのでb1 == b2はself.x == other.x and self.y == other.yを実行する。x, yどちらも同じ値なのでTrue。", "vs": "__eq__を定義するとハッシュ値を求める__hash__のデフォルトの挙動が失われ、そのクラスのインスタンスは辞書のキーやセットの要素として使えなくなる（TypeErrorになる）。値による比較と辞書・セットでの利用を両立したい場合は__hash__も合わせて定義する必要がある。", "opt": ["正解。PointAは__eq__を定義していないのでa1 == a2はidの比較になり、別オブジェクトなのでFalse。PointBは__eq__を定義していてx, yの値を比較するので、b1 == b2は値が同じでTrue。", "PointAもPointBも同じx, yの値を持っているから==はTrueになると考えると誤り。__eq__を定義していないPointAは値ではなくidで比較される。", "__eq__を定義してもオブジェクトである以上は必ずidで比較されると考えると誤り。__eq__を定義すればその中身の比較ロジックがそのまま使われる。", "PointAとPointBの判定を逆に覚えると誤り。__eq__が無い方（PointA）がFalse、__eq__がある方（PointB）がTrueになる。"], "calc": "1つずつ確かめる。\n\n【a1 == a2】PointAには__eq__が定義されていない → Pythonのデフォルトの==はid(a1) == id(a2)と同じ意味になる → a1とa2は別々にPointA(1, 2)で作られた別オブジェクトなのでidは異なる → False\n\n【b1 == b2】PointBには__eq__が定義されている → b1 == b2を評価すると、その定義どおりb1.x == b2.x and b1.y == b2.yが実行される → 1 == 1 and 2 == 2 → True\n\nprint(a1 == a2, b1 == b2) → False True"}'),

  ('python-drill-q94', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class Item:
    def __init__(self, name):
        self.name = name

class Product:
    def __init__(self, name):
        self.name = name
    def __repr__(self):
        return f"Product({self.name!r})"

i = Item("apple")
p = Product("banana")
print(i)
print(p)',
   '["<__main__.Item object at 0x...> の後に Product(''banana'')", "<__main__.Item object at 0x...> の後に <__main__.Product object at 0x...>", "Item(''apple'') の後に Product(''banana'')", "エラーになる（__repr__が無いItemはprintできない）"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（__repr__のオーバーライド）", "point": "__repr__を定義していないクラスのインスタンスをprint()すると<クラス名 object at メモリアドレス>という表示になるが、__repr__を定義すると自分で決めた分かりやすい文字列に変えられる。", "why_asked": "デバッグでオブジェクトをprint()やログに出したときに、中身が読めない住所表示のままだと原因調査に時間がかかる。自作クラスに__repr__を用意しておくかどうかで、デバッグのしやすさが大きく変わる。", "kid": "Itemには__repr__が無いので、print(i)は「このオブジェクトはメモリのどこそこにある」という機械向けの住所表示になる。Productには__repr__が定義されているので、print(p)はその定義どおりProduct(''banana'')という読みやすい文字列になる。", "eg": "名札を付けていない人と、名札を付けている人の違いのようなもの。名札が無い人は「◯番受付にいる人」としか呼べないが、名札がある人は名前で呼べる。", "terms": [["__repr__", "オブジェクトを文字列として表現するための特殊メソッド。print()やそのままの変数評価で呼ばれる"], ["object at 0x...", "__repr__が定義されていないときのデフォルト表示。クラス名とメモリ上の住所（実行のたびに変わる）が表示される"], ["f-string", "f\"...\"の中に{}で式を埋め込める文字列の書き方。ここでは{self.name!r}でnameをクォート付きで埋め込んでいる"]], "think": "1行目のprint(i)では、Itemクラスに__repr__が定義されていないので、Pythonが用意するデフォルトの表示（<__main__.Item object at メモリアドレス>という形）になる。2行目のprint(p)では、Productクラスに__repr__が定義されているので、print()はそれを呼び出し、\"Product(''banana'')\"という文字列がそのまま表示される。", "vs": "__str__という似た特殊メソッドもあり、print()はまず__str__を探し、無ければ__repr__を使う。今回はどちらのクラスにも__str__が無いので、Productでは__repr__の定義がそのまま使われている。両方定義する場合、__str__は人間向けの読みやすい表示、__repr__は開発者向けの正確な表示という使い分けが一般的。", "opt": ["正解。Itemには__repr__が無いので<__main__.Item object at 0x...>という住所表示になる。Productは__repr__を定義しているのでその通りProduct(''banana'')と表示される。", "__repr__を定義しても住所表示のままだと考えると誤り。__repr__を定義したクラスのインスタンスをprint()すると、その定義した文字列がそのまま使われる。", "__repr__が無いItemも自動的に分かりやすい表示になると考えると誤り。__repr__を定義していないクラスは、Pythonが用意するデフォルトの住所表示のままになる。", "__repr__を定義していないクラスのインスタンスもprint()自体はできる。表示が読みにくい住所表示になるだけで、エラーにはならない。"], "calc": "1行ずつ確かめる。\n\n【print(i)】Itemクラスには__repr__が定義されていない → print()はPythonが用意するデフォルトの表示を使う → <クラス名 object at メモリアドレス>という形 → <__main__.Item object at 0x...>（アドレスの数字部分は実行のたびに変わる）\n\n【print(p)】Productクラスには__repr__が定義されている → print()はその定義を呼び出す → f\"Product({self.name!r})\"を評価 → self.nameは''banana'' → !rが付いているのでクォート付きで埋め込まれる → \"Product(''banana'')\"\n\n出力は\n<__main__.Item object at 0x...>\nProduct(''banana'')\nの2行。", "viz": "<svg viewBox=\"0 0 340 130\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"20\" y=\"20\" width=\"130\" height=\"50\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"85\" y=\"38\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">Item（__repr__無し）</text><text x=\"85\" y=\"56\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">&lt;...Item object at 0x...&gt;</text><rect x=\"190\" y=\"20\" width=\"130\" height=\"50\" rx=\"4\" fill=\"none\" stroke=\"#60a5fa\"/><text x=\"255\" y=\"38\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">Product（__repr__有り）</text><text x=\"255\" y=\"56\" text-anchor=\"middle\" font-size=\"10\" fill=\"#e8eaf0\">Product(''banana'')</text><text x=\"170\" y=\"100\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">print()したときに何が見えるかが変わる</text></svg>"}'),

  ('python-drill-q95', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class Cart:
    items = []  # クラス変数

    def add(self, item):
        self.items.append(item)

c1 = Cart()
c2 = Cart()
c1.add("apple")
c2.add("banana")
print(c1.items)
print(c2.items)',
   '["[''apple'', ''banana''] の後に [''apple'', ''banana'']", "[''apple''] の後に [''banana'']", "[''apple'', ''banana''] の後に []", "エラーになる（クラス変数itemsはメソッドの外で定義されているため、メソッド内から直接appendすることはできない）"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（クラス変数とインスタンス変数）", "point": "self.items.append(...)のように=を使わず直接変更（append等）した場合、self.itemsは新しいインスタンス変数を作らず、クラス変数のあの1個だけのリストをそのまま書き換える。だから全インスタンスで共有されて見える。", "why_asked": "クラス直下に書いたリストや辞書をうっかりクラス変数として使うと、全インスタンスがデータを共有してしまうバグの定番。add()のような「追加するだけ」のメソッドはself.items = ...という代入をしないので気づきにくい。", "kid": "items = []はCartクラス自身が持つ1個だけのリスト（クラス変数）。c1もc2もself.itemsと書くとまずこの共有リストを見に行き、appendはこの同じリストを書き換えるので、c1.add(\"apple\")もc2.add(\"banana\")も同じリストに追加される。だからc1.itemsもc2.itemsも同じ[''apple'', ''banana'']になる。", "eg": "1つの職場に置いてある共用の伝言板のようなもの。Aさんが書き込んでもBさんが書き込んでも、2人が見ているのは同じ1枚の板。自分専用のメモ帳（インスタンス変数）だと思って書き込むと、実は全員で共有している1枚の板に書いていた、という罠。", "terms": [["クラス変数", "class Cart:の直下（メソッドの外）で定義した変数。全インスタンスで1個だけ共有される"], ["インスタンス変数", "self.属性名 = 値のように代入して作る、そのインスタンス専用の変数"], ["ミュータブル", "リストや辞書のように、作った後で中身を書き換えられるデータの性質。append等で直接変更すると元のオブジェクトそのものが変わる"]], "think": "c1 = Cart()、c2 = Cart()の時点ではどちらも__init__で何もしないので、self.itemsという名前のインスタンス変数はまだ作られていない。c1.add(\"apple\")を実行すると、self.itemsを参照しようとするがc1自身は持っていないので、クラス変数Cart.itemsの[]を見つけてそれにappendする → クラス変数が[''apple'']になる。c2.add(\"banana\")も同様にself.itemsを参照するとやはり同じクラス変数を見つけてappendする → クラス変数が[''apple'', ''banana'']になる。c1もc2も自分専用のitemsを持っていないので、どちらもこの共有された1個のクラス変数を参照し続け、print(c1.items)もprint(c2.items)も同じ[''apple'', ''banana'']になる。", "vs": "もしadd()の中でself.items = self.items + [item]のように=で代入していたら話は変わる。代入は新しいリストを作ってそれをそのインスタンス専用のインスタンス変数として結び付けるので、c1とc2はそれぞれ別のリストを持つようになり、[''apple'']と[''banana'']のように分かれる。appendのような「直接変更」と=のような「代入」の違いが、共有されるかどうかの分かれ目。", "opt": ["正解。self.items.append(...)は=を使わない直接変更なので、Cartクラスが1個だけ持つクラス変数itemsをそのまま書き換える。c1もc2も同じクラス変数を参照しているので、両方とも[''apple'', ''banana'']になる。", "c1とc2はそれぞれ別のインスタンスだから、追加した内容も別々に管理されると考えると誤り。self.items = [...]のように代入していない限り、self.itemsはインスタンス専用ではなくクラス変数を指したままになる。", "後から追加したc2の変更だけがc2.itemsに反映され、c1.itemsは最初のままだと考えると誤り。c1とc2は同じ1個のリストを参照しているので、どちらの追加もその1個のリストに反映され両方から見える。", "クラス変数はメソッド内からappendのような直接変更ができないと考えると誤り。クラス変数もインスタンス変数と同じくオブジェクトなので、参照さえできればappend等のメソッドは普通に呼び出せる。"], "calc": "1つずつ確かめる。\n\n【クラス定義の瞬間】items = []というクラス変数（Cart自身が持つ1個だけの空リスト）が作られる。以後、代入で上書きされない限りずっとこの同じリストが使われる。\n\n【c1.add(\"apple\")】self.itemsを参照 → c1自身はitemsを持っていないのでクラス変数Cart.itemsの[]が見つかる → .append(\"apple\") → このクラス変数が[''apple'']になる\n\n【c2.add(\"banana\")】self.itemsを参照 → c2自身もitemsを持っていないので同じクラス変数Cart.items（すでに[''apple'']になっている）が見つかる → .append(\"banana\") → このクラス変数が[''apple'', ''banana'']になる\n\n【print(c1.items)】c1も同じクラス変数を参照 → [''apple'', ''banana'']\n【print(c2.items)】c2も同じクラス変数を参照 → [''apple'', ''banana'']", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"110\" y=\"14\" width=\"150\" height=\"42\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"185\" y=\"30\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">Cart（クラス変数）</text><text x=\"185\" y=\"46\" text-anchor=\"middle\" font-size=\"11\" fill=\"#e8eaf0\">items = [''apple'', ''banana'']</text><rect x=\"15\" y=\"96\" width=\"90\" height=\"34\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"60\" y=\"117\" text-anchor=\"middle\" font-size=\"11\" fill=\"#e8eaf0\">c1</text><rect x=\"235\" y=\"96\" width=\"90\" height=\"34\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"280\" y=\"117\" text-anchor=\"middle\" font-size=\"11\" fill=\"#e8eaf0\">c2</text><line x1=\"60\" y1=\"96\" x2=\"150\" y2=\"56\" stroke=\"#60a5fa\" stroke-width=\"1.5\" marker-end=\"url(#arrow95)\"/><line x1=\"280\" y1=\"96\" x2=\"220\" y2=\"56\" stroke=\"#60a5fa\" stroke-width=\"1.5\" marker-end=\"url(#arrow95)\"/><text x=\"185\" y=\"80\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">c1.items と c2.items は同じ1個のリストを指す</text><defs><marker id=\"arrow95\" markerWidth=\"6\" markerHeight=\"6\" refX=\"5\" refY=\"3\" orient=\"auto\"><path d=\"M0,0 L6,3 L0,6 z\" fill=\"#60a5fa\"/></marker></defs></svg>"}'),

  ('python-drill-q96', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class Animal:
    def __init__(self, name):
        self.name = name

    @classmethod
    def create_default(cls):
        return cls("no name")

    @staticmethod
    def make_default_static():
        return Animal("no name")

class Dog(Animal):
    pass

a = Dog.create_default()
b = Dog.make_default_static()
print(type(a).__name__, type(b).__name__)',
   '["Dog Animal", "Dog Dog", "Animal Animal", "エラーになる（Dogにcreate_defaultは定義されていない）"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（@staticmethodと@classmethodの違い）", "point": "@classmethodの中のclsは「実際に呼び出したクラス」に自動で置き換わるが、@staticmethodは普通の関数と同じでコードに書いたクラス名の通りにしか動かない。だから継承先から呼んだときの結果が変わる。", "why_asked": "別コンストラクタ（作成用の入口メソッド）を用意するときに@classmethodを使うか@staticmethodを使うかで、サブクラスから呼び出したときの挙動が変わってしまう。ライブラリ設計で意図せず親クラスのインスタンスしか作れないコードになってしまう典型的な落とし穴。", "kid": "Dog.create_default()を呼ぶと、@classmethodのclsには呼び出し元のDogがそのまま入るので、cls(\"no name\")はDog(\"no name\")と同じ意味になり、できるのはDogのインスタンス。Dog.make_default_static()を呼んでも、@staticmethodの中身はAnimal(\"no name\")と固定で書かれているので、できるのは常にAnimalのインスタンス。", "eg": "「今日の当番が作る」というルールと、「いつも決まった人（Animalさん）が作る」というルールの違いのようなもの。Dogチームが当番制（classmethod）で作れば当番であるDogが作ったものになるが、いつも決まった人が作る（staticmethod）ルールだと、誰が頼んでも作るのは常にその決まった人（Animal）のまま。", "terms": [["@classmethod", "第一引数に呼び出し元のクラス自身(cls)を自動で受け取るメソッド。サブクラスから呼ぶとclsにはサブクラスが入る"], ["@staticmethod", "selfもclsも受け取らない、クラスの名前空間に置かれただけの普通の関数"], ["cls(...)", "clsに入っているクラスのコンストラクタを呼び出すこと。呼び出し元のクラスに応じて作られるインスタンスの型が変わる"]], "think": "1行目でDog.create_default()を呼ぶと、@classmethodなのでclsには呼び出し元であるDogクラス自身が渡される。cls(\"no name\")はDog(\"no name\")と同じ意味になり、Dogのインスタンスaが作られる。2行目でDog.make_default_static()を呼んでも、@staticmethodの中には呼び出し元の情報が渡ってこないので、コード中に書かれた通りAnimal(\"no name\")が実行され、Animalのインスタンスbが作られる。print(type(a).__name__, type(b).__name__)は、それぞれのクラス名を表示するのでDog Animalになる。", "vs": "継承しない単純な例だと@classmethodと@staticmethodの見た目上の違いは「clsを受け取るかどうか」だけに見えるが、この問題のように継承したクラスから呼び出すと差がはっきり出る。@classmethodは呼び出し元に応じて作るインスタンスの型を変えられるので、別コンストラクタ（create_defaultのような入口）を作るときは@staticmethodより@classmethodの方が安全。", "opt": ["正解。@classmethodのclsには呼び出し元のDogがそのまま入るのでcls(\"no name\")はDogのインスタンスになる。@staticmethodの中身はAnimal(\"no name\")と固定で書かれているので、常にAnimalのインスタンスになる。", "@staticmethodも呼び出し元のクラスを自動で認識すると考えると誤り。@staticmethodはselfもclsも受け取らない普通の関数なので、コード中に書いた通りAnimalのインスタンスしか作れない。", "@classmethodのclsも継承前のAnimalに固定されると考えると誤り。@classmethodのclsは呼び出し元に応じて変わるので、Dog.create_default()から呼べばclsにはDogが入る。", "create_default()はAnimalクラスに定義されているが、DogはAnimalを継承しているのでDog.create_default()のように親クラスのメソッドをそのまま呼び出せる。"], "calc": "呼び出しを1つずつ追う。\n\n【a = Dog.create_default()】create_default()は@classmethod → 呼び出し元のDogがclsに自動で渡される → 中身はreturn cls(\"no name\") → clsはDogなのでDog(\"no name\")と同じ → aはDogのインスタンス\n\n【b = Dog.make_default_static()】make_default_static()は@staticmethod → clsもselfも渡されない、ただの関数として実行される → 中身はreturn Animal(\"no name\")とコードに固定で書かれている → bはAnimalのインスタンス\n\n【print(type(a).__name__, type(b).__name__)】aの型名は\"Dog\"、bの型名は\"Animal\" → 出力は「Dog Animal」"}'),

  ('python-drill-q97', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class Vehicle:
    def __init__(self, brand):
        self.brand = brand
        self.wheels = 4

class Car(Vehicle):
    def __init__(self, brand, model):
        super().__init__(brand)
        self.model = model

class Bike(Vehicle):
    def __init__(self, brand, model):
        self.model = model

car = Car("Toyota", "Corolla")
bike = Bike("Trek", "FX")
print(car.brand, car.wheels)
print(bike.model, bike.wheels)',
   '["Toyota 4 の後にAttributeError", "Toyota 4 の後に FX 4", "Toyota 4 の後に FX None", "エラーになる（Carをインスタンス化した時点でエラーになる）"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（super().__init__()を使った継承）", "point": "子クラスの__init__でsuper().__init__()を呼ばないと、親クラスの__init__は実行されず、親クラス側で設定されるはずの属性はそのインスタンスに一切作られない。", "why_asked": "継承したクラスに独自の__init__を書くとき、super().__init__()を呼び忘れると親クラスの初期化処理がまるごとスキップされる。書き忘れてもその場ではエラーにならず、後でその属性に触れたときに初めてAttributeErrorとして表面化するので原因調査がしにくい。", "kid": "Carはsuper().__init__(brand)を呼んでいるので、Vehicleの__init__が実行されbrandとwheelsが両方セットされる。Bikeはsuper().__init__を呼んでいないので、Vehicleの__init__は一切実行されず、self.brandもself.wheelsも作られない。だからbike.wheelsにアクセスした瞬間にAttributeErrorになる。", "eg": "先輩から仕事を引き継ぐときに、引き継ぎ資料（親クラスの初期化処理）を読むかどうかの違いのようなもの。資料を読んで引き継いだ人（Car）は必要な情報（wheels）を最初から持っているが、資料を読まずに自己流で始めた人（Bike）は、その情報をそもそも持っていないので後で聞かれても答えられない。", "terms": [["super()", "親クラス（継承元のクラス）を指す。super().__init__(...)で親クラスの初期化処理を呼び出せる"], ["継承", "class Car(Vehicle):のように書いて、Vehicleが持つ属性やメソッドをCarでも使えるようにする仕組み"], ["AttributeError", "存在しない属性にアクセスしようとしたときに発生する例外"]], "think": "1行目、Car(\"Toyota\", \"Corolla\")では__init__の中でsuper().__init__(brand)を呼んでいるので、Vehicleの__init__が実行されself.brand=\"Toyota\"とself.wheels=4が設定される。続けてself.model=\"Corolla\"も設定される。print(car.brand, car.wheels)はどちらも問題なくアクセスできるので\"Toyota 4\"になる。2行目、Bike(\"Trek\", \"FX\")では__init__の中でsuper().__init__(brand)を呼んでいないので、Vehicleの__init__は実行されず、self.brandもself.wheelsも一切作られない。self.model=\"FX\"だけが設定される。print(bike.model, bike.wheels)を実行しようとすると、bike.modelは\"FX\"が返るが、続くbike.wheelsでは存在しない属性にアクセスしようとしてAttributeErrorが発生し、そこでプログラムが止まる。", "vs": "super().__init__()を呼ばなくても、Carのインスタンス化やBikeのインスタンス化そのものはエラーにならずに成功する点に注意。エラーになるのは、実際に無い属性（bike.wheels）に後からアクセスしたタイミング。呼び忘れに気づくのが実行時のかなり後になりやすい理由はここにある。", "opt": ["正解。Carはsuper().__init__(brand)を呼んでいるのでbrandとwheelsが両方設定され\"Toyota 4\"になる。Bikeはsuper().__init__を呼んでいないのでself.wheelsが一切作られず、bike.wheelsにアクセスした時点でAttributeErrorになる。", "BikeもVehicleを継承しているのだから、wheelsは自動で4が設定されると考えると誤り。継承しているだけでは親クラスの__init__は実行されない。子クラスの__init__の中でsuper().__init__()を明示的に呼ばない限り、親クラスの初期化処理はスキップされる。", "属性が設定されていない場合はエラーではなくNoneになると考えると誤り。self.wheelsという代入自体が一度も実行されていないので、その属性はインスタンスに存在せず、アクセスしようとするとAttributeErrorになる。", "Carのインスタンス化時点でエラーになると考えると誤り。Carはsuper().__init__(brand)を正しく呼んでいるのでインスタンス化は問題なく成功する。もしエラーになるとしたら呼び忘れているBikeの方で、しかもインスタンス化のタイミングではなく、後からbike.wheelsにアクセスした瞬間。"], "calc": "1行ずつ追う。\n\n【car = Car(\"Toyota\", \"Corolla\")】Carの__init__の中でsuper().__init__(brand)を実行 → Vehicleの__init__が動く → self.brand=\"Toyota\"、self.wheels=4がセットされる → 続けてself.model=\"Corolla\"がセットされる\n\n【print(car.brand, car.wheels)】どちらも存在する属性 → \"Toyota\" 4 → 1行目の出力は「Toyota 4」\n\n【bike = Bike(\"Trek\", \"FX\")】Bikeの__init__はsuper().__init__を呼んでいない → Vehicleの__init__は一切実行されない → self.brandもself.wheelsも作られない → self.model=\"FX\"だけがセットされる\n\n【print(bike.model, bike.wheels)】bike.modelは\"FX\"で問題なく取得できるが、続くbike.wheelsは存在しない属性 → AttributeErrorが発生しそこで停止\n\nつまり出力は「Toyota 4」の後にAttributeError。", "viz": "<svg viewBox=\"0 0 340 150\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"110\" y=\"10\" width=\"150\" height=\"40\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"185\" y=\"26\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">Vehicle.__init__</text><text x=\"185\" y=\"42\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">brand, wheels=4 を設定</text><rect x=\"10\" y=\"90\" width=\"140\" height=\"50\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"80\" y=\"106\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">Car.__init__</text><text x=\"80\" y=\"120\" text-anchor=\"middle\" font-size=\"9\" fill=\"#60a5fa\">super().__init__(brand) 呼ぶ</text><text x=\"80\" y=\"134\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">brand, wheels, model 揃う</text><rect x=\"190\" y=\"90\" width=\"140\" height=\"50\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"260\" y=\"106\" text-anchor=\"middle\" font-size=\"9\" fill=\"#8892a4\">Bike.__init__</text><text x=\"260\" y=\"120\" text-anchor=\"middle\" font-size=\"9\" fill=\"#c9a04a\">super().__init__ 呼ばない</text><text x=\"260\" y=\"134\" text-anchor=\"middle\" font-size=\"9\" fill=\"#e8eaf0\">model のみ（wheels 無し）</text><line x1=\"150\" y1=\"50\" x2=\"80\" y2=\"90\" stroke=\"#60a5fa\" stroke-width=\"1.5\" marker-end=\"url(#arrow97)\"/><line x1=\"220\" y1=\"50\" x2=\"260\" y2=\"90\" stroke=\"#2a2f3f\" stroke-width=\"1.5\" stroke-dasharray=\"3,3\"/><defs><marker id=\"arrow97\" markerWidth=\"6\" markerHeight=\"6\" refX=\"5\" refY=\"3\" orient=\"auto\"><path d=\"M0,0 L6,3 L0,6 z\" fill=\"#60a5fa\"/></marker></defs></svg>"}'),

  ('python-drill-q98', 'クラスとオブジェクト指向',
   '出力される内容は？',
   'class Circle:
    def __init__(self, radius):
        self.radius = radius

    @property
    def area(self):
        return 3.14 * self.radius ** 2

c = Circle(2)
print(c.area)
print(c.area())',
   '["12.56 の後にTypeError", "12.56 の後に12.56", "エラーになる（1行目のc.areaに()が無いためそこでエラーになる）", "エラーになる（@propertyを付けたメソッドはprintできない）"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（@propertyによるgetter）", "point": "@propertyを付けたメソッドは、呼び出し側では()を付けずに属性のようにアクセスする。()を付けて呼ぶと、そのメソッドの戻り値（この場合は数値）に対して()で呼び出そうとすることになり、数値は呼び出せないのでエラーになる。", "why_asked": "@propertyを付けたメソッドをただのメソッドだと思って()を付けて呼んでしまうミスは、既存のクラスにgetterとして後から@propertyを追加したときなどによく起きる。属性アクセスの書き方が変わることを知らないとハマる。", "kid": "areaメソッドに@propertyが付いているので、c.areaと書くだけでそのメソッドが実行されて戻り値（3.14 * 2 ** 2 = 12.56）が返ってくる。c.area()と()を付けると、areaはすでに12.56という数値に置き換わっているので、12.56()を呼び出そうとすることになりTypeErrorになる。", "eg": "自動ドアと手動ドアの違いのようなもの。@propertyが付いたドア（自動ドア）は近づくだけ（c.area）で開くが、開けるボタン（()）を押そうとしても、そこにはもうボタンが無いのでエラーになる。", "terms": [["@property", "メソッドを、呼び出し側からは()を付けない属性のように見せかけるデコレータ"], ["getter", "属性の値を取得するための処理。@propertyを付けたメソッドはgetterとしてよく使われる"], ["TypeError", "本来呼び出せない（callableでない）ものを()で呼び出そうとしたときなどに発生する例外"]], "think": "1行目のprint(c.area)では、areaは@propertyが付いているので、c.areaと書いた時点で自動的にareaメソッドが実行される。中身は3.14 * self.radius ** 2で、self.radiusは2なので3.14 * 4 = 12.56が返る。print()はこの12.56を表示する。2行目のprint(c.area())では、まずc.areaが評価され、これも同じく12.56という数値になる。続けてその12.56に対して()を付けて呼び出そうとするが、数値は呼び出し可能なオブジェクトではないので、\"''float'' object is not callable\"というTypeErrorが発生する。", "vs": "@propertyを付けていない普通のメソッド（decoratorが無いdef area(self):）は逆に、c.areaと書いても実行されずメソッドオブジェクトが返るだけで、実行するにはc.area()と()を付ける必要がある。@propertyがあるかないかで、()を付けるべきかどうかが逆転する点が紛らわしい。", "opt": ["正解。c.areaは@propertyのおかげで()無しで実行され12.56を返す。c.area()は12.56という数値にさらに()を付けて呼び出そうとする形になり、数値は呼び出せないのでTypeErrorになる。", "()を付けても付けなくても同じ結果が返ると考えると誤り。@propertyが付いたareaは()無しで初めて実行される値であり、その値（数値）にさらに()を付けると呼び出しエラーになる。", "@propertyを付けたメソッドは()を付けないと実行されないと考えると誤り。@propertyの目的はまさにその逆で、()を付けずに属性のようにアクセスできるようにすること。1行目のc.areaは()無しで正しく実行される。", "@propertyを付けたメソッドの戻り値も普通の値なのでprintできないという制限は無いと考えると誤り。print(c.area)は問題なく12.56を表示できる。エラーになるのは2行目でその値にさらに()を付けて呼び出そうとした場合。"], "calc": "1行ずつ確かめる。\n\n【print(c.area)】areaには@propertyが付いている → c.areaと書いた時点で()無しでもareaメソッドが自動実行される → 3.14 * self.radius ** 2 → self.radiusは2 → 3.14 * (2 ** 2) = 3.14 * 4 = 12.56 → 1行目の出力は「12.56」\n\n【print(c.area())】まずc.areaが評価される → 同じく12.56という数値になる → その12.56に対して()を付けて呼び出そうとする → 数値(float)はcallableではない → TypeError: ''float'' object is not callable が発生しそこで停止\n\nつまり出力は「12.56」の後にTypeError。"}'),

  ('python-drill-q99', '制御構文と真偽値',
   '出力される内容は？',
   'values = {"a": 0, "b": "", "c": {}, "d": "0", "e": [0]}
for key, val in values.items():
    if val:
        print(key, end="")',
   '["de", "e", "d", "cde"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（truthy/falsyの判定）", "point": "if文でチェックされるのは中身の有無。文字列\"0\"は文字が1つ入っているのでtruthy、リスト[0]は要素が1つ入っているのでtruthy——中の値がFalse相当でも入れ物自体が空でなければTrueになる。", "why_asked": "「0っぽいものは全部False」という思い込みで実務のif文にバグを仕込みやすい。文字列\"0\"やリスト[0]をfalsy扱いしてしまうミスは典型的。", "kid": "0、空文字\"\"、空辞書{}の3つはfalsyでif文をスルーする。文字列\"0\"は中身のある文字列なのでtruthy、リスト[0]も要素が1つあるのでtruthyとして表示される。", "eg": "空っぽの財布かどうかを見るとき、財布の中に「0円と書かれたメモ」が1枚入っていれば、それは空っぽの財布ではなく「メモが1枚入っている財布」として扱われる、というようなもの。", "terms": [["truthy/falsy", "if文でTrue/False相当として扱われる値の性質。0・空文字・空リスト・空辞書・Noneはfalsy"], ["dict.items()", "辞書のキーと値のペアを順に取り出すメソッド"], ["end=\"\"", "print()の改行を空文字に変えて、続けて出力するオプション"]], "think": "1行目で辞書valuesを作る: a=0, b=\"\"(空文字), c={}(空辞書), d=\"0\"(文字の0という文字列), e=[0](要素が1個のリスト)。\nfor文でキーと値を順番に取り出し、if val: で「valがtruthyかどうか」だけを見る。\naの0はfalsyなのでスキップ。bの\"\"もfalsyなのでスキップ。cの{}も空辞書なのでfalsyでスキップ。\ndの\"0\"は文字列として中身が1文字入っているのでtruthy → \"d\"が出力される。\neの[0]はリストの中に要素が1個（中身は0だが、リスト自体は空じゃない）なのでtruthy → \"e\"が出力される。\nend=\"\"で改行せず続けて出すので、最終的に\"de\"とつながって表示される。", "vs": "「値そのものがFalse相当かどうか」と「入れ物（コンテナ）が空かどうか」は別の話。\"0\"や[0]は中身の値としてはFalse寄りに見えても、コンテナとしては空でないのでtruthy。空にしたいなら\"\"や[]のようにする必要がある。", "opt": ["正解。0・\"\"（空文字）・{}（空辞書）の3つだけfalsyでスキップされ、\"0\"（文字列）と[0]（要素1個のリスト）はどちらもtruthyなので\"d\"と\"e\"が出力される。", "\"d\"が出力されないのはおかしい。文字列\"0\"は数値の0とは別物で、中身のある文字列なのでtruthy。", "\"e\"が出力されないのはおかしい。[0]は要素の中身が0でも、リスト自体は空ではなく要素数1なのでtruthy。", "\"c\"が出力されるのはおかしい。{}は要素が1つも無い空辞書なのでfalsy。"], "calc": "辞書の各要素をif valで順番に判定する:\n①key=\"a\", val=0 → bool(0)はFalse → if文の中に入らずスキップ。\n②key=\"b\", val=\"\" → bool(\"\")はFalse（空文字）→ スキップ。\n③key=\"c\", val={} → bool({})はFalse（空辞書）→ スキップ。\n④key=\"d\", val=\"0\" → bool(\"0\")はTrue（1文字でも入っている文字列はtruthy）→ print(\"d\", end=\"\")で\"d\"を出力。\n⑤key=\"e\", val=[0] → bool([0])はTrue（要素が1個あるリストはtruthy、中身の0は関係ない）→ print(\"e\", end=\"\")で\"e\"を出力。\n改行せず続けて出すので最終出力は\"de\"。"}'),

  ('python-drill-q100', '制御構文と真偽値',
   '出力される内容は？',
   'def has_negative(nums):
    for n in nums:
        if n < 0:
            print("found negative")
            break
    else:
        print("all non-negative")

has_negative([3, 5, -2, 8])
has_negative([3, 5, 2, 8])',
   '["found negative\nall non-negative", "found negative\nall non-negative\nall non-negative", "found negative", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（for-else構文）", "point": "for文のelseは「breakされずに最後まで回りきったときだけ」実行される。breakで抜けるとelseはスキップされる。", "why_asked": "「探して見つかったらこう、最後まで見つからなかったらこう」という処理を書くとき、フラグ変数を用意しなくてもfor-elseで簡潔に書ける。知らないとelseの意味を誤読してバグを埋め込む。", "kid": "1回目の呼び出しは-2が見つかった時点でbreakするのでelseは実行されず「found negative」だけ。2回目は最後まで回ってもbreakしないのでelseが実行され「all non-negative」が出る。", "eg": "探し物ゲームで「見つかったらそこで終わり（ベルを鳴らさない）」「探しても見つからなかったら最後にベルを鳴らす」というルールのようなもの。ベルはbreakされなかったときだけ鳴る。", "terms": [["for-else", "forループにelse節を付けると、breakされずにループが最後まで回りきったときだけelse節が実行される"], ["break", "ループを途中で強制的に抜ける文。breakで抜けるとelseはスキップされる"]], "think": "1回目の呼び出しhas_negative([3, 5, -2, 8]):\nn=3→負でない、n=5→負でない、n=-2→負なのでprint(\"found negative\")してbreak。breakしたのでelse節はスキップ。\n2回目の呼び出しhas_negative([3, 5, 2, 8]):\nすべて負でないのでbreakは一度も起きずループが最後まで回りきる。ループが正常終了したのでelse節が実行されprint(\"all non-negative\")。", "vs": "普通のif/elseと違い、for-elseのelseは「ifが偽だったとき」ではなく「ループがbreakされなかったとき」に実行される。while文にも同じelseが使え、意味は同じ。", "opt": ["正解。1回目はbreakしたのでelseはスキップされ「found negative」のみ。2回目はbreakせず最後まで回ったのでelseが実行され「all non-negative」が出力される。", "elseは「forループの後に必ず実行される」わけではない。breakで抜けたときはelse節はスキップされるので、1回目の呼び出しで「all non-negative」は出力されない。", "2回目の呼び出しでelseが実行されないのはおかしい。breakが一度も起きずループが最後まで回りきっているので、else節の「all non-negative」がちゃんと出力される。", "for文のelse節はPythonの正式な構文でエラーにはならない。breakされなかったときの後処理を書くための機能。"], "calc": "has_negative([3, 5, -2, 8])を呼んだとき:\n①n=3 → 3<0はFalse → 何もしない。\n②n=5 → 5<0はFalse → 何もしない。\n③n=-2 → -2<0はTrue → print(\"found negative\")してbreak。ループはここで強制終了。\n④breakで抜けたのでelse節は実行されない。\n\nhas_negative([3, 5, 2, 8])を呼んだとき:\n⑤n=3, 5, 2, 8のすべてが0以上なのでif文の中に入らず、breakも一度も起きない。\n⑥ループが正常に最後まで回りきったので、else節が実行されprint(\"all non-negative\")。"}'),

  ('python-drill-q101', '制御構文と真偽値',
   '出力される内容は？',
   'x = 15
print(1 < x < 10)
print((1 < x) < 10)',
   '["False\nTrue", "True\nTrue", "True\nFalse", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（連鎖比較）", "point": "1 < x < 10はandで2つの比較をつないだのと同じ意味（1<x かつ x<10）。丸カッコを付けた(1 < x) < 10は先に1<xだけを計算してTrue/Falseにしてから、そのTrue/Falseを10と比較する別物の式になる。", "why_asked": "連鎖比較はPythonらしい書き方でよく使われるが、丸カッコを付けた式と結果が変わることを知らないと「範囲チェックのつもりが実は違う計算をしていた」というバグに気づけない。", "kid": "1 < x < 10は「1より大きく、かつ10より小さい」をまとめて聞いている。x=15はこの範囲に入らないのでFalse。(1 < x) < 10はまず1<15を計算してTrueにし、そのTrue（数値の1として扱われる）が10より小さいかを聞いているので別の答えTrueになる。", "eg": "「1万円より高くて、かつ10万円より安い」という2つの条件を一気に聞くのが連鎖比較。カッコを付けた式は「まず『1万円より高い？』にYes/Noで答えさせてから、そのYes/Noそのものを10万円と比べる」という、意味が変わった質問になっている。", "terms": [["連鎖比較（chained comparison）", "1 < x < 10のように比較演算子を連続で書くと、1<x and x<10と同じ意味になるPython特有の書き方"], ["bool値の数値扱い", "TrueやFalseは比較や演算の中では1や0として扱われる"]], "think": "1行目: x=15。\n2行目: 1 < x < 10 は 1<15 かつ 15<10 のand結合として評価される。1<15はTrue、15<10はFalseなので全体はFalse。\n3行目: (1 < x) < 10 はまずカッコの中の1<15を先に計算してTrueを得る。次にTrue < 10を計算する。TrueはPythonでは1として扱われるので1<10でTrue。", "vs": "見た目は似ているが、1 < x < 10は「2つの条件を両方満たすか」を聞く連鎖比較、(1 < x) < 10は「1<xの結果（True/False）を10と数値比較する」という別の計算。丸カッコを付けると連鎖比較の意味は失われる。", "opt": ["正解。1 < 15 < 10 は1<15(True)かつ15<10(False)なのでFalse。(1 < 15) < 10 は先にTrueを求めてから1<10を計算するのでTrue。", "1 < x < 10 は1<x かつ x<10 の両方を満たすかを聞いている。x=15は10より小さくないので、この行はFalseになりTrueにはならない。", "2行が逆。1 < x < 10 はxが1〜10の範囲に入っているかを聞く式なのでx=15ではFalse、(1 < x) < 10 は1<15の結果Trueを10と比較するのでTrueになる。", "連鎖比較も丸カッコを付けた比較も、どちらもPythonとして正しい構文でエラーにはならない。"], "calc": "1行目 print(1 < x < 10):\n①x=15なので、1 < x < 10 は 1 < 15 and 15 < 10 と同じ意味で評価される。\n②1 < 15 → True。\n③15 < 10 → False。\n④TrueとFalseをandで結んだ結果はFalse。よって出力はFalse。\n\n2行目 print((1 < x) < 10):\n⑤まずカッコの中の1 < 15 を計算する → True。\n⑥次にTrue < 10を計算する。PythonではTrueは1として扱われるので、1 < 10 を計算しているのと同じ。\n⑦1 < 10 → True。よって出力はTrue。"}'),

  ('python-drill-q102', '制御構文と真偽値',
   '出力される内容は？',
   'scores = []
default = [0, 0, 0]
print(scores or default)
print(scores and default)',
   '["[0, 0, 0]\n[]", "True\nFalse", "[]\n[0, 0, 0]", "[]\n[]"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（and/orが返す値）", "point": "Pythonのor/andは最後に評価した「値そのもの」を返す。orは最初にtruthyな値が出た時点でそれを返し、andは最初にfalsyな値が出た時点でそれを返す（どちらもTrue/Falseに変換しない）。", "why_asked": "「デフォルト値があればそれを使う」というa or bの書き方は実務でよく使われるが、返ってくるのがbool値ではなく実際のオブジェクトそのものだと知らないと、後続の処理で型を誤解してバグになる。", "kid": "scoresは空リストでfalsy。orは左がfalsyなので右のdefaultをそのまま返す。andは左がfalsyな時点でそこで確定するので、左のscoresをそのまま返す（右のdefaultは評価すらされない）。", "eg": "「手持ちの傘がなければ（or）、代わりの傘を貸す」という約束事のようなもの。手持ちの傘があるかどうかを聞くだけでなく、実際に貸す傘そのものが返ってくる。andは逆に「両方揃っているか」を聞きつつ、最初に「足りない」と分かった時点でその「足りない方」自体を返してくる。", "terms": [["or演算子", "左がtruthyならその値を、falsyなら右の値を返す（True/Falseへの変換はしない）"], ["and演算子", "左がfalsyならその値を、truthyなら右の値を返す"], ["短絡評価（ショートサーキット）", "結果が確定した時点で残りの式を評価せずに打ち切る仕組み"]], "think": "1行目: scores=[]（空リスト、falsy）、default=[0, 0, 0]（要素ありのリスト、truthy）。\n2行目: scores or default は、左のscoresがfalsyなので右のdefaultを返す。よって[0, 0, 0]が出力される。\n3行目: scores and default は、左のscoresがfalsyな時点で結果が確定するので、右のdefaultは見にいかず左のscoresをそのまま返す。よって[]が出力される。", "vs": "if文の中で「if a or b:」のように使うとTrue/Falseの真偽だけが問題になるので気づきにくいが、「x = a or b」のように値を受け取る書き方をすると、返ってくるのがbool値ではなく実際のa自身かb自身であることが表に出る。", "opt": ["正解。orは左のscoresがfalsyなので右のdefaultをそのまま返し、andは左のscoresがfalsyな時点で確定するので左のscoresをそのまま返す。", "or/andはTrue/Falseに変換した真偽値を返すわけではない。評価した値そのもの（この場合はリスト）をそのまま返す。", "orとandの結果が逆。orは左がfalsyなら右を返すのでdefaultが先、andは左がfalsyならそこで確定して左を返すのでscoresが後。", "andの結果は合っているが、orの結果がscoresの[]のままになるのはおかしい。orは左がfalsyなときは右のdefaultを返す。"], "calc": "2行目 print(scores or default):\n①左のscoresを評価する → []はfalsy。\n②orは左がfalsyなので、右のdefaultを評価してそのまま返す。\n③defaultは[0, 0, 0]なので、これがそのまま出力される。\n\n3行目 print(scores and default):\n④左のscoresを評価する → []はfalsy。\n⑤andは左がfalsyな時点で結果が確定するので、右のdefaultは評価せず、左のscores自身を返す（短絡評価）。\n⑥scoresは[]なので、これがそのまま出力される。"}'),

  ('python-drill-q103', '制御構文と真偽値',
   '出力される内容は？',
   'def classify(n):
    match n:
        case 0:
            return "zero"
        case 1 | 2 | 3:
            return "small"
        case _ if n < 0:
            return "negative"
        case _:
            return "large"

for x in [0, 2, -5, 100]:
    print(classify(x))',
   '["zero\nsmall\nnegative\nlarge", "zero\nsmall\nlarge\nlarge", "large\nlarge\nlarge\nlarge", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（match-case構文）", "point": "matchは上から順にcaseを照合し、最初にマッチしたcaseだけが実行される。case _:はどんな値にもマッチする「それ以外全部」の受け皿で、必ず最後に置く。", "why_asked": "Python 3.10以降で使えるmatch-caseはif/elifの連続より読みやすい反面、case _ if ...のガード条件やcaseの順序を誤解すると、意図しない分岐に落ちてしまう。", "kid": "0はcase 0にそのままマッチして\"zero\"。2はcase 1 | 2 | 3のどれかに一致するので\"small\"。-5はcase 0にもcase 1|2|3にも一致せず、case _ if n < 0の条件（n<0）を満たすので\"negative\"。100はどのcaseにも当てはまらず最後のcase _:に落ちて\"large\"。", "eg": "受付窓口で「0番の人はこちら」「1〜3番の人はこちら」「マイナスの整理券の人はこちら」「それ以外の人は総合案内へ」と、上から順に案内板を確認していくようなもの。最初に自分の条件に当てはまった案内板の指示に従う。", "terms": [["match-case", "値を複数のパターンと上から順に照合し、最初に一致したcaseを実行するPython 3.10以降の構文"], ["case _:", "どんな値にもマッチするワイルドカード。他のどのcaseにも一致しなかった場合の受け皿として使う"], ["case _ if 条件", "ワイルドカードに条件（ガード）を付け、その条件を満たすときだけマッチさせる書き方"]], "think": "x=0のとき: case 0 に直接一致するので\"zero\"を返す。\nx=2のとき: case 0には一致しないが、case 1 | 2 | 3 の中に2が含まれるので\"small\"を返す。\nx=-5のとき: case 0にもcase 1|2|3にも一致しない。次のcase _ if n < 0を見ると、n=-5は0より小さいので条件を満たし\"negative\"を返す。\nx=100のとき: これまでのどのcaseにも一致せず、ガード条件のcase _ if n < 0も100<0がFalseで満たさない。最後のワイルドカードcase _:に落ちて\"large\"を返す。", "vs": "case _ if 条件という「ガード付きワイルドカード」と、条件なしのcase _:は別物。ガード付きは条件を満たさなければマッチせず次のcaseに進むが、条件なしのcase _:は問答無用でマッチする。だから条件なしのワイルドカードは必ず一番最後に置く。", "opt": ["正解。0は\"zero\"、2は\"small\"、-5はcase _ if n < 0のガード条件を満たすので\"negative\"、100はどれにも当てはまらず最後のcase _:で\"large\"になる。", "case _ if n < 0のガード条件はちゃんと機能する。-5はn < 0を満たすのでcase _:まで進まず\"negative\"で確定する。", "case _:はワイルドカードだが、リストの中で一番最後に書かれているので他のcaseに一致しなかったときだけ使われる。0や2は先に書かれたcaseに一致するので\"large\"にはならない。", "match-caseはPython 3.10以降の正式な構文で、case _ if 条件というガード付きの書き方もエラーにはならない。"], "calc": "classify(x)をx=0, 2, -5, 100の順に呼んだときの照合の流れ:\n①x=0 → case 0 に直接一致 → \"zero\"を返す（ここで照合終了）。\n②x=2 → case 0には不一致。case 1 | 2 | 3 は「1か2か3のどれか」という意味で、2はこれに含まれるので一致 → \"small\"を返す。\n③x=-5 → case 0にもcase 1|2|3にも不一致。次のcase _ if n < 0 はワイルドカード_に条件n < 0が付いたもので、-5 < 0はTrueなので一致 → \"negative\"を返す。\n④x=100 → ここまでのcaseすべてに不一致（case _ if n < 0も100 < 0がFalseで不一致）。最後の無条件case _: に落ちて\"large\"を返す。"}'),

  ('python-drill-q104', '制御構文と真偽値',
   '出力される内容は？',
   'def grade(score):
    return "A" if score >= 90 else "B" if score >= 70 else "C"

print(grade(95), grade(75), grade(50))',
   '["A B C", "A A A", "C C C", "A B B"]',
   0, '[0]', 'single',
   '{"asked": "出力される内容は？（ネストした三項演算子）", "point": "ネストした三項演算子はa if cond1 else (b if cond2 else c)という形にカッコを補って読む。最初の条件から順に判定し、最初に成立した条件の値が採用される。", "why_asked": "1行で書けて便利な反面、else以降に三項演算子を重ねると評価順序を読み違えやすい。特にif/elifの連鎖と同じ意味だと気づかず、評価順を逆に勘違いしがち。", "kid": "score=95は90以上なので\"A\"。score=75は90未満だがelse以下を見ると70以上なので\"B\"。score=50はどちらの条件も満たさないので最後の\"C\"になる。", "eg": "「90点以上ならA、そうでなければ（70点以上ならB、そうでなければC）」という、if/elif/elseの3段階の判定を1行で書き下したようなもの。elseの中にもう一つ判定が入れ子になっているだけで、順番に確認していく流れは同じ。", "terms": [["三項演算子（条件式）", "a if cond else bの形で、条件condがTrueならa、Falseならbを式の値としてそのまま返す1行のif/else"], ["ネスト（入れ子）", "elseの部分にさらに別の三項演算子を書き、複数段階の条件分岐を1行で表現すること"]], "think": "grade(95): score >= 90 は 95>=90 でTrue → \"A\"を返す（else以下は評価されない）。\ngrade(75): score >= 90 は 75>=90 でFalse → else側の\"B\" if score >= 70 else \"C\"を評価する。75>=70はTrueなので\"B\"を返す。\ngrade(50): score >= 90 は 50>=90 でFalse → else側を評価する。50>=70もFalseなので、さらにそのelseの\"C\"を返す。", "vs": "if/elif/elseで書いた場合と評価順序・結果はまったく同じ。三項演算子はあくまで1行で書くための表記であり、else以下に三項演算子を重ねるほどif/elifを重ねているのと同じ意味になる。", "opt": ["正解。95は90以上で\"A\"、75は90未満だが70以上なので\"B\"、50はどちらの条件も満たさないので\"C\"。", "score >= 90を満たさない75や50まで\"A\"になるのはおかしい。else以下の条件がFalseなら、その先のelseまで評価が進む。", "score >= 90を満たす95まで\"C\"になるのはおかしい。95は最初の条件score >= 90をTrueで満たすのでその時点で\"A\"が確定する。", "50はscore >= 70（50>=70）もFalseなので、\"B\"ではなくさらに先のelseの\"C\"になる。"], "calc": "grade(95)を呼んだとき:\n①score >= 90 → 95 >= 90 はTrue → その場で\"A\"が返る。else以下は評価されない。\n\ngrade(75)を呼んだとき:\n②score >= 90 → 75 >= 90 はFalse → else側の\"B\" if score >= 70 else \"C\"を評価する。\n③score >= 70 → 75 >= 70 はTrue → \"B\"が返る。\n\ngrade(50)を呼んだとき:\n④score >= 90 → 50 >= 90 はFalse → else側を評価する。\n⑤score >= 70 → 50 >= 70 はFalse → さらにそのelseの\"C\"が返る。\n\n最終的にprint(grade(95), grade(75), grade(50))は3つの戻り値をスペース区切りで出力するので\"A B C\"となる。"}'),

  ('python-drill-q105', '辞書とセット',
   'このコードを実行すると何が出力される？',
   'defaults = {"volume": 50, "difficulty": "normal"}
user_pref = {"difficulty": "hard", "language": "ja"}
merged = defaults | user_pref
print(merged)',
   '["{''volume'': 50, ''difficulty'': ''hard'', ''language'': ''ja''}", "{''volume'': 50, ''difficulty'': ''normal'', ''language'': ''ja''}", "{''difficulty'': ''hard'', ''language'': ''ja''}", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（辞書のマージ演算子|）", "point": "`|`で辞書をマージするなら、キーが重複したときは右側（後ろ）の辞書の値が勝つ。", "why_asked": "デフォルト設定をユーザー設定で上書きするような処理は実務で頻出する。左右どちらが優先されるかを逆に覚えていると、ユーザーの指定が無視されるバグになる。", "kid": "defaultsとuser_prefを`|`でマージすると、両方のキーをあわせ持つ新しい辞書ができる。difficultyは両方にあるが、後ろに書いたuser_prefの''hard''が残る。", "eg": "2枚の座席表を重ねて1枚にまとめるとき、同じ席番号が両方にあったら、後から重ねた紙の方の名前が見える、という感じ。", "terms": [["`|`演算子（辞書のマージ）", "Python 3.9以降で使える、2つの辞書を合体させて新しい辞書を作る演算子"], ["defaults | user_pref", "左のdefaultsをベースに、右のuser_prefの内容で重複キーを上書きしてマージする"]], "think": "1行目でdefaultsはvolumeとdifficultyの2キー。2行目でuser_prefはdifficultyとlanguageの2キー。3行目のdefaults | user_prefでは、まずdefaultsの内容をベースにし、そこへuser_prefのキーと値を重ねていく。volumeはdefaultsにしかないのでそのまま残り、languageはuser_prefにしかないので追加され、difficultyは両方にあるので後ろのuser_prefの''hard''に置き換わる。", "vs": "似た書き方に`defaults.update(user_pref)`があるが、これはdefaults自体を書き換える破壊的な操作で、新しい辞書は作らない。`|`は新しい辞書を返すので元のdefaultsとuser_prefはどちらも変化しない。", "opt": ["正解。`|`は左を土台に右で上書きしてマージした新しい辞書を作る。重複するdifficultyキーは右側のuser_prefの''hard''が残る。", "左側が優先されると考えた場合の答え。実際は右側（後ろに書いた方）のuser_prefの値が優先される。", "`|`がdefaultsを完全に置き換えると考えた場合の答え。実際はvolumeのようなdefaultsだけにあるキーもそのまま残る。", "`|`は辞書同士でも問題なくマージできる演算子（Python 3.9以降）。エラーにはならない。"], "calc": "左を土台にして、右で上書きするイメージで1キーずつ確認する。\n\ndefaults = {''volume'': 50, ''difficulty'': ''normal''}\nuser_pref = {''difficulty'': ''hard'', ''language'': ''ja''}\n\nvolume → defaultsだけに存在 → そのまま50が残る\ndifficulty → 両方に存在 → 右側(user_pref)の''hard''が勝つ\nlanguage → user_pref側だけに存在 → 新しく追加される\n\nmerged = defaults | user_pref → {''volume'': 50, ''difficulty'': ''hard'', ''language'': ''ja''}"}'),

  ('python-drill-q106', '辞書とセット',
   'このコードを実行すると何が出力される？',
   'morning = {"coffee", "toast", "juice"}
evening = {"coffee", "salad", "juice"}
print(sorted(morning - evening))
print(sorted(morning ^ evening))',
   '["[''toast''] と [''salad'', ''toast'']", "[''coffee'', ''juice''] と [''salad'', ''toast'']", "[''toast''] と [''toast'']", "[] と [''coffee'', ''salad'', ''juice'', ''toast'']"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（setの差集合と対称差集合）", "point": "`-`は片方（左）にしかない要素、`^`はどちらか一方にだけある要素（両方に共通する要素は除いたもの）を返す。", "why_asked": "重複データの検出や『Aにあって Bに無いものだけ』を抜き出す処理でset演算を使うが、-と^の意味を取り違えると欲しいものと違う集合を取得してしまう。", "kid": "morning - eveningはmorningにしかないtoastだけが残り、morning ^ eveningはどちらか一方にしかないtoastとsaladの両方が残る（両方にあるcoffeeとjuiceは消える）。", "eg": "2つのグループの集合写真を比べて、『Aだけに写っている人』を探すのが-、『AかBのどちらか片方にしか写っていない人（両方に写っている人は除く）』を探すのが^、というイメージ。", "terms": [["`-`（差集合）", "左のセットにあって右のセットに無い要素だけを取り出す演算子"], ["`^`（対称差集合）", "両方のセットのうち、どちらか一方にだけある要素を取り出す演算子（両方に共通する要素は除外される）"], ["sorted(セット)", "setは表示順が不定なので、順序を固定して結果を確認しやすくするために使っている"]], "think": "1行目でmorningは3要素、2行目でeveningは3要素、coffeeとjuiceが共通している。morning - eveningはmorningにあってeveningに無い要素なのでtoastだけ残る。morning ^ eveningはどちらか一方にしかない要素なので、morning側のtoastとevening側のsaladの両方が残り、共通のcoffeeとjuiceは除外される。", "vs": "`&`（積集合）は逆に『両方に共通する要素』を返す。`morning & evening`なら{''coffee'', ''juice''}になる。-や^と&は真逆の発想になるので混同しないよう注意。", "opt": ["正解。-は左にあって右に無い要素、^はどちらか一方にだけある要素（共通分は除く）。", "-を&（共通する要素を取り出す積集合）と取り違えた場合の答え。-は共通する要素ではなく、左だけにある要素を返す。", "^を-と同じ『morningだけの要素』だと考えた場合の答え。実際は^はevening側だけの要素(salad)も含める。", "-を『共通していないので空になる』、^を『全部合わせる』と誤解した場合の答え。-は左だけの要素をきちんと残し、^は共通する要素を除外する。"], "calc": "共通する要素と片方だけの要素を仕分けてから計算する。\n\nmorning = {coffee, toast, juice}\nevening = {coffee, salad, juice}\n共通: coffee, juice\nmorningだけ: toast\neveningだけ: salad\n\nmorning - evening → morningにあってeveningに無い要素 → toastだけ → [''toast'']\nmorning ^ evening → どちらか一方にだけある要素 → toastとsalad（共通のcoffeeとjuiceは除外） → [''salad'', ''toast'']（sorted済み）"}'),

  ('python-drill-q107', '辞書とセット',
   'このコードを実行すると何が出力される？',
   'from collections import defaultdict
inventory = defaultdict(list)
inventory["fruits"].append("apple")
print(inventory["vegetables"])
print(dict(inventory))',
   '["[] と {''fruits'': [''apple''], ''vegetables'': []}", "エラーになる", "[] と {''fruits'': [''apple'']}", "None と {''fruits'': [''apple''], ''vegetables'': None}"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（defaultdictで存在しないキーにアクセスしたときの挙動）", "point": "defaultdict(list)は存在しないキーに一度アクセスするだけで、そのキーに空リストが自動生成されて辞書に追加される。", "why_asked": "通常のdictなら存在しないキーへのアクセスはKeyErrorになるが、defaultdictはそれを回避できる。ただし『読んだだけなのにキーが増える』という副作用があることを知らないと、辞書の中身が意図せず膨らんでしまう。", "kid": "inventory[''fruits'']にappendしたことでfruitsキーができ、その後inventory[''vegetables'']を読んだだけなのに、defaultdictは自動で空リストを用意してそれをvegetablesキーとして辞書に登録してしまう。", "eg": "冷蔵庫に『野菜』というラベルの棚がまだ無くても、『野菜の棚を見よう』とした瞬間に自動で空の棚が用意されて、それ以降ずっとその棚が存在し続ける、というイメージ。", "terms": [["defaultdict(list)", "collections標準ライブラリのクラス。存在しないキーにアクセスすると自動的に空リストを作って初期化する辞書"], ["dict(inventory)", "defaultdictを普通のdictに変換して表示する（defaultdictをそのままprintすると特殊な表記が付くため、見やすくするために変換している）"]], "think": "1行目でinventoryは空のdefaultdict(list)。2行目でinventory[''fruits'']に''apple''をappendし、fruitsキーに[''apple'']ができる。3行目のprint(inventory[''vegetables''])は、vegetablesキーがまだ無いので、defaultdictがその場で空リストを自動生成して返す。同時にこの操作でvegetablesキー自体が辞書に追加される。4行目でdict(inventory)を表示すると、fruitsとvegetablesの両方のキーが残っている。", "vs": "通常のdict（defaultdictを使わないただの{}）で同じコードを書くと、存在しないキーvegetablesへのアクセスはKeyErrorで例外が発生する。defaultdictは`.get()`と違い、読み取りアクセスしただけでもそのキーを辞書に実際に追加してしまう点に注意（`.get(''vegetables'', [])`ならキーを追加せずに空リストを返すだけで済む）。", "opt": ["正解。defaultdict(list)は存在しないキーへのアクセス時に自動で空リストを作り、そのキー自体も辞書に追加する。", "通常のdictと同じようにKeyErrorになると考えた場合の答え。defaultdictはキーが無くてもエラーにならず、自動で空リストを用意する。", "読み取っただけならキーは追加されないと考えた場合の答え。実際はdefaultdictは読み取りアクセスだけでもそのキーを辞書に実際に追加してしまう。", "存在しないキーのデフォルト値がNoneになると考えた場合の答え。defaultdict(list)ではNoneではなく空リスト[]が使われる。"], "calc": "1行ずつ辞書の中身を追う。\n\ninventory = defaultdict(list) → 空の辞書\ninventory[''fruits''].append(''apple'') → fruitsキーが無いので自動で空リストを用意 → そこに''apple''を追加 → inventory = {''fruits'': [''apple'']}\nprint(inventory[''vegetables'']) → vegetablesキーが無いので自動で空リストを用意して返す → 出力は[]、同時にinventory = {''fruits'': [''apple''], ''vegetables'': []}に変化\nprint(dict(inventory)) → {''fruits'': [''apple''], ''vegetables'': []}"}'),

  ('python-drill-q108', '文字列操作',
   'このコードを実行すると何が出力される？',
   'x = 3
y = 4
print(f"{x} + {y} = {x + y}")
print(f"{''py''.upper()} is {len(''python'')} chars")',
   '["3 + 4 = 7 と PY is 6 chars", "{x} + {y} = {x + y} と {''py''.upper()} is {len(''python'')} chars", "エラーになる", "3 + 4 = 7 と py is 6 chars"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（f-stringの中で式や関数呼び出しを使う）", "point": "f-stringの`{}`の中には変数だけでなく、計算式やメソッド呼び出しなど任意の式をそのまま書ける。", "why_asked": "ログ出力やメッセージ生成で『変数をそのまま貼るだけ』と思い込んでいると、f-stringの中で計算やメソッド呼び出しができることに気づかず、わざわざ手前で別の変数に計算結果を代入する回りくどいコードを書いてしまう。", "kid": "f-stringの{}の中に書いたx + yはそのまま足し算として計算されて7になり、''py''.upper()もそのまま実行されて''PY''になる。", "eg": "テンプレートの空欄に、ただの数字だけでなく『ここで計算した結果を入れてね』という指示書を挟み込めるようなもの。", "terms": [["f-string", "文字列の前にfを付けて書く記法。{}の中に式を書くと、その式を評価した結果が文字列に埋め込まれる"], ["f文字列の{}内の式", "変数名だけでなく、四則演算やメソッド呼び出しなど、Pythonの式として評価できるものは何でも書ける"]], "think": "1行目でx=3, y=4。2行目のf\"{x} + {y} = {x + y}\"では、{x}は3、{y}は4、{x + y}はxとyを足した式として評価されて7になり、''3 + 4 = 7''という文字列になる。3行目のf\"{''py''.upper()} is {len(''python'')} chars\"では、{''py''.upper()}は''py''という文字列に対して.upper()メソッドを呼び出した結果''PY''になり、{len(''python'')}は''python''という文字列の長さ6が入るので、''PY is 6 chars''になる。", "vs": "古い書き方の`\"{} + {} = {}\".format(x, y, x + y)`でも同じことはできるが、f-stringの方が変数名や式をその場に直接書けて読みやすい。`%`演算子を使うprintf形式のフォーマットでは式をそのまま書くことはできず、事前に変数へ計算結果を入れておく必要がある。", "opt": ["正解。{}の中は式として評価される。x + yは7、''py''.upper()は''PY''、len(''python'')は6になる。", "f-stringの{}が中身をそのまま文字として表示すると考えた場合の答え。実際は{}の中は式として評価され、計算結果や関数の戻り値が埋め込まれる。", "f-stringの{}にはメソッド呼び出しを書けないと考えた場合の答え。実際は{}の中には変数だけでなく、メソッド呼び出しを含む任意の式を書ける。", ".upper()がf-stringの中では効かないと考えた場合の答え。実際は{}内の式は通常のPythonコードと同じように評価されるので、.upper()もそのまま働く。"], "calc": "{}の中の式を1つずつ評価する。\n\nf\"{x} + {y} = {x + y}\"\n・{x} → 3\n・{y} → 4\n・{x + y} → 3 + 4を計算 → 7\n→ ''3 + 4 = 7''\n\nf\"{''py''.upper()} is {len(''python'')} chars\"\n・{''py''.upper()} → ''py''を大文字化 → ''PY''\n・{len(''python'')} → ''python''は6文字 → 6\n→ ''PY is 6 chars''"}'),

  ('python-drill-q109', '文字列操作',
   'このコードを実行すると何が出力される？',
   'text = "hello world"
table = str.maketrans("lo", "10")
print(text.translate(table))',
   '["he110 w0r1d", "hel10 world", "he111 w1r1d", "he001 w1r0d"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（str.translateとstr.maketransによる一括置換）", "point": "str.maketrans(from, to)は『fromのi番目の文字をtoのi番目の文字に変換する対応表』を作り、str.translate(table)はその対応表に従って1文字ずつ一括で置き換える。", "why_asked": ".replace()を何度も呼ぶと変換ペアが増えるほどコードが長くなるが、translateとmaketransを使うと複数文字の置換を1回の呼び出しでまとめて書けることを知らないと、無駄に長いコードになってしまう。", "kid": "str.maketrans(''lo'', ''10'')は『lを1に、oを0に変換する』という対応表を作り、text.translate(table)はhello worldの中のlとoだけをその対応表通りに置き換えて''he110 w0r1d''にする。", "eg": "『変換ルール表』を1枚用意して、その表に載っている文字だけを一気に置き換えていくようなもの。lは1に、oは0に、というルールを1回の作業でまとめて適用するイメージ。", "terms": [["str.maketrans(from, to)", "from文字列のi番目の文字をto文字列のi番目の文字に対応させる変換表を作る"], ["str.translate(table)", "maketransで作った変換表に従って、文字列中の対象文字を一括で置き換える"]], "think": "1行目でtext = ''hello world''。2行目のstr.maketrans(''lo'', ''10'')は、''l''→''1''、''o''→''0''という対応表を作る（1文字目同士、2文字目同士がペアになる）。3行目のtext.translate(table)は、textの各文字を1文字ずつ調べて、対応表にある文字だけ置き換える。h,eはそのまま、l→1、l→1、o→0、スペースはそのまま、wはそのまま、o→0、r,d手前のlは1、最後のdはそのまま、と1文字ずつ追うと''he110 w0r1d''になる。", "vs": ".replace(''l'', ''1'').replace(''o'', ''0'')のように.replace()を連続で呼んでも同じ結果は作れるが、置換したい文字が増えるほど.replace()の呼び出しも増えて読みにくくなる。translateとmaketransなら対応表を1つ作るだけで何文字でも一括置換できる。", "opt": ["正解。maketransで''l''→''1''、''o''→''0''の対応表を作り、translateは1文字ずつその対応表通りに置き換える。", "translateを.replace(''lo'', ''10'')のような部分文字列の置換だと勘違いした場合の答え。実際は''lo''という2文字それぞれが個別の変換対象になり、部分文字列としてまとめて置換されるわけではない。", "''l''と''o''のどちらも同じ文字（''1''）に変換されると勘違いした場合の答え。実際はmaketransは1文字目同士・2文字目同士をペアにするので、''l''→''1''、''o''→''0''と別々の文字に対応する。", "''l''と''o''の対応が逆（''l''→''0''、''o''→''1''）だと勘違いした場合の答え。maketransは引数の並び順通りに、''lo''の1文字目''l''が''10''の1文字目''1''に対応する。"], "calc": "1文字ずつ対応表(l→1, o→0)と照らし合わせる。\n\ntext = ''hello world''\ntable: l → 1、o → 0（それ以外の文字はそのまま）\n\nh→h, e→e, l→1, l→1, o→0, (空白)→(空白), w→w, o→0, r→r, l→1, d→d\n\n→ ''he110 w0r1d''"}'),

  ('python-drill-q110', '文字列操作',
   'このコードを実行すると何が出力される？',
   'result = "ab" * 2 + "cd" * 3
print(result)',
   '["ababcdcdcd", "ababcdababcdababcd", "abababcdcd", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（文字列の掛け算と結合を組み合わせた式の評価順序）", "point": "文字列の`*`は`+`より先に計算される（掛け算の方が優先順位が高い）ので、`\"ab\" * 2 + \"cd\" * 3`は`(\"ab\" * 2) + (\"cd\" * 3)`として評価される。", "why_asked": "数値の四則演算と同じ優先順位ルールが文字列の演算子にもそのまま適用されることを知らないと、掛け算と足し算が混ざった式を左から順番に計算してしまい、意図と違う文字列を作ってしまう。", "kid": "\"ab\" * 2は''abab''、\"cd\" * 3は''cdcdcd''になり、それを+でつなげるので''ababcdcdcd''になる。", "eg": "『abを2回繰り返したスタンプ』と『cdを3回繰り返したスタンプ』を、それぞれ別々に完成させてから最後にのりで貼り合わせる、というイメージ。先に貼り合わせてからまとめて繰り返す、という順番ではない。", "terms": [["演算子の優先順位", "1つの式に複数の演算子があるとき、どれを先に計算するかのルール。文字列の`*`（繰り返し）は`+`（連結）より先に計算される"], ["文字列 * 整数", "文字列をその整数回だけ繰り返して連結した新しい文字列を作る"]], "think": "1行目の式\"ab\" * 2 + \"cd\" * 3では、まず優先順位の高い*が先に計算される。\"ab\" * 2は''abab''、\"cd\" * 3は''cdcdcd''になる。その後、+でこの2つの文字列がそのままつながるので、''abab'' + ''cdcdcd'' = ''ababcdcdcd''になる。", "vs": "もし(\"ab\" * 2 + \"cd\") * 3のようにカッコで先に+を計算させると、''ababcd''を3回繰り返した''ababcdababcdababcd''という別の結果になる。カッコの有無で優先順位が変わる点に注意。", "opt": ["正解。*は+より先に計算されるので、\"ab\" * 2の''abab''と\"cd\" * 3の''cdcdcd''を先に作ってから連結する。", "式全体を左から順番に評価し、(\"ab\" * 2 + \"cd\") * 3のようにまとめて3回繰り返すと勘違いした場合の答え。実際は*が+より先に計算されるので、そのようなまとめ方にはならない。", "\"ab\" * 2と\"cd\" * 3の繰り返し回数を取り違えた（abを3回、cdを2回と逆にした）場合の答え。実際はabが2回、cdが3回繰り返される。", "文字列に対して*と+を同じ式の中で混ぜて使うとエラーになると勘違いした場合の答え。文字列の繰り返し(*)と連結(+)は同じ式の中で問題なく組み合わせられる。"], "calc": "優先順位の高い*から先に計算する。\n\n\"ab\" * 2 → ''abab''\n\"cd\" * 3 → ''cdcdcd''\n\n最後に+でつなげる → ''abab'' + ''cdcdcd'' → ''ababcdcdcd''"}'),

  ('python-drill-q111', 'リストとタプル',
   'このコードを実行すると何が出力される？',
   'grid = [[0] * 3] * 2
grid[0][0] = 1
print(grid)',
   '["[[1, 0, 0], [1, 0, 0]]", "[[1, 0, 0], [0, 0, 0]]", "[[1, 1, 1], [1, 1, 1]]", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（ネストしたリストを*で複製するときの罠）", "point": "`[内側のリスト] * n`は内側のリストのコピーではなく、同じオブジェクトへの参照をn個並べるだけなので、1つを変更すると全部が変わって見える。", "why_asked": "2次元配列や盤面を初期化するときに`[[0] * cols] * rows`と書いてしまうと、見た目は独立した行に見えても実は全行が同じリストを指しているため、1マスだけ書き換えたつもりが全行が変わってしまうバグを引き起こす、非常に有名な罠。", "kid": "[[0] * 3] * 2は『[0, 0, 0]という1つのリストを2回並べる』という意味になり、外側のリストには同じ[0, 0, 0]への参照が2つ入るだけ。だからgrid[0][0] = 1で書き換えると、grid[1]も同じリストを指しているので一緒に変わって見える。", "eg": "1枚の名簿のコピーを2部刷ったつもりが、実は同じ1枚の名簿を2つのクリップボードに挟んだだけだったようなもの。片方のクリップボードの名簿に書き込むと、もう片方のクリップボードから見ても同じ名簿なので、当然内容が変わって見える。", "terms": [["リストの`*`複製", "[x] * nは、xという要素（オブジェクトへの参照）をn個並べた新しいリストを作る。x自体は複製されない"], ["参照（オブジェクトの共有）", "変数が値そのものではなく、値が置かれている場所を指している状態。複数の変数が同じ場所を指していると、片方を書き換えると他方からも変化が見える"]], "think": "1行目の[0] * 3は新しいリスト[0, 0, 0]を1つ作る。次に[[0, 0, 0]] * 2は、その[0, 0, 0]という1つのリストへの参照を2個並べるだけなので、gridの中身は『同じ[0, 0, 0]オブジェクトを指す参照』が2つ入った状態になる（grid[0]とgrid[1]は同一のオブジェクト）。2行目のgrid[0][0] = 1は、その共有されているリストの0番目の要素を1に書き換える。grid[0]とgrid[1]はどちらも同じリストを指しているので、両方とも[1, 0, 0]に見える。", "vs": "各行を独立させたい場合は`[[0, 0, 0] for _ in range(2)]`のようにリスト内包表記で毎回新しいリストを作る必要がある。この書き方なら呼び出しごとに別々の新しいリストが生成されるので、grid[0][0] = 1としてもgrid[1]は変化しない。", "opt": ["正解。外側の* 2は同じ内側リストへの参照を2つ並べるだけなので、grid[0]とgrid[1]は同一のリストを指しており、片方を書き換えると両方に反映される。", "grid[0]とgrid[1]が別々の独立したリストだと勘違いした場合の答え。実際は[[0] * 3] * 2は内側のリストをコピーせず、同じリストへの参照を2つ並べるだけ。", "grid[0][0] = 1という代入がリスト全体のすべての要素を1に置き換えると勘違いした場合の答え。実際に書き換わるのはインデックス0の要素だけで、それが2つの行に反映される。", "grid[0]がタプルのように書き換え不可（イミュータブル）だと勘違いした場合の答え。grid[0]は普通のリストなので要素の代入は問題なくできる。"], "calc": "外側の`* 2`は『同じ内側リストへの参照』を2つ並べるだけ、という点に注目する。\n\n[0] * 3 → 新しいリスト[0, 0, 0]を1つ作る（これをAと呼ぶ）\n[A] * 2 → Aへの参照を2つ並べる → grid = [A, A]（grid[0]とgrid[1]は同じAを指す）\n\ngrid[0][0] = 1\n・grid[0]はAそのものなので、Aの0番目の要素を1に書き換える → A = [1, 0, 0]\n・grid[1]も同じAを指しているので、grid[1]から見ても[1, 0, 0]に変わって見える\n\nprint(grid) → [[1, 0, 0], [1, 0, 0]]（grid[0]とgrid[1]は今も同じオブジェクト）", "viz": "<svg viewBox=\"0 0 340 140\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\"><text x=\"10\" y=\"18\" font-size=\"11\" fill=\"#8892a4\">grid = [A, A]（同じリストAを2つ参照している）</text><rect x=\"20\" y=\"40\" width=\"90\" height=\"32\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"65\" y=\"60\" font-size=\"10\" fill=\"#e8eaf0\" text-anchor=\"middle\">grid[0]</text><rect x=\"20\" y=\"88\" width=\"90\" height=\"32\" rx=\"4\" fill=\"none\" stroke=\"#2a2f3f\"/><text x=\"65\" y=\"108\" font-size=\"10\" fill=\"#e8eaf0\" text-anchor=\"middle\">grid[1]</text><rect x=\"200\" y=\"64\" width=\"120\" height=\"32\" rx=\"4\" fill=\"none\" stroke=\"#c9a04a\"/><text x=\"260\" y=\"84\" font-size=\"10\" fill=\"#e8eaf0\" text-anchor=\"middle\">A = [1, 0, 0]</text><line x1=\"110\" y1=\"56\" x2=\"200\" y2=\"78\" stroke=\"#60a5fa\"/><line x1=\"110\" y1=\"104\" x2=\"200\" y2=\"82\" stroke=\"#60a5fa\"/><circle cx=\"110\" cy=\"56\" r=\"2\" fill=\"#60a5fa\"/><circle cx=\"110\" cy=\"104\" r=\"2\" fill=\"#60a5fa\"/></svg>"}'),

  ('python-drill-q112', 'リストとタプル',
   'このコードを実行すると何が出力される？',
   'words = ["kiwi", "fig", "banana", "date"]
result = sorted(words, key=len, reverse=True)
print(result)',
   '["[''banana'', ''kiwi'', ''date'', ''fig'']", "[''banana'', ''date'', ''kiwi'', ''fig'']", "[''kiwi'', ''fig'', ''date'', ''banana'']", "[''kiwi'', ''fig'', ''banana'', ''date'']"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（sorted()のkey引数とreverse引数の組み合わせ）", "point": "key=lenで『長さ』を並べ替えの基準にし、reverse=Trueで降順にする。同じ長さの要素同士は元のリストでの並び順がそのまま保たれる（安定ソート）。", "why_asked": "『昇順に並べてから逆にする』と考えると同着の要素の順番まで逆になると誤解しやすいが、Pythonのsorted()はreverse=Trueでも安定ソートを保つので、同着同士の元の並び順は変わらない。この違いを知らないと、同着が多いデータの並べ替え結果を読み間違える。", "kid": "各単語の長さはkiwi=4, fig=3, banana=6, date=4。長さの降順に並べるとbanana(6)が最初、次に長さ4のkiwiとdateが元の並び順のまま続き、最後にfig(3)が来る。", "eg": "背の高い順に整列させるとき、同じ身長の人同士は元の整列順（並んでいた順番）のまま並び直す、というイメージ。同じ身長の人たちの前後関係まで逆転させたりはしない。", "terms": [["sorted(iterable, key=..., reverse=...)", "keyに渡した関数の戻り値を基準に並べ替え、reverse=Trueなら降順にする"], ["安定ソート（stable sort）", "並べ替えの基準となる値が同じ要素同士は、元のリストでの並び順を保ったまま並べ替える性質。Pythonのsorted()とsort()はreverseの有無にかかわらず安定ソート"]], "think": "1行目でwordsは4つの単語。2行目のsorted(words, key=len, reverse=True)は、まず各単語をlen()で数値化する。kiwi→4, fig→3, banana→6, date→4。この数値を基準に降順（大きい順）に並べる。banana(6)が最初に来るのは確定。残りはkiwiとdateがどちらも4、figが3で最後。同じ4同士のkiwiとdateは、元のwordsリストでkiwiがdateより先にあったので、その順番のまま『kiwi, date』の順で並ぶ。結果は[''banana'', ''kiwi'', ''date'', ''fig'']。", "vs": "もし『昇順に並べてからlist.reverse()やスライスの[::-1]で反転する』と、同着の要素の前後関係まで反転してしまい、kiwiとdateの順番が入れ替わった[''banana'', ''date'', ''kiwi'', ''fig'']になる。sorted()のreverse=Trueと、後から反転するのは同着がある場合に結果が変わる点に注意。", "opt": ["正解。長さの降順に並べ、同じ長さのkiwiとdateは元のwordsでの並び順（kiwiが先）のまま残る（安定ソート）。", "『昇順に並べてから丸ごと反転する』と考えた場合の答え。それだと同着のkiwiとdateの前後関係まで逆転してしまうが、reverse=Trueは安定ソートなので同着の順番は元のまま保たれる。", "key=lenが効かず、文字列そのものの降順（アルファベット順の逆）で並べ替えたと考えた場合の答え。実際はkey=lenが指定されているので、長さを基準に並べ替える。", "sorted()にreverseとkeyを同時に渡すと並べ替えが行われず元の順番のままになると勘違いした場合の答え。実際はkeyとreverseは同時に指定でき、指定した基準で正しく並べ替えられる。"], "calc": "各単語をlen()で数値化してから、降順・同着は元の順番維持で並べる。\n\nkiwi → 4\nfig → 3\nbanana → 6\ndate → 4\n\n長さの降順: banana(6) → 長さ4の2つ(kiwi, date) → fig(3)\n長さ4同士のkiwiとdateは、元のwordsでkiwiが先にあったので、その順番のまま『kiwi, date』の順に並ぶ（安定ソート）\n\n→ [''banana'', ''kiwi'', ''date'', ''fig'']"}'),

  ('python-drill-q113', '関数型プログラミング',
   'このコードを実行すると何が出力される？',
   'from functools import partial

def power(base, exponent):
    return base ** exponent

square = partial(power, exponent=2)
cube = partial(power, exponent=3)
print(square(5), cube(2))',
   '["25 8", "125 8", "25 9", "エラーになる"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（functools.partialによる引数の部分適用）", "point": "partial(関数, 固定したい引数=値)は、その引数だけをあらかじめ埋め込んだ新しい関数を作る。後から渡す引数は残りの引数（ここではbase）に入る。", "why_asked": "同じ関数を『一部の引数だけ変えて』何度も呼びたい場面（累乗の底だけ変える、決まった設定を使い回すAPI呼び出しなど）で使うが、どの引数が固定されどの引数が後から埋まるのかを取り違えると、意図と違う計算をしてしまう。", "kid": "squareはexponent（指数）を2に固定した関数、cubeはexponent（指数）を3に固定した関数。square(5)は残りのbaseに5を渡すので5の2乗の25、cube(2)は2の3乗の8になる。", "eg": "『いつも指数は2で計算する電卓』と『いつも指数は3で計算する電卓』をあらかじめ2台用意しておいて、あとは底の数字（5や2）だけをそれぞれの電卓に打ち込む、というイメージ。電卓同士は独立していて、片方の設定がもう片方に影響することはない。", "terms": [["functools.partial(関数, 引数=値)", "関数の一部の引数だけをあらかじめ固定した、新しい関数（呼び出し可能なオブジェクト）を作る"], ["部分適用", "関数の引数の一部だけを先に決めておき、残りの引数は後から呼び出すときに渡す、という考え方"]], "think": "3〜4行目でpower(base, exponent)はbaseのexponent乗を返す関数。6行目のsquare = partial(power, exponent=2)は、exponentを2に固定したpower関数のようなものを作る。7行目のcube = partial(power, exponent=3)も同様にexponentを3に固定するが、squareとは別の独立したオブジェクトなので、squareのexponentが上書きされたりはしない。8行目のsquare(5)は、残っているbaseに5を渡すので、power(5, exponent=2) = 5 ** 2 = 25。cube(2)はpower(2, exponent=3) = 2 ** 3 = 8。", "vs": "普通に`def square(base): return power(base, exponent=2)`とラッパー関数を自分で書いても同じことはできるが、partialを使うと1行で同じ部分適用の関数を作れる。partialで固定した引数を、あとから位置引数として重ねて渡すとエラーになる点にも注意（例えばsquare(5, 2)のように第2引数もexponentとして渡そうとすると、exponentの値が2つ指定されたことになりエラーになる）。", "opt": ["正解。squareはexponent=2、cubeはexponent=3に固定された別々の関数。square(5)は5 ** 2 = 25、cube(2)は2 ** 3 = 8。", "後から作ったcubeのexponent=3が、先に作ったsquareにも影響すると勘違いした場合の答え。squareとcubeはそれぞれ独立したオブジェクトなので、片方の設定がもう片方に影響することはない。", "cube(2)のbaseとexponentを取り違え、3 ** 2として計算した場合の答え。cubeはexponentが3に固定されているので、後から渡した2はbaseに入り、2 ** 3として計算される。", "partial(power, exponent=2)のようにキーワード引数で固定した後、残りの引数を位置引数で渡すことはできないと勘違いした場合の答え。固定していないbaseは通常どおり位置引数として渡せる。"], "calc": "squareとcubeはそれぞれ独立した『exponent固定済み関数』であることに注目して1つずつ計算する。\n\nsquare = partial(power, exponent=2) → exponentを2に固定した関数\ncube = partial(power, exponent=3) → exponentを3に固定した関数（squareとは別物）\n\nsquare(5) → 残りのbaseに5が入る → power(5, exponent=2) → 5 ** 2 → 25\ncube(2) → 残りのbaseに2が入る → power(2, exponent=3) → 2 ** 3 → 8\n\nprint(square(5), cube(2)) → 25 8"}'),

  ('python-drill-q114', '関数型プログラミング',
   'このコードを実行すると何が出力される？',
   'from itertools import groupby

data = ["a", "a", "b", "a", "a"]
groups = [(k, list(g)) for k, g in groupby(data)]
print(groups)',
   '["[(''a'', [''a'', ''a'']), (''b'', [''b'']), (''a'', [''a'', ''a''])]", "[(''a'', [''a'', ''a'', ''a'', ''a'']), (''b'', [''b''])]", "[(''a'', [''a'']), (''a'', [''a'']), (''b'', [''b'']), (''a'', [''a'']), (''a'', [''a''])]", "[(''a'', [''a'', ''a'']), (''b'', [''b''])]"]',
   0, '[0]', 'single',
   '{"asked": "このコードを実行すると何が出力される？（itertools.groupbyで連続する同じ要素をグループ化する）", "point": "groupby()は『直前の要素と同じ値かどうか』だけを見て連続する要素をグループ化する。事前にソートされていないと、同じ値でも離れていれば別グループとして扱われる。", "why_asked": "『同じ値をまとめて集計してくれる関数』だと思い込んでいると、事前にソートしていないデータにgroupbyを使ったときに、期待した1つのグループにならず、離れた場所にある同じ値が複数の別グループに分かれてしまう罠にハマる。", "kid": "dataは[''a'', ''a'', ''b'', ''a'', ''a'']という並び。groupbyは前後を見て『連続して同じ値が続いている間』だけを1つのグループにするので、最初の2つの''a''で1グループ、''b''で1グループ、最後の2つの''a''でまた別の1グループの、合計3グループになる。", "eg": "電車の座席で、隣同士に座っている同じ色の服の人たちだけを『1つのグループ』として数えるようなもの。同じ色の服でも、間に別の色の人が座っていれば、離れた場所の人たちは別グループとしてカウントされる。", "terms": [["itertools.groupby(iterable)", "連続して同じ値（またはkey関数の戻り値）が続く区間ごとにグループ化するイテレータを作る。ソートされていないデータでは離れた同じ値は別グループになる"], ["list(g)", "groupbyが返す各グループはイテレータなので、中身を確認するためにlist()でリストに変換している"]], "think": "dataは[''a'', ''a'', ''b'', ''a'', ''a'']の5要素。groupbyは先頭から順に見ていき、直前の要素と同じ値が続く限り同じグループに入れる。1番目の''a''と2番目の''a''は連続しているので1つ目のグループ(''a'', [''a'', ''a''])。3番目の''b''は直前と違う値なので新しいグループ(''b'', [''b''])。4番目の''a''も直前の''b''と違う値なので、たとえキーが''a''であっても既に終わった1つ目の''a''グループとはまとめられず、新しい3つ目のグループが始まる。4番目と5番目の''a''は連続しているので(''a'', [''a'', ''a''])としてまとめられる。結果、3つのグループができる。", "vs": "もし本当に『同じ値を全部1つにまとめたい』のであれば、事前にsorted(data)でソートしてからgroupbyに渡す必要がある。ソート済みのデータなら同じ値は必ず隣り合うので、[''a'', ''a'', ''a'', ''a'', ''b'']をgroupbyすると(''a'', [...4個])と(''b'', [''b''])の2グループにきれいにまとまる。collections.Counterを使えば、ソートを気にせず値ごとの個数をまとめて数えられる。", "opt": ["正解。groupbyは連続する同じ値だけをまとめるので、離れた場所にある同じ''a''は別グループになり、合計3グループになる。", "groupbyがデータ全体から同じ値を探して1つのグループにまとめてくれると勘違いした場合の答え。実際は連続している範囲しか見ないので、離れた''a''は別グループとして扱われる。", "groupbyがグループ化をまったく行わず、要素を1つずつバラバラに返すと勘違いした場合の答え。実際は連続する同じ値はきちんと1つのグループにまとめられる。", "同じキー''a''は1回しか使えず、2回目に''a''が出てきたときは無視されると勘違いした場合の答え。実際はキーが同じでも、間に別の値を挟めば新しい別グループとして扱われる。"], "calc": "『直前の要素と同じかどうか』だけを見ながら1つずつグループを区切っていく。\n\ndata = [''a'', ''a'', ''b'', ''a'', ''a'']\n\n1番目''a'' → 新しいグループ開始（キー''a''）\n2番目''a'' → 直前と同じ''a'' → 同じグループに追加 → (''a'', [''a'', ''a''])\n3番目''b'' → 直前の''a''と違う → 新しいグループ開始（キー''b''） → (''b'', [''b''])\n4番目''a'' → 直前の''b''と違う → 新しいグループ開始（キー''a''、1つ目の''a''グループとは別物）\n5番目''a'' → 直前と同じ''a'' → 同じグループに追加 → (''a'', [''a'', ''a''])\n\n→ [(''a'', [''a'', ''a'']), (''b'', [''b'']), (''a'', [''a'', ''a''])]（''a''のグループが2回出てくる＝合計3グループ）"}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'python-drill'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
