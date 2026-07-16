-- Terraform Associate (004) Set B — 問題 34〜50（6. State管理 / 7. インフラ保守 / 8. HCP Terraform）/ 2026-07-16
-- 公式 Exam Content List の 6a〜6d、7a〜7c、8a〜8d に対応。
-- Set A が扱っていない ローカルバックエンド・部分設定・terraform_remote_state・state CLI・
-- force-unlock・CLIワークスペース・Sentinel/OPA・動的プロバイダ認証情報を配置する。
BEGIN;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

-- ── 6. State管理 ──
('terraform-associate-b-q34', '6. State管理',
 'backendブロックを一切書かずに terraform apply を実行した。stateはどう扱われるか。',
 NULL::text,
 '["ローカルバックエンドが既定で使われ、作業ディレクトリの terraform.tfstate に保存される","バックエンド未設定のエラーとなり、実行が中断される","stateは作られず、毎回実インフラを走査して差分が計算される","メモリ上にのみ保持され、プロセス終了時に破棄される"]',
 0, '[0]', 'single',
 '{"asked":"既定のバックエンドを理解しているか。","why_asked":"リモートバックエンドの設定ばかりが話題になるため、既定が何かを意識しないまま使っている人が多い。ローカルに平文で置かれている事実を認識できているかは、機密の扱いにも直結する。","kid":"何も書かなければ、手元の terraform.tfstate に保存される。","terms":[["ローカルバックエンド","既定のバックエンド。作業ディレクトリのファイルにstateを保存する。"]],"think":"設定が無いからstateが無いのではなく、既定のローカルバックエンドが黙って使われている。だから手元にファイルができる。","snippet":"# backend を書かない場合の既定\n# ./terraform.tfstate         現在の state\n# ./terraform.tfstate.backup  直前の state\n\n# 明示的に書くこともできる\nterraform {\n  backend \"local\" {\n    path = \"custom.tfstate\"\n  }\n}","vs":"既定があるか、無いとエラーか、が軸。ローカルバックエンドが既定で使われるため、設定が無くても動く。stateは必ず作られる。","opt":["正解。ローカルバックエンドが既定で使われ、作業ディレクトリにstateファイルが作られる。","バックエンドの指定は必須ではない。書かなければローカルが使われる。","stateは作られる。Terraformは管理下リソースの識別にstateを必要とする。","ファイルとして永続化される。メモリ上だけということはない。"]}'),

('terraform-associate-b-q35', '6. State管理',
 'バックエンドの設定のうち、バケット名は構成に書き、環境ごとに異なるキーは実行時に与えたい。使う仕組みはどれか。',
 NULL::text,
 '["backendブロックに一部だけ書き、残りを init -backend-config で与える","backendブロック内で var を参照し、変数として渡す","環境ごとにbackendブロックを分けて書き、実行時に選択する","backendブロックをローカルにしてから、apply後に手動で移行する"]',
 0, '[0]', 'single',
 '{"asked":"バックエンドの部分設定を知っているか。","why_asked":"backendブロックでは変数も参照も使えないという制約が、環境ごとの切り替えで必ず壁になる。その回避手段が用意されていることを知っているかが問われる。","kid":"backendには変数を書けない。足りない分は init のときに渡す。","terms":[["部分設定","backendブロックに一部だけ書き、残りを -backend-config で補う方式。"]],"think":"backendはinitの最初に読まれるため、変数の評価より前に決まっていなければならない。だから変数が使えず、代わりにinitへ直接渡す口がある。","snippet":"# 構成側は共通部分だけ\nterraform {\n  backend \"s3\" {\n    bucket = \"my-tfstate\"\n    region = \"us-east-1\"\n    # key はここに書かない\n  }\n}\n\n# 環境ごとに実行時へ渡す\nterraform init -backend-config=\"key=prod/terraform.tfstate\"\n# あるいはファイルで\nterraform init -backend-config=prod.backend.hcl","vs":"initへ渡すか、構成内で解決するか、が軸。backendブロックでは変数も式も使えないため、構成内での切り替えはできない。","opt":["正解。部分設定として一部だけ書き、残りを init の -backend-config で与える。","backendブロックでは変数や参照は使えない。initより前に確定している必要がある。","backendブロックは1つしか書けず、実行時に選ぶ仕組みも無い。","ローカルで作ってから手で移すのは事故のもと。正規の手段が用意されている。"]}'),

