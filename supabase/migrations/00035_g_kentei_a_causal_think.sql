-- Set A パイロット: 仕組み系8問の think に因果の背骨を通す（非破壊マージ、既存キー保持）
BEGIN;
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', '坂を下って最適点を探す学習には、2つの弱点がある。1つ目、ふつうの勾配降下はジグザグして遅い。そこでモメンタム（勢い）が過去の進行方向を引き継いで慣性をつけ、まっすぐ速く進める。2つ目、どの方向も同じ歩幅だと、急な方向で行き過ぎ、緩い方向で進まない。そこでRMSPropが各方向の勾配の大きさを見て歩幅を自動で調整する。Adamはこの「勢い」と「歩幅の自動調整」を両取りしたので、多くの場面で速く安定して収束する。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q20';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ「出口から入口へ」という向きなのかがカギ。各重みを直すには「その重みを少し動かすと最終的な誤差がどれだけ変わるか（勾配）」が要る。ネットワークは入口から出口へ関数を何段も重ねた入れ子構造なので、出口側の誤差から連鎖律で1層ずつ手前へ掛け算していくと、途中の計算を使い回しながら全部の重みの勾配を一度に求められる。前向きに一つずつ求め直すより圧倒的に速い。だから誤差を出口から入口へさかのぼらせる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q21';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜL1だけが重みをちょうど0にできるのかがカギ。正則化は「重みを小さくせよ」という罰を足す仕組み。L2は重みの2乗を罰するので、重みが0に近づくほど引っぱる力も弱まり、0の手前で止まって完全には0にならない。L1は重みの絶対値を罰するので、0のすぐそばでも引っぱる力が一定のまま働き、小さい重みを0まで押し切る。結果、効かない項目の重みが0になって消え、効く項目だけが残る（特徴選択）。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q22';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜランダムに休ませると過学習が減るのかがカギ。全ノードが常にそろっていると、特定のノード同士が「いつも一緒に働く」前提で結託し、訓練データの細かい癖まで一緒に覚え込む。学習のたびに一部を無効化すると、どのノードが居るかが毎回変わるので、少数の相棒に頼れず、一つひとつが単独でも効く特徴を学ぶようになる。さらに毎回違う構成のネットワークを学ぶことになり、それらを平均するような効果（アンサンブル）で初見データに強くなる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q23';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ同じフィルタを画像じゅうで使い回すのかがカギ。「縦線」や「角」といった特徴は、画像のどこに現れても同じ特徴。位置ごとに別々の重みを用意すると、左上の縦線と右下の縦線を別物として学び直すことになり、重みが膨大で非効率になる。1枚のフィルタを全域でスライドさせて使い回せば、場所が変わっても同じ特徴を拾え（位置によらない検出）、覚える重みも激減する。だから畳み込み層は少ないパラメータで効率よく特徴を捉えられる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q24';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ縮めると位置ズレに強くなるのかがカギ。最大値プーリングは、小さな領域の中で「一番強く反応した値」だけを代表として残す。特徴が数ピクセルずれても、その領域の中に入ってさえいれば最大値は変わらないので、出力も変わらない。つまり多少の位置のズレを吸収できる。あわせて縦横のサイズが縮むので計算量も減る。新しい特徴を拾うのではなく、拾った特徴を粗くまとめて安定させるのが役割。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q25';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ門と記憶で勾配消失に対処できるのかがカギ。ふつうのRNNは前の状態に毎回重みを掛け直して伝えるため、長い系列では掛け算が積み重なって「直してね」の合図（勾配）が消え、遠い過去を学べない。LSTMは情報をそのまま通す「記憶（セル）」の通路を持ち、掛け算ではなく足し込みで更新するので合図が薄まりにくい。さらに「門」が何を覚え・忘れ・出すかを調整するので、必要な情報だけ遠くまで届く。だから長い依存関係を学べる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q26';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ競わせると本物そっくりになるのかがカギ。生成器は「識別器をだませたか」だけを手がかりに学ぶ。識別器は本物と偽物を見分けようとどんどん賢くなるので、だますためのハードルが自動的に上がり続ける。生成器はその上がり続ける基準を超えようと改善を迫られ、結果として本物との差が縮まっていく。人が「正解の絵」を用意しなくても、識別器が動く採点者の役をするのがミソ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei' AND q.source_ref = 'g-kentei-q34';
COMMIT;
