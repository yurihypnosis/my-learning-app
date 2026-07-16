-- Terraform Associate (004) Set B — 問題 17〜33（4. 構成(HCL) / 5. モジュール）/ 2026-07-16
-- 公式 Exam Content List の 4b〜4h、5a〜5d に対応。Set A が薄かった式・関数・lifecycle を厚くする。
BEGIN;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

-- ── 4. 構成(HCL) ──
('terraform-associate-b-q17', '4. 構成(HCL)',
 '構成内で繰り返し使う中間的な値に名前を付けたい。入力として外から渡す必要はない。使うべきブロックはどれか。',
 NULL::text,
 '["locals","variable","output","data"]',
 0, '[0]', 'single',
 '{"asked":"locals と variable の使い分けを理解しているか。","why_asked":"どちらも値に名前を付けるため混同されやすい。外から渡すものか、構成内で組み立てるものかという役割の違いが分かっていないと、変えるつもりのない値まで入力変数にしてしまう。","kid":"外から受け取るのが variable、中で組み立てるのが locals。","terms":[["locals","構成内で使う名前付きの値。外部からは指定できない。"],["variable","呼び出し側から渡される入力。"]],"think":"利用者に選ばせたいなら variable、式の途中結果に名前を付けたいだけなら locals。外から上書きできてしまうかどうかで分ける。","snippet":"variable \"env\" {\n  type = string\n}\n\nlocals {\n  # 外から渡す必要のない、組み立てた値\n  name_prefix = \"${var.env}-app\"\n  common_tags = {\n    Environment = var.env\n    ManagedBy   = \"terraform\"\n  }\n}\n\nresource \"aws_s3_bucket\" \"this\" {\n  bucket = \"${local.name_prefix}-bucket\"\n  tags   = local.common_tags\n}","vs":"外から渡すか、中で組み立てるか、が軸。output は呼び出し元へ返す値、data は既存情報の参照で、いずれも中間値の命名には使わない。","opt":["正解。locals は構成内で組み立てた値に名前を付ける。外部からは指定できない。","variable は外から渡される入力。渡す必要がない値に使うと、意図せず上書きされうる。","output は呼び出し元へ値を返す仕組みで、構成内での再利用のためのものではない。","data は外部の既存情報を参照するブロック。中間値の命名には使わない。"]}'),

('terraform-associate-b-q18', '4. 構成(HCL)',
 '変数 var.env が "prod" のときは "t3.large"、それ以外は "t3.micro" を使いたい。式として正しいものはどれか。',
 NULL::text,
 '["var.env == \"prod\" ? \"t3.large\" : \"t3.micro\"","if var.env == \"prod\" then \"t3.large\" else \"t3.micro\"","cond(var.env == \"prod\", \"t3.large\", \"t3.micro\")","switch(var.env) { prod = \"t3.large\", default = \"t3.micro\" }"]',
 0, '[0]', 'single',
 '{"asked":"条件式の構文を知っているか。","why_asked":"HCLには if 文が無く、条件は式として書く。他言語の感覚のまま書こうとすると通らない。宣言的な言語では制御構造ではなく式で分岐するという発想を確かめる設問。","kid":"HCL の分岐は 条件 ? 真 : 偽 の形だけ。","terms":[["条件式","condition ? true_val : false_val の形で値を選ぶ式。"]],"think":"HCLは手続きを書く言語ではないので、文としての if は無い。値を選ぶ式が1種類あるだけ。","snippet":"resource \"aws_instance\" \"web\" {\n  instance_type = var.env == \"prod\" ? \"t3.large\" : \"t3.micro\"\n}\n\n# 3分岐以上は入れ子か lookup で\nlocals {\n  size = lookup(\n    { prod = \"t3.large\", stg = \"t3.small\" },\n    var.env,\n    \"t3.micro\"  # 既定値\n  )\n}","vs":"式として書くか、文として書くか、が軸。HCLには if 文も switch 文も無く、条件式が唯一の分岐。cond という関数も存在しない。","opt":["正解。HCLの条件式は 条件 ? 真の値 : 偽の値 の形をとる。","HCLに if/then/else の文は無い。分岐は式として書く。","cond という組み込み関数は存在しない。","HCLに switch 文は無い。多分岐は入れ子の条件式か lookup で表す。"]}'),