('terraform-associate-b-q36', '6. State管理',
 'ローカルバックエンドからS3バックエンドへ切り替えるため構成を書き換えた。既存のstateを新しいバックエンドへ移したい。実行するコマンドはどれか。',
 NULL::text,
 '["terraform init -migrate-state","terraform init -reconfigure","terraform state push","terraform refresh"]',
 0, '[0]', 'single',
 '{"asked":"バックエンド移行時のフラグを区別できるか。","why_asked":"-migrate-state と -reconfigure は名前が近く、取り違えると既存のstateを引き継がないまま新しいバックエンドが初期化される。事故に直結する区別。","kid":"移すなら -migrate-state。-reconfigure は捨てて作り直す。","terms":[["-migrate-state","既存のstateを新しいバックエンドへ移行する。"],["-reconfigure","既存のstateを引き継がず、バックエンド設定を初期化し直す。"]],"think":"引越しで荷物も運ぶのが -migrate-state、住所だけ変えて荷物は置いていくのが -reconfigure。","snippet":"# 既存stateを新バックエンドへ移す（確認を求められる）\nterraform init -migrate-state\n\n# 引き継がずに設定だけ入れ替える\nterraform init -reconfigure","vs":"stateを引き継ぐか、捨てるか、が軸。名前は近いが結果は正反対で、-reconfigure では既存のstateは移らない。","opt":["正解。既存のstateを新しいバックエンドへ移行する。実行時に確認を求められる。","-reconfigure はstateを引き継がずに設定を初期化し直す。移行の目的では使わない。","state push は手元のstateファイルを強制的に書き込むコマンド。バックエンド移行の正規手段ではない。","refresh はstateを実態へ合わせるコマンドで、保存先の変更とは無関係。"]}'),

('terraform-associate-b-q37', '6. State管理',
 '別の構成(別state)で作成されたVPCのIDを、こちらの構成から読み取りたい。使う仕組みはどれか。',
 NULL::text,
 '["terraform_remote_state データソースで相手のstateを参照する","相手のstateファイルを file() で読み込んでJSONとして解析する","terraform state pull の結果を variable の既定値へ貼り付ける","相手の構成をモジュールとして source に指定して呼び出す"]',
 0, '[0]', 'single',
 '{"asked":"別stateの値を参照する正規の手段を知っているか。","why_asked":"構成を分割すると必ず出てくる要求。正規の仕組みを知らないと、値の手写しやstateの直接読み込みといった壊れやすい方法へ流れる。","kid":"相手が output に出した値だけを、専用のデータソースで読む。","terms":[["terraform_remote_state","別のstateのoutput値を読み取るデータソース。"]],"think":"相手のstate全体を覗くのではなく、相手がoutputとして公開した値だけを受け取る。だから相手側にoutputの定義が要る。","snippet":"# 相手側（network構成）\noutput \"vpc_id\" {\n  value = aws_vpc.this.id\n}\n\n# こちら側\ndata \"terraform_remote_state\" \"network\" {\n  backend = \"s3\"\n  config = {\n    bucket = \"my-tfstate\"\n    key    = \"network/terraform.tfstate\"\n    region = \"us-east-1\"\n  }\n}\n\nresource \"aws_subnet\" \"a\" {\n  vpc_id = data.terraform_remote_state.network.outputs.vpc_id\n}","vs":"公開されたoutputを読むか、stateを直接触るか、が軸。stateの内部構造は実装詳細で、直接読むのは壊れやすい。","opt":["正解。相手がoutputとして公開した値を、専用のデータソース経由で読み取る。","stateの内部構造は実装詳細で、直接解析すると版の変更で壊れる。","手で貼り付けた値は相手の変更に追随しない。自動化の意味が失われる。","モジュールとして呼ぶと、相手のリソースをこちらのstateでも作ろうとして二重管理になる。"]}'),

