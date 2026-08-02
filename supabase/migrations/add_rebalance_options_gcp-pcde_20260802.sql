BEGIN;

-- q44/q45 は正解の選択肢だけが突出して長かったため、意味を変えずに文言を整えて長さを揃える。

UPDATE public.questions
SET options = '["自然言語で「悪化の要因は何か」と尋ね、関連するメトリクスやリソースの変化を手がかりとして提示させ、そこから原因調査を始める起点にする。","メトリクスの解釈はAIの担当外であり、Gemini Cloud Assistの機能はアラートポリシーの閾値設定のみに限定されている、と案内する。","AIに聞く前にまずSLOの基準そのものを緩めて再定義し直し、レイテンシの悪化自体を許容範囲に含めてしまうことにする。","AIが提示した要因候補をそのまま原因として確定し、裏付け調査を行わずに対応チケットの原因欄へそのまま記載する。"]'::jsonb,
    explanation_data = explanation_data || '{"opt":["正解。自然言語で要因の手がかりを尋ね、そこから調査を始めるのがGemini Cloud Assistの使い方。","Gemini Cloud Assistはアラート閾値設定に限定された機能ではなく、メトリクスの解釈も支援する。","悪化の原因を調べる前にSLOの基準そのものを緩めるのは、問題を測定から見えなくするだけで解決していない。","AIが提示するのはあくまで候補であり、裏付けなしに確定原因として記載すると誤った対応につながる。"]}'::jsonb
WHERE source_ref = 'gcp-pcde-q44'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'gcp-pcde');

UPDATE public.questions
SET options = '["トレースのウォーターフォールについて自然言語で「どのスパンが遅延の主要因か」と尋ね、注目すべきスパンを絞り込み、該当スパンを人が詳しく調べる。","トレース分析支援はOpenTelemetryを導入していない環境専用の機能であり、既存のトレーシング基盤とは併用できない、と案内する。","スパンが多すぎる場合はトレース収集自体を停止し、メトリクスとログだけで遅延原因を判断する運用に切り替える。","AIが絞り込んだスパンを見た時点で調査を打ち切り、そのスパンの担当チームへそのまま修正を依頼する。"]'::jsonb,
    explanation_data = explanation_data || '{"opt":["正解。自然言語で主要因スパンを尋ねて絞り込み、そこから先は人が詳細を調べるのが適切な使い方。","Gemini Cloud Assistは既存のOpenTelemetryベースのトレーシング基盤と併用でき、導入有無を問わない機能ではない。","スパンが多いことを理由に収集自体を止めると、遅延箇所を特定する手がかりそのものを失う。","AIによる絞り込みは調査の起点であり、絞り込んだスパンを見ただけで原因を確定するのは早計。"]}'::jsonb
WHERE source_ref = 'gcp-pcde-q45'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'gcp-pcde');

COMMIT;
