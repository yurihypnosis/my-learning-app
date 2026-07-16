-- Terraform Associate (004) Set B — 科目・カテゴリ + 問題 1〜16 / 2026-07-16
--
-- Set A(50問)と重複しない範囲を狙う。公式の Exam Content List (004) を参照し、
-- Set A が手付かずだった 4e(関数・式)、4f(create_before_destroy)、6a(ローカルバックエンド)、
-- CLIワークスペース、変数の優先順位、Sentinel/OPA、動的プロバイダ認証情報などを厚めに配分。
-- 004 は現行版（003 は 2026-01-08 に廃止、対象 Terraform 1.12）。
--
-- 誤答は実在するコマンド/構文/機能の近縁ペアで構成し、正解と字数を揃える。
-- 「何もしない」「目視で確認」のような投げやりな誤答は置かない。
BEGIN;

-- ===== 科目 =====
INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('terraform-associate-b',
        'HashiCorp Terraform Associate (004) — Set B',
        'HashiCorp Certified: Terraform Associate 004 対策 第2弾。Set A で手薄だった式・組み込み関数・lifecycle・変数の優先順位・CLIワークスペース・バックエンドの部分設定・HCP のポリシーと動的認証情報を厚めに配分した50問。本試験は約60分/57〜60問。本番の再現ではなく学習用オリジナル。',
        '#7B42BC', 31, true)
ON CONFLICT (slug) DO NOTHING;

-- ===== カテゴリ（Set A と同名。分野別の集計が Set をまたいで効くようにする）=====
INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('1. IaC概念',        '#58a6ff', 0),
  ('2. Terraform基礎',  '#3fb950', 1),
  ('3. コアワークフロー', '#f0883e', 2),
  ('4. 構成(HCL)',      '#a371f7', 3),
  ('5. モジュール',      '#d2a8ff', 4),
  ('6. State管理',      '#f85149', 5),
  ('7. インフラ保守',    '#e3b341', 6),
  ('8. HCP Terraform',  '#39c5cf', 7)
) AS v(name, color, sort_order)
WHERE s.slug = 'terraform-associate-b'
  AND NOT EXISTS (
    SELECT 1 FROM public.categories c WHERE c.subject_id = s.id AND c.name = v.name
  );

-- ===== 問題 1〜16 =====
INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

-- ── 1. IaC概念 ──
('terraform-associate-b-q1', '1. IaC概念',
 '同じ構成ファイルに対して terraform apply を2回続けて実行した。2回目の挙動として正しいものはどれか。',
 NULL::text,
 '["構成と実インフラに差分が無いため、変更なしと表示され何も作成されない","構成に書かれたリソースがもう一組、新規に作成される","2回目は冪等性の警告が出て、確認のうえ再作成される","stateが更新され、リソースは同じ内容で置き換えられる"]',
 0, '[0]', 'single',
 '{"asked":"宣言的なツールの冪等性を理解しているか。","why_asked":"IaCの中核は「望ましい状態を宣言する」こと。実行するたびに増えるスクリプト的な発想が抜けていないと、applyの回数で結果が変わると考えてしまう。試験はこの発想の転換ができているかを最初に確かめる。","kid":"「この状態にして」と頼んでいるので、既にその状態なら何もしない。","terms":[["冪等性","同じ操作を何度行っても結果が同じになる性質。"],["宣言的","手順ではなく望ましい最終状態を書く方式。"]],"think":"エアコンを28度に設定するのと同じ。すでに28度ならボタンを押しても何も起きない。手順書のように「+1度」を繰り返すのとは違う。","vs":"望ましい状態を宣言しているか、手順を実行しているか、が軸。差分が無ければ実行しても何も起きないのが宣言的なツールの前提。","opt":["正解。現状と望ましい状態が一致していれば差分が無く、No changes となる。","増えるのは命令的なスクリプトの発想。宣言的なツールは同じリソースを二重に作らない。","冪等であることが前提なので警告は出ないし、再作成もされない。","差分が無い以上、置き換えも state の更新も起きない。"]}'),

