-- ap-server 第二期増量: 全問に「たとえ」(eg)を非破壊マージで追加
-- explanation-clarity スキルの①のテコ。既存66問はeg=100%だったが新規54問は1問しか無かった欠落を是正。
BEGIN;

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、3人の見張り番を立てて、全員が同時に居眠りしない限り誰かが必ず気づいてくれる体制。3人とも同時に居眠りする確率はとても低い。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q67';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、1年のうち「お休みしてよい割合」がたった0.1%と決められているイメージ。1年を8760時間の勤務時間だと考えると、その0.1%はわずか9時間弱にしかならない。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q69';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、故障の頻度(MTBF)は変えずに、修理屋さんの腕を上げて直る時間(MTTR)だけを半分にするイメージ。壊れる回数は同じでも、直っている時間が減るぶん稼働率は上がる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q70';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、2人の見張り番(サーバー)を立てても、2人が同じ懐中電灯(電源)を使っていたら、その懐中電灯が壊れたときは2人とも見えなくなる。見張り番を増やす前に、懐中電灯自体の予備も要る。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q71';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、お店を増やす(台数を増やす)以外にも、1つのお店の接客をもっと手早く丁寧にする(壊れにくくする)という方向でも、お客さんを待たせない工夫ができる、というイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q72';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、大事な書類のコピーを1部(RAID5)ではなく2部(RAID6)取っておけば、1部が破れても、もう1部が破れても、まだ元の内容を復元できる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q73';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、6人でお金を出し合って買い物をするとき、そのうち2人分は「もしものときの積立」に回すルール。実際に使えるのは残り4人分のお金。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q74';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、足の速い人たちを2人1組のペアにして手をつながせ(ミラーリング)、複数のペアで同時に走らせる(ストライピング)リレー。速さと安心、両方を手に入れる作戦。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q75';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、8人を2人1組のペア4組に分け、各組が同じ荷物を持ち合うイメージ。実際に運べる荷物の量は、ペアの数である4組ぶんだけ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q76';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、クラスで1人が休んで代わりの助っ人が来たとき、残りの全員が総出でその人に一から仕事を教え込んでいる状態。忙しくバタバタしている間に、もう1人休んだら仕事が回らなくなる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q77';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、大事な手紙を3人がそれぞれ同じ内容で書き写して持っている状態。3人合わせても、伝わる情報の量は1人分の手紙と同じ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q78';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、先生が教室を定期的に見回って「みんな元気ですか」と確認して回るイメージ。具合の悪い生徒(壊れたサーバー)がいたら、その日の日直(振り分け先)から外してあげる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q79';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、レジに並ぶとき「順番に空いているレジへ」ではなく「今いちばん空いているレジへ」案内してくれる店員さんがいるイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q80';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、リレーで走者が転んだ瞬間、控えの選手がすぐにバトンを受け取って走り出す、その切り替えの瞬間そのもの。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q81';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、5人で回している仕事に、念のため6人目を1人だけ待機させておくイメージ。全員分を2倍に増やすよりずっと現実的。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q82';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、いつも同じ店員さんに接客してもらうよう指名するイメージ。違う店員さんに代わるたびに「さっき話した内容」が伝わっていないと困るときに使う。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q83';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、案内係が名簿の順番通りに窓口を教えるだけで、その窓口が本当に開いているかまでは確認してくれないイメージ。閉まっている窓口に案内されてしまうことがある。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q84';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、TCPは配達員が「受け取りました」のサインをもらうまで確認する宅配便、UDPはポストに投函するだけで届いたか確認しない普通郵便。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q85';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、お店に注文書の書き方を間違えて出してしまい、店員さんに「この注文書、書き方がおかしいですよ」と突き返されるイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q86';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、注文の仕方は正しかったのに、お店の厨房でトラブルが起きて料理が作れなくなってしまったイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q87';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、荷物を送るための専用の宅配業者。手元のファイルをサーバーへ送ったり、サーバーからファイルを持ち帰ったりする役目。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q88';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、工場の見回り担当が、各設備の温度計やメーターを定期的にチェックして回るイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q89';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、はがき(HTTP)で送っていた手紙を、封筒に入れて鍵をかけて送る(HTTPS)ようにするイメージ。届く内容は同じでも、途中で誰かに読まれにくくなる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q90';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、貴重品を送るとき、金庫の鍵(共通鍵)を宅配便で届けるのは危ないので、まず金庫の鍵穴だけを相手に渡し(公開鍵暗号方式で共通鍵を送る)、その後の荷物のやり取りは普段の宅配便(共通鍵暗号方式)で済ませるイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q91';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、家に入るのに鍵(知識=パスワード)だけでなく、顔認証(生体)や合言葉が書かれたカード(所持)も両方必要にする、二重三重の玄関。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q92';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、同じレシピ(パスワード)で料理を作っても、隠し味(ソルト)を人ごとに変えれば、同じ味には仕上がらなくなるイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q93';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、その場限りで使い捨てにする合言葉。一度使ったら、次にはもう同じ合言葉は使えない。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q94';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、合言葉そのものを言う代わりに、「今日のお題」に対する答えだけを言うイメージ。お題は毎回変わるので、答えを盗み聞きされても次回は使えない。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q95';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、分厚い契約書そのものに毎回ハンコを押す代わりに、契約書の要約(短いメモ)だけにハンコを押すイメージ。要約なら短時間で済む。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q96';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、注文のたびに「商品名」を手書きで書き写すのをやめて、商品リストという別の台帳を用意し、注文には商品番号だけを書くようにするイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q97';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、住所録に「友人の名前」ではなく「友人の会員番号」だけを書いておき、詳しい情報は会員名簿を見に行くイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q98';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、注文リストと顧客名簿という2冊のノートを、同じ「顧客番号」を目印にして横に並べて見比べるイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q99';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、辞書の索引を見て目的のページへすぐたどり着くイメージ。索引がなければ、最初のページから1枚ずつめくって探すことになる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q100';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、トイレの「使用中」の札。誰かが使っている間は、他の人は外で待つしかない。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q101';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、狭い廊下で向かい合った2人が、お互い「どうぞお先に」と譲り合ったまま、どちらも動けなくなってしまう状態。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q102';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、レストランで「ご注文承りました」と返事が来るまでの時間がレスポンスタイム、実際に料理がテーブルに届くまでの時間がターンアラウンドタイム。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q103';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、1時間に何個の荷物を仕分けられるかを、1秒あたりに直して考えるイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q104';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、レジが空いているうちはすぐ会計できるが、混み始めると行列がどんどん伸びていき、あと少し混むだけで待ち時間が一気に長くなるイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q105';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、1人の料理人をもっと鍛えて速くする(スケールアップ)か、料理人の人数を増やして手分けする(スケールアウト)か、という2つの作戦。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q106';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、新車を売り出す前に試験コースで実際に走らせて、最高速度や燃費を測っておくイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q107';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、レイテンシは1台の車がゴールまで走りきる時間、スループットは1時間にその道を何台の車が通れるかという道路全体の容量。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q108';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、月曜に全部の教科書をコピーしておき、火・水・木は「月曜からの変更点だけ」をそのつどコピーする。木曜のノートを復元したいときは、月曜のコピーと木曜のコピーの2つだけで足りる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q109';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、本番の舞台とまったく同じセットをもう1つ、別の劇場に常に組み立てたまま待機させておくイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q110';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、大事な写真を3枚焼き増しし、そのうち2枚は違う種類のアルバムに入れ、1枚は実家に預けておくイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q111';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、日記を書くたびに、その場ですぐもう1冊の日記にも同じ内容を書き写しているイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q112';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、BCPは「会社全体が災害でもお店を開け続けるための計画」、DRはそのうち「レジのシステムだけを復旧させる担当」というイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q113';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、作業中のノートの内容をまるごと保存せず「さっきからどこが変わったか」だけをメモしておくイメージ。すぐにメモできる。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q114';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、ファイル単位アクセスは「本を1冊ちょうだい」と頼む図書館の貸し出し、ブロック単位アクセスは自分の引き出しに直接手を伸ばして中身を出し入れするイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q115';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、RAIDは「金庫の中身を壊れにくくする仕組み」、NAS・SANは「その金庫をみんなでどう使うかという貸し出しルール」。金庫の中にさらに二重の鍵(RAID)がかかっていることもある。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q116';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、よく読む本は机の上に、たまにしか読まない本は本棚の奥にしまうイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q117';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、大きな水槽を用意しますよと約束しておきながら、実際に水を入れた分だけ水槽の壁を継ぎ足していくイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q118';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、フォルダの階層を掘っていく代わりに、荷物に「宛名タグ」を付けてバーコードで一発検索できる倉庫のイメージ。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q119';

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('eg', 'たとえるなら、1秒間に何回レジを打てるかという回転の速さ。1回あたりの会計金額(スループット)とは別の指標。')
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'ap-server' AND q.source_ref = 'ap-server-q120';

COMMIT;