('terraform-associate-b-q38', '6. State管理',
 'あるリソースを実インフラは残したままTerraformの管理から外したい。CLIで行う場合のコマンドはどれか。',
 NULL::text,
 '["terraform state rm","terraform destroy -target","terraform state mv","terraform untaint"]',
 0, '[0]', 'single',
 '{"asked":"state rm の役割を理解しているか。","why_asked":"「管理から外す」と「削除する」を混同すると、実インフラを消してしまう。state操作は取り返しがつかないことも多く、コマンドの効果範囲の理解が直接事故に効く。","kid":"state rm は台帳から消すだけ。実物は残る。","terms":[["terraform state rm","stateから項目を取り除く。実リソースは削除しない。"],["terraform state mv","state内でアドレスを移動する。"]],"think":"stateは対応表。そこから行を消せばTerraformは見失うだけで、実物には手を触れない。消すのは destroy。","snippet":"# 管理から外す（実リソースは残る）\nterraform state rm aws_instance.web\n\n# 宣言的にやるなら removed ブロック（1.7+）\n# removed {\n#   from = aws_instance.web\n#   lifecycle { destroy = false }\n# }","vs":"台帳から外すか、実物を消すか、が軸。destroy は実リソースを削除し、state mv はアドレスの移動、untaint は再作成マークの解除。","opt":["正解。stateから取り除くだけで、実リソースはそのまま残る。","destroy は実リソースを削除する。残したいという要件に反する。","state mv は同じstate内や別state間でアドレスを移す操作。管理から外すものではない。","untaint は再作成マークを外すコマンドで、管理からは外れない。"]}'),

('terraform-associate-b-q39', '6. State管理',
 'apply の実行中にネットワークが切れ、stateロックが残ったまま解放されなくなった。次の実行を可能にするための正規の手段はどれか。',
 NULL::text,
 '["terraform force-unlock にロックIDを渡して解除する","terraform init -reconfigure でバックエンドを初期化し直す","-lock=false を付けて以降の実行を続ける","stateファイルを手元へダウンロードして再アップロードする"]',
 0, '[0]', 'single',
 '{"asked":"残留ロックの正規の解除方法を知っているか。","why_asked":"ロックが残る事故は現実に起きる。正規の手段を知らないと、-lock=false という危険な回避へ流れ、同時実行によるstate破損を招く。","kid":"エラーに出るロックIDを force-unlock に渡す。","terms":[["force-unlock","残留したstateロックを、IDを指定して解除するコマンド。"]],"think":"ロックはstateを守る仕組み。壊れたときは正しく外すのであって、無効化して素通りするのは守りを捨てること。","snippet":"# エラーに表示された Lock ID を渡す\nterraform force-unlock 1a2b3c4d-5678-90ab-cdef-1234567890ab\n\n# 他に実行中の人がいないことを必ず確かめてから","vs":"ロックを正しく外すか、迂回するか、が軸。-lock=false は守り自体を無効にする回避で、同時実行の危険を残す。","opt":["正解。エラーに表示されるロックIDを force-unlock に渡して解除する。","-reconfigure はバックエンド設定の初期化で、残留ロックは解除されない。","-lock=false は以降ロックを取らなくなる指定。他の実行と衝突してstateが壊れうる。","手作業での入れ替えは競合と破損の危険が高い。正規のコマンドがある。"]}'),

('terraform-associate-b-q40', '6. State管理',
 'stateファイルの機密性について正しいものはどれか。',
 NULL::text,
 '["変数に sensitive を付けていても、値は平文でstateに含まれうる","sensitive を付けた値はstate内でハッシュ化されて保存される","stateは常に暗号化されるため、保管先の設定は不要である","機密値はstateには入らず、実行時にのみ扱われる"]',
 0, '[0]', 'single',
 '{"asked":"stateに機密が平文で入ることを理解しているか。","why_asked":"公式のサンプル問題でも真偽形式で問われる論点。stateを守る責任がバックエンド側にあることを認識していないと、S3を公開設定のまま置くような事故につながる。","kid":"stateには機密が平文で入る。守るのは保管先の役目。","terms":[["state内の機密","DBのパスワードなど、リソースの属性としてstateに記録される値。"]],"think":"Terraformは属性をそのままstateに書き込む。表示を隠す機能はあっても、保存の形式は変えない。だから保管先を暗号化しアクセスを絞る。","snippet":"# state を守るのはバックエンド側\nterraform {\n  backend \"s3\" {\n    bucket  = \"my-tfstate\"\n    key     = \"prod/terraform.tfstate\"\n    encrypt = true          # 保存時の暗号化\n  }\n}\n# あわせてバケットのアクセス権限を絞る","vs":"表示を隠すことと、保存を守ることは別。sensitive は前者にしか効かず、後者はバックエンドの設定とアクセス制御で担う。","opt":["正解。sensitive は表示を隠すだけで、値は平文のままstateに含まれうる。","ハッシュ化はされない。値はそのまま記録される。","暗号化は自動ではない。バックエンドごとに設定して初めて効く。","機密値は属性としてstateに保存される。実行時だけということはない。"]}'),