('terraform-associate-b-q2', '1. IaC概念',
 'Terraformのようなプロビジョニングツールと、Ansibleのような構成管理(Configuration Management)ツールの位置づけの違いとして最も適切なものはどれか。',
 NULL::text,
 '["Terraformはインフラそのものの作成・変更を担い、構成管理ツールは主に既存OS上の設定を担う","Terraformはクラウド専用で、構成管理ツールはオンプレミス専用という住み分けである","Terraformは手続き的に動き、構成管理ツールは宣言的に動くという違いがある","Terraformはエージェントを常駐させ、構成管理ツールはエージェントレスで動作する"]',
 0, '[0]', 'single',
 '{"asked":"プロビジョニングと構成管理の守備範囲の違いを理解しているか。","why_asked":"どちらもIaCと呼ばれるため混同されやすい。試験は「Terraformで何をすべきで、何をすべきでないか」の線引きを問う。ここが曖昧だと、Terraformで無理にOS設定まで抱え込む設計に走る。","kid":"Terraformは建物を建てる係、構成管理ツールは建った部屋の中を整える係。","terms":[["プロビジョニング","VPCやVMなどインフラ資源そのものを用意すること。"],["構成管理","OS上のパッケージや設定ファイルを望ましい状態に保つこと。"]],"think":"土地を用意して建物を建てるのがTerraform、部屋に家具を置いて配線するのが構成管理ツール。両者は競合ではなく分担。","vs":"担当する層が違う。クラウドかオンプレか、宣言的か手続き的か、エージェントの有無は、この2つを分ける軸ではない。","opt":["正解。Terraformはインフラの作成・変更、構成管理ツールはその上のOS設定を担う。補完関係にある。","Terraformはオンプレミスのリソースもプロバイダ経由で扱え、構成管理ツールもクラウド上のVMを扱う。","どちらも宣言的に書ける。Terraformが手続き的というのは逆で、宣言的であることが特徴。","Terraformはエージェントを常駐させない。エージェントの有無はこの2種の違いを説明しない。"]}'),

('terraform-associate-b-q3', '1. IaC概念',
 'インフラの定義をバージョン管理システムで管理することの利点として、最も適切なものはどれか。',
 NULL::text,
 '["変更が差分としてレビューでき、いつ誰が何を変えたかを追跡して過去の状態へ戻せる","構成ファイルが自動的に暗号化され、機密情報を安全に保管できる","実インフラの変更が即座に検知され、構成ファイルへ自動で反映される","Terraformの実行速度が上がり、大規模な構成でも計画時間が短縮される"]',
 0, '[0]', 'single',
 '{"asked":"IaCをバージョン管理する意義を理解しているか。","why_asked":"IaCの利点は「速くなる」ことだと思われがちだが、本質はレビューと追跡ができること。試験は性能や暗号化といった魅力的だが的外れな効能を並べ、変更を人が読める形で残すという価値を掴んでいるかを見る。","kid":"インフラの変更が、コードと同じようにプルリクエストで議論できるようになる。","terms":[["バージョン管理","変更履歴を記録し、過去の状態へ戻せる仕組み。"]],"think":"設計図が履歴付きで残っているので、誰がいつどこを変えたか遡れるし、まずければ前の版に戻せる。口頭やGUI操作にはこれが無い。","vs":"変更を人が読めて追える形にすることが本質。暗号化も、実インフラからの逆流も、実行速度も、バージョン管理がもたらすものではない。","opt":["正解。差分のレビュー、変更履歴の追跡、過去の版への切り戻しが可能になる。","バージョン管理は暗号化しない。機密はむしろ平文で入り込みやすいので別途の対策が要る。","Gitは実インフラを監視しない。実態との差分はTerraform側で検出するもの。","バージョン管理は実行速度に影響しない。"]}'),