('terraform-associate-b-q19', '4. 構成(HCL)',
 'count で作成した複数の aws_instance について、全インスタンスのIDをリストとして出力したい。式として正しいものはどれか。',
 NULL::text,
 '["aws_instance.web[*].id","aws_instance.web.id[*]","aws_instance.web[all].id","aws_instance.web.*"]',
 0, '[0]', 'single',
 '{"asked":"スプラット式の書き方を理解しているか。","why_asked":"複数リソースからまとめて属性を取る場面は頻出だが、記号の位置を取り違えると通らない。count/for_each で作ったリソースの参照方法を身につけているかを確かめる。","kid":"[*] はリソースの側に付ける。属性の側ではない。","terms":[["スプラット式","リストの各要素から同じ属性を取り出して並べる式。"]],"think":"「web の全部について、その id」と読む。まず全部を指してから属性を取るので、[*] はリソース名の直後。","snippet":"resource \"aws_instance\" \"web\" {\n  count         = 3\n  ami           = var.ami_id\n  instance_type = \"t3.micro\"\n}\n\noutput \"instance_ids\" {\n  # 全インスタンスのIDをリストで\n  value = aws_instance.web[*].id\n}\n\n# for_each の場合は values() でマップから値を取る\n# value = values(aws_instance.web)[*].id","vs":"[*] をどこに置くか、が軸。まず複数を指してから属性を取るので、リソース名の直後に置く。","opt":["正解。リソース名の直後に [*] を置き、その後ろで属性を指定する。","属性の後ろに置くと、単一のidに対してスプラットを適用する形になり成立しない。","[all] という記法は存在しない。","末尾の .* は旧来のスプラットの名残の書き方で、この形では属性を指定できない。"]}'),

('terraform-associate-b-q20', '4. 構成(HCL)',
 'マップ変数から指定したキーの値を取り出し、キーが存在しない場合は既定値を返したい。使う組み込み関数はどれか。',
 NULL::text,
 '["lookup","element","coalesce","merge"]',
 0, '[0]', 'single',
 '{"asked":"マップから既定値つきで値を引く関数を知っているか。","why_asked":"似た名前の関数が多く、対象がリストかマップか、何を返すかで使い分ける。関数名の暗記ではなく、どのデータ構造に何をする関数かを整理できているかが問われる。","kid":"lookup(マップ, キー, 既定値)。キーが無ければ既定値。","terms":[["lookup","マップからキーで値を引き、無ければ既定値を返す。"],["element","リストからインデックスで要素を取る。"],["coalesce","引数を左から見て、最初のnullや空でない値を返す。"]],"think":"引く先がマップか、リストか。既定値が要るか。この2つで関数が決まる。","snippet":"locals {\n  sizes = { prod = \"t3.large\", stg = \"t3.small\" }\n\n  # キーがあればその値、無ければ既定値\n  size = lookup(local.sizes, var.env, \"t3.micro\")\n}","vs":"対象がマップかリストか、が軸。element はリスト向け、coalesce は複数の候補から最初の有効値を選ぶ関数、merge はマップの結合。","opt":["正解。lookup はマップからキーで引き、無ければ第3引数の既定値を返す。","element はリストからインデックスで要素を取る関数。マップのキー引きには使わない。","coalesce は引数を左から見て最初の有効値を返す。キーの存在有無を扱う関数ではない。","merge は複数のマップを1つに結合する関数。値の取り出しには使わない。"]}'),

