-- =============================================================
-- 00025_seed_terraform_associate.sql
-- HashiCorp Terraform Associate (004) — Set A / 50問 / 8ドメイン
-- 形式混在: single / multi / 真偽(2択single) / 穴埋め(code列)
-- 設計方針: 誤答は実在コマンド/サービスの近縁ペア。選択肢の分量も均一化。
-- 選択肢は正解を先頭に並べ correct_index=0 / correct_indices で管理(描画時シャッフル)。
-- 解説は asked / why_asked / kid / terms / think / snippet(任意) / vs / opt(固定形式)。
-- 注: 本番の再現ではなく学習用オリジナル。本試験は約60分/57〜60問。
-- =============================================================

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('terraform-associate', 'HashiCorp Terraform Associate (004) — Set A', 'HashiCorp Certified: Terraform Associate 004 対策 第1弾。本番004の8ドメイン準拠・形式混在（単一/複数/真偽/穴埋め）50問。誤答は実在サービス/コマンドの近縁ペアで構成。本試験は約60分/57〜60問。本番の再現ではなく学習用オリジナル。', '#7B42BC', 30)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('1. IaC概念', '#58a6ff', 0),
  ('2. Terraform基礎', '#3fb950', 1),
  ('3. コアワークフロー', '#f0883e', 2),
  ('4. 構成(HCL)', '#a371f7', 3),
  ('5. モジュール', '#d2a8ff', 4),
  ('6. State管理', '#f85149', 5),
  ('7. インフラ保守', '#e3b341', 6),
  ('8. HCP Terraform', '#39c5cf', 7)
) AS v(name, color, sort_order)
WHERE s.slug = 'terraform-associate'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options, correct_index, correct_indices, question_type, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb, v.correct_index, v.correct_indices::jsonb, v.question_type, v.explanation_data::jsonb, 0
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('terraform-associate-q1', '1. IaC概念',
   'Infrastructure as Code(IaC)の中核的な利点として最も適切なものはどれか。',
   NULL,
   '["インフラを宣言的なコードで定義し、再現性・バージョン管理・レビューを可能にする", "既存インフラのメトリクスとアラートを一元的に可視化する", "アプリのビルド成果物を各環境へ配布するパイプラインを実行する", "サーバへ手動でSSH接続する作業をGUIで補助する"]', 0, '[0]', 'single',
   '{"asked": "IaCが何を解決するかを理解しているか。", "why_asked": "IaCという言葉はDevOpsの道具箱全体を指す流行語として使われがちで、監視やCI-CDとの境界が溶けている。試験は入口でその混同を潰し、Terraformが引き受けるのは「インフラの定義と再現」だけだと線を引かせにくる。", "kid": "インフラを「コード」で書くと、同じ環境を何度でも同じ形で作れて、変更履歴も残る。", "terms": [["IaC", "インフラを人間/機械可読なコードで定義・管理する手法。"]], "think": "料理を「勘」で作るとブレるが、レシピ(コード)にすれば誰が作っても同じ味。それがIaC。", "vs": "監視の一元化=オブザーバビリティ／成果物の配布=CI-CD。どちらもIaC本体ではない。", "opt": ["正解。宣言的・再現可能・レビュー可能がIaCの核。", "監視の説明。IaCの目的ではない。", "CI-CDの説明。インフラ定義そのものではない。", "手動作業の補助であり、コード化による自動化ではない。"]}'),

  ('terraform-associate-q2', '1. IaC概念',
   'Terraformがマルチクラウドやハイブリッドクラウドをどのように扱うか、最も適切な説明はどれか。',
   NULL,
   '["各プロバイダ経由で、クラウドをまたいで同一のワークフローと構文で管理できる", "1回の実行につき1つのクラウドしか対象にできない", "クラウドごとに専用のTerraformバイナリを使い分ける必要がある", "オンプレミス機器は一切管理できずクラウド専用である"]', 0, '[0]', 'single',
   '{"asked": "Terraformのサービス非依存なワークフローを理解しているか。", "why_asked": "ベンダ専用ツールの感覚を引きずると、クラウドごとに実行やバイナリを分ける発想に流れる。HashiCorpが売っているのは個々のAPIではなく、どのクラウドでも同じ手順で回せるワークフローそのもの。そこを取り違えていないかを早い段階で確かめてくる。", "kid": "AWSでもGCPでも、同じ書き方・同じ手順(plan/apply)で扱える。窓口(プロバイダ)を差し替えるだけ。", "terms": [["プロバイダ", "各クラウド/サービスのAPIをTerraformに橋渡しするプラグイン。"]], "think": "同じリモコン(ワークフロー)で、テレビもエアコンも操作できる。差すアダプタ(プロバイダ)が違うだけ。", "vs": "1実行1クラウド/バイナリ使い分けは誤り。単一構成で複数プロバイダを併用できる。", "opt": ["正解。プロバイダを介して統一ワークフローで扱える。", "複数プロバイダを1構成で併用できるため誤り。", "バイナリは共通。プロバイダが差分を吸収する。", "オンプレ/SaaSもプロバイダがあれば管理可能。"]}'),

  ('terraform-associate-q3', '1. IaC概念',
   '宣言的(declarative)なアプローチが、命令的(imperative)なスクリプトに対して持つ利点はどれか。',
   NULL,
   '["望ましい最終状態を書けば、現状との差分をTerraformが計算し必要な変更だけ適用する", "実行手順を1行ずつ順番に記述するため、処理順序を完全に手で制御できる", "変更のたびに全リソースを削除して作り直すため状態がずれない", "リソースの作成順序を必ず利用者が手動で指定する必要がある"]', 0, '[0]', 'single',
   '{"asked": "宣言的モデルの本質(最終状態を書く)を理解しているか。", "why_asked": "スクリプトに慣れた人ほど「順序を自分で握れること」を利点だと感じるが、その直感こそ命令的発想の名残。差分の計算を人間が抱え込んだ時点で冪等性は壊れる。その一点を宣言的モデルの核として繰り返し確認してくる。", "kid": "「どうやるか」ではなく「どうなっていてほしいか」を書く。差分の埋め方はTerraformが考える。", "terms": [["宣言的", "目標状態を記述し、到達手順はツールに委ねる方式。"], ["命令的", "手順を逐次記述する方式。"]], "think": "カーナビに「目的地」だけ入れる(宣言的)か、曲がる場所を全部自分で言う(命令的)かの違い。", "vs": "手順の逐次記述・毎回作り直し・順序手動指定はいずれも命令的発想で、宣言的の利点ではない。", "opt": ["正解。最終状態を宣言し差分だけ適用する。", "逐次手順の制御は命令的の特徴。", "毎回作り直しはしない。差分適用が基本。", "依存は基本Terraformが推論する。"]}'),

  ('terraform-associate-q4', '2. Terraform基礎',
   '使用するプロバイダのバージョンを固定/制約するには、どこに記述するのが正しいか。',
   NULL,
   '["terraformブロック内 required_providers の version 引数", "providerブロック内の region などの接続引数", "各環境ごとの terraform.tfvars ファイルの側", "state保管先を定める backend ブロックの設定"]', 0, '[0]', 'single',
   '{"asked": "プロバイダのバージョン制約の記述場所を知っているか。", "why_asked": "バージョンを緩めたままの構成は、こちらが何もしていないのに新版の登場で壊れる。だからHashiCorpは「どこに書くか」という些末に見える位置の知識を、再現性を守る意思があるかの試金石として問う。regionやtfvarsを混ぜるのはその揺さぶり。", "kid": "「どのプロバイダをどのバージョンで使うか」は required_providers にまとめて書く。", "terms": [["required_providers", "必要なプロバイダのソースとバージョン制約を宣言するブロック。"]], "think": "部品表(required_providers)に「この部品はv5系」と型番を書くイメージ。regionは動かし方の設定で別物。", "snippet": "terraform {\n  required_providers {\n    aws = {\n      source  = \"hashicorp/aws\"\n      version = \"~> 5.0\"\n    }\n  }\n}", "vs": "regionは接続先の指定/tfvarsは変数値/backendはstate保管先。いずれもバージョン制約の場所ではない。", "opt": ["正解。required_providers の version で制約する。", "regionは接続先であってバージョンではない。", "tfvarsは入力変数の値を渡す場所。", "backendはstateの保管先設定。"]}'),

  ('terraform-associate-q5', '2. Terraform基礎',
   '依存ロックファイル(.terraform.lock.hcl)の役割として正しいものはどれか。',
   NULL,
   '["選定したプロバイダの版とハッシュを固定し再現性を保つ", "管理下リソースの現在の状態と属性を保存する", "各入力変数のデフォルト値をまとめて保持する", "取得済みモジュールのソースURLをキャッシュする"]', 0, '[0]', 'single',
   '{"asked": "ロックファイルとstateの役割の違いを区別できるか。", "why_asked": "lockもstateも「勝手に生成される何か」と一括りにされやすく、現場ではlockをgitignoreしてチーム内で版がずれる事故が起きる。試験は両者を隣に並べ、別物として説明し分けられるかを試している。", "kid": "「使ったプロバイダの版とハッシュ」を控えておくメモ。誰がinitしても同じ版が入る。", "terms": [["依存ロックファイル", ".terraform.lock.hcl。プロバイダの選定版とハッシュを固定する。"]], "think": "レシピで使った調味料の「銘柄と製造ロット」を控えておく紙。次も同じ物を使える。状態(state)とは別。", "vs": "現在状態=state/変数値=tfvars/モジュール取得は.terraform配下。ロックはプロバイダ版の固定が役割。", "opt": ["正解。プロバイダ版とハッシュを固定し再現性を担保。", "現在状態の保存はstateファイルの役割。", "変数デフォルトはvariableブロック。", "モジュール取得はロックファイルの管轄外。"]}'),

  ('terraform-associate-q6', '2. Terraform基礎',
   'terraform init が行うこととして正しいものを2つ選べ。',
   NULL,
   '["バックエンドを初期化する", "必要なプロバイダとモジュールをダウンロードする", "構成に基づき実インフラを作成する", "stateファイルを削除する"]', 0, '[0,1]', 'multi',
   '{"asked": "initの責務(準備)とapplyの責務(適用)を分離できているか。", "why_asked": "initを最初に打つおまじないで済ませている受験者は多い。準備と適用の境界が曖昧なままではCIのどの段階に何を通すかを設計できない。コマンドの暗記ではなく、責務の線引きを言葉にできるかを見にきている。", "kid": "initは「準備」だけ。道具(プロバイダ)を揃えて保管庫(backend)を用意する。物は作らない。", "terms": [["backend", "stateの保管と操作方式を決める設定。"]], "think": "料理前の「食材と道具を揃える」段階がinit。実際に調理(作成)するのはapply。", "vs": "インフラ作成はapply/state削除はinitの仕事ではない。", "opt": ["正解。backendの初期化はinitの役割。", "正解。プロバイダ/モジュール取得はinit。", "実インフラ作成はapplyの役割。", "initはstateを削除しない。"]}'),

  ('terraform-associate-q7', '2. Terraform基礎',
   'プロバイダのプラグインは、どのタイミングでダウンロードされるか。',
   NULL,
   '["terraform init 実行時", "terraform plan 実行時", "terraform apply 実行時", "terraform validate 実行時"]', 0, '[0]', 'single',
   '{"asked": "プロバイダ取得のタイミングを正しく理解しているか。", "why_asked": "どの段階でネットワークへ取りに行くかを知らないと、閉域環境やCIでプラグインをキャッシュする設計ができない。取得の失敗が適用直前に露見すれば被害は大きく、そこが実運用の詰まりどころだからこそ一問を割いて聞く。", "kid": "道具(プラグイン)を取りに行くのは最初のinitのとき。", "terms": [["プラグイン", "プロバイダの実体。initで.terraform配下に取得される。"]], "think": "工事の初日に工具を搬入(init)。以降のplan/applyは搬入済みの工具で作業する。", "vs": "plan/apply/validateは取得済み前提で動く。取得はinit。", "opt": ["正解。initで取得する。", "planは差分計算で、取得はしない。", "applyは適用で、取得はしない。", "validateは構文検証のみ。"]}'),

  ('terraform-associate-q8', '2. Terraform基礎',
   '同一プロバイダを異なるリージョンで使い分けるための正しい方法はどれか。',
   NULL,
   '["providerに alias を定義し、リソース側で provider を明示指定する", "リージョンごとに別ディレクトリへ構成を完全に分割する", "required_providers に同じプロバイダを二重に記述する", "count を使ってリージョンの数だけリソースを複製する"]', 0, '[0]', 'single',
   '{"asked": "複数プロバイダ構成(alias)を扱えるか。", "why_asked": "リージョンごとにディレクトリを切る運用は現実によくあるので、選択肢として妙に説得力がある。だが同じ構成を二重管理すれば必ずずれていく。ひとつの構成の中でプロバイダを名前で呼び分ける道具を持っているかが分かれ目。", "kid": "同じ窓口を2つ用意して名札(alias)を付け、リソース側で「こっちの窓口を使う」と指名する。", "terms": [["alias", "同一プロバイダの追加設定に付ける別名。"]], "think": "同じ銀行(プロバイダ)の東京支店と大阪支店(alias)。手続き(リソース)ごとにどの支店かを指定する。", "snippet": "provider \"aws\" {\n  region = \"us-east-1\"\n}\n\n# 名札(alias)を付けた2つ目の窓口\nprovider \"aws\" {\n  alias  = \"tokyo\"\n  region = \"ap-northeast-1\"\n}\n\nresource \"aws_s3_bucket\" \"my_bucket\" {\n  provider = aws.tokyo\n  bucket   = \"my-example-bucket\"\n}", "vs": "ディレクトリ分割や二重宣言は不要。countはリソース複製でありプロバイダ切替ではない。", "opt": ["正解。aliasで複数設定を定義し明示的に指定。", "同一構成内でalias併用でき、分割は不要。", "required_providersの二重記述はしない。", "countは同一provider内での複製に過ぎない。"]}'),

  ('terraform-associate-q9', '2. Terraform基礎',
   'Terraformがstateを保持する主な理由として最も適切なものはどれか。',
   NULL,
   '["実リソースと構成の対応を保持し差分計算に用いるため", "プロバイダの認証情報を暗号化して安全に保管するため", "HCLの構文と型が正しいかを事前に検証するため", "モジュール間の依存関係を解決し実行順序を決めるため"]', 0, '[0]', 'single',
   '{"asked": "stateの目的を理解しているか。", "why_asked": "stateを単なるキャッシュだと思っている限り、消してもまた作られるという致命的な誤解が残る。実物と構成をつなぐ唯一の対応表だからこそ、後で問われる移行やロックや機密の扱いが、すべてここを土台に積み上がる。", "kid": "「構成に書いた物」と「実際に作った物」の対応表。これがあるから差分を素早く出せる。", "terms": [["state", "管理対象リソースと構成の対応・メタデータを記録するファイル。"]], "think": "持ち物リスト(state)があるから、次に何を足す/減らすかがすぐ分かる。認証保管や構文検査とは別。", "vs": "認証保管でも構文検証でもない。マッピング保持と差分計算がstateの役目。", "opt": ["正解。マッピング保持と差分計算・性能のため。", "認証情報の保管がstateの目的ではない。", "構文検証はvalidateの役割。", "依存解決はグラフ構築で行う。"]}'),

  ('terraform-associate-q10', '3. コアワークフロー',
   '標準的なコアTerraformワークフローの順序として正しいものはどれか。',
   NULL,
   '["構成を書く → init → plan → apply", "init → apply → plan → validate", "plan → apply → init → fmt", "fmt → import → refresh → apply"]', 0, '[0]', 'single',
   '{"asked": "コアワークフローの基本順序を把握しているか。", "why_asked": "順序自体は暗記で済むが、試験が確かめたいのは「適用の前に必ず人が差分を見る」という関門を飛ばさない姿勢。applyを前に置いた選択肢は、確認を省く運用がなぜ危ないかを理解しているかの踏み絵になっている。", "kid": "書く→準備(init)→差分確認(plan)→適用(apply)。この並びが基本。", "terms": [["コアワークフロー", "write/init/plan/applyの基本サイクル。"]], "think": "設計を書く→道具を揃える→見積り(plan)を見る→着工(apply)。順番が入れ替わると成立しない。", "snippet": "# 構成(.tf)を書いたあとの基本の並び\nterraform init\nterraform plan\nterraform apply", "vs": "applyがplanより先/initが後ろ、は誤り。まず準備、次に差分確認、最後に適用。", "opt": ["正解。write→init→plan→applyが基本。", "applyがplanより前になっており不正。", "initが後半にあり不正。", "importやrefreshは基本サイクルの必須手順ではない。"]}'),

  ('terraform-associate-q11', '3. コアワークフロー',
   '構成の構文的な妥当性(参照ミスや型不整合など)をローカルで検査するコマンドはどれか。',
   NULL,
   '["terraform validate", "terraform fmt", "terraform show", "terraform refresh"]', 0, '[0]', 'single',
   '{"asked": "validateの役割を他コマンドと区別できるか。", "why_asked": "クラウドの認証情報がなくても回せる検査を、パイプラインのどれだけ手前に置けるかという設計の話に直結する。fmtやshowを並べてくるのは、似た「無害なコマンド」群の中で、どれが何を保証するのかを混ぜて覚えていないかを見るため。", "kid": "「書き方が正しいか」だけを見るのがvalidate。差分やインフラは見ない。", "terms": [["validate", "構文と内部整合性を検査するコマンド。API接続は不要。"]], "think": "提出前に書類の記入ミスだけチェック(validate)。実際に窓口へ出す(plan/apply)のは別段階。", "vs": "fmtは整形/showは表示/refreshはstate更新。構文検査はvalidate。", "opt": ["正解。構文と整合性の検査。", "fmtはスタイル整形であって妥当性検査ではない。", "showはstate/planの内容表示。", "refreshは実インフラに合わせたstate更新。"]}'),

  ('terraform-associate-q12', '3. コアワークフロー',
   'terraform fmt が行うことはどれか。',
   NULL,
   '["構成ファイルを標準の書式・スタイルに整形する", "構成の構文的な妥当性を検証する", "未使用の変数を自動的に削除する", "stateファイルの中身を整形する"]', 0, '[0]', 'single',
   '{"asked": "fmtの責務を理解しているか。", "why_asked": "書式が揃っていないコードは、レビューで本質的な差分が空白の差に埋もれる。fmtを独立して問うのは、体裁を整えるだけで中身の正しさは一切保証しないという限界を、validateとの境界込みで押さえさせたいから。", "kid": "インデントや空白を「見た目のルール」に揃えるだけ。中身の正しさは見ない。", "terms": [["fmt", "canonicalな書式へ整形するコマンド。"]], "think": "文章の体裁(字下げ・改行)を整えるのがfmt。誤字脱字(妥当性)の検査はvalidateの仕事。", "vs": "妥当性検査=validate/未使用変数の削除はしない/stateは対象外。", "opt": ["正解。標準書式へ整形する。", "妥当性検証はvalidateの役割。", "変数の自動削除は行わない。", "stateはfmtの対象外。"]}'),

  ('terraform-associate-q13', '3. コアワークフロー',
   '「terraform plan を実行すると実インフラが変更される」——この記述は正しいか。',
   NULL,
   '["誤り", "正しい"]', 0, '[0]', 'single',
   '{"asked": "planが読み取り専用(変更しない)ことを理解しているか。", "why_asked": "本番でplanを打つのが怖いという誤解と、planが通ったから安全という過信は表裏一体。何も変えないと言い切れるからこそ、誰でも何度でも差分を覗ける。その安心がレビュー文化の前提になっていることを確認してくる。", "kid": "planは「これから何が変わるか」を見せるだけ。実際には何も変えない。", "terms": [["plan", "適用前の差分(実行計画)を提示する読み取り専用操作。"]], "think": "工事の見積書(plan)を見ても、まだ工事(apply)は始まっていない。", "vs": "変更が起きるのはapply。planは提示のみ(内部でrefreshはあるが構成変更はしない)。", "opt": ["正解。planは変更しない。ゆえに記述は誤り。", "planでインフラは変わらないため、この選択は不適切。"]}'),

  ('terraform-associate-q14', '3. コアワークフロー',
   'リソースを1つだけ強制的に破棄・再作成したい。現行(推奨)の方法はどれか。',
   NULL,
   '["terraform apply -replace=ADDRESS", "terraform taint ADDRESS", "terraform destroy -target=ADDRESS", "terraform refresh -target=ADDRESS"]', 0, '[0]', 'single',
   '{"asked": "非推奨のtaintではなく-replaceを選べるか。", "why_asked": "taintは古い記事や教材に大量に残っており、現場の記憶だけで解くと引っかかる。HashiCorpはstateに印を付ける操作から、置換をplanの上に見える形で示すやり方へ舵を切った。その転換に追随できているかを試す設問。", "kid": "「これだけ作り直して」は apply -replace で指定する。昔のtaintは今は非推奨。", "terms": [["-replace", "対象リソースを次のapplyで置換(破棄→再作成)させるオプション。"], ["taint", "旧来の置換指定。現在は-replace推奨で非推奨扱い。"]], "think": "1部屋だけリフォーム(置換)を指示するのが-replace。taintは古いやり方の同義。", "snippet": "# 現行の置換方法(terraform taint は非推奨)\nterraform apply -replace=aws_instance.web", "vs": "destroy -targetは削除のみ(再作成しない)/refreshはstate更新のみ。置換は-replace。", "opt": ["正解。現行推奨の置換方法。", "taintは非推奨。-replaceに置き換わった。", "destroy -targetは削除のみで再作成しない。", "refreshはstate更新で再作成しない。"]}'),

  ('terraform-associate-q15', '3. コアワークフロー',
   'terraform destroy は何を対象に削除するか。',
   NULL,
   '["そのワークスペースの構成で管理されている全リソース", "stateファイルそのものだけ", "ダウンロード済みのプロバイダプラグイン", "ローカルの.terraformディレクトリ"]', 0, '[0]', 'single',
   '{"asked": "destroyの対象範囲を理解しているか。", "why_asked": "対象範囲を曖昧にしたままdestroyを打つと、想定より広く消える事故が起きる。消えるのは控えでも道具でもなく実物、しかも構成が管理している全部だという一線を、まだ取り返しがつく段階で刻ませたい。", "kid": "destroyは「作った実物」を消す。stateやプラグインの掃除ではない。", "terms": [["destroy", "管理下の実リソースを削除する操作。"]], "think": "建てた建物(実リソース)を取り壊すのがdestroy。図面控え(state)や工具(プラグイン)の廃棄ではない。", "vs": "stateやプラグイン削除は別作業。destroyは実インフラの削除。", "opt": ["正解。管理下の実リソースを削除する。", "stateのみ削除ではない。", "プラグイン削除ではない。", ".terraformの削除ではない。"]}'),

  ('terraform-associate-q16', '3. コアワークフロー',
   'レビュー時点の実行計画を保存し、後でその内容どおりに確定適用したい。正しい手順はどれか。',
   NULL,
   '["terraform plan -out=tfplan の後 terraform apply tfplan", "terraform apply -out=tfplan の後 terraform plan tfplan", "terraform plan -save の後 terraform apply --from-plan", "terraform apply -auto-approve のみ"]', 0, '[0]', 'single',
   '{"asked": "保存済みプランの適用フローを知っているか。", "why_asked": "レビューした差分と実際に適用される差分がずれるなら、承認という手続き自体が意味を失う。保存プランはその隙間を塞ぐ仕組みで、auto-approveを並べてくるのは、確認を省く近道につい手が伸びないかを見ているから。", "kid": "planを-outでファイルに保存し、そのファイルをapplyに渡すと、見た内容そのままが適用される。", "terms": [["-out", "planの結果を保存するオプション。"]], "think": "見積書(保存プラン)に判を押して、その見積どおりに発注(apply)する。途中で内容がすり替わらない。", "snippet": "# 計画を保存し、その内容どおりに適用する\nterraform plan -out=tfplan\nterraform apply tfplan", "vs": "-outはplan側/-saveや--from-planは存在しない/auto-approveは保存プランではなく即時承認。", "opt": ["正解。plan -out で保存しapplyに渡す。", "-outはapplyではなくplanのオプション。", "-save/--from-planという構文はない。", "auto-approveは保存プランの適用ではない。"]}'),

  ('terraform-associate-q17', '4. 構成(HCL)',
   'resourceブロックとdataブロックの違いとして正しいものはどれか。',
   NULL,
   '["resourceは作成・管理を行い、dataは既存情報の参照を行う", "dataは書き込み専用で、resourceは読み取り専用である", "両者は同義で、ブロック名が異なるだけである", "dataはローカル変数を定義するために使うものである"]', 0, '[0]', 'single',
   '{"asked": "resourceとdataの役割を区別できるか。", "why_asked": "どこまでが自分の持ち物で、どこからは他人の資産として参照するだけかという所有権の境界の話。既存のVPCをうっかりresourceで書けば、Terraformはそれを管理下と見なして作り直しにかかる。その線引きを最初に叩き込む設問。", "kid": "resourceは「作る/持つ」、dataは「すでにある物を調べて使う」。", "terms": [["data source", "既存リソースの情報を読み取る参照専用ブロック。"]], "think": "resourceは自分で建てる家、dataは近所の既存の家の住所を調べて参照する感じ。", "snippet": "# 作成・管理する\nresource \"aws_s3_bucket\" \"my_bucket\" {\n  bucket = \"my-example-bucket\"\n}\n\n# 既存のものを参照する(作成しない)\ndata \"aws_s3_bucket\" \"existing\" {\n  bucket = \"existing-example-bucket\"\n}", "vs": "dataは読み取り(作成しない)。書き込み専用/同義/ローカル変数はいずれも誤り。", "opt": ["正解。resource=管理、data=参照。", "dataは書き込みしない。逆。", "同義ではなく役割が異なる。", "ローカル変数はlocalsで定義する。"]}'),

  ('terraform-associate-q18', '4. 構成(HCL)',
   '下のmap型変数から us-east-1 の値を参照する式として正しいものはどれか。',
   'variable "vpc_cidrs" {
  type = map(string)
  default = {
    us-east-1 = "10.0.0.0/16"
    us-west-1 = "10.2.0.0/16"
  }
}',
   '["var.vpc_cidrs[\"us-east-1\"]", "var.vpc_cidrs.us-east-1", "vpc_cidrs[\"us-east-1\"]", "var[\"vpc_cidrs\"].us-east-1"]', 0, '[0]', 'single',
   '{"asked": "mapのキー参照構文を書けるか(ハイフンを含むキー)。", "why_asked": "HCLの式評価は暗記ではなく規則で決まる。ドット記法が万能だと思い込むと、ハイフンを含むキーで構文エラーに落ちる。試験はこうした「たいてい動くから正しいと錯覚している書き方」を選択肢に混ぜ、規則を理解しているかを見分けにくる。", "kid": "mapの中身は かぎ括弧[\"キー\"] で取り出す。キーにハイフンがある時はドット記法は使えない。", "terms": [["map", "キーと値の対応表。値はブラケットで参照する。"]], "think": "辞書で単語(キー)を引くとき index[\"単語\"] の形。ハイフン入りの見出しはドットでは引けない。", "snippet": "# ○ ハイフンを含むキーは [\"...\"] で参照する\nlocals {\n  east_cidr = var.vpc_cidrs[\"us-east-1\"]\n}\n\n# ✗ ドット記法はハイフン入りキーには使えない\n# var.vpc_cidrs.us-east-1", "vs": "var.名.キー のドット記法はキーにハイフンがあると不可。先頭のvar.も必須。", "opt": ["正解。ブラケットでキー参照。ハイフン対応。", "ハイフンを含むキーはドット記法で参照できない。", "先頭のvar.が抜けている。", "参照の構文順序が不正。"]}'),

  ('terraform-associate-q19', '4. 構成(HCL)',
   '「各属性が異なる型を持つ、名前付きの構造化データ」を表現する型はどれか。',
   NULL,
   '["object({ name = string, port = number })", "tuple([string, number, bool, string])", "map(string) で全属性を同一型にする", "list(object({ name = string }))"]', 0, '[0]', 'single',
   '{"asked": "複合型(object/tuple/map)を使い分けられるか。", "why_asked": "型を曖昧にした構成は、渡ってくる値が変わった瞬間に壊れる。HashiCorpが型の明示を推すのは、誤った入力をapplyより前に弾くためだ。試験は似た複合型を横並びにして、「とりあえずmapで束ねる」という妥協を正解らしく見せてくる。", "kid": "名前付きで型がバラバラの属性を束ねるのがobject。順番だけで名前が無いのがtuple。", "terms": [["object", "属性名ごとに型を定める構造型。"], ["tuple", "位置(順序)で型を定める、名前無しの並び。"]], "think": "objectは「氏名=文字/年齢=数字」の記入用紙(項目名あり)。tupleは項目名の無い順番だけの並び。", "snippet": "variable \"server\" {\n  type = object({\n    name = string\n    port = number\n  })\n}", "vs": "tupleは名前無し・順序依存/mapは全値が同一型/list(object)はobjectの並び。名前付き混合型はobject。", "opt": ["正解。名前付き・型混合はobject。", "tupleは名前が無く順序で決まる。", "mapは全値が同一型でなければならない。", "objectの並びであって単一のobjectではない。"]}'),

  ('terraform-associate-q20', '4. 構成(HCL)',
   'for_each が引数として受け付けるコレクション型を2つ選べ。',
   NULL,
   '["map(string) 型のコレクション", "文字列の set 型のコレクション", "list(string) 型のコレクション", "number 型の単一の数値"]', 0, '[0,1]', 'multi',
   '{"asked": "for_eachが受け付ける型(map/set)を知っているか。", "why_asked": "for_eachがmapとsetに限られるのは、キーで同一性を保つという設計思想の帰結。順序しか持たないlistでは一つひとつを識別できない。試験は仕様の丸暗記ではなく、なぜlistがそのままでは弾かれるのかまで届いているかを測ってくる。", "kid": "for_eachはmapか文字列のsetを渡す。ただのlistや数値は渡せない(setに変換する)。", "terms": [["for_each", "コレクションの各要素にキー付きでインスタンスを作るメタ引数。"]], "think": "名簿(map/set)を渡すと、名前(キー)ごとに1つずつ席を用意する。順番だけのlistではキーが定まらない。", "snippet": "# map をそのまま渡せる\nresource \"aws_instance\" \"web\" {\n  for_each      = { a = \"t3.micro\", b = \"t3.small\" }\n  instance_type = each.value\n}\n\n# list は toset() で set にしてから渡す\nresource \"aws_iam_user\" \"example\" {\n  for_each = toset(var.names)\n  name     = each.key\n}", "vs": "listはtoset()等でset化して渡す/numberはcountの世界。for_eachはmap/set。", "opt": ["正解。mapはfor_eachで使える。", "正解。文字列のsetも使える。", "listはそのままでは不可(要set化)。", "数値はcountの領域でfor_eachでは不可。"]}'),

  ('terraform-associate-q21', '4. 構成(HCL)',
   'countで作った複数リソースのうち、リストの途中要素を削除すると起きやすい問題はどれか。',
   NULL,
   '["以降のインデックスがずれ無関係なリソースまで再作成される", "検証エラーで停止し変更は何も適用されなくなる", "差分は生じず既存リソースはそのまま保たれる", "stateが自動で並べ替えてズレを修復してくれる"]', 0, '[0]', 'single',
   '{"asked": "count(インデックス)の弱点とfor_each推奨理由を理解しているか。", "why_asked": "番号での管理は本番で実際に事故る。無関係なリソースの再作成はサービス停止やデータ消失に直結するため、試験はこの弱点を繰り返し問う。「差分は出ない」「stateが直してくれる」という都合のいい期待を並べ、楽観を潰しにくる。", "kid": "countは番号で管理するので、途中を抜くと後ろが全部ずれて作り直しになる。だから安定IDが要る時はfor_each。", "terms": [["count", "数値インデックスで複製するメタ引数。"]], "think": "番号札で管理する行列。真ん中の人が抜けると以降の番号が全部繰り上がり、別人扱いになる。", "snippet": "# ○ キーで管理されるので、途中を消しても他がずれない\nresource \"aws_instance\" \"web\" {\n  for_each      = toset(var.names)\n  ami           = var.ami_id\n  instance_type = \"t3.micro\"\n  tags          = { Name = each.key }\n}\n\n# ✗ count は番号管理。途中を消すと後続のindexがずれて再作成される\n# resource \"aws_instance\" \"web\" {\n#   count = length(var.names)\n#   tags  = { Name = var.names[count.index] }\n# }", "vs": "for_eachはキーで管理するためインデックスずれが起きない。停止/無変化/自動修復はいずれも誤り。", "opt": ["正解。インデックスずれで再作成が波及する。", "エラーで止まるのではなく再作成が起きる。", "差分は生じる。", "自動修復はしない。"]}'),

  ('terraform-associate-q22', '4. 構成(HCL)',
   'リソース内で可変個のネストブロック(例: 複数のingressルール)をループ生成する仕組みはどれか。',
   NULL,
   '["dynamic ブロック", "count メタ引数", "for_each をリソースに直接付与", "provisioner ブロック"]', 0, '[0]', 'single',
   '{"asked": "dynamicブロックの用途を理解しているか。", "why_asked": "リソースそのものを増やすことと、リソースの中の構造を増やすことは別の問題だ。ここを混同したままcountやfor_eachに手を伸ばす受験者は多く、試験は両方を選択肢に置いて、構成をどの粒度で捉えているかを確かめてくる。", "kid": "1つのリソースの中の「小さなブロック」を数だけ繰り返したい時にdynamicを使う。", "terms": [["dynamic", "ネストブロックを式から動的に生成する構文。"]], "think": "1枚の申込書(リソース)の中で、家族欄(ネストブロック)を人数分だけ増やすイメージ。", "snippet": "resource \"aws_security_group\" \"example\" {\n  name = \"example\"\n\n  dynamic \"ingress\" {\n    for_each = var.ports\n    content {\n      from_port = ingress.value\n      to_port   = ingress.value\n      protocol  = \"tcp\"\n    }\n  }\n}", "vs": "count/for_eachはリソース自体の複製。ネスト「ブロック」の生成はdynamic。provisionerは実行系。", "opt": ["正解。ネストブロックの動的生成はdynamic。", "countはリソース単位の複製。", "リソース複製であってネストブロック生成ではない。", "provisionerは作成後のコマンド実行。"]}'),

  ('terraform-associate-q23', '4. 構成(HCL)',
   '入力変数に「1〜65535の範囲」などの制約を課し、違反時にエラーを出したい。どこに書くか。',
   NULL,
   '["variableブロック内の validation ブロック", "resourceのlifecycle内の precondition ブロック", "構成トップレベルの独立した check ブロック", "providerブロックに渡す接続用の設定引数"]', 0, '[0]', 'single',
   '{"asked": "変数のvalidationと各種条件の書き分けができるか。", "why_asked": "誤りは早い層で止めるほど傷が浅いというのがTerraformの一貫した立場。似た検証機能が複数ある中でどこに置くべきかを選ばせるのがこの手の問いで、入力の妥当性をapplyまで持ち越さず入口で断つ判断が評価される。", "kid": "入力値そのもののチェックはvariableの中のvalidationに書く。", "terms": [["variable validation", "入力変数に条件を課す仕組み。"]], "think": "申込用紙の記入欄(変数)に「1〜65535で記入」と注意書き(validation)を付ける。", "snippet": "variable \"port\" {\n  type = number\n\n  validation {\n    condition     = var.port >= 1 && var.port <= 65535\n    error_message = \"port は 1〜65535 で指定してください。\"\n  }\n}", "vs": "preconditionはリソース適用直前の前提/checkは継続的アサート。入力値検証はvariableのvalidation。", "opt": ["正解。入力変数の検証はvalidation。", "preconditionはリソース側の前提条件。", "checkは継続的検証で入力値検証とは別。", "providerの引数ではない。"]}'),

  ('terraform-associate-q24', '4. 構成(HCL)',
   'リソースやdataの適用前後で満たすべき前提/結果条件を宣言するために使うのはどれか。',
   NULL,
   '["リソースの lifecycle 内の precondition / postcondition", "入力を検証する variable の validation ブロック", "版要件を課す terraform の required_version", "出力を秘匿する output の sensitive 属性"]', 0, '[0]', 'single',
   '{"asked": "precondition/postconditionの位置と役割を理解しているか。", "why_asked": "宣言的に書いていても、暗黙のうちに信じている前提が崩れれば構成は壊れる。だからHashiCorpは前提と結果をコードに残すことを推す。試験は検証系を横並びにして、誰がいつ何を保証するのかという配置の理解を突いてくる。", "kid": "「作る前にこの前提が成り立っているか」「作った後この結果になっているか」をリソース側で保証する。", "terms": [["precondition", "適用前に満たすべき前提条件。"], ["postcondition", "適用後に満たすべき結果条件。"]], "think": "料理前に「材料が揃っているか(pre)」、料理後に「規定の温度になったか(post)」を確認する関所。", "snippet": "resource \"aws_instance\" \"example\" {\n  ami           = data.aws_ami.example.id\n  instance_type = \"t3.micro\"\n\n  lifecycle {\n    # 適用「前」に満たすべき前提条件\n    precondition {\n      condition     = data.aws_ami.example.architecture == \"x86_64\"\n      error_message = \"AMI は x86_64 である必要があります。\"\n    }\n\n    # 適用「後」に満たすべき結果条件(self で自身の属性を参照)\n    postcondition {\n      condition     = self.public_dns != \"\"\n      error_message = \"パブリック DNS が割り当てられていません。\"\n    }\n  }\n}", "vs": "変数値の検証はvalidation/バージョン要件はrequired_version/sensitiveは秘匿表示。", "opt": ["正解。pre/postconditionはlifecycle内で宣言。", "validationは入力変数側の検証。", "required_versionはTerraform本体の版要件。", "sensitiveは出力の秘匿。"]}'),

  ('terraform-associate-q25', '4. 構成(HCL)',
   'check ブロック(1.5+)の特徴として最も正しいものはどれか。',
   NULL,
   '["アサートを継続評価し、失敗しても警告に留めapplyは止めない", "条件を満たさない場合は必ずapplyを失敗させて停止する", "入力変数の型と範囲を適用の前に検証する", "対象リソースが削除されるのを恒久的に禁止する"]', 0, '[0]', 'single',
   '{"asked": "checkとprecondition(停止する)の違いを区別できるか。", "why_asked": "止めるべき失敗と、知らせれば足りる失敗は違う。この強弱を取り違えると、見張りのつもりで置いた仕掛けがapplyを塞ぐ。試験は「必ず失敗させる」という強い言い切りを混ぜ、機能の効き方を正確に掴んでいるか試してくる。", "kid": "checkは「気づき」を出す見張り。ダメでも止めはしない。止めたいならpreconditionを使う。", "terms": [["check", "独立したアサーション。失敗は警告となりapplyを妨げない。"]], "think": "健康診断の「要観察」通知(check)。手術中止(precondition失敗)まではしない。", "snippet": "check \"api_health\" {\n  data \"http\" \"example\" {\n    url = \"https://example.com/health\"\n  }\n\n  # 失敗しても警告どまりで apply は止まらない\n  assert {\n    condition     = data.http.example.status_code == 200\n    error_message = \"health エンドポイントが 200 を返していません。\"\n  }\n}", "vs": "適用を止めるのはprecondition/postcondition。型検証はvalidation。削除禁止はprevent_destroy。", "opt": ["正解。警告のみでapplyは止めない。", "強制的に失敗させるのはpre/postcondition。", "型検証はvariableのvalidation。", "削除禁止はlifecycleのprevent_destroy。"]}'),

  ('terraform-associate-q26', '4. 構成(HCL)',
   '機密値をstateやplanに一切残さないための手法として正しいものを2つ選べ。',
   NULL,
   '["write-only 引数を使う", "ephemeral な値/リソースを使う", "sensitive = true を付ける", "-var オプションでコマンドラインから渡す"]', 0, '[0,1]', 'multi',
   '{"asked": "sensitiveとwrite-only/ephemeralの本質的な違いを理解しているか。", "why_asked": "stateに秘密が平文で残ることは、現実に漏洩事故を生んできた。隠せた気になるのが最も危険な誤解であり、試験は表示を伏せる機能と保存そのものを避ける機能を並べて、どこまで守れているのかを正確に線引きさせにくる。", "kid": "sensitiveは「画面で隠す」だけでstateには平文で残る。stateに残さないのはwrite-only/ephemeral。", "terms": [["write-only引数", "値をstate/planに保存しない書き込み専用の引数(1.11+)。"], ["ephemeral", "実行中だけ存在しstate/planに保存されない値/リソース(1.10+)。"]], "think": "sensitiveは黒塗り(見えないが書類には書いてある)。write-only/ephemeralは「そもそも書類に残さない」。", "vs": "sensitive=trueや-varはstateへの平文保存を防げない。保存回避はwrite-only/ephemeral。", "opt": ["正解。write-only引数はstate/planに残さない。", "正解。ephemeralは実行中のみでstateに残さない。", "sensitiveは表示を隠すだけでstateには平文で残る。", "-var渡しでもstateには平文で保存され得る。"]}'),

  ('terraform-associate-q27', '4. 構成(HCL)',
   '「sensitive = true を付けた変数は、stateファイルに保存されない」——この記述は正しいか。',
   NULL,
   '["誤り", "正しい"]', 0, '[0]', 'single',
   '{"asked": "sensitiveの誤解(stateには平文)を正せるか。", "why_asked": "守れているように見える機能ほど油断を生む。画面で伏せ字になれば安全だと錯覚した受験者は、平文の値を抱えたstateを共有ストレージに置いてしまう。試験はあえて断定文の正誤を問い、その思い込みをその場で剥がしにきている。", "kid": "sensitiveはログや画面での表示を隠すだけ。stateの中身は平文のまま。", "terms": [["sensitive", "出力やログでの表示を秘匿する属性。stateの平文保存は防がない。"]], "think": "レシートの一部を手で隠して見せても、レシート原本(state)には金額が印字されている。", "snippet": "variable \"db_password\" {\n  type      = string\n  sensitive = true  # 画面やログでは隠れるが、state には平文で保存される\n}", "vs": "state保存を避けたいならwrite-only/ephemeral。sensitiveは表示秘匿のみ。", "opt": ["正解。stateには平文で残るため記述は誤り。", "sensitiveでもstateには平文で残るため不適切。"]}'),

  ('terraform-associate-q28', '4. 構成(HCL)',
   'Terraformが参照から自動推論できない依存関係を、明示的に宣言するメタ引数はどれか。',
   NULL,
   '["depends_on", "lifecycle", "for_each", "provisioner"]', 0, '[0]', 'single',
   '{"asked": "暗黙依存と明示依存(depends_on)を区別できるか。", "why_asked": "参照関係から依存グラフを組み立てるのがTerraformの基本で、depends_onは推論が届かない例外を補う道具にすぎない。乱用すれば並列実行が損なわれ記述と実態もずれる。試験はこの原則と例外の順番を取り違えていないか見ている。", "kid": "普段は参照(A.idをBが使う等)で順番を推論する。参照が無いのに順番を守らせたい時だけdepends_on。", "terms": [["depends_on", "参照では表せない依存を明示するメタ引数。"]], "think": "普通は「材料を使う」流れで順番が決まる。関係が見えない作業に「これは先にやって」と手動で札を付ける。", "snippet": "resource \"aws_s3_bucket\" \"example\" {\n  bucket = \"my-bucket\"\n}\n\nresource \"aws_instance\" \"app\" {\n  ami           = \"ami-0123456789abcdef0\"\n  instance_type = \"t3.micro\"\n\n  # 参照は無いが、バケットを先に作らせる\n  depends_on = [aws_s3_bucket.example]\n}", "vs": "lifecycleは作成/削除の振る舞い/for_eachは反復/provisionerは実行。明示依存はdepends_on。", "opt": ["正解。明示的依存はdepends_on。", "lifecycleは置換等の振る舞い制御。", "for_eachは反復生成。", "provisionerは作成後の処理実行。"]}'),

  ('terraform-associate-q29', '5. モジュール',
   'モジュールの version 引数が使えるのは、どのソースから取得する場合か。',
   NULL,
   '["Terraformレジストリ(公開/HCPプライベート)のモジュール", "Gitリポジトリを直接指定したモジュール", "ローカルパス(./modules/...)のモジュール", "任意のHTTP URLで配布されるモジュール"]', 0, '[0]', 'single',
   '{"asked": "versionが有効なソース種別を知っているか。", "why_asked": "版指定はどこでも同じように効くと思い込むと、Gitやローカル参照のまま版が固定できていないことに気づけない。試験はソースの種類ごとに固定の手段が変わるという実務上の落とし穴を、素直な問い方で確かめにくる。", "kid": "versionが効くのはレジストリ経由の時だけ。Gitやローカルはソース側でタグ/パスを指定する。", "terms": [["module version", "レジストリ由来モジュールに対する版制約引数。"]], "think": "公式ストア(レジストリ)なら「v2.1を入れて」と版指定できる。手渡し(Git/local)は自分でどの版か決める。", "snippet": "# ○ レジストリ由来なら version が使える\nmodule \"vpc\" {\n  source  = \"terraform-aws-modules/vpc/aws\"\n  version = \"~> 5.0\"\n}\n\n# ✗ Git は version 不可。source 側で ref= を使う\nmodule \"vpc_git\" {\n  source = \"git::https://example.com/vpc.git?ref=v1.2.0\"\n}", "vs": "Gitはref=でタグ指定/localは版概念なし。version引数はレジストリ専用。", "opt": ["正解。versionはレジストリ由来で有効。", "Gitはref引数でタグ/ブランチを指定する。", "ローカルパスに版制約は使えない。", "任意HTTPのversion引数は不可。"]}'),

  ('terraform-associate-q30', '5. モジュール',
   '子モジュールへ値を渡し、子モジュールから結果を受け取る正しい仕組みはどれか。',
   NULL,
   '["入力は input variables、出力は output values を用いる", "親子でstateファイルを直接共有して値を受け渡す", "共有のproviderブロックを経由して値を受け渡す", "外部のdata sourceを経由して値を受け渡す"]', 0, '[0]', 'single',
   '{"asked": "モジュールの入出力インターフェースを理解しているか。", "why_asked": "モジュールが部品として再利用できるのは、外とのやり取りが入口と出口だけに絞られているから。裏口で値を渡す設計は結合を強め、モジュールという単位の意味を壊す。試験は抜け道を並べて、境界の感覚があるかを測ってくる。", "kid": "子に渡すのは変数(入力)、子から返すのはoutput(出力)。この2つが窓口。", "terms": [["input variable", "モジュールへの入力口。"], ["output value", "モジュールからの出力口。"]], "think": "関数の引数(入力変数)と戻り値(output)。stateやproviderで裏渡しするものではない。", "snippet": "module \"vpc\" {\n  source     = \"./modules/vpc\"\n  cidr_block = \"10.0.0.0/16\"  # 入力: 子の input variable へ渡す\n}\n\noutput \"vpc_id\" {\n  value = module.vpc.vpc_id  # 出力: 子の output value を受け取る\n}", "vs": "state共有/provider経由/data経由はいずれもモジュールの正規インターフェースではない。", "opt": ["正解。変数=入力、output=出力。", "stateの直接共有は正規手段ではない。", "provider経由の値渡しではない。", "data経由は既存参照であり親子受け渡しではない。"]}'),

  ('terraform-associate-q31', '5. モジュール',
   'モジュール内で宣言した入力変数のスコープとして正しいものはどれか。',
   NULL,
   '["そのモジュール内でのみ有効で、親からは明示的に渡す必要がある", "ルート含む全モジュールでグローバルに共有される", "宣言すると自動的に親モジュールへ継承される", "環境変数として自動的に公開される"]', 0, '[0]', 'single',
   '{"asked": "モジュールの変数スコープ(局所)を理解しているか。", "why_asked": "値が勝手に降ってくると期待した時点で、モジュールは独立した部品でなくなる。明示的に渡すという不便さこそ再利用性の裏付けであり、試験はグローバル共有や自動継承といった「楽な仕組み」への願望を選ばせて潰しにくる。", "kid": "変数はそのモジュールの中だけの話。親から渡さない限り値は入らない。", "terms": [["変数スコープ", "変数が有効な範囲。モジュール境界で閉じる。"]], "think": "部屋(モジュール)の中の張り紙は、その部屋でしか通用しない。他の部屋へは持って行って渡す必要がある。", "vs": "グローバル共有/自動継承/環境変数化はいずれも誤り。境界をまたぐ時は明示的に渡す。", "opt": ["正解。モジュール内に閉じ、明示的に渡す。", "グローバル共有はされない。", "自動継承はされない。", "環境変数に自動公開はされない。"]}'),

  ('terraform-associate-q32', '5. モジュール',
   '公開Terraformレジストリのモジュールを参照するsourceの正しい書式はどれか。',
   NULL,
   '["source = \"terraform-aws-modules/vpc/aws\"", "source = \"https://registry.terraform.io/vpc\"", "source = \"registry:vpc/aws\"", "source = \"aws::vpc::latest\""]', 0, '[0]', 'single',
   '{"asked": "レジストリのソース記法(namespace/name/provider)を知っているか。", "why_asked": "レジストリの参照は決まった三段構造で解決され、それらしいURLを貼れば動くという世界ではない。試験は紛らわしい書式を複数並べ、公開モジュールを実際にinitで取得した経験があるかどうかを見分けようとしている。", "kid": "公開レジストリは「作者名/モジュール名/プロバイダ名」の3段スラッシュで書く。", "terms": [["レジストリソース", "NAMESPACE/NAME/PROVIDER 形式の参照。"]], "think": "住所を「県/市/町」の3段で書くのと同じ決まった並び。URL丸ごとや独自スキームではない。", "snippet": "module \"vpc\" {\n  # namespace / name / provider の3段\n  source  = \"terraform-aws-modules/vpc/aws\"\n  version = \"~> 5.0\"\n}", "vs": "生URLや独自スキームは不可。3段スラッシュのレジストリ記法が正。", "opt": ["正解。namespace/name/provider形式。", "生URL指定はレジストリ記法ではない。", "registry:プレフィックスは無効。", "::区切りの独自表記は無効。"]}'),

  ('terraform-associate-q33', '5. モジュール',
   'レジストリモジュールを安定運用するため、versionにはどの制約を使うのが定石か。',
   NULL,
   '["~> 3.1 のような悲観的制約で許容範囲を絞る", "常に latest を指す", ">= 3.1 のみで上限を設けない", "制約を書かず毎回最新を取得する"]', 0, '[0]', 'single',
   '{"asked": "悲観的バージョン制約(~>)の意図を理解しているか。", "why_asked": "上限を書かない指定は、ある日入り込む破壊的更新で構成を壊す。再現性を最優先するのがHashiCorpの一貫した立場であり、試験はlatestや制約なしという手軽さを正解らしく並べて、更新の管理を放棄していないか試してくる。", "kid": "~>は「上位の互換範囲だけ許す」書き方。予期せぬ破壊的更新を避けつつ小さな修正は取り込む。", "terms": [["~>", "悲観的制約。指定桁までは固定し、末尾のみ上げ幅を許す。"]], "think": "~> 3.1 は「3.x系の3.1以上」まで。4.0(破壊的)は勝手に入らない安全柵。", "snippet": "module \"vpc\" {\n  source  = \"terraform-aws-modules/vpc/aws\"\n  version = \"~> 3.1\"  # 3.1 以上 4.0 未満(3.x 系のみ許可)\n}", "vs": "latest/上限なし/制約なしは破壊的更新を招く。~>で範囲を絞るのが定石。", "opt": ["正解。~>で互換範囲に限定する。", "latestは予期せぬ更新を招く。", "上限なしは破壊的更新を防げない。", "制約なしは再現性を損なう。"]}'),

  ('terraform-associate-q34', '6. State管理',
   'リモートバックエンドを設定するために記述するブロックはどれか。',
   NULL,
   '["terraformブロック内の backend \"s3\" { ... }", "providerブロック内の backend 引数", "resource \"backend\" ブロック", "terraform_remote_state data ソース"]', 0, '[0]', 'single',
   '{"asked": "backendの宣言場所を知っているか。", "why_asked": "stateの置き場所は構成全体の前提であって、個々のプロバイダ設定と同列に語る話ではない。試験は宣言場所を取り違える受験者を狙い、名前のよく似た他state参照用のdataを添えてくる。設定と参照の区別が問われている。", "kid": "stateの保管先(バックエンド)は terraform ブロックの中の backend に書く。", "terms": [["backend", "stateの保管と操作方式を定める設定。"]], "think": "荷物の預け先(backend)は、契約書の決まった欄(terraformブロック)に書く。", "snippet": "terraform {\n  backend \"s3\" {\n    bucket = \"my-tfstate\"\n    key    = \"prod/terraform.tfstate\"\n    region = \"us-east-1\"\n  }\n}", "vs": "terraform_remote_stateは他stateの出力を「読む」data。設定場所はterraformブロックのbackend。", "opt": ["正解。terraformブロック内のbackendで設定。", "providerのbackend引数は存在しない。", "backendというresource種別はない。", "terraform_remote_stateは読み取り用のdata。"]}'),

  ('terraform-associate-q35', '6. State管理',
   'state locking(状態ロック)の主な目的はどれか。',
   NULL,
   '["同時実行によるstateの破損を防ぐ", "stateファイルを暗号化する", "差分計算を高速化する", "IAM権限を管理する"]', 0, '[0]', 'single',
   '{"asked": "state lockingの目的を理解しているか。", "why_asked": "stateはチーム全員が同じ台帳を見ている前提で成り立ち、壊れた瞬間に復旧はほぼ手作業になる。試験は破損を起きてから直すのではなく起こさない設計を求める。暗号化など別の便利機能を並べ、ロックが守る対象を取り違えないか試している。", "kid": "2人が同時にapplyしてstateが壊れないよう、作業中は鍵をかける。", "terms": [["state locking", "操作中に他の書き込みを排他する仕組み。"]], "think": "トイレの「使用中」札(ロック)。中の人がいる間は他が入れず、衝突しない。", "vs": "暗号化・高速化・権限管理は別機能。ロックは同時書き込みの排他が目的。", "opt": ["正解。同時実行での破損防止。", "暗号化はロックの目的ではない。", "高速化とは無関係。", "権限管理はIAM/ポリシーの領域。"]}'),

  ('terraform-associate-q36', '6. State管理',
   '追加リソースを別途用意しなくても state locking をネイティブに提供する保管先を2つ選べ。',
   NULL,
   '["HCP Terraform のリモートバックエンド", "Google Cloud Storage(GCS)バックエンド", "ローカルバックエンド単体での運用", "-lock=false を付けて実行する運用"]', 0, '[0,1]', 'multi',
   '{"asked": "ネイティブにロックを持つバックエンドを把握しているか。", "why_asked": "バックエンド選定は後から運用でカバーが効かない。追加リソース無しでロックが効くかは安全性を直接左右するので、標準装備の差を覚えているかが問われる。-lock=falseのような、動かすための回避策を正解に見せる罠も定番。", "kid": "HCPやGCSは最初からロック機能つき。ローカル単体や-lock=falseはロックにならない。", "terms": [["ネイティブロック", "バックエンド自体が持つロック機能。"]], "think": "鍵が最初から付いているロッカー(HCP/GCS)と、鍵無し/鍵を外した状態(ローカル/-lock=false)。", "vs": "S3は従来DynamoDB併用(近年はネイティブ対応も)/-lock=falseはロック無効化。HCP・GCSは標準装備。", "opt": ["正解。HCPは標準でロックを提供。", "正解。GCSはネイティブにロックを提供。", "ローカル単体は堅牢なロックを前提にできない。", "-lock=falseはロックを無効化する指定。"]}'),

  ('terraform-associate-q37', '6. State管理',
   '誰かがコンソールから手動変更したことで生じた設定ドリフトを検出したい。最も適した操作はどれか。',
   NULL,
   '["terraform plan または refresh-only で実態との差分を表示する", "terraform fmt で構成ファイルを標準書式に整形する", "terraform validate で構文と内部整合性を検証する", "terraform import で既存リソースを取り込む"]', 0, '[0]', 'single',
   '{"asked": "ドリフト検出の方法を理解しているか。", "why_asked": "手動変更の放置は次のapplyでの意図しない上書きにつながる、現場で最も多い事故の入口。試験はコマンド名を暗記しただけの受験者を、fmtやvalidateという頻繁に打つが目的の違うコマンドで揺さぶってくる。", "kid": "planを走らせると「構成」と「実際」のズレが出る。それがドリフトの検出。", "terms": [["ドリフト", "構成と実インフラの乖離。"], ["refresh-only", "構成は変えずstateだけ実態に合わせるモード。"]], "think": "持ち物リスト(構成)と実際のカバン(インフラ)を照合(plan)して、増減(ドリフト)を見つける。", "snippet": "# 構成と実インフラのズレ(ドリフト)を表示する\nterraform plan\n\n# stateの実態同期だけを確認したい場合\nterraform plan -refresh-only", "vs": "fmtは整形/validateは構文/importは取り込み。差分検出はplanまたはrefresh-only。", "opt": ["正解。planで差分としてドリフトが見える。", "fmtは書式整形で差分検出ではない。", "validateは構文検証のみ。", "importは新規取り込みでドリフト検出ではない。"]}'),

  ('terraform-associate-q38', '6. State管理',
   'リソースを再作成せずに、state上のアドレス変更(リファクタ)を安全に行う宣言的方法はどれか。',
   NULL,
   '["moved ブロック", "removed ブロック", "import ブロック", "prevent_destroy"]', 0, '[0]', 'single',
   '{"asked": "movedブロックの用途をremoved/importと区別できるか。", "why_asked": "Terraformはアドレスが変われば別物とみなすので、名前を直しただけのつもりが再作成になり本番が落ちる。試験はstate mvのような手続き的操作より、意図が構成に残りレビューできる宣言的なやり方を一貫して上位に置く。", "kid": "名前を付け替えるだけ(実物は同じ)ならmoved。作り直しを避けられる。", "terms": [["moved", "stateアドレスの変更を宣言し再作成を防ぐブロック。"]], "think": "同じ商品の棚番号(アドレス)だけ書き換える作業。商品自体(実リソース)は動かさない。", "snippet": "# 実リソースは再作成せず、state上のアドレスだけ移す\nmoved {\n  from = aws_instance.old\n  to   = aws_instance.new\n}", "vs": "removedは管理から外す/importは取り込み/prevent_destroyは削除防止。アドレス変更はmoved。", "opt": ["正解。再作成せずアドレスを移すのはmoved。", "removedは管理からの除外で用途が違う。", "importは新規取り込み。", "prevent_destroyは削除防止でリファクタではない。"]}'),

  ('terraform-associate-q39', '6. State管理',
   '実インフラは削除せずにTerraform管理からだけ外したい(宣言的な方法)。使うのはどれか。',
   NULL,
   '["removed ブロック", "moved ブロック", "terraform destroy", "lifecycle の create_before_destroy"]', 0, '[0]', 'single',
   '{"asked": "removedブロックの効果(実体は残す)を理解しているか。", "why_asked": "管理から外すのと消すのは結果が正反対なのに、選択を誤れば本番リソースが戻らない。この取り返しのつかなさを重く見るからこそ、destroyという一見それらしい操作を並べて判断を試す構図になっている。", "kid": "removedは「管理表からだけ消す」。実物はそのまま残す。destroyは実物ごと消える。", "terms": [["removed", "stateから除外しつつ実リソースは破棄しないブロック(1.7+)。"]], "think": "社員名簿から名前を消す(管理外)だけで、その人がいなくなる(destroy)わけではない。", "snippet": "# 実インフラは残したまま、Terraform管理からだけ外す\nremoved {\n  from = aws_instance.example\n\n  lifecycle {\n    destroy = false\n  }\n}", "vs": "destroyは実削除/movedはアドレス変更/create_before_destroyは置換順序。管理外し(実体維持)はremoved。", "opt": ["正解。実体を残し管理からのみ除外。", "movedはアドレス変更で除外ではない。", "destroyは実リソースも削除する。", "create_before_destroyは置換時の順序制御。"]}'),

  ('terraform-associate-q40', '6. State管理',
   'refresh-only モードの用途として正しいものはどれか。',
   NULL,
   '["実態に合わせてstateだけ更新し、構成による変更は行わない", "構成に合わせて実インフラのリソースを変更する", "stateファイルを完全に削除して初期化する", "実行計画をファイルに保存して後で適用する"]', 0, '[0]', 'single',
   '{"asked": "refresh-onlyの効果を理解しているか。", "why_asked": "planは差分を見せると同時にapplyへ進む道でもある。実インフラに一切触れずstateだけを実態へ寄せたい場面があるという運用感覚が問われ、同期と変更を混同する層を狙って通常applyの説明が置かれている。", "kid": "実物に合わせて「台帳(state)だけ」直すモード。実物には手を出さない。", "terms": [["refresh-only", "stateを実態に同期させるだけのモード。"]], "think": "在庫を数え直して帳簿(state)を実数に合わせる。商品(インフラ)は動かさない。", "snippet": "# 実インフラは変更せず、stateだけを実態に合わせる\nterraform plan -refresh-only\nterraform apply -refresh-only", "vs": "インフラ変更は通常のapply/state削除でも計画保存でもない。stateの同期がrefresh-only。", "opt": ["正解。stateのみ実態に同期する。", "インフラ変更は通常のapplyの役割。", "state削除ではない。", "計画保存はplan -outの役割。"]}'),

  ('terraform-associate-q41', '7. インフラ保守',
   '既存の実リソースをTerraform管理下に取り込む、宣言的な方法(1.5+)はどれか。',
   NULL,
   '["import ブロック(to と id を記述)", "moved ブロック", "terraform state push", "data ソースとして参照する"]', 0, '[0]', 'single',
   '{"asked": "宣言的import(ブロック)を旧来のCLIやmovedと区別できるか。", "why_asked": "かつてのimportはCLIで取り込み構成は手書きという分断があった。ブロック化されたのは取り込みもplanでレビューしてから適用するというコアワークフローに揃えるためで、新しい作法へ知識を更新できているかを測る。", "kid": "取り込みたい対象と実IDをimportブロックに書けば、plan/applyの流れで取り込める。", "terms": [["import block", "toとidで既存リソースをstateへ取り込む宣言的構文(1.5+)。"]], "think": "既にある家(実リソース)を、図面(構成)の管理台帳に「これは我々の管理下」と登録する作業。", "snippet": "# to = 取り込み先アドレス, id = 実リソースのID\nimport {\n  to = aws_instance.example\n  id = \"i-0123456789abcdef0\"\n}", "vs": "movedはアドレス変更/state pushはstate丸ごと投入/dataは参照のみ。取り込みはimportブロック。", "opt": ["正解。to/id指定の宣言的import。", "movedは既存管理内のアドレス変更。", "state pushはstate全体の上書きで危険な別操作。", "dataは参照で、管理下への取り込みではない。"]}'),

  ('terraform-associate-q42', '7. インフラ保守',
   'import ブロックと組み合わせ、取り込むリソースの構成(HCL)を自動生成させるコマンドはどれか。',
   NULL,
   '["terraform plan -generate-config-out=FILE", "terraform show -json", "terraform apply -auto-approve", "terraform init -upgrade"]', 0, '[0]', 'single',
   '{"asked": "import時の構成自動生成フラグを知っているか。", "why_asked": "既存リソースの属性を手書きで再現する作業量こそが、Terraform移行を頓挫させる最大の壁。試験は取り込みを言葉として知っているかではなく実際に完遂できるかを見ており、頻出コマンドを並べて記憶の曖昧さを突く。", "kid": "importブロックを書いてplanに-generate-config-outを付けると、対応するHCLの雛形を出力してくれる。", "terms": [["-generate-config-out", "importブロック対象の構成を生成出力するplanオプション。"]], "think": "取り込む家の「間取り図」を自動で起こしてくれる機能。あとは細部を手直しする。", "snippet": "# importブロックを書いた上で実行すると、対応するHCLが生成される\nterraform plan -generate-config-out=generated.tf", "vs": "showは表示/applyは適用/init -upgradeはプロバイダ更新。構成生成はplanの当該フラグ。", "opt": ["正解。planの-generate-config-outで生成。", "showは既存内容の表示のみ。", "applyは適用で生成機能ではない。", "init -upgradeはプロバイダ版の更新。"]}'),

  ('terraform-associate-q43', '7. インフラ保守',
   'state内で管理されているリソースの一覧(アドレス)を確認するコマンドはどれか。',
   NULL,
   '["terraform state list", "terraform state show", "terraform output", "terraform show -json"]', 0, '[0]', 'single',
   '{"asked": "state listとstate showを区別できるか。", "why_asked": "state操作は事故と隣り合わせで、まず現状を正しく読むことから始まる。試験は名前の近いサブコマンドを並べ、全体を俯瞰するのか一点を掘るのかという粒度で道具を選び分ける感覚が身についているかを確認している。", "kid": "一覧を見るのがstate list、1個の中身を見るのがstate show。", "terms": [["state list", "管理下リソースのアドレス一覧を表示。"]], "think": "listは目次(全体の見出し)、showは各ページの本文。用途が違う。", "snippet": "# state内のリソースアドレスを一覧表示\nterraform state list", "vs": "showは単一の詳細/outputは出力値/show -jsonは全体構造。一覧はstate list。", "opt": ["正解。アドレス一覧はstate list。", "state showは単一リソースの詳細。", "outputは定義した出力値の表示。", "show -jsonは計画/状態全体の構造出力。"]}'),

  ('terraform-associate-q44', '7. インフラ保守',
   'state内の特定リソース1件の属性を詳細に確認するコマンドはどれか。',
   NULL,
   '["terraform state show <ADDRESS>", "terraform state list", "terraform output <NAME>", "terraform plan"]', 0, '[0]', 'single',
   '{"asked": "単一リソースの詳細確認手段を知っているか。", "why_asked": "実際に適用されている属性値はstateにしか残っておらず、障害調査はそこが起点になる。差分を見るplanや値を取り出すoutputと混ぜることで、欲しい情報がどこにあるかを言い当てられるかを試す狙いがある。", "kid": "1個のリソースの中身(属性)を見たいならstate showにアドレスを渡す。", "terms": [["state show", "指定アドレスの属性を詳細表示。"]], "think": "名簿の一覧(list)から1人を選び、その人の詳細プロフィール(show)を開く。", "snippet": "# アドレスを指定して単一リソースの属性を表示\nterraform state show aws_instance.example", "vs": "listは一覧/outputは出力値/planは差分。単一詳細はstate show。", "opt": ["正解。単一リソースの詳細はstate show。", "listは一覧表示に留まる。", "outputは出力値であって属性詳細ではない。", "planは差分表示。"]}'),

  ('terraform-associate-q45', '7. インフラ保守',
   'Terraformの詳細ログを有効化するために設定する環境変数はどれか(値の例: DEBUG)。',
   'export ____=DEBUG
terraform apply',
   '["TF_LOG", "TF_DEBUG", "TERRAFORM_LOG", "LOG_LEVEL"]', 0, '[0]', 'single',
   '{"asked": "ログ有効化の環境変数(TF_LOG)を知っているか。", "why_asked": "プロバイダ絡みの不具合はログを出せなければ原因究明が止まる。これは調べれば分かるのではなく手を動かした経験がないと当てられない知識で、もっともらしい別名を並べて実務の有無をふるいにかけている。", "kid": "TF_LOGにTRACEやDEBUGを入れると詳しいログが出る。", "terms": [["TF_LOG", "ログ詳細度を指定する環境変数(TRACE/DEBUG/INFO/WARN/ERROR)。"]], "think": "カメラの「詳細記録モード」をONにするスイッチがTF_LOG。似た名前は罠。", "snippet": "# TRACE / DEBUG / INFO / WARN / ERROR が指定できる\nexport TF_LOG=DEBUG\nterraform apply", "vs": "TF_DEBUG/TERRAFORM_LOG/LOG_LEVELは無効。正しくはTF_LOG。", "opt": ["正解。TF_LOGでログ詳細度を指定。", "TF_DEBUGという変数は存在しない。", "TERRAFORM_LOGは無効。", "LOG_LEVELは無効。"]}'),

  ('terraform-associate-q46', '7. インフラ保守',
   '詳細ログの出力先をファイルに指定する環境変数はどれか。',
   NULL,
   '["TF_LOG_PATH", "TF_LOG_FILE", "TF_OUT", "TF_LOG_DEST"]', 0, '[0]', 'single',
   '{"asked": "ログ出力先の環境変数を知っているか。", "why_asked": "画面に流れるログはCIや長時間のapplyでは追いきれず、残さなければ意味がない。有効化と保存先を担う二つの変数が対で使われる設計を理解しているかが問われ、片方しか覚えていない受験者が落ちる。", "kid": "ログをファイルに残すならTF_LOG_PATHにパスを設定する。", "terms": [["TF_LOG_PATH", "ログの出力先ファイルを指定する環境変数。"]], "think": "録画データの「保存先フォルダ」を指定するのがTF_LOG_PATH。TF_LOG(ON/OFF)とセットで使う。", "snippet": "# TF_LOG とセットで使い、ログをファイルに出力する\nexport TF_LOG=DEBUG\nexport TF_LOG_PATH=./terraform.log\nterraform apply", "vs": "TF_LOG_FILE/TF_OUT/TF_LOG_DESTは無効。出力先はTF_LOG_PATH。", "opt": ["正解。出力先はTF_LOG_PATH。", "TF_LOG_FILEは存在しない。", "TF_OUTは無効。", "TF_LOG_DESTは無効。"]}'),

  ('terraform-associate-q47', '8. HCP Terraform',
   'HCP Terraformで、環境(dev/stg/prod)やチーム単位に複数ワークスペースをグループ化する上位単位はどれか。',
   NULL,
   '["プロジェクト(Projects)", "変数セット(Variable sets)", "実行トリガー(Run triggers)", "組織直下にワークスペースを平置きする"]', 0, '[0]', 'single',
   '{"asked": "projectsとworkspaceの階層関係を理解しているか。", "why_asked": "ワークスペースが増えるほど権限管理と見通しが破綻するため、HCPは組織・プロジェクト・ワークスペースという階層で統制する。試験はこの構造を、変数共有や連鎖実行という別レイヤーの機能と混同しないかを試す。", "kid": "ワークスペースを束ねる「フォルダ」がプロジェクト。dev/prodやチーム単位に整理できる。", "terms": [["Project", "複数ワークスペースをまとめる組織単位。"]], "think": "個々の書類(ワークスペース)を、案件別のバインダー(プロジェクト)に綴じるイメージ。", "vs": "変数セットは値の共有/run triggersは連鎖実行。グループ化の単位はプロジェクト。", "opt": ["正解。ワークスペースの束はプロジェクト。", "変数セットは値の共有機能でグループ化単位ではない。", "run triggersは実行連鎖であって整理単位ではない。", "平置きは整理にならない。"]}'),

  ('terraform-associate-q48', '8. HCP Terraform',
   'HCP Terraformでの実行(run)の起動方式として正しいものを2つ選べ。',
   NULL,
   '["VCS駆動(リポジトリのpush等をトリガー)", "CLI駆動(ローカルからterraformコマンドで起動)", "手元でterraform.tfstateを手動アップロードして起動", "GCEのcronでローカルバイナリを定期実行"]', 0, '[0,1]', 'multi',
   '{"asked": "HCPのrun起動方式(VCS/CLI/API)を把握しているか。", "why_asked": "HCPの価値は実行を個人のPCから引き剥がし、記録と権限が残る場所へ移すことにある。入口が定義されているのはそのためで、stateを手で持ち込むような統制を捨てる発想が誤答として用意されている。", "kid": "HCPの実行は、Git連携(VCS)か、手元CLIか、API経由で起こす。手動state投入やcronは起動方式ではない。", "terms": [["VCS駆動", "リポジトリのイベントでrunを起動する方式。"], ["CLI駆動", "ローカルCLIからHCP上でrunを起動する方式。"]], "think": "工場のライン(run)を動かすスイッチはVCS/CLI/APIの3種。倉庫に在庫を放り込む(state投入)のは起動ではない。", "vs": "state手動投入やcronは正規のrun起動ではない。VCS/CLI(/API)が正。", "opt": ["正解。VCS駆動はrunの正規起動方式。", "正解。CLI駆動も正規の起動方式。", "state手動アップロードはrun起動ではない。", "cron実行はHCPのrun起動方式ではない。"]}'),

  ('terraform-associate-q49', '8. HCP Terraform',
   '複数ワークスペースで共通の変数群を一元管理して適用したい。使う機能はどれか。',
   NULL,
   '["変数セット(Variable sets)", "各ワークスペースで terraform.tfvars を個別複製する", "実行トリガー(Run triggers)", "プロジェクト(Projects)"]', 0, '[0]', 'single',
   '{"asked": "Variable setsの用途を理解しているか。", "why_asked": "同じ値を各所にコピーすれば更新漏れは必ず起き、認証情報なら事故に直結する。重複を排して一箇所で管理する思想が評価軸にあり、tfvarsの個別複製という動くが確実に破綻する道をあえて自然に見せている。", "kid": "同じ変数を複数のワークスペースに一括で効かせる仕組みが変数セット。", "terms": [["Variable sets", "複数ワークスペース/プロジェクトに共通変数を適用する機能。"]], "think": "共通の社内ルール(変数)を、各部署(ワークスペース)へ一括配布する回覧板。", "vs": "tfvars個別複製は重複管理で非効率/run triggersは連鎖/projectsは整理単位。共通変数はVariable sets。", "opt": ["正解。共通変数の一元管理はVariable sets。", "個別複製は一元管理にならない。", "run triggersは実行連鎖の機能。", "projectsは整理単位で変数共有機能ではない。"]}'),

  ('terraform-associate-q50', '8. HCP Terraform',
   'あるワークスペースのapply成功を、別ワークスペースの実行の引き金にしたい。使う機能はどれか。',
   NULL,
   '["実行トリガー(Run triggers)", "変数セット(Variable sets)", "depends_on メタ引数", "VCSのwebhookを直接設定する"]', 0, '[0]', 'single',
   '{"asked": "Run triggersの用途をVariable sets等と区別できるか。", "why_asked": "ネットワークを作ってからアプリ、といった環境をまたぐ順序は単一構成の依存では表現できない。ワークスペース境界の外に別次元の順序制御があると認識しているかが問われ、depends_onを持ち出す誤りを誘っている。", "kid": "上流のapply成功で下流を自動起動する連鎖がrun triggers。ワークスペースをまたぐ順番付け。", "terms": [["Run triggers", "上流ワークスペースの完了で下流runを自動起動する機能。"]], "think": "ドミノ倒し。前のワークスペース(牌)が倒れる(apply成功)と次が倒れる(run起動)。", "vs": "Variable setsは変数共有/depends_onは単一構成内の依存/webhook直設定は正規手段でない。連鎖はrun triggers。", "opt": ["正解。ワークスペース間の連鎖はrun triggers。", "Variable setsは変数共有で連鎖ではない。", "depends_onは同一構成内の依存で用途が違う。", "webhook直設定はHCPの正規の連鎖手段ではない。"]}')

) AS v(source_ref, cat_name, question_text, code, options, correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.cat_name
WHERE s.slug = 'terraform-associate'
ON CONFLICT (subject_id, source_ref) DO NOTHING;