-- ── 2. Terraform基礎 ──
('terraform-associate-b-q4', '2. Terraform基礎',
 'プロバイダのバージョン制約に version = "~> 4.2.0" と書いた場合、許容されるバージョンの範囲はどれか。',
 NULL::text,
 '["4.2.0 以上 4.3.0 未満","4.2.0 以上 5.0.0 未満","4.2.0 のみ","4.2.0 以上で上限なし"]',
 0, '[0]', 'single',
 '{"asked":"悲観的制約演算子の桁ごとの挙動を理解しているか。","why_asked":"~> は最も使われる制約でありながら、指定した桁数で許容範囲が変わる。~> 4.2 と ~> 4.2.0 の違いを知らないまま使うと、意図せず破壊的変更を取り込むか、逆にパッチも入らない。試験はこの桁の違いを狙って問う。","kid":"~> は「一番右の数字だけ上がってよい」という意味。","terms":[["~>","悲観的制約演算子。最も右の桁のみ増加を許す。"]],"think":"~> 4.2.0 は右端が 0 なので、そこだけ上がる＝4.2.x。~> 4.2 なら右端が 2 なので 4.x。指定した桁数で天井の位置が決まる。","snippet":"# ~> 4.2.0 → 4.2.0 以上 4.3.0 未満（パッチだけ許可）\nversion = \"~> 4.2.0\"\n\n# ~> 4.2   → 4.2.0 以上 5.0.0 未満（マイナーまで許可）\nversion = \"~> 4.2\"\n\n# >= 4.2.0 → 上限なし。破壊的変更も入りうる\nversion = \">= 4.2.0\"","vs":"どの桁まで固定したかが軸。~> 4.2 ならマイナーまで許すが、~> 4.2.0 と桁を増やすとパッチしか許さない。","opt":["正解。右端の桁だけ増加が許されるため 4.2.x に収まる。","それは ~> 4.2 と書いた場合の範囲。桁を1つ増やすと天井が下がる。","1つの版に固定したいなら version に 4.2.0 と等号で書く。","上限が無いのは >= 4.2.0 の挙動。"]}'),

('terraform-associate-b-q5', '2. Terraform基礎',
 'Terraform CLI 本体のバージョンに対して制約を課したい。記述する場所として正しいものはどれか。',
 NULL::text,
 '["terraformブロック内の required_version","terraformブロック内の required_providers","providerブロック内の version 引数","variableブロックの validation 条件"]',
 0, '[0]', 'single',
 '{"asked":"required_version と required_providers の対象の違いを理解しているか。","why_asked":"どちらも terraform ブロックの中にあり名前も似ているため混同されやすい。CLI本体の版とプロバイダの版は別の話で、取り違えるとチーム内で版がばらついたまま気づけない。","kid":"required_version は Terraform 本体、required_providers はプロバイダ。","terms":[["required_version","この構成を扱える Terraform CLI の版制約。"],["required_providers","使用するプロバイダの出所と版制約。"]],"think":"required_version は「このアプリを開くには本体 v1.5 以上が必要」という指定。required_providers は「使う拡張機能はこれ」という指定。対象がそもそも違う。","snippet":"terraform {\n  # Terraform CLI 本体の版制約\n  required_version = \">= 1.5.0\"\n\n  # プロバイダの出所と版制約\n  required_providers {\n    aws = {\n      source  = \"hashicorp/aws\"\n      version = \"~> 5.0\"\n    }\n  }\n}","vs":"制約の対象が本体かプロバイダか、が軸。同じ terraform ブロック内にあるが、required_version は CLI、required_providers はプロバイダを指す。","opt":["正解。required_version が Terraform CLI 本体の版制約を表す。","required_providers はプロバイダの出所と版を指定するもので、CLI本体の版ではない。","providerブロックの引数はそのプロバイダへの接続設定。版の制約はここには書かない。","validation は入力変数の値を検証する仕組みで、CLIの版とは無関係。"]}'),

('terraform-associate-b-q6', '2. Terraform基礎',
 '既にロックファイルで固定されているプロバイダについて、制約の範囲内でより新しい版へ更新したい。実行するコマンドはどれか。',
 NULL::text,
 '["terraform init -upgrade","terraform init -reconfigure","terraform providers lock","terraform refresh"]',
 0, '[0]', 'single',
 '{"asked":"ロックファイルの更新方法を知っているか。","why_asked":"init は初回だけ実行するものと思い込むと、ロックファイルが更新されず版が固定されたままになる。試験は init のフラグごとの役割を区別できるかを確かめる。","kid":"普通の init はロックに従うだけ。-upgrade を付けて初めて上を取りに行く。","terms":[["-upgrade","制約の範囲内で、より新しい版へロックを更新する。"],["-reconfigure","バックエンド設定を再構成する。state の移行はしない。"]],"think":"ロックファイルは「前回これを使った」という記録。普通の init はその記録どおりに入れるだけなので、更新したいと明示しない限り版は動かない。","snippet":"# 制約の範囲内で新しい版を取り、.terraform.lock.hcl を更新する\nterraform init -upgrade","vs":"何を更新するか、が軸。-reconfigure はバックエンド設定、providers lock は他プラットフォーム向けのハッシュ追加、refresh は state。ロックの版を上げるのは -upgrade。","opt":["正解。制約の範囲内で新しい版を取得し、ロックファイルを更新する。","-reconfigure はバックエンド設定を初期化し直すフラグで、プロバイダの版には触れない。","providers lock は他プラットフォーム向けのハッシュを足すためのもの。版を上げる目的では使わない。","refresh は state を実態へ合わせるコマンドで、プロバイダの版とは無関係。"]}'),

