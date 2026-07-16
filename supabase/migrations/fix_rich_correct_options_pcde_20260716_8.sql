-- 正解の選択肢から列挙と括弧補足を落とす (GCP PCDE バッチ6の8問) 2026-07-16
-- バッチ6で誤答は直したが、正解が具体名を列挙して長いままだったため字数差が残っていた。
-- 列挙と正式名称は opt へ移し、選択肢は素の主張だけにする。
BEGIN;

UPDATE public.questions q
SET options = jsonb_set(q.options, '{0}', to_jsonb(v.correct)),
    explanation_data = jsonb_set(q.explanation_data, '{opt,0}', to_jsonb(v.opt0))
FROM (VALUES

('gcp-pcde-d', 'gcp-pcde-d-q43',
 'nodeSelector・affinity・taint/toleration などのスケジューリング制約の不一致を確認する',
 '正解。CPU・メモリに余裕があるのに Pending なら、まず疑うのは配置制約の不一致。nodeSelector、affinity/anti-affinity、taint に対する toleration の不足を順に確認する。'),

('gcp-pcde-d', 'gcp-pcde-d-q13',
 'ビルドステップの直後にコンテナスキャンを組み込み、深刻度に応じてパイプラインを失敗させる',
 '正解。trivy などのスキャンツール、または Artifact Registry へのプッシュとスキャン待機をビルド直後に挟み、深刻度に応じてパイプラインを落とせば、その時点で止められる。'),

('gcp-pcde-d', 'gcp-pcde-d-q33',
 '正常終了ログのログベース指標に対して、一定時間更新が無いことを検知する不在アラートを設定する',
 '正解。不在アラート(absence alert)は「起きるはずのことが起きていない」を検知できる唯一の形。期待される実行間隔内に指標が更新されなければ発報させる。沈黙は最も発見が遅れる障害。'),

('gcp-pcde-e', 'gcp-pcde-e-q9',
 'ビルドパイプラインで SBOM を自動生成し、脆弱性情報と突き合わせて影響範囲の特定に使う',
 '正解。SBOM(Software Bill of Materials)をビルド時に自動生成し Artifact Analysis 等と連携させれば、新たな脆弱性が公表されたときに影響するイメージを即座に割り出せる。'),

('gcp-pcde-g', 'gcp-pcde-g-q22',
 'SLOをSLAと同値にすると、SLO違反の時点で既に契約違反にも該当し、対応の猶予がない',
 '正解。SLO違反(内部的な許容量の超過)が発生した瞬間に SLA違反(契約違反)にも該当してしまい、気づいてから手を打つ余白が無い。だからSLOはSLAより厳しく置く。'),

('gcp-pcde-g', 'gcp-pcde-g-q28',
 'ログのタイムスタンプ、アラート発報履歴、トレース、チャットの投稿履歴など客観的な記録を突き合わせる',
 '正解。Cloud Logging のタイムスタンプ、Cloud Monitoring のアラート発報履歴、Cloud Trace、チャットの投稿履歴を突き合わせれば、記憶に頼らない正確な時系列になる。'),

('gcp-pcde-g', 'gcp-pcde-g-q30',
 '一時的な不一致が起きうることをアプリ設計とSLI設計の両方へ反映し、必要な箇所だけ別途対応する',
 '正解。結果整合性は設計上の選択なので、アプリ設計とSLI設計の両方へ織り込む。書き込み直後の読み取り(read-after-write)が要る箇所だけ別途手当てする。'),

('gcp-pcde', 'gcp-pcde-q35',
 '稼働時間チェックや合成モニタで、外部から定期的にエンドポイントを検査する。',
 '正解。稼働時間チェック(uptime check)や合成モニタ(synthetic monitor)は外部から能動的にアクセスして応答を確かめるので、ユーザーより先に気づける。')

) AS v(slug, source_ref, correct, opt0)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = v.slug);

COMMIT;
