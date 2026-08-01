BEGIN;

-- 既存81問のうち、正解が単独最長で答えが推測できてしまっていた30問の選択肢を均す。
-- 意味・正解位置・explanation_dataは一切変更しない。誤答の密度と長さだけを補う。

UPDATE public.questions q
SET options = '["-p 8080:80 はホスト:コンテナのポートを明示指定、-P は Dockerfile の EXPOSE で公開されたポートをランダムなホストポートに自動マッピング", "-p と -P はどちらも全く同じポートマッピング動作を行うコマンドであり、実質的には書き方が違うだけの表記ゆれにすぎない", "-P を指定すると、Dockerfileの EXPOSE 命令で宣言された全ポートが、コンテナ側と全く同じ番号のままホストにマッピングされる", "-p はUDPプロトコルを使うポートだけをサポートし、-P の方はTCPプロトコルを使うポートだけをサポートする"]'::jsonb
WHERE q.source_ref = 'dca-q59'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["シークレットは Swarm のマネージャーが暗号化して管理し、必要なサービスのコンテナのみ /run/secrets/ にマウントされる", "シークレットの値は環境変数の形式に自動変換されたうえで、Swarmクラスター内の全コンテナへ無条件に配布される", "シークレットの中身はDocker Hub上の該当リポジトリに、暗号化された状態でそのままアップロードされ保存される", "シークレットを利用しているコンテナを一度でも再起動すると、そのシークレットの内容は自動的に完全消去される"]'::jsonb
WHERE q.source_ref = 'dca-q67'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["コンテナにホストのネットワークインターフェースから直接 MAC アドレスと IP アドレスを割り当て、物理ネットワークに直接接続する", "Macvlanは、コンテナ同士がやり取りするトラフィックの中身だけを自動的に暗号化して転送してくれる仕組み", "複数のDockerホストにまたがって動くコンテナ同士を、1つの仮想的なL2ネットワークとしてまとめて接続する仕組み", "Macvlanネットワークを指定すると、そのコンテナが持つネットワーク機能そのものが完全に無効化されてしまう"]'::jsonb
WHERE q.source_ref = 'dca-q61'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["docker login <registry> でログインし、docker tag でレジストリ名を含む完全なタグを付けてから docker push する", "docker login やタグ付けを省略し、docker push に --registry フラグでレジストリのURLを直接指定するだけでよい", "プライベートレジストリであっても、docker tag でレジストリ名を含むタグを付けさえすれば認証なしでpushできる", "通常のdocker buildコマンドに--pushフラグを付ければ、タグ付けの手順を経ずに直接レジストリへpushできる"]'::jsonb
WHERE q.source_ref = 'dca-q9'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["ボリュームは Docker が管理する領域に保存され、バインドマウントはホスト OS の任意のパスを直接マウントする", "名前付きボリュームは、それを使っていたコンテナを削除すると同時に必ず自動的に削除される", "バインドマウントで指定したホストのパスは、Dockerが自動的に暗号化してから保管する", "ボリュームはネットワーク越しの外部ストレージに対してのみ使用でき、ローカルには作れない"]'::jsonb
WHERE q.source_ref = 'dca-q28'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["save はイメージ全体（レイヤー・タグ含む）を tar で保存、export はコンテナのファイルシステムを履歴なしで tar に書き出す", "export はイメージのレイヤー構造をそのまま含めて保存し、save はメタデータだけを保存する（説明が逆）", "save コマンドと export コマンドは実装上どちらも全く同一のtarフォーマットで出力される", "export は Docker Hub のようなリモートレジストリへイメージをそのままアップロードするコマンド"]'::jsonb
WHERE q.source_ref = 'dca-q38'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["constraint は必須条件でマッチしないノードには絶対配置しない。placement-pref は優先度で、できれば均等分散するが絶対ではない", "constraint と placement-pref はSwarmの内部的には同一の機能で、書き方だけが異なる別名にすぎない", "placement-pref は各ノードのCPU使用率をリアルタイムに測定し、自動的に配置を最適化し続ける機能", "constraint はマネージャーノードに対してのみ適用可能な設定で、ワーカーノードには一切指定できない"]'::jsonb
WHERE q.source_ref = 'dca-q81'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["iptables の MASQUERADE ルールでコンテナの送信元 IP をホストの IP に変換（SNAT）して外部に送信する", "コンテナは最初からホストと同じIPアドレスを使って通信するため、NAT変換自体が不要になる", "Dockerの外部通信はNATを一切使わず、VXLANカプセル化だけで直接インターネットへ届けている", "iptables のDNATルールを使って、外部からコンテナへ向かう通信の宛先だけを変換している"]'::jsonb
WHERE q.source_ref = 'dca-q63'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["Docker デーモン（dockerd）の設定ファイルで、ログドライバーやレジストリ設定などを永続的に設定する", "docker run コマンドを実行するたびに使われるデフォルトの引数を設定するファイル", "各Dockerfileに書かれたデフォルトの命令を、ビルド時に上書きするための設定ファイル", "docker compose を実行する際に自動で読み込まれるデフォルトの設定ファイル"]'::jsonb
WHERE q.source_ref = 'dca-q50'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["コンテナが正常に動作しているか定期的にチェックし、結果を docker ps の STATUS に反映する", "コンテナではなくホストマシン全体の健全性を監視して、必要なら自動的に再起動する", "単独のdocker runでは効かず、Swarmサービスに対してだけ自動的に適用される仕組み", "定期的な繰り返しではなく、コンテナ起動時に1回だけ実行されるウォームアップ用の命令"]'::jsonb
WHERE q.source_ref = 'dca-q37'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["image prune は未使用イメージのみ削除、system prune はイメージ・コンテナ・ネットワーク・ビルドキャッシュを一括削除する", "system prune はボリュームも既定のオプションだけで必ず一緒に削除するが、image prune は削除しない", "image prune はタグの有無に関わらず全イメージを問答無用で削除し、system prune の方は選択的に削除する", "image prune も system prune も、既定のオプションのまま実行中のコンテナが使うイメージまで削除してしまう"]'::jsonb
WHERE q.source_ref = 'dca-q41'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["ボリュームのマウントポイント（ホスト上のパス）・ドライバー・ラベルなどのメタデータ", "そのボリュームを現在マウントして使っているコンテナのID一覧", "そのボリュームの中に実際に保存されているファイルの一覧", "そのボリュームに対する読み書きのI/O統計情報の推移"]'::jsonb
WHERE q.source_ref = 'dca-q73'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["Swarm のどのノードに来たリクエストも、サービスの実行コンテナにルーティングするロードバランシングを提供する", "外部から届いたトラフィックをすべて検査してブロックするファイアウォールとして機能する", "他のネットワークとは完全に切り離された、Swarmサービス同士の内部通信専用ネットワーク", "Swarmの管理者だけがサービスの稼働状態を監視するために使う、専用の管理ネットワーク"]'::jsonb
WHERE q.source_ref = 'dca-q62'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["イメージ・コンテナ・ボリューム・ビルドキャッシュが使用しているディスク容量", "現在実行中コンテナのCPUとメモリのリアルタイム使用率", "各コンテナが使っているネットワーク帯域幅の使用量", "現在実行中のコンテナの中で動いているプロセスの一覧"]'::jsonb
WHERE q.source_ref = 'dca-q53'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["OverlayFS を使って読み取り専用レイヤーを積み重ね、最上位に書き込み可能なコンテナレイヤーを配置する", "overlay2 はディスクを一切使わず、すべてのデータをメモリ上だけに保存しておく仕組み", "overlay2 は変更のたびに下位レイヤーの中身を毎回まるごと完全にコピーしてから書き換える", "overlay2 という名前だが、実際にはZFSというファイルシステムをベースに実装されている"]'::jsonb
WHERE q.source_ref = 'dca-q74'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["名前空間（Namespaces）と cgroups（Control Groups）", "パケットを制御するiptablesと、ストレージを扱うOverlayFS", "サービス管理を担うsystemdと、システムコールを絞るseccomp", "アクセス制御を行うAppArmorと、仮想ネットワークのVXLAN"]'::jsonb
WHERE q.source_ref = 'dca-q48'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["docker build のビルドコンテキストから特定ファイルを除外し、イメージサイズ削減とシークレット漏洩防止に使う", "Dockerfile 自体に書かれたコメント行を、ビルド時に無視させるための専用の設定ファイル", "docker run 実行時に、特定のボリュームだけをマウントしないよう明示的に指定するファイル", "コンテナが実際に実行されるタイミングで、特定の環境変数だけを除外して読み込ませないファイル"]'::jsonb
WHERE q.source_ref = 'dca-q35'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["ボリュームは Docker が管理するストレージ、バインドマウントはホストのディレクトリを直接マウント、tmpfs はメモリ上の一時ストレージ", "バインドマウントの方がDockerが管理するストレージで、ボリュームの方がホストのディレクトリを直接マウントする（説明が逆）", "tmpfs は実はディスク上に永続化される大容量のストレージで、ボリュームよりもずっと多くの容量を扱える", "ボリューム・バインドマウント・tmpfsの3つは、Dockerの内部実装としてはすべて完全に同一の機能であり、書き方だけが異なる"]'::jsonb
WHERE q.source_ref = 'dca-q71'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["名前付きボリュームは docker volume ls で確認・再利用できる。匿名ボリュームはコンテナ削除時に docker rm -v で一緒に削除できる", "匿名ボリュームは必ず docker volume create コマンドで明示的に作成し、名前付きボリュームはDockerfile内でのみ作成できる", "名前付きボリュームの方こそ、それを使っていたコンテナを削除すると自動的に一緒に削除されてしまう", "匿名ボリュームは名前が無い分、複数のコンテナ間で自由に指定して共有できる仕組みになっている"]'::jsonb
WHERE q.source_ref = 'dca-q72'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["そのノードで動いているタスクを別のノードに移動し、新しいタスクをスケジュールしなくなる", "そのノードをクラスターから強制的に切り離し、Swarmから完全に削除する", "そのノードで動いているコンテナをすべて即座に停止し、跡形もなく削除する", "そのノードがマネージャーだった場合、自動的にワーカーノードへ降格させる"]'::jsonb
WHERE q.source_ref = 'dca-q80'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["python app.py が実行される。docker run 時に引数を渡すと CMD だけが上書きされる", "CMDに書かれた引数の方が優先され、ENTRYPOINTのpythonコマンド自体は無視される", "docker run を実行するときに渡す引数によって、固定のはずのENTRYPOINT自体が上書きされてしまう", "CMD命令が書かれていない場合、ENTRYPOINTの命令自体も一緒に無視されて実行されない"]'::jsonb
WHERE q.source_ref = 'dca-q11'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["接続先の Docker デーモン（ローカル・リモート・Swarm 等）を切り替える設定を管理する", "コンテナに割り当てるネットワーク名前空間そのものをcontextという単位で設定する", "docker buildで使われるビルドコンテキストの範囲を、あらかじめ定義しておく", "docker compose を実行する際に使われるプロジェクト名を設定するための項目"]'::jsonb
WHERE q.source_ref = 'dca-q52'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["コンテナがホストのほぼすべてのデバイスにアクセスでき、カーネルへの操作も可能になりコンテナエスケープのリスクが高まる", "--privileged はコンテナ内のプロセスをrootユーザーとして実行するだけの設定で、危険性はさほど高くない", "--privileged を付けると、コンテナが行うネットワーク通信の暗号化だけが自動的に無効化される", "--privileged を付けると、コンテナのファイルシステムだけが自動的にホストと共有状態になる"]'::jsonb
WHERE q.source_ref = 'dca-q69'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["Docker はファイルレベルのロックを提供しないため、複数コンテナが同時書き込みするとデータ競合が発生しうる", "Docker のボリュームは常に自動で排他制御を行っているため、複数コンテナが同時に使っても安全", "使用しているボリュームドライバーが、書き込みの順番を自動的にすべて直列化してくれる", "複数のコンテナが同じボリュームへ同時に書き込もうとすると、Docker側が自動的にエラーとして弾いてくれる"]'::jsonb
WHERE q.source_ref = 'dca-q77'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["コンテナはホスト OS のカーネルを共有するが、VM は独自のカーネルを持つハイパーバイザー上で動く", "コンテナはカーネルを共有しているにも関わらず、VMよりも強力なセキュリティ分離を実現している", "VMはゲストOSを丸ごと積んでいるにも関わらず、実はコンテナより起動が速い", "コンテナはCPUの仮想化技術を使って動いており、VMの方はOSレベルの仮想化技術を使っている"]'::jsonb
WHERE q.source_ref = 'dca-q47'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["コンテナはホストのネットワークスタックを共有し、コンテナのポートはホストのポートとして直接公開される", "--network host を付けると、コンテナはむしろ外部ネットワークから完全に隔離される", "同じhostネットワークモードのコンテナ同士は、専用のDNSでコンテナ名を使って通信できる", "hostモードのコンテナには、ホスト側で設定したファイアウォールルールが一切適用されない"]'::jsonb
WHERE q.source_ref = 'dca-q21'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["ネットワークのサブネット・ゲートウェイ・接続コンテナの IP アドレス", "そのネットワーク上を流れる全パケットの詳細な通信ログ", "そのネットワークに接続する各コンテナのファイアウォールルール一覧", "そのネットワークが使っているドライバー自体のソースコード"]'::jsonb
WHERE q.source_ref = 'dca-q22'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["DOCKER_CONTENT_TRUST=1 で、署名されていないイメージの pull/push を拒否する", "DOCKER_TRUST_ALL=1 という環境変数を設定すると、すべてのイメージの署名が自動検証される", "DCTを有効にすると、pushするイメージの中身そのものが自動的に暗号化されてしまう", "DCTという機能自体が、社内のプライベートレジストリでは仕様上サポートされていない"]'::jsonb
WHERE q.source_ref = 'dca-q70'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["config は非機密の設定ファイル（nginx.conf 等）を配布する。secret は機密値を暗号化して配布する", "config と secret は Swarm内部の実装としては完全に同一の機能で、名前が違うだけ", "config は常にボリュームを経由して配布され、secret は毎回ネットワーク経由で配布される", "secret の方こそ平文のまま保存され、config の方が暗号化されて保存される（説明が逆）"]'::jsonb
WHERE q.source_ref = 'dca-q78'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET options = '["コンテナ内のプロセスが呼び出せるシステムコールを制限し、カーネル攻撃面を減らす", "そのコンテナが使えるCPUの使用率だけを制限する仕組み", "そのコンテナが行うネットワーク通信の中身を暗号化する仕組み", "複数のコンテナ間でのファイルシステムへのアクセス権を制御する仕組み"]'::jsonb
WHERE q.source_ref = 'dca-q68'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

COMMIT;