('terraform-associate-b-q7', '2. Terraform基礎',
 'required_providers に source = "hashicorp/aws" と書いた。このアドレスの意味として正しいものはどれか。',
 NULL::text,
 '["レジストリ上の名前空間(hashicorp)とプロバイダ名(aws)を指す短縮形である","GitHub上の organization とリポジトリ名を指している","ローカルディスク上のプラグイン配置ディレクトリを指している","プロバイダを提供するクラウドのアカウントIDとサービス名を指している"]',
 0, '[0]', 'single',
 '{"asked":"プロバイダのソースアドレスの構造を理解しているか。","why_asked":"source の文字列がGitHubのパスに見えるため取り違えやすい。実際はレジストリのアドレスで、既定のホストが省略されている。ここを誤解すると、サードパーティ製プロバイダの参照方法にも辿り着けない。","kid":"hashicorp/aws は registry.terraform.io/hashicorp/aws の省略形。","terms":[["ソースアドレス","[ホスト/]名前空間/種別 の形式でプロバイダを指す。"]],"think":"完全形は registry.terraform.io/hashicorp/aws。既定のレジストリなのでホスト部分を省略できる。GitHubのURLではない。","snippet":"terraform {\n  required_providers {\n    # 短縮形。registry.terraform.io/hashicorp/aws と同じ\n    aws = {\n      source  = \"hashicorp/aws\"\n      version = \"~> 5.0\"\n    }\n\n    # 既定以外のレジストリはホストから書く\n    example = {\n      source = \"registry.example.com/myorg/example\"\n    }\n  }\n}","vs":"レジストリ上の住所か、それ以外か、が軸。GitHubのパスにもディレクトリにも見えるが、実体は既定レジストリのアドレスの省略形。","opt":["正解。既定レジストリ上の名前空間とプロバイダ名を指す短縮形。","形は似ているがGitHubのパスではない。プロバイダはレジストリから取得される。","ローカルのプラグイン配置は別途 filesystem_mirror などで指定する。source の意味ではない。","クラウドのアカウントとは無関係。プロバイダの配布元を指すアドレス。"]}'),

('terraform-associate-b-q8', '2. Terraform基礎',
 '現在の構成とstateが、どのプロバイダのどの版に依存しているかを一覧で確認したい。最も適したコマンドはどれか。',
 NULL::text,
 '["terraform providers","terraform version","terraform show","terraform state list"]',
 0, '[0]', 'single',
 '{"asked":"プロバイダ依存の確認手段を知っているか。","why_asked":"version は CLI とプロバイダの版を出すが、どのモジュールがどのプロバイダを要求しているかまでは示さない。似た情報を返すコマンドの守備範囲を区別できるかが問われる。","kid":"terraform providers は「この構成が誰に依存しているか」の一覧。","terms":[["terraform providers","構成とstateが要求するプロバイダを、モジュール階層つきで表示する。"]],"think":"依存の一覧が欲しいのか、今入っている版が知りたいのか、で使うコマンドが変わる。前者が providers、後者が version。","snippet":"# 構成とstateが要求するプロバイダを階層つきで一覧する\nterraform providers","vs":"依存関係の一覧か、それ以外か、が軸。version は導入済みの版、show は state の中身、state list はリソースのアドレス一覧。","opt":["正解。構成とstateが要求するプロバイダを、モジュール階層つきで一覧できる。","version は CLI と導入済みプロバイダの版を表示するが、どこが要求しているかは示さない。","show は state や plan の中身を表示するコマンドで、プロバイダ依存の一覧ではない。","state list が返すのは管理下リソースのアドレス一覧。"]}'),