('terraform-associate-b-q21', '4. 構成(HCL)',
 '外部のテンプレートファイルに変数を埋め込んで文字列を生成し、ユーザーデータとして渡したい。使う組み込み関数はどれか。',
 NULL::text,
 '["templatefile","file","jsonencode","format"]',
 0, '[0]', 'single',
 '{"asked":"templatefile と file の違いを理解しているか。","why_asked":"file は読むだけで置換をしない。両者を取り違えると、テンプレート記法がそのまま文字列として渡り、実行時に初めて気づくことになる。","kid":"file は読むだけ。templatefile は読んで変数を埋める。","terms":[["templatefile","ファイルを読み、渡した変数で置換した文字列を返す。"],["file","ファイルの内容をそのまま文字列として返す。"]],"think":"置換が要るかどうかで分かれる。変数を渡す口があるのが templatefile。","snippet":"resource \"aws_instance\" \"web\" {\n  # テンプレートに変数を埋め込む\n  user_data = templatefile(\"${path.module}/init.sh.tftpl\", {\n    hostname = var.hostname\n    port     = var.port\n  })\n}\n\n# file は読むだけ。置換はされない\n# user_data = file(\"${path.module}/init.sh\")","vs":"置換するかどうか、が軸。file は素の読み込み、jsonencode は値をJSON文字列へ、format は書式文字列の組み立て。","opt":["正解。templatefile はファイルを読み、渡した変数で置換した結果を返す。","file は内容をそのまま返すだけで、テンプレートの置換は行わない。","jsonencode は値をJSON文字列へ変換する関数。ファイルは読まない。","format は書式指定で文字列を組み立てる関数。外部ファイルは扱わない。"]}'),

('terraform-associate-b-q22', '4. 構成(HCL)',
 '下の構成で、security group がインスタンスより先に作成されることを Terraform が知る理由として正しいものはどれか。',
 'resource "aws_security_group" "web" {
  name = "web-sg"
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
}',
 '["インスタンスの引数がsecurity groupの属性を参照しており、依存が暗黙に推論されるため","構成ファイル内での記述順が上から下へ実行されるため","aws_security_group の方がリソース種別として優先度が高いと定められているため","depends_on が省略された場合、アルファベット順に作成されるため"]',
 0, '[0]', 'single',
 '{"asked":"暗黙の依存関係がどう決まるかを理解しているか。","why_asked":"記述順で動くと誤解していると、参照の無いリソース間で順序が保証されると思い込み、実際には並列に作られて失敗する。参照こそが依存の根拠だと分かっているかを問う。","kid":"参照した時点で「先に要る」とTerraformが気づく。","terms":[["暗黙の依存","属性を参照することで自動的に構築される依存関係。"],["依存グラフ","リソース間の依存を表す有向グラフ。順序はここから決まる。"]],"think":"aws_security_group.web.id を使うには、まず security group が存在して id が確定していなければならない。だから参照が順序を決める。","snippet":"# 参照があるので暗黙に順序が決まる\nresource \"aws_instance\" \"web\" {\n  vpc_security_group_ids = [aws_security_group.web.id]\n}\n\n# 参照が無いのに順序を強制したいときだけ depends_on\nresource \"aws_instance\" \"app\" {\n  depends_on = [aws_s3_bucket.assets]\n}","vs":"参照があるか、が軸。記述順もリソース種別もアルファベット順も、Terraformの実行順序を決める根拠にはならない。","opt":["正解。属性を参照した時点で依存グラフに辺が張られ、順序が決まる。","HCLは宣言的で、記述順は実行順を決めない。参照が無ければ並列に作られうる。","リソース種別ごとの優先度という仕組みは存在しない。","アルファベット順で作成されることはない。順序は依存グラフから決まる。"]}'),

