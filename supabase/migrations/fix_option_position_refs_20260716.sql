-- 解説の位置参照を解消し、選択肢シャッフルを効かせる (6問) 2026-07-16
--
-- selection.ts の shuffleOptions は、解説の自由文が「選択肢A」のように位置で
-- 選択肢を指している問題をシャッフル対象から外す（入れ替えると本文と食い違うため）。
-- その結果これらの問題だけ DB の並び順のまま出題され、正解位置が固定化していた。
-- 位置参照をやめて内容で指すように書き換え、シャッフルを効かせる。
--
-- 内訳:
--   dca-q1 / dca-q6 / dca-q46 / m5q01 … 実際に「選択肢A」と位置参照していた
--   ctal-ta-a-q17 / m3q38          … CRUDの(C)(R)(U)(D)やプロジェクト名（A）を
--                                     位置参照と誤検知されていた。表記を変えて回避する
BEGIN;

-- CRUD の頭文字が (C)(R)(U)(D) と1文字括弧になっており誤検知。綴りに変える
UPDATE public.questions q
SET explanation_data = jsonb_set(q.explanation_data, '{think}',
  to_jsonb('ノートアプリで「メモを書く(Create)・読む(Read)・直す(Update)・捨てる(Delete)」が全部できるか確かめる。これがCRUD。'::text))
WHERE q.source_ref = 'ctal-ta-a-q17'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'ctal-ta');

-- 「選択肢 A/B/D」→ 内容で指す
UPDATE public.questions q
SET explanation_data = jsonb_set(q.explanation_data, '{vs}',
  to_jsonb('『クラスター全体が停止して管理操作を一切受け付けない』わけではない。ワーカーの自動昇格も、手動で docker node promote しない限り起きない（Swarm は自動で昇格しない）。クラスターが自動解散してコンテナが全削除されることもない。'::text))
WHERE q.source_ref = 'dca-q1'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

-- 「選択肢 A が scale の正しい構文」→ 位置に依存しない書き方へ
UPDATE public.questions q
SET explanation_data = jsonb_set(q.explanation_data, '{vs}',
  to_jsonb('resize / set は存在しないサブコマンド。update --replicas も実際に使えるが、今回問われているのは scale の構文で、service=数値 の形式をとる。'::text))
WHERE q.source_ref = 'dca-q6'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

-- 「正しくないものはどれか」の問題。「選択肢 A」→ その主張の内容で指す
UPDATE public.questions q
SET explanation_data = jsonb_set(q.explanation_data, '{vs}',
  to_jsonb('BuildKit の利点は並列ビルドを可能にすること。『全ステージを必ず順番通りにビルドするため並列ビルドができない』は正反対の説明で、これが「正しくないもの」＝答えにあたる。'::text))
WHERE q.source_ref = 'dca-q46'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

-- 「選択肢Bは過剰装備、選択肢Dは別機能」→ サービス名で指す
UPDATE public.questions q
SET explanation_data = jsonb_set(q.explanation_data, '{vs}',
  to_jsonb('VPCピアリングは対等な2つのVPCを繋げる。共有VPCはホストプロジェクトが所有するVPCを貸し出す。どちらもプライベートIP通信を実現できる。Cloud InterconnectとVPN Gatewayの組み合わせは過剰装備、Cloud NATは全く別の機能。'::text))
WHERE q.source_ref = 'm5q01'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'gcp-ace');

-- プロジェクト名の（A）（B・C）が位置参照と誤検知。役割で書く
UPDATE public.questions q
SET explanation = '複数プロジェクトの統合監視＝Cloud Monitoringワークスペース。ホストとなるプロジェクトの下にワークスペースを作り、そこへ監視対象のプロジェクトを追加する。ロール付与は権限の話で統合ビューの機能ではない。'
WHERE q.source_ref = 'm3q38'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'gcp-ace');

COMMIT;
