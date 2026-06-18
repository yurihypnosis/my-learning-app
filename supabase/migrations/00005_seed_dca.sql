-- =============================================================
-- 00005_seed_dca.sql
-- DCA Docker Certified Associate — 6ドメイン / 31問
-- =============================================================

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('dca', 'DCA Docker Certified Associate', 'Docker の本番運用に必要な知識を問う認定試験（オーケストレーション・イメージ・ネットワーク・セキュリティ・ストレージほか）', '#2496ed', 2)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('Orchestration',                              '#58a6ff', 0),
  ('Image Creation, Management, and Registry',   '#3fb950', 1),
  ('Installation and Configuration',             '#d2a8ff', 2),
  ('Networking',                                 '#e3a008', 3),
  ('Security',                                   '#f778ba', 4),
  ('Storage and Volumes',                        '#a5d6ff', 5)
) AS v(name, color, sort_order)
WHERE s.slug = 'dca'
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

  -- Domain 1: Orchestration (6問)
  ('dca-q1', 'Orchestration',
   'Docker Swarm で 3 ノードのクラスターを構成し、マネージャーを 1 台に限定した場合、マネージャーが停止すると何が起きるか。',
   NULL,
   '["クラスター全体が停止し、Swarm の管理操作は一切受け付けられなくなる","ワーカーノードが自動的にマネージャーに昇格してクラスターを維持する","既存サービスはそのまま稼働し続けるが、新規タスクのスケジューリングはできなくなる","クラスターが自動で解散し、コンテナがすべて削除される"]', 2, '[2]', 'single',
   '{"asked":"Swarm でマネージャーが停止したとき、既存タスクとスケジューリング機能のそれぞれにどう影響するかを区別して理解しているか。","terms":[["マネージャーノード","Swarm の状態管理・スケジューリングを担う制御プレーン。"],["Raft コンセンサス","マネージャー群での状態合意プロトコル。マネージャーが過半数生存していれば機能する。"],["ワーカーノード","タスク（コンテナ）を実行するだけのノード。管理操作の権限は持たない。"]],"think":"工場の管理棟（マネージャー）が閉まっても、ライン（ワーカー）の作業員は今日の仕事を続けられる。でも『次の指示』は出せない。既存タスクはそのまま動き続けるが、新しい割り当てや再スケジューリングは止まる。","vs":"選択肢 A のように『すべて停止』はしない。選択肢 B の自動昇格は手動で docker node promote しない限り起きない（Swarm は自動で昇格しない）。選択肢 D の全削除もない。","opt":["クラスター全停止はしない。既存コンテナは動き続ける。","ワーカーの自動マネージャー昇格は起きない。手動操作が必要。","正解。既存タスクは継続、スケジューリング新規不可。","全削除はしない。"]}'),

  ('dca-q2', 'Orchestration',
   'Swarm サービスを更新する際、ダウンタイムをゼロにするためのローリングアップデート設定として正しいものはどれか。',
   'docker service update\n  --update-parallelism 2\n  --update-delay 10s\n  myservice',
   '["2レプリカずつ、10秒間隔でローリング更新される","全レプリカを同時に更新した後、10秒待って完了とする","2レプリカを停止し、10秒後に新バージョンで起動する","update-parallelism はレプリカ数を変更するオプションである"]', 0, '[0]', 'single',
   '{"asked":"--update-parallelism と --update-delay の意味を組み合わせて正確に読み取れるか。","terms":[["--update-parallelism","一度に更新するレプリカの数（並列度）。",""],["--update-delay","各バッチ更新の間に挟む待機時間。ヘルスチェックの猶予期間として機能する。"]],"think":"引越し業者が荷物を2個ずつ運び、10分ごとに休憩を挟みながら進める感覚。一度に全部運ばないので、途中でも旧荷物（旧バージョン）がある程度残り、サービスが止まらない。","vs":"parallelism は同時更新数（=バッチサイズ）であってレプリカ総数の変更ではない。delay は全部終わった後の待機ではなく、各バッチ間の待機。","opt":["正解。parallelism=2 で2つずつ、delay=10s で間隔。","全レプリカ同時更新は parallelism に全数を指定した場合。","2レプリカを停止してから待つのではなく、更新して待つ。","update-parallelism はレプリカ数変更ではなく並列更新数。"]}'),

  ('dca-q3', 'Orchestration',
   'Swarm サービスで、特定ノードにのみタスクをデプロイする制約を設定したい。正しいコマンドはどれか。',
   NULL,
   '["docker service create --constraint node.labels.env==production myimage","docker service create --node-selector env=production myimage","docker service create --placement-constraint env=production myimage","docker service create --filter label=env=production myimage"]', 0, '[0]', 'single',
   '{"asked":"Swarm のノード配置制約を指定するフラグ名と書式を正確に知っているか。","terms":[["配置制約 (placement constraint)","サービスのタスクをどのノードに配置するか絞り込む条件。ノードラベルやエンジン属性で指定する。"],["node.labels","ノードに手動で付けたラベル。docker node update --label-add で設定する。"]],"think":"採用面接の条件を『node.labels.env==production を持つ部署（ノード）への配属のみ』と指定する感覚。","vs":"--node-selector は Kubernetes の構文、--placement-constraint と --filter label は Docker の正式なフラグではない。フラグ名は --constraint、書式は key==value（イコール2つ）。","opt":["正解。--constraint node.labels.key==value が正しい書式。","--node-selector は Kubernetes の用語。Docker Swarm には無い。","--placement-constraint というフラグは存在しない。","--filter label は docker ps 等のフィルタ用で、service create とは別。"]}'),

  ('dca-q4', 'Orchestration',
   'Swarm の global サービスと replicated サービスの違いとして正しいものはどれか。',
   NULL,
   '["global は全ノードに 1 タスクずつ配置され、replicated は指定数のレプリカを任意配置する","global は自動スケーリングされ、replicated は手動スケーリングのみ","global はマネージャーノードのみで動き、replicated はワーカーのみで動く","global はステートレス専用で、replicated はステートフル専用"]', 0, '[0]', 'single',
   '{"asked":"global モードと replicated モードの配置ロジックの違いを理解しているか。","terms":[["global サービス","Swarm 内の全ノードに自動で 1 タスクずつ配置される。監視エージェント等のサイドカー用途に向く。"],["replicated サービス","指定したレプリカ数（--replicas N）を Swarm が任意のノードに分散配置する。"]],"think":"global は『全クラスに1人ずつ学級委員を置く』制度、replicated は『委員を3人選んで好きなクラスに置く』制度。","vs":"自動スケーリング・ノード種別の制限・ステートの分類は、global と replicated の違いとは無関係。","opt":["正解。global=全ノード1タスク、replicated=指定数任意配置。","自動スケーリングは global の特性ではない。","ノード種別の制限はデプロイモードと直接関係しない。","ステートの扱いはデプロイモードと無関係。"]}'),

  ('dca-q5', 'Orchestration',
   'Docker Stack で複数サービスをデプロイする際、サービス間の起動順序の依存を定義するキーはどれか。',
   'services:\n  db:\n    image: postgres\n  app:\n    image: myapp\n    ________:\n      - db',
   '["depends_on","requires","after","links"]', 0, '[0]', 'single',
   '{"asked":"Compose/Stack ファイルでサービスの起動順序依存を宣言するキーを知っているか。","terms":[["depends_on","依存するサービスが起動してから、このサービスを起動することを宣言するキー。"],["Swarm Stack","docker stack deploy で Compose ファイルをもとに複数サービスをまとめてデプロイする仕組み。"]],"think":"料理の手順と同じ。『ご飯が炊けてから（db）、おかずを並べる（app）』という順を depends_on で宣言する。","vs":"requires と after は Compose の有効キーではない（systemd の用語と混同しやすい）。links は旧来のサービス発見機能で、起動順序制御とは別物。","opt":["正解。depends_on でサービス起動依存を定義する。","requires は Compose の有効キーではない。","after は Compose の有効キーではない（systemd の用語）。","links は旧来の名前解決機能で起動順序制御ではない。"]}'),

  ('dca-q6', 'Orchestration',
   'docker service scale コマンドとして正しいものはどれか。',
   NULL,
   '["docker service scale myservice=5","docker service update --replicas 5 myservice","docker service resize myservice --count 5","docker service set myservice replicas=5"]', 0, '[0]', 'single',
   '{"asked":"Swarm サービスのレプリカ数を変更する正しいコマンド構文を知っているか。","terms":[["docker service scale","service=数値 の形式でレプリカ数を即変更するショートカットコマンド。"],["docker service update --replicas","より細かいオプションと組み合わせながらレプリカ数を変更できる汎用コマンド。"]],"think":"scale は簡潔な専用コマンド（短縮版）、update --replicas は多機能版。どちらも正しいが、scale の構文は service=数値 の形式。","vs":"resize / set は存在しないサブコマンド。update --replicas も正しいが今回は選択肢 A が scale コマンドの正しい構文。","opt":["正解。docker service scale myservice=5 が正しい構文。","update --replicas も正しいコマンドだが、scale コマンドの構文としては A が正解。","resize は存在しないサブコマンド。","set は存在しないサブコマンド。"]}'),

  -- Domain 2: Image Creation, Management, and Registry (6問)
  ('dca-q7', 'Image Creation, Management, and Registry',
   'マルチステージビルドを使う主な目的はどれか。',
   'FROM golang:1.22 AS builder\nWORKDIR /app\nCOPY . .\nRUN go build -o myapp\n\nFROM alpine:3.19\nCOPY --from=builder /app/myapp /myapp\nCMD [\"/myapp\"]',
   '["最終イメージからビルドツールや中間ファイルを除き、イメージサイズを小さくする","複数の OS プラットフォーム向けイメージを同時にビルドする","ビルド中に発生したレイヤーをキャッシュして再ビルドを高速化する","同じ Dockerfile から複数の異なるイメージを同時に push する"]', 0, '[0]', 'single',
   '{"asked":"マルチステージビルドの本来の目的（最終イメージのスリム化）を理解しているか。","terms":[["マルチステージビルド","Dockerfile 内に複数の FROM ステージを持ち、最終ステージに必要なファイルだけを COPY --from で引き継ぐ手法。"],["COPY --from","別ステージ（または名前付きビルダー）からファイルを引き継ぐ命令。"]],"think":"調理場（builder ステージ）で食材を切って炒めるが、お皿に盛るとき（最終ステージ）には調理器具は付けない。食べる人に必要なのは料理だけ。Go コンパイラは実行には不要なので最終イメージから捨てられる。","vs":"マルチプラットフォームビルドは別機能（docker buildx）。キャッシュ高速化はレイヤー順序の話。複数イメージ push も別話題。","opt":["正解。ビルドツールを除いた軽量な最終イメージを作れる。","マルチプラットフォームは buildx の機能。","キャッシュは Dockerfile のレイヤー設計で制御する別機能。","複数イメージの同時 push はマルチステージビルドの目的ではない。"]}'),

  ('dca-q8', 'Image Creation, Management, and Registry',
   '以下の Dockerfile で、キャッシュを最大限に活用しながらビルドするには、どの命令の順番が最適か。',
   NULL,
   '["COPY requirements.txt → RUN pip install → COPY . . の順にする","COPY . . → COPY requirements.txt → RUN pip install の順にする","全ファイルをまず COPY して、最後に RUN でまとめてインストールする","RUN pip install を Dockerfile の先頭に置く"]', 0, '[0]', 'single',
   '{"asked":"レイヤーキャッシュが無効化されるタイミングを理解し、変化しにくい依存定義ファイルを先にコピーすることでビルドを高速化できると分かるか。","terms":[["レイヤーキャッシュ","直前の命令と同じ入力なら、実行をスキップして過去の結果を再利用する仕組み。"],["キャッシュの無効化","COPY でコピーするファイルが変化した場合、その行以降のすべてのキャッシュが無効になる。"]],"think":"ソースコードは毎回変わるが、requirements.txt（依存リスト）は頻繁には変わらない。先にリストだけコピーしてインストールしておけば、コード変更だけのときはインストール層（重い処理）がキャッシュから再利用される。","vs":"先に全部コピーすると、コード1行の変更でインストール処理まで全部やり直しになる。","opt":["正解。変化しない依存定義を先にコピーし、重い install をキャッシュさせる。","全体コピー後に requires をコピーするのは逆で、キャッシュ効率が悪い。","全ファイルを先にコピーすると依存インストールのキャッシュが効かない。","RUN を先頭には置けない（依存ファイルが存在しない段階でインストールできない）。"]}'),

  ('dca-q9', 'Image Creation, Management, and Registry',
   'プライベートレジストリに push するために必要な手順として正しいものはどれか。',
   NULL,
   '["docker login <registry> でログインし、docker tag でレジストリ名を含む完全なタグを付けてから docker push する","docker push に --registry フラグでレジストリ URL を直接指定する","docker tag のみで、ログインは不要","docker build 時に --push フラグで直接 push できる（tag 不要）"]', 0, '[0]', 'single',
   '{"asked":"プライベートレジストリへの push に必要な3つの手順（ログイン・タグ付け・プッシュ）を知っているか。","terms":[["docker login","レジストリへの認証。認証情報は ~/.docker/config.json に保存される。"],["docker tag","イメージに完全修飾名（registry/repo:tag）を付ける操作。push 先を指定する役割。"]],"think":"荷物を指定の倉庫（レジストリ）に送るには、①倉庫に入れる鍵（login）②正しい住所ラベル（tag）③発送（push）の3ステップ。","vs":"--registry フラグは docker push には存在しない。ログインなしではアクセス拒否される（private）。--push は docker build に存在するが、それだけでは tag の設定は別途必要。","opt":["正解。login → tag（完全修飾名）→ push の順が正しい手順。","docker push に --registry フラグは存在しない。","プライベートレジストリは認証が必要。ログインなしでは拒否される。","--push は buildx では使えるが、tag を省略できるわけではない。"]}'),

  ('dca-q10', 'Image Creation, Management, and Registry',
   'イメージのダイジェスト（sha256:...）を使って特定のバージョンを pull するメリットはどれか。',
   'docker pull myregistry.io/myimage@sha256:abc123...',
   '["タグが上書きされてもイメージの内容が変わらない、不変の参照ができる","sha256 は最新のセキュリティアップデートを自動で取得できる","ダイジェスト指定すると pull が高速になる","ダイジェスト指定は registry への認証が不要になる"]', 0, '[0]', 'single',
   '{"asked":"イメージのダイジェスト参照が、タグ参照とどう違うのか（不変 vs 移動可能）を理解しているか。","terms":[["ダイジェスト (sha256:...)","イメージの内容から計算された一意のハッシュ。内容が変わると値も変わるため、内容を一意に特定できる。"],["タグ","人間が読みやすい可変のラベル（latest など）。レジストリ側で差し替え可能。"]],"think":"本の ISBN（ダイジェスト）と題名（タグ）の違い。ISBN は内容が変わると変わるが、題名は同じまま版を重ねられる。同じタグでも中身が変わることがあるのがタグ参照の落とし穴。","vs":"ダイジェストは『固定』の手段であって、最新取得・高速化・認証省略とは無関係。","opt":["正解。ダイジェスト参照はイメージ内容を不変に固定できる。","ダイジェストは特定の内容を指すので、最新更新とは逆の概念。","ダイジスト指定で速度は変わらない。","認証は引き続き必要。"]}'),

  ('dca-q11', 'Image Creation, Management, and Registry',
   'ENTRYPOINT と CMD を組み合わせた場合の動作として正しいものはどれか。',
   'ENTRYPOINT ["python"]\nCMD ["app.py"]',
   '["python app.py が実行される。docker run 時に引数を渡すと CMD だけが上書きされる","CMD が優先され python は無視される","docker run 時の引数で ENTRYPOINT が上書きされる","CMDが無いと ENTRYPOINT も無視される"]', 0, '[0]', 'single',
   '{"asked":"ENTRYPOINT と CMD の組み合わせルールと、run 時の引数でどちらが上書きされるかを理解しているか。","terms":[["ENTRYPOINT","コンテナが必ず実行するコマンド。--entrypoint フラグなしでは上書きできない。"],["CMD","ENTRYPOINT への既定引数、またはシェルコマンド。docker run の引数で上書きされる。"]],"think":"ENTRYPOINT は『どの道具を使うか』（python）、CMD は『既定の作業ファイル』（app.py）。道具は固定で、引数だけ変えられる。run 時に別ファイルを渡すと CMD 部分だけが置き換わる。","vs":"CMD が優先される（ENTRYPOINT を無視する）のは CMD のみの場合。ENTRYPOINT がある場合、run の引数は CMD を置き換え、ENTRYPOINT は変わらない。","opt":["正解。ENTRYPOINT[0] + CMD[0] で python app.py、run 引数は CMD を上書き。","ENTRYPOINT がある場合、CMD は引数として扱われ python は無視されない。","run 引数は CMD を上書きする。ENTRYPOINT は --entrypoint フラグでのみ上書き可能。","CMD がなくても ENTRYPOINT は実行される（引数なしで実行される）。"]}'),

  ('dca-q12', 'Image Creation, Management, and Registry',
   'ローカルに pull 済みのコンテナイメージの詳細なメタデータ（レイヤー情報・環境変数等）を確認するコマンドはどれか。',
   NULL,
   '["docker image inspect <image>","docker image ls --verbose <image>","docker image show <image>","docker image describe <image>"]', 0, '[0]', 'single',
   '{"asked":"イメージの詳細メタデータを取得する正しいサブコマンドを知っているか。","terms":[["docker image inspect","イメージの詳細情報（レイヤー・環境変数・Entrypoint・ポート等）を JSON 形式で出力するコマンド。"]],"think":"コンテナの『仕様書を見る』ときは inspect。ls は一覧表示、show・describe は Docker には存在しないサブコマンド。","vs":"--verbose は docker image ls の有効なフラグではない。show と describe は Docker のサブコマンドとして存在しない。","opt":["正解。docker image inspect がメタデータ取得の正しいコマンド。","--verbose は docker image ls の有効フラグではない。","show は docker image のサブコマンドとして存在しない。","describe は docker image のサブコマンドとして存在しない。"]}'),

  -- Domain 3: Installation and Configuration (5問)
  ('dca-q13', 'Installation and Configuration',
   'Docker Engine のストレージドライバーとして、現在の Linux カーネルで最も推奨されるものはどれか。',
   NULL,
   '["overlay2","aufs","devicemapper","vfs"]', 0, '[0]', 'single',
   '{"asked":"現代の Linux 環境で Docker が推奨するストレージドライバーを知っているか。","terms":[["overlay2","Linux カーネル 4.x 以降で推奨されるストレージドライバー。OverlayFS を使い、パフォーマンスと安定性に優れる。"],["aufs","旧来のドライバー。現代のカーネルでは標準組み込みでなく、非推奨。"],["devicemapper","RHEL 系で使われていた旧来のブロックストレージ方式。ダイレクトモードで運用困難。"]],"think":"新しい家（モダンカーネル）には最新設備（overlay2）が最適。aufs は古いアパートの設備で、新居には合わない。","vs":"vfs はキャッシュなしで毎回フルコピーするため、パフォーマンスが劣悪（テスト用途のみ）。aufs は非推奨、devicemapper は推奨されなくなった。","opt":["正解。overlay2 がモダン Linux の推奨ドライバー。","aufs は非推奨。カーネル標準組み込みではない。","devicemapper は非推奨。直接設定が困難。","vfs はパフォーマンスが最悪。テスト用途のみ。"]}'),

  ('dca-q14', 'Installation and Configuration',
   'daemon.json を使って Docker デーモンの設定を変更する場合の正しいパスと説明はどれか。',
   NULL,
   '["/etc/docker/daemon.json — デーモン全体のオプションを JSON で指定する設定ファイル","~/.docker/daemon.json — ユーザーごとのデーモン設定","~/daemon.json — docker run 時に自動で読み込まれる","/usr/bin/docker/daemon.json — バイナリと同じ場所に置く"]', 0, '[0]', 'single',
   '{"asked":"Docker デーモンの設定ファイルの正しいパスを知っているか。","terms":[["daemon.json","/etc/docker/daemon.json に置く、Docker デーモン全体の設定ファイル。デーモン再起動で反映される。"]],"think":"システム全体に影響するデーモン設定は /etc 配下（システム設定の慣習的な場所）に置く。","vs":"ホームディレクトリ配下や /usr/bin は誤り。~/.docker/config.json はクライアントの設定（レジストリの認証情報等）であって、デーモン設定ではない。","opt":["正解。/etc/docker/daemon.json がデーモン設定ファイルのパス。","~/.docker/ はクライアント設定ディレクトリ。デーモン設定ではない。","daemon.json が自動読み込みされるのは /etc/docker/ 配下。","バイナリ配置ディレクトリに設定ファイルは置かない。"]}'),

  ('dca-q15', 'Installation and Configuration',
   'Docker デーモンをシステム起動時に自動起動させ、クラッシュ時に再起動させるコマンドはどれか。',
   NULL,
   '["sudo systemctl enable --now docker","sudo service docker autostart","sudo docker daemon --restart always","sudo dockerd --auto-restart"]', 0, '[0]', 'single',
   '{"asked":"systemd を使ったデーモンの有効化（自動起動）と即時起動を1コマンドで実行できることを知っているか。","terms":[["systemctl enable","サービスをシステム起動時に自動起動するよう登録する。"],["--now","enable と組み合わせることで、有効化と同時に即起動まで行う省略形。"]],"think":"電話の転送設定をオンにしながら、今すぐ転送も始める操作と同じ。enable だけでは次回起動時から、--now で今すぐも有効に。","vs":"service コマンドは SysVinit 系の旧コマンドで autostart サブコマンドは存在しない。docker daemon / dockerd に --restart や --auto-restart フラグはない。","opt":["正解。systemctl enable --now docker で自動起動登録＋即時起動。","service autostart は存在しないサブコマンド。","docker daemon に --restart フラグは存在しない。","dockerd に --auto-restart フラグは存在しない。"]}'),

  ('dca-q16', 'Installation and Configuration',
   'Docker コンテキスト（context）機能の主な用途はどれか。',
   NULL,
   '["複数の Docker ホスト（デーモン）を切り替えて操作できるようにする","Docker イメージのビルドコンテキストを指定する","Compose ファイルの環境変数グループを切り替える","Docker ネットワークのスコープを定義する"]', 0, '[0]', 'single',
   '{"asked":"docker context コマンドが何の切り替えを担うかを理解しているか。","terms":[["docker context","接続先の Docker デーモン（DOCKER_HOST）と TLS 設定を名前付きで管理し、切り替える機能。"]],"think":"SSH の設定ファイル（~/.ssh/config）でホストを名前で切り替えるのと同じ感覚。context ではリモートデーモンやローカルデーモンをスイッチして操作できる。","vs":"ビルドコンテキストは docker build 時の『送るファイル範囲』のことで別概念。Compose の環境変数は .env ファイル、ネットワークスコープは docker network の話。","opt":["正解。コンテキストは接続先デーモンを切り替える機能。","ビルドコンテキスト（COPY などの基点）は別の概念。","Compose の環境変数切り替えはコンテキストと無関係。","ネットワークスコープはネットワーク設定の話。"]}'),

  ('dca-q17', 'Installation and Configuration',
   'Docker Desktop が使う仮想マシン（LinuxKit VM）に対して、エンタープライズで注意すべき点はどれか。',
   NULL,
   '["内部の Linux カーネルや VM の設定を直接変更することはサポートされておらず、Docker Desktop 付属の設定に従う必要がある","Docker Desktop ではコンテナはホスト OS のカーネルを直接使うためセキュリティが高い","Linux では Docker Desktop と Docker Engine は全く同じもの","Docker Desktop は常にルートフルモードで動作するため、Linux に比べてセキュリティリスクが低い"]', 0, '[0]', 'single',
   '{"asked":"Docker Desktop（Mac / Windows）の内部 VM の扱いと制限を理解しているか。","terms":[["LinuxKit VM","Docker Desktop が Mac / Windows 上でコンテナを動かすために使う軽量 Linux 仮想環境。"],["Docker Engine","Linux 上で直接動くデーモン。カーネルを直接利用する。"]],"think":"Docker Desktop はラップされた箱（VM）の中でコンテナが動く。箱の中の設定は Docker Desktop の GUI や設定ファイルで制御し、直接 VM をいじることはサポートされない。","vs":"Mac / Windows では LinuxKit VM を介すため、ホスト OS のカーネルを直接使うわけではない。Linux の Docker Engine とは別物。Desktop はルートフルリスクが『低い』とは言えない（VM 内でルートとして動く部分がある）。","opt":["正解。VM 内部の直接設定変更はサポート外。","Mac/Windows では VM を介するためホスト OS カーネルを直接使わない。","Docker Desktop と Docker Engine は別製品（VM あり／なし）。","ルートフルモードのセキュリティリスクが Linux より低いとは言えない。"]}'),

  -- Domain 4: Networking (5問)
  ('dca-q18', 'Networking',
   '同一 Docker ホスト上のコンテナ同士が、コンテナ名で名前解決して通信できるネットワークはどれか。',
   NULL,
   '["user-defined bridge ネットワーク","default bridge（docker0）","host ネットワーク","macvlan ネットワーク"]', 0, '[0]', 'single',
   '{"asked":"コンテナ名による DNS 解決が有効になるネットワーク種別を知っているか。","terms":[["user-defined bridge","docker network create で作成したカスタムブリッジ。組み込み DNS が有効で、コンテナ名でアクセスできる。"],["default bridge（docker0）","docker run 時に何も指定しないと接続されるデフォルトブリッジ。コンテナ名の DNS 解決は無効。"]],"think":"新しく作ったコミュニティ（user-defined bridge）では、メンバーは名前（コンテナ名）で呼び合える。デフォルトの寮（docker0）では名前は分からず IP で連絡するしかない。","vs":"host はコンテナとホストが同一ネットワークスタックを共有する特殊形式。macvlan は物理ネットワークに直結する形式。どちらもコンテナ間名前解決の話とは異なる。","opt":["正解。user-defined bridge でコンテナ名 DNS 解決が有効。","default bridge（docker0）ではコンテナ名 DNS 解決が無効。","host ネットワークはコンテナとホストが同一スタック。名前解決の話とは別。","macvlan は物理ネットワーク直結方式で、別の用途。"]}'),

  ('dca-q19', 'Networking',
   'コンテナのポートをホストの特定のインターフェース（127.0.0.1 のみ）に公開するための正しいオプションはどれか。',
   NULL,
   '["-p 127.0.0.1:8080:80","-p 8080:80 --host-interface 127.0.0.1","-p 8080:80 --bind 127.0.0.1","-p 8080:80 -e BIND=127.0.0.1"]', 0, '[0]', 'single',
   '{"asked":"ポートバインドを特定のインターフェースに限定する書式（IP:HostPort:ContainerPort）を知っているか。","terms":[["-p / --publish","ホストのポートをコンテナのポートに紐付けて公開するオプション。書式: [IP:]hostPort:containerPort"],["ループバックバインド","127.0.0.1 にバインドすることで、同一ホストからのアクセスだけに制限する手法。"]],"think":"受付を『正面玄関（全インターフェース）』に開けるか、『内部通用口（127.0.0.1）』だけに限定するかを決める。-p の先頭に IP を付けると、そのインターフェースだけに限定できる。","vs":"--host-interface / --bind / -e BIND は存在しないオプション（または環境変数として解釈されるだけ）。書式は IP:HostPort:ContainerPort の3フィールド。","opt":["正解。127.0.0.1:8080:80 でループバックのみに限定。","--host-interface は存在しないオプション。","--bind は docker run のオプションとして存在しない。","-e BIND は環境変数を渡すだけで、ポートバインドに影響しない。"]}'),

  ('dca-q20', 'Networking',
   'Docker のオーバーレイネットワークを使う場合の前提条件はどれか。',
   NULL,
   '["Swarm モードが有効であること（または key-value ストアが設定されていること）","すべてのホストが同一 LAN サブネット内にあること","各ホストに静的 IP が割り当てられていること","Docker Engine のバージョンが 20 以上であること"]', 0, '[0]', 'single',
   '{"asked":"オーバーレイネットワークが機能するための必須前提を理解しているか。","terms":[["オーバーレイネットワーク","物理的に別ホスト上のコンテナを同一 L2 ネットワークに見せる仮想ネットワーク。"],["Swarm モード","オーバーレイネットワークの管理に必要な分散状態ストアを内蔵している。"]],"think":"複数ビルの部屋（コンテナ）を同じフロアに見せるには、管理センター（Swarm の内蔵 Raft ストア）が状態を同期していなければならない。","vs":"同一 LAN は必須条件ではない（WAN 越しでも動く）。静的 IP もバージョン要件も前提条件ではない。","opt":["正解。Swarm モードが有効（または外部 KV ストア）が必須。","同一 LAN は必須ではない。インターネット越しでも動く。","静的 IP は必須条件ではない。","特定バージョン要件はオーバーレイの前提ではない。"]}'),

  ('dca-q21', 'Networking',
   'コンテナを --network host で起動した場合の説明として正しいものはどれか。',
   NULL,
   '["コンテナはホストのネットワークスタックを共有し、コンテナのポートはホストのポートとして直接公開される","コンテナは外部ネットワークから完全に隔離される","コンテナ同士は host ネットワーク内でコンテナ名で通信できる","ホストのファイアウォールルールはコンテナに適用されない"]', 0, '[0]', 'single',
   '{"asked":"host ネットワークモードがコンテナとホストのネットワーク分離をなくすことを理解しているか。","terms":[["host ネットワーク","コンテナのネットワーク名前空間をホストと共有するモード。-p なしでもホストのポートとして公開される。"]],"think":"壁（ネットワーク分離）を取り払って、コンテナがホストの部屋に引っ越す感覚。ポートマッピング不要でホストのポートが直接使える。","vs":"host ネットワークは隔離のない状態で、外部から完全隔離とは逆。コンテナ名 DNS はホストネットワークでは機能しない（user-defined bridge の特性）。ホストのファイアウォールはコンテナにも適用される。","opt":["正解。ホストのネットワークスタックを共有し、-p 不要でポートが直接公開される。","host ネットワークは隔離をなくすモードで、外部隔離とは逆。","コンテナ名 DNS は user-defined bridge の特性。host ネットワークでは機能しない。","ホストのファイアウォールルールはコンテナにも影響する。"]}'),

  ('dca-q22', 'Networking',
   'docker network inspect コマンドで確認できる情報として正しいものはどれか。',
   NULL,
   '["ネットワークのサブネット・ゲートウェイ・接続コンテナの IP アドレス","ネットワーク上の全パケットの通信ログ","コンテナのファイアウォールルール一覧","ネットワークドライバーのソースコード"]', 0, '[0]', 'single',
   '{"asked":"docker network inspect コマンドが出力する情報を理解しているか。","terms":[["docker network inspect","指定ネットワークの詳細情報（サブネット・ゲートウェイ・ドライバー・接続コンテナとその IP 等）を JSON で出力するコマンド。"]],"think":"建物の設計図（サブネット・ゲートウェイ）と入居者リスト（接続コンテナと IP）を一覧表示するイメージ。","vs":"パケットログは tcpdump などのツール、ファイアウォールルールは iptables / docker の設定、ソースコードは inspect の出力ではない。","opt":["正解。サブネット・GW・接続コンテナ IP などのメタデータを表示する。","パケット通信ログは別ツール（tcpdump 等）で取得する。","コンテナのファイアウォールルールは inspect では取得できない。","ドライバーのソースコードは表示されない。"]}'),

  -- Domain 5: Security (5問)
  ('dca-q23', 'Security',
   'コンテナのセキュリティ強化として、非 root ユーザーでコンテナプロセスを実行させる方法はどれか。',
   'FROM ubuntu:22.04\nRUN useradd -m appuser\n# ↓ここに何を書く？\nCMD ["myapp"]',
   '["USER appuser を Dockerfile に追加する","PRIVILEGE appuser を Dockerfile に追加する","docker run --non-root appuser を指定する","ENTRYPOINT を chown コマンドにする"]', 0, '[0]', 'single',
   '{"asked":"Dockerfile で実行ユーザーを切り替える命令を知っているか。","terms":[["USER 命令","以降のコマンド（RUN / CMD / ENTRYPOINT）を実行するユーザーを切り替える Dockerfile 命令。"]],"think":"工場のラインに入る前に制服を着替える（USER で権限の低いユーザーに切り替え、root のままラインに立たない）ようなもの。","vs":"PRIVILEGE は存在しない命令。docker run --non-root は存在しないオプション。ENTRYPOINT を chown にしても実行ユーザーは変わらない。","opt":["正解。USER appuser で以降の CMD 実行ユーザーを切り替える。","PRIVILEGE は存在しない Dockerfile 命令。","docker run に --non-root オプションは存在しない。","chown は所有権変更であり、実行ユーザーの変更ではない。"]}'),

  ('dca-q24', 'Security',
   'コンテナに付与される Linux ケーパビリティを制限するための docker run オプションはどれか。',
   NULL,
   '["--cap-drop ALL（全削除して必要な cap だけ --cap-add で追加）","--security-opt no-capabilities","--privilege=false","--isolation=restricted"]', 0, '[0]', 'single',
   '{"asked":"コンテナのケーパビリティを最小化する正しいアプローチ（cap-drop ALL + cap-add 必要分）を知っているか。","terms":[["Linux capabilities","root 権限を細分化した権限セット（例: NET_ADMIN, SYS_PTRACE など）。コンテナはデフォルトで一部のみ付与。"],["--cap-drop / --cap-add","ケーパビリティを削除・追加するフラグ。--cap-drop ALL で全削除後、必要なものだけ --cap-add する最小権限パターンが推奨。"]],"think":"万能ナイフ（デフォルトの cap セット）から不要な刃を全部外し、今回の作業に必要な刃だけ付け直すイメージ。","vs":"--security-opt no-capabilities / --privilege=false / --isolation=restricted は存在しないオプション（または意味が異なる）。","opt":["正解。--cap-drop ALL で全削除し、必要なものだけ --cap-add で追加するのが最小権限パターン。","--security-opt no-capabilities は存在しないオプション。","--privilege はルートフルの逆ではなく --privileged が特権付与（=拡大側）。","--isolation=restricted は存在しないオプション。"]}'),

  ('dca-q25', 'Security',
   'Docker Content Trust（DCT）を有効にした場合の効果はどれか。',
   NULL,
   '["pull/push 時に署名検証を行い、署名されていないイメージは拒否される","コンテナのネットワーク通信が自動的に TLS 暗号化される","イメージレイヤーがファイルシステムレベルで暗号化される","コンテナに特権モードを付与できなくなる"]', 0, '[0]', 'single',
   '{"asked":"Docker Content Trust が何を検証するのか（署名の確認による改ざん防止）を理解しているか。","terms":[["Docker Content Trust (DCT)","Notary ベースのイメージ署名検証機能。DOCKER_CONTENT_TRUST=1 で有効化。",""],["Notary","Docker が採用するコンテンツ署名・検証のフレームワーク。"]],"think":"荷物に封印の判子（署名）が押されているか確認してから受け取る仕組み。判子のない荷物（未署名イメージ）は受け取らない。","vs":"DCT はイメージの『出所の正当性』を検証するもの。ネットワーク通信の暗号化・レイヤー暗号化・特権モード制御とは別の話。","opt":["正解。署名検証を行い、未署名イメージを拒否する。","ネットワーク暗号化は DCT の機能ではない。","ファイルシステム暗号化は DCT の機能ではない。","特権モード制御は DCT の機能ではない。"]}'),

  ('dca-q26', 'Security',
   'コンテナのファイルシステムを読み取り専用にする docker run オプションはどれか。',
   NULL,
   '["--read-only","--immutable","--no-write","--fs-readonly"]', 0, '[0]', 'single',
   '{"asked":"コンテナルートファイルシステムを read-only にするフラグを知っているか。","terms":[["--read-only","コンテナのルートファイルシステムを読み取り専用でマウントするフラグ。"]],"think":"展示物に『手を触れないでください』のケースを付けるイメージ。書き込みが必要な場所（/tmp 等）は --tmpfs を組み合わせて対処する。","vs":"--immutable / --no-write / --fs-readonly は存在しないフラグ。","opt":["正解。--read-only でルートファイルシステムを読み取り専用にする。","--immutable は存在しないフラグ。","--no-write は存在しないフラグ。","--fs-readonly は存在しないフラグ。"]}'),

  ('dca-q27', 'Security',
   'Docker の seccomp プロファイルの役割として正しいものはどれか。',
   NULL,
   '["コンテナプロセスが呼び出せるシステムコールを制限する","コンテナのメモリ使用量を制限する","コンテナ間のネットワーク通信を暗号化する","イメージの脆弱性スキャンを行う"]', 0, '[0]', 'single',
   '{"asked":"seccomp プロファイルがシステムコールの制限に使うセキュリティ機能であることを知っているか。","terms":[["seccomp","Secure Computing Mode の略。カーネルに対してコンテナが呼び出せるシステムコールをホワイトリスト/ブラックリスト形式で制限する。"],["Docker のデフォルト seccomp プロファイル","約 300 のシステムコールを許可し、危険な約 44 をブロックするデフォルトポリシー。"]],"think":"コンテナに電話帳（システムコール一覧）を渡すが、危険な番号（危険な syscall）にはあらかじめ発信規制をかけておく仕組み。","vs":"メモリ制限は --memory フラグ、ネットワーク暗号化は TLS / DCT、脆弱性スキャンは trivy / snyk 等のツール。","opt":["正解。seccomp はシステムコールの呼び出しを制限する。","メモリ制限は --memory フラグで行う。","ネットワーク暗号化は seccomp の機能ではない。","脆弱性スキャンは別ツールの役割。"]}'),

  -- Domain 6: Storage and Volumes (4問)
  ('dca-q28', 'Storage and Volumes',
   'Docker ボリュームとバインドマウントの違いとして正しいものはどれか。',
   NULL,
   '["ボリュームは Docker が管理する領域に保存され、バインドマウントはホスト OS の任意のパスを直接マウントする","ボリュームはコンテナ削除と同時に必ず削除される","バインドマウントは Docker が暗号化して保管する","ボリュームはネットワーク越しのストレージのみに使える"]', 0, '[0]', 'single',
   '{"asked":"ボリュームとバインドマウントの管理主体と保存場所の違いを正確に理解しているか。","terms":[["Docker ボリューム","Docker が /var/lib/docker/volumes/ 配下で管理する永続ストレージ。コンテナ削除後も残る（明示的削除まで）。"],["バインドマウント","ホスト OS の任意のディレクトリをコンテナにマウントする手法。ホスト側のパス構造に依存する。"]],"think":"ボリュームは Docker が管理する専用ロッカー、バインドマウントは『自分の部屋（ホストの任意ディレクトリ）の棚をそのまま貸す』感覚。","vs":"ボリュームはコンテナ削除と同時に削除されない（docker volume rm が必要）。バインドマウントは暗号化しない。ボリュームはネットワーク越し専用ではなくローカルにも使う。","opt":["正解。Docker 管理領域 vs ホスト OS 任意パスが最大の違い。","ボリュームはコンテナ削除後も残る。明示的な docker volume rm が必要。","バインドマウントは暗号化しない。","ボリュームはネットワーク越しだけでなく、ローカルにも使う。"]}'),

  ('dca-q29', 'Storage and Volumes',
   '複数のコンテナで同じボリュームをマウントしてデータを共有したい。正しい方法はどれか。',
   'docker run -v myvolume:/data app1\ndocker run -v ______:/data app2',
   '["同じボリューム名（myvolume）を指定する","--volumes-from で app1 コンテナを指定する（どちらも正しい）","新しいボリューム名を指定し、docker cp でコピーする","ボリュームのシンボリックリンクをコンテナ間で作成する"]', 0, '[0]', 'single',
   '{"asked":"同じ名前付きボリュームを複数コンテナで共有する方法を知っているか。","terms":[["名前付きボリューム","docker volume create または -v name:/path 形式で作成・参照する、名前で識別されるボリューム。同名を複数コンテナで指定すれば共有できる。"]],"think":"同じ鍵（ボリューム名）を持つロッカー（ボリューム）に、2人がそれぞれ自分の棚（マウントポイント）として紐付けるイメージ。","vs":"--volumes-from も別途正しい方法だが、最も標準的なのは同じ名前を指定する方法。docker cp は都度コピーで共有にならない。シンボリックリンクは不要で複雑。","opt":["正解。同じボリューム名を指定するだけで共有できる。","--volumes-from も動くが、同名指定が標準的でシンプルな方法。","docker cp はコピーであり、継続的な共有にならない。","シンボリックリンクは不要かつ複雑で非推奨。"]}'),

  ('dca-q30', 'Storage and Volumes',
   'コンテナ内の /tmp を高速なメモリベースのストレージにマウントしたい。正しいオプションはどれか。',
   NULL,
   '["--tmpfs /tmp","--memory-mount /tmp","--ramdisk /tmp","--volatile /tmp"]', 0, '[0]', 'single',
   '{"asked":"tmpfs マウント（メモリベース）を使うフラグを知っているか。","terms":[["--tmpfs","指定パスをメモリ上の tmpfs でマウントする。コンテナ停止でデータは揮発するが、高速かつ --read-only コンテナで一時書き込みが必要な場所に使う。"]],"think":"ホワイトボード（tmpfs）はペンで書いたらすぐ消えるが、書くのはとても速い。コンテナが止まれば全消去。一時データの置き場に最適。","vs":"--memory-mount / --ramdisk / --volatile は存在しないフラグ。","opt":["正解。--tmpfs /tmp でメモリベースマウントを設定する。","--memory-mount は存在しないフラグ。","--ramdisk は存在しないフラグ。","--volatile は存在しないフラグ。"]}'),

  ('dca-q31', 'Storage and Volumes',
   '不要なボリュームを一括削除して Docker ホストのディスク容量を解放するコマンドはどれか。',
   NULL,
   '["docker volume prune","docker volume rm --all","docker system clean --volumes","docker volumes delete unused"]', 0, '[0]', 'single',
   '{"asked":"未使用ボリュームを一括削除するコマンドを知っているか。また system prune との違いも把握しているか。","terms":[["docker volume prune","使用されていない（どのコンテナにもマウントされていない）ボリュームを一括削除するコマンド。"],["docker system prune","停止コンテナ・未使用ネットワーク・ダングリングイメージ・ビルドキャッシュをまとめて削除する。--volumes フラグを付けるとボリュームも含まれる。"]],"think":"倉庫の『棚卸し』と同じ。どこにも紐付いていない荷物（未使用ボリューム）をまとめて捨てる。prune は Docker 全般の『不要物一括削除』コマンドの共通語。","vs":"rm --all / clean --volumes / volumes delete unused はいずれも存在しないオプション・サブコマンド。","opt":["正解。docker volume prune で未使用ボリュームを一括削除する。","docker volume rm --all は存在しない（--all フラグはない）。","docker system clean は存在しないサブコマンド（正しくは prune）。","docker volumes delete unused は存在しないコマンド。"]}')

) AS v(source_ref, cat_name, question_text, code, options, correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.cat_name
WHERE s.slug = 'dca'
ON CONFLICT (subject_id, source_ref) DO NOTHING;