-- ── 7. インフラ保守 ──
('terraform-associate-b-q41', '7. インフラ保守',
 '同じ構成でdevとprodのstateを分けたい。CLIのワークスペース機能について正しいものはどれか。',
 NULL::text,
 '["ワークスペースごとに別のstateを持ち、構成内では terraform.workspace で名前を参照できる","ワークスペースごとに別のバックエンドを設定でき、保管先そのものを分けられる","ワークスペースを切り替えると、構成ファイルも自動的に対応するものへ切り替わる","ワークスペースはHCP Terraform専用の機能で、CLI単体では使えない"]',
 0, '[0]', 'single',
 '{"asked":"CLIワークスペースの実体を理解しているか。","why_asked":"HCP Terraformのワークスペースと名前が同じで別物なうえ、環境分離の手段として過信されやすい。分かれるのはstateだけで、構成もバックエンドも共通という制約を知っているかが問われる。","kid":"分かれるのはstateだけ。構成もバックエンドも同じ。","terms":[["CLIワークスペース","同一バックエンド内で複数のstateを切り替える仕組み。"],["terraform.workspace","現在のワークスペース名を返す式。"]],"think":"1つのバックエンドの中に、名前付きのstateが複数ある状態。構成は共通なので、差は変数と terraform.workspace で表現する。","snippet":"terraform workspace new dev\nterraform workspace select dev\nterraform workspace list\n\n# 構成側で現在の名前を参照できる\nlocals {\n  instance_type = terraform.workspace == \"prod\" ? \"t3.large\" : \"t3.micro\"\n}","vs":"何が分かれるか、が軸。分かれるのはstateだけで、構成ファイルもバックエンドも共通。HCP側のワークスペースとは同名の別物。","opt":["正解。stateがワークスペースごとに分かれ、構成内では terraform.workspace で名前を参照できる。","バックエンドは共通。同じ保管先の中でstateが分かれるだけ。","構成ファイルは切り替わらない。同じ構成を共有する。","CLI単体で使える。HCP Terraformのワークスペースは同名の別概念。"]}'),

('terraform-associate-b-q42', '7. インフラ保守',
 'リソース間の依存関係を図として書き出し、構成の全体像を確認したい。使うコマンドはどれか。',
 NULL::text,
 '["terraform graph","terraform show","terraform plan -out","terraform providers"]',
 0, '[0]', 'single',
 '{"asked":"terraform graph の用途を知っているか。","why_asked":"依存グラフはTerraformの中核だが、それを可視化するコマンドの存在は見落とされやすい。似た情報を出すコマンドとの守備範囲の違いを問う設問。","kid":"graph は依存関係を DOT 形式で吐く。","terms":[["terraform graph","依存グラフを DOT 形式で出力するコマンド。"]],"think":"順序が思ったとおりにならないとき、Terraformがどう依存を捉えているかを見たい。そのための出力口。","snippet":"# DOT 形式で出力し、画像へ変換する\nterraform graph | dot -Tsvg > graph.svg","vs":"依存の構造を出すか、状態や計画を出すか、が軸。show は state や plan の中身、plan -out は計画の保存、providers は依存プロバイダの一覧。","opt":["正解。依存グラフを DOT 形式で出力でき、可視化ツールへ渡せる。","show は state や plan の内容を表示するコマンドで、依存の図は出さない。","plan -out は計画をファイルへ保存するもの。図の生成ではない。","providers はプロバイダ依存の一覧で、リソース間の依存は示さない。"]}'),

