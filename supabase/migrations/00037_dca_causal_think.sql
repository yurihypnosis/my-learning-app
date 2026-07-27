-- DCA: 仕組み系5問の think に因果の背骨を通す（非破壊マージ、既存キー保持）
BEGIN;
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ既存タスクは動き続けるのに、新しい割り当てだけ止まるのかがカギ。Swarm は頭脳（マネージャー＝コントロールプレーン）と手足（ワーカー）で役割が分かれている。「どのコンテナをどこで動かすか」を決める判断と、その決定を記録する台帳（Raft）はマネージャー側にある。一方ワーカーは、すでに割り当てられたタスクを自分の手元で実行しているだけ。だからマネージャーが1台きりで止まると、動作中のタスクはワーカー上でそのまま走り続けるが、新しいスケジューリングや障害時の再配置という「判断」ができなくなる。マネージャーを複数（奇数）置けば、1台落ちても残りで判断を続けられる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'dca' AND q.source_ref = 'dca-q1';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜダイジェスト指定なら必ず同じ中身が取れるのかがカギ。ダイジェスト（sha256:...）はイメージの中身そのものから計算したハッシュ値で、中身が1バイトでも変われば必ず別の値になる。つまり「この値＝この中身」が1対1で結びつく。一方タグ（例: v1.2）はただの動かせる貼り紙で、後から別のイメージに貼り替えられる。だから同じタグでも中身が入れ替わることがあり、再現性が要る本番ではダイジェストで固定する。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'dca' AND q.source_ref = 'dca-q10';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜレイヤーに分け、下層を読み取り専用にするのかがカギ。各レイヤーは中身から決まる識別子を持つので、同じ内容のレイヤーは複数のイメージやコンテナで1つを使い回せる（ディスクの節約になり、pull やコンテナ起動も速い）。使い回せるのは下層を誰も書き換えないからで、だから読み取り専用にしてある。コンテナは起動時に一番上へ薄い書き込み可能レイヤーを1枚だけ載せ、変更はそこにだけ書く（コピーオンライト）。おかげで元のイメージは汚れず、多数のコンテナが同じイメージを安全に共有できる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'dca' AND q.source_ref = 'dca-q40';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜコンテナは VM より軽いのかがカギ。VM は各部屋に独自の OS（ゲスト OS）を丸ごと積むので、起動のたびに OS を立ち上げる時間とメモリが要る。コンテナはホストのカーネルを共有し、プロセスを名前空間で隔離しているだけなので、積むべきゲスト OS が無い。だから起動は秒以下、消費するリソースも小さい。ただし裏返しとして、カーネルを共有する以上、カーネルを突く攻撃はコンテナの壁を越えうる。ここが VM ほど分離が強くない理由。「軽さ」と「分離の弱さ」は同じ“カーネル共有”から来る表と裏。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'dca' AND q.source_ref = 'dca-q47';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜどのノードにアクセスしても目的のコンテナに届くのかがカギ。Swarm は公開ポートを ingress という特別なネットワークで全ノードに広げ、各ノードにロードバランサーを置く。クラスタ全体で「どのサービスのタスクがどのノードで動いているか」を共有しているので、タスクを持たないノードが受けても、そのノードが実際に動いているノードへ転送する。だから利用者はどのノードのアドレスを叩いても、コンテナの居場所を知らずにサービスへ到達できる。これがルーティングメッシュ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'dca' AND q.source_ref = 'dca-q62';
COMMIT;
