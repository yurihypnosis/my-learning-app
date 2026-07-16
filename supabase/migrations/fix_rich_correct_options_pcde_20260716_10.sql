-- 正解の選択肢から用語の英語表記を落とし、解説側へ移す (GCP PCDE 22問) 2026-07-16
--
-- 正解だけが「権限借用(impersonation)」のように原語を併記して長くなっていた。
-- 英語表記は試験対策として価値があるので捨てず、explanation_data.opt の該当箇所へ移す。
-- 括弧の中身が答えの実質(バーンレートの倍率など)であるものは対象にしていない。
BEGIN;

UPDATE public.questions q
SET options = jsonb_set(q.options, '{0}', to_jsonb(v.correct)),
    explanation_data = jsonb_set(q.explanation_data, '{opt,0}', to_jsonb(v.opt0))
FROM (VALUES

('gcp-pcde-e', 'gcp-pcde-e-q43',
 'VerticalPodAutoscaler を推奨モードで導入し、実際の使用量に基づく推奨値を確認してから反映する',
 '正解。VerticalPodAutoscaler(VPA)の推奨モード(updateMode: off)でまず実際の使用量に基づく提案を確認し、納得した上で requests/limits に反映するのが安全な進め方。'),

('gcp-pcde', 'gcp-pcde-q16',
 'Cloud Build が生成するビルド来歴/アテステーションを使い、出所を検証する。',
 '正解。SLSA provenance(ビルド来歴)で、その成果物がどの経路で作られたかを検証する。'),

('gcp-pcde-c', 'gcp-pcde-c-q17',
 '各リージョンのGKEターゲットを子として参照するマルチターゲットを作り、ステージからそれを参照する',
 '正解。マルチターゲット(multi-target)は複数の子ターゲットへ同時にデプロイし、成否を1つの単位として扱える。'),

('gcp-pcde-c', 'gcp-pcde-c-q7',
 '機密区分にはタグを使ってIAM条件付きアクセスを実現し、コスト配分にはラベルを使って分類する',
 '正解。タグ(Tags)はIAM条件付きアクセスに、ラベル(Labels)は請求レポートでのコスト配分に、それぞれ適した仕組み。'),

('gcp-pcde', 'gcp-pcde-q3',
 'Cloud Foundation Toolkit / エンタープライズ基盤ブループリントを使う。',
 '正解。実績ある Terraform ベースのブループリントを土台にする。'),

('gcp-pcde-g', 'gcp-pcde-g-q37',
 'ログの出力自体を構造化し、テキストの正規表現ではなく特定フィールドの値を条件にする指標へ切り替える',
 '正解。ログをJSON形式の構造化ログにしてフィールドベースの抽出へ切り替えれば、正規表現マッチングの曖昧さに起因する誤カウントを根本から解消できる。'),

('gcp-pcde-d', 'gcp-pcde-d-q1',
 'サービスアカウントの権限借用を使い、Token Creator権限を持つ管理者が一時的な認証情報で操作する',
 '正解。権限借用(impersonation)なら一時的な認証情報で操作でき、キーを持ち出さずに監査証跡付きで高権限の作業ができる。'),

('gcp-pcde-c', 'gcp-pcde-c-q39',
 'Log Analyticsを有効にしたログバケットを作り、保持期間を5年にしてBigQueryへリンクする',
 '正解。Log Analytics とリンク済みデータセット(linked dataset)なら、ストレージを複製せずにSQLクエリと5年間の保持を両立でき、運用負荷も低い。'),

('gcp-pcde-d', 'gcp-pcde-d-q8',
 'Cloud Native Buildpacks を使用し、Dockerfile なしでソースからイメージをビルドする',
 '正解。Buildpacks なら pack CLI や Cloud Build 連携から、Dockerfile なしでベストプラクティスに沿った最適化イメージを自動生成できる。'),

('gcp-pcde-e', 'gcp-pcde-e-q33',
 '複数の条件をAND条件で結合するコンバイナを設定し、両方が同時に満たされた場合のみ発報させる',
 '正解。AND条件のコンバイナ(combiner)を設定すれば、CPU使用率とエラー率の両方が同時にしきい値を超えた場合にのみ発報する。'),

('gcp-pcde-g', 'gcp-pcde-g-q27',
 '社内の開発者が体感するビルドの成功率や、ビルド開始までの待ち時間といった指標',
 '正解。ビルド成功率や待ち時間といった開発者体験(DevEx)に直結する指標は、プラットフォームチームの実際の信頼性を測るSLIとして適切。'),

('gcp-pcde', 'gcp-pcde-q39',
 '最小インスタンス数を設定し、コールドスタートを抑えつつオートスケールさせる。',
 '正解。最小インスタンス数(min instances)で温めつつ、上限まではオートスケールさせる。'),

('gcp-pcde-d', 'gcp-pcde-d-q22',
 '新鮮さを測るSLIを設定する。直近のバッチ完了からの経過時間が許容範囲内かどうかを見る',
 '正解。新鮮さ(freshness)のSLIなら、データがどれだけ最新かというバッチ処理特有のユーザー体験を的確に表せる。'),

('gcp-pcde-e', 'gcp-pcde-e-q44',
 'プリエンプション通知を検知するハンドラを実装し、猶予時間内に処理状態を保存して終了する',
 '正解。プリエンプション通知(termination notice)を受けるハンドラを実装し、猶予時間内に状態を保存すれば、中断されても安全に処理を再開できる。'),

('gcp-pcde-e', 'gcp-pcde-e-q38',
 '通知チャネルの検証により、実際に通知が届く宛先であることを事前に確認する',
 '正解。通知チャネルの検証(verification)は、実際に通知が届く宛先であることを事前に確かめ、緊急時に誰も呼ばれないという事態を防ぐことが目的。'),

('gcp-pcde-c', 'gcp-pcde-c-q19',
 '本番用トリガーにrequire-approvalフラグを設定し、承認者に承認者ロールを付与する',
 '正解。require-approval と Cloud Build Approver ロールの組み合わせが、Cloud Build ネイティブの承認フロー。'),

('gcp-pcde-g', 'gcp-pcde-g-q46',
 'スケールダウンの安定化ウィンドウを適切な長さに設定し、一定期間の推移を見てから縮小させる',
 '正解。スケールダウンの安定化ウィンドウ(stabilization window)を適切に設定すれば、一時的な変動での過度な縮小判断を抑え、スラッシングを防げる。'),

('gcp-pcde-d', 'gcp-pcde-d-q6',
 'リソースマネージャーのタグを使用する。タグはIAM条件や組織ポリシーの条件として参照できる',
 '正解。タグ(tags)はIAM条件や組織ポリシーの条件として参照でき、タグの付与自体にも権限管理があるためアクセス制御の根拠にできる。'),

('gcp-pcde-d', 'gcp-pcde-d-q34',
 '各サービスのログ出力をJSON形式の構造化ログに統一し、共通のフィールドを定義する',
 '正解。severity や trace_id といった共通フィールドを構造化ログとして統一すれば、サービス横断でのフィールドベースの検索・集計が機械的にできる。'),

('gcp-pcde-g', 'gcp-pcde-g-q26',
 'バックプレッシャーを実装し、キューが一定量を超えたら上流にビジー応答を返すか受付を絞る',
 '正解。バックプレッシャー(backpressure)により、下流の処理能力の限界を上流へ明示的に伝え、送信ペースを落としてもらうことでメモリ圧迫を防げる。'),

('gcp-pcde-d', 'gcp-pcde-d-q23',
 '正確性のSLI。レスポンスが期待されるスキーマ・値域を満たしている割合を見る',
 '正解。正確性(correctness)のSLIを足せば、応答はあるが内容が誤っているという、可用性SLIだけでは見逃すケースを検知できる。'),

('gcp-pcde', 'gcp-pcde-q1',
 '組織レベルで組織ポリシーを設定し、フォルダ・プロジェクトに継承させる。',
 '正解。組織(Organization)レベルのポリシーが配下の全体へ継承される。')

) AS v(slug, source_ref, correct, opt0)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = v.slug);

COMMIT;
