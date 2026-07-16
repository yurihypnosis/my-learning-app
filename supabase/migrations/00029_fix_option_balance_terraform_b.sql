-- Set B の字数バランス調整（3問）/ 2026-07-16
-- 自己チェックで正解が単独最長かつ差が10字を超えた3問。具体名を opt へ移し、
-- 誤答側も同じ密度へ揃える。
BEGIN;

-- 既定のバックエンド: ファイル名を opt へ移し、誤答も同密度に
UPDATE public.questions q
SET options = '["既定のローカルバックエンドが使われ、作業ディレクトリにstateファイルが作られる","バックエンドが未設定であるというエラーになり、初期化の時点で実行が中断される","stateは作られず、実行のたびに実インフラを走査して差分が計算される","stateはメモリ上にのみ保持され、プロセスの終了時に破棄される"]'::jsonb,
    explanation_data = jsonb_set(q.explanation_data, '{opt,0}',
      to_jsonb('正解。ローカルバックエンドが既定で使われ、作業ディレクトリの terraform.tfstate に保存される。直前の state は terraform.tfstate.backup に残る。'::text))
WHERE q.source_ref = 'terraform-associate-b-q34'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'terraform-associate-b');

-- CLIワークスペース: 正解から冗長な語を落とす
UPDATE public.questions q
SET options = jsonb_set(q.options, '{0}',
      to_jsonb('ワークスペースごとに別のstateを持ち、terraform.workspace で名前を参照できる'::text))
WHERE q.source_ref = 'terraform-associate-b-q41'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'terraform-associate-b');

-- バックエンドの部分設定: 誤答を同じ密度へ
UPDATE public.questions q
SET options = jsonb_set(q.options, '{1}',
      to_jsonb('backendブロック内で var を参照し、環境ごとの値を変数として渡す'::text))
WHERE q.source_ref = 'terraform-associate-b-q35'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'terraform-associate-b');

COMMIT;
