-- 解説文更新 (2026-06-18)
-- 対象: m2q21, m3q3, m3q16, m2q34, m2q44

UPDATE public.questions
SET explanation = 'Google Workspaceを使っている＝Cloud Identity（IDとグループを管理する基盤）が最初から含まれている。「グループにロールを付与」する設計なら、100人→1000人でも追加設定は人をグループに入れるだけ。MFAもCloud Identityで一括設定可能。×A：Active Directoryへの移行は不必要な複雑さ（既存Google環境が使える）。×C・D：IDフェデレーション＝「別会社の社員証（外部IdP）をそのままGCPに使わせる仕組み」。OktaやAzure ADなど社外IdPが既にある場合に使うものであり、Google Workspaceだけで完結する今回の構成には不要。'
WHERE source_ref = 'm2q21';

UPDATE public.questions
SET explanation = 'Cloud Identity＝Googleのユーザー管理基盤（アカウント作成・グループ・MFAを管理する部門）。登場人物：IdP（Identity Provider）＝「あなたは本物」と証明する側＝会社のSSOシステム。SP（Service Provider）＝証明書を受け取ってサービスを提供する側＝Google。例え：会社の入館証（SSO）を見せれば社食（Google）を使える仕組みを作るのがB。×A：「GoogleをIdP」＝逆向き（GoogleログインをベースにしてSSOが使えなくなる）。×C・D：OAuthは「認可（誰が何のリソースにアクセスできるか）」のプロトコルで、「誰であるかの認証」には使わない。SAMLのみが認証フェデレーションに対応。'
WHERE source_ref = 'm3q3';

UPDATE public.questions
SET explanation = '2つの独立した概念を区別することがカギ。①権限のサポートレベル（supported vs testing）：各権限が本番で安定して使えるかどうかの品質ラベル。「全権限が本番使用に適切」→supported一択。testingはGoogleが将来変更・廃止する可能性があり本番NG。②ロールのステージ（ALPHA/BETA/GA）：ロール全体が組織内でどの開発フェーズかを示すラベル。「最初のバージョンを明確に共有」→ALPHA（「まだ育成中の初版」という宣言）。よくある混同：「本番に使う＝GA」ではない。GAはロールの完成度の話であり、ロールがALPHAでも権限がsupportedなら実際の本番リソースへの操作は安全。'
WHERE source_ref = 'm3q16';

UPDATE public.questions
SET explanation = 'Cloud Run＝「Dockerコンテナごと持ち込んで動かす」。HTTPサーバーとして動く既存コンテナをほぼそのまま移行できる。Cloud Functions＝「関数1つのコードだけ渡す」FaaS。DockerイメージをCloud Functionsに直接デプロイする機能は存在しない。×B：技術的に不可（DockerイメージはFunctionsにデプロイできない）。×C：複雑なマイクロサービス全体を関数単位に書き直す必要があり、最小限の変更での移行に反する。×D：個別に分解する必要があり書き直しが発生。また「オンプレと同じ設定（IPやURL）」はクラウド移行時に必ず変わるので非現実的。'
WHERE source_ref = 'm2q34';

UPDATE public.questions
SET explanation = '3コンポーネント別に最適サービスを選ぶ問題。①FlaskウェブアプリはApp Engine：「PythonのWebフレームワークをコードだけ渡せばGoogleが動かしてくれる」サービス。②APIはCloud Run：DockerでHTTPサーバーを動かすのに最適。③長時間ETLバッチはCloud Tasks＋Cloud Run：Cloud Tasksがスケジューリングし、Cloud RunでJobを実行。判断の根拠：×Cloud Storage（GCS）はHTMLやCSS等の静的ファイルを配信するだけで、Pythonコードの実行は不可（Flaskは動かない）。×Compute Engineはサーバーレスではなく「VMを自分で管理する」形態のため運用コストが高い。'
WHERE source_ref = 'm2q44';
