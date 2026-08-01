BEGIN;

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 172" xmlns="http://www.w3.org/2000/svg"><text x="170" y="14" font-size="10" fill="#e8eaf0" text-anchor="middle" font-weight="600">名前空間が分ける「見える範囲」</text><rect x="20" y="32" width="100" height="40" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="70.0" y="49" font-size="9.5" fill="#60a5fa" text-anchor="middle" font-weight="600">PID</text><text x="70.0" y="62" font-size="7.5" fill="#8892a4" text-anchor="middle" font-weight="normal">専用のプロセスID</text><rect x="130" y="32" width="100" height="40" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="180.0" y="49" font-size="9.5" fill="#60a5fa" text-anchor="middle" font-weight="600">NET</text><text x="180.0" y="62" font-size="7.5" fill="#8892a4" text-anchor="middle" font-weight="normal">専用のIP・ポート</text><rect x="240" y="32" width="100" height="40" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="290.0" y="49" font-size="9.5" fill="#60a5fa" text-anchor="middle" font-weight="600">MNT</text><text x="290.0" y="62" font-size="7.5" fill="#8892a4" text-anchor="middle" font-weight="normal">専用のファイルの木</text><rect x="20" y="82" width="100" height="40" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="70.0" y="99" font-size="9.5" fill="#60a5fa" text-anchor="middle" font-weight="600">UTS</text><text x="70.0" y="112" font-size="7.5" fill="#8892a4" text-anchor="middle" font-weight="normal">専用のホスト名</text><rect x="130" y="82" width="100" height="40" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="180.0" y="99" font-size="9.5" fill="#60a5fa" text-anchor="middle" font-weight="600">IPC</text><text x="180.0" y="112" font-size="7.5" fill="#8892a4" text-anchor="middle" font-weight="normal">専用のプロセス間通信</text><rect x="240" y="82" width="100" height="40" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="290.0" y="99" font-size="9.5" fill="#60a5fa" text-anchor="middle" font-weight="600">USER</text><text x="290.0" y="112" font-size="7.5" fill="#8892a4" text-anchor="middle" font-weight="normal">専用のユーザーID</text><text x="170" y="158" font-size="7.5" fill="#8892a4" text-anchor="middle" font-weight="normal">代表的な6種（他にTIME/CGROUPもある）。cgroupsは範囲でなく量を絞る（別物）</text></svg>')
WHERE q.source_ref = 'dca-q64'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

-- 監査で指摘: option 1 の「（どちらも正しい）」が correct_index=0 と矛盾していた。
-- --volumes-from も実在する正しい共有手段だが、この設問では自分で言い切ってしまい
-- 採点と矛盾する見た目になっていたため、自己言及の一言だけを外す。
UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}', to_jsonb('--volumes-from で app1 コンテナを指定する'::text))
WHERE q.source_ref = 'dca-q29'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

COMMIT;
