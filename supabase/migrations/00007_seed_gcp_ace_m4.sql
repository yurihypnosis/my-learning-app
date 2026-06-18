-- =============================================================
-- 00007_seed_gcp_ace_m4.sql
-- GCP ACE 練習問題 第1セット（m4q prefix）
-- =============================================================

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options, correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb, v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('m4q01', '運用・CLI',
   'スタートアップ企業の買収完了後、そのGCPプロジェクトを自社組織に移動し、自社の請求先アカウントで課金されるようにする必要があります。最小限の労力で達成するには？',
   NULL::text,
   '["projects.moveメソッドでプロジェクトを組織に移動し、請求先アカウントを更新する","Deployment Managerでプロジェクト内リソースのIaCテンプレートを作成し、自社組織の新プロジェクトにデプロイする","Marketplaceのプライベートカタログを作成し、リソースをアップロードして自社プロジェクトにデプロイする","Terraformでリソースのテンプレートを作成し、自社組織の新プロジェクトに再デプロイする"]',
   0, '[0]', 'single',
   '{"asked":"GCPリソース階層でのプロジェクト移行と請求先変更の方法を問う。既存リソースを保ちながら最小手順で組織をまたぐ移動を実現できるかを確認する。","terms":[["projects.move","プロジェクトを別の組織やフォルダに移動するAPIメソッド。プロジェクト内のリソースはそのまま保持され、再作成は不要。"],["請求先アカウント（Billing Account）","GCPの利用料金を支払うための口座。プロジェクトとは独立して存在し、どのプロジェクトをどの口座に紐づけるかは別途設定する。"]],"think":"引越し（projects.move）と口座変更（billing update）の2ステップだけ。家具（リソース）はそのまま持っていける。B/C/Dは家具を全部捨てて新居で買い直すようなもので、最小限の労力に反する。","vs":"IaCツール（Terraform・Deployment Manager）は『新しく作る』ためのもので、既存プロジェクトの移行には不向き。『移動』と『再構築』を混同しないこと。","opt":["正解。projects.moveで組織移動＋請求先更新の2ステップで最小労力。","Deployment Managerは新規インフラ作成用。既存プロジェクトの移行には複雑すぎる。","Marketplaceカタログは外部共有・販売用。プロジェクト移行の手段ではない。","Terraformも新規構築用。既存リソースの移行より複雑で労力が大きい。"]}'),

  ('m4q05', 'コンピュート・VM',
   'マネージドインスタンスグループ（MIG）のウェブアプリを段階的にデプロイしたい。現在ライブトラフィックを受信中。デプロイ中に利用可能な容量が減少しないようにするには？',
   NULL::text,
   '["maxSurgeを1以上、maxUnavailableを0に設定してローリングアクションを開始する","maxSurgeを0、maxUnavailableを1に設定してローリングアクションを開始する","新しいMIGを作成してロードバランサのバックエンドに追加する（ブルー/グリーンデプロイ）","新しいインスタンステンプレートでMIGを更新し、インスタンスを手動削除して新バージョンで再作成する"]',
   0, '[0]', 'single',
   '{"asked":"MIGのローリングアップデートでmaxSurgeとmaxUnavailableの意味を理解し、容量を落とさないための正しい設定を選べるかを問う。","terms":[["maxSurge","ローリング中に一時的に追加できるインスタンスの上限数。新旧を並行稼働させる余裕を作る。"],["maxUnavailable","ローリング中に同時に停止できるインスタンスの最大数。0にすると現在台数を下回らない（容量減少なし）。"],["ローリングアップデート","MIGを止めずに少しずつ新バージョンに置き換える更新方式。"]],"think":"引越しの例。荷物（トラフィック）を受け取りながら部屋（VM）を順番に改装するには、まず新しい部屋を1室余分に用意（maxSurge=1）してから旧部屋を取り壊す。旧部屋を先に壊す（maxUnavailable=1）と一時的に部屋が足りなくなる。","vs":"maxSurge=0/maxUnavailable=1は旧インスタンスを先に落としてから新しいものを起動するので容量が一時的に減る。容量維持にはmaxUnavailable=0が必須。","opt":["正解。新インスタンスを先に起動してから旧を落とすので容量は減らない。","maxUnavailable=1は旧を先に落とすため一時的に容量が減少し要件違反。","カナリア/ブルーグリーンとして有効だが、既存MIGのローリングアップデートより複雑。","手動削除は作業量が多く、誤操作リスクもある。最小手順でない。"]}'),

  ('m4q07', 'IAM・組織ポリシー',
   '財務チームにはプロジェクトを請求先アカウントにリンクする権限のみ付与し、他の変更は不可にしたい。エンジニアリングチームはプロジェクト作成はできるが請求先へのリンクはできない。どう設定すべきか？',
   NULL::text,
   '["財務チーム: Billing Account User（請求先）＋Project Billing Manager（組織）。エンジニアリング: Project Creatorのみ","財務チーム: Billing Account Administratorを組織レベルで付与。エンジニアリング: Project Creatorを付与","財務チーム: Project Ownerを各プロジェクトに付与。エンジニアリング: Project Creatorを付与","財務チーム: Billing Account Userのみ（請求先）。エンジニアリング: Project Creator＋Billing Account Viewer"]',
   0, '[0]', 'single',
   '{"asked":"GCPの請求に関する2つのIAMロール（Billing Account UserとProject Billing Manager）の違いと、最小権限での組み合わせを理解しているかを問う。","terms":[["Billing Account User","請求先アカウントとプロジェクトをリンクする権限。プロジェクトのリソース操作権限は含まない。"],["Project Billing Manager","プロジェクトの請求先リンクを変更する権限。組織レベルで付与すると全プロジェクトに適用される。リソース操作権限なし。"],["Project Creator","新規プロジェクトを作成できる権限。請求先アカウントへのリンク権限は含まない。"]],"think":"経理部（財務チーム）は『どの口座に紐付けるか』だけ決められればいい。Billing Account Userで請求先アカウントを使う権限、Project Billing Managerで全プロジェクトへの適用が可能になる。エンジニアはProject Creatorのみで部署（プロジェクト）は作れるが口座の変更はできない。","vs":"Billing Account AdministratorはBillingアカウント全体の管理者（ユーザー追加・削除も可能）で権限が広すぎる。Project Ownerはプロジェクトの全権限で過剰。","opt":["正解。財務チームに最小権限（リンク操作のみ）、エンジニアにProjectCreatorのみという最小権限設計。","Billing Account Adminは管理者権限が広すぎ、最小権限の原則に反する。","Project OwnerはプロジェクトリソースへのフルアクセスでBilling操作以外も含み過剰。","Billing Account UserだけではProject Billing Managerなしでプロジェクトへのリンク変更ができない。"]}'),

  ('m4q18', 'IAM・組織ポリシー',
   'データセンターで実行するアプリからAutoML（GCPサービス）を使用する。適切なアクセス権を持つサービスアカウントを作成済み。オンプレミス環境からAPIへの認証を有効にするには？',
   NULL::text,
   '["サービスアカウントのキーファイルをダウンロードし、オンプレミスアプリケーションで認証情報として使用する","サービスアカウントのキーをVMのメタデータに保存する","Direct Interconnectでネットワーク接続を確立する","IAM管理コンソールでSAと同じ権限をユーザーアカウントに付与し、そのユーザーアカウントで認証する"]',
   0, '[0]', 'single',
   '{"asked":"オンプレミス環境からGCPサービスにアクセスする際の認証方法を問う。GCP外の環境ではメタデータサーバーによる自動認証が使えないという制約を理解しているか。","terms":[["サービスアカウントキーファイル（JSON）","サービスアカウントの秘密鍵をJSON形式でエクスポートしたもの。GCP外の環境からAPI認証に使用する。","メタデータサーバー","GCPのVM内に自動的に存在する認証情報プロバイダ（169.254.169.254）。GCP上のVMでは自動的に認証情報を取得できるが、オンプレミス環境には存在しない。"]],"think":"自社ビル（オンプレ）でGoogleの施設（GCP）に入るには、事前に発行した入館証（キーファイル）を持参するしかない。GCPのVM内なら建物のセキュリティシステム（メタデータサーバー）が自動で認証してくれるが、社外からは手動の証明書が必要。","vs":"Direct Interconnectはネットワーク接続の手段であり認証の仕組みではない。ユーザーアカウントでの認証はGoogleのベストプラクティスに反する（アカウント離任時の管理が困難）。","opt":["正解。オンプレミスでGCP APIを使う唯一の標準的方法。","VMのメタデータは別の目的で使うもの。キーファイルをメタデータに保存するのはセキュリティリスクが高い。","Direct Interconnectはネットワーク接続であり、API認証とは無関係。","ユーザーアカウントでのアプリ認証はGoogle非推奨。パスワード管理・権限分離が複雑になる。"]}'),

  ('m4q21', 'コンピュート・VM',
   'Compute EngineでWindows VMを設定後、RDP経由でVMにログインできることを確認したい。どうすべきか？',
   NULL::text,
   '["VM作成後、gcloud compute reset-windows-passwordを使用してVMのログイン認証情報を取得する","VM作成後、GoogleアカウントのID/パスワードでVMにログインする","VM作成後、サービスアカウントの秘密キーファイルをダウンロードしてRDP認証に使用する","VM作成後、ssh-keygenでSSHキーを生成しWindowsのRDPに使用する"]',
   0, '[0]', 'single',
   '{"asked":"Compute EngineのWindows VMへのRDPアクセスに必要な認証情報取得手順を理解しているかを問う。","terms":[["gcloud compute reset-windows-password","Compute EngineのWindows VMに対してランダムなパスワードを生成し、そのユーザー名とパスワードを返すgcloudコマンド。RDP接続に使用する。"],["RDP（Remote Desktop Protocol）","Windowsのリモートデスクトップ接続に使用するプロトコル。デフォルトでTCPポート3389を使用。GoogleアカウントではなくWindowsローカル認証を使う。"]],"think":"Windowsの部屋（VM）に入るには、GCP管理人（gcloudコマンド）に頼んで合鍵（パスワード）を発行してもらう。Googleアカウントのカードキーは全く別のロックで使えない。Linuxで使うSSHキーも無関係。","vs":"GoogleアカウントはGCPコンソールへのログインには使うが、Windows VMのRDP認証とは別物。SSHキーはLinux向けのアクセス手段でWindowsとは関係ない。","opt":["正解。reset-windows-passwordがGCP推奨の標準的なWindows VM認証情報取得方法。","GoogleアカウントはWindowsローカル認証では直接使えない。","サービスアカウントキーはGCP APIアクセス用であり、RDP認証には使えない。","SSHキーはLinux VM向け。WindowsのRDPには不要。"]}'),

  ('m4q22', 'IAM・組織ポリシー',
   'dev1グループのユーザーのために、単一のCompute EngineインスタンスへのSSH接続を設定したい。このインスタンスのみがdev1ユーザーが接続できるリソースである必要がある。どうすべきか？',
   NULL::text,
   '["インスタンスにenable-oslogin=trueのメタデータを設定する。dev1グループにcompute.osLoginロールを付与する。Cloud Shellを使ってSSH接続するよう案内する","インスタンスにプロジェクト全体のSSHキーをブロックを有効にする。dev1グループの各ユーザーにSSHキーを生成・配布し、サードパーティツールで接続させる","プロジェクトレベルでdev1グループにcompute.instanceAdminロールを付与する","VPCファイアウォールで22番ポートへのアクセスをdev1グループのIPにのみ許可する"]',
   0, '[0]', 'single',
   '{"asked":"OS Login機能でIAMグループベースのSSHアクセス制御を設定する方法を問う。インスタンスレベルで権限を絞りつつIAMで管理できることを理解しているか。","terms":[["OS Login","IAMロールでLinux VMへのSSHアクセスを管理する機能。メタデータにenable-oslogin=trueを設定することで有効化。鍵の手動管理が不要になる。"],["roles/compute.osLogin","OS Login経由でSSH接続を許可するIAMロール。プロジェクト全体・フォルダ・インスタンスレベルで付与できる。"]],"think":"社員証（IAMロール）でオフィスの特定の部屋（インスタンス）にだけ入れる仕組み。カードキー（SSHキー）の手動配布や管理が不要。インスタンスレベルでロールを付与すれば『この部屋だけ』を実現できる。","vs":"compute.instanceAdminはプロジェクト全体のインスタンスへのアクセス権であり『このインスタンスのみ』という要件に反する。ファイアウォールでIPを絞るのはセキュリティ層が違い、グループ管理と連動しない。","opt":["正解。OS LoginでIAMグループと連動したSSH管理が実現。インスタンスレベルでロールを付与すれば範囲も限定できる。","手動でSSHキーを生成・配布・管理するのは煩雑。IAMグループと連動しないため管理が困難。","instanceAdminはプロジェクト全体のVM操作権限で、特定インスタンスのみへのSSHアクセス制限はできない。","ファイアウォールはIPベースの制御でIAMグループと連動しない。ユーザーのIPが変わると機能しない。"]}'),

  ('m4q26', 'GKE',
   'GKEで自動スケーリングを有効にした新しいアプリをHTTPSのパブリックIPアドレスで公開したい。どうすべきか？',
   NULL::text,
   '["NodePortタイプのKubernetes Serviceを作成し、Cloud Load Balancer経由で公開するKubernetes Ingressを作成する","LoadBalancerタイプのKubernetes Serviceのみを作成する（HTTPS証明書は別途管理）","各ノードのポート443でアプリを公開するNodePort Serviceを作成し、全ノードのIPでDNSを設定する","ClusterIPタイプのServiceを作成し、Cloud Armorで外部アクセスを制御する"]',
   0, '[0]', 'single',
   '{"asked":"GKEでHTTPS外部公開の標準的な方法（Kubernetes Ingress）を理解しているかを問う。","terms":[["Kubernetes Ingress","クラスタ外からのHTTP/HTTPSトラフィックを管理するKubernetesのAPIオブジェクト。SSL終端・URLルーティング・ロードバランシングを一元管理する。GKEではGoogle Cloud Load Balancerが自動作成される。"],["NodePort","各ノードの特定ポートでServiceを公開する方式。外部LBなしでも使えるが、健全性チェックやTLS管理が手動になる。"]],"think":"ビルの受付（Ingress）が来客（HTTPSリクエスト）を適切な部屋（Pod）に案内し、セキュリティチェック（HTTPS）も担当する。NodePortは裏口の番号を教えて直接来てもらう原始的な方法で、管理が大変。","vs":"LoadBalancer Serviceはサービスごとに別々のLBが作られるので複数サービスがある場合にコスト増。Ingressは1つのLBで複数サービスを管理できる。ClusterIPはクラスタ内通信専用で外部からのアクセスは不可。","opt":["正解。IngressがGKEでHTTPS外部公開の標準。Googleが推奨する構成。","LoadBalancer Serviceはサービスごとに別LBが作られ、HTTPS管理も複雑になる。","ノードIPをDNSに直接登録するのはノード追加/削除のたびに手動更新が必要で運用困難。","ClusterIPはクラスタ内通信専用であり外部からのHTTPSアクセスはできない。"]}'),

  ('m4q28', 'IAM・組織ポリシー',
   'GCPプロジェクトに新しい監査担当者を追加する。すべてのプロジェクトリソースの読み取りのみ許可し、変更は不可にしたい。どう権限設定すべきか？',
   NULL::text,
   '["組み込みのProject Viewerプリミティブロール（roles/viewer）を選択し、ユーザーアカウントをメンバーに追加する","読み取り専用権限のカスタムロールを新規作成し、ユーザーアカウントを追加する","組み込みのIAMサービスビューアロールを選択し、ユーザーアカウントを追加する","各リソース（Compute、Storage等）のViewerロールを個別に付与する"]',
   0, '[0]', 'single',
   '{"asked":"GCPの事前定義プリミティブロールで『プロジェクト全体の読み取り専用』に最適なロールを選べるかを問う。","terms":[["roles/viewer（Project Viewer）","プロジェクト内のすべてのリソースに対する読み取り権限を付与するプリミティブロール。リソースの作成・変更・削除は不可。監査員・閲覧者向けの標準ロール。"],["プリミティブロール","GCPに最初から用意された基本ロール（Owner/Editor/Viewer）。Viewerは全リソース閲覧のみ。"]],"think":"会社の決算書（プロジェクト）を見るだけの監査役が必要とするのは『閲覧パス』だけ。GCPにはこれにぴったりの既製品ロール（Project Viewer）がある。カスタムロールは既製品で足りる場合は不要で管理コストが増える。","vs":"サービスビューアという名前の組み込みロールは一般的に存在しない。各リソースのViewerを個別付与は管理が煩雑で、新しいリソースタイプを追加するたびに設定が必要になる。","opt":["正解。既製品のProject Viewerロールで全リソース読み取り専用が最もシンプル。","カスタムロールは既製品で要件を満たす場合は不要。管理オーバーヘッドが増える。","サービスビューアという名前の標準ロールは一般的に存在しない。","リソースごとの個別付与は管理が煩雑。新しいリソースタイプで設定漏れが発生しやすい。"]}'),

  ('m4q31', 'IAM・組織ポリシー',
   '組織はG Suite（現Google Workspace）を使用しており、全ユーザーがG Suiteアカウントを持っている。一部のG SuiteユーザーにGCPプロジェクトのアクセス権を付与したい。どうすべきか？',
   NULL::text,
   '["G SuiteユーザーのアカウントをGCPのIAMポリシーに直接メンバーとして追加し、適切なロールを付与する","GCPコンソールでCloud Identityを有効にする","G Suiteアカウントを別途Googleアカウントに変換する手続きを行う","G Suiteコンソールでcloud-console-users@yourdomain.comというグループにユーザーを追加する"]',
   0, '[0]', 'single',
   '{"asked":"G Suite（Google Workspace）アカウントとGCPのIAMの関係を理解しているかを問う。G SuiteアカウントはそのままGCP IAMで使えることを知っているか。","terms":[["Google Workspace（旧G Suite）","Googleが提供するビジネス向けコラボレーションツールスイート（Gmail、Drive等）。アカウントはGoogleアカウントの一種で、GCPのIAMに直接使用できる。"]],"think":"会社のGoogleアカウント（G Suite）はそのままGCPの入館証として使える。追加手続きは一切不要。GCPのIAMポリシーにGoogleグループやメールアドレスを追加するだけでアクセス権が付与される。","vs":"Cloud Identityは主にG Suiteを持っていない組織がGoogle IDサービスを使うためのもので、既にG Suiteがある場合は不要。変換手続きは存在しない。特定グループ名でGCPアクセスが自動付与される仕組みはない。","opt":["正解。G SuiteアカウントはGoogleアカウントの一種でIAMに直接追加できる。追加手順不要。","Cloud IdentityはG Suiteがない組織向け。G Suite使用中には不要。","G SuiteアカウントをGoogleアカウントに変換する手続きは存在しない。既に同じもの。","特定のグループ名（cloud-console-users等）に追加するだけで自動的にGCPアクセスが付与されることはない。"]}'),

  ('m4q34', '監視・ログ',
   '特定の時刻にGCPのサービスアカウントが作成されたことを確認する必要がある。どうすべきか？',
   NULL::text,
   '["アクティビティログを「Configuration（構成）」カテゴリでフィルタし、リソースタイプを「サービスアカウント」に絞る","アクティビティログを「Configuration」カテゴリでフィルタし、リソースタイプを「Google Project」に絞る","アクティビティログを「Data Access（データアクセス）」カテゴリでフィルタし、リソースタイプを「サービスアカウント」に絞る","Cloud Monitoring（Stackdriver）でサービスアカウント作成のアラートを設定して監視する"]',
   0, '[0]', 'single',
   '{"asked":"Cloud Audit Logsの種類（Admin ActivityとData Access）の違いと、サービスアカウント作成を追跡する正しいログカテゴリを知っているかを問う。","terms":[["Admin Activity logs（管理アクティビティログ）","リソースの設定変更（作成・削除・IAMポリシー変更など）を記録する監査ログ。GCPコンソールの「Configuration（構成）」カテゴリに相当。常時有効。"],["Data Access logs（データアクセスログ）","データの読み書き（BigQueryクエリ実行・GCSファイル読み取りなど）を記録する監査ログ。デフォルトでは無効。"]],"think":"工場の管理台帳には『設備を追加した記録（Admin Activity）』と『製品を移動した記録（Data Access）』がある。サービスアカウントを作成するのは設備追加に相当するので、管理台帳（Admin Activity）のConfiguration（構成）欄を見る。リソースタイプで「サービスアカウント」を指定して絞り込む。","vs":"Data AccessはAPIの呼び出し記録（誰が何のデータを読んだか）であり、アカウント作成（設定変更）とは異なるカテゴリ。Google ProjectリソースタイプはプロジェクトCRUD操作でSA作成とは別。","opt":["正解。Admin Activity（Configuration）＋サービスアカウントリソースタイプが正しい組み合わせ。","カテゴリは正しいがリソースタイプが誤り。Google ProjectはSA作成とは別の操作を指す。","Data AccessはデータへのアクセスログでSA作成（設定変更）の記録ではない。","Monitoringはリアルタイムのメトリクス監視用。過去の特定時刻に作成されたかを確認するのには不向き。"]}'),

  ('m4q36', '運用・CLI',
   '1つの請求先アカウントにリンクされた3つのGCPプロジェクトのうち1つで、Compute Engineの使用に対する予算アラートを設定する必要がある。どうすべきか？',
   NULL::text,
   '["請求先アカウントの管理者であることを確認する。関連する請求先アカウントを選択し、対象プロジェクトに対して予算とアラートを作成する","プロジェクトのオーナーであることを確認する。プロジェクト設定から予算とアラートを直接作成する","プロジェクト管理者であることを確認する。請求先アカウントを選択し、カスタムアラートを作成する","3つのプロジェクトすべての合計コストに対して請求先アカウントレベルで単一の予算を作成する"]',
   0, '[0]', 'single',
   '{"asked":"GCPの予算アラート設定に必要なIAMロール（Billing Account Admin）と操作場所（請求先アカウント）を理解しているかを問う。","terms":[["Billing Account Administrator","請求先アカウントの全管理権限（ユーザー管理・予算設定・プロジェクトリンク）を持つロール。予算設定はこのロールが必要。"],["予算（Budget）","特定の請求先アカウント・プロジェクト・サービスに対してコスト上限を設定し、アラートを送る機能。プロジェクトフィルタで特定プロジェクトのみを対象にできる。"]],"think":"月の食費予算（予算アラート）を管理するのは財布の管理者（Billing Admin）。個々の商品（プロジェクト）の担当者（Project Owner）は財布全体の管理権限を持っていない。予算は『財布（Billing Account）』の設定であり、プロジェクト設定ではない。","vs":"Project OwnerはIAMのオーナーロールで、請求先アカウントの管理権限は含まれない。Project Adminも同様。3プロジェクト合計ではなく、特定の1プロジェクトに絞る要件がある。","opt":["正解。Billing Account AdminがBillingコンソールで特定プロジェクトを対象に予算を設定する唯一の正しい方法。","Project OwnerはBillingコンソールへのアクセス権を持たず、予算設定はできない。","Project AdminというロールはGCPに標準では存在しない上、Billingコンソールへのアクセス権もない。","3プロジェクト合計の予算では1プロジェクト単体の上限管理ができず、要件を満たさない。"]}'),

  ('m4q37', 'コンピュート・VM',
   '96 vCPUを必要とするオンプレミスアプリをGCPに移行する。同様の環境で実行できるようにしたい。どうすべきか？',
   NULL::text,
   '["VMを作成する際にマシンタイプn1-standard-96を指定する","デフォルト設定でVMを作成し、gcloudを使って実行中のインスタンスを96 vCPUに変更する","n1-highcpu-96マシンタイプを指定してVMを作成する","デフォルト設定でVMを起動し、Rightsizing Recommendationsに基づいて徐々に調整する"]',
   0, '[0]', 'single',
   '{"asked":"GCPで96 vCPUを必要とするワークロードに対応するマシンタイプを正しく選べるかを問う。","terms":[["n1-standard-N","バランス型マシンタイプ。vCPU数Nに対してN×3.75GBのメモリ比率。n1-standard-96は96 vCPUと360GBメモリを提供。"],["n1-highcpu-N","高CPU/低メモリ比率のマシンタイプ。vCPU数Nに対してN×0.9GBのメモリ。CPU集約型ワークロード向け。"]],"think":"96人乗りの飛行機（96 vCPU）が必要なら、最初から96人乗りの型（n1-standard-96）を手配する。小型機で出発して途中で拡張するには一旦着陸（停止）が必要で非効率。CPUをほとんど使わないアプリにhighcpuを選ぶのは割高で不適切。","vs":"n1-highcpu-96は96 vCPUを提供するが1 vCPUあたりのメモリが0.9GBと少ない。汎用的な移行にはstandardの方が適切。実行中のVMのvCPU数変更には停止が必要で、初期設定での無駄な手順が発生する。","opt":["正解。最初から適切なマシンタイプを選ぶのが最も効率的。","実行中VMのvCPU変更は停止が必要。デフォルト設定から始めるのは非効率で手順が増える。","highcpuはCPU集約型向け。vCPU数は合っているがメモリ比率が低く汎用的な移行には不適切な場合がある。","Rightsizing Recommendationsは使用量ベースの推奨で、移行初日に96 vCPUの要件が明確な場合は不要なステップ。"]}'),

  ('m4q40', 'ストレージ',
   '1つの地理的ロケーションにデータを保存するコンプライアンス要件がある。最初の30日間は高頻度アクセス、その後は年1回程度のアクセスが想定される。どう設定すべきか？',
   NULL::text,
   '["Regional Storageを選択する。30日後にColdline Storageにアーカイブするバケットライフサイクルルールを追加する","Regional Storageを選択する。30日後にNearline Storageにアーカイブするバケットライフサイクルルールを追加する","Multi-Regional Storageを選択する。30日後にColdline Storageにアーカイブするバケットライフサイクルルールを追加する","Nearline Storageを選択し、ライフサイクルルールなしで運用する"]',
   0, '[0]', 'single',
   '{"asked":"Cloud Storageのストレージクラスの特性（地理的制約・アクセス頻度・コスト）とライフサイクル管理の組み合わせを正しく選べるかを問う。","terms":[["Regional Storage","単一リージョン内にデータを保存。地理的ロケーション制限のコンプライアンス要件を満たす。高頻度アクセス向け。"],["Coldline Storage","年4回未満のアクセス向け。ストレージコストが最も安い。データ取得時にアクセス料金が発生。年1回のアクセスに最適。"],["Nearline Storage","月1回程度のアクセス向け。年1回しかアクセスしない場合はColdlineより割高になる。"],["バケットライフサイクル管理","オブジェクトの作成からの経過日数などの条件に基づいてストレージクラス変更や削除を自動実行する機能。"]],"think":"新鮮な野菜（初月データ）は冷蔵庫（Regional）で保存。長期保存になったら冷凍庫（Coldline）に自動移動するタイマーをセット。年に1回しか取り出さない食材（データ）なら冷凍庫（Coldline）が最安。Nearline（チルド室）は月1回用なので年1回には過剰スペック。","vs":"Nearlineは月1回程度のアクセスに最適化されており、年1回のアクセスにはColdlineの方がコスト効率が高い。Multi-Regionalは複数の地理的ロケーションにデータをレプリケーションするため、単一ロケーション要件に反する。","opt":["正解。単一リージョン（コンプライアンス）＋自動でColdline移行（年1回コスト最適化）の組み合わせ。","Nearlineは月1回程度向けで、年1回アクセスにはColdlineより割高。","Multi-Regionalは複数地理ロケーションへのレプリケーションで、単一ロケーション要件に違反する。","最初の30日は高頻度アクセスなのでNearlineは割高。またライフサイクルなしでは30日後も最適化されない。"]}'),

  ('m4q42', 'GKE',
   '単一のプリエンプティブルノードプールを持つGKEクラスタで、レプリカ数2のDeploymentを作成した。数分後、1つのPodがPending状態のまま。原因を調べるには？',
   NULL::text,
   '["kubectl describe pod [pod名] でPodの詳細と警告イベントを確認する","kubectl describe deployment [deployment名] でDeploymentの詳細とエラーメッセージを確認する","kubectl describe service [service名] でServiceの詳細とエラーメッセージを確認する","kubectl logs [pod名] でPodのコンテナログを確認する"]',
   0, '[0]', 'single',
   '{"asked":"KubernetesのPodがPending状態になる原因を診断する正しいコマンドと、Pendingが示す状態を理解しているかを問う。","terms":[["Pending状態","KubernetesのスケジューラがまだそのPodをノードに配置できていない状態。原因：リソース不足、NodeSelectorと一致するノードがない、プリエンプティブルノードが削除されたなど。"],["kubectl describe pod","PodのSpec・Status・イベント履歴を表示するコマンド。Eventsセクションに''Insufficient memory''や''Preempted''などの診断情報が出力される。"]],"think":"乗客（Pod）が座席（ノード）に着けない理由は、座席（Pod）の予約票（kubectl describe pod）を見るのが最短。電車のダイヤ（Deployment）や改札（Service）では原因はわからない。プリエンプティブルノードが削除されて空きがなくなった場合もdescribe podのEventsに記録される。","vs":"logsはコンテナが起動した後のアプリケーションログ。Pending状態はコンテナが起動前なので、ログ自体が存在しない。Deploymentはレプリカ数の管理、ServiceはトラフィックのルーティングでPendingの根本原因は持たない。","opt":["正解。describe podのEventsセクションにPendingの原因（リソース不足・プリエンプション等）が記録されている。","Deploymentは全体の状態を管理するが、個々のPodがなぜPendingかの詳細は持たない。","Serviceはトラフィックルーティングの抽象化であり、スケジューリング問題の診断には無関係。","Pending状態ではコンテナが起動していないためログは存在しない。logsコマンドは起動後のデバッグに使う。"]}'),

  ('m4q47', 'GKE',
   'GKEクラスタで顧客が任意のコードを実行できるマルチテナント環境を提供している。顧客のPod間の分離を最大化したい。どうすべきか？',
   NULL::text,
   '["GKEサンドボックス（gVisor）を有効にし、顧客のPod仕様にruntimeClassName: gvisorを追加する","Binary Authorizationを使用し、顧客のPodが使用するコンテナイメージのみをホワイトリストに登録する","Container Analysis APIで顧客Podのコンテナイメージの脆弱性を検出する","GKEノードのイメージとしてcos_containerdを選択する"]',
   0, '[0]', 'single',
   '{"asked":"GKEでコンテナ間の実行時分離を最大化するためのgVisor（GKEサンドボックス）を知っているかを問う。","terms":[["gVisor（GKE Sandbox）","Googleが開発したコンテナサンドボックスランタイム。カーネルシステムコールをインターセプトしてホストOSを直接触らせない。通常のLinux名前空間より強固な分離を提供。"],["RuntimeClass","Kubernetesでコンテナのランタイム（gVisorなど）を指定するオブジェクト。Pod仕様でruntimeClassNameを指定して使用。"]],"think":"通常のコンテナは薄いガラスの仕切り（Linux名前空間）で隔てられているだけ。gVisorは分厚い防弾ガラスの仕切り。悪意あるコードがホストOSのシステムコールを直接呼び出すのをブロックするため、他の顧客の環境への影響を大幅に抑制できる。","vs":"Binary Authorizationはデプロイ時の認証制御（何を実行するか）であり、実行時のプロセス間分離ではない。Container Analysisは脆弱性スキャンで分離強化とは別。cos_containerdはデフォルトランタイムで基本的な分離のみ。","opt":["正解。gVisorはサンドボックス化された実行環境でコンテナ間の分離を最大化する。","Binary Authorizationはデプロイの認可制御。実行時の分離を強化するものではない。","Container Analysisは静的な脆弱性スキャン。実行時の動的な分離とは別の概念。","cos_containerdはGKEのデフォルトOSイメージ。gVisorほどの強固な分離は提供しない。"]}'),

  ('m4q48', 'IAM・組織ポリシー',
   'SREがサポートケースを開いた際に、Google Cloudサポートチームからのアクセスリクエストを承認できるようにしたい。Googleが推奨するプラクティスに従いたい。どうすべきか？',
   NULL::text,
   '["SREグループにroles/accessapproval.approverロールを付与する","SREグループにroles/iam.securityAdminロールを付与する","個々のSREユーザーにroles/accessapproval.approverロールを直接付与する","Organization AdministratorにAccess Approvalの管理を一任する"]',
   0, '[0]', 'single',
   '{"asked":"Access Approvalサービスの設定方法と、Googleが推奨するIAMグループ管理のベストプラクティスを組み合わせて理解しているかを問う。","terms":[["Access Approval（アクセス承認）","Googleのサポートエンジニアやエンジニアリングチームが顧客データや設定にアクセスする必要がある際に、顧客側が明示的に承認または拒否できるサービス。"],["roles/accessapproval.approver","Access Approvalリクエストを承認または拒否できるIAMロール。このロールを持つユーザー/グループに承認権限が付与される。"]],"think":"修理業者（Googleサポート）が自宅（顧客のGCPデータ）に入る前に、担当者（SRE）の承認印（Access Approvalリクエスト）が必要な仕組み。グループで管理すれば担当SREが変わっても簡単に入れ替えられる。個人への直接付与は退職時などの管理が手間。","vs":"iam.securityAdminはIAMポリシー全体の変更権限でAccess Approvalとは全く別の機能。個人への直接付与はGoogleの推奨（グループ管理）に反する。Organization Administratorは組織全体の管理者で、SREの日常業務として承認を行うには権限が広すぎる。","opt":["正解。approverロールをSREグループに付与することで、グループメンバーが承認者となり管理も容易。","iam.securityAdminはIAMポリシー変更権限でAccess Approvalの承認とは無関係。","個人への直接付与はGoogle推奨のグループ管理に反する。SREの異動・退職のたびに手動対応が必要になる。","Organization AdminはSRE全員がなるべき権限ではなく、承認権限付与の場所としても適切でない。"]}'
  )

) AS v(source_ref, cat_name, question_text, code, options, correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.cat_name
WHERE s.slug = 'gcp-ace'
ON CONFLICT (subject_id, source_ref) DO NOTHING;