('terraform-associate-b-q23', '4. 構成(HCL)',
 '設定変更のたびに置き換えが必要なリソースについて、ダウンタイムを避けるため「新しいものを作ってから古いものを壊す」順序にしたい。使う lifecycle の設定はどれか。',
 NULL::text,
 '["create_before_destroy = true","prevent_destroy = true","ignore_changes = all","replace_triggered_by を指定する"]',
 0, '[0]', 'single',
 '{"asked":"create_before_destroy の用途を理解しているか。","why_asked":"004 で明示的に加わった論点。既定の置き換えは「壊してから作る」順序なので、その間サービスが落ちる。順序を反転できることを知らないと、無停止の要件を設計で満たせない。","kid":"既定は壊してから作る。これを逆にする設定。","terms":[["create_before_destroy","置き換え時に、新しいリソースを作ってから古いものを破棄する。"],["prevent_destroy","そのリソースの破棄計画をエラーにする。"]],"think":"引越しで、新居を借りてから旧居を引き払うか、先に引き払ってから探すか。既定は後者なので、無停止にしたいなら明示的に反転させる。","snippet":"resource \"aws_instance\" \"web\" {\n  ami           = var.ami_id\n  instance_type = \"t3.micro\"\n\n  lifecycle {\n    # 新を作ってから旧を壊す（既定は逆）\n    create_before_destroy = true\n  }\n}","vs":"置き換えの順序を変えるか、置き換えそのものを止めるか、が軸。prevent_destroy は破棄を禁止し、ignore_changes は差分を無視、replace_triggered_by は別リソースを引き金に置き換える。","opt":["正解。置き換え時に新しいものを先に作り、その後で古いものを破棄する。","prevent_destroy は破棄をエラーにする設定。順序を変えるものではない。","ignore_changes は指定した属性の差分を無視する設定で、置き換えの順序には関係しない。","replace_triggered_by は他のリソースの変更を引き金に置き換えを起こす設定。順序の話ではない。"]}'),

('terraform-associate-b-q24', '4. 構成(HCL)',
 '本番データベースについて、誤って破棄されることを構成の側で防ぎたい。使う lifecycle の設定はどれか。',
 NULL::text,
 '["prevent_destroy = true","create_before_destroy = false","ignore_changes = [\"all\"]","depends_on を指定して依存を固定する"]',
 0, '[0]', 'single',
 '{"asked":"prevent_destroy の役割を理解しているか。","why_asked":"lifecycle の各設定は名前が近く、目的が混ざりやすい。破壊的な操作の抑止という重い役割を、どの設定が担うのかを正確に押さえているかを問う。","kid":"破棄の計画が出た時点でエラーにして止める。","terms":[["prevent_destroy","そのリソースを破棄する計画が含まれるとエラーで停止する。"]],"think":"消えて困るものに札を貼っておく。札があると、破棄を含む計画は最後まで進めない。","snippet":"resource \"aws_db_instance\" \"prod\" {\n  identifier = \"prod-db\"\n\n  lifecycle {\n    # 破棄を含む計画はエラーで止まる\n    prevent_destroy = true\n  }\n}\n\n# 意図して消すときは、この設定を外してから destroy する","vs":"破棄を止めるか、順序や差分を制御するか、が軸。create_before_destroy は順序、ignore_changes は差分の無視で、どちらも破棄自体は止めない。","opt":["正解。破棄を含む計画がエラーになるため、誤った destroy を構成側で止められる。","create_before_destroy は置き換えの順序を決める設定。false にしても破棄は止まらない。","ignore_changes は属性の差分を無視する設定で、破棄の抑止はしない。","depends_on は順序を宣言するメタ引数。破棄を防ぐ機能は無い。"]}'),