('terraform-associate-b-q43', '7. インフラ保守',
 '保存した実行計画ファイルの内容を、機械的に解析できる形で確認したい。使うコマンドはどれか。',
 NULL::text,
 '["terraform show -json tfplan","terraform plan -json","terraform state show tfplan","terraform output -json"]',
 0, '[0]', 'single',
 '{"asked":"保存済み計画の検査方法を知っているか。","why_asked":"CIでポリシーチェックを挟む場面で必要になる。計画をJSONで読み出せることを知らないと、人向けの表示を切り出す脆い実装に走る。","kid":"保存した計画は show -json で読める。","terms":[["terraform show -json","stateまたは保存済み計画をJSONで出力する。"]],"think":"計画ファイルはバイナリなので直接は読めない。JSONへ変換する口が用意されており、そこから機械的に検査する。","snippet":"terraform plan -out=tfplan\n\n# 保存した計画をJSONで読み出す\nterraform show -json tfplan | jq \".resource_changes[].change.actions\"","vs":"保存済みの計画を読むか、その場で作るか、が軸。plan -json は今から計画を作って流す形で、保存済みファイルの検査ではない。","opt":["正解。保存済みの計画ファイルをJSONへ変換して読み出せる。","plan -json はその場で計画を作りながらJSONを流すもの。保存済みファイルの検査には使わない。","state show は state 内のリソースを見るコマンドで、計画ファイルは扱えない。","output は出力値を取るコマンド。計画の中身は見られない。"]}'),

('terraform-associate-b-q44', '7. インフラ保守',
 'TF_LOG に設定できるログレベルのうち、最も詳細な情報が出力されるものはどれか。',
 NULL::text,
 '["TRACE","DEBUG","INFO","VERBOSE"]',
 0, '[0]', 'single',
 '{"asked":"ログレベルの序列を知っているか。","why_asked":"障害の切り分けでプロバイダとのやりとりまで見たい場面は必ず来る。レベルの序列と、存在しない値を区別できるかを問う。","kid":"TRACE が最も詳細。","terms":[["TF_LOG","ログレベルを指定する環境変数。TRACE / DEBUG / INFO / WARN / ERROR。"]],"think":"詳細な順に TRACE > DEBUG > INFO > WARN > ERROR。最も細かく見たいなら一番上を指定する。","snippet":"export TF_LOG=TRACE\nexport TF_LOG_PATH=./terraform.log\nterraform apply","vs":"実在するレベルか、が軸。指定できるのは TRACE / DEBUG / INFO / WARN / ERROR の5つで、VERBOSE は含まれない。","opt":["正解。TRACE が最も詳細で、プロバイダとのやりとりまで出力される。","DEBUG は TRACE の次に詳細だが、最も詳細ではない。","INFO は概要レベルで、切り分けには情報が足りないことが多い。","VERBOSE というレベルは存在しない。"]}'),

('terraform-associate-b-q45', '7. インフラ保守',
 'importブロックを使わずCLIで既存リソースを取り込む場合、事前に必要な作業はどれか。',
 NULL::text,
 '["取り込み先のリソースブロックを構成にあらかじめ記述しておく","取り込み対象のリソースにタグを付けて識別できるようにしておく","stateファイルを空にしてから init をやり直しておく","対象リソースをいったん停止し、変更が入らない状態にしておく"]',
 0, '[0]', 'single',
 '{"asked":"CLIでのimportの前提を理解しているか。","why_asked":"importはstateへ登録するだけで構成は書いてくれない。この前提を知らないと、取り込んだ直後のplanで削除計画が出て慌てることになる。importブロックとの違いも同時に問われる。","kid":"CLIのimportはstateに登録するだけ。器は自分で書く。","terms":[["terraform import","既存リソースをstateへ登録するコマンド。構成は生成しない。"],["importブロック","1.5以降の宣言的な取り込み。設定の自動生成にも対応する。"]],"think":"importは対応表に行を足す操作。構成側に受け皿が無いと、stateにあって構成に無い＝削除対象という扱いになる。","snippet":"# 1. 受け皿を先に書く\nresource \"aws_instance\" \"web\" {\n  # 属性は後から埋める\n}\n\n# 2. state へ登録\nterraform import aws_instance.web i-0123456789abcdef0\n\n# 3. plan の差分を見ながら属性を合わせる\n\n# 1.5+ なら import ブロックで宣言的に。設定生成もできる\n# terraform plan -generate-config-out=generated.tf","vs":"構成が先に要るか、が軸。CLIのimportはstateへ登録するだけで、構成は生成しない。importブロックなら設定の生成まで頼める。","opt":["正解。受け皿となるリソースブロックが無いと、取り込んだ直後に削除計画として現れる。","タグは識別の助けにはなるが、importの前提条件ではない。指定するのはリソースID。","stateを空にする必要は無い。既存のstateへ追加する操作。","対象の停止は不要。importは実リソースに変更を加えない。"]}'),

