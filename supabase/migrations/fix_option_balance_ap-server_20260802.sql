BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('ap-server-q14', '["1台でも故障するとデータ全体が失われ、バックアップ等が必須になるため","RAID0は読み書きの速度がRAID1やRAID5より遅いとされるため","RAID0はディスクを1台しか使えないという制約があるとされるため","RAID0は暗号化ができず、セキュリティ上の弱点になるとされるため"]'),
  ('ap-server-q31', '["PKI（公開鍵基盤）","共通鍵暗号方式","ハッシュ関数","ワンタイムパスワード"]'),
  ('ap-server-q36', '["商品情報を別テーブルに切り出し、注文からは商品IDで参照する","注文テーブルの列をすべて削除し、商品テーブルだけで管理する","同じ商品の注文をすべて1行にまとめ、数量の列だけで管理する","商品名と単価を毎回コピーし続け、検索の速さだけを優先する"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

COMMIT;
