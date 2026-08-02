BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  ('ap-server-q47', '["待ち時間と処理時間を合計した値","処理時間だけを取り出した値","待ち時間だけを取り出した値","スループットとレスポンスタイムを掛け合わせた値"]'),
  ('ap-server-q59', '["容量を柔軟に融通し合え、複数サーバー構成も組みやすくなるから","共有すると各サーバーの容量が自動的に増えるから","共有すると障害の影響を1台だけに抑えられるから","共有しないとネットワークにつながらないから"]'),
  ('ap-server-q65', '["インフラ管理の一部または全部を事業者に委ねられる","オンプレミスより必ずセキュリティが強固になる","オンプレミスより必ず利用料金が安くなる","インフラの管理はすべて利用者自身が行う必要がある"]')
) AS v(source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

COMMIT;
