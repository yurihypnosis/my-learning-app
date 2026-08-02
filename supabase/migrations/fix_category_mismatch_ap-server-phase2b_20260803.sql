-- ap-server 第二期増量: カテゴリ違いの選択肢で消去法が効いてしまう問題を修正(q93,q94)
BEGIN;

UPDATE public.questions
SET options = '["ソルト", "ノンス（nonce）", "チェックサム", "イニシャルベクトル（IV）"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。ソルトは、ハッシュ化の前に付け加える利用者ごとのランダムな値。", "ノンス（nonce）は、主に暗号化通信などで一度きり使われる使い捨ての値で、ハッシュ化のたびに付け加えるソルトとは役割が異なる。", "チェックサムはデータの伝送誤りなどを検出するための値で、パスワードの保護を目的とした仕組みではない。", "イニシャルベクトル（IV）は共通鍵暗号方式の暗号化処理で使われる初期値で、パスワードのハッシュ化に使うソルトとは用途が異なる。"]'::jsonb)
WHERE source_ref = 'ap-server-q93'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

UPDATE public.questions
SET options = '["ワンタイムパスワード（OTP）", "セッションID", "アクセストークン", "APIキー"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。ワンタイムパスワードは、一度きり・または一定時間だけ有効な使い捨てのパスワード。", "セッションIDは、ログイン中の一連のやり取りを識別するためにサーバーが発行する番号で、利用者が入力するパスワードの一種ではない。", "アクセストークンは、APIなどへのアクセス権限を証明するために発行される文字列で、ログイン時に利用者が入力するパスワードとは役割が異なる。", "APIキーは、プログラムがサービスを呼び出す際に使う固定的な識別子で、時間とともに変化する使い捨てのパスワードとは性質が異なる。"]'::jsonb)
WHERE source_ref = 'ap-server-q94'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

COMMIT;