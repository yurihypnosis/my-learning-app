-- =============================================================
-- 00004_seed_gh200.sql
-- GH-200 GitHub Actions 認定 — 5ドメイン / 35問
-- =============================================================

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('gh-200', 'GH-200 GitHub Actions 認定', '本番は65問・100分・700/1000で合格（2026年1月更新の5ドメイン構成）', '#e3a008', 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('Author and Manage Workflows',                  '#58a6ff', 0),
  ('Consume and Troubleshoot Workflows',            '#3fb950', 1),
  ('Author and Maintain Actions',                  '#d2a8ff', 2),
  ('Manage GitHub Actions for the Enterprise',     '#e3a008', 3),
  ('Secure and Optimize Automation',               '#f778ba', 4)
) AS v(name, color, sort_order)
WHERE s.slug = 'gh-200'
ON CONFLICT (subject_id, name) DO NOTHING;

-- ----------------------------------------------------------------
-- Questions
-- ----------------------------------------------------------------
INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options, correct_index, correct_indices, question_type, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb, v.correct_index, v.correct_indices::jsonb, v.question_type, v.explanation_data::jsonb, 0
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  -- D1: Author and Manage Workflows
  ('gh200-q1', 'Author and Manage Workflows',
   'リポジトリで毎日 UTC 午前2時にワークフローを自動実行したい。cron の値として正しいものはどれか。',
   'on:\n  schedule:\n    - cron: ''___''',
   '["0 2 * * *","2 0 * * *","* 2 * * *","0 2 * * 1-5"]', 0, '[0]', 'single',
   '{"asked":"cron 式の各フィールドを正しく読めるか、そして schedule トリガーが UTC 基準である点を理解しているか。","terms":[["cron 式","「分 時 日 月 曜日」の5つの値で実行タイミングを表す書式。左から順番が決まっている。"],["schedule トリガー","時刻でワークフローを起動する on の一種。時刻は常に UTC（日本時間 −9時間）で解釈される。"],["* (アスタリスク)","「毎回（すべて）」の意味。その位置の値を限定しない。"]],"think":"目覚まし時計を「何分・何時」の順でセットするのと同じ。左から『分→時』なので、2時00分は「0 2」。残りの『日・月・曜日』は毎日でいいので全部 * を置く。","vs":"`0 2`（2時00分）と `2 0`（0時02分）は分と時が逆になっただけの引っかけ。『左端が分』とだけ覚えれば即座に弾ける。曜日に `1-5` を入れると平日限定になり「毎日」の要件から外れる。","opt":["正解。分=0・時=2、残りは * で毎日。","分と時が逆。毎日 00:02 に実行されてしまう。","分が * なので毎時2分台に毎分実行される。","曜日 1-5 で平日のみに限定される。要件は毎日。"]}'),

  ('gh200-q2', 'Author and Manage Workflows',
   'matrix ビルドで、1つの組み合わせが失敗しても残りのジョブを最後まで走らせたい。正しい設定はどれか。',
   'jobs:\n  test:\n    strategy:\n      ____: false\n      matrix:\n        node: [18, 20, 22]',
   '["fail-fast","continue-on-error","max-parallel","if-no-files-found"]', 0, '[0]', 'single',
   '{"asked":"matrix の一部が失敗したときの「全体を巻き込んで止めるか／止めないか」を制御するキーを知っているか。","terms":[["matrix","1つのジョブ定義から複数の組み合わせ（例: Node 18/20/22）を自動展開して並列実行する仕組み。"],["fail-fast","matrix の早期中断スイッチ。既定は true で、1つ失敗すると残りの組み合わせをキャンセルする。"]],"think":"3つの鍋を同時に火にかけている状況。既定（fail-fast: true）は『1つ焦げたら全部火を止める』。3つとも最後まで仕上げて結果を見たいなら、明示的に false にして早期中断を切る。","vs":"`continue-on-error` と混同しやすいが、レイヤーが違う。fail-fast は『matrix 全体をキャンセルするか』の設定、continue-on-error は『この1ステップ／1ジョブの失敗を成功扱いにするか』の設定。前者は横並びの仲間を巻き込む話、後者は自分1人の失敗をどう扱うかの話、と切り分ける。","opt":["正解。matrix の早期キャンセルを無効化する。","ステップ／ジョブ単位の失敗許容で、strategy 直下のキーではない。","同時実行数の制御で、失敗時の挙動は変えない。","upload-artifact のオプション。無関係。"]}'),

  ('gh200-q3', 'Author and Manage Workflows',
   'build ジョブが成功した後にのみ deploy ジョブを実行したい。正しいキーはどれか。',
   NULL,
   '["deploy ジョブに needs: build を指定する","deploy ジョブに depends-on: build を指定する","build ジョブに triggers: deploy を指定する","deploy ジョブに after: build を指定する"]', 0, '[0]', 'single',
   '{"asked":"ジョブ間の実行順序（依存関係）を宣言するキーを正確に覚えているか。","terms":[["ジョブ","ワークフロー内の処理のまとまり。既定では複数ジョブは並列に走る。"],["needs","ジョブ依存を宣言するキー。指定したジョブが成功して完了するまで、このジョブは待機する。"]],"think":"料理の手順と同じで『下ごしらえ（build）が終わってから炒める（deploy）』という順序を宣言したいだけ。GitHub Actions でその順序を表すキーは needs ひとつ。","vs":"`depends-on` は他のツール、`after` や `triggers` は雰囲気で正しそうに見えるダミー。『順序の指定＝needs』と一対一で結びつけておけば、似た英単語に惑わされない。","opt":["正解。needs がジョブ依存の唯一の正しいキー。","GitHub Actions に depends-on というキーは無い。","triggers というジョブキーは存在しない。","after というジョブキーは存在しない。"]}'),

  ('gh200-q4', 'Author and Manage Workflows',
   '手動実行時に環境名を選ばせ、その値をワークフロー内で使いたい。最も適切な参照方法はどれか。',
   'on:\n  workflow_dispatch:\n    inputs:\n      target:\n        type: choice\n        options: [staging, production]',
   '["${{ inputs.target }}（または github.event.inputs.target）で参照する","${{ env.target }} で参照する","${{ secrets.target }} で参照する","${{ vars.target }} で参照する"]', 0, '[0]', 'single',
   '{"asked":"手動実行（workflow_dispatch）で受け取った入力値を、どのコンテキストから読み出すか。","terms":[["workflow_dispatch","GitHub の画面やボタンから手動でワークフローを起動するトリガー。"],["inputs","起動時に渡された入力値が入るコンテキスト。type: choice にすると選択式ドロップダウンになる。"],["コンテキスト","${{ }} の中で参照できる『値の入れ物』の総称（github / env / secrets / vars / inputs など）。"]],"think":"Webフォームを想像する。送信された入力欄の値は、決まった『受け取り箱』から取り出す。手動実行の入力箱は inputs。だから inputs.target。","vs":"env（環境変数）・secrets（機密値）・vars（設定変数）はどれも別々の箱で、見た目は ${{ }} で同じでも中身の出どころが違う。『手動入力で渡した値か？』を問われたら inputs、と出どころで判断する。","opt":["正解。dispatch 入力は inputs コンテキストで参照する。","env は環境変数で、入力値とは別の箱。","secrets は機密値の保管庫。入力値ではない。","vars は設定変数。入力値とは別。"]}'),

  ('gh200-q5', 'Author and Manage Workflows',
   '再利用可能ワークフローを呼び出す際、呼び出し元の全シークレットを丸ごと渡したい。最も簡潔な方法はどれか。',
   'jobs:\n  call:\n    uses: org/repo/.github/workflows/ci.yml@main\n    secrets: ______',
   '["inherit","all","github.secrets","true"]', 0, '[0]', 'single',
   '{"asked":"再利用可能ワークフローへシークレットを一括で継承させるキーワードを知っているか。","terms":[["再利用可能ワークフロー (reusable workflow)","別のワークフローから uses で呼び出せる、部品化されたワークフロー。"],["secrets: inherit","呼び出し元が持つシークレットをまとめて、呼ばれる側へ継承させる指定。"]],"think":"子に買い物を頼むとき、必要なお金だけ手渡すか、財布ごと渡すか。inherit は『財布ごと渡す』に相当し、個別に列挙する手間が省ける。","vs":"個別に渡したい場合は secrets: の下に name: 値 を列挙する。『全部まとめて＝inherit』『選んで渡す＝列挙』の二択で覚える。all / true / github.secrets はそれらしく見えるが無効値。","opt":["正解。inherit が全シークレット継承のキーワード。","all という値は無効。","github.secrets というコンテキストは存在しない。","true は無効な値。"]}'),

  ('gh200-q6', 'Author and Manage Workflows',
   '同一ブランチへ連続で push されたとき、進行中の古い run を自動キャンセルして最新だけ残したい。正しい設定はどれか。',
   'concurrency:\n  group: ${{ github.ref }}\n  ________: true',
   '["cancel-in-progress","fail-fast","max-parallel","auto-cancel"]', 0, '[0]', 'single',
   '{"asked":"同一グループの run が重なったとき、進行中の古い run を打ち切る設定を知っているか。","terms":[["concurrency","同じグループ名の run を同時に走らせない／走らせ方を制御する仕組み。"],["group","どの run 同士を『同じ仲間』とみなすかのキー。ここを github.ref にするとブランチ単位でまとめられる。"],["cancel-in-progress","同じグループで新しい run が来たとき、進行中の古い run をキャンセルする指定。"]],"think":"エレベーターのボタン連打。新しく押した呼び出しが生き残り、古い呼び出しは無効になる。同じグループ名で『走ってる古いのは止めて最新だけ動かして』と指示するのが cancel-in-progress。","vs":"fail-fast と max-parallel は matrix 用のキーで、ここでは出てこない。『run 全体の重複制御＝concurrency』『matrix 内の挙動＝fail-fast / max-parallel』と所属を分けて判断する。","opt":["正解。進行中の同一グループ run をキャンセルする。","matrix の設定。concurrency では使わない。","matrix の同時数制御。","auto-cancel というキーは存在しない。"]}'),

  ('gh200-q7', 'Author and Manage Workflows',
   'workflow・job・step の3階層すべてで同名の環境変数 MODE を定義した。step 内の run で参照したとき、実際に使われる値はどれか。',
   NULL,
   '["step レベルで定義した値","workflow（最上位）レベルで定義した値","job レベルで定義した値","未定義となりエラーになる"]', 0, '[0]', 'single',
   '{"asked":"env を複数階層で同名定義したときの優先順位（スコープの上書きルール）を理解しているか。","terms":[["env","環境変数を定義するキー。workflow / job / step の3階層で書ける。"],["スコープ","その定義が効く範囲。step は最も狭く（内側）、workflow は最も広い（外側）。"]],"think":"会社の就業規則（workflow）・部署のローカルルール（job）・自分の机の貼り紙（step）の関係。同じ事柄が重複したら、一番手元に近い（内側の）貼り紙が優先される。env も同じで step > job > workflow。","vs":"直感的に『一番上位（workflow）が一番強い』と思いがちだが逆。『近いものが勝つ＝内側が優先』と覚える。重複しても上書きされるだけでエラーにはならない。","opt":["正解。最も内側の step スコープが優先。","workflow は最も外側で、内側に上書きされる。","job は step と workflow の中間。step があれば負ける。","重複定義は許容され、エラーにはならない。"]}'),

  ('gh200-q8', 'Author and Manage Workflows',
   'pull_request イベントでのみ実行され、push では実行されないステップを書きたい。正しい if 条件はどれか。',
   NULL,
   '["if: ${{ github.event_name == ''pull_request'' }}","if: ${{ github.ref == ''pull_request'' }}","if: ${{ github.trigger == ''pull_request'' }}","if: ${{ env.EVENT == ''pull_request'' }}"]', 0, '[0]', 'single',
   '{"asked":"『どのイベントで起動したか』を判定するコンテキストを正しく選べるか。","terms":[["github.event_name","ワークフローを起動したイベントの名前（push / pull_request / schedule など）が入る。"],["github.ref","起動時のブランチ／タグ参照（refs/heads/main など）が入る。"]],"think":"受付で『何の用件で来たか（イベント名）』と『どの入口から来たか（ref）』を区別するイメージ。今回は用件＝pull_request かどうかを見たいので event_name。","vs":"github.ref はブランチ名であってイベント名ではない（引っかけ）。github.trigger や env.EVENT は存在しないか自動設定されない。『イベント種別の判定＝event_name』『ブランチ判定＝ref』で覚える。","opt":["正解。event_name でイベント種別を判定する。","github.ref は ref 名であってイベント名ではない。","github.trigger というコンテキストは存在しない。","env.EVENT は自動では設定されない。"]}'),

  -- D2: Consume and Troubleshoot Workflows
  ('gh200-q9', 'Consume and Troubleshoot Workflows',
   '同一 run 内で、build ジョブが生成したビルド成果物を deploy ジョブで受け取りたい。標準的な方法はどれか。',
   NULL,
   '["build で actions/upload-artifact、deploy で actions/download-artifact を使う","ジョブ間でファイルシステムが共有されるので何もしなくてよい","outputs で成果物ファイルを直接渡す","cache を使ってファイルを引き継ぐ"]', 0, '[0]', 'single',
   '{"asked":"ジョブをまたいでファイル（成果物）を確実に受け渡す正攻法を知っているか。","terms":[["artifact","run の途中で保存し、後から取り出せる成果物（ビルド出力やレポートなど）。"],["upload-artifact / download-artifact","成果物を預ける／取り出す公式アクション。"]],"think":"build と deploy は別々の作業部屋（別ランナー）。机の上のファイルは隣の部屋には届かない。一度ロッカー（artifact）に預けて、別部屋で取り出す——この『預けて・取り出す』が upload と download。","vs":"outputs は小さな文字列を渡す伝言メモ、cache は高速化のための使い回しで確実な受け渡しは保証されない。『バイナリ／ファイルの確実な受け渡し＝artifact』『短い文字列＝outputs』『速度のための再利用＝cache』と用途で切り分ける。","opt":["正解。artifact のアップロード／ダウンロードで受け渡す。","ジョブごとに別ランナーなのでファイルは共有されない。","outputs は小さな文字列値向け。バイナリには不適。","cache は再利用が目的で、確実な受け渡しには不向き。"]}'),

  ('gh200-q10', 'Consume and Troubleshoot Workflows',
   '失敗したワークフローの原因究明のため、各ステップの詳細なデバッグログを出力させたい。正しい設定はどれか。',
   NULL,
   '["シークレットまたは変数 ACTIONS_STEP_DEBUG を true に設定する","ワークフローに debug: true を追加する","ジョブに verbose: true を追加する","runs-on に debug ラベルを付ける"]', 0, '[0]', 'single',
   '{"asked":"詳細ログ（デバッグログ）を有効化する『場所』と『キー名』を知っているか。","terms":[["ACTIONS_STEP_DEBUG","ステップ単位の詳細ログを出すスイッチ。値 true をリポジトリのシークレットまたは変数として設定する。"],["ACTIONS_RUNNER_DEBUG","ランナー側の診断ログを出す同種のスイッチ。"]],"think":"アプリの『詳細表示モード』を、本体（YAML）ではなく設定画面（リポジトリの Secrets / Variables）でオンにするイメージ。スイッチは YAML の外側にある。","vs":"debug: true や verbose: true は『いかにもありそう』な YAML キーだが存在しない。『デバッグログ＝設定側の ACTIONS_STEP_DEBUG / ACTIONS_RUNNER_DEBUG』と場所ごと覚えると引っかからない。","opt":["正解。ACTIONS_STEP_DEBUG をシークレット／変数で true に。","debug: true というワークフローキーは存在しない。","verbose: true というジョブキーは存在しない。","runs-on はランナー指定。debug ラベルでログは増えない。"]}'),

  ('gh200-q11', 'Consume and Troubleshoot Workflows',
   '5つのジョブのうち2つが失敗した。「Re-run failed jobs」を実行した場合の挙動として正しいものはどれか。',
   NULL,
   '["失敗した2ジョブと、それに依存するジョブのみが再実行される","全5ジョブが最初から再実行される","失敗ジョブのステップのうち失敗箇所からのみ再開される","成功ジョブを含む全ジョブのログが消去される"]', 0, '[0]', 'single',
   '{"asked":"「失敗ジョブのみ再実行」が、どこまでの範囲を再実行するかを正確に理解しているか。","terms":[["Re-run failed jobs","失敗したジョブ（と、それに needs で依存する後続ジョブ）だけを再実行する操作。"],["Re-run all jobs","成功・失敗を問わず全ジョブを最初から実行し直す操作。"]],"think":"テストで間違えた問題だけ解き直すのと同じ。正解済み（成功ジョブ）は触らない。ただし、間違えた問題を直すと答えが変わる連動問題（依存する後続ジョブ）も巻き込んで解き直す。","vs":"『全部最初から』は別ボタンの Re-run all jobs。また、再実行は必ずジョブ単位で、ステップ途中からの再開はできない。『失敗分だけ＝failed』『全部＝all』『単位はジョブ』の3点で区別。","opt":["正解。失敗ジョブ＋それに依存する下流ジョブが対象。","全実行は Re-run all jobs の挙動。","ステップ途中再開はできず、ジョブ単位で再実行される。","再実行でログは消えない。"]}'),

  ('gh200-q12', 'Consume and Troubleshoot Workflows',
   'run のサマリ画面に、ジョブの結果を Markdown 形式の表で表示したい。正しい方法はどれか。',
   NULL,
   '["Markdown を $GITHUB_STEP_SUMMARY ファイルに追記する","echo で標準出力に Markdown を出す","set-output で summary を渡す","actions/upload-artifact で summary.md を上げる"]', 0, '[0]', 'single',
   '{"asked":"run のサマリページに表示を出す専用の仕組み（環境ファイル）を知っているか。","terms":[["ジョブサマリ","run の結果ページ上部に出る、ジョブごとの要約表示。Markdown で書ける。"],["$GITHUB_STEP_SUMMARY","サマリ表示の中身を書き込むための特別なファイルパス。ここに追記した Markdown が描画される。"]],"think":"掲示板（サマリ画面）に貼りたい紙は、専用の投函口（$GITHUB_STEP_SUMMARY）に入れる。例: echo ''## 結果'' >> $GITHUB_STEP_SUMMARY。普通に喋った内容（標準出力）はログには流れても掲示板には貼られない。","vs":"標準出力はログに出るだけ、artifact はダウンロード用、set-output は旧式で用途違い。『サマリ画面に出す＝$GITHUB_STEP_SUMMARY への追記』だけが正解ルート。","opt":["正解。$GITHUB_STEP_SUMMARY への追記で表示される。","標準出力はログには出るがサマリ表示にはならない。","set-output は非推奨かつ用途が異なる。","artifact はダウンロード用でサマリには出ない。"]}'),

  ('gh200-q13', 'Consume and Troubleshoot Workflows',
   'あるステップが失敗してもジョブ全体は成功扱いで続行させたい。正しい設定はどれか。',
   'steps:\n  - run: ./flaky-check.sh\n    ________: true',
   '["continue-on-error","ignore-error","allow-failure","fail-fast"]', 0, '[0]', 'single',
   '{"asked":"個々のステップの失敗を許容してジョブを続行させるキーを知っているか。","terms":[["continue-on-error","そのステップ（やジョブ）が失敗しても処理を続行し、最終的に成功扱いにする指定。"],["flaky","実行のたびに成否がぶれる、不安定なテスト／処理のこと。"]],"think":"『ここはコケても気にせず先へ進んでよい』という許可証。不安定な検査など、失敗が致命的でない箇所に貼る。後続で steps.<id>.outcome を見れば、結果に応じた分岐もできる。","vs":"ignore-error は存在しないキー、allow-failure は GitLab CI の用語、fail-fast は matrix 専用。『1ステップの失敗を許す＝continue-on-error』に固定して、似た意味の他ツール用語に流されない。","opt":["正解。失敗を許容して続行するステップ設定。","ignore-error というキーは存在しない。","allow-failure は GitLab CI の用語。","fail-fast は matrix の設定。"]}'),

  -- D3: Author and Maintain Actions
  ('gh200-q14', 'Author and Maintain Actions',
   '複数の run ステップ（シェルコマンド群）をまとめて再利用可能なアクションとして公開したい。追加の言語ランタイムやコンテナは不要。最も適したアクション種別はどれか。',
   NULL,
   '["Composite action","JavaScript action","Docker container action","Reusable workflow"]', 0, '[0]', 'single',
   '{"asked":"3種類あるアクションの中から、要件（シェルステップを束ねるだけ）に最も軽量・適切なものを選べるか。","terms":[["Composite action","複数の step（主にシェルコマンド）を1つのアクションにまとめた部品。追加のランタイム不要。"],["JavaScript action","Node.js で実装するアクション。ロジックを JS で書く。"],["Docker container action","コンテナイメージ上で動くアクション。任意の環境を持ち込めるが重い。"]],"think":"よく使う一連の手順を『ショートカット集』にまとめたい。中身がただのシェル手順なら、新しい道具（Node やコンテナ）を持ち出す必要はなく、composite が最軽量で適切。","vs":"JavaScript action は Node 実装が要る、Docker action はイメージのビルドが要る、reusable workflow はそもそもアクションではなくジョブ単位の再利用。『既存シェルの束ね＝composite』『ジョブ丸ごとの再利用＝reusable workflow』という粒度の違いに注意。","opt":["正解。シェルステップ群の束ね役に最適。","Node 実装が必要で、単なるシェル束ねには過剰。","コンテナビルドが必要で重い。","アクションではなくワークフロー再利用の仕組み。"]}'),

  ('gh200-q15', 'Author and Maintain Actions',
   'JavaScript アクションの action.yml で実行ランタイムを指定する。2026年時点で推奨される値はどれか。',
   'runs:\n  using: ''______''\n  main: ''dist/index.js''',
   '["node20","node12","javascript","composite"]', 0, '[0]', 'single',
   '{"asked":"JavaScript アクションのランタイム指定の正しい値と、サポート世代の感覚を持っているか。","terms":[["runs.using","アクションをどの方式で実行するかの指定（node20 / docker / composite など）。"],["main","JS アクションのエントリーポイント（最初に実行されるファイル）。"]],"think":"『どのエンジンで動かすか』のラベル。Node の現役世代を選ぶ、というだけ。2026年時点の現行は node20。","vs":"node12（や node16）は古くサポート終了済み——『最新世代を選ぶ』で弾ける。javascript という using 値は存在しない。composite は main を取らない別種別なので、main が書かれている時点で composite は不適合と判断できる。","opt":["正解。現行サポートの Node ランタイム指定。","node12 はサポート終了済み。","javascript という using 値は存在しない。","composite は main を取らない別種別。"]}'),

  ('gh200-q16', 'Author and Maintain Actions',
   'composite action 内で生成した値を、呼び出し元へ output として返したい。正しい構成はどれか。',
   NULL,
   '["ステップで >> $GITHUB_OUTPUT に書き、action.yml の outputs で value: ${{ steps.<id>.outputs.<name> }} を参照する","action.yml の outputs に run の標準出力が自動的に入る","::set-output を使えば action.yml の記述は不要","outputs は composite action では使えない"]', 0, '[0]', 'single',
   '{"asked":"composite action の output を呼び出し元へ渡すには『ステップ側の書き込み』と『action.yml 側の紐付け』の両方が要ると理解しているか。","terms":[["$GITHUB_OUTPUT","ステップの出力値を書き込む環境ファイル。echo \"name=value\" >> $GITHUB_OUTPUT の形で使う。"],["outputs.value","action.yml で『この値を外に出す』と宣言する欄。中で steps.<id>.outputs.<name> を参照する。"]],"think":"中で働く作業者が結果を伝票（$GITHUB_OUTPUT）に書き、受付（action.yml の outputs）が『この伝票を外のお客に渡します』と明示する。両方そろって初めて値が外へ出る。","vs":"『自動で外に出る』は誤り——明示の紐付けが要る。::set-output は旧式（非推奨）で、今は $GITHUB_OUTPUT 方式。composite でも outputs は普通に使える。","opt":["正解。$GITHUB_OUTPUT への書き込み＋outputs.value 参照が定石。","自動では入らない。明示的な紐付けが必要。","set-output は非推奨で、outputs 定義は必要。","composite action でも outputs は使える。"]}'),

  ('gh200-q17', 'Author and Maintain Actions',
   '自作アクションを利用者が uses: my-org/my-action@v1 のまま使い続けられるよう、パッチ修正に追従させたい。推奨されるバージョニング運用はどれか。',
   NULL,
   '["個別の semver タグ（v1.2.3）に加え、移動するメジャータグ v1 を最新コミットへ貼り替える","毎回ユーザーにフル SHA を更新してもらう","main ブランチを直接参照させ、タグは付けない","リリースのたびに別名のアクションを新規公開する"]', 0, '[0]', 'single',
   '{"asked":"アクション『提供側』の慣習として、利用者が @v1 固定のまま安全に更新を受け取れる運用を理解しているか。","terms":[["semver タグ (v1.2.3)","意味のある不変のバージョン番号。一度切ったら中身を変えない。"],["移動メジャータグ (v1)","最新の互換コミットへ貼り替えていく、動くタグ。利用者の追従点になる。"]],"think":"雑誌の『v1 の棚』に最新号を置き続けるイメージ。読者は棚（@v1）だけ見ていれば、最新の互換号が自動で手に入る。提供側は v1.2.3 の不変タグも別途残しておく。","vs":"ここは『利用側のセキュリティ（=フル SHA 固定）』の話と混ざりやすいが、視点が逆。提供側はメジャータグを動かして追従させるのが慣習。利用側で第三者アクションを固める話なら SHA。『提供する側／使う側』のどちらの視点かをまず確かめる。","opt":["正解。移動メジャータグ運用が推奨される慣習。","毎回 SHA 更新は利用者負担が大きく、提供側の運用ではない。","main 直参照は破壊的変更が即流入し危険。","毎回別名公開は利用者の uses を壊す。"]}'),

  ('gh200-q18', 'Author and Maintain Actions',
   '公開アクションを GitHub Marketplace で見栄え良く表示するため、アイコンと色を action.yml に設定したい。使うキーはどれか。',
   NULL,
   '["branding（icon と color）","marketplace（logo）","display（icon）","metadata（badge）"]', 0, '[0]', 'single',
   '{"asked":"Marketplace 表示用のアイコン・色を設定する action.yml のキー名を知っているか。","terms":[["branding","action.yml で Marketplace 表示の見た目を整えるキー。icon（Feather アイコン名）と color（背景色）を持つ。"],["Feather icons","branding.icon で指定できるアイコンセットの名称。"]],"think":"商品パッケージのロゴと配色を決めるようなもの。action.yml の branding 欄に icon と color を書けば、Marketplace の見た目に反映される。","vs":"marketplace / display / metadata は、それっぽいが存在しないキー。『見た目の設定＝branding』と一語で覚えれば消去法で選べる。","opt":["正解。branding.icon / branding.color を指定する。","marketplace というメタデータキーは無い。","display というキーは無い。","metadata というキーは無い。"]}'),

  ('gh200-q19', 'Author and Maintain Actions',
   '同一リポジトリ内のローカル composite action（例: ./.github/actions/setup）を uses で呼ぶ。ワークフロー側で必ず必要になる前提ステップはどれか。',
   NULL,
   '["actions/checkout でリポジトリをチェックアウトしておく","actions/setup-node を先に実行する","permissions を write-all にする","self-hosted ランナーを使う"]', 0, '[0]', 'single',
   '{"asked":"ローカルアクション（uses: ./path）を呼ぶ前提条件を理解しているか。","terms":[["ローカルアクション","同じリポジトリ内のパスを uses: ./... で参照するアクション。"],["actions/checkout","ランナー上にリポジトリの中身を取得（チェックアウト）する公式アクション。"]],"think":"自宅（リポジトリ）にある道具を使うには、まず家に入る（checkout する）必要がある。チェックアウト前のランナーは空っぽで、./.github/actions/setup というファイル自体が存在しない。","vs":"setup-node は Node 環境を整える別目的で必須ではない。権限の最大化（write-all）はむしろ非推奨だし無関係。self-hosted も不要（GitHub-hosted でも動く）。『ローカルファイル参照には、まずファイルを取りに行く checkout』と原理から考える。","opt":["正解。ローカルアクション参照には checkout が前提。","setup-node は Node 用で、必須前提ではない。","権限を最大化する必要は無い（むしろ非推奨）。","ローカルアクションは GitHub-hosted でも動く。"]}'),

  -- D4: Manage GitHub Actions for the Enterprise
  ('gh200-q20', 'Manage GitHub Actions for the Enterprise',
   'GPU を搭載した self-hosted runner（ラベル gpu を付与済み）でジョブを動かしたい。正しい runs-on はどれか。',
   NULL,
   '["runs-on: [self-hosted, gpu]","runs-on: gpu-latest","runs-on: ubuntu-latest","runs-on: hosted-gpu"]', 0, '[0]', 'single',
   '{"asked":"self-hosted runner を、付与したラベルで正しく指定できるか。複数ラベルの意味も含めて。","terms":[["self-hosted runner","自分で用意したマシン上で動かすランナー。GitHub が用意するクラウドランナー（GitHub-hosted）の対義。"],["ラベル","ランナーに付ける目印（self-hosted / OS / アーキ / 用途など）。"],["runs-on の配列","[a, b] と書くと『a も b も満たす』ランナー（AND 条件）に割り当てられる。"]],"think":"求人の条件指定と同じ。『自社勤務（self-hosted）かつ GPU 担当（gpu）』の両方を満たす人にだけ仕事を振る。配列はすべて満たす AND。","vs":"gpu-latest や hosted-gpu は存在しない GitHub-hosted 風のダミー。ubuntu-latest は GitHub 側の通常クラウド機で、自前の GPU 機ではない。『自前マシンを狙う＝self-hosted ラベル＋カスタムラベル』と組で覚える。","opt":["正解。self-hosted ＋カスタムラベルで対象を限定する。","gpu-latest という GitHub-hosted ラベルは存在しない。","ubuntu-latest は GitHub-hosted の通常機。GPU 機ではない。","hosted-gpu というラベルは標準には無い。"]}'),

  ('gh200-q21', 'Manage GitHub Actions for the Enterprise',
   'Organization に登録した self-hosted runner 群を、特定のリポジトリだけがアクセスできるよう制御したい。最も適した仕組みはどれか。',
   NULL,
   '["Runner group を作成し、アクセスできるリポジトリを限定する","各リポジトリの Secrets でランナー名を制限する","ワークフローの permissions でランナーを絞る","ブランチ保護ルールでランナーを制限する"]', 0, '[0]', 'single',
   '{"asked":"self-hosted ランナーの『利用できるリポジトリ』を制御するガバナンス機能を知っているか。","terms":[["Runner group","organization / enterprise レベルでランナーをまとめ、どのリポジトリから使えるかを制御する単位。"]],"think":"『この部屋（ランナー群）に入れるのはこの部署（指定リポジトリ）だけ』という入館証管理。機密性の高い自前環境を、無関係なリポジトリから使われないよう囲う。","vs":"Secrets は値の保管、permissions は GITHUB_TOKEN の権限、ブランチ保護はマージ条件——どれもランナーの利用範囲とは別の軸。『ランナーへのアクセス制御＝runner group』と機能を一対一で結ぶ。","opt":["正解。runner group でアクセス可能リポジトリを限定する。","Secrets はランナーのアクセス制御には使えない。","permissions は GITHUB_TOKEN の権限制御。ランナー選択は制御しない。","ブランチ保護はマージ条件の制御で無関係。"]}'),

  ('gh200-q22', 'Manage GitHub Actions for the Enterprise',
   'Organization 全体で、信頼できる発行元のアクションだけを許可したい。Actions の許可ポリシーとして設定できる選択肢を全て選べ。（複数選択）',
   NULL,
   '["GitHub 公式（actions/ や github/）が作成したアクションを許可","Marketplace の検証済み作成者（verified creators）のアクションを許可","特定のアクションを許可リスト（owner/name@* など）で指定","リポジトリ管理者のメールアドレスでアクションを許可"]', 0, '[0,1,2]', 'multi',
   '{"asked":"Organization の Actions 許可ポリシーで実際に存在する制限軸を、存在しないダミーと区別できるか。","terms":[["許可ポリシー (allowed actions)","組織内で使えるアクションを『全許可／ローカルのみ／信頼元のみ』などに絞る設定。"],["verified creator","GitHub が身元を検証済みの Marketplace 出店者。"]],"think":"イベントの入場制限に例えると、『公式スタッフ（GitHub 作成）』『認証済み出店者（verified creators）』『名指しの招待リスト（明示的許可リスト）』は通す——という3つの軸で許可を組み立てられる。","vs":"『メールアドレスで許可』は存在しない罠。アクションの許可はあくまで『発行元の信頼レベル』や『名指しリスト』で決めるもので、個人のメールアドレスを基準にする仕組みは無い、と原理で弾く。","opt":["正しい。GitHub 作成アクションの許可はポリシー項目にある。","正しい。検証済み作成者の許可はポリシー項目にある。","正しい。明示的な許可リスト指定が可能。","誤り。メールアドレスでの許可という設定は存在しない。"]}'),

  ('gh200-q23', 'Manage GitHub Actions for the Enterprise',
   'Organization レベルのシークレットを作成したが、全リポジトリではなく選んだ一部のリポジトリにだけ使わせたい。正しい設定はどれか。',
   NULL,
   '["シークレット作成時に「Selected repositories」を選びアクセス可能リポジトリを指定する","各リポジトリのワークフローに allow-list を書く","Environment を作ってそこにだけ org secret を複製する","org secret は常に全リポジトリ共有で、限定はできない"]', 0, '[0]', 'single',
   '{"asked":"Organization シークレットの可視範囲（どのリポジトリから使えるか）を制御する正しい場所を知っているか。","terms":[["Organization シークレット","組織全体で共有できるシークレット。作成時にアクセス範囲を選べる。"],["アクセスポリシー","All（全リポジトリ）／ Private（プライベートのみ）／ Selected（指定リポジトリのみ）の3択。"]],"think":"会社の金庫を『全部署が開けられる』のか『指定した部署だけ』なのか、金庫を置くとき（=シークレット作成時）に決める。Selected を選んで名指しすれば限定できる。","vs":"ワークフロー側に何を書いても org secret の可視性は変えられない（制御は設定側）。複製でもないし、全共有固定でもない。『org secret の範囲＝作成時のアクセスポリシー』と置き場所を固定して覚える。","opt":["正解。Selected repositories でアクセスを限定する。","ワークフロー側の記述では可視性は制御できない。","複製ではなくアクセスポリシーで制御する。","限定は可能。常時全共有ではない。"]}'),

  ('gh200-q24', 'Manage GitHub Actions for the Enterprise',
   '本番デプロイのジョブだけ、承認者によるレビューを必須にしたい。GitHub Actions で実現する標準機能はどれか。',
   NULL,
   '["Environment を作り required reviewers を設定し、ジョブに environment: を指定する","ブランチ保護ルールで CODEOWNERS を必須にする","concurrency でジョブをブロックする","workflow_dispatch の inputs に承認者名を入れる"]', 0, '[0]', 'single',
   '{"asked":"ジョブ実行『前』に人手の承認ゲートを差し込む標準機能を知っているか。","terms":[["Environment","デプロイ先（production / staging など）を表す論理単位。保護ルールを付けられる。"],["required reviewers","その environment を使うジョブの実行前に、指定レビュアーの承認を必須にする保護ルール。"]],"think":"本番のドアの前に関所を置き、『承認者のハンコがないと通れない』状態にする。ジョブに environment: production を紐付けると、その関所が効く。","vs":"ブランチ保護はマージ時の制御で、タイミングが違う（デプロイジョブの実行前ではない）。concurrency は同時実行制御、inputs はただの入力欄で承認の強制力はない。『実行前の人手承認＝environment の required reviewers』と機能を結ぶ。","opt":["正解。environment の required reviewers が承認ゲート。","ブランチ保護はマージ時の制御で、実行前承認ではない。","concurrency は同時実行制御で承認機能ではない。","inputs に名前を書いても承認ゲートにはならない。"]}'),

  ('gh200-q25', 'Manage GitHub Actions for the Enterprise',
   '外部の運用ダッシュボードから、特定リポジトリのワークフロー実行履歴やアーティファクトをプログラムで取得・管理したい。最も適した手段はどれか。',
   NULL,
   '["GitHub REST API（Actions エンドポイント）を使う","ワークフロー YAML を直接 git pull で読む","runner のローカルログファイルを SSH で読む","Marketplace のアクションをローカル実行する"]', 0, '[0]', 'single',
   '{"asked":"実行履歴・成果物・シークレット等を外部からプログラム的に扱う公式手段を知っているか。","terms":[["REST API（Actions エンドポイント）","workflow run / job / log / artifact / secret / variable を取得・操作できる API 群。"]],"think":"外部システムから GitHub の中を覗くための『公式の窓口』。ダッシュボードはこの窓口（API）越しにデータを取りに行く。","vs":"YAML を読んでも実行履歴や成果物は得られない、GitHub-hosted ランナーへ SSH ログインは不可、ローカル実行は管理手段ではない——いずれも『実行データを取得する』要件を満たさない。『プログラムで実行データを扱う＝Actions REST API』。","opt":["正解。Actions REST API が標準のプログラム的管理手段。","YAML を読んでも実行履歴や成果物は取れない。","GitHub-hosted ランナーへの SSH ログインはできない。","Marketplace アクションのローカル実行は管理手段ではない。"]}'),

  -- D5: Secure and Optimize Automation
  ('gh200-q26', 'Secure and Optimize Automation',
   '最小権限の原則に従い、ワークフローの GITHUB_TOKEN にリポジトリ内容の読み取りだけを許可したい。正しい記述はどれか。',
   'permissions:\n  contents: ____',
   '["read","write","none で全許可","all"]', 0, '[0]', 'single',
   '{"asked":"GITHUB_TOKEN の権限を、必要最小限（読み取りのみ）に絞る正しい値を選べるか。","terms":[["GITHUB_TOKEN","ワークフロー実行時に自動発行される一時トークン。permissions で権限を絞れる。"],["permissions","スコープごとに read / write / none を割り当てるキー。"],["最小権限の原則","必要な権限だけを与え、それ以上は与えない設計指針。"]],"think":"入館証に『閲覧のみ』の権限だけ付ける感覚。読むだけでよいなら contents: read。出発点として permissions: {} と空にすると全スコープ none になり、そこから必要分だけ足すのが安全。","vs":"write は書き込みまで許してしまい過剰、none は読みすらできず不足。read がちょうど『読み取りのみ』。all は contents の有効値ではない。『読むだけ＝read』『何もさせない＝none』『書きも許す＝write』を量で覚える。","opt":["正解。contents: read で読み取りのみに限定。","write は書き込みも許可してしまう。","none は許可ゼロで、読み取りすらできない。","all は contents スコープの有効値ではない。"]}'),

  ('gh200-q27', 'Secure and Optimize Automation',
   '長期保管のクラウド認証情報をシークレットに置かず、OIDC でクラウドへ短命トークンで認証したい。ワークフローに必要な permissions はどれか。',
   'permissions:\n  id-token: write\n  contents: read',
   '["id-token: write が必須（OIDC トークン発行のため）","contents: write が必須","actions: write が必須","特別な permissions は不要"]', 0, '[0]', 'single',
   '{"asked":"OIDC でクラウド認証する際に必要となる固有の permission を知っているか。","terms":[["OIDC (OpenID Connect)","長期シークレットを保持せず、その場で発行する短命トークンでクラウドへ認証する仕組み。"],["id-token: write","ジョブが OIDC トークンを要求できるようにする権限。OIDC 認証の必須条件。"]],"think":"長期の合鍵（シークレット）を相手に預けっぱなしにする代わりに、入る度に使い捨ての入館証を発行してもらう方式。その『入館証を発行してもらう許可』が id-token: write。","vs":"contents: write や actions: write はリポジトリ操作の権限で、クラウド認証とは無関係。OIDC の鍵は id-token のみ。『短命トークンでクラウド認証＝id-token: write』とセットで暗記する。","opt":["正解。id-token: write が OIDC の必須権限。","contents: write はリポジトリ書き込み権限で OIDC とは無関係。","actions: write も OIDC 認証には不要。","id-token: write を明示しないと OIDC トークンは取得できない。"]}'),

  ('gh200-q28', 'Secure and Optimize Automation',
   'Issue のタイトルをそのまま run 内のシェルに埋め込んでいる。スクリプトインジェクションの危険がある。最も安全な修正はどれか。',
   '# 危険な例\n- run: echo "Title: ${{ github.event.issue.title }}"',
   '["値を env: にバインドし、run 内では \"$TITLE\" のように環境変数として参照する","値をシングルクォートで囲むだけにする","permissions を read に下げれば防げる","self-hosted runner で実行すれば防げる"]', 0, '[0]', 'single',
   '{"asked":"信頼できない入力を run に直接展開する危険性と、その正しい回避法を理解しているか。","terms":[["スクリプトインジェクション","攻撃者が入力（Issue タイトル等）に仕込んだ文字列が、コマンドとして実行されてしまう攻撃。"],["${{ }} 展開","ワークフロー実行前に値が文字列としてその場に埋め込まれる処理。ここに悪意ある文字列が入ると危険。"],["env バインド","値を一旦環境変数に渡し、シェル内では \"$VAR\" として参照する安全な受け渡し方。"]],"think":"他人が書いた紙（Issue タイトル）を、そのまま大声で読み上げる（run に直書きする）と、紙に仕込まれた命令まで実行させられる。一度封筒（env 変数）に入れてから『封筒の中身を表示』とすれば、中身は命令ではなくただのデータとして扱われる。","vs":"クォートで囲むだけでは、${{ }} 展開の段階で注入が完成してしまうので不十分。権限を下げても、ランナーを変えても、文字列が run に注入される構造そのものは変わらない。『信頼できない入力＝env にバインドして引用符付きで使う』が唯一の本質的対策。","opt":["正解。env バインド＋引用符付き参照でインジェクションを防ぐ。","クォートだけでは ${{ }} 展開段階の注入を防げない。","権限を下げても run への文字列注入自体は防げない。","ランナー種別を変えても注入リスクは残る。"]}'),

  ('gh200-q29', 'Secure and Optimize Automation',
   'サプライチェーン保護のため、サードパーティ製アクションを最も安全にバージョン固定する方法はどれか。',
   NULL,
   '["完全な40文字のコミット SHA でピン留めする（uses: owner/repo@<full-sha>）","メジャータグ @v3 で固定する","@latest で常に最新を使う","@main ブランチで固定する"]', 0, '[0]', 'single',
   '{"asked":"第三者アクションを使う側の視点で、改ざんに最も強い固定方法を選べるか。","terms":[["サプライチェーン保護","外部依存（アクション等）が改ざんされて自分の CI に悪影響を及ぼすのを防ぐこと。"],["SHA ピン留め","コミットの一意なハッシュ（40文字）で固定すること。中身が変わらない不変参照。"]],"think":"店で『最新版ください』ではなく『型番◯◯をください』と指定する感覚。SHA は中身が変わらない指紋なので、後から作者がこっそり差し替えても掴まされない。","vs":"@v3 や @main、@latest はいずれも作者側で中身を貼り替え可能（=動く参照）。問17の『提供側はメジャータグを動かす』とは視点が逆で、ここは使う側が外部依存を固める話。『他人のアクションを使う側のセキュリティ＝フル SHA』と覚える。","opt":["正解。フル SHA は不変で改ざんに強い。","メジャータグは移動可能なため、外部依存では不十分。","@latest は予期せぬ変更が流入し最も危険。","@main も任意に変わるため固定にならない。"]}'),

  ('gh200-q30', 'Secure and Optimize Automation',
   '依存パッケージのインストール時間を短縮するため actions/cache を導入する。キャッシュキー設計として最も適切なのはどれか。',
   '- uses: actions/cache@<sha>\n  with:\n    path: ~/.npm\n    key: npm-${{ hashFiles(''package-lock.json'') }}\n    restore-keys: npm-',
   '["ロックファイルのハッシュをキーに含め、restore-keys で前方一致フォールバックを用意する","毎回固定の文字列キーにする","コミット SHA をキーにする","実行ごとにランダムなキーにする"]', 0, '[0]', 'single',
   '{"asked":"キャッシュが『正しく更新され、かつよく当たる』キー設計の原則を理解しているか。","terms":[["actions/cache","依存関係などを保存して次回の run で再利用し、時間を短縮する公式アクション。"],["hashFiles","指定ファイル（ロックファイル等）の内容からハッシュを生成する関数。"],["restore-keys","キーが完全一致しないとき、前方一致で近いキャッシュを拾うフォールバック。"]],"think":"買い物リスト（ロックファイル）が前回と同じなら、買い置き（キャッシュ）をそのまま使う。リストが変わればキーも変わり、買い直す。完全一致しなくても、近い買い置きは restore-keys で拾ってヒット率を上げる。","vs":"固定キーは依存が更新されても古いキャッシュを使い続けて事故る。SHA キーは毎コミット変わってほぼ当たらない、ランダムキーは一切当たらない。『内容が変わったら鍵も変わる＝hashFiles』『当たりやすくする＝restore-keys』の二本柱で判断。","opt":["正解。hashFiles＋restore-keys がキャッシュ効率の定石。","固定キーだと依存更新後も古いキャッシュを使い続ける。","SHA キーは毎コミットで変わりほぼヒットしない。","ランダムキーはキャッシュが一切効かない。"]}'),

  ('gh200-q31', 'Secure and Optimize Automation',
   'ビルド成果物の出所（誰が・どのワークフローで生成したか）を検証可能にし、改ざんを検出したい。GitHub Actions の機能はどれか。',
   NULL,
   '["Artifact attestation（来歴 / provenance を生成・検証する）","Dependabot alerts","Code scanning","Branch protection"]', 0, '[0]', 'single',
   '{"asked":"成果物の『出所の証明と改ざん検出』を担う機能を、他のセキュリティ機能と区別できるか。","terms":[["artifact attestation","成果物の来歴（provenance）に署名し、どの run から生成されたかを検証可能にする機能。"],["provenance / SLSA","『いつ・どこで・どう作られたか』の来歴情報と、その信頼性基準の枠組み。"]],"think":"製品に『どの工場・どのラインで・いつ作ったか』を記した封印付き証明書を付けるイメージ。後から中身がすり替えられても、証明書と照合すれば改ざんを検出できる。","vs":"Dependabot は依存の脆弱性アラート、Code scanning はコードの静的解析、Branch protection はマージ制御——いずれも守る対象が違う。『成果物の出所証明・改ざん検出＝attestation』と紐づける。","opt":["正解。attestation が成果物の来歴検証を担う。","Dependabot は依存の脆弱性検知で、来歴ではない。","Code scanning はコードの静的解析。","Branch protection はマージ制御。"]}'),

  ('gh200-q32', 'Secure and Optimize Automation',
   'フォークからの pull_request で動くワークフローについて、セキュリティ上正しい理解はどれか。',
   NULL,
   '["フォーク由来のジョブにシークレットは渡されず、GITHUB_TOKEN も読み取り中心に制限される","フォークの PR でも全シークレットが常に利用できる","フォークの PR では GITHUB_TOKEN が常に write 権限を持つ","フォークの PR は常に自動でブロックされ実行できない"]', 0, '[0]', 'single',
   '{"asked":"外部フォークからの PR に対する、シークレット・トークンの既定の安全制限を理解しているか。","terms":[["pull_request（フォーク由来）","見知らぬ第三者のフォークから送られてくる PR。信頼できない入力源とみなされる。"],["pull_request_target","フォーク PR でも昇格した権限で動く別トリガー。便利だが扱いを誤ると危険。"]],"think":"見知らぬ人からの『直してあげました』という提案（フォーク PR）に、いきなり金庫の鍵（シークレット）や書き込み権限を渡したりはしない。既定で読み取り寄りに制限されるのは自然な防御。","vs":"『全シークレット使える』『write 固定』『常にブロック』はいずれも極端な誤り。実際は『シークレット非付与＋トークン制限＋実行自体は可能（設定により承認は要る）』。信頼が要る処理は pull_request_target を慎重に使うか environment で守る、が次の一手。","opt":["正解。フォーク PR はシークレット非付与＋トークン制限が既定。","フォーク PR に全シークレットは渡らない。","フォーク PR の GITHUB_TOKEN は write 固定ではない。","フォーク PR は実行自体は可能（承認設定はあり得る）。"]}'),

  ('gh200-q33', 'Secure and Optimize Automation',
   'GitHub Actions の利用コストと実行時間を削減する施策として有効なものを全て選べ。（複数選択）',
   NULL,
   '["concurrency で重複／古い run をキャンセルする","actions/cache で依存解決を再利用する","matrix の不要な組み合わせを include/exclude で削る","全ジョブを self-hosted の最大スペック機で常時並列実行する"]', 0, '[0,1,2]', 'multi',
   '{"asked":"コスト・時間の削減施策として妥当なものと、一見良さそうで逆効果なものを見分けられるか。","terms":[["分課金","GitHub-hosted ランナーは実行時間（分）で課金される。無駄な実行＝無駄な課金。"],["include / exclude","matrix の組み合わせを足し引きして、実行する数を最適化するキー。"]],"think":"節約の基本は『無駄を止める・やり直しを減らす・量を絞る』。古い run を止める（concurrency）、再ビルドを避ける（cache）、組み合わせを減らす（matrix 絞り込み）はどれもこれに当てはまる。","vs":"『最大スペック機で常時全並列』は速そうに見えて、むしろ単価も同時実行数も増えてコスト浪費になる典型の罠。『最適化＝減らす方向』『常時フルスペック＝増やす方向』で逆だと気づければ弾ける。","opt":["正しい。重複 run のキャンセルは無駄な分課金を防ぐ。","正しい。キャッシュは再ビルド時間を短縮する。","正しい。matrix 絞り込みでジョブ数を最適化する。","誤り。常時最大並列は最適化ではなくコスト増要因。"]}'),

  ('gh200-q34', 'Author and Maintain Actions',
   'Docker container action を作る際、action.yml でコンテナの起動方法として指定できる組み合わせはどれか。',
   'runs:\n  using: ''docker''\n  image: ''______''',
   '["''Dockerfile''（同梱の Dockerfile をビルド）または公開イメージ（docker://...）","''composite''","''node20''","''shell''"]', 0, '[0]', 'single',
   '{"asked":"Docker container action の image 欄に書ける2種類の値を知っているか。","terms":[["using: ''docker''","アクションをコンテナとして動かす指定。"],["image","起動するコンテナの元。同梱 Dockerfile をビルドするか、docker://<registry>/<image> で公開イメージを指す。"]],"think":"料理に例えると、自前のレシピ（Dockerfile）でその場で調理するか、出来合いの缶詰（docker:// の公開イメージ）を使うか。Docker action はこの2通りから選べる。","vs":"composite と node20 は『別種別のアクションの using 値』であって image の値ではない。shell という image 値も存在しない。問15（JS の using=node20）と混同しないよう、『using が docker のときの image は Dockerfile か docker://』と限定して覚える。","opt":["正解。Dockerfile か docker:// イメージを指定する。","composite は別種別の using 値。","node20 は JS アクションの using 値。","shell という image 値は存在しない。"]}'),

  ('gh200-q35', 'Author and Manage Workflows',
   '別リポジトリにある再利用可能ワークフローへ入力値を渡したい。呼び出し側で入力を渡すキーはどれか。',
   'jobs:\n  call:\n    uses: org/repo/.github/workflows/deploy.yml@v1\n    ____:\n      environment: production',
   '["with","inputs","env","params"]', 0, '[0]', 'single',
   '{"asked":"再利用可能ワークフローの『呼び出し側』が入力を渡すキーと、『受け側』が定義するキーを区別できるか。","terms":[["with","呼び出し側で入力値を渡すキー（アクションに入力を渡すときと同じ）。"],["on.workflow_call.inputs","受け側で『どんな入力を受け付けるか』を定義するキー。"]],"think":"受付（受け側）が『inputs という受付票』を用意し、来訪者（呼び出し側）は『with という記入欄』に書いて手渡す。渡す側が触るのは with。","vs":"inputs は受け側の定義キーであって、渡す側の書き方ではない（役割が逆）。env は環境変数、params は存在しないキー。『渡す＝with／受け取る定義＝inputs』と方向で覚える。","opt":["正解。呼び出し側は with で入力を渡す。","inputs は受け側（workflow_call）の定義キー。","env は環境変数で入力受け渡しではない。","params というキーは存在しない。"]}')

) AS v(source_ref, cat_name, question_text, code, options, correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.cat_name
WHERE s.slug = 'gh-200'
ON CONFLICT (subject_id, source_ref) DO NOTHING;