('terraform-associate-b-q25', '4. 構成(HCL)',
 'オートスケーリングによって外部で変更される desired_capacity について、Terraform が毎回差分として検出し戻そうとするのを避けたい。使う設定はどれか。',
 NULL::text,
 '["lifecycle の ignore_changes に対象の属性を指定する","lifecycle の prevent_destroy を有効にする","対象の属性を variable に切り出して既定値を与える","対象リソースを data ブロックへ書き換える"]',
 0, '[0]', 'single',
 '{"asked":"ignore_changes の用途を理解しているか。","why_asked":"外部の仕組みが正当に変更する属性は現場に必ずある。差分が出るたびに戻していては運用にならない。特定の属性だけ管理から外すという発想を持てているかを問う。","kid":"この属性の差分は見なかったことにする、という指定。","terms":[["ignore_changes","指定した属性について、実態との差分を無視する。"]],"think":"オートスケーラーが台数を動かすのは正常な動作。それをTerraformが毎回戻すと綱引きになるので、その属性だけ見ないようにする。","snippet":"resource \"aws_autoscaling_group\" \"web\" {\n  desired_capacity = 2\n\n  lifecycle {\n    # オートスケーラーが動かす属性は差分を見ない\n    ignore_changes = [desired_capacity]\n  }\n}","vs":"差分を無視するか、他の制御か、が軸。prevent_destroy は破棄の抑止、変数への切り出しは値の出所を変えるだけで差分は出続ける。","opt":["正解。ignore_changes に挙げた属性は、実態と構成が食い違っても差分として扱われない。","prevent_destroy は破棄を止める設定で、属性の差分には関係しない。","変数にしても構成側の値が実態と違えば差分は出る。管理から外すことにはならない。","data へ書き換えると参照専用になり、そのリソースを管理できなくなる。"]}'),

('terraform-associate-b-q26', '4. 構成(HCL)',
 '同じ変数に対して、terraform.tfvars での指定と、コマンドラインの -var での指定が両方ある。どちらが優先されるか。',
 NULL::text,
 '["コマンドラインの -var が優先される","terraform.tfvars が優先される","後から書かれた方が優先される","両方あるとエラーになり、実行が停止する"]',
 0, '[0]', 'single',
 '{"asked":"変数の優先順位を理解しているか。","why_asked":"変数の指定経路が多く、どれが勝つかを知らないと、値が反映されない理由を延々と探すことになる。CIでの上書きにも直結する実務的な知識。","kid":"コマンドラインが一番強い。","terms":[["変数の優先順位","低い順に default → 環境変数 TF_VAR_ → terraform.tfvars → *.auto.tfvars → -var / -var-file。"]],"think":"その場で明示的に指定したものほど強い。既定値が最も弱く、コマンドラインが最も強い。","snippet":"# 優先度: 低 → 高\n# 1. variable の default\n# 2. 環境変数 TF_VAR_name\n# 3. terraform.tfvars / terraform.tfvars.json\n# 4. *.auto.tfvars（ファイル名の辞書順）\n# 5. -var / -var-file（コマンドライン。最優先）\n\nterraform apply -var=\"instance_type=t3.large\"","vs":"どこで指定したか、が軸。その場で明示したものほど優先される。エラーにはならず、静かに上書きされる。","opt":["正解。コマンドラインの -var と -var-file が最も優先度が高い。","tfvars はコマンドラインより弱い。CIから上書きできるのはこの順位のおかげ。","記述順ではなく、指定した経路の種類で優先度が決まる。","重複してもエラーにはならない。優先度の高い方が黙って採用される。"]}'),