('terraform-associate-b-q46', '7. インフラ保守',
 'プロビジョナー(local-exec / remote-exec)の位置づけとして、公式に示されている考え方はどれか。',
 NULL::text,
 '["他に手段が無いときの最後の手段であり、可能ならプロバイダの機能で実現する","構成管理の標準的な手段であり、OS設定は積極的にプロビジョナーで書くべきである","宣言的に動作するため、リソース定義と同じ感覚で安全に多用できる","stateに実行結果が記録されるため、再実行時の冪等性が保証される"]',
 0, '[0]', 'single',
 '{"asked":"プロビジョナーの位置づけを理解しているか。","why_asked":"手軽なので多用されがちだが、HashiCorp自身が最後の手段と明記している。宣言的な世界に手続きを持ち込む行為であり、その代償を理解しているかを問う。","kid":"プロビジョナーは最後の手段。まず他の方法を探す。","terms":[["プロビジョナー","リソース作成時などに任意のコマンドを実行する仕組み。"]],"think":"プロビジョナーの中身はTerraformには理解できない任意のコマンド。差分も計画も出せないので、宣言的な利点が失われる。","snippet":"# 最後の手段。まず代替を検討する\n# - クラウド側の user_data / メタデータ\n# - 専用のプロバイダやリソース\n# - イメージの事前作成\n\nresource \"aws_instance\" \"web\" {\n  # 可能ならこちらで済ませる\n  user_data = templatefile(\"init.sh.tftpl\", {})\n}","vs":"最後の手段か、標準的な手段か、が軸。中身が任意のコマンドである以上、Terraformは差分を計算できず冪等性も保証できない。","opt":["正解。公式は最後の手段と位置づけており、まず他の方法を検討するよう求めている。","OS設定は構成管理ツールやイメージの事前作成で扱うのが定石。プロビジョナーの積極利用は推奨されない。","プロビジョナーは手続き的で、Terraformは中身を理解できない。多用すると宣言的な利点が崩れる。","stateに実行結果は記録されず、冪等性も保証されない。冪等にする責任は書いた側にある。"]}'),

-- ── 8. HCP Terraform ──
('terraform-associate-b-q47', '8. HCP Terraform',
 'HCP Terraformでリモート実行を使いつつ、実行の起動と計画の確認は手元のCLIから行いたい。該当するワークフローはどれか。',
 NULL::text,
 '["CLI駆動ワークフロー","VCS駆動ワークフロー","APIワークフロー","エージェント経由ワークフロー"]',
 0, '[0]', 'single',
 '{"asked":"HCP Terraformの3つのワークフローを区別できるか。","why_asked":"起動の起点がどこかで呼び名が変わる。取り違えると、VCS連携が必須だと思い込んで移行の設計を誤る。","kid":"手元から terraform apply を打つが、実行はHCP側で走る形。","terms":[["CLI駆動","cloudブロックを設定し、手元のCLIから起動してHCP上で実行する方式。"],["VCS駆動","リポジトリへのpushを引き金にHCP側が実行する方式。"]],"think":"起動の起点で分ける。手元のCLIならCLI駆動、リポジトリのpushならVCS駆動、プログラムからならAPI。","snippet":"terraform {\n  cloud {\n    organization = \"my-org\"\n    workspaces {\n      name = \"prod\"\n    }\n  }\n}\n\n# 手元から起動するが、実行はHCP側で走る\n# terraform apply","vs":"起動の起点がどこか、が軸。CLIか、リポジトリへのpushか、APIか。エージェントは実行の到達手段で、ワークフローの区分ではない。","opt":["正解。cloudブロックを設定し、手元のCLIから起動してHCP上で実行する方式。","VCS駆動はリポジトリへのpushが起点。手元からの起動ではない。","APIワークフローはプログラムからの起動を指す。CLIからの起動とは別。","エージェントは私設環境へ到達するための仕組みで、ワークフローの分類ではない。"]}'),