('terraform-associate-b-q9', '2. Terraform基礎',
 'Terraform の state ファイルに保存される内容として正しいものはどれか。',
 NULL::text,
 '["管理下リソースの実IDと属性、および構成アドレスとの対応づけ","構成ファイルのHCLそのものと、その変更履歴","プロバイダのプラグイン本体とその実行バイナリ","実行時に使われた認証情報とAPIトークン"]',
 0, '[0]', 'single',
 '{"asked":"stateが何を保持しているかを理解しているか。","why_asked":"stateを「設定のバックアップ」と誤解すると、消しても構成から作り直せると考えてしまう。実際はTerraformが管理下のリソースを見つけるための唯一の紐づけで、失えば既存リソースを見失う。","kid":"どの記述がどの実物に対応するか、の対応表。","terms":[["state","構成上のアドレスと実リソースの対応、および属性のキャッシュ。"]],"think":"構成は「何が欲しいか」、実インフラは「今あるもの」。その2つを結ぶ台帳がstate。台帳が無いとTerraformは自分が作った物を識別できない。","vs":"対応づけの台帳か、それ以外か、が軸。HCLそのものはGitに、プラグインは .terraform に、認証情報は環境や別の仕組みにある。","opt":["正解。実リソースのIDと属性、および構成アドレスとの対応が記録される。","HCLと履歴はバージョン管理システムが持つもの。stateの役割ではない。","プラグイン本体は init で .terraform ディレクトリへ取得される。stateには入らない。","認証情報は通常stateには保存されない。ただし機密値が属性として入ることはある。"]}'),

-- ── 3. コアワークフロー ──
('terraform-associate-b-q10', '3. コアワークフロー',
 'CI上で、差分の有無によって後続の処理を分岐させたい。terraform plan の終了コードを差分の有無で変えるために付けるオプションはどれか。',
 NULL::text,
 '["-detailed-exitcode","-out=tfplan","-json","-lock=false"]',
 0, '[0]', 'single',
 '{"asked":"planの終了コードをCIで使う方法を知っているか。","why_asked":"planは差分があっても既定では成功(0)を返すため、素直に書くとCIが差分を検知できない。自動化の場面で必ず必要になる知識で、試験も実務寄りの問い方をしてくる。","kid":"-detailed-exitcode を付けると、差分ありが 2 で返る。","terms":[["-detailed-exitcode","0=差分なし、1=エラー、2=差分あり を返す。"]],"think":"既定では成功か失敗かの2値しか返らないので、差分の有無が区別できない。3値にするフラグを明示的に付ける必要がある。","snippet":"# 0 = 差分なし / 1 = エラー / 2 = 差分あり\nterraform plan -detailed-exitcode\n\n# CI での分岐例\nterraform plan -detailed-exitcode || [ $? -eq 2 ] && echo \"差分あり\"","vs":"終了コードを変えるか、出力を変えるか、が軸。-out は計画の保存、-json は出力形式、-lock=false はロックの無効化で、いずれも終了コードには影響しない。","opt":["正解。差分なし0・エラー1・差分あり2 と、終了コードが3値になる。","-out は計画をファイルへ保存するフラグ。終了コードの挙動は変わらない。","-json は出力を機械可読にするフラグで、終了コードは既定のまま。","-lock=false はstateロックを取らない指定。危険なうえ終了コードとは無関係。"]}'),

('terraform-associate-b-q11', '3. コアワークフロー',
 'terraform plan と terraform apply について、追加のフラグを付けずに実行した場合の挙動として正しいものを2つ選べ。',
 NULL::text,
 '["どちらも実行前にstateを実態に合わせて自動で更新する","applyは実インフラへ変更を加え、その結果をstateへ反映する","planは実インフラへ変更を加えないが、stateは書き換える","applyは既定で確認を求めず、そのまま変更を適用する"]',
 0, '[0,1]', 'multi',
 '{"asked":"planとapplyの既定の挙動を正確に押さえているか。","why_asked":"planが安全であること、applyが確認を挟むこと、両者がstateを自動で更新することは、日常的に使っていても正確に言語化しにくい。試験は既定の挙動をそのまま問い、思い込みを洗い出す。","kid":"planもapplyも、まず実態を見に行ってから差分を出す。","terms":[["リフレッシュ","実インフラの現状を読み取り、stateの属性を最新化する処理。"]],"think":"差分を出すには「今どうなっているか」を知る必要がある。だからplanもapplyも、まず実態を確認してから構成と比べる。","vs":"実インフラを変えるかどうか、が軸。planは読むだけ、applyは変更してstateへ書き戻す。確認プロンプトは既定では出る。","opt":["正解。どちらも実行時にリフレッシュを行い、実態を反映したうえで差分を計算する。","正解。applyは実インフラを変更し、その結果をstateへ書き戻す。","planは変更計画を出すだけで、stateファイルを書き換えることはしない。","applyは既定で yes の入力を求める。確認を飛ばすには -auto-approve が要る。"]}'),

