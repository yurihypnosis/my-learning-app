-- 正解の選択肢に付いた括弧の補足を解説へ移す (GCP PCDE 17問) 2026-07-16
--
-- 正解だけが「(kubectl describe node)」「(本番投入可否レビュー)」「(single pane of glass)」
-- のような補足を抱えて長くなり、内容を知らなくても最長の選択肢を選べば当たる状態だった。
-- 補足は explanation_data.opt へ移し、選択肢は素の主張だけにする。
-- 誤答を水増しして長さを揃えるのではなく、正解から余分を落とす方向で直す。
BEGIN;

UPDATE public.questions q
SET options = jsonb_set(q.options, '{0}', to_jsonb(v.correct)),
    explanation_data = jsonb_set(q.explanation_data, '{opt,0}', to_jsonb(v.opt0))
FROM (VALUES

('gcp-pcde-e', 'gcp-pcde-e-q48',
 '該当ノードのリソース使用状況とノードイベントを確認し、そのノード固有の問題を調べる',
 '正解。1ノードだけ遅いという事実は原因を絞る強い手がかり。kubectl describe node で CPU・メモリ・ディスクの使用状況やイベントを見れば、過負荷・ディスク圧迫・ハードウェア関連の異常といったノード固有の問題を切り分けられる。'),

('gcp-pcde-e', 'gcp-pcde-e-q32',
 'Production Readiness Review の基準を定義し、運用面の整備状況を確認する',
 '正解。Production Readiness Review（本番投入可否レビュー）は、モニタリング・アラート・SLO・オンコール体制まで含めて本番に出してよいかを客観的な基準で判断する仕組み。'),

('gcp-pcde-e', 'gcp-pcde-e-q23',
 '複数リージョン構成に変更し、リージョン障害時にフェイルオーバーできるようにする',
 '正解。リージョン全体の障害に数分で応えるには、別リージョンに稼働可能な系を持つしかない。アクティブ-アクティブなら自動で、アクティブ-パッシブでも迅速に切り替えられる。'),

('gcp-pcde-g', 'gcp-pcde-g-q38',
 '各ツールのデータを共通のダッシュボードへ集約し、単一の入り口から確認できるようにする',
 '正解。single pane of glass（単一の窓）の考え方。各ツールのデータを1つの入り口へ集約すれば、調査のたびに行き来する手間が減る。'),

('gcp-pcde-d', 'gcp-pcde-d-q44',
 '1回で済む初期化処理をリクエストハンドラの外へ移動し、インスタンスの生存期間中に使い回す',
 '正解。リクエストに依存しない初期化はグローバルスコープ（コンテナ起動時）へ出せば1インスタンスにつき1回で済み、以降のリクエストは読み込み済みのモデルを使い回せる。'),

('gcp-pcde-g', 'gcp-pcde-g-q34',
 'Pub/Sub メッセージの属性にトレースコンテキストを載せて伝播させ、両側でトレースを連結する',
 '正解。トレースコンテキストをメッセージ属性（attributes）に載せて渡せば、パブリッシュ側とサブスクライブ側のスパンが親子として連結され、非同期をまたいで追跡できる。'),

('gcp-pcde-d', 'gcp-pcde-d-q36',
 'アラートポリシーにドキュメントを添付し、通知に対応手順へのリンクを含める',
 '正解。Cloud Monitoring のプレイブック（ランブック）機能やアラートポリシーへのドキュメント添付を使い、通知そのものに手順へのリンクを付けておけば、担当者は探す手間なく対応に入れる。'),

('gcp-pcde-e', 'gcp-pcde-e-q13',
 'Cloud Build のビルド構成で artifacts を指定し、成果物を Cloud Storage へ自動アップロードする',
 '正解。artifacts（objects）を指定すれば、テスト結果やカバレッジレポートがビルドごとに Cloud Storage へ自動保存され、後から参照できる。'),

('gcp-pcde-g', 'gcp-pcde-g-q45',
 '日本国内のリージョナルバケットまたは国内デュアルリージョンを選び、国内に閉じつつ冗長性を確保する',
 '正解。asia-northeast1 のようなリージョナル、または国内2リージョンのデュアルリージョンなら、データを日本国内に閉じたままゾーン障害に耐えられる。'),

('gcp-pcde-e', 'gcp-pcde-e-q7',
 'GKE のコスト配分機能を有効化し、Namespace/ラベル単位のコスト内訳を確認する',
 '正解。コストアロケーション機能なら、Namespace やラベル単位で実際の消費量に基づいた内訳を BigQuery や Cloud Billing で確認でき、請求根拠として示せる。'),

('gcp-pcde-e', 'gcp-pcde-e-q10',
 'Cloud Deploy のカナリア分析を構成し、Cloud Monitoring の指標で自動判定させる',
 '正解。deploymentStrategy の canary と Cloud Monitoring の指標を組み合わせれば、しきい値を超えた時点でロールアウトの停止を自動で判断できる。'),

('gcp-pcde-e', 'gcp-pcde-e-q39',
 '全プロジェクト・全サービスで共通の命名規則とラベルを定め、テレメトリ送信時に一貫して付与する',
 '正解。相関付けは送信時の規約でしか実現できない。サービス名・環境名といったリソース属性を組織全体のルールとして先に決め、一貫して付与する。'),

('gcp-pcde-e', 'gcp-pcde-e-q41',
 'コストの内訳を分析し、重要度と利用状況に基づいて優先順位をつけて対応する',
 '正解。どの指標・どのログ・どのプロジェクトが多くを占めているかをまず把握し、重要度と利用状況で優先順位を付ける。計測せずに手を打たないのがDevOpsの流儀。'),

('gcp-pcde-g', 'gcp-pcde-g-q47',
 'Cloud Run の起動時CPUブーストを有効にし、起動時に一時的にCPUを増やして起動時間を短縮する',
 '正解。startup CPU boost は起動フェーズに一時的にCPUを増やす機能で、最小インスタンスを置いてなお残るスパイク時のコールドスタートに直接効く。'),

('gcp-pcde-e', 'gcp-pcde-e-q36',
 'エグゼンプラーをメトリクスに埋め込み、メトリクス値から代表的なトレースへ直接遷移できるようにする',
 '正解。エグゼンプラー（exemplars）はメトリクスの特定の点に代表トレースへの参照を埋め込むので、グラフからスパイクを起こしたその1本へ直接飛べる。'),

('gcp-pcde-g', 'gcp-pcde-g-q10',
 'ビルド構成で高性能なマシンタイプを指定し、CPU/メモリ不足がボトルネックか検証する',
 '正解。E2_HIGHCPU_8 のような高性能なマシンタイプで実行してみることで、スペック不足が本当にボトルネックなのかを切り分けられる。'),

('gcp-pcde-c', 'gcp-pcde-c-q5',
 'リソースのアノテーションcnrm.cloud.google.com/deletion-policyをabandonに設定してから移行元で削除し、移行先で同じマニフェストを適用する',
 '正解。abandon を指定すると、マニフェストを削除しても実リソースは残るため、名前空間をまたいで安全に付け替えられる。')

) AS v(slug, source_ref, correct, opt0)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = v.slug);

-- c-q5 は正解の側にアノテーション名が必須で短くできないため、対になる誤答を同じ密度に揃える
UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}',
  to_jsonb('リソースのアノテーションcnrm.cloud.google.com/deletion-policyをnoneに設定してから、移行元で削除して移行先で再適用する'::text))
WHERE q.source_ref = 'gcp-pcde-c-q5'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'gcp-pcde-c');

COMMIT;