('terraform-associate-b-q48', '8. HCP Terraform',
 '「本番では特定のタグが必須」といった組織の規則を、applyの前に自動で強制したい。HCP Terraformで使う機能はどれか。',
 NULL::text,
 '["Sentinel または OPA によるポリシー適用","変数セットで必須の変数を全ワークスペースへ配布する","run triggers で後続ワークスペースの実行を連鎖させる","ワークスペースのアクセス権限をチーム単位で絞る"]',
 0, '[0]', 'single',
 '{"asked":"HCPのポリシー適用の仕組みを知っているか。","why_asked":"統制を人のレビューに任せるか、仕組みで強制するかは組織の分かれ目。ポリシーの適用点がplanとapplyの間にあることを理解しているかが問われる。","kid":"planの結果を機械が審査して、通らなければapplyさせない。","terms":[["Sentinel","HashiCorpのポリシーとしてのコードの仕組み。"],["OPA","Open Policy Agent。HCP Terraformでも利用できる。"]],"think":"planの出力を審査対象にすれば、適用の前に規則違反を止められる。人のレビューに頼らず機械的に効かせる形。","vs":"適用前に機械が止めるか、別の統制か、が軸。変数セットは値の配布、run triggers は実行の連鎖、権限はアクセス制御で、いずれも構成の中身は審査しない。","opt":["正解。planの結果をポリシーで審査し、違反していればapplyへ進ませない。","変数セットは共通の値を配る仕組み。タグが付いているかどうかの審査はしない。","run triggers はワークスペース間で実行を連鎖させる機能。規則の強制とは別。","権限の制御は誰が操作できるかの話で、構成の中身が規則に沿うかは見ない。"]}'),

('terraform-associate-b-q49', '8. HCP Terraform',
 'HCP Terraformからクラウドへ接続する際、長期のアクセスキーをワークスペースへ保存せずに済ませたい。使う仕組みはどれか。',
 NULL::text,
 '["動的プロバイダ認証情報を構成し、実行ごとに短命な資格情報を得る","環境変数としてアクセスキーを登録し、機密扱いにして隠す","変数セットにアクセスキーをまとめ、全ワークスペースへ配布する","エージェントを私設環境に置き、そこの認証情報を使わせる"]',
 0, '[0]', 'single',
 '{"asked":"動的プロバイダ認証情報の目的を理解しているか。","why_asked":"004で明示された論点。長期キーは漏れれば失効まで使われ続けるため、そもそも保存しない構成へ寄せるのが現在の推奨。隠すことと持たないことの違いを問う。","kid":"キーを預けるのではなく、実行のたびに短命な資格情報を借りる。","terms":[["動的プロバイダ認証情報","OIDC等でクラウドと信頼関係を結び、実行ごとに短命な資格情報を得る仕組み。"]],"think":"隠しても、保存されている限りいつか漏れる。実行のたびに借りて捨てる形にすれば、盗まれる対象そのものが無くなる。","vs":"長期の資格情報を持つか、持たないか、が軸。機密扱いも配布先の工夫も、保存していること自体は変わらない。","opt":["正解。クラウドと信頼関係を結び、実行ごとに短命な資格情報を得るため、長期キーを保存せずに済む。","機密扱いは表示を隠すだけ。長期キーを保存している事実は変わらない。","変数セットでの配布は、むしろ同じ長期キーが多くのワークスペースへ広がる。","エージェントは到達手段。認証情報の寿命の問題は解決しない。"]}'),

('terraform-associate-b-q50', '8. HCP Terraform',
 '複数のワークスペースを、担当チームや製品の単位でまとめ、権限もその単位で扱いたい。HCP Terraformの機能はどれか。',
 NULL::text,
 '["プロジェクト","変数セット","run triggers","ワークスペースのタグ"]',
 0, '[0]', 'single',
 '{"asked":"プロジェクトの役割を理解しているか。","why_asked":"004で追加された論点。ワークスペースが増えると一覧が破綻するため、束ねる単位が要る。タグとの違い（権限の付与単位になるか）を区別できるかが分かれ目。","kid":"ワークスペースをまとめる箱。権限もその箱の単位で付けられる。","terms":[["プロジェクト","複数のワークスペースをまとめ、権限の付与単位にもなるHCP Terraformの構造。"]],"think":"ワークスペースが数十に増えると、個別に権限を付けるのは破綻する。まとめる単位があり、そこへ権限を付けられる。","vs":"権限の付与単位になるか、が軸。タグは絞り込みの目印にはなるが権限は付かず、変数セットは値の配布、run triggers は実行の連鎖。","opt":["正解。ワークスペースをまとめる単位であり、チーム権限もこの単位で付与できる。","変数セットは共通の変数を配る仕組み。まとめる単位でも権限の単位でもない。","run triggers はワークスペース間で実行を連鎖させる機能で、整理の仕組みではない。","タグは絞り込みには使えるが、チーム権限を付与する単位にはならない。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'terraform-associate-b'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
