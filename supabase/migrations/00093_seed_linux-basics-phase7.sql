BEGIN;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('linux-q200', 'よく使うコマンドの覚え方（テキスト処理）',
   '行の内容を並べ替えて表示するコマンド `sort` は、何をそのまま名前にしたコマンドか。',
   NULL::text,
   '["sort（並べ替える）", "search（探す）", "select（選び出す）", "split（分割する）"]',
   0, '[0]', 'single',
   '{"asked":"sortコマンドの名前の由来を問う問題。","why_asked":"一番シンプルな例から「コマンド名は英単語そのままのこともある」という前提を作っておく回。","kid":"sortは行を並べ替えるコマンド。名前も英語の「sort（並べ替える）」をそのまま使っているだけ。","eg":"トランプを数字順に並べ替えることを英語で「sort the cards」と言うのと同じ。コマンドの`sort`も、行という「カード」を順番に並べ替えている。","terms":[["sort","行を指定した順序（数字順・辞書順など）に並べ替えるコマンド"]],"think":"すべてのコマンドが頭字語というわけではない。sortのように、やっていることをそのまま英単語にしただけの名前も多い。まず「そのまま系」の存在を知っておくと、あとの略語系コマンドとの対比がしやすくなる。","vs":"searchやselectと違い、sortは「順番を変える」ことに特化しており、条件で絞り込む機能ではない。","opt":["正解。sortは「並べ替える」という英単語をそのまま名前にしている。","searchは「探す」という意味で、並べ替えではなく検索を連想させる紛らわしい選択肢。","selectは「選び出す」という意味で、並べ替えではなく抽出を連想させる。","splitは「分割する」という意味で、ファイルを分けるコマンドの名前としてありそうだが、並べ替えとは別の操作。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="38" text-anchor="middle" font-size="13" fill="#8892a4">そのまま英単語</text><rect x="120" y="52" width="100" height="32" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="74" text-anchor="middle" font-size="18" font-family="monospace" fill="#e8eaf0">sort</text><text x="170" y="100" text-anchor="middle" font-size="12" fill="#8892a4">= 並べ替える</text></svg>'),

  ('linux-q201', 'よく使うコマンドの覚え方（テキスト処理）',
   '隣り合う重複した行をひとつにまとめるコマンド `uniq` は、英単語のどの部分を短縮した名前か。',
   NULL::text,
   '["unique（唯一の）の最初の4文字", "union（結合）の最初の4文字", "unit（単位）の最初の4文字", "until（〜まで）の最初の4文字"]',
   0, '[0]', 'single',
   '{"asked":"uniqコマンドの名前が何の単語を短縮したものかを問う問題。","why_asked":"英単語の一部を切り取って名前にする、というコマンド名のよくあるパターンを知っておく回。","kid":"uniqは「unique（ユニーク、唯一の）」という英単語の最初の4文字だけを取った名前。重複を1つにまとめるので「唯一のものにする」というイメージ。","eg":"同じ写真が何枚も並んでいるアルバムから、同じものをまとめて1枚だけ残すイメージ。それが「unique（唯一）」にする、というuniqの由来。","terms":[["uniq","隣り合う重複した行をひとつにまとめるコマンド。uniqueの短縮"]],"think":"「uniq」という綴りを見て「unique」の省略だと気づけるかがポイント。英単語の末尾（この場合は`ue`）を落として短くする、という命名パターンはLinuxコマンドによくある。","vs":"unionは「結合」の意味で、複数のものをまとめる点はuniqと似て見えるが、重複を除く操作ではなく集合を合体させる操作を指す言葉。","opt":["正解。uniqueの最初の4文字を取った名前で、重複行を「唯一」にする働きを表す。","unionは「結合」という意味で、重複除去ではなく合体を意味する紛らわしい単語。","unitは「単位」という意味で、行の重複除去とは関係が薄い。","untilは「〜まで」という意味の前置詞で、コマンドの機能とは無関係。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="16" font-family="monospace"><tspan fill="#60a5fa">uniq</tspan><tspan fill="#8892a4">ue</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">最初の4文字だけ使う</text><rect x="130" y="76" width="80" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">uniq</text></svg>'),

  ('linux-q202', 'よく使うコマンドの覚え方（テキスト処理）',
   '行数・単語数・文字数を数えるコマンド `wc` は、何の頭文字を組み合わせた名前か。',
   NULL::text,
   '["word count（単語数）", "write copy（書き写す）", "word compare（単語比較）", "watch count（数を見張る）"]',
   0, '[0]', 'single',
   '{"asked":"wcコマンドの名前が何の頭文字かを問う問題。","why_asked":"2つの単語の頭文字だけを取って名前にする、という別パターンの命名を知っておく回。","kid":"wcは「word count（単語数）」の頭文字を取った名前。単語だけでなく行数・文字数も数えられるが、代表として「単語数」が名前になっている。","eg":"「word count」と検索すると原稿の文字数を数えてくれるツールが出てくるのと同じ発想。wcコマンドもファイルの中の言葉の量を数える道具。","terms":[["wc","ファイルの行数・単語数・文字数を数えるコマンド。word countの頭文字"]],"think":"「w」と「c」という1文字ずつが、それぞれ別の単語の頭文字になっている、という組み合わせ方に気づけるかがポイント。uniqのような「1つの単語の一部を切る」パターンとは違う。","vs":"write copyやwatch countのような紛らわしい候補もあるが、wcが数えるのは「単語」であって「コピー」や「監視」ではない。","opt":["正解。wordの頭文字wと、countの頭文字cを組み合わせた名前。","write copyは「書き写す」という意味で、数を数える機能とは無関係。","word compareは「単語比較」という意味で、数を数えるのではなく比較する操作を連想させる。","watch countは「数を見張る」という意味で、継続的な監視を連想させるが実際のwcは1回だけ数える。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="15" font-family="monospace"><tspan fill="#60a5fa">w</tspan><tspan fill="#8892a4">ord </tspan><tspan fill="#60a5fa">c</tspan><tspan fill="#8892a4">ount</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">頭文字だけ組み合わせる</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">wc</text></svg>'),

  ('linux-q203', 'よく使うコマンドの覚え方（テキスト処理）',
   'ファイルの先頭部分だけを表示するコマンド `head` の名前の由来として最も適切なものはどれか。',
   NULL::text,
   '["head（頭・先頭）という英単語そのまま", "heading（見出し）の省略形", "header（先頭情報）の省略形", "heap（山積み）の言い換え"]',
   0, '[0]', 'single',
   '{"asked":"headコマンドの名前の由来を問う問題。","why_asked":"sortと同じ「そのまま系」の命名パターンを、対になるtailとセットで定着させる回。","kid":"headは「頭・先頭」という意味の英単語をそのまま使った名前。ファイルの先頭（頭）の部分だけを見せてくれる。","eg":"行列の「先頭（head）」に並んでいる人だけを見る、というイメージ。ファイルの中身を行列に見立てると、headは先頭の数行だけを見せてくれる。","terms":[["head","ファイルの先頭部分だけを表示するコマンド"]],"think":"「先頭を見たいならhead」という、英単語の意味とコマンドの動作が完全に一致しているパターン。次のtailと対で覚えると定着しやすい。","vs":"tailと対になる存在で、headは先頭、tailは末尾という逆の役割を持つ。","opt":["正解。headは「頭・先頭」という英単語そのままで、ファイルの先頭部分を表示する。","headingは「見出し」という意味で似ているが、headコマンドの由来としては単語そのものではなく別語の派生形になってしまう。","headerは「先頭情報」という意味で近いが、headコマンドの名前はheaderの省略形ではなく単語headそのもの。","heapは「山積み」という意味で、先頭を見るという機能とは関係が薄い。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="38" text-anchor="middle" font-size="13" fill="#8892a4">そのまま英単語</text><rect x="120" y="52" width="100" height="32" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="74" text-anchor="middle" font-size="18" font-family="monospace" fill="#e8eaf0">head</text><text x="170" y="100" text-anchor="middle" font-size="12" fill="#8892a4">= 先頭を見る</text></svg>'),

  ('linux-q204', 'よく使うコマンドの覚え方（テキスト処理）',
   'ファイルの末尾部分だけを表示するコマンド `tail` の名前の由来として最も適切なものはどれか。',
   NULL::text,
   '["tail（尻尾・末尾）という英単語そのまま", "trail（跡）の省略形", "table（表）の言い換え", "total（合計）の省略形"]',
   0, '[0]', 'single',
   '{"asked":"tailコマンドの名前の由来を問う問題。","why_asked":"headと対になる回。ログの末尾を追いかけたいという実務の場面と結び付けて定着させる。","kid":"tailは「尻尾・末尾」という意味の英単語をそのまま使った名前。ファイルの末尾（お尻）の部分だけを見せてくれる。","eg":"動物の尻尾（tail）が体の末尾にあるのと同じで、tailコマンドはファイルという体の末尾部分を見せてくれる。","terms":[["tail","ファイルの末尾部分だけを表示するコマンド。ログの最新行を追いかける場面でよく使われる"]],"think":"headとセットで「先頭がhead、末尾がtail」と対で覚えると忘れにくい。ログファイルは新しい記録ほど末尾に追加されていくため、最新の状況を知りたいときにtailが役立つ。","vs":"headと対になる存在で、headは先頭、tailは末尾という逆の役割を持つ。","opt":["正解。tailは「尻尾・末尾」という英単語そのままで、ファイルの末尾部分を表示する。","trailは「跡」という意味で似た響きだが、tailコマンドの由来としては別の単語。","tableは「表」という意味で、末尾を見るという機能とは無関係。","totalは「合計」という意味で、末尾を見るという機能とは無関係。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="38" text-anchor="middle" font-size="13" fill="#8892a4">そのまま英単語</text><rect x="120" y="52" width="100" height="32" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="74" text-anchor="middle" font-size="18" font-family="monospace" fill="#e8eaf0">tail</text><text x="170" y="100" text-anchor="middle" font-size="12" fill="#8892a4">= 末尾を見る</text></svg>'),

  ('linux-q205', 'よく使うコマンドの覚え方（テキスト処理）',
   '文章の一部を検索して置き換えるようなコマンド `sed` は、何を組み合わせた名前か。',
   NULL::text,
   '["stream（流れ）とeditor（編集する）を組み合わせた名前", "search（探す）とedit（編集する）を組み合わせた名前", "select（選ぶ）とdelete（削除する）を組み合わせた名前", "send（送る）とedit（編集する）を組み合わせた名前"]',
   0, '[0]', 'single',
   '{"asked":"sedコマンドの名前が何を組み合わせた名前かを問う問題。","why_asked":"「stream editor」という由来を知ると、sedがファイル全体を一度に開いて編集するのではなく、データを流れとして処理する道具だと直感できるようになる。","kid":"sedは「stream（流れ）」の頭文字sと「editor（編集する）」の一部edを組み合わせた名前。データを流れのように読みながら、その場で置き換えていく編集ツール。","eg":"ベルトコンベアの上を流れてくる商品を、止めずに次々とラベル貼り替えしていくイメージ。sedはファイルを一気に開くのではなく、流れてくる行を1行ずつ編集していく。","terms":[["sed","ストリームエディタ。データを流しながらその場で検索・置換などの編集を行うコマンド"],["ストリーム","データが一度に全部そろうのではなく、少しずつ流れてくる形のこと"]],"think":"「stream」+「editor」という由来を知ると、sedがテキストエディタのように画面を開いて操作するのではなく、パイプで流れてくるデータをその場で加工する道具だと分かる。","vs":"searchやeditのような似た響きの英単語と混同しやすいが、sedの正式な由来はstream editorであり、searchという単語は使われていない。","opt":["正解。stream（流れ）の頭文字sと、editor（編集する）の一部edを組み合わせた名前。","searchとeditの組み合わせに見えるが、sedの由来はsearchではなくstreamであり、字面が似ているだけの誤り。","selectとdeleteの組み合わせに見えるが、sedはこの2つの単語とは無関係。","sendとeditの組み合わせに見えるが、sedはこの2つの単語とは無関係。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="14" font-family="monospace"><tspan fill="#60a5fa">s</tspan><tspan fill="#8892a4">tream </tspan><tspan fill="#60a5fa">ed</tspan><tspan fill="#8892a4">itor</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">s + ed を組み合わせる</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">sed</text></svg>'),

  ('linux-q206', 'よく使うコマンドの覚え方（テキスト処理）',
   'テキストを列ごとに処理できるコマンド `awk` の名前の由来として最も適切なものはどれか。',
   NULL::text,
   '["このコマンドを作った3人の開発者の名字の頭文字", "「配列」を意味する英単語の略", "「自動」を意味する英単語の略", "「解析」を意味する英単語の略"]',
   0, '[0]', 'single',
   '{"asked":"awkコマンドの名前の由来を問う問題。","why_asked":"これまでの「英単語の組み合わせ」とは違う、人名由来という珍しいパターンを知っておく回。","kid":"awkは、このコマンドを作った3人の開発者、Aho（エイホ）・Weinberger（ワインバーガー）・Kernighan（カーニハン）の名字の頭文字を並べた名前。英単語ではなく人の名前が由来になっている。","eg":"3人で作った道具に、3人それぞれの頭文字を1文字ずつ持ち寄って名前を付けた、というイメージ。英単語の意味を探しても見つからないのはそのため。","terms":[["awk","開発者Aho・Weinberger・Kernighanの頭文字から付けられた、テキストを列ごとに処理するコマンド"]],"think":"これまでのsort/uniq/wc/head/tail/sedはすべて英単語の意味に由来していたが、awkだけは人名由来という例外パターン。「英単語の略だろう」と決めつけて探すと見つからない、という点を覚えておくと良い。","vs":"「配列」「自動」「解析」のような英単語の略だと思い込みやすいが、awkはそれらの単語とは無関係で、人名の頭文字が由来。","opt":["正解。開発者Aho・Weinberger・Kernighanの3人の名字の頭文字を組み合わせた名前。","「配列」を意味する英単語の略だと推測しやすいが、awkの由来は英単語ではなく人名。","「自動」を意味する英単語の略だと推測しやすいが、awkの由来は英単語ではなく人名。","「解析」を意味する英単語の略だと推測しやすいが、awkの由来は英単語ではなく人名。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="12" font-family="monospace"><tspan fill="#60a5fa">A</tspan><tspan fill="#8892a4">ho </tspan><tspan fill="#60a5fa">W</tspan><tspan fill="#8892a4">einberger </tspan><tspan fill="#60a5fa">K</tspan><tspan fill="#8892a4">ernighan</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">3人の開発者の頭文字</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">awk</text></svg>'),

  ('linux-q207', 'よく使うコマンドの覚え方（ネットワーク）',
   'URLを指定してデータをやり取りするコマンド `curl` の名前の由来として最も適切なものはどれか。',
   NULL::text,
   '["「URLを見る」を表す言葉遊びから付いた名前とされる", "「巻く・丸める」という意味の英単語そのまま", "「通信を暗号化する」という意味の略語", "開発者の出身地の名前"]',
   0, '[0]', 'single',
   '{"asked":"curlコマンドの名前の由来を問う問題。","why_asked":"由来がはっきり1つの単語には決まらない、言葉遊び系の命名パターンがあることを知っておく回。","kid":"curlは「client」と「URL」を組み合わせた名前で、発音すると「シー・ユーアールエル（see URL）」＝「URLを見る」に聞こえる言葉遊びが由来とされている。","eg":"「URLを見に行く道具」という意味を、発音のダジャレに乗せて名付けた、というイメージ。英単語の意味そのものよりも音の響きが由来になっている珍しいパターン。","terms":[["curl","URLを指定してWebサーバーとデータをやり取りするコマンド"]],"think":"curlという綴りには「巻き毛」という意味もあるため紛らわしいが、コマンドの由来はその意味ではなく、client＋URLの組み合わせと「see URL」という発音のダジャレとされている。","vs":"「巻く・丸める」という辞書的な意味のcurlと、コマンド名としてのcurlは同じ綴りでも由来が異なる別の話。","opt":["正解。client（クライアント）とURLを組み合わせ、発音が「see URL」に聞こえることに由来するとされる。","curlという単語自体には「巻く・丸める」という意味もあるが、コマンド名の由来としてはこちらではない。","「通信を暗号化する」という機能を連想させるが、curlという名前自体が暗号化を意味する略語ではない。","開発者の出身地の名前だと推測しやすいが、curlの由来は地名ではない。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="38" text-anchor="middle" font-size="13" fill="#8892a4">client + URL の言葉遊び</text><rect x="120" y="52" width="100" height="32" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="74" text-anchor="middle" font-size="18" font-family="monospace" fill="#e8eaf0">curl</text><text x="170" y="100" text-anchor="middle" font-size="12" fill="#8892a4">発音 ≒ 「see URL」</text></svg>'),

  ('linux-q208', 'よく使うコマンドの覚え方（ネットワーク）',
   '指定したURLからファイルをダウンロードするコマンド `wget` は、何を組み合わせた名前か。',
   NULL::text,
   '["web（ウェブ）とget（取ってくる）を組み合わせた名前", "wide（広い）とget（取ってくる）を組み合わせた名前", "web（ウェブ）とgate（門）を組み合わせた名前", "write（書く）とget（取ってくる）を組み合わせた名前"]',
   0, '[0]', 'single',
   '{"asked":"wgetコマンドの名前が何を組み合わせた名前かを問う問題。","why_asked":"web＋getという素直な組み合わせを知ることで、curlとの役割の違い（wgetはダウンロードに特化）も直感的に整理できる。","kid":"wgetは「web（ウェブ）」と「get（取ってくる）」を組み合わせた名前。その名の通り、Web上のファイルを取ってくる（ダウンロードする）ためのコマンド。","eg":"通販サイトで「今すぐ入手（get）」ボタンを押すのと同じ感覚で、Web（web）から欲しいファイルを取ってくる（get）道具、とイメージすると覚えやすい。","terms":[["wget","指定したURLからファイルをダウンロードするコマンド"]],"think":"名前の通りの機能を持つ、素直な組み合わせパターン。curlが「やり取り全般」に使える汎用ツールなのに対し、wgetは「取ってくる（ダウンロードする）」ことに特化しているという役割の違いも、名前から連想できる。","vs":"curlと役割が似ているように見えるが、curlは送信も含めた幅広い通信に使え、wgetはダウンロードに特化している点が違う。","opt":["正解。webとgetを組み合わせた名前で、Webからファイルを取ってくる機能をそのまま表している。","wideとgetの組み合わせに見えるが、wgetの由来はwideではなくweb。","web（ウェブ）は合っているが、後半はgetではなくgate（門）だと思い込みやすい紛らわしい選択肢。","writeとgetの組み合わせに見えるが、wgetの由来はwriteではなくweb。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="15" font-family="monospace"><tspan fill="#60a5fa">web</tspan><tspan fill="#8892a4"> + </tspan><tspan fill="#60a5fa">get</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">2つの単語をそのまま連結</text><rect x="130" y="76" width="80" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">wget</text></svg>'),

  ('linux-q209', 'よく使うコマンドの覚え方（ネットワーク）',
   '相手のコンピュータに応答があるか確認するコマンド `ping` の名前の由来として最も適切なものはどれか。',
   NULL::text,
   '["潜水艦のソナーが発する「ピン」という音に由来する", "「経路」を意味する英単語の略", "「接続」を意味する英単語の略", "開発者の名字に由来する"]',
   0, '[0]', 'single',
   '{"asked":"pingコマンドの名前の由来を問う問題。","why_asked":"英単語の略でも人名でもない、音の擬態語という第三のパターンを知っておく回。","kid":"pingは、潜水艦のソナーが「ピン」という音を出して壁や別の船に当たった反響で位置を確かめる、あの仕組みからイメージして名付けられたとされる。相手に信号を送って、返事が返ってくるかを確かめる動作がそっくりだったため。","eg":"暗いトンネルの中で「やっほー」と叫んで、こだまが返ってくるかで壁までの距離や相手の存在を確かめるイメージ。pingコマンドも相手に小さな信号を送り、返事（応答）が返ってくるかを確かめている。","terms":[["ping","相手のコンピュータに信号を送り、応答が返ってくるかを確認するコマンド"],["ソナー","音波を発して反響を調べることで、水中の物体の位置を探る仕組み"]],"think":"「信号を送って、跳ね返ってくる反応で存在を確かめる」というソナーの仕組みと、pingコマンドが「相手に信号を送って応答があるか確かめる」動作が本質的に同じであることに由来がある。後から「Packet InterNet Groper」というこじつけの当て字が作られたこともあるが、それは名前が先にあった後の後付けとされる。","vs":"「Packet InterNet Groper」という頭字語をpingの由来だと紹介する俗説もあるが、開発者自身はソナーの音をイメージして名付けたと説明しており、頭字語は後付けとされる。","opt":["正解。潜水艦のソナーが発する「ピン」という音と、信号を送って応答を確かめる動作が結び付けられて名付けられたとされる。","「経路」を意味する英単語の略だと推測しやすいが、pingの由来は経路ではなくソナーの音。","「接続」を意味する英単語の略だと推測しやすいが、pingの由来は接続ではなくソナーの音。","開発者の名字に由来すると推測しやすいが、pingは人名ではなくソナーの音のイメージが由来。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><circle cx="80" cy="55" r="10" fill="none" stroke="#3b82f6" stroke-width="1.5"/><circle cx="80" cy="55" r="20" fill="none" stroke="#2a2f3f" stroke-width="1.5"/><circle cx="80" cy="55" r="30" fill="none" stroke="#2a2f3f" stroke-width="1.5"/><text x="80" y="95" text-anchor="middle" font-size="11" fill="#8892a4">ソナーの「ピン」音</text><text x="250" y="50" text-anchor="middle" font-size="11" fill="#8892a4">信号→応答の確認</text><rect x="210" y="60" width="80" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="250" y="79" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">ping</text></svg>'),

  ('linux-q210', 'よく使うコマンドの覚え方（ネットワーク）',
   'リモートのコンピュータに安全にログインするコマンド `ssh` は、何の略か。',
   NULL::text,
   '["Secure Shell（安全な・シェル）", "System Shell（システムの・シェル）", "Server Shell（サーバーの・シェル）", "Send Shell（送信する・シェル）"]',
   0, '[0]', 'single',
   '{"asked":"sshコマンドが何の略かを問う問題。","why_asked":"「シェルとコマンドの正体」で学んだシェルという言葉が、SSHという略語の中にも登場していることに気づかせる回。","kid":"sshは「Secure Shell（安全な・シェル）」の略。Secureの頭文字S、Shellの最初の2文字SHを組み合わせて「SSH」になっている。","eg":"普段パソコンの中で使っているシェル（コマンドを受け付ける窓口）を、暗号化した安全な通信の中で、遠く離れたコンピュータに対しても使えるようにしたもの、とイメージすると分かりやすい。","terms":[["ssh","Secure Shellの略。リモートのコンピュータへ安全にログインするための仕組みとコマンド"],["Shell","コマンドを受け付けて実行するプログラム。シェルとコマンドの正体で学んだ概念"]],"think":"Secureの頭文字S1つと、Shellの頭文字2文字SHを組み合わせるとSSHになる。Shellという言葉が「シェルとコマンドの正体」で既に学んだ概念そのものだと気づくと、名前の意味がすんなり入ってくる。","vs":"System ShellやServer Shellのように聞こえそうだが、SSHのSはSystemでもServerでもなくSecure（安全な）の頭文字。","opt":["正解。Secure（安全な）のSと、Shell（シェル）の頭2文字SHを組み合わせた略語。","System Shellのように聞こえるが、SSHのSはSystemではなくSecureの頭文字。","Server Shellのように聞こえるが、SSHのSはServerではなくSecureの頭文字。","Send Shellのように聞こえるが、SSHのSはSendではなくSecureの頭文字。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="15" font-family="monospace"><tspan fill="#60a5fa">S</tspan><tspan fill="#8892a4">ecure </tspan><tspan fill="#60a5fa">SH</tspan><tspan fill="#8892a4">ell</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">S + SH を組み合わせる</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">ssh</text></svg>'),

  ('linux-q211', 'よく使うコマンドの覚え方（ネットワーク）',
   'ファイルを暗号化した通信で別のコンピュータへコピーするコマンド `scp` は、何を組み合わせた名前か。',
   NULL::text,
   '["secure（安全な）と、ファイルコピーの`cp`を組み合わせた名前", "system（システムの）と、ファイルコピーの`cp`を組み合わせた名前", "shell（シェルの）と、ファイルコピーの`cp`を組み合わせた名前", "send（送信する）と、ファイルコピーの`cp`を組み合わせた名前"]',
   0, '[0]', 'single',
   '{"asked":"scpコマンドが何を組み合わせた名前かを問う問題。","why_asked":"よく使うコマンドの覚え方（ファイル操作）で学んだcp（コピー）という既知のコマンドに、secureが付け足されただけだと気づかせる回。","kid":"scpは「secure（安全な）」と、ファイルをコピーするコマンド`cp`を組み合わせた名前。cpに「暗号化して安全に送る」という意味を足したものがscp。","eg":"普段使っているコピー機（cp）に、鍵付きの安全な配達サービスを付けたのがscp、とイメージすると分かりやすい。中身（コピーする、という機能）は同じで、運び方が安全になっている。","terms":[["scp","secure copyの略。暗号化した通信でファイルを別のコンピュータへコピーするコマンド"],["cp","ファイルをコピーするコマンド。よく使うコマンドの覚え方（ファイル操作）で学んだ"]],"think":"secureのsと、既に知っているcp（コピー）を組み合わせるだけでscpになる。cpという土台を知っていれば、scpは「それのSSH版」だと一気に理解できる。","vs":"cpと機能自体は同じ「コピー」だが、cpは同じコンピュータの中でのコピー、scpは別のコンピュータへ暗号化した通信で送るコピーという点が違う。","opt":["正解。secure（安全な）と、既に学んだコピー用コマンドcpを組み合わせた名前。","systemとcpの組み合わせに見えるが、scpの由来はsystemではなくsecure。","shellとcpの組み合わせに見えるが、scpの由来はshellではなくsecure。","sendとcpの組み合わせに見えるが、scpの由来はsendではなくsecure。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="14" font-family="monospace"><tspan fill="#60a5fa">s</tspan><tspan fill="#8892a4">ecure </tspan><tspan fill="#60a5fa">cp</tspan><tspan fill="#8892a4">（既知）</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">s + 既に学んだcp</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">scp</text></svg>'),

  ('linux-q212', 'よく使うコマンドの覚え方（ネットワーク）',
   '現在のネットワーク接続状況を表示するコマンド `netstat` は、何を組み合わせた名前か。',
   NULL::text,
   '["network（ネットワーク）とstatistics（統計情報）を組み合わせた名前", "network（ネットワーク）とstatus（状態）を組み合わせた名前", "internet（インターネット）とstatistics（統計情報）を組み合わせた名前", "network（ネットワーク）とstart（開始）を組み合わせた名前"]',
   0, '[0]', 'single',
   '{"asked":"netstatコマンドが何を組み合わせた名前かを問う問題。","why_asked":"部分的な短縮と部分的な短縮を組み合わせる、少し複雑な命名パターンに慣れる回。","kid":"netstatは「network（ネットワーク）」の最初の3文字netと「statistics（統計情報）」の最初の4文字statを組み合わせた名前。ネットワークの通信状況をまとめて見せてくれる。","eg":"お店の売上を「統計情報」としてまとめて見るように、netstatはコンピュータの通信を「ネットワークの統計情報」としてまとめて見せてくれる、とイメージすると分かりやすい。","terms":[["netstat","現在のネットワーク接続や通信状況をまとめて表示するコマンド。network statisticsの略"]],"think":"「net」と「stat」というそれぞれ別の単語の一部を組み合わせている点は、sedのstream＋editorと似た命名パターン。どちらも単語の頭の数文字だけを取って連結している。","vs":"「status（状態）」という単語と字面が似ているため紛らわしいが、netstatの由来はstatusではなくstatistics（統計情報）。","opt":["正解。networkの最初の3文字と、statisticsの最初の4文字を組み合わせた名前。","statusと似た響きだが、netstatの由来はstatusではなくstatistics。","internetの略に見えるが、netstatの前半はinternetではなくnetworkが由来。","startと似た響きだが、netstatの後半はstartではなくstatisticsが由来。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="13" font-family="monospace"><tspan fill="#60a5fa">net</tspan><tspan fill="#8892a4">work </tspan><tspan fill="#60a5fa">stat</tspan><tspan fill="#8892a4">istics</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">net + stat を組み合わせる</text><rect x="130" y="76" width="80" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="14" font-family="monospace" fill="#e8eaf0">netstat</text></svg>'),

  ('linux-q213', 'よく使うコマンドの覚え方（システム管理）',
   '動いているプロセスをCPU使用率の高い順にリアルタイムで表示するコマンド `top` の名前の由来として最も適切なものはどれか。',
   NULL::text,
   '["「上位・トップ」という英単語そのまま。負荷の高いプロセスが上に来ることから", "「合計」を意味する英単語の略", "「時刻」を意味する英単語の略", "開発者の名字に由来する"]',
   0, '[0]', 'single',
   '{"asked":"topコマンドの名前の由来を問う問題。","why_asked":"「リソース監視の基礎」で扱ったtopの仕組みに、今回は「なぜtopという名前なのか」という角度から接続する回。","kid":"topは「上位・トップ」という意味の英単語そのまま。CPUを多く使っているプロセスほど画面の上（トップ）に表示されることから、この名前になっている。","eg":"ランキング表で1位から順に上から並ぶのと同じで、topコマンドも一番CPUを使っているプロセスが表の一番上（トップ）に来るように並べてくれる。","terms":[["top","動いているプロセスをCPU使用率の高い順に一覧表示するコマンド。負荷の高いプロセスが画面の上位に来る"]],"think":"「表示される順番の一番上」という見た目の特徴が、そのまま名前になっている。「リソース監視の基礎」で学んだ「なぜ継続的に監視するか」という発想に、「なぜtopという名前か」という一段別の角度を足す回。","vs":"「合計」や「時刻」のような意味に聞こえる紛らわしい候補もあるが、topの由来は「順位の一番上」という単純な意味。","opt":["正解。「上位・トップ」という英単語そのままで、負荷の高いプロセスが表の上位に表示されることに由来する。","「合計」を意味する英単語の略だと推測しやすいが、topは合計ではなく順位の一番上を意味する。","「時刻」を意味する英単語の略だと推測しやすいが、topは時刻とは無関係。","開発者の名字に由来すると推測しやすいが、topは人名ではなく「上位」という意味の単語そのもの。"]}',
   '<svg viewBox="0 0 340 120" xmlns="http://www.w3.org/2000/svg"><rect x="60" y="20" width="220" height="18" rx="3" fill="#3b82f6" opacity="0.25"/><text x="70" y="33" font-size="10" fill="#e8eaf0">CPU 82% ← 一番上</text><rect x="60" y="42" width="220" height="18" rx="3" fill="#2a2f3f"/><text x="70" y="55" font-size="10" fill="#8892a4">CPU 30%</text><rect x="60" y="64" width="220" height="18" rx="3" fill="#2a2f3f"/><text x="70" y="77" font-size="10" fill="#8892a4">CPU 5%</text><text x="170" y="102" text-anchor="middle" font-size="12" fill="#8892a4">top = 「上位」に並ぶ</text></svg>'),

  ('linux-q214', 'よく使うコマンドの覚え方（システム管理）',
   'ディスクの空き容量を表示するコマンド `df` は、何の頭文字か。',
   NULL::text,
   '["disk free（ディスクの空き）", "disk format（ディスクの形式）", "data flow（データの流れ）", "disk find（ディスクを探す）"]',
   0, '[0]', 'single',
   '{"asked":"dfコマンドが何の頭文字かを問う問題。","why_asked":"「ディスクとストレージの基礎」で学んだディスク容量の話に、名前の由来という角度から接続する回。次のduと対で覚えると定着しやすい。","kid":"dfは「disk free（ディスクの空き）」の頭文字を組み合わせた名前。ディスク全体のうち、どれだけ空きがあるかをまとめて見せてくれる。","eg":"貯金箱に「あといくら入るか（空き容量）」を確認するようなイメージ。dfコマンドはディスクという貯金箱に、あとどれだけ入るかを教えてくれる。","terms":[["df","ディスク全体の空き容量を表示するコマンド。disk freeの頭文字"]],"think":"diskの頭文字dと、freeの頭文字fを組み合わせるとdfになる。次に出てくるduと名前が似ているが、dfは「ディスク全体の空き」、duは「特定のファイルやフォルダの使用量」という違いがある。","vs":"duと1文字違いで紛らわしいが、dfは「ディスク全体の空き容量」、duは「あるファイル/ディレクトリが使っている容量」を見る、という調べる対象が違う。","opt":["正解。disk（ディスク）とfree（空き）の頭文字を組み合わせた名前。","disk formatの略に見えるが、dfはformatではなくfree（空き）が由来。","data flowの略に見えるが、dfの前半はdataではなくdiskが由来。","disk findの略に見えるが、dfはfindではなくfree（空き）が由来。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="15" font-family="monospace"><tspan fill="#60a5fa">d</tspan><tspan fill="#8892a4">isk </tspan><tspan fill="#60a5fa">f</tspan><tspan fill="#8892a4">ree</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">頭文字だけ組み合わせる</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">df</text></svg>'),

  ('linux-q215', 'よく使うコマンドの覚え方（システム管理）',
   'ファイルやディレクトリが使っている容量を表示するコマンド `du` は、何の頭文字か。',
   NULL::text,
   '["disk usage（ディスクの使用量）", "data unit（データの単位）", "disk update（ディスクの更新）", "directory usage（ディレクトリの使用量）"]',
   0, '[0]', 'single',
   '{"asked":"duコマンドが何の頭文字かを問う問題。","why_asked":"直前のdfと対にして、「空き（free）」と「使用量（usage）」という反対の視点を持つ2つのコマンドをセットで整理する回。","kid":"duは「disk usage（ディスクの使用量）」の頭文字を組み合わせた名前。指定したファイルやフォルダが、ディスクをどれだけ使っているかを見せてくれる。","eg":"クローゼットの中で「この服が場所をどれだけ占領しているか」を測るようなイメージ。duコマンドは指定したファイルやフォルダが、ディスクという場所をどれだけ占領しているかを教えてくれる。","terms":[["du","指定したファイルやディレクトリが使っているディスク容量を表示するコマンド。disk usageの頭文字"]],"think":"diskの頭文字dと、usageの頭文字uを組み合わせるとduになる。dfが「全体の空き」を見るのに対し、duは「特定の場所の使用量」を見る、という視点の違いをセットで覚えると忘れにくい。","vs":"dfと1文字違いで紛らわしいが、dfは「ディスク全体の空き容量」を見るのに対し、duは「特定のファイル/ディレクトリの使用量」を見る点が逆の視点。","opt":["正解。disk（ディスク）とusage（使用量）の頭文字を組み合わせた名前。","data unitの略に見えるが、duの前半はdataではなくdiskが由来。","disk updateの略に見えるが、duはupdateではなくusage（使用量）が由来。","directory usageの略に見えるが、duの前半はdirectoryではなくdiskが由来。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="15" font-family="monospace"><tspan fill="#60a5fa">d</tspan><tspan fill="#8892a4">isk </tspan><tspan fill="#60a5fa">u</tspan><tspan fill="#8892a4">sage</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">頭文字だけ組み合わせる</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">du</text></svg>'),

  ('linux-q216', 'よく使うコマンドの覚え方（システム管理）',
   'メモリの空き容量を表示するコマンド `free` の名前の由来として最も適切なものはどれか。',
   NULL::text,
   '["「空いている・自由な」という英単語そのまま", "「頻度」を意味する英単語の略", "「解放する」という動詞の過去分詞形", "開発者の造語で特に意味はない"]',
   0, '[0]', 'single',
   '{"asked":"freeコマンドの名前の由来を問う問題。","why_asked":"「スワップメモリと仮想メモリの仕組み」で学んだメモリの話に、コマンド名という角度から接続する回。","kid":"freeは「空いている・自由な」という意味の英単語をそのまま使った名前。メモリ全体のうち、まだ使われていない（空いている）分がどれだけあるかを見せてくれる。","eg":"ホテルの「空室（free room）」を確認するのと同じで、freeコマンドはメモリという部屋のうち、まだ空いている（free）分がどれだけあるかを教えてくれる。","terms":[["free","メモリの空き容量・使用中の容量をまとめて表示するコマンド"]],"think":"「そのまま系」の命名パターンで、sortやheadと同じく、意味を表す英単語をそのままコマンド名にしている。dfの「disk free」のfreeと同じ単語だと気づくと、両方まとめて覚えやすい。","vs":"「頻度」を意味するfrequencyと綴りの一部が似ているが、freeコマンドの由来はfrequencyではなく「空いている」という意味そのもの。","opt":["正解。「空いている・自由な」という英単語をそのまま名前にしている。","「頻度」を意味する英単語の略だと推測しやすいが、freeは頻度とは無関係。","「解放する」という動詞の過去分詞形に見えるが、freeコマンドは動詞の活用形ではなく形容詞のfreeそのもの。","開発者の造語だと思われがちだが、freeは辞書に載っている一般的な英単語そのものが由来。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="38" text-anchor="middle" font-size="13" fill="#8892a4">そのまま英単語</text><rect x="115" y="52" width="110" height="32" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="74" text-anchor="middle" font-size="18" font-family="monospace" fill="#e8eaf0">free</text><text x="170" y="100" text-anchor="middle" font-size="12" fill="#8892a4">= メモリの空き</text></svg>'),

  ('linux-q217', 'よく使うコマンドの覚え方（システム管理）',
   '新しいユーザーアカウントを作成するコマンド `useradd` は、何を組み合わせた名前か。',
   NULL::text,
   '["user（ユーザー）とadd（追加する）を組み合わせた名前", "user（ユーザー）とaddress（住所）を組み合わせた名前", "use（使う）とradar（探索）を組み合わせた名前", "user（ユーザー）とaudit（監査）を組み合わせた名前"]',
   0, '[0]', 'single',
   '{"asked":"useraddコマンドが何を組み合わせた名前かを問う問題。","why_asked":"wgetと同じ「そのまま2単語連結」パターンで、素直な命名の存在をもう一度定着させる回。","kid":"useraddは「user（ユーザー）」と「add（追加する）」を組み合わせた名前。その名の通り、新しいユーザーを追加するコマンド。","eg":"名簿に新しい生徒の名前を追加するのと同じで、useraddはコンピュータを使う人の名簿に、新しいユーザー（user）を追加（add）する道具。","terms":[["useradd","新しいユーザーアカウントを作成するコマンド"]],"think":"「権限とユーザー」で学んだ「ユーザー」という概念に、「追加する」という動作をそのまま足した、分かりやすい命名。特殊な略語ではなく2つの単語をそのまま連結している。","vs":"addressやauditのような似た響きの単語と混同しやすいが、useraddの後半はadd（追加する）というシンプルな動詞。","opt":["正解。userとaddをそのまま組み合わせた名前で、新しいユーザーを追加する機能を表している。","addressと似た響きだが、useraddの後半はaddressではなくadd（追加する）。","radarと似た響きだが、useraddの前半後半ともにradarとは無関係。","auditと似た響きだが、useraddの後半はauditではなくadd（追加する）。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="15" font-family="monospace"><tspan fill="#60a5fa">user</tspan><tspan fill="#8892a4"> + </tspan><tspan fill="#60a5fa">add</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">2つの単語をそのまま連結</text><rect x="120" y="76" width="100" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="14" font-family="monospace" fill="#e8eaf0">useradd</text></svg>'),

  ('linux-q218', 'よく使うコマンドの覚え方（システム管理）',
   'ユーザーのパスワードを変更するコマンド `passwd` は、何の省略形か。',
   NULL::text,
   '["password（パスワード）の末尾を短くした省略形", "pass word（合言葉）の頭文字を並べた略語", "personal word（個人の言葉）の省略形", "protect word（言葉を守る）の省略形"]',
   0, '[0]', 'single',
   '{"asked":"passwdコマンドが何の省略形かを問う問題。","why_asked":"「権限とユーザー」で学んだユーザーの話に接続しつつ、単語の途中を削って短くする、という少し珍しい省略パターンを知っておく回。","kid":"passwdは「password（パスワード）」という単語の途中を短くした名前。password（p-a-s-s-w-o-r-d）の真ん中あたりの「or」を抜いて、passwd（p-a-s-s-w-d）にしている。","eg":"「お誕生日おめでとう」を「誕生日おめ」と略すように、passwordの一部を抜いて短くしたのがpasswd。意味は変わらず「パスワード」のまま。","terms":[["passwd","ユーザーのパスワードを変更するコマンド。passwordの省略形"]],"think":"これまでの「頭文字だけ取る」パターンとは違い、passwdは単語の途中を削って短くしている。古いコンピュータではファイル名やコマンド名の長さに制限があったため、こうした短縮がよく行われていた、という背景を知っておくと納得しやすい。","vs":"「pass」と「word」の頭文字を並べたものだと誤解しやすいが、passwdはpasswordという1つの単語の途中を短くしたものであり、2つの単語の頭文字略語ではない。","opt":["正解。passwordという1つの単語の途中（or）を抜いて短くした省略形。","pass wordという2つの単語の頭文字を並べた略語に見えるが、実際はpasswordという1語の省略形。","personal wordの省略形に見えるが、passwdの由来はpersonalではなくpassword。","protect wordの省略形に見えるが、passwdの由来はprotectではなくpassword。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="15" font-family="monospace"><tspan fill="#60a5fa">passw</tspan><tspan fill="#c47070">or</tspan><tspan fill="#60a5fa">d</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">「or」を抜いて短くする</text><rect x="120" y="76" width="100" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="14" font-family="monospace" fill="#e8eaf0">passwd</text></svg>'),

  ('linux-q219', 'よく使うコマンドの覚え方（システム管理）',
   '別のユーザー（多くは管理者権限）としてコマンドを実行する `sudo` は、何を組み合わせた名前か。',
   NULL::text,
   '["su（代理のユーザーとして、の略）とdo（実行する）を組み合わせた名前", "su（特権ユーザー、の略）とdo（実行する）を組み合わせた名前", "su（システムユーザー、の略）とdo（実行する）を組み合わせた名前", "su（共有ユーザー、の略）とdo（実行する）を組み合わせた名前"]',
   0, '[0]', 'single',
   '{"asked":"sudoコマンドが何を組み合わせた名前かを問う問題。","why_asked":"「権限とユーザー」で扱ったsudoの使い方に、名前の由来という角度から接続する回。","kid":"sudoは、別のユーザーとして操作するための古くからあるコマンド`su`（substitute user＝代理のユーザー、の略）と、「do（実行する）」を組み合わせた名前。「代理のユーザーとして、これを実行する」という意味になる。","eg":"自分の代わりに窓口の担当者（代理のユーザー）に手続きをお願いするイメージ。sudoは「この作業だけ、別の人（多くは管理者）の代わりにやってもらう」という意味合いの名前。","terms":[["sudo","substitute user do の略。別のユーザーの権限で、指定した1つのコマンドだけを実行する仕組み"],["su","substitute userの略。ユーザーを切り替えるための古くからあるコマンド"]],"think":"「superuser do（特権ユーザーとして実行）」という説明もよく聞かれるが、これは俗説であり、正式にはsu（substitute user、代理のユーザー）とdoを組み合わせた名前とされる。sudoは常に管理者権限とは限らず、指定した別のどのユーザーとしても実行できる、という点でsuperuserという説明はやや不正確。","vs":"「superuser do」という俗説の方が広まっているが、sudoは特定のユーザー（管理者以外も含む）の代理として実行する仕組みであり、superuser（特権ユーザー）専用というわけではない。","opt":["正解。su（代理のユーザー、substitute userの略）とdo（実行する）を組み合わせた名前。","「特権ユーザー（superuser）」の略だという俗説が広まっているが、正式にはsubstitute userが由来とされる。","「システムユーザー」の略だと推測しやすいが、suの由来はsystemではなくsubstitute。","「共有ユーザー」の略だと推測しやすいが、suの由来はsharedではなくsubstitute。"]}',
   '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg"><text x="170" y="42" text-anchor="middle" font-size="14" font-family="monospace"><tspan fill="#60a5fa">su</tspan><tspan fill="#8892a4">(代理ユーザー) + </tspan><tspan fill="#60a5fa">do</tspan></text><text x="170" y="65" text-anchor="middle" font-size="11" fill="#8892a4">su + do を組み合わせる</text><rect x="140" y="76" width="60" height="28" rx="4" fill="none" stroke="#3b82f6" stroke-width="1.5"/><text x="170" y="95" text-anchor="middle" font-size="15" font-family="monospace" fill="#e8eaf0">sudo</text></svg>')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'linux-basics'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