('terraform-associate-b-q12', '3. コアワークフロー',
 '巨大な構成のうち、特定の1リソースだけを対象に計画・適用したい。使えるオプションと、その扱いに関する説明として正しいものはどれか。',
 NULL::text,
 '["-target を使えるが、依存の一部を飛ばすため常用は推奨されず、例外的な復旧手段とされる","-target を使えば依存関係も含めて安全に絞り込めるため、日常的な運用手順として推奨される","-only を使う。対象外のリソースはstateから一時的に除外される","-exclude で他を除外する。対象リソースの依存は自動的に補完される"]',
 0, '[0]', 'single',
 '{"asked":"-target の用途と、その位置づけを理解しているか。","why_asked":"-target は便利なので常用したくなるが、構成全体の整合性を確かめないまま適用することになる。HashiCorp自身が例外的な手段と位置づけており、試験もその温度感を問う。","kid":"-target は緊急用の抜け道。普段使いする道具ではない。","terms":[["-target","対象のリソースアドレスとその依存だけに操作を絞るフラグ。"]],"think":"全体を見て差分を出すのがTerraformの前提。一部だけ当てると、構成全体としては整合していない状態を意図的に作ることになる。","snippet":"# 例外的な復旧手段。常用しない\nterraform apply -target=aws_instance.web","vs":"例外的な手段か、日常の手順か、が軸。-target は実在するが常用は非推奨で、-only や -exclude というフラグは存在しない。","opt":["正解。-target は実在するが、構成全体の整合性を確かめずに適用するため例外的な手段とされる。","依存は辿られるが、対象外のリソースとの整合は確認されない。日常の手順としては推奨されない。","-only というフラグは存在しない。stateから一時的に除外されることもない。","-exclude は plan/apply の絞り込みフラグとしては存在しない。"]}'),

('terraform-associate-b-q13', '3. コアワークフロー',
 '式や組み込み関数の挙動を、実インフラへ影響を与えずに対話的に試したい。使うコマンドはどれか。',
 NULL::text,
 '["terraform console","terraform show","terraform validate","terraform plan"]',
 0, '[0]', 'single',
 '{"asked":"terraform console の用途を知っているか。","why_asked":"式や関数の確認をplanの実行で試そうとすると、時間がかかるうえ実態への問い合わせも走る。用途に合った道具を選べるかを問う設問。","kid":"式を試す電卓のようなもの。","terms":[["terraform console","式や関数を対話的に評価する対話シェル。"]],"think":"関数の戻り値を確かめたいだけなら、計画を立てる必要はない。式を打ち込んで結果を見る場所が用意されている。","snippet":"$ terraform console\n> upper(\"abc\")\n\"ABC\"\n> cidrsubnet(\"10.0.0.0/16\", 8, 2)\n\"10.0.2.0/24\"","vs":"式を評価するか、既存のものを表示・検査するか、が軸。show は state や plan の中身、validate は構文と整合の検査、plan は差分の計算。","opt":["正解。console は式や関数を対話的に評価できる。","show は state や plan の内容を表示するコマンドで、任意の式は評価できない。","validate は構文と内部整合を検査するもので、式の戻り値は返さない。","plan でも式は評価されるが、差分の計算が目的で対話的に試す用途には向かない。"]}'),