('terraform-associate-b-q27', '4. 構成(HCL)',
 'オブジェクト型の変数で、一部の属性を任意にし、指定が無い場合は既定値を使いたい。型定義で用いる仕組みはどれか。',
 NULL::text,
 '["optional() を型の中で使い、既定値を第2引数で与える","nullable = true を変数に指定する","validation ブロックで未指定を許可する","default に部分的なオブジェクトを渡す"]',
 0, '[0]', 'single',
 '{"asked":"オブジェクト型の任意属性の書き方を知っているか。","why_asked":"複合型の変数はモジュールの入口で多用される。任意属性を表現できないと、呼び出し側に全属性の指定を強いることになる。","kid":"optional(型, 既定値) で、その属性だけ省略可能にできる。","terms":[["optional","オブジェクト型の属性を任意にし、既定値を与える型修飾。"],["nullable","変数そのものに null を許すかの設定。"]],"think":"変数全体を任意にするのではなく、オブジェクトの中の一部の属性だけを任意にしたい。だから型の側で表現する。","snippet":"variable \"server\" {\n  type = object({\n    name = string\n    # 省略可能。省略時は 8080\n    port = optional(number, 8080)\n    tags = optional(map(string), {})\n  })\n}\n\n# 呼び出し側は name だけでよい\n# server = { name = \"web\" }","vs":"型の中で表現するか、変数全体に対する設定か、が軸。nullable は変数自体にnullを許すか、validation は値の検査で、どちらも属性ごとの任意化はできない。","opt":["正解。optional(型, 既定値) で属性ごとに任意化と既定値を表現できる。","nullable は変数全体に null を許すかの設定で、オブジェクト内の属性ごとの制御はできない。","validation は値を検査する仕組み。属性を任意にする機能ではない。","default に部分的なオブジェクトを渡しても、型が要求する属性は満たされずエラーになる。"]}'),

('terraform-associate-b-q28', '4. 構成(HCL)',
 '出力値に sensitive = true を設定した。この設定の効果として正しいものはどれか。',
 NULL::text,
 '["CLIの出力では値が隠されるが、stateファイルには平文で保存される","stateファイル内でも値が暗号化されて保存される","出力値がstateに一切保存されなくなる","その出力を他のモジュールから参照できなくなる"]',
 0, '[0]', 'single',
 '{"asked":"sensitive の効果の範囲を理解しているか。","why_asked":"画面に出ないことを安全だと取り違える誤解は根強い。公式のサンプル問題でも真偽形式で問われる論点で、stateの扱いを別途考えられるかどうかに直結する。","kid":"隠れるのは画面だけ。stateには平文で残る。","terms":[["sensitive","CLIの表示やログ上で値を隠す指定。保存形式は変えない。"]],"think":"sensitive は表示の抑制であって暗号化ではない。stateを守りたいなら、保管先の暗号化とアクセス制御を別に用意する。","snippet":"output \"db_password\" {\n  value     = aws_db_instance.main.password\n  sensitive = true  # 画面では隠れる。state には平文で入る\n}\n\n# state 側は別途守る\n# - 暗号化されるバックエンドを使う\n# - state へのアクセス権を絞る","vs":"表示を隠すか、保存を変えるか、が軸。sensitive が効くのは表示だけで、stateの保存形式にも参照可否にも影響しない。","opt":["正解。表示上は隠れるが、stateには平文のまま保存される。","sensitive は暗号化しない。暗号化はバックエンド側の責務。","stateには保存される。保存されなくなるわけではない。","sensitive を付けても参照はできる。参照先でも sensitive として扱われるだけ。"]}'),

