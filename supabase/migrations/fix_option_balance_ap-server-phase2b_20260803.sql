-- ap-server 第二期増量: 選択肢の長さバランス是正・opt対応ずれ修正(q84,q116,q108,q77,q90,q115)
BEGIN;

UPDATE public.questions
SET options = '["各サーバーの状態を継続的に確認する仕組みを持たないことが多く、故障したサーバーにも振り分けてしまう", "複数のサーバーへリクエストを分散させること自体ができず、実質的に1台構成と変わらない仕組みである", "常に決まった1台のサーバーにしかリクエストが送られず、負荷分散の効果がまったく得られない", "通信内容の暗号化には対応しておらず、DNSの問い合わせ自体を安全に行うことができない"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。DNSラウンドロビンは基本的にサーバーの生死を確認せず、故障したサーバーのIPも教え続けてしまうことがある。", "DNSラウンドロビンも複数のIPアドレスを順番に返すことで、複数サーバーへの分散自体は行え、1台構成と同じではない。", "順番に異なるIPアドレスを返す仕組みなので、常に1台だけに集中し続けるわけではない。", "暗号化通信への対応可否は、DNSによる分散方式そのものとは直接関係しない話である。"]'::jsonb)
WHERE source_ref = 'ap-server-q84'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

UPDATE public.questions
SET options = '["両者は異なるレイヤーの技術であり、SANのストレージ装置内部でRAIDを組む、というように組み合わせて使われることが多い", "RAIDを使うと、NASやSANのような共有ストレージの仕組み自体を併用することが一切できなくなる", "NAS・SANのような共有ストレージを導入すれば、内部の各ディスクをRAIDで冗長化する必要はなくなる", "RAIDとNAS・SANは、名称が違うだけで実際にはまったく同じ役割を担っている仕組みである"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。RAIDとNAS・SANは異なるレイヤーの技術で、SANのストレージ装置内部でRAIDを組む、という組み合わせがよく使われる。", "NAS・SANのストレージ装置内部でRAIDが使われることは珍しくなく、RAIDを使うから共有ストレージが使えなくなるわけではない。", "NAS・SANを導入しても、その内部のディスクが1台だけなら故障時にデータを失うため、RAIDによる冗長化が不要になるわけではない。", "RAID（ディスクの冗長化）とNAS・SAN（共有方式）は目的も仕組みも異なり、同じ役割の呼び方違いではない。"]'::jsonb)
WHERE source_ref = 'ap-server-q116'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

UPDATE public.questions
SET options = '["レイテンシは1件の処理にかかる遅延時間、スループットは単位時間あたりに処理できる件数を表す", "レイテンシとスループットはどちらも同じ意味を表す用語であり、単に言い換えているだけにすぎない", "レイテンシは単位時間あたりの処理件数、スループットは1件あたりの遅延時間を表す用語である", "レイテンシもスループットも、システムが正常に稼働していた時間の割合である稼働率を表す指標である"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。レイテンシは1件あたりの遅延時間、スループットは単位時間あたりの処理件数を表す。", "レイテンシとスループットは、それぞれ「時間」と「件数」という異なる観点の指標であり、同じ意味を表す言い換えではない。", "レイテンシとスループットの説明が入れ替わっている。正しくはレイテンシが時間、スループットが件数を表す。", "稼働率はシステムが正常に動いていた時間の割合を表す、また別の指標であり、レイテンシ・スループットとは異なる。"]'::jsonb)
WHERE source_ref = 'ap-server-q108'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

UPDATE public.questions
SET options = '["残りのディスクへの負荷が高まり、その間にもう1台が故障するとデータを失うリスクが上がる", "リビルド中は残りのディスクへの負荷がむしろ下がるため、特に注意すべきことは何もない", "リビルド中は一時的にRAID5全体の実効容量がむしろ増加し、より多くのデータを保存できるようになる", "リビルドが完了するまでの間は、システムを稼働させたまま利用することは一切できない"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。リビルド中は全ディスクへの読み込み負荷が高まり、その間の追加故障でデータを失うリスクが上がる。", "リビルド中は残りのディスクを総動員してデータを復元するため、負荷はむしろ上がる。", "リビルド中に実効容量が増えることはなく、故障したディスク分はそのまま使えない状態が続く。", "多くのRAID5構成ではリビルド中も稼働を続けたまま使用できるが、その間は性能が低下することが多い。"]'::jsonb)
WHERE source_ref = 'ap-server-q77'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

UPDATE public.questions
SET options = '["通信内容が暗号化されるため、途中で盗み見られても内容が分かりにくくなる", "暗号化処理が入る分、サーバーとの通信速度は常にHTTPより速くなる", "画像や動画といった特定の種類のファイルしかやり取りできなくなる仕様である", "ドメイン名を使った通信ができなくなり、IPアドレスだけで通信するようになる"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。HTTPSはTLSによって通信内容を暗号化し、途中で盗聴されても内容が分かりにくくなる。", "暗号化の処理が挟まる分、HTTPSは一般にHTTPよりわずかにオーバーヘッドがあり、常に速くなるとは言えない。", "HTTPSでもHTMLやテキストなど、HTTPと同じ種類のデータをやり取りできる。", "HTTPSでもHTTPと同様にドメイン名を使って通信でき、IPアドレス専用の通信方式ではない。"]'::jsonb)
WHERE source_ref = 'ap-server-q90'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

UPDATE public.questions
SET options = '["OSからは自分専用のディスクのように扱え、データベースのような細かく高速な読み書きに向く", "複数の利用者が同じフォルダを共有して使うには、ファイル単位アクセスよりも手軽な方式である", "ネットワークを経由したアクセスという形態そのものが技術的に成立しない", "ファイルという概念そのものが、この方式には一切存在しない"]'::jsonb,
    explanation_data = explanation_data || jsonb_build_object('opt', '["正解。ブロック単位アクセスは、OSから自分専用のディスクのように扱え、データベースなど高速な読み書きに向く。", "複数利用者でのファイル共有のしやすさは、むしろファイル単位アクセス（NAS）の強みである。", "SANはネットワーク（専用の高速ネットワーク）を経由してブロック単位アクセスを行う仕組みであり、ネットワーク経由でアクセスできないというのは誤り。", "ブロック単位アクセスでも、OS側でファイルシステムを構築すれば、その上でファイルという概念を扱うことができる。"]'::jsonb)
WHERE source_ref = 'ap-server-q115'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server');

COMMIT;