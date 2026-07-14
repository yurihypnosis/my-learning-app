-- =============================================================
-- 00010_seed_gh200_m2.sql
-- GH-200 GitHub Actions 認定 — 追加50問 (q36–q85)
-- =============================================================

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options, correct_index, correct_indices, question_type, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb, v.correct_index, v.correct_indices::jsonb, v.question_type, v.explanation_data::jsonb, 0
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  -- ============================================================
  -- D1: Author and Manage Workflows (q36–q48)
  -- ============================================================

  ('gh200-q36', 'Author and Manage Workflows',
   'main ブランチへの push のうち、src/ ディレクトリ配下のファイルが変更されたときだけワークフローを起動したい。正しい設定はどれか。',
   'on:\n  push:\n    branches: [main]\n    _____:\n      - ''src/**''',
   '["paths","files","include","filter"]', 0, '[0]', 'single',
   '{"asked":"push トリガーで特定のパスが変更されたときだけ起動する絞り込みキーを知っているか。","terms":[["paths フィルター","ファイルパスのパターンを指定し、マッチするファイルが変更された push / pull_request にのみ起動を限定する。glob パターン（** など）を使える。"],["branches フィルター","ブランチ名で起動対象を絞る。paths と組み合わせて両方の条件を AND で満たす push だけに絞れる。"]],"think":"空港のゲート（branches）は通れたとしても、手荷物検査（paths）で対象ファイルが含まれていないと中に入れない。2つのフィルターは AND 条件として機能する。","vs":"paths-ignore というキーもあり、『指定パスを除いた全変更で起動』に使う。paths と paths-ignore は同時に使えない。files・include・filter は GitHub Actions に存在しないキー。","opt":["正解。paths がパスフィルターの正しいキー。","files は無効なキー。","include は無効なキー。","filter は無効なキー。"]}'),

  ('gh200-q37', 'Author and Manage Workflows',
   'CI ワークフローが成功した後にのみ、別の CD ワークフローを自動起動したい。正しいトリガーはどれか。',
   NULL,
   '["workflow_run","workflow_call","on: push (needs あり)","repository_dispatch"]', 0, '[0]', 'single',
   '{"asked":"別ワークフローの完了をトリガーに起動する仕組みを知っているか。","terms":[["workflow_run","指定した別ワークフローが完了（completed）・要求（requested）・進行中（in_progress）になったときに起動するトリガー。同じリポジトリ内の別ワークフローを『連鎖』させる。"],["workflow_call","ワークフローを再利用可能にして、他のワークフローから呼び出す仕組み。連鎖ではなく『呼び出し』。"]],"think":"リレーのバトンパス。前走者（CI）がゴールしたのを見届けてから次のランナー（CD）が走る。これが workflow_run。workflow_call は『チームプレーで同じ処理を共有する』もので、連鎖とは別の概念。","vs":"workflow_call は呼び出し元が明示的に uses で呼ぶ形。workflow_run は受け取る側が on: workflow_run で宣言する形。方向が逆。repository_dispatch は外部システムからの API 呼び出しで起動する。","opt":["正解。別ワークフローの完了を待って起動する。","再利用可能ワークフローの呼び出しキーで、連鎖ではない。","needs はジョブ間の依存でワークフロー間には使えない。","外部APIからの手動トリガー。"]}'),

  ('gh200-q38', 'Author and Manage Workflows',
   'push と pull_request の両方をトリガーにしているが、pull_request のときだけ追加のステップを実行したい。正しい if 条件はどれか。',
   NULL,
   '["if: github.event_name == ''pull_request''","if: github.event == ''pull_request''","if: env.EVENT == ''pull_request''","if: trigger == ''pull_request''"]', 0, '[0]', 'single',
   '{"asked":"現在のイベント名を参照するコンテキストを正確に知っているか。","terms":[["github.event_name","現在のトリガーイベント名（push・pull_request・workflow_dispatch など）を文字列で返すコンテキスト。"],["github.event","イベントの詳細ペイロード（issue 番号、PR タイトルなど）が入る。イベント名そのものではない。"]],"think":"コンビニのレジで『何で払いますか？』と聞かれたとき、支払い方法の種類（クレジット）を答えるのが event_name。財布の中身（金額・カード番号）を答えるのが event の中身。","vs":"github.event_name＝名前の文字列、github.event＝詳細オブジェクト。この2つは全く別物。env.EVENT は自分で設定しないと空、trigger というコンテキストは存在しない。","opt":["正解。イベント名を文字列で返す正しいコンテキスト。","github.event はペイロードオブジェクトで名前ではない。","env は環境変数の箱。自動では入らない。","trigger というコンテキストは存在しない。"]}'),

  ('gh200-q39', 'Author and Manage Workflows',
   'テストステップが失敗しても後続のレポート生成ステップを必ず実行したい。最も適切な設定はどれか。',
   'steps:\n  - name: Run tests\n    id: tests\n    run: npm test\n  - name: Generate report\n    _____: always()',
   '["if","continue-on-error","needs","when"]', 0, '[0]', 'single',
   '{"asked":"前のステップが失敗してもそのステップを実行する制御キーと条件関数を知っているか。","terms":[["if: always()","前のステップの成否に関わらず必ず実行する条件式。デフォルトはステップが成功時のみ実行。"],["always()","ジョブやステップの status に関係なく true を返す組み込み関数。キャンセル時にも実行する。"],["continue-on-error: true","そのステップが失敗してもジョブを失敗とみなさず後続ステップを続ける設定。if とは異なる。"]],"think":"スポーツのリレーでバトンを落としても、後ろの選手がコースに出て最後まで走る設定。if: always() は「前の人が転んでも私は走る」という宣言。","vs":"continue-on-error: true はテストステップに付けると『失敗を成功扱いにする』もので、後続ステップへの影響を変える。if: always() はレポートステップ側に付けて『前が失敗でも私は動く』設定。目的が違う。","opt":["正解。if: always() で前ステップの失敗に関わらず実行できる。","テストステップに付けると失敗を成功扱いにしてしまう。ここで使う対象が違う。","needs はジョブ間の依存キーでステップには使えない。","when というキーは存在しない。"]}'),

  ('gh200-q40', 'Author and Manage Workflows',
   'build ジョブでビルドしたバージョン番号を、後続の deploy ジョブで使いたい。正しい方法はどれか。',
   'jobs:\n  build:\n    outputs:\n      version: ${{ steps.ver.outputs.version }}\n    steps:\n      - id: ver\n        run: echo "version=1.2.3" >> $GITHUB_OUTPUT',
   '["deploy ジョブで needs.build.outputs.version を参照する","deploy ジョブで env.version を参照する","deploy ジョブで steps.ver.outputs.version を参照する","deploy ジョブで github.outputs.version を参照する"]', 0, '[0]', 'single',
   '{"asked":"ジョブ間で値を受け渡す outputs の参照パスを正確に知っているか。","terms":[["jobs.<id>.outputs","ジョブが外部に公開する出力値の定義。needs で依存しているジョブの出力を参照できる。"],["needs.<job>.outputs.<name>","依存ジョブの出力値を参照するコンテキストパス。"],["GITHUB_OUTPUT","ステップから次のステップ（同一ジョブ内）に値を渡す環境ファイル。echo key=value >> $GITHUB_OUTPUT で書き込む。"]],"think":"工場（build ジョブ）が伝票（outputs）に品番を書いて出荷し、倉庫（deploy ジョブ）が入荷伝票（needs.build.outputs）を読む流れ。ジョブをまたぐ宅配便はこの伝票経由でしか届かない。","vs":"steps.ver.outputs は同じジョブ内のステップ間参照。別ジョブからは見えない。env は環境変数でジョブをまたいで自動引き継ぎはされない。","opt":["正解。ジョブ間出力は needs.<job>.outputs.<name> で参照する。","env はジョブをまたいで自動伝播しない。","steps.<id>.outputs は同一ジョブ内だけの参照。","github コンテキストに outputs は無い。"]}'),

  ('gh200-q41', 'Author and Manage Workflows',
   'ワークフロー内の全ステップのデフォルトシェルを bash に、作業ディレクトリを ./app に設定したい。最も適切な場所はどれか。',
   'jobs:\n  build:\n    _____:\n      run:\n        shell: bash\n        working-directory: ./app',
   '["defaults","settings","options","config"]', 0, '[0]', 'single',
   '{"asked":"ワークフローまたはジョブのデフォルト実行設定を一括指定するキーを知っているか。","terms":[["defaults","シェルや作業ディレクトリのデフォルト値をジョブ全体または特定ステップに適用するキー。ジョブレベルまたはワークフロートップレベルに置ける。"],["defaults.run","run ステップのデフォルト設定（shell・working-directory）を一括指定する。"]],"think":"会社の就業規則（defaults）でコアタイムや服装規定を全員に一括適用するのと同じ。各ステップで毎回 shell: bash を書く手間を省ける。","vs":"settings・options・config は GitHub Actions に存在しないキー。ステップ個別に shell: bash を書くと重複が増えるので defaults の方が DRY。","opt":["正解。defaults.run でシェルと作業ディレクトリを一括設定できる。","settings は存在しないキー。","options は存在しないキー。","config は存在しないキー。"]}'),

  ('gh200-q42', 'Author and Manage Workflows',
   'main ブランチへの push が連続した場合、古い実行をキャンセルして最新の実行だけ続けたい。正しい設定はどれか。',
   'concurrency:\n  group: ${{ github.ref }}\n  _____: true',
   '["cancel-in-progress","cancel-previous","abort-old","interrupt"]', 0, '[0]', 'single',
   '{"asked":"concurrency でグループ内の古い実行を自動キャンセルするキーを知っているか。","terms":[["concurrency","同じグループ内で実行を1つに制限し、既存の実行をキャンセルするかキューイングするかを制御する機能。"],["cancel-in-progress: true","同じグループで実行中のワークフローがあれば即座にキャンセルし、新しい実行を優先する。false（デフォルト）は新しい実行をキューに入れる。"]],"think":"エレベーターが1台しかないビル。古い呼び出しを取り消して最新の呼び出しだけ答えるのが cancel-in-progress: true。false はキューに並ばせる（全部実行される）。","vs":"cancel-previous・abort-old・interrupt は存在しないキー。concurrency はジョブレベルにも置けて、デプロイの二重実行防止にも使われる。","opt":["正解。進行中の同一グループ実行をキャンセルして最新を優先する。","cancel-previous は存在しない。","abort-old は存在しない。","interrupt は存在しない。"]}'),

  ('gh200-q43', 'Author and Manage Workflows',
   'テストジョブが無限ループに陥った場合に備え、最大30分で強制終了させたい。正しい設定はどれか。',
   'jobs:\n  test:\n    _____: 30',
   '["timeout-minutes","max-duration","time-limit","run-limit"]', 0, '[0]', 'single',
   '{"asked":"ジョブのタイムアウトを分単位で設定するキーを知っているか。","terms":[["timeout-minutes","ジョブまたはステップが実行できる最大時間（分）。超えると自動キャンセルされる。デフォルトは 360 分（6時間）。"]],"think":"電子レンジのタイマー。いくら調理中でも設定時間が来れば自動で止まる。無限ループによるクレジット消費を防ぐ安全装置。","vs":"max-duration・time-limit・run-limit は存在しないキー。ステップレベルにも timeout-minutes を置ける（ジョブ設定より優先される）。","opt":["正解。分単位でジョブのタイムアウトを設定する正しいキー。","max-duration は存在しない。","time-limit は存在しない。","run-limit は存在しない。"]}'),

  ('gh200-q44', 'Author and Manage Workflows',
   'テストジョブが失敗した場合でも、後続のクリーンアップジョブを必ず実行したい。正しい設定はどれか。',
   'jobs:\n  test:\n    ...\n  cleanup:\n    needs: test\n    if: _____',
   '["always()","success()","failure()","!cancelled()"]', 0, '[0]', 'single',
   '{"asked":"needs に依存しているジョブで、前ジョブが失敗してもキャンセルせず実行させる条件式を知っているか。","terms":[["always()","ジョブ・ステップの成否やキャンセルに関わらず常に true を返す。クリーンアップ処理に最適。"],["success()","前のジョブが全て成功した場合のみ true。needs があるときのデフォルト条件。"],["failure()","依存ジョブのいずれかが失敗した場合のみ true。"]],"think":"レストランで食事（テスト）が終わったら食器の片付け（クリーンアップ）は必ずやる。食事が失敗しても（お客様が食べられなくても）片付けはする。それが always()。","vs":"needs があると、デフォルトは success() 相当。テストが失敗したとき cleanup がキャンセルされるのはそのため。always() を明示して初めてどんな場合でも実行される。!cancelled() は「キャンセルでない限り」でほぼ同じだが、failure() の場合を含まないことがある。","opt":["正解。成否・キャンセル問わず必ず実行する。","デフォルト。テスト失敗でクリーンアップはキャンセルされる。","テスト失敗時のみ実行。成功時に片付けができない。","キャンセル以外で実行するが、always() の方が明示的で意図が明確。"]}'),

  ('gh200-q45', 'Author and Manage Workflows',
   'ワークフロー内でリポジトリ名を取得したい。正しい参照はどれか。',
   NULL,
   '["${{ github.repository }}","${{ env.REPOSITORY }}","${{ runner.name }}","${{ job.name }}"]', 0, '[0]', 'single',
   '{"asked":"github コンテキストからリポジトリ名を取得する正しいプロパティを知っているか。","terms":[["github コンテキスト","ワークフロー実行に関するメタ情報（リポジトリ名・ブランチ名・コミット SHA・イベント名など）を持つ。"],["github.repository","owner/repo 形式のリポジトリ名。例: octocat/hello-world"],["runner コンテキスト","ランナーのOSやアーキテクチャ情報を持つ。リポジトリ情報は含まない。"]],"think":"GitHub というサービスの住民票（github コンテキスト）にはリポジトリ名・ブランチ名・オーナー名などが記載されている。リポジトリそのものの情報は必ず github.* から引く。","vs":"env.REPOSITORY は自分でセットしない限り空。runner はジョブが動いているマシンの情報（OSなど）。job はジョブのステータスで、名前はジョブIDからしか取れない。","opt":["正解。owner/repo 形式のリポジトリ名を返す。","env は環境変数の箱で、自動設定はされない。","runner はランナーマシンの情報（OS など）。","job はジョブのステータス情報。"]}'),

  ('gh200-q46', 'Author and Manage Workflows',
   'Node.js プロジェクトで npm install の結果を次回のワークフロー実行でも再利用してビルドを高速化したい。最も適切なアクションはどれか。',
   NULL,
   '["actions/cache","actions/upload-artifact","actions/download-artifact","actions/setup-node"]', 0, '[0]', 'single',
   '{"asked":"依存関係のキャッシュと成果物の保存を区別し、適切なアクションを選べるか。","terms":[["actions/cache","ビルドキャッシュ（node_modules など）を保存・復元する。キー（通常 package-lock.json のハッシュ）が同じなら前回の結果を再利用し実行時間を短縮する。"],["actions/upload-artifact","ワークフローの成果物（バイナリ・レポートなど）をアップロードする。別ジョブや人が後でダウンロードして使う用途。キャッシュとは異なりすべての実行で保存・閲覧できる。"]],"think":"引っ越しのとき毎回家具を買い直すか（毎回 npm install）、倉庫に預けておいた家具を取り出すか（cache）。キャッシュは『同じ荷物』と判断できたときだけ再利用する。","vs":"upload-artifact は成果物の保管（ビルド結果・テストレポートを保存して後で確認）で、キャッシュではない。setup-node はランナーに Node.js をインストールするだけ。","opt":["正解。依存関係を実行間でキャッシュして高速化する。","成果物のアップロード用で、キャッシュ機能はない。","成果物のダウンロード用。","Node.js のインストール用で、キャッシュは別途必要。"]}'),

  ('gh200-q47', 'Author and Manage Workflows',
   'ステップでビルドしたバージョン番号を同一ジョブの次のステップに渡したい。最も現代的な方法はどれか。',
   NULL,
   '["echo \"version=1.2.3\" >> $GITHUB_OUTPUT と steps.<id>.outputs.version で参照","echo \"::set-output name=version::1.2.3\" を使う","GITHUB_ENV ファイルに書き込む","GITHUB_STEP_SUMMARY に書き込む"]', 0, '[0]', 'single',
   '{"asked":"ステップ出力の現行の推奨方法と非推奨の方法を区別できるか。","terms":[["GITHUB_OUTPUT","ステップの出力値を次のステップに渡す環境ファイル（推奨）。echo key=value >> $GITHUB_OUTPUT で書き込み、${{ steps.<id>.outputs.<key> }} で参照。"],["::set-output","旧来のワークフローコマンド（非推奨・廃止済み）。インジェクション脆弱性のため GITHUB_OUTPUT に置き換えられた。"],["GITHUB_ENV","環境変数として以降のステップ全体に渡す。出力値の共有というより env セット用。"],["GITHUB_STEP_SUMMARY","ジョブサマリーページに Markdown を表示するファイル。値の受け渡しではない。"]],"think":"社内メモを回す方法：旧システム（::set-output）は廃止されたFAX、新システム（GITHUB_OUTPUT ファイル）は安全な社内チャット。","vs":"::set-output はセキュリティ問題で廃止。試験でも非推奨として認識しておく。GITHUB_ENV は環境変数の設定で、outputs コンテキストには入らない。","opt":["正解。GITHUB_OUTPUT ファイルへの書き込みが現在の推奨方式。","::set-output は非推奨・廃止済み。使ってはいけない。","GITHUB_ENV は環境変数のセットで、outputs とは別の仕組み。","GITHUB_STEP_SUMMARY はサマリー表示用でデータ受け渡しには使わない。"]}'),

  ('gh200-q48', 'Author and Manage Workflows',
   'ワークフローがリポジトリの内容を読む必要があるが、書き込みは不要。最小権限で設定するにはどれか。',
   'permissions:\n  contents: _____',
   '["read","write","none","read-write"]', 0, '[0]', 'single',
   '{"asked":"GITHUB_TOKEN の contents 権限を最小権限の原則で正しく設定できるか。","terms":[["permissions","ワークフロー・ジョブ単位で GITHUB_TOKEN に付与する権限スコープと読み書きレベルを宣言する。"],["contents: read","リポジトリのコード・タグ・リリースを読み取れる。push や commit には使えない最小レベル。"],["最小権限の原則","必要な最低限の権限しか付与しない。攻撃されてもトークンが使える範囲を制限できる。"]],"think":"鍵束（GITHUB_TOKEN）に用途外の鍵を付けない。読むだけの仕事には読み取り鍵（read）だけ渡せば、鍵を盗まれても書き換えはできない。","vs":"write は書き込みも含む過剰な権限。none は完全禁止（clone も不可）。read-write は GitHub Actions の値ではない（read・write・none の3種）。","opt":["正解。読み取り専用で最小権限。","書き込み権限も含む。読むだけなら過剰。","アクセス完全禁止。clone もできなくなる。","read-write という値は存在しない。"]}'),

  -- ============================================================
  -- D2: Consume and Troubleshoot Workflows (q49–q58)
  -- ============================================================

  ('gh200-q49', 'Consume and Troubleshoot Workflows',
   'build ジョブで生成したバイナリを test ジョブと deploy ジョブの両方でダウンロードして使いたい。最も適切な方法はどれか。',
   NULL,
   '["build で actions/upload-artifact、test と deploy で actions/download-artifact を使う","build で GITHUB_OUTPUT に書き、test と deploy で steps.<id>.outputs で読む","build で actions/cache でキャッシュし、test と deploy で同じキーで復元","build で GCS にアップロードし、test と deploy でダウンロード"]', 0, '[0]', 'single',
   '{"asked":"成果物（artifact）を複数ジョブ間で共有する正しい手段を選べるか。","terms":[["actions/upload-artifact","ワークフロー中に生成されたファイルを GitHub の成果物ストレージにアップロードする。同一ワークフロー実行内で他ジョブからダウンロードできる。"],["actions/download-artifact","upload-artifact でアップロードした成果物を取得する。複数ジョブが同じ成果物を個別にダウンロードできる。"]],"think":"共有ドライブにバイナリを置いて（upload）、複数人が各自でダウンロード（download）するイメージ。GITHUB_OUTPUT や cache は別の用途でジョブをまたぐファイル共有には向かない。","vs":"GITHUB_OUTPUT は文字列値をジョブ出力するもので、バイナリファイルには使えない。actions/cache はキャッシュキーが同じ場合のみ復元し、ランランごとの成果物共有には不向き。","opt":["正解。ジョブ間でファイルを渡す標準手段。","GITHUB_OUTPUT は文字列値限定でファイル転送には使えない。","cache はビルド高速化用でジョブ間成果物の確実な受け渡しには不向き。","外部ストレージは不必要に複雑で認証も必要になる。"]}'),

  ('gh200-q50', 'Consume and Troubleshoot Workflows',
   '再利用可能ワークフロー（workflow_call）を呼び出すときに、呼び出し元が渡した入力値とシークレットを受け取れるよう定義する場所はどこか。',
   'on:\n  workflow_call:\n    _____:\n      environment:\n        type: string',
   '["inputs","parameters","args","variables"]', 0, '[0]', 'single',
   '{"asked":"再利用可能ワークフローで呼び出し元から値を受け取る定義キーを知っているか。","terms":[["workflow_call","ワークフローを再利用可能にするトリガー。uses: キーで呼び出せる。"],["inputs（workflow_call 下）","呼び出し元が with: で渡す値の型・必須・デフォルトを定義するセクション。string・boolean・number の型を指定できる。"]],"think":"API の引数定義と同じ。関数（再利用可能 WF）の入力パラメーターを inputs で宣言し、呼び出し側が with: で値を渡す。","vs":"secrets も workflow_call 下に定義できるが、機密値用の別セクション。inputs は非機密の値。parameters・args・variables は GitHub Actions の正しいキーではない。","opt":["正解。呼び出し元から渡される入力値の定義キー。","parameters は存在しないキー。","args は存在しないキー。","variables は存在しないキー。"]}'),

  ('gh200-q51', 'Consume and Troubleshoot Workflows',
   'ワークフローの各ステップの詳細なデバッグログを有効にしたい。最も適切な方法はどれか。',
   NULL,
   '["リポジトリの Secrets に ACTIONS_STEP_DEBUG を true でセット","ワークフロー YAML に debug: true を追加","gh workflow run --debug フラグを付けて実行","ランナーの環境変数 DEBUG=true をセット"]', 0, '[0]', 'single',
   '{"asked":"GitHub Actions のステップレベルデバッグログを有効にする正しい方法を知っているか。","terms":[["ACTIONS_STEP_DEBUG","true にセットするとランナー診断ログとステップデバッグログが有効になる。シークレットまたは変数として設定する。"],["ACTIONS_RUNNER_DEBUG","ランナー自体の詳細ログを有効にする。ACTIONS_STEP_DEBUG と併用することが多い。"]],"think":"カメラのデバッグモード。普段は見えない内部処理（ステップの詳細）を録画するスイッチを入れるのが ACTIONS_STEP_DEBUG。このスイッチは設定画面（Secrets）から入れる。","vs":"gh workflow run --verbose はあるが --debug フラグはなく、ランナー側の詳細ログには影響しない。YAML に debug: true というキーは存在しない。","opt":["正解。ACTIONS_STEP_DEBUG シークレットを true にするとデバッグログが有効。","YAML に debug: true というキーは存在しない。","gh CLI に --debug フラグは存在しない。","ランナー環境変数では GitHub のステップログには影響しない。"]}'),

  ('gh200-q52', 'Consume and Troubleshoot Workflows',
   '再利用可能ワークフローの実行結果を呼び出し元のワークフローで受け取りたい。どうすればよいか。',
   NULL,
   '["workflow_call の on.workflow_call.outputs にキーを定義し、呼び出し元で needs.<job>.outputs.<key> で参照","GITHUB_OUTPUT を使って呼び出し元の GITHUB_ENV に書き込む","共有アーティファクトに値を書き込んで呼び出し元でダウンロード","呼び出し元と呼び出し先でシークレットを共有する"]', 0, '[0]', 'single',
   '{"asked":"再利用可能ワークフローが呼び出し元に値を返す仕組みを理解しているか。","terms":[["on.workflow_call.outputs","再利用可能ワークフローが外部に公開する出力値の定義。内部ジョブの outputs を参照できる。"],["needs.<job>.outputs","呼び出し元ワークフローでは、呼び出したジョブ（uses: を書いたジョブ）の outputs として参照できる。"]],"think":"受託工場（再利用可能 WF）が製品を作って『出来上がり数量』を納品書に書く（outputs 定義）。発注元（呼び出し元）が納品書（needs.*.outputs）を読む仕組み。","vs":"GITHUB_ENV はジョブをまたがない。アーティファクトはファイルの受け渡しで、値の返却には過剰。シークレット共有は機密値管理であり値の返却とは無関係。","opt":["正解。outputs セクションで定義し呼び出し元で needs.*.outputs として参照する。","GITHUB_ENV の内容は別ワークフローに自動伝播しない。","ファイル受け渡し手段であり、値の返却には不適切。","シークレット共有は機密値用で値の返却ではない。"]}'),

  ('gh200-q53', 'Consume and Troubleshoot Workflows',
   'ワークフローの一部のジョブが失敗した後、失敗したジョブだけを再実行したい。この操作はどこで行うか。',
   NULL,
   '["GitHub UI の Actions タブ → 実行詳細画面 → 「Re-run failed jobs」","ワークフロー YAML に retry: true を追加","gh workflow run コマンドで再実行","新しいコミットを push して再トリガー"]', 0, '[0]', 'single',
   '{"asked":"失敗したジョブのみを再実行する操作手順を知っているか。","terms":[["Re-run failed jobs","GitHub UI の実行詳細画面右上にあるボタン。失敗したジョブだけを再実行し、成功済みジョブの結果を再利用する。","Re-run all jobs は全ジョブをゼロから実行し直す。"]],"think":"テスト答案を全問やり直す（Re-run all）か、間違えた問題だけやり直す（Re-run failed）かの違い。ビルドが成功していれば壊さないで、失敗したテストだけ直したい場面に最適。","vs":"retry: true というキーは YAML に存在しない。gh CLI で再実行は可能だが『失敗したジョブだけ』を指定する場合は UI が最も直感的。新しい push は別の実行になり、再実行ではない。","opt":["正解。UI から失敗ジョブのみ再実行できる。","retry: true というキーは存在しない。","gh CLI でも可能だが『失敗のみ』指定は UI が直感的。","別の実行になってしまい、再実行ではない。"]}'),

  ('gh200-q54', 'Consume and Troubleshoot Workflows',
   'README に「main ブランチの CI ワークフロー」のステータスバッジを埋め込みたい。バッジ URL の形式として正しいものはどれか。',
   NULL,
   '["https://github.com/<owner>/<repo>/actions/workflows/<filename>.yml/badge.svg","https://github.com/<owner>/<repo>/actions/badge/<workflow-name>.svg","https://shields.io/github/actions/<owner>/<repo>","https://api.github.com/repos/<owner>/<repo>/actions/runs/latest/badge"]', 0, '[0]', 'single',
   '{"asked":"GitHub Actions のワークフローステータスバッジの正しい URL パターンを知っているか。","terms":[["ステータスバッジ","ワークフローの最新実行結果（passing/failing）を SVG 画像で表示する。README やドキュメントに埋め込んで CI の状態を一目で確認できる。"]],"think":"郵便受けの旗（バッジ）を見れば郵便が届いているか一目でわかる。バッジ URL は /actions/workflows/<ファイル名>/badge.svg の形で、ファイル名（.yml）まで含める。","vs":"ファイル名でなくワークフロー名（name:）を使う形式は正しくない。shields.io は外部サービスで GitHub 公式のバッジとは異なる。api.github.com のパスも公式バッジの形式ではない。","opt":["正解。ワークフローファイル名を含む公式バッジ URL。","ワークフロー名ではなくファイル名が必要。","shields.io は外部サービス。公式バッジはこの形式ではない。","この API パスはバッジ画像を返さない。"]}'),

  ('gh200-q55', 'Consume and Troubleshoot Workflows',
   'main ブランチへのマージ前に「CI / tests」ステータスチェックが必ず成功している必要がある。どこで設定するか。',
   NULL,
   '["リポジトリの Settings → Branches → ブランチ保護ルール → Require status checks to pass","ワークフロー YAML に required: true を追加","CODEOWNERS ファイルでワークフローを指定","リポジトリの Actions → General → Required workflows"]', 0, '[0]', 'single',
   '{"asked":"必須ステータスチェックの設定場所を知っているか。","terms":[["ブランチ保護ルール","Settings → Branches で main などのブランチへの push/merge の条件を設定する機能。特定のステータスチェックの成功を義務付けられる。"],["Require status checks to pass","PR のマージ前に指定したジョブ・ステータスチェックが成功必須になる設定。"]],"think":"ビルのセキュリティゲート。フロアに入るには受付でのチェック（ステータスチェック）が通らないとドア（merge）が開かない。ゲートの設定は警備室（Settings → Branches）で行う。","vs":"YAML に required: true キーは存在しない。CODEOWNERS はファイル変更の承認者を設定するもの。Required workflows（Enterprise 機能）は組織全体に必須ワークフローを課すもので、特定ブランチのステータスチェックとは別。","opt":["正解。ブランチ保護ルールで必須チェックを設定する。","YAML に required: true は存在しない。","CODEOWNERS はコードオーナー指定で、チェック義務化とは別。","Enterprise の必須ワークフロー機能で、ブランチ保護とは異なる。"]}'),

  ('gh200-q56', 'Consume and Troubleshoot Workflows',
   'fork からの pull_request イベントで、フォーク元のコードを安全にチェックアウトするにはどのアクションを使えばよいか。',
   NULL,
   '["actions/checkout（デフォルト動作で pull_request は head を安全にチェックアウト）","actions/checkout --fork","pull_request_target トリガーに切り替えて actions/checkout","外部コードは手動でダウンロードしてチェックアウト"]', 0, '[0]', 'single',
   '{"asked":"pull_request トリガーのセキュリティモデルと fork コードの扱いを理解しているか。","terms":[["pull_request","fork からの PR でも制限されたトークン権限（読み取りのみ）でコードをチェックアウトして実行。シークレットは渡されないため安全。"],["pull_request_target","ベースリポジトリの文脈で実行されシークレットにアクセス可能。fork の HEAD コードを直接チェックアウトすると危険。"]],"think":"見知らぬ人が持ってきたコード（fork の PR）を隔離された試験室（制限されたトークン）で動かすのが pull_request。試験室は機密書類（シークレット）を持ち込めないから安全。","vs":"pull_request_target はシークレットが使えるが fork のコードを直接実行すると悪意あるコードがシークレットを盗める危険がある。--fork オプションは存在しない。","opt":["正解。pull_request トリガーは fork PR でも制限権限で安全にチェックアウトできる。","--fork オプションは存在しない。","pull_request_target は fork の HEAD を直接チェックアウトすると危険。","手動ダウンロードは不必要で実用的でない。"]}'),

  ('gh200-q57', 'Consume and Troubleshoot Workflows',
   'ワークフローの実行ログに「Error: Process completed with exit code 1.」と表示されているが、どのステップが失敗したか特定できない。最初に確認すべき場所はどこか。',
   NULL,
   '["UI の実行詳細でジョブを展開し、赤くなっているステップのログを確認","GITHUB_STEP_SUMMARY を読む","リポジトリの Insights → Actions","gh run view コマンドで最新の実行一覧を確認"]', 0, '[0]', 'single',
   '{"asked":"ワークフロー失敗時に失敗ステップを特定するデバッグ手順を知っているか。","terms":[["実行詳細画面","Actions タブ → 実行をクリック → ジョブをクリックすると各ステップのログが展開表示される。赤いバツ印のステップが失敗箇所。"],["GITHUB_STEP_SUMMARY","各ステップが書き込んだサマリーを実行詳細の Summary タブに表示。詳細ログではない。"]],"think":"病院のカルテ（実行ログ）を開いて、どの検査（ステップ）で数値が異常値（赤）だったかを確認するのと同じ。まず視覚的に赤いステップを探す。","vs":"GITHUB_STEP_SUMMARY はステップが書いたサマリーで、エラーの詳細ログではない。Insights → Actions はワークフロー全体のトレンドで個別エラーの特定には使わない。gh run view は概要を出すが詳細ログの確認は UI が速い。","opt":["正解。UI でジョブ → ステップを展開して赤いステップのログを読む。","サマリー表示で詳細エラーログではない。","全体トレンド表示で個別エラー特定には不向き。","実行一覧の取得コマンドで、詳細ログの確認には追加ステップが必要。"]}'),

  ('gh200-q58', 'Consume and Troubleshoot Workflows',
   'あるステップ（id: lint）が失敗したときだけ、次のステップでエラーメッセージを出力したい。正しい if 条件はどれか。',
   NULL,
   '["if: steps.lint.outcome == ''failure''","if: steps.lint.result == ''failure''","if: failure()","if: steps.lint.status == ''failed''"]', 0, '[0]', 'single',
   '{"asked":"steps コンテキストの outcome プロパティを正しく参照できるか。","terms":[["steps.<id>.outcome","continue-on-error 適用前のステップの実際の結果（success・failure・cancelled・skipped）。","steps.<id>.conclusion は continue-on-error 後の最終判定。"]],"think":"採点前の答案（outcome）と、採点・補正後の成績証明書（conclusion）の違い。continue-on-error で失敗を成功扱いにしても outcome には元の失敗が残る。","vs":"result というプロパティは steps コンテキストには存在しない。failure() 関数はジョブ全体の状態を見るもので特定ステップの結果ではない。status という名前のプロパティも存在しない。","opt":["正解。steps.<id>.outcome で特定ステップの実際の結果を参照する。","result というプロパティは存在しない。","failure() はジョブ全体の状態を返し、特定ステップは判別できない。","status というプロパティは存在しない。"]}'),

  -- ============================================================
  -- D3: Author and Maintain Actions (q59–q68)
  -- ============================================================

  ('gh200-q59', 'Author and Maintain Actions',
   'シェルスクリプトで実装した複数のステップをひとまとめにして再利用したい。最もシンプルなアクション種別はどれか。',
   NULL,
   '["Composite action","JavaScript action","Docker container action","Reusable workflow"]', 0, '[0]', 'single',
   '{"asked":"3種類のアクション（Composite・JavaScript・Docker）の特性と使い分けを理解しているか。","terms":[["Composite action","複数の run ステップや他のアクション呼び出しをまとめた action。YAML だけで定義でき、特別なランタイムやコンテナは不要。最もシンプル。"],["JavaScript action","Node.js で実装。@actions/core などの SDK を使える。高速だがランナーに Node.js が必要。"],["Docker container action","Dockerfile でランタイムごとパッケージ。Linux ランナーのみ対応。起動に時間がかかる。"]],"think":"お弁当箱（Composite）は既に作った料理を詰め合わせるだけで簡単。フライパン（JavaScript）は本格的だが調理技術が要る。キッチン丸ごと（Docker）は最も強力だが準備に時間がかかる。","vs":"Reusable workflow は .github/workflows/ に置くワークフロー全体の再利用で、1つのステップとして uses で呼ぶアクションとは階層が異なる。","opt":["正解。シェルスクリプトの複数ステップをまとめるなら Composite が最もシンプル。","Node.js 実装が必要で、シェルスクリプトの再利用には過剰。","Dockerfile が必要でシンプルではない。","ワークフロー全体の再利用でアクションとは異なる。"]}'),

  ('gh200-q60', 'Author and Maintain Actions',
   'Composite action の action.yml で、内部の run ステップのシェルを指定するために必須のキーはどれか。',
   'runs:\n  using: composite\n  steps:\n    - run: echo hello\n      _____: bash',
   '["shell","run-shell","exec","interpreter"]', 0, '[0]', 'single',
   '{"asked":"Composite action の steps で run を使うとき shell の指定が必須であることを知っているか。","terms":[["shell（Composite action 内）","Composite action の steps に run を書く場合は shell の明示が必須（通常のワークフロー YAML では省略できるが Composite では省略不可）。"]],"think":"レシピ本（action.yml）には『どの調理器具（shell）を使うか』を必ず書かなければならないルール。ワークフロー本体と違って省略できないので注意。","vs":"通常のワークフローでは shell を省略すると自動でデフォルト（bash / powershell）が選ばれるが、Composite では省略するとエラーになる。run-shell・exec・interpreter は存在しないキー。","opt":["正解。Composite action の run ステップでは shell 指定が必須。","run-shell は存在しないキー。","exec は存在しないキー。","interpreter は存在しないキー。"]}'),

  ('gh200-q61', 'Author and Maintain Actions',
   'JavaScript action でエラーを検出し、ワークフローをステップを失敗させたい。@actions/core の正しいメソッドはどれか。',
   NULL,
   '["core.setFailed(message)","core.error(message)","core.fail(message)","process.exit(1)"]', 0, '[0]', 'single',
   '{"asked":"JavaScript action でステップを失敗させる正式な方法を知っているか。","terms":[["core.setFailed(message)","ステップに失敗マークを付けてワークフローを失敗終了させる。エラーメッセージを Annotations に表示する。","@actions/core パッケージが提供する公式 API。"],["core.error(message)","エラーアノテーションを表示するが、それだけではステップは失敗にならない。"],["process.exit(1)","Node.js の終了でステップが失敗するが、エラーメッセージの適切な表示がされず、非推奨。"]],"think":"火災報知器（setFailed）は警告音を鳴らして人を避難させる（ワークフロー停止）。単なる警告灯（error）は光るだけで避難指示は出ない。","vs":"core.error は注釈としてエラーを表示するが、ステップを失敗にするには setFailed が必要。process.exit(1) は動くが GitHub Actions の適切な失敗シグナルではない（ログが不完全になる）。","opt":["正解。ステップを失敗にしてメッセージを表示する公式メソッド。","エラー注釈を表示するが、ステップを失敗にはしない。","core.fail は存在しない。","動くが非推奨。ログが不完全になる可能性がある。"]}'),

  ('gh200-q62', 'Author and Maintain Actions',
   'Docker container action の action.yml で、実行するコンテナのエントリポイントスクリプトを指定するキーはどれか。',
   'runs:\n  using: docker\n  image: Dockerfile\n  _____: /entrypoint.sh',
   '["entrypoint","cmd","run","command"]', 0, '[0]', 'single',
   '{"asked":"Docker action の action.yml で entrypoint を指定するキーを知っているか。","terms":[["entrypoint","Docker action で実行するスクリプトまたはバイナリのパスを指定するキー。Dockerfile の ENTRYPOINT を上書きできる。"],["args","entrypoint に渡す引数を配列で指定する。"]],"think":"レストランのシェフ（entrypoint）を指名して、何を作るか（args）を指示するイメージ。Dockerfile にシェフが書いてあっても action.yml で別のシェフを指名できる（上書き）。","vs":"cmd は Docker 本来の CMD 命令に相当するが action.yml のキー名は args。run は Composite action のキーで Docker action には使わない。command は存在しないキー。","opt":["正解。Docker action の実行エントリポイントを指定するキー。","cmd は Docker の概念で action.yml のキー名ではない。","run は Composite action 用。","command は存在しないキー。"]}'),

  ('gh200-q63', 'Author and Maintain Actions',
   'GitHub Marketplace にアクションを公開するための必須条件はどれか。',
   NULL,
   '["パブリックリポジトリのルートに action.yml（または action.yaml）を置く","actions という名前の organization にリポジトリを作る","release を作成し v1.0.0 タグを付ける","README.md に uses の例を記載する"]', 0, '[0]', 'single',
   '{"asked":"Marketplace への公開に必須な条件を知っているか。","terms":[["action.yml（または action.yaml）","アクションのメタデータファイル。name・description・runs などを定義する。Marketplace 公開には必須。"],["Marketplace 公開条件","①パブリックリポジトリ ②リポジトリルートに action.yml ③GitHub アカウントで同意。タグや organization 名の制約はない。"]],"think":"市場（Marketplace）への出店には看板（action.yml）が必須。店名（name）と説明（description）が書いてあれば、建物（リポジトリ）が公開されている限り出店できる。","vs":"タグを付けることはバージョン管理として推奨されるが Marketplace 公開の必須条件ではない。organization 名に制約はない。README は強く推奨されるが必須ではない。","opt":["正解。パブリックリポジトリルートの action.yml が最低条件。","organization 名の制約はない。","タグは推奨だが必須ではない。","推奨されるが必須ではない。"]}'),

  ('gh200-q64', 'Author and Maintain Actions',
   'サードパーティアクションを利用するとき、セキュリティ上最も推奨される参照方法はどれか。',
   NULL,
   '["フルコミット SHA で固定する（例: uses: actions/checkout@a81bbbf8...）","メジャーバージョンタグで参照する（例: uses: actions/checkout@v4）","main ブランチで参照する（例: uses: actions/checkout@main）","バージョンを省略する（例: uses: actions/checkout）"]', 0, '[0]', 'single',
   '{"asked":"アクションのバージョン参照方法のセキュリティリスクを理解し、最も安全な方法を選べるか。","terms":[["コミット SHA 固定","特定コミットの不変ハッシュでアクションを固定。タグは上書き可能だが SHA は変更できないため、悪意あるコードの混入を防げる。"],["タグ参照（v4 など）","メジャーバージョンタグは mutable（上書き可能）。タグが書き換えられると意図しないコードが実行されるリスクがある。"]],"think":"引用文献を参照するとき、書籍名（タグ）だけ書くと改訂されると内容が変わる。ISBN（コミット SHA）で固定すれば同じ内容が保証される。","vs":"main ブランチ参照は最もリスクが高い（いつでも内容が変わる）。タグ参照はバランスが取れているが SHA より安全性は低い。セキュリティが最優先ならば SHA 固定一択。","opt":["正解。SHA は不変で最も安全。","タグは上書き可能でセキュリティリスクがある。","main は常に変化するため最もリスクが高い。","バージョン省略は latest 相当で最新の変更が勝手に入る。"]}'),

  ('gh200-q65', 'Author and Maintain Actions',
   'アクションの inputs に値が渡されなかった場合に自動で使われるデフォルト値を設定するキーはどれか。',
   'inputs:\n  environment:\n    description: Target environment\n    required: false\n    _____: staging',
   '["default","fallback","initial","placeholder"]', 0, '[0]', 'single',
   '{"asked":"action.yml の inputs でデフォルト値を設定するキーを知っているか。","terms":[["default","入力が省略されたときに自動で使われる値。required: false と組み合わせて使う。"],["required","この入力が必須かどうか。true の場合、値が渡されないとアクションはエラーになる。"]],"think":"フォームの『未入力の場合はこの値を使う』欄が default。省略可能（required: false）な入力に default を設定しておくと、呼び出し側が何も渡さなくてもアクションが動く。","vs":"fallback・initial・placeholder は存在しないキー。required: true と default を同時に設定すると default は使われない（required なのに値が無い場合はエラーのため）。","opt":["正解。省略時のデフォルト値を設定するキー。","fallback は存在しないキー。","initial は存在しないキー。","placeholder は HTML フォームの概念で action.yml のキーではない。"]}'),

  ('gh200-q66', 'Author and Maintain Actions',
   'JavaScript action でメインのロジック終了後に必ずクリーンアップ処理を実行したい。action.yml の正しい設定はどれか。',
   NULL,
   '["runs.post に後処理スクリプトのパスを指定する","runs にクリーンアップ関数を配列で追加する","ワークフロー側で別ステップを追加する","process.on(''exit'') で登録する"]', 0, '[0]', 'single',
   '{"asked":"JavaScript action の post 実行フックを知っているか。","terms":[["runs.post","ジョブ完了後にクリーンアップスクリプトを実行する後処理フック。runs.pre（前処理）と対になっている。"],["runs.post-if","post の実行条件を指定できる（例: always() で常に実行）。"]],"think":"工事業者が作業後に現場を片付ける（post）義務があるのと同じ。メイン作業（main）とは独立したクリーンアップが保証される。","vs":"process.on(''exit'') は Node.js の仕組みで動くかもしれないが GitHub Actions の正式な後処理フックではなく、ランナーの終了タイミングと合わない場合がある。ワークフロー側に別ステップを追加するのは action の利用者に負担をかける。","opt":["正解。runs.post でクリーンアップスクリプトを後処理フックとして登録する。","配列で追加する仕組みは存在しない。","利用者に後処理ステップを手動追加させるのはアクション設計として良くない。","Node.js の exit イベントは GitHub Actions のフックと同期しない場合がある。"]}'),

  ('gh200-q67', 'Author and Maintain Actions',
   'JavaScript action の action.yml で、Node.js 20 ランタイムで main.js を実行するよう指定する正しい設定はどれか。',
   'runs:\n  using: _____\n  main: main.js',
   '["node20","nodejs20","node","js"]', 0, '[0]', 'single',
   '{"asked":"JavaScript action の using フィールドに指定する正しいランタイム文字列を知っているか。","terms":[["using: node20","Node.js 20 で JavaScript を実行する指定。他に node16（非推奨）・node12（廃止）がある。"],["runs.main","エントリポイントの JavaScript ファイルパスを指定する。"]],"think":"実行環境（ランタイム）を宣言するのは OS バージョンを指定するようなもの。node20 が現在の推奨バージョン文字列。","vs":"nodejs20・node・js は正しいランタイム識別子ではない。node16 は現在非推奨になりつつあり、新規アクションは node20 を使うのが推奨。","opt":["正解。Node.js 20 の正しいランタイム識別子。","nodejs20 は無効。","node だけでは無効（バージョンが必要）。","js は無効。"]}'),

  ('gh200-q68', 'Author and Maintain Actions',
   'action.yml で color と icon を設定する目的はどれか。',
   'branding:\n  color: blue\n  icon: check-circle',
   '["GitHub Marketplace でのアクションのアイコンとカラーを設定する","ワークフロー実行ログのアクション名の表示色を変える","README に自動でバッジを生成する","CI ステータスチェックのアイコンを変更する"]', 0, '[0]', 'single',
   '{"asked":"action.yml の branding セクションの目的を知っているか。","terms":[["branding","GitHub Marketplace のアクション一覧ページで表示されるアイコン（Feather Icons）と背景色を設定するセクション。Marketplace に公開しない場合は機能しない。"]],"think":"店の看板デザイン（branding）はショッピングモール（Marketplace）に出店したときに客に見えるもの。店内（ワークフロー実行）には関係ない。","vs":"実行ログの表示色やステータスチェックのアイコンは branding で変えられない。README のバッジ自動生成機能もない。","opt":["正解。Marketplace のアイコンと背景色の設定。","ログの表示色は branding では変えられない。","バッジの自動生成機能はない。","ステータスチェックのアイコンは変えられない。"]}'),

  -- ============================================================
  -- D4: Manage GitHub Actions for the Enterprise (q69–q77)
  -- ============================================================

  ('gh200-q69', 'Manage GitHub Actions for the Enterprise',
   'セルフホストランナーに「gpu」と「high-memory」の2つのカスタムラベルを付けて、特定ジョブでだけ使いたい。ジョブ側の正しい設定はどれか。',
   'jobs:\n  ml-train:\n    runs-on: _____',
   '["[self-hosted, gpu, high-memory]","self-hosted-gpu-high-memory","gpu AND high-memory","[gpu, high-memory]"]', 0, '[0]', 'single',
   '{"asked":"セルフホストランナーのカスタムラベルを runs-on で指定する構文を知っているか。","terms":[["runs-on（配列）","複数のラベルを AND 条件でランナーを選択する。指定したラベルを全て持つランナーが選ばれる。"],["self-hosted","セルフホストランナーの識別に使う組み込みラベル。カスタムラベルと組み合わせる。"]],"think":"タクシー配車で『SUV かつ ペット可』の車を探すのと同じ。複数の条件（ラベル）を配列で AND 指定すると、全条件を満たすランナーが選ばれる。","vs":"文字列をハイフンでつないでも配列にはならない。runs-on: [gpu, high-memory] だと self-hosted ラベルのないランナーが選ばれる可能性があるため self-hosted も配列に含めるのが通例。","opt":["正解。self-hosted と全カスタムラベルを配列で AND 指定する。","ハイフン結合の文字列は正しい構文ではない。","AND という演算子は uses-on に使わない。","self-hosted ラベルを省略するとホストされたランナーが選ばれる可能性がある。"]}'),

  ('gh200-q70', 'Manage GitHub Actions for the Enterprise',
   '組織のセルフホストランナーを特定のリポジトリだけに使わせたい。どの機能を使うか。',
   NULL,
   '["ランナーグループを作成し、アクセス対象リポジトリを制限する","ランナーに runs-on ラベルでリポジトリ名を付ける","ブランチ保護ルールでランナーを制限する","ランナーを各リポジトリに個別に登録する"]', 0, '[0]', 'single',
   '{"asked":"ランナーグループによるアクセス制御の仕組みを知っているか。","terms":[["ランナーグループ","組織またはエンタープライズレベルでランナーをグループ化し、どのリポジトリ（または全リポジトリ）がアクセスできるかを制御する機能。"],["デフォルトグループ","全てのリポジトリからアクセス可能な Default runner group に初期登録される。"]],"think":"社内の特別な印刷機（高性能ランナー）を特定の部署だけに使わせるには、鍵付きの部屋（ランナーグループ）に入れてアクセス権を絞る。ラベルは『どのランナーを使うか』の識別子であり、アクセス制御ではない。","vs":"ラベルはランナー選択の仕組みであり、アクセス制限ではない。ブランチ保護はコードのマージ条件設定でランナー制御ではない。個別登録では組織全体の管理が煩雑になる。","opt":["正解。ランナーグループでリポジトリのアクセスを制限する。","ラベルはランナーの選択に使い、アクセス制御機能はない。","ブランチ保護はコードのマージ条件でランナー制御ではない。","スケールしない方法。グループ管理の方が効率的。"]}'),

  ('gh200-q71', 'Manage GitHub Actions for the Enterprise',
   '組織内で GitHub が提供するアクションとマーケットプレイスの一部アクションのみ許可し、それ以外のサードパーティアクションを禁止したい。どこで設定するか。',
   NULL,
   '["組織の Settings → Actions → General → Actions permissions","リポジトリの Settings → Actions → Allowed actions","CODEOWNERS でアクションのパスを管理","ランナーグループのポリシー"]', 0, '[0]', 'single',
   '{"asked":"組織レベルで許可するアクションの範囲を制御する設定場所を知っているか。","terms":[["Actions permissions（組織レベル）","①全アクション許可 ②GitHub アクションのみ ③選択したアクション・再利用可能ワークフローのみ の3段階でポリシーを設定できる。","組織の Settings → Actions → General で設定。"]],"think":"会社の購買規定（Actions permissions）で『社内製品（GitHub アクション）と承認済みベンダー（許可リスト）のみ購入可』と決めるイメージ。各プロジェクト（リポジトリ）に個別に設定させると統制がとれない。","vs":"リポジトリレベルの設定は組織ポリシーの範囲内でのみ変更可能（組織が『選択したアクションのみ』に制限していれば、リポジトリで全許可にはできない）。CODEOWNERS はコード変更の承認者設定。","opt":["正解。組織レベルで許可するアクションのスコープを一元管理できる。","リポジトリレベルは組織ポリシーの範囲内に限定される。","CODEOWNERS はアクション利用の制御ではない。","ランナーグループはランナーへのアクセス制御であり、アクションの許可管理ではない。"]}'),

  ('gh200-q72', 'Manage GitHub Actions for the Enterprise',
   'エンタープライズで、全組織のワークフローが使えるセルフホストランナーを一元管理したい。どこに登録すればよいか。',
   NULL,
   '["エンタープライズレベルのランナーとして登録する","各組織に個別にランナーを登録する","デフォルトランナーグループに追加する","リポジトリレベルのランナーとして登録する"]', 0, '[0]', 'single',
   '{"asked":"エンタープライズレベルのランナー登録と組織・リポジトリレベルの違いを理解しているか。","terms":[["エンタープライズランナー","Enterprise Settings → Actions → Runners で登録。全組織（または指定組織）から利用できる。一元管理に最適。"],["組織ランナー","その組織のリポジトリだけが使える。複数組織への共有には不向き。"],["リポジトリランナー","そのリポジトリだけが使える。最もスコープが狭い。"]],"think":"本社（Enterprise）に会議室を作れば全部署（全組織）が使える。各部署に個別に作ると管理がバラバラになる。","vs":"デフォルトランナーグループはランナーのグルーピングの話であり、登録先（どのレベルか）とは別の概念。","opt":["正解。エンタープライズ登録で全組織からアクセスできる。","スケールしない。","グルーピングの話であり登録先レベルとは別。","スコープが最も狭い。"]}'),

  ('gh200-q73', 'Manage GitHub Actions for the Enterprise',
   'セルフホストランナーマシンをメンテナンスのためオフラインにしたい。そのランナーで実行中のジョブはどうなるか。',
   NULL,
   '["ランナーサービスを停止するとジョブは失敗し、他のランナーへの自動再割り当ては行われない","ランナーサービスを停止するとジョブは自動的に別のランナーに移行する","ランナーサービスを停止するとジョブは完了まで待機する","ランナーサービスを停止するとジョブはキャンセルされ再キューに入る"]', 0, '[0]', 'single',
   '{"asked":"セルフホストランナーを停止したときの実行中ジョブへの影響を知っているか。","terms":[["ランナーサービス停止時の挙動","実行中のジョブはそのタイムアウト設定まで応答を待ち、タイムアウトすると失敗する。他のランナーへの自動移行はない（ステートフルな中断は不可）。"]],"think":"配達中のトラック（ランナー）が止まっても荷物（ジョブ）は自動で別のトラックに積み替えられない。荷物はそこで止まってしまう。メンテナンス前にはジョブが完了するのを待つか、キャンセルするのが安全。","vs":"GitHub ホストのランナーと異なり、セルフホストのランナーは障害時に自動再割り当てされない。ドレイン機能（新しいジョブの受け付けを止める）を使って安全にメンテナンスするのが推奨。","opt":["正解。自動再割り当てはなく、タイムアウトまで待って失敗する。","自動移行の仕組みはない。","永遠に待つわけではなく、タイムアウトで失敗する。","自動キャンセル＆再キューの仕組みはない。"]}'),

  ('gh200-q74', 'Manage GitHub Actions for the Enterprise',
   'AWS にデプロイするワークフローで、長期間有効な AWS シークレットキーをリポジトリシークレットに保存せず認証したい。推奨される方法はどれか。',
   NULL,
   '["OIDC を使って GitHub Actions が AWS に一時クレデンシャルを取得する","AWS シークレットキーを組織シークレットに格納して各リポジトリに共有","GitHub Environments の環境シークレットに AWS キーを保管","ランナー上の ~/.aws/credentials ファイルに書き込む"]', 0, '[0]', 'single',
   '{"asked":"OIDC（OpenID Connect）を使ったクラウド認証の利点とユースケースを理解しているか。","terms":[["OIDC（OpenID Connect）","GitHub Actions が ID トークン（JWT）を発行し、AWS/GCP/Azure がそのトークンを信頼して一時クレデンシャルを払い出す仕組み。長期間有効なシークレットキーが不要になる。"],["一時クレデンシャル","使用後（またはセッション終了後）に自動で失効する認証情報。漏洩しても長期的な被害を防げる。"]],"think":"毎回使い捨ての来客バッジ（一時クレデンシャル）を受付（AWS STS）で発行してもらうイメージ。永久パス（長期シークレット）を作って渡さなくていい。OIDC がその申請書の役割。","vs":"組織シークレットや環境シークレットに長期キーを保存しても、キーが漏洩したリスクは変わらない。~/.aws/credentials へのハードコードは最も危険。","opt":["正解。OIDC で長期シークレット不要の安全な認証。","長期キー保存のリスクは変わらない。","長期キー保存のリスクは変わらない。","ハードコードは最も危険な方法。"]}'),

  ('gh200-q75', 'Manage GitHub Actions for the Enterprise',
   'エンタープライズでセルフホストランナーを需要に応じて自動スケールさせたい。Kubernetes クラスタを使う場合の推奨ツールはどれか。',
   NULL,
   '["Actions Runner Controller（ARC）","GitHub Actions Runner Scale Sets","Kubernetes HPA のみ","GitHub の Hosted Larger Runners"]', 0, '[0]', 'single',
   '{"asked":"Kubernetes 上でセルフホストランナーを自動スケールする公式推奨ツールを知っているか。","terms":[["Actions Runner Controller（ARC）","Kubernetes Operator として動作し、ワークフローのキュー状況に応じてセルフホストランナー Pod を自動的にスケールアウト/インする。GitHub が公式サポート。"],["Scale Sets","ARC 2.x 以降の推奨デプロイモード。より安定した自動スケーリングを提供。"]],"think":"需要に応じてレジ（ランナー）を自動で開閉するスーパーマーケットのシステム。ARC が混雑度（ジョブキュー）を監視してレジ（Pod）を増減する。","vs":"Kubernetes HPA だけではジョブキューの深さに基づくスケーリングはできない（CPU/メモリ基準のスケーリング）。GitHub Hosted Larger Runners は GitHub 管理のランナーでセルフホストではない。","opt":["正解。Kubernetes 上のランナー自動スケールの公式ツール。","ARC の一機能であり単体ツールではない。","HPA だけではジョブキュー基準のスケーリングができない。","これはGitHubが管理するランナーでセルフホストではない。"]}'),

  ('gh200-q76', 'Manage GitHub Actions for the Enterprise',
   'GitHub の IP 許可リスト（IP allow list）を有効にしている組織でセルフホストランナーを使うとき、追加で必要な設定はどれか。',
   NULL,
   '["セルフホストランナーの送信元 IP を許可リストに追加する","ランナーの受信ポート 443 を開放する","GitHub の IP 範囲を許可リストに追加する","何も追加不要（セルフホストは自動で許可される）"]', 0, '[0]', 'single',
   '{"asked":"IP 許可リストとセルフホストランナーの組み合わせで必要な設定を知っているか。","terms":[["IP 許可リスト","Organization Settings で有効にすると、指定した IP からのみ GitHub.com へのアクセスを許可する。"],["セルフホストランナーと IP 許可リスト","ランナーは GitHub API を呼び出して通信する。ランナーのマシン IP を許可リストに追加しないとジョブが実行できない。"]],"think":"会社の来客リスト（IP 許可リスト）に自社の宅配便（ランナー）の社員証番号を載せないと、受付（GitHub）に弾かれてしまう。","vs":"ランナーは GitHub に対して発信するが、IP 許可リストはどの IP から GitHub にアクセスするかを制限する。ランナーの受信ポートを開放しても IP 許可リストには影響しない。","opt":["正解。ランナーの送信元 IP を許可リストに追加する必要がある。","ランナーの受信ポートとは別の話。","GitHub の IP 範囲を許可するのは逆方向（GitHub がランナーにアクセスする場合）。","自動許可はされない。明示的に追加が必要。"]}'),

  ('gh200-q77', 'Manage GitHub Actions for the Enterprise',
   'エンタープライズ管理者が、全組織の全リポジトリで特定のセキュリティスキャンワークフローを必ず実行させたい。どの機能を使うか。',
   NULL,
   '["エンタープライズの Required workflows（必須ワークフロー）","ブランチ保護ルールの Require status checks","各リポジトリの CODEOWNERS で強制","エンタープライズの Actions permissions で強制"]', 0, '[0]', 'single',
   '{"asked":"エンタープライズ全体で特定ワークフローを必須にする機能を知っているか。","terms":[["Required workflows（必須ワークフロー）","エンタープライズまたは組織レベルで、指定したリポジトリのワークフローを全リポジトリの PR に対して必須で実行させる機能。セキュリティスキャンやコンプライアンスチェックの強制に使う。"]],"think":"マンションの管理規約（Required workflows）で全住戸が消防点検（セキュリティスキャン）を受けなければならないと定めるイメージ。各住戸（リポジトリ）が自分でルールを設定する必要がない。","vs":"ブランチ保護ルールはリポジトリごとの設定。CODEOWNERS はファイル変更の承認者設定。Actions permissions はどのアクションを使えるかの制御でワークフロー実行の強制ではない。","opt":["正解。エンタープライズ全体に必須ワークフローを課せる機能。","ブランチ保護はリポジトリ個別の設定で全体への強制はできない。","CODEOWNERS はコードオーナーの設定でワークフロー強制ではない。","Actions permissions はアクション利用の制御であり、ワークフロー強制ではない。"]}'),

  -- ============================================================
  -- D5: Secure and Optimize Automation (q78–q85)
  -- ============================================================

  ('gh200-q78', 'Secure and Optimize Automation',
   'ワークフローで GITHUB_TOKEN に書き込み権限が一切不要なとき、最もセキュリティが高い設定はどれか。',
   'permissions: _____',
   '["read-all","write-all","{}","none"]', 0, '[0]', 'single',
   '{"asked":"GITHUB_TOKEN を全スコープ読み取り専用にする permissions の正しいショートハンドを知っているか。","terms":[["permissions: read-all","全スコープを read に設定する省略形。ワークフロー全体に適用する。"],["permissions: write-all","全スコープを write に設定。デフォルト設定と近い。不要な書き込み権限を与えてしまう。"],["permissions: {}","全スコープを none にする（完全禁止）。contents の read もできなくなる（clone 不可）。"]],"think":"マスターキー（全権限）を渡すのではなく、『全部屋の覗き窓（read-all）』だけ渡すイメージ。何も書き込まないワークフローには read-all が適切。","vs":"{}（空オブジェクト）は全部 none になり、checkout もできなくなる点に注意。none は単一スコープの禁止に使う。read-all と write-all の使い分けは書き込みが必要かどうかで判断。","opt":["正解。全スコープ読み取り専用の省略形。","全書き込み権限を与えてしまう。","全スコープを none にして checkout も不可になる。","none は単一スコープのキーとして使うもの。permissions: none という書き方は無効。"]}'),

  ('gh200-q79', 'Secure and Optimize Automation',
   'CI ワークフローで untrusted input（ユーザー提供のデータ）をシェルコマンドに使う場合、スクリプトインジェクションを防ぐ最善の方法はどれか。',
   NULL,
   '["入力値を環境変数に代入してからシェルコマンドで参照する","${{ github.event.issue.title }} を直接 run: の中に書く","入力値を secrets に保存してから使う","入力値を base64 エンコードしてから使う"]', 0, '[0]', 'single',
   '{"asked":"スクリプトインジェクション攻撃を防ぐための安全な入力値の扱い方を知っているか。","terms":[["スクリプトインジェクション","${{ }} 式を run: に直接埋め込むと、悪意あるコンテンツ（例: issue タイトルにシェルコマンド）がランナー上で実行される脆弱性。"],["環境変数経由での参照","env: セクションで TITLE: ${{ github.event.issue.title }} と代入し、run: 内で $TITLE として参照。環境変数はシェルがコマンドとして解釈しないため安全。"]],"think":"料理の食材（ユーザー入力）を直接火（シェル）に投げ込まず、容器（環境変数）に入れてから渡す。容器があればどんな食材を入れても爆発しない。","vs":"直接 ${{ }} を run: に書くのは最もリスクが高い。base64 エンコードは一定の保護にはなるが根本的解決ではなく、デコード後の処理で脆弱性が再発する。","opt":["正解。環境変数を介することでインジェクションを防げる。","直接埋め込みは最大のリスク。","secrets に保存するのは機密値の管理で、インジェクション対策ではない。","根本的解決ではなく、デコード後に再び脆弱性が生じる。"]}'),

  ('gh200-q80', 'Secure and Optimize Automation',
   'pull_request_target トリガーで fork からの PR のコードを直接チェックアウトして実行するリスクは何か。',
   NULL,
   '["悪意ある fork のコードがシークレットにアクセスできる","チェックアウトに失敗する","ランナーのディスク容量が不足する","fork のコードが自動で main にマージされる"]', 0, '[0]', 'single',
   '{"asked":"pull_request_target の危険性とシークレット漏洩リスクを理解しているか。","terms":[["pull_request_target","ベースリポジトリのコンテキストで実行されるため、シークレットにアクセスできる。fork の HEAD コードを直接チェックアウトすると、その悪意あるコードがシークレットを読み取れる。"],["pull_request（通常）","fork PR では制限されたトークンのみ使用、シークレット無し。安全。"]],"think":"ゲストを自社の金庫がある部屋（pull_request_target＝シークレットあり）に招待した上で、ゲスト自身のコード（fork のコード）を動かす。金庫の中身を自由に見られてしまう。","vs":"pull_request（通常）はゲストを隔離した来客室（シークレットなし）で対応するので安全。pull_request_target は外部 CI サービスと連携する特殊な場合にのみ慎重に使う。","opt":["正解。シークレット漏洩が最大のリスク。","技術的にチェックアウトは成功する（危険なのはその後の実行）。","ディスク容量はこのトリガー固有の問題ではない。","自動マージはされない。"]}'),

  ('gh200-q81', 'Secure and Optimize Automation',
   'リポジトリで使用しているサードパーティアクションのバージョンを自動で最新に保ちたい。最も適切な方法はどれか。',
   NULL,
   '["Dependabot の package-ecosystem: github-actions を設定する","Renovate Bot をセルフホストして設定する","weekly で actions/checkout などを自動更新するワークフローを書く","手動でリリースノートを監視してバージョンを更新する"]', 0, '[0]', 'single',
   '{"asked":"GitHub Actions のバージョンを自動更新する公式の仕組みを知っているか。","terms":[["Dependabot（github-actions）",".github/dependabot.yml に package-ecosystem: github-actions を設定すると、.github/workflows/*.yml 内の uses: のバージョンを自動でアップデートする PR を作成してくれる。"]],"think":"アプリの依存ライブラリ（npm）を自動更新するのと同じ感覚で、GitHub Actions も Dependabot が管理できる。人手でリリースノートを追う必要がなくなる。","vs":"Renovate Bot も同様の機能があるが GitHub 公式ではなく自己管理が必要。カスタムワークフローは実装コストが高い。手動監視は見落としリスクがある。","opt":["正解。Dependabot が github-actions の uses バージョンを自動更新する。","機能は同等だが GitHub 公式ではなく自己管理が必要。","自前実装は不要（Dependabot が無料で提供）。","手動では見落としやタイムラグが生じる。"]}'),

  ('gh200-q82', 'Secure and Optimize Automation',
   '.github/workflows/ ディレクトリの変更には、セキュリティチームのレビューを必須にしたい。最も適切な方法はどれか。',
   NULL,
   '["CODEOWNERS で .github/workflows/ をセキュリティチームに割り当て、ブランチ保護で CODEOWNERS レビューを必須にする","CODEOWNERS で .github/workflows/*.yml を required: true にする","ブランチ保護ルールの Require approvals を 2 に設定する","ワークフロー変更は別ブランチで管理するポリシーを設ける"]', 0, '[0]', 'single',
   '{"asked":"CODEOWNERS とブランチ保護を組み合わせてワークフロー変更を保護する方法を知っているか。","terms":[["CODEOWNERS","特定のパスを変更する PR に特定のユーザー・チームのレビューを要求するファイル。.github/CODEOWNERS に記述する。"],["Require review from Code Owners","ブランチ保護ルールで有効にすると、CODEOWNERS で指定されたオーナーのレビュー承認が必須になる。"]],"think":"会社の重要書類（ワークフロー）を変更するには法務部（セキュリティチーム）の印鑑（CODEOWNERS レビュー）が必要、という社内規定を自動化したもの。","vs":"CODEOWNERS に required: true キーは存在しない（CODEOWNERS はシンプルなパターン→チームのマッピングファイル）。Require approvals だけでは誰でもレビューできてしまう（セキュリティチーム限定にならない）。","opt":["正解。CODEOWNERS でオーナー設定 + ブランチ保護で必須化の2段構え。","required: true キーは CODEOWNERS に存在しない。","誰でもレビューできてしまい、チーム限定にならない。","ポリシーだけでは技術的な強制力がない。"]}'),

  ('gh200-q83', 'Secure and Optimize Automation',
   'GITHUB_TOKEN を使ってワークフローが PR にコメントを追加したい。最小権限に設定する場合、必要な権限はどれか。',
   'permissions:\n  pull-requests: _____',
   '["write","read","none","read-write"]', 0, '[0]', 'single',
   '{"asked":"PR へのコメント投稿に必要な GITHUB_TOKEN のスコープと権限レベルを知っているか。","terms":[["pull-requests: write","Pull Request のコメント・ラベル・マージなどの書き込み操作が可能。コメント追加には write が必要。"],["pull-requests: read","PR の内容を読むのみ。コメント追加は不可。"]],"think":"掲示板（PR）に書き込む（コメント）には書き込み権限（write）が必要。読むだけなら read で十分だが、投稿するなら write が要る。","vs":"read-write は GitHub Actions の権限値として存在しない（read・write・none の3択）。none はアクセス完全禁止。","opt":["正解。PR へのコメント追加には write が必要。","read は閲覧のみで、コメント追加不可。","none は完全禁止。","read-write という値は存在しない。"]}'),

  ('gh200-q84', 'Secure and Optimize Automation',
   'production 環境へのデプロイを自動化する際、特定のメンバーによる手動承認を必須にしたい。正しい設定場所はどれか。',
   NULL,
   '["リポジトリの Settings → Environments → production → Required reviewers","ジョブの if 条件でメンバーを指定する","ブランチ保護ルールの Require review を使う","ワークフローに approval ジョブを追加する"]', 0, '[0]', 'single',
   '{"asked":"デプロイ前の手動承認ゲートを設ける Environments 機能を知っているか。","terms":[["Environments（環境）","デプロイ先（staging・production など）を表す概念。Required reviewers・wait timer・シークレットをまとめて設定できる。"],["Required reviewers","Environment を使うジョブが実行される前に、指定したユーザー・チームの承認が必要になる。承認するまでジョブはキューで待機する。"]],"think":"工場の出荷ゲート（Environment）で品質管理担当（Required reviewers）が OKを出さないとトラックが出発できない（デプロイできない）仕組み。","vs":"if 条件でメンバーを指定してもリアルタイムの承認待ち機能はない。ブランチ保護はコードのマージ条件。approval ジョブを自作するのは複雑で、公式の Environment 機能を使う方が確実。","opt":["正解。Environments の Required reviewers で承認ゲートを設置できる。","if 条件は静的な条件分岐で、インタラクティブな承認待ちはできない。","ブランチ保護はコードマージ条件でデプロイ承認ではない。","Environment 機能を使わない自作実装は不要に複雑。"]}'),

  ('gh200-q85', 'Secure and Optimize Automation',
   'シークレット「DB_PASSWORD」をリポジトリ・組織・環境の3階層に同名で設定した場合、production 環境のジョブで参照される値はどれか。',
   NULL,
   '["環境シークレットの値（最も優先度が高い）","組織シークレットの値","リポジトリシークレットの値","3つの値を結合したもの"]', 0, '[0]', 'single',
   '{"asked":"シークレットの優先順位（スコープ階層）を理解しているか。","terms":[["シークレットの優先順位","環境シークレット > リポジトリシークレット > 組織シークレットの順で優先される。同名の場合は最もスコープが狭い（詳細な）設定が勝つ。"]],"think":"ロシアのマトリョーシカ人形。一番内側（環境）が一番内側にある最終的な値として使われる。外側（組織）から内側（環境）に向かって上書きされるイメージ。","vs":"結合は行われない。複数の同名シークレットが存在する場合は最も優先度の高い1つだけが参照される。組織シークレットは最も優先度が低く、環境専用のシークレットで上書きできるのはセキュリティ分離の設計意図。","opt":["正解。環境シークレットが最も優先度が高い。","組織シークレットは最も優先度が低い。","リポジトリシークレットより環境シークレットが優先。","結合は行われない。"]}')

) AS v(source_ref, category_name, question_text, code, options, correct_index, correct_indices, question_type, explanation_data)
ON c.name = v.category_name AND s.slug = 'gh-200'
ON CONFLICT (subject_id, source_ref) DO NOTHING;