-- ── 5. モジュール ──
('terraform-associate-b-q29', '5. モジュール',
 '同じモジュールを、リストで与えた複数の設定それぞれに対して1回ずつ呼び出したい。module ブロックで使える仕組みはどれか。',
 NULL::text,
 '["module ブロックでも count や for_each といったメタ引数を使える","モジュールはメタ引数を受け付けないため、呼び出しを人手で複製する","モジュール内の各リソースに個別に for_each を書いて対応する","for_each はリソース専用のため、module では count のみ使える"]',
 0, '[0]', 'single',
 '{"asked":"モジュールにメタ引数が使えることを知っているか。","why_asked":"メタ引数はリソース専用だと思い込むと、同じ module ブロックを何度も書き写すことになる。モジュールもリソースと同じように繰り返せるという理解を問う。","kid":"module にも count / for_each が使える。","terms":[["メタ引数","count / for_each / depends_on / providers など、ブロック共通の引数。"]],"think":"モジュールは複数リソースをまとめた単位。呼び出し自体を繰り返せるので、リソースと同じ感覚で for_each を当てればよい。","snippet":"module \"vpc\" {\n  source   = \"./modules/vpc\"\n  for_each = var.vpc_configs   # map(object)\n\n  name = each.key\n  cidr = each.value.cidr\n}\n\n# 参照はキー付きで\n# module.vpc[\"prod\"].vpc_id","vs":"モジュールにもメタ引数が効くか、が軸。count も for_each も module ブロックで使え、片方だけということもない。","opt":["正解。module ブロックでも count と for_each を使い、呼び出しを繰り返せる。","メタ引数は使えるので、人手での複製は不要。","内側に書くとモジュール全体の繰り返しにはならず、呼び出し単位で分けたい要件を満たせない。","for_each はモジュールでも使える。count のみという制限は無い。"]}'),

('terraform-associate-b-q30', '5. モジュール',
 'aliasを付けた複数のプロバイダ構成のうち、特定のものを子モジュールに使わせたい。module ブロックで指定するメタ引数はどれか。',
 NULL::text,
 '["providers","provider","alias","depends_on"]',
 0, '[0]', 'single',
 '{"asked":"モジュールへのプロバイダの渡し方を知っているか。","why_asked":"モジュールは既定で親のプロバイダを継承するため、明示的に渡す場面を知らないとマルチリージョン構成で詰まる。単数形と複数形の違いという細部も同時に問われる。","kid":"module には providers（複数形）でマップとして渡す。","terms":[["providers","モジュール内のプロバイダ名と、親の構成との対応を渡すメタ引数。"]],"think":"モジュールの中では aws という名前で使いたいが、実体は親の aws.tokyo。その対応表を渡すのが providers。","snippet":"provider \"aws\" {\n  region = \"us-east-1\"\n}\n\nprovider \"aws\" {\n  alias  = \"tokyo\"\n  region = \"ap-northeast-1\"\n}\n\nmodule \"tokyo_vpc\" {\n  source = \"./modules/vpc\"\n\n  # 子の aws に、親の aws.tokyo を割り当てる\n  providers = {\n    aws = aws.tokyo\n  }\n}","vs":"単数形か複数形か、が軸。resource で使うのは provider（単数）、module で使うのは providers（複数）でマップを渡す。","opt":["正解。providers にマップを渡し、子モジュール内の名前と親の構成を対応づける。","provider（単数）は resource ブロックで使う引数。module では使わない。","alias は provider ブロック側で別名を定義する引数。module ブロックの引数ではない。","depends_on は順序を宣言するメタ引数で、プロバイダの割り当てはできない。"]}'),

('terraform-associate-b-q31', '5. モジュール',
 'Gitリポジトリのタグ v1.2.0 を指定してモジュールを取得したい。source の書き方として正しいものはどれか。',
 NULL::text,
 '["git::https://example.com/vpc.git?ref=v1.2.0","git::https://example.com/vpc.git と version = \"v1.2.0\"","https://example.com/vpc.git@v1.2.0","registry://example.com/vpc?tag=v1.2.0"]',
 0, '[0]', 'single',
 '{"asked":"Gitソースでの版指定の書き方を知っているか。","why_asked":"レジストリでは version 引数を使うため、Gitでも同じだと思い込みやすい。ソースの種類ごとに固定の手段が変わるという点は、Set A でも角度を変えて問われる頻出の落とし穴。","kid":"Git は source の中に ?ref= で書く。version 引数は効かない。","terms":[["ref","Gitソースでタグ・ブランチ・コミットを指定するクエリ引数。"]],"think":"version 引数はレジストリ専用。Gitはリポジトリの中のどこを指すかを自分で書く必要があるので、URLのクエリで指定する。","snippet":"# ○ Git は source に ?ref= を付ける\nmodule \"vpc\" {\n  source = \"git::https://example.com/vpc.git?ref=v1.2.0\"\n}\n\n# ○ レジストリなら version 引数が使える\nmodule \"vpc_registry\" {\n  source  = \"terraform-aws-modules/vpc/aws\"\n  version = \"~> 5.0\"\n}","vs":"版をどこに書くか、が軸。レジストリは version 引数、Git は source のクエリ。混ぜても効かない。","opt":["正解。Gitソースでは ?ref= にタグ・ブランチ・コミットを指定する。","version 引数はレジストリ由来のモジュール専用で、Gitソースでは効かない。","@ でリビジョンを指定する記法はTerraformのモジュールソースには無い。","registry:// というスキームは存在しない。"]}'),

