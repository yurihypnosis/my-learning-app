-- 正解の選択肢を刈り込む (GCP PCDE 16問) 2026-07-16
--
-- この16問は誤答が実在の設定や現実的な判断で、質としては問題ない。
-- 正解だけが具体例や原語を抱えて長く、そこだけが手がかりになっていた。
-- 具体例は explanation_data.opt へ移し、選択肢は主張だけにする。
BEGIN;

UPDATE public.questions q
SET options = jsonb_set(q.options, '{0}', to_jsonb(v.correct)),
    explanation_data = jsonb_set(q.explanation_data, '{opt,0}', to_jsonb(v.opt0))
FROM (VALUES

-- バーンレート: 倍率と期間の具体値を opt へ（選択肢は「2本立て」という主張だけ残す）
('gcp-pcde-c', 'gcp-pcde-c-q22',
 '短いルックバック期間と高い倍率のfast-burnポリシーと、長いルックバック期間と低い倍率のslow-burnポリシーの2つを作成する',
 '正解。fast-burn(例: ルックバック1時間・倍率10倍)とslow-burn(例: ルックバック24時間・倍率2倍)の2ポリシー構成が、急激な消費と緩やかな消費の両方を検知するGoogle推奨パターン。1本では、早く捕まえれば誤報が増え、誤報を減らせば静かな劣化を見逃す。'),

('gcp-pcde-c', 'gcp-pcde-c-q33',
 '標準的な属性には Semantic Conventions を使い、固有の属性は SetAttributes で追加する',
 '正解。標準的な属性には OpenTelemetry の Semantic Conventions を使い、アプリケーション固有の属性はスパンの SetAttributes メソッドで意味のあるキーバリューとして追加する。観測データは自分ではなくツールが読むため、規約に沿ってこそ横断的な自動解析が効く。'),

('gcp-pcde-c', 'gcp-pcde-c-q13',
 'Podの仕様に break-glass ラベルを true に設定してデプロイし、後で監査ログのイベントを確認する',
 '正解。image-policy.k8s.io/break-glass ラベルを true にすれば例外的に通せる。後から Cloud Audit Logs の breakglass イベントで確認できるため、例外に記録が強制される。統制を壊さずに緊急対応する正規の逃げ道。'),

('gcp-pcde-c', 'gcp-pcde-c-q25',
 'Cloud Armor の Adaptive Protection を有効化し、自動デプロイのプレースホルダールールを設定する',
 '正解。Adaptive Protection を有効化し、evaluateAdaptiveProtectionAutoDeploy() を使うプレースホルダールールを置けば、検知から緩和の配備までが自動で届く。L7攻撃はパターンが動き続けるため、人がルールを書く速度では間に合わない。'),

('gcp-pcde-c', 'gcp-pcde-c-q18',
 '社内用のstandardと公開キャッシュ用のremoteを上流に持つvirtualリポジトリを作り、standardの優先度を高くする',
 '正解。virtual リポジトリが単一のエンドポイントになり、standard の優先度を高くしておけば社内パッケージが優先される。社内名のパッケージを外部から取らせる攻撃を防ぐ形にもなる。'),

('gcp-pcde-c', 'gcp-pcde-c-q1',
 '共有VPCを構成し、ホストプロジェクトにネットワークを置いて各チームをサービスプロジェクトとして接続する',
 '正解。ネットワークチームがホストプロジェクトでファイアウォールとサブネットを一元管理しつつ、各チームは自分のサービスプロジェクトで自由に動ける。統制と速度の分界点を正しく引いた構成。'),

('gcp-pcde-c', 'gcp-pcde-c-q44',
 '定常負荷にはリソースベースCUD、変動ワークロードにはフレキシブルCUDを購入する',
 '正解。us-central1 の定常な N2 にはリソースベースCUDで深い割引を得て、リージョンとマシンタイプをまたぐ変動ワークロードにはフレキシブルCUDを当てる。割引の深さと柔軟性のトレードオフを、ワークロードの性格ごとに使い分ける。'),

('gcp-pcde-c', 'gcp-pcde-c-q37',
 'JSONルートに severity を含め、抽出したトレースIDを logging.googleapis.com/trace に設定する',
 '正解。X-Cloud-Trace-Context ヘッダーから取り出したトレースIDを logging.googleapis.com/trace に入れれば、Cloud Logging が規約どおりに解釈してログとトレースが紐づく。名前が違えばただの文字列にしかならない。'),

('gcp-pcde-c', 'gcp-pcde-c-q50',
 '30日以内に該当イメージを pull または push するスケジュールタスクを作り、継続スキャンの対象に保つ',
 '正解。Artifact Analysis の継続的なスキャンは直近30日以内に触られたイメージが対象。定期的に pull/push しておけば、再ビルドを待たずに最新の脆弱性情報が反映され続ける。検査結果には賞味期限がある。'),

('gcp-pcde-g', 'gcp-pcde-g-q23',
 '合成モニタはトラフィックが無い時間帯でも一貫した検証ができ、RUMは実環境のばらつきを含む体感品質を掴める',
 '正解。両者は相補的。合成モニタリングはトラフィックの有無に関係なく一貫した検証ができ、RUMは実際のユーザーのデバイスや回線のばらつきを含めた体感品質を把握できる。'),

('gcp-pcde-d', 'gcp-pcde-d-q4',
 'VPC Service Controls のサービス境界を構成し、境界外へのAPIアクセスとデータの持ち出しを制限する',
 '正解。権限を正しく持つ者こそ最大の漏えい経路になりうる。VPC Service Controls はIAMとは別の層で境界を引き、正当な権限を持つ内部者による境界外への持ち出しを止める。'),

('gcp-pcde-e', 'gcp-pcde-e-q50',
 'メモリリークをアプリケーションコード内に疑い、ヒーププロファイルなどで調査する',
 '正解。時間経過とともに悪化し続けるメモリ使用量は、確保したメモリが解放されずに蓄積するメモリリークの典型的な症状。まず疑うべき原因として妥当で、ヒーププロファイルで裏を取る。'),

('gcp-pcde-d', 'gcp-pcde-d-q41',
 'しきい値超過が一定時間継続した場合にのみ発報する持続時間を設定する',
 '正解。持続時間(duration)を例えば5分に設定すれば、一瞬だけの変動では発報せず、実際に一定時間続く問題のみを検知できる。誤検知は感度ではなく計測のやり方で直す。'),

('gcp-pcde-e', 'gcp-pcde-e-q3',
 'Cloud Asset Inventory を使用し、特定時点のスナップショットや変更履歴を取得する',
 '正解。Cloud Asset Inventory ならある時点のリソース状態や、その後の変更履歴(タイムライン)を正確かつ網羅的に後から参照できる。監査は後から証明できるかが勝負。'),

('gcp-pcde-d', 'gcp-pcde-d-q27',
 'クライアント側にサーキットブレーカーと指数バックオフを実装し、過負荷の間はリトライを抑制する',
 '正解。指数バックオフにジッターを加えたリトライとサーキットブレーカーの組み合わせで、依存先が過負荷の間は試行そのものを抑える。善意の再試行がそのまま攻撃になり、復旧しかけたサービスを再び潰す。'),

('gcp-pcde-e', 'gcp-pcde-e-q1',
 'Access Context Manager でアクセスレベルを定義し、VPC Service Controls の境界に適用する',
 '正解。デバイスの状態などを条件にしたアクセスレベルを定義し、それを VPC Service Controls の境界へ適用する。ネットワークの内側にいることではなく、誰がどの端末で来たかを信頼の根拠にするのがゼロトラストの発想。')

) AS v(slug, source_ref, correct, opt0)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = v.slug);

COMMIT;
