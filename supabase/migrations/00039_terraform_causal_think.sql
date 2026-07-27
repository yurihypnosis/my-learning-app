-- Terraform: 仕組み系5問の think に因果の背骨を通す（非破壊マージ、既存キー保持）
BEGIN;
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜTerraformはstateを持つのかがカギ。Terraformが扱うのは「構成に書いた“あるべき姿”」と「クラウド上の“実物”」の2つ。この2つを突き合わせて差分を出すには、どの構成のどのリソースが、クラウド上のどのIDの実物に対応するかを覚えておく台帳が要る。それがstate。台帳が無いと、Terraformは前回自分が作った物を識別できず、次に何を足し・変え・消せばよいかを計算できない。だからstateは、毎回クラウドに問い合わせる代わりの対応表であり、差分計算とドリフト検出の土台になる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'terraform-associate' AND q.source_ref = 'terraform-associate-q9';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ途中の要素を消すと想定外の作り直しが起きるのかがカギ。countで作ったリソースは、stateの中で web[0]・web[1]・web[2] …と番号（インデックス）を住所として記録される。リストの真ん中の要素を消すと、それより後ろの要素の番号が全部1つずつ繰り上がる。するとTerraformは「元の web[2] は消えた、新しい web[1] ができた」と解釈し、実際は同じ物でも破棄と再作成をしてしまう。for_each ならキー（文字列）を住所にするので、途中を消しても他の住所は動かず、この巻き添えが起きない。だから増減するリソースには for_each が安全。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'terraform-associate' AND q.source_ref = 'terraform-associate-q21';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ手動で依存を宣言する必要があるのかがカギ。Terraformは実行順を、構成内の参照から自動で組み立てる。AがBの属性（例: B.id）を使っていれば、「Bを先に作ってからA」と依存グラフに刻まれる。ところが、実際には順序が要るのに参照が現れない関係もある（例: IAM権限が先に無いとリソース作成が失敗するが、構成上は互いを参照していない）。この隠れた依存はグラフに見えないので、Terraformは順序を保証できない。そこで depends_on で「これは先に」と明示的に札を付け、グラフに手で辺を足す。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'terraform-associate' AND q.source_ref = 'terraform-associate-q28';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜロックが要るのかがカギ。applyは、まずstateを読み、次に変更を計算して実行し、最後に新しいstateを書き戻す、という流れで進む。2人が同時にapplyすると、両者が同じ古いstateを読んで別々の変更を書き戻し、後から書いた方が相手の変更を上書きしてしまう。結果、stateが実インフラと食い違って壊れる。ロックは、誰かがapply中は他のapplyを待たせて、この読み書きを1件ずつ順番に行わせる仕組み。だから並行実行による破損を防げる。バックエンドによってはロックを自前で備えている。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'terraform-associate' AND q.source_ref = 'terraform-associate-q35';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ既定のままだとダウンタイムが出るのかがカギ。設定変更で置き換えが必要になると、Terraformは既定で「古いリソースを壊してから新しいリソースを作る」順で動く。この間は一瞬、そのリソースが存在しない空白の時間ができ、サービスが止まる。create_before_destroy を付けると順序が反転し、新しいリソースを先に作って稼働させてから古いものを壊すので、常に動いているリソースが1つ以上あり、無停止で置き換えられる。ただし新旧が一時的に併存するため、名前やポートが重複しない設計が要る。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'terraform-associate-b' AND q.source_ref = 'terraform-associate-b-q23';
COMMIT;