('terraform-associate-b-q32', '5. モジュール',
 '子モジュールが output "vpc_id" を定義している。親モジュールからこの値を参照する式として正しいものはどれか。',
 NULL::text,
 '["module.network.vpc_id","module.network.output.vpc_id","var.network.vpc_id","local.network.vpc_id"]',
 0, '[0]', 'single',
 '{"asked":"モジュール出力の参照式を知っているか。","why_asked":"出力の参照は日常的に書くが、output という語を式に含めてしまう誤りは起きやすい。モジュールの境界をまたぐ値の流れを正しく表現できるかを確かめる。","kid":"module.<呼び出し名>.<出力名> で参照する。","terms":[["module出力の参照","module.NAME.OUTPUT の形で、子の output を親から読む。"]],"think":"子モジュールは output で外向きの口を開けている。親はその口の名前を直接指すので、間に output という語は要らない。","snippet":"# 子: modules/network/outputs.tf\noutput \"vpc_id\" {\n  value = aws_vpc.this.id\n}\n\n# 親\nmodule \"network\" {\n  source = \"./modules/network\"\n}\n\nresource \"aws_subnet\" \"a\" {\n  vpc_id = module.network.vpc_id\n}","vs":"何を経由して参照するか、が軸。module.<名前>.<出力名> で直接指す。間に output は挟まず、var や local でもない。","opt":["正解。module.<呼び出し名>.<出力名> の形で参照する。","式に output という語は含めない。","var は自分に渡された入力変数を指す。子の出力の参照には使わない。","local は自分の locals を指す。子モジュールの出力とは別。"]}'),

('terraform-associate-b-q33', '5. モジュール',
 'モジュール内で宣言した変数に、呼び出し側から値を渡さなかった。既定値も定義されていない場合の挙動はどれか。',
 NULL::text,
 '["適用時に値の入力を求められ、非対話環境ではエラーになる","null が渡されたものとして扱われ、処理が続行する","親モジュールの同名の変数の値が自動的に継承される","空文字列が既定値として補われ、警告が表示される"]',
 0, '[0]', 'single',
 '{"asked":"既定値の無い変数の挙動を理解しているか。","why_asked":"変数のスコープが独立していることと、既定値が無い変数は必須になることの両方を確かめる設問。親から自動継承されると誤解していると、渡し忘れに気づけない。","kid":"既定値の無い変数は必須。渡さなければ聞かれる。","terms":[["必須変数","default が無い変数。値の指定が無ければ入力を求められる。"]],"think":"モジュールの変数は外から明示的に渡す入口。既定値が無いということは「必ず指定してほしい」という宣言なので、無ければ止まる。","vs":"必須になるか、暗黙に補われるか、が軸。変数のスコープはモジュールごとに独立しており、親から自動で継承されることはない。","opt":["正解。既定値が無い変数は必須で、値が無ければ入力を求められる。CIなど非対話環境ではエラーになる。","null が自動で入ることはない。null を許したいなら明示的に default = null と書く。","変数は自動継承されない。親から明示的に渡す必要がある。","空文字列が補われることはない。型が string でも同じ。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'terraform-associate-b'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
