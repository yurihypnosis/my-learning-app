-- =============================================================
-- 00124_add_point_eg_e_shikaku.sql
-- E資格 Set A/B 全94問に point(決め手)・eg(たとえ) を非破壊マージで追加。
-- explanation-clarity スキルの①②のテコ。既存キーは温存。
-- =============================================================

BEGIN;

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "正方行列限定なら固有値分解、正方でなくても使えるのがSVD。", "eg": "固有値分解は「正方形の切符しか通せない改札」、SVDは「どんな形の切符でも通せる改札」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q1';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "並列で独立に育てて多数決がバギング、前の誤りを次が直すのがブースティング。", "eg": "バギングは「別々の生徒がそれぞれ問題を解いて多数決で答えを決める」、ブースティングは「1人目が間違えた問題を2人目が重点的に復習する」リレー式の勉強。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q10';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "高次元での距離の余裕が低次元では足りず、点が密集してしまう。", "eg": "広い体育館(高次元)に散らばっていた人たちを狭い教室(低次元)に集めると、みんなぎゅうぎゅうになるイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q11';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "次元が増えるほどデータ空間はスカスカになる。", "eg": "1本道(1次元)なら隣人はすぐ見つかるが、広い砂漠(高次元)では隣の人を見つけるのが難しくなる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q12';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "1回だけ分けるのがホールドアウト、k回繰り返して平均するのがk分割交差検証。", "eg": "ホールドアウトは「1回の模試の結果だけで実力を判断する」、k分割交差検証は「何回も模試を受けてその平均で実力を判断する」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q13';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "閾値を動かしたときの真陽性率と偽陽性率の軌跡がROC曲線、その下の面積がAUC。", "eg": "健康診断の「ここから異常とみなす」ラインを厳しくしたり緩くしたりしながら、見逃しと誤検知のバランスがどう変わるかを描いたグラフ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q14';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "複数同時に正解になりうるならクラスごとに独立なシグモイド。", "eg": "多クラス分類は「好きな果物を1つだけ選ぶ」アンケート、マルチラベル分類は「好きな果物に全部チェックを入れる」アンケート。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q15';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "0〜1で正だけがシグモイド、-1〜1で0中心がtanh。", "eg": "シグモイドは「0点〜100点」の成績、tanhは「マイナス50点〜プラス50点」の相対評価。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q16';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "今の場所ではなく、勢いで進んだ先の勾配を見て補正する。", "eg": "自転車で坂を下るとき、今いる場所ではなく「この勢いだと少し先はどんな傾斜か」を予測してブレーキを調整する。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q17';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "累積し続けるとブレーキが強くなりすぎる、移動平均ならブレーキが強くなりすぎない。", "eg": "AdaGradは「これまでの失敗を全部合計して落ち込み続ける」、RMSPropは「最近の失敗だけを気にする」気持ちの切り替えの早さ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q18';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "カーネルの窓を列として並べ直し、畳み込みを行列積の形に変換する。", "eg": "バラバラに置かれた資料を、コピー機にかけやすいように1列に並べ直してからまとめてコピーを取る。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q19';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "n回中k回になる並び方の数(nCk)×各並びの確率、を掛ける。", "eg": "コイン3枚投げて表2枚裏1枚になる組み合わせ(表表裏、表裏表、裏表表)を数え上げて確率を足し合わせる、クジの当たりパターンを数えるのと同じ考え方。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q2';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "層を重ねるたび、受容野は(カーネルサイズ-1)ずつ両端に広がる。", "eg": "望遠鏡のレンズを1枚追加するたびに、見える範囲が少しずつ広がっていくイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q20';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "depth-wiseが空間、point-wiseがチャネル、役割を分けて計算量を減らす。", "eg": "depth-wiseは「各科目ごとに担当の先生が採点する」、point-wiseは「その後で全科目の点数を1人の担任がまとめて総合評価する」、分業で効率化。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q21';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "前向きと後ろ向き2つのRNNの出力を組み合わせる。", "eg": "本を頭から読む人とお尻から読む人、2人の感想を合わせて内容を判断するイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q22';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "入力を1つのベクトルに圧縮するエンコーダと、そこから生成するデコーダの2段構え。", "eg": "エンコーダは「長い話を1枚の要約メモにする」、デコーダは「そのメモを見ながら別の言葉で話し直す」通訳者。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q23';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "位置の情報を埋め込みベクトルに足し算して伝える。", "eg": "番号札を配って、順番がバラバラに処理されても「自分は何番目か」が分かるようにしておく。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q24';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "複数の視点で並列に関係性を学習し、後で結合する。", "eg": "1つの事件を、複数の捜査官がそれぞれ違う角度(目撃証言・防犯カメラ・指紋)から同時に調べて、最後に情報を突き合わせる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q25';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "総当たりがグリッドサーチ、過去の結果を活かすのがベイズ最適化。", "eg": "グリッドサーチは「全部のレシピを試してみる」、ベイズ最適化は「これまで美味しかった組み合わせから次の候補を予想する」料理研究。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q26';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "候補枠を用意せず、各点から直接中心までの距離を予測する。", "eg": "あらかじめ用意したテンプレート(型紙)を当てはめるのではなく、その場その場で「ここが中心にどれだけ近いか」を直接測る。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q27';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "フレームと文字の対応が未知でも、End-to-Endで学習できるようにする。", "eg": "歌詞と歌声のタイミングを1音ずつ手動で合わせなくても、曲全体と歌詞全体を聴かせるだけで自然と対応を学習させる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q28';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "未来を見ずに(Causal)、間隔を広げて(Dilated)少ない層で広い範囲を見る。", "eg": "Causalは「答えを先に見ない」クイズのルール、Dilatedは「1つ飛ばしで席を見渡す」ことで少ない視線移動で教室全体を見渡せる工夫。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q29';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "向きを入れ替えると値が変わる、非対称な指標。", "eg": "「AさんからBさんへの片思い度」と「BさんからAさんへの片思い度」は別の数字、というのに近い非対称性。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q3';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "ノイズを足す過程を学習し、その逆(ノイズを取り除く過程)で生成する。", "eg": "すりガラスに息を吹きかけて曇らせていく様子を覚え、その逆再生(曇りを取り除く)ができれば、真っ白な曇りガラスから絵を浮かび上がらせられる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q30';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "条件を与えて生成を制御するのが条件付きGAN、ペアなしでドメイン変換するのがCycleGAN。", "eg": "条件付きGANは「注文書通りに絵を描く画家」、CycleGANは「見本と完成品のペアが無くても、雰囲気だけを真似して変換できる画家」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q31';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "行動を選ぶActorと評価するCriticを分担させる。", "eg": "Actorは「実際にプレーする選手」、Criticは「その場ですぐアドバイスするコーチ」、二人三脚で上達していく。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q32';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "学習元と学習先でデータの性質が違うために起きる性能低下がドメインシフト。", "eg": "日本の運転免許で海外の右側通行の道を運転すると感覚がズレる、というような「慣れた環境と違う環境」のギャップ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q33';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "同じデータの別バージョンは近く、違うデータは遠くなるように学習する。", "eg": "同じ人の変装前後の写真は「同一人物」と判定し、他人の写真とは「別人」と判定できるように、似顔絵の特徴を掴む練習。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q34';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "モデルが一番迷っているデータを優先してラベル付けを依頼する。", "eg": "テストの復習で、もう完璧に解ける問題ではなく「あやふやな問題」を優先して先生に質問するイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q35';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "Anchor・Positive・Negativeの3つ組で、近づける/遠ざけるを同時に学習する。", "eg": "本人の写真(Anchor)を、別の日に撮った本人の写真(Positive)には似せて、他人の写真(Negative)からは離すように顔認識を鍛える。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q36';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "複数タスクの経験から、新しいタスクにすぐ適応できる初期値を獲得する。", "eg": "色んなスポーツを少しずつ経験してきた人は、新しいスポーツを始めても他の競技のコツを応用してすぐ上達しやすい。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q37';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "複雑なモデルを、局所的または全体的に単純なモデルで近似して説明する。", "eg": "複雑な機械の仕組み全部は分からなくても、「このボタンを押すとこう動く」という部分的な説明書を作るイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q38';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "多数の小さな端末が対象ならクロスデバイス、少数の大きな組織が対象ならクロスサイロ。", "eg": "クロスデバイスは「大人数の生徒が1人1台タブレットで参加する」、クロスサイロは「少数だが大きな学校同士が協力する」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q39';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "Yを知って減ったXの不確実性の量が相互情報量。", "eg": "天気予報(Y)を見て、傘を持っていくか(X)の迷いがどれだけ減ったか、という「情報のありがたみ」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q4';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "1命令で複数データを一斉処理、GPUではスレッド単位でより柔軟に(SIMT)。", "eg": "SIMDは「先生の号令で全員が同じ体操をする」、SIMTは「各生徒が自分のペースで動きつつ、同じ種目のところではタイミングを揃える」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q40';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "ソフトターゲットにはクラス間の似ている度合いの情報が詰まっている。", "eg": "答え合わせで「正解/不正解」だけでなく「どの選択肢に何%くらい迷ったか」まで先生が教えてくれると、生徒はより深く学べる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q41';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "エッジは通信に強いが資源に制約、クラウドは資源は豊富だが通信に依存する。", "eg": "エッジ推論は「その場で自分の頭で考える」、クラウド推論は「電話で専門家に相談する」。電話が繋がらないと専門家には頼れない。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q42';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "絶対値の和がL1ノルム、2乗和の平方根がL2ノルム。", "eg": "L1ノルムは「信号無視せず道なりに歩いた距離」、L2ノルムは「まっすぐ突っ切った距離」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q5';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "対数を取ると掛け算が足し算になり、極端に小さい値も防げる。", "eg": "小さい割合を何度も掛け算していくと電卓の表示が0になってしまうので、対数という「物差しの変換」で扱いやすい数字に直す。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q6';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "ラベル付き・ラベルなし両方使うのが半教師あり学習。", "eg": "答え付きの問題集と、答えのない問題集を両方使って勉強するイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q7';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "誤分類を一切許さないのがハード、多少は許すのがソフト。", "eg": "ハードマージンは「1つの遅刻も許さない」厳しい校則、ソフトマージンは「多少の遅刻には目をつぶる」柔らかい校則。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q8';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "高次元への変換を省略しつつ、その内積だけを直接計算する。", "eg": "海外旅行の話をするのに実際に現地まで行かなくても、写真や換算レートだけで「向こうでの距離感」を計算してしまう裏技。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku-b' AND q.source_ref = 'e-shikaku-b-q9';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "行と列を掛け合わせるなら行列積、同じ場所同士を掛けるだけならアダマール積。", "eg": "行列積は「クラス全員の得点をかけ合わせて総合点を出す」ような集約計算、アダマール積は「同じ日番号の出席と忘れ物チェックをその場でペアで掛ける」ような一対一の計算。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q1';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "まっすぐ測るならユークリッド、道なりに測るならマンハッタン。", "eg": "鳥が飛ぶ最短距離がユークリッド距離、タクシーが信号沿いに走る距離がマンハッタン距離。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q10';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "係数をきっぱり0にしたいならL1、全体を穏やかに縮めたいならL2。", "eg": "L1は「いらない荷物を思い切って捨てる」断捨離、L2は「全部の荷物を少しずつコンパクトに詰め直す」圧縮パッキング。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q11';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "単純すぎるモデルはバイアス大、複雑すぎるモデルはバリアンス大。", "eg": "大雑把すぎる地図はそもそも目的地にたどり着けない(バイアス大)。細かすぎる地図は毎回微妙に違う道を勧めてブレる(バリアンス大)。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q12';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "ロジットが0ならシグモイドの出力はちょうど0.5。", "eg": "天秤がちょうど真ん中でつり合っている状態が、シグモイドのz=0にあたる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q13';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "境界線から一番近いデータまでの余白(マージン)を最大にする。", "eg": "綱引きで、両チームからできるだけ均等に離れた位置に中央の線を引くイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q14';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "1種類だけならGini=0、混ざるほどGiniは大きくなる。", "eg": "福袋の中身が全部同じ商品ならGini=0(お楽しみ度ゼロ)、色んな商品が混ざっているほどGiniは大きい。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q15';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "その主成分の分散を全体の分散で割ったのが寄与率。", "eg": "クラス対抗リレーで、自分の走った区間のタイムが総合タイムの何%を占めるかという割合。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q16';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "グループ数を先に決めるならk-means、後で決められるのは階層的クラスタリング。", "eg": "k-meansは「今日は3チームに分かれます」と先に人数を決める体育の授業、階層的クラスタリングは「まず2人組を作り、それをどんどん合体させて、最後にどこで区切るか決める」フリースタイルの整列。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q17';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "予測した陽性が分母なら適合率、実際の陽性が分母なら再現率。", "eg": "魚釣りで「釣れた魚のうち食べられる魚の割合」が適合率、「池にいた食べられる魚のうち釣れた割合」が再現率。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q18';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "単位行列を掛けると入力はそのまま、あとはバイアスを足すだけ。", "eg": "等倍コピー機(単位行列)でそのままコピーしてから、付箋(バイアス)を1枚貼り足すイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q19';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "行列を掛けても向きが変わらない方向を探すなら固有ベクトル、その伸び率が固有値。", "eg": "鏡の前でTシャツの生地を縦に引っ張ると縦方向にだけ伸びる。その「伸びる向き」が固有ベクトル、「何倍伸びたか」が固有値。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q2';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "連続値の予測はMSE、複数クラスから1つ選ぶならソフトマックス+クロスエントロピー。", "eg": "体重(連続値)の予想はMSEで採点、選択式のテスト(選ぶのは1つ)はクロスエントロピーで採点。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q20';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "グラフが平らな場所を何層も通ると、傾き(勾配)は掛け算でどんどん0に近づく。", "eg": "伝言ゲームで、後ろに行くほど声のボリュームを毎回半分にされていくと、最後には誰にも聞こえなくなる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q21';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "勾配の逆向きに、学習率ぶんだけθを動かす。", "eg": "山を下るとき、傾いている方向の逆(下り坂)へ、歩幅(学習率)ぶんだけ一歩進むイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q22';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "Adam=勢いを覚える(モメンタム)+歩幅を自動調整する(RMSProp)。", "eg": "モメンタムは「勢いのついた自転車」、RMSPropは「デコボコ道で自動調整するサスペンション」、Adamは両方を搭載した自転車。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q23';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "合成関数の微分は、途中の変数を介した掛け算に分解できる。", "eg": "工場の生産ラインで、最終製品の品質のズレの原因を、1つ前の工程、そのまた1つ前の工程…と順番に遡って突き止めるイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q24';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "初期値の大きさが層のユニット数と釣り合っていないと、信号が層を通るたびに膨らむか縮む。", "eg": "バケツリレーで、最初の人が水を入れすぎると溢れ、少なすぎると空になり、最後の人に届く水の量がおかしくなる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q25';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "損失関数に罰金を科すのがL1/L2、ニューロンを間引くのがドロップアウト。", "eg": "L1/L2は「重い荷物には追加料金を取る」宅配便のルール、ドロップアウトは「毎回メンバーの一部を休ませて特定の人に頼りきらないチームを作る」練習方法。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q26';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "検証誤差が上がり始めた瞬間が、学習をやめるサイン。", "eg": "過去問だけをやり込みすぎて本番の初見問題に弱くなる前に、ちょうどいいところで復習を切り上げるイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q27';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "(入力-カーネル+2×パディング)÷ストライド、その後+1。", "eg": "長さ7mの廊下に3m幅の敷物を2mずつずらしながら何回敷けるかを数える計算。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q28';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "窓ごとの最大値を残すのがMax pooling、チャネル全体を1個に集約するのがGAP。", "eg": "Max poolingはクラス対抗で「各班の一番足が速い人」を選ぶ、GAPは「クラス全員のタイムを平均して1つの代表値にする」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q29';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "軸が2つを超えたら、行列ではなくテンソルと呼ぶ。", "eg": "1個の数字はメモ、並んだ数字はリスト、表はノート1ページ、そこに「色」の軸が加わったらノートの束(複数ページの積み重ね)=テンソル。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q3';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "忘れる・取り入れる・出す、を3つのゲートで調整するのがLSTM。", "eg": "LSTMは「いる情報だけ残すノート」。ページをめくるたびに「これは消す、これは書き足す、これは今回使う」と選別する日記帳。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q30';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "自分の文の中だけを見るのがSelf-Attention、相手の文を見にいくのがSource Target Attention。", "eg": "Self-Attentionはクラス内で友達同士が話し合う、Source Target Attentionは通訳者が原文のほうを振り返りながら訳文を作る。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q31';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "ミニバッチをまたいでならすのがBatch Norm、1サンプルの中でならすのがLayer Norm。", "eg": "Batch Normは「クラス全員の今日のテストの点数を基準にならす」、Layer Normは「1人の生徒の全科目の点数を基準にならす」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q32';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "入力をそのまま足す近道があると、勾配が深い層まで届きやすい。", "eg": "高層ビルに非常階段(近道)があれば、エレベーターが遅くても各階に人と情報がすぐ届く。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q33';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "画像をパッチに切り分けてトークンのように扱えば、Transformerにそのまま入力できる。", "eg": "1枚の絵をタイル状に切り分けて、1枚1枚のタイルを「単語」として文章のように読ませるイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q34';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "候補を絞ってから分類が2段階、一気に済ませるのが1段階。", "eg": "Faster R-CNNは「まず怪しい人をリストアップしてから1人ずつ尋問する」警察、YOLOは「会場全体を一度に見渡して、その場で全員をチェックする」監視カメラ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q35';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "一番自信のある枠を残し、それと重なりの大きい枠を消す。", "eg": "同じニュースを伝える速報が何本も出たとき、一番詳しくて信頼できる1本だけ残して、内容が被る他の速報は消す。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q36';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "縮めた側の情報を、拡大する側の同じ解像度に直接橋渡しする。", "eg": "地図を縮小コピーして大まかな道順を覚えた後、拡大コピーに戻すとき、縮小前の元の地図(細かい道)をこっそり参照する。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q37';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "1語から周りを当てるのがskip-gram、周りから1語を当てるのがCBOW。", "eg": "skip-gramは「この単語からどんな仲間の単語が浮かぶ？」という連想ゲーム、CBOWは「周りのヒントから空欄の単語を当てる」穴埋めクイズ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q38';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "文中の単語を隠して、前後両方から埋めさせるのがMLM。", "eg": "歌詞の一部を隠して「ここに入る歌詞は？」と前後の文脈から当てさせる穴埋めクイズ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q39';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "陽性という結果から病気の確率を逆算するときはベイズの定理で事後確率を求める。", "eg": "傘を持っている人が必ず雨予報を見たとは限らない。日傘の可能性もある。「結果(傘)」から「原因(天気)」を逆算するのがベイズの考え方。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q4';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "重みを変えずにプロンプトの例だけで対応できるのがFew-shot learning。", "eg": "新しいバイト先で、マニュアルを読み込む(再学習)のではなく、先輩の実演を数回見ただけでコツをつかむイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q40';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "サンプリング周波数は、記録したい最大周波数の2倍以上必要。", "eg": "観覧車が1周する様子を写真で記録するとき、最低でも半周ごとに1枚は撮らないと、回っているのか止まっているのか分からなくなる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q41';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "フーリエ変換→メル尺度で圧縮→ケプストラムで声色を抽出、の順。", "eg": "オーケストラの音をまず楽器ごとの音の高さに分解し(フーリエ変換)、人間の耳の感度に合わせて聞こえ方を調整し(メル尺度)、最後に「この音色は誰の声か」を抽出する(ケプストラム)。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q42';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "1点に圧縮するだけなら通常のAE、確率分布として学習するのがVAE。", "eg": "通常のAEは「駐車場の1つの決まった枠に車を停める」、VAEは「このあたりに停めてOKという広めのエリアを用意しておく」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q43';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "識別器を騙せる1パターンに偏るのがモード崩壊。", "eg": "モノマネ芸人が「これさえやればウケる」1つのネタばかり繰り返して、レパートリーが増えなくなる状態。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q44';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "経験を貯めてランダムに取り出すことで、時間的な偏りを崩す。", "eg": "毎日同じ順番で単語帳を復習すると偏って覚えるので、カードをシャッフルしてランダムな順で復習する。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q45';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "畳み込み層の勾配を使って、画像のどこに注目したかをヒートマップにする。", "eg": "先生が採点済みのテストに「ここを見て判断した」と蛍光ペンで印をつけてくれるようなもの。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q46';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "枝を切るのがプルーニング、先生の知識を教え込むのが蒸留、数値の細かさを落とすのが量子化。", "eg": "プルーニングは本棚の「読まない本を処分する」、蒸留は「先生の要点ノートを生徒に渡す」、量子化は「高画質動画を圧縮して容量を減らす」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q47';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "モデル自体を分割するのがモデル並列化、コピーを配ってデータを分担するのがデータ並列化。", "eg": "モデル並列化は「1台の大きな機械を分解して各部屋に置く」、データ並列化は「同じ機械のコピーを複数の工場に置いて、違う注文をそれぞれ処理する」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q48';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "データは外に出さず、学習結果だけをサーバーに送って合体させる。", "eg": "みんなが自分のノートは持ち帰ったまま、「今日学んだ要点」だけを黒板に書き出して、クラス全体の知識にまとめる。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q49';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "平均的にどうなるかは期待値、バラつき具合は分散。", "eg": "クラスのテストの平均点が期待値、点数がみんな団子状態かバラバラかを表すのが分散。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q5';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "同じ計算を大量に並列でこなすのがSIMD/SIMT、深層学習の行列演算と相性が良い。", "eg": "工場のベルトコンベアで、同じ作業(命令)を大勢の作業員(データ)が一斉にこなすイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q50';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "カーネルを共有するから軽いのがコンテナ型、丸ごとOSを立てるから重いのがハイパーバイザー型。", "eg": "コンテナ型は「同じアパートの部屋を間借りする」、ハイパーバイザー型は「毎回一戸建てを新築する」。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q51';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "エッジは通信に強いが資源に制約、軽量化とのトレードオフを考える。", "eg": "スマホゲームで、綺麗すぎるグラフィックは動作が重くなるので、画質を少し落として快適さを優先するイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q52';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "データだけで決めるならMLE、事前の予想も混ぜるならMAP推定。", "eg": "新人の実力を今日のテストの点だけで判断するのがMLE、履歴書の経歴も加味して判断するのがMAP推定。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q6';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "五分五分が一番予測しづらい=エントロピー最大。", "eg": "じゃんけんで相手が絶対グーしか出さないなら簡単に勝てる(エントロピー0)。何を出すか全く読めない相手が一番手強い(エントロピー最大)。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q7';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "正解ラベルが0のクラスは掛け算で式から消え、正解クラスの確率だけが残る。", "eg": "通知表で5教科のうち1教科だけ見て褒められるように、他の教科の点は0倍されて自動的に無視される。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q8';

UPDATE public.questions q
SET explanation_data = q.explanation_data || '{"point": "近い順にk個集めて多数決するならk近傍法。", "eg": "知らない街で美味しい店を探すとき、近所の人k人に「どこがおすすめ？」と聞いて多数決するイメージ。"}'::jsonb
FROM public.subjects s
WHERE q.subject_id = s.id AND s.slug = 'e-shikaku' AND q.source_ref = 'e-shikaku-q9';

COMMIT;
