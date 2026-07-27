-- Set B/C/D: 仕組み系21問の think に因果の背骨を通す（非破壊マージ、既存キー保持）
BEGIN;
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ枝を切っても結果が変わらないのかがカギ。ミニマックス法は、自分は得点が最大に、相手は最小になる手を選び合うと考えて先を読む。読む途中で「この枝を深く調べても、相手（または自分）はすでに分かっているもっと良い手を選ぶので、ここは絶対に選ばれない」と判明することがある。選ばれない枝はいくら読んでも最終判断に影響しないので、そこで打ち切ってよい。これがαβ法。結果はミニマックスと同じまま、無駄読みだけを省くので速くなる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q6';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ木をたくさん作って多数決すると強くなるのかがカギ。1本の決定木は、訓練データのちょっとした偏りに引きずられて過学習しやすく、木ごとに間違え方がバラバラ。少しずつ違うデータと特徴で多数の木を作ると、それぞれの気まぐれな間違いは方向がそろわないので多数決で打ち消し合い、多くの木に共通する本当に効く判断だけが残る。結果、1本より安定して当たる。前の失敗を順番に補うブースティングとは、作り方が逆（並列に作って平均する）。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q13';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ「一番広い余白」で分けるのかがカギ。訓練データを分けるだけなら境界は何本も引けるが、本当に効かせたいのはまだ見ぬデータ。境界を片方のグループすれすれに引くと、新しい点が少しずれただけで反対側と誤判定してしまう。境界を両グループのちょうど真ん中（余白＝マージンが最大）に置けば、新しい点が多少ずれても境界をまたぎにくい。つまりマージンの広さは未知データのズレに対する安全余裕で、広いほど汎化する。だから「一番安全な真ん中」に引く。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q14';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ一方を抑えると他方が増えるのかがカギ。モデルを単純にすると、本質を捉えきれず的を外す誤り（バイアス）が大きくなる。逆に複雑にすると、訓練データのたまたまのブレまで拾ってしまい、データが変わるたび予測が揺れる誤り（バリアンス）が大きくなる。単純さと複雑さは同じつまみの両端なので、片方を減らそうと動かすともう片方が増える。だから最適な複雑さは中間にあり、両者の和が最小になる点を狙う。未学習（バイアス過大）と過学習（バリアンス過大）を一本の軸で捉えた見方。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q15';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜReLUだと勾配が消えにくいのかがカギ。学習の「直してね」の合図（勾配）は、活性化関数の傾きを掛けながら層を伝わる。シグモイドは一番効くところでも傾きが4分の1以下しかなく、層を通るたび合図が縮み、深いと消えてしまう。ReLUはプラス側の傾きがちょうど1なので、掛けても合図が縮まずそのまま奥まで届く。だから深い層でも学習が進む。マイナス側は0にして不要な信号を落とすのも、シンプルさの利点。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q18';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ値のばらつきをそろえると学習が速く安定するのかがカギ。層が重なると、前の層の重みが更新されるたびに次の層へ入る値の分布が大きくずれ、後ろの層は毎回「土台が動く」状態で学び直しを迫られる。各層の入口で値の平均と広がりを一定にそろえておけば、土台が安定して大きな学習率でも発散しにくく、収束が速くなる。目的は入力分布の安定で、ノードを休ませて過学習を抑えるドロップアウトとは狙いが別。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q19';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ近道を足すと深くても学習できるのかがカギ。層を積むほど、「直してね」の合図（勾配）は各層を通るたび掛け算で薄まり、手前まで届かなくなる。入力をそのまま先の層へ足し込む近道があると、合図はその近道を通ってほぼ減らずに手前へ届く。さらに各層は答えそのものではなく、入力からの差分（残差）だけを学べばよくなり、学習が楽になる。だから100層を超える深さでも学習が進む。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q25';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ小モデルが大モデルをまねると性能を保てるのかがカギ。正解ラベルは「猫」か「犬」かの0か1しか教えないが、大モデルの出力は「猫90%・犬8%・きつね2%」のように、どれとどれが似ているかという豊かな情報を含む。小モデルにこの確率つきの判断をまねさせると、正解だけを教えるより多くの手がかりを受け取れるので、小さくても大モデルに近い賢さを持てる。だから性能を保ったまま軽くできる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-b' AND q.source_ref = 'g-kentei-b-q33';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜラベルなしデータが役立つのかがカギ。正解ラベルを付ける作業は高くつくので大量には用意しにくいが、ラベルなしのデータ自体はいくらでも集まる。ラベルなしデータからは「どこにデータの塊があるか（分布の形）」が分かり、境界はデータが薄いすき間に引くのが自然だと当たりがつく。この形の手がかりに、少数の正解ラベルで「どの塊がどのクラスか」を対応づければ、少ないラベルでも精度を上げられる。だから両方を組み合わせる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q12';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ弱いモデルを寄せ集めると強くなるのかがカギ。1つのモデルはそれぞれ違うクセで間違える。多数のモデルの予測を多数決や平均でまとめると、各自の気まぐれな間違いは方向がそろわず打ち消し合い、多くのモデルが共通して捉えた正しい判断だけが残る。だから1つより安定して当たる。ただし全部が同じ間違い方をすると打ち消せないので、モデルどうしをなるべく違う作り方にするのがコツ。バギングやブースティングはこの実現方法の代表。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q17';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ層を増やすとXORが解けるのかがカギ。単純パーセプトロンは1本の直線でしか2グループを分けられない。ところがXORは、まっすぐ1本の線では正解と不正解を分けられない配置になっている。間に中間層を挟むと、まず複数の直線で領域を切り、その結果をさらに組み合わせて曲がった（非線形な）境界を作れる。だから1本の直線では無理だったXORも分けられる。層を重ねて表現力を上げたのが多層パーセプトロン。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q18';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ前の勢いを引き継ぐと速く安定するのかがカギ。ふつうの勾配降下は、谷が細長いと左右の急な斜面で往復し、ジグザグしてなかなか谷底へ進まない。過去の進行方向を「勢い（慣性）」として少しずつ足し込むと、往復する横揺れは毎回向きが逆なので互いに打ち消し合い、逆に谷に沿った進みたい方向は同じ向きが積み重なって加速する。結果、揺れが減って谷底へ速くたどり着く。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q20';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ確率分布として捉えると新しいデータを作れるのかがカギ。ふつうのオートエンコーダは入力を1点の値に圧縮するだけなので、その点の周りがどんなデータに対応するかは保証がなく、適当な点から復元しても意味のある出力になりにくい。VAEは圧縮先を点ではなく「確率的な広がり（分布）」として学ぶので、その分布から新しく点をサンプリングして復元すれば、学習データに似た未知のデータを作り出せる。だから生成に使える。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q24';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ重み付き和としきい値で判断できるのかがカギ。各入力に「効き具合のつまみ（重み）」を掛けて足し合わせると、入力全体を1つの数値に要約できる。その数値がしきい値を超えたら1、超えなければ0を出す。これは実は、重みで決まる1本の境界線のどちら側かを判定していることに等しい。学習では、間違えるたびに重みを少しずつ調整して境界を動かす。こうして直線で2グループを分けるのがパーセプトロン。ニューラルネットの最小単位にあたる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q7';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ「各特徴は独立」とわざわざ単純化するのかがカギ。本来は「単語Aと単語Bが同時に出る確率」まで考えたいが、単語の組み合わせは膨大で、全部の同時確率を正確に求めるには天文学的な量のデータが要る。そこで各特徴は互いに独立と割り切ると、確率を1つずつ求めて掛け合わせるだけで済み、少ないデータと軽い計算で分類できる。この仮定は現実には厳密には成り立たないが、迷惑メール判定などでは実用上とてもよく効く。だから「ナイーブ（単純）」と呼ぶ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q11';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ重みを大きくさせないと過学習が抑えられるのかがカギ。重みが大きいほど、入力のわずかな違いに出力が敏感に反応する。すると訓練データの細かなノイズにまでぴったり合わせにいき、初見のデータで大きく外す（過学習）。学習時に「重みが大きいと罰を与える」項を足しておくと、モデルは誤差を減らすことと重みを小さく保つことを両立させようとし、必要以上に複雑な当てはめを避ける。結果、なめらかで初見に強いモデルになる。L1・L2はこの罰の与え方の違い。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q16';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ最初の値の決め方で学習の進みが変わるのかがカギ。全部の重みを同じ値（たとえば0）にそろえて始めると、どのノードも全く同じ計算をして同じように更新され、いつまでも見分けがつかず学習が進まない。かといって大きすぎる値や小さすぎる値で始めると、層を伝わる信号や勾配がどんどん膨らむ・縮むして、勾配爆発や勾配消失を起こす。だから各層を通っても信号の大きさが保たれるよう、ばらつき具合を計算して初期値を決める（XavierやHeの初期化）。出発点しだいで学習の成否が変わる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q20';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ方向ごとに歩幅を変えると良いのかがカギ。すべての方向で同じ歩幅（学習率）を使うと、勾配が急な方向では大きく動きすぎて行き過ぎ、勾配が緩い方向ではほとんど進まない、という不都合が起きる。RMSPropは各方向について最近の勾配の大きさを覚えておき、よく動く方向は歩幅を自動で小さく、あまり動かない方向は歩幅を相対的に大きくする。こうして方向ごとにちょうどよい歩幅にそろえるので、安定して速く進める。勢いを足すモメンタムと組み合わせたのがAdam。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q22';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ勾配の逆向きに動かすと誤差が減るのかがカギ。勾配とは「重みをどちらへ動かすと誤差が最も増えるか」を指す矢印。誤差を増やす向きが分かるなら、その真逆へ動かせば誤差は最も速く減る。誤差を地形の高さ、重みを位置に見立てると、いま立っている場所の一番急な下り方向へ一歩ずつ進む、坂下りに等しい。一歩の大きさが学習率。これを繰り返して谷底（誤差が小さい重み）へ近づくのが勾配降下法。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q23';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ注意を複数に分けるのかがカギ。1組の注意だけだと、単語どうしの関係を1つの観点でしか見られない。文の中には主語と述語の対応、代名詞が誰を指すか、修飾の関係など、同時に捉えたい関係が何種類もある。注意を複数の頭（ヘッド）に分け、それぞれ別の観点で関係を測らせてから束ねると、多様な関係を並行して捉えられる。だから1つの注意より豊かに文脈を表現できる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q24';
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('think', 'なぜ密なベクトルに変換し、しかもその変換を学習するのかがカギ。単語を「1か所だけ1」のワンホットで表すと、語彙が数万なら数万次元と巨大なうえ、どの単語どうしも距離が等しく意味の近さを全く表せない。埋め込み層は各単語を数百次元程度の詰まったベクトルに変換し、その値をタスクの学習の中で調整する。すると「王と女王」のような意味の近い語が近くに配置され、意味の関係を数値で扱えるようになる。だから後段の処理が賢くなる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'g-kentei-d' AND q.source_ref = 'g-kentei-d-q25';
COMMIT;