('terraform-associate-b-q14', '3. コアワークフロー',
 '出力値をシェルスクリプトから機械的に取得し、他のツールへ渡したい。最も適した方法はどれか。',
 NULL::text,
 '["terraform output -json で出力値をJSONとして取得する","terraform show の表示結果を文字列として切り出す","terraform state show で対象リソースの属性を読み取る","terraform console で出力名を評価して値を得る"]',
 0, '[0]', 'single',
 '{"asked":"出力値を機械的に取り出す手段を知っているか。","why_asked":"人が読む表示を切り出して使う運用は、書式が変わった瞬間に壊れる。機械が読む前提の出口が用意されていることを知っているかが問われる。","kid":"output -json なら、そのまま jq に渡せる。","terms":[["terraform output","ルートモジュールの出力値を取得するコマンド。"]],"think":"人向けの表示と機械向けの出力は別物。後者が用意されているなら、表示を切り出す必要はない。","snippet":"# 全出力をJSONで\nterraform output -json\n\n# 単一の出力を生の値で（引用符なし）\nterraform output -raw instance_ip","vs":"機械向けの出口を使うか、人向けの表示を加工するか、が軸。show や console でも値には辿り着けるが、安定した取り出し口は output。","opt":["正解。output -json なら構造化された形で取得でき、他のツールへそのまま渡せる。","show の出力は人向けの整形。書式変更で壊れる脆い切り出しになる。","state show は個々のリソース属性の確認用。出力値を取る正規の手段ではない。","console は対話的な評価用。スクリプトから使う想定の口ではない。"]}'),

('terraform-associate-b-q15', '3. コアワークフロー',
 'terraform validate が検査する対象として正しいものはどれか。',
 NULL::text,
 '["構文と、変数の型や参照先といった構成内部の整合性","実インフラの現状と構成の差分","プロバイダの認証情報が有効かどうか","state内のリソースが実在しているかどうか"]',
 0, '[0]', 'single',
 '{"asked":"validate の守備範囲を理解しているか。","why_asked":"validate を通ったから安全だと考えると、実際の適用で初めて失敗する。ローカルで完結する検査と、リモートへの問い合わせが要る検査の線引きを問う設問。","kid":"validate は書き方の検査。実物は見に行かない。","terms":[["terraform validate","構文と内部整合を、リモートへ問い合わせずに検査する。"]],"think":"実態を見に行かないからこそ、認証情報が無くても走る。逆に言えば、実インフラ側の問題は何も分からない。","vs":"ローカルで完結する検査か、実態への問い合わせが要るか、が軸。差分の検出も認証の確認もリモートへのアクセスが要るので、validate の範囲外。","opt":["正解。構文と、型や参照といった構成内部の整合性を検査する。","差分の検出は plan の役割。validate は実態を見に行かない。","認証情報の有効性はリモートへの問い合わせが必要で、validate では確認できない。","state と実態の一致は refresh や plan が確かめること。"]}'),

('terraform-associate-b-q16', '3. コアワークフロー',
 'terraform destroy と terraform apply -destroy の関係として正しいものはどれか。',
 NULL::text,
 '["どちらも管理下リソースの削除計画を作って適用する、実質的に同じ操作である","destroy はstateも削除するが、apply -destroy はstateを残すという違いがある","destroy は確認を求めず、apply -destroy は確認を求めるという違いがある","apply -destroy というオプションは存在せず、destroy のみが正しい"]',
 0, '[0]', 'single',
 '{"asked":"destroy の実体を理解しているか。","why_asked":"destroy を特別なコマンドだと思い込むと、削除も計画を作って適用する通常のワークフローの一種だという理解に至らない。計画を保存してレビューできることにも気づけない。","kid":"destroy は「全部消す」という計画を作る apply の別名のようなもの。","terms":[["terraform destroy","apply -destroy の別名。削除の計画を作って適用する。"]],"think":"削除も1つの望ましい状態（何も無い状態）への収束。だから同じ plan/apply の枠組みで動く。","snippet":"# 同じ意味\nterraform destroy\nterraform apply -destroy\n\n# 削除計画を保存してレビューすることもできる\nterraform plan -destroy -out=tfplan\nterraform apply tfplan","vs":"別物か、同じものの別名か、が軸。stateの扱いも確認の有無も両者で違いはない。","opt":["正解。destroy は apply -destroy の別名で、削除の計画を作って適用する。","どちらもstateファイル自体は残る。中の管理対象が空になるだけ。","どちらも既定で確認を求める。飛ばすには -auto-approve が要る。","apply -destroy は実在する。destroy はその別名。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'terraform-associate-b'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
