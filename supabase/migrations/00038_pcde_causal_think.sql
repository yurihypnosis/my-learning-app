-- PCDE: コアSRE概念6問の think に因果の背骨を通す（非破壊マージ、既存キー保持）
BEGIN;
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ「許容できる不調の量」をわざわざ数値にするのかがカギ。SLO を 99.9% と決めると、残りの 0.1% ＝「落としてよい上限」が自動的に決まる。これがエラーバジェット。ポイントは、あいまいだった「信頼性」を、使える残量という具体的な数字に変えたこと。残量があるうちは多少リスクを取って新機能を出してよく、使い切ったら止めて信頼性回復に回す、と客観的に判断できる。だから「速く出したい開発」と「落としたくない運用」の対立が、感情論でなく残高で決着する。99.9% なら 30日で約43分が上限、と量で表せる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'gcp-pcde' AND q.source_ref = 'gcp-pcde-q19';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜトイルを減らすことにこだわるのかがカギ。トイル＝手作業で繰り返す、自動化できるのに人がやっている運用作業。これが厄介なのは、サービスが大きくなると作業量も比例して増える（人手が青天井で要る）、いくらこなしても新しい価値を生まない、そして単調な繰り返しで人が疲弊する、という三重苦だから。だから一度自動化に投資すれば、以後は人手が増えず、空いた時間を信頼性を上げるエンジニアリングに回せる。SRE がトイルに上限（例: 業務の50%まで）を設けるのはこのため。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'gcp-pcde' AND q.source_ref = 'gcp-pcde-q21';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜレイテンシ・トラフィック・エラー・サチュレーションの4つなのかがカギ。この4つは、サービスの状態を別々の角度から漏れなく捉えるよう選ばれている。トラフィックはどれだけ需要が来ているか、レイテンシはその要求にどれだけ速く応えられているか、エラーはどれだけ失敗しているか、サチュレーションはリソースにあとどれだけ余裕があるか（限界が近いか）。需要・速さ・失敗・余力をそろって見れば、たいていの不調はこのどれかに先に現れる。だから膨大な指標を全部見なくても、まずこの4つで全体の健康状態がつかめる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'gcp-pcde' AND q.source_ref = 'gcp-pcde-q22';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ「誰が悪い」を問わない（非難しない）のかがカギ。人を責める文化だと、当事者は失敗を隠したり、事実を控えめに話すようになる。すると本当に何が起きたかの情報が失われ、根本原因にたどり着けず、同じ事故が繰り返される。逆に非難しないと約束すれば、当事者が安心して正直に経緯を語れる。正確な経緯が集まって初めて、穴だった仕組み（分かりにくいUI、足りない安全装置）を直せる。人はミスするものだと前提を置き、個人でなく仕組みで防ぐ、というSREの立場がここに表れている。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'gcp-pcde' AND q.source_ref = 'gcp-pcde-q24';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ速い燃焼と遅い燃焼の2種類を置くのかがカギ。バーンレートはエラーバジェットを食いつぶす速さ。速い燃焼（fast-burn）は短時間で大量に消費する急な障害を狙い、すぐ鳴るようにするが、感度が高いぶん一過性の小さな異常でも鳴りやすい。遅い燃焼（slow-burn）は、1回1回は小さくてもじわじわバジェットを削り続ける劣化を狙う。これは速い方の条件には引っかからず見逃されてしまう。片方だけだと「急な大事故」か「静かな劣化」のどちらかを取りこぼす。だから両方を組み合わせて、速さの違う2種類の危険をどちらも捉える。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'gcp-pcde-c' AND q.source_ref = 'gcp-pcde-c-q22';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜタイムアウトとプール分離が連鎖障害を防ぐのかがカギ。下流サービスが遅れると、それを呼ぶ側のスレッドは応答を待ったまま解放されない。タイムアウトが無いと、待ちスレッドがどんどん溜まってプールを食いつぶし、その上流も応答できなくなる。こうして1つの遅延が上へ上へと連鎖する。タイムアウトを入れれば、一定時間で待つのをやめてスレッドを解放できる。さらに依存先ごとにスレッドプールを分けておけば（バルクヘッド）、遅い依存先が食いつぶすのはその区画だけで済み、他の機能は生き残る。船の隔壁と同じで、浸水を1区画に閉じ込める。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'gcp-pcde-d' AND q.source_ref = 'gcp-pcde-d-q25';
COMMIT;
