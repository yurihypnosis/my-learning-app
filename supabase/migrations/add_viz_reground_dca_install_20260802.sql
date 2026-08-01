BEGIN;

-- Installation and Configuration: viz for the two foundational questions
-- (VM vs container architecture, and the 2 kernel features Docker relies on),
-- plus zero-prerequisite grounding for "カーネル" and "デーモン" which are used
-- unexplained across this category.

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object(
  'kid', 'OSの一番奥にあって、CPU・メモリ・ディスクなどハードウェアと直接やり取りする土台のプログラムを「カーネル」と呼ぶ。ふだん使うアプリやコマンドは、全部このカーネルにお願いして動いている。コンテナはホストのカーネルを間借りする、VMは自前のカーネルを丸ごと持つ。だからコンテナは軽い。',
  'terms', '[["カーネル","OSの中心にあって、CPU・メモリ・ディスクなどハードウェアを直接操作する土台のプログラム。アプリは全部これにお願いして動く。"],["コンテナ","ホストのカーネルを共有しながら、名前空間（namespace）とcgroupsで隔離されたプロセス群。軽量・高速起動。"],["仮想マシン（VM）","ハイパーバイザー（VMware・KVM等）の上で独自のカーネルごと動く。完全な隔離だが起動が遅くリソース消費が大きい。"]]'::jsonb,
  'viz', '<svg viewBox="0 0 340 188" xmlns="http://www.w3.org/2000/svg"><text x="83" y="14" font-size="11" fill="#e8eaf0" text-anchor="middle" font-weight="600">仮想マシン(VM)</text><text x="257" y="14" font-size="11" fill="#e8eaf0" text-anchor="middle" font-weight="600">コンテナ</text><rect x="8" y="138" width="150" height="22" rx="4" fill="#1a1e29" stroke="#2a2f3f" stroke-width="1"/><text x="83" y="152" font-size="9" fill="#8892a4" text-anchor="middle">ハードウェア</text><rect x="8" y="112" width="150" height="22" rx="4" fill="#1a1e29" stroke="#2a2f3f" stroke-width="1"/><text x="83" y="126" font-size="9" fill="#8892a4" text-anchor="middle">ハイパーバイザー</text><rect x="8" y="84" width="73" height="24" rx="4" fill="#20263a" stroke="#60a5fa" stroke-width="1"/><text x="44.5" y="95" font-size="8" fill="#60a5fa" text-anchor="middle">ゲストOS</text><text x="44.5" y="105" font-size="7" fill="#8892a4" text-anchor="middle">(独自カーネル)</text><rect x="85" y="84" width="73" height="24" rx="4" fill="#20263a" stroke="#60a5fa" stroke-width="1"/><text x="121.5" y="95" font-size="8" fill="#60a5fa" text-anchor="middle">ゲストOS</text><text x="121.5" y="105" font-size="7" fill="#8892a4" text-anchor="middle">(独自カーネル)</text><rect x="8" y="54" width="73" height="22" rx="4" fill="#232a1f" stroke="#6ab08d" stroke-width="1"/><text x="44.5" y="68" font-size="9" fill="#e8eaf0" text-anchor="middle">アプリA</text><rect x="85" y="54" width="73" height="22" rx="4" fill="#232a1f" stroke="#6ab08d" stroke-width="1"/><text x="121.5" y="68" font-size="9" fill="#e8eaf0" text-anchor="middle">アプリB</text><text x="83" y="178" font-size="9" fill="#c47070" text-anchor="middle">4層 = 起動が重い</text><rect x="182" y="138" width="150" height="22" rx="4" fill="#1a1e29" stroke="#2a2f3f" stroke-width="1"/><text x="257" y="152" font-size="9" fill="#8892a4" text-anchor="middle">ハードウェア</text><rect x="182" y="112" width="150" height="22" rx="4" fill="#1a1e29" stroke="#3b82f6" stroke-width="1"/><text x="257" y="126" font-size="8" fill="#60a5fa" text-anchor="middle">ホストOSのカーネル(共有)</text><rect x="182" y="74" width="73" height="22" rx="4" fill="#232a1f" stroke="#6ab08d" stroke-width="1"/><text x="218.5" y="88" font-size="9" fill="#e8eaf0" text-anchor="middle">コンテナA</text><rect x="259" y="74" width="73" height="22" rx="4" fill="#232a1f" stroke="#6ab08d" stroke-width="1"/><text x="295.5" y="88" font-size="9" fill="#e8eaf0" text-anchor="middle">コンテナB</text><text x="257" y="178" font-size="9" fill="#6ab08d" text-anchor="middle">2層 = 起動が軽い</text></svg>'
)
WHERE q.source_ref = 'dca-q47'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object(
  'kid', 'OSの一番奥にある「カーネル」が持つ機能のうち、コンテナを支えているのが2つ。名前空間が「見える範囲」を分け、cgroupsが「使えるリソース量」を区切る。この2つでコンテナが成り立つ。',
  'viz', '<svg viewBox="0 0 340 158" xmlns="http://www.w3.org/2000/svg"><text x="170" y="14" font-size="10" fill="#e8eaf0" text-anchor="middle" font-weight="600">コンテナを支える2つのカーネル機能</text><rect x="10" y="26" width="150" height="92" rx="4" fill="#1a1e29" stroke="#2a2f3f" stroke-width="1"/><text x="85" y="39" font-size="9" fill="#60a5fa" text-anchor="middle" font-weight="600">名前空間 (Namespaces)</text><text x="85" y="51" font-size="8" fill="#8892a4" text-anchor="middle">＝見える範囲を分ける個室</text><rect x="18" y="60" width="63" height="52" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="49.5" y="76" font-size="8" fill="#e8eaf0" text-anchor="middle">コンテナA</text><text x="49.5" y="88" font-size="7" fill="#8892a4" text-anchor="middle">PID1から</text><text x="49.5" y="98" font-size="7" fill="#8892a4" text-anchor="middle">自分だけ見える</text><rect x="89" y="60" width="63" height="52" rx="4" fill="#20263a" stroke="#3b82f6" stroke-width="1"/><text x="120.5" y="76" font-size="8" fill="#e8eaf0" text-anchor="middle">コンテナB</text><text x="120.5" y="88" font-size="7" fill="#8892a4" text-anchor="middle">PID1から</text><text x="120.5" y="98" font-size="7" fill="#8892a4" text-anchor="middle">自分だけ見える</text><rect x="180" y="26" width="150" height="92" rx="4" fill="#1a1e29" stroke="#2a2f3f" stroke-width="1"/><text x="255" y="39" font-size="9" fill="#c9a04a" text-anchor="middle" font-weight="600">cgroups</text><text x="255" y="51" font-size="8" fill="#8892a4" text-anchor="middle">＝使えるリソース量の上限</text><text x="196" y="63" font-size="7" fill="#8892a4" text-anchor="start">メモリ 512MB上限</text><rect x="196" y="66" width="118" height="10" rx="2" fill="#20263a" stroke="#2a2f3f" stroke-width="1"/><rect x="196" y="66" width="70.8" height="10" rx="2" fill="#c9a04a"/><line x1="314" y1="63" x2="314" y2="79" stroke="#c47070" stroke-width="1.5"/><text x="316" y="75" font-size="7" fill="#c47070" text-anchor="start">上限</text><text x="196" y="89" font-size="7" fill="#8892a4" text-anchor="start">CPU 1.5コア上限</text><rect x="196" y="92" width="118" height="10" rx="2" fill="#20263a" stroke="#2a2f3f" stroke-width="1"/><rect x="196" y="92" width="47.2" height="10" rx="2" fill="#c9a04a"/><line x1="314" y1="89" x2="314" y2="105" stroke="#c47070" stroke-width="1.5"/><text x="316" y="101" font-size="7" fill="#c47070" text-anchor="start">上限</text><text x="170" y="148" font-size="8" fill="#8892a4" text-anchor="middle">どちらもLinuxカーネルの機能。Dockerは魔法を使っていない</text></svg>'
)
WHERE q.source_ref = 'dca-q48'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

-- デーモン（daemon）を初めてその場で言う。q15 は「デーモンを起動させる」設問なので接地の起点に最適。
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object(
  'kid', 'Dockerには裏で常に動き続けている本体のプログラム（デーモン、dockerd）がある。docker のコマンドを打つと、この本体に「これやって」と指示を送っているだけ。デーモンが動いていなければコマンドは何も実行できない。enableで次回起動時からの自動起動をオン、--nowで今すぐ起動、を1コマンドでやる。',
  'terms', '[["デーモン（daemon）","パソコンの裏で常に動き続けているプログラム。dockerd がDockerの本体で、docker コマンドはこのデーモンに指示を送るだけの窓口。"],["systemd","Linuxでデーモンの起動・停止・自動再起動を管理する仕組み。systemctl コマンドで操作する。"]]'::jsonb
)
WHERE q.source_ref = 'dca-q15'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'dca');

COMMIT;
