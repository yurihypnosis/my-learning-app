-- 英語・句動詞（Set T3-C）: 日常・語り22問（発覚・判明系11／感情・反応系11）
-- question-authoring-pv スキル準拠。感情・反応系はスキル記載の固定5クラスタに無い補助クラスタ
-- （T3の組は先送り・回避系/開始・着手系/関係・対立系/増減・変化系/発覚・判明系の5つで、5つ目の相方が
--  スキルに無いため日常語り向けに新設。docs/pv-chunk-ledger.md 参照）。
BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('pv-t3-c',
        '英語・句動詞（Set T3-C）',
        '【Speak-First】日本語の場面を見たら、選択肢を見る前に3秒以内で英文を声に出す。言ってから表示。口で言えなかったら解答後にチップを押す。',
        '#6ab08d', 124, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('発覚・判明系', '#a3e635', 1),
  ('感情・反応系', '#e879f9', 2)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'pv-t3-c'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('pv-t3c-q01', '発覚・判明系',
   '〔中立〕彼が転職を考えていることを偶然知った。',
   NULL::text,
   '["I happened to find out that he was thinking about changing jobs.","I happened to search and discover outside that he was thinking about changing jobs.","I happened to find out on that he was thinking about changing jobs.","I basically stumbled onto the fact he was job hunting, no cap."]',
   0, '[0]', 'single',
   '{"asked":"情報を知ることを find out で述べられるか。","point":"find out＝（情報を）知る・判明する。意図的な調査でも偶然の発見でも使える最頻出表現。","kid":"find out＝見つけて外に出す。隠れていた情報を見つけ出すイメージ。","eg":"I only found out about the meeting change this morning.","terms":[["find out + that節/about","事実や話題を続ける形が定番"],["find out on（誤用）","不要な前置詞を付けた誤り"]],"think":"情報を知った経緯を述べる文→動詞は find→粒子は out。","vs":"直訳肢の search and discover outside は find out の意味を「探して発見する」と過剰に分解した不自然な直訳。find out on は不要な前置詞を付けた誤用。最後の肢は stumbled onto/no cap など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 のエピソード描写、CAE Speaking Part 3 の情報伝達トピックで最頻出。","usecase":"偶然や成り行きで何かを知ったことを説明する自然な言い方。","opt":["正解。find out が情報を知ることを示す標準形。","過剰に分解した不自然な直訳。","不要な前置詞を加えた誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q02', '発覚・判明系',
   '〔中立〕心配していたが、結局すべてうまくいった。',
   NULL::text,
   '["I was worried, but everything turned out fine.","I was worried, but everything turned its direction out fine.","I was worried, but everything turned in fine.","I was worried, but it basically all worked out fine in the end, yeah."]',
   0, '[0]', 'single',
   '{"asked":"結果的な判明を turn out で述べられるか。","point":"turn out＝結局〜だと判明する。予想と違った、または心配が杞憂だったという結果を示す最頻出表現。","kid":"turn out＝回って外に出る。予想もしなかった結果が最終的に姿を現すイメージ。","eg":"The weather turned out better than the forecast predicted.","terms":[["turn out + 形容詞/that節","fine/well/that ... の形と相性が良い"],["turn in（誤用）","前置詞は out 固定、in は誤り"]],"think":"結果を述べる文→動詞は turn→粒子は out。","vs":"直訳肢の turned its direction out は turn を「方向転換」として文字通り直訳した不自然な表現。turn in は前置詞の誤用。最後の肢は worked out という別のチャンクへの言い換えで、意味は近いがこの設問が問う turn out 特有の表現とはずれる。","why_asked":"IELTS Speaking Part 2 のエピソード結末、CAE Speaking Part 3 の結果報告で最頻出。","usecase":"心配していたことが結果的にうまくいったことを説明する自然な言い方。","opt":["正解。turned out が結果的な判明を示す標準形。","turnを方向転換として直訳した表現。","前置詞の誤用。","別チャンクへの言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3c-q03', '発覚・判明系',
   '〔中立〕古い写真の箱を偶然見つけた。',
   NULL::text,
   '["I came across a box of old photos by chance.","I walked across and met a box of old photos by chance.","I came across on a box of old photos by chance.","I basically just happened upon this box of old photos, kinda random."]',
   0, '[0]', 'single',
   '{"asked":"偶然の発見を come across で述べられるか。","point":"come across＝（物や人に）偶然出くわす。探していたわけではないのに見つけることを示す最頻出表現。","kid":"come across＝横切って出会う。道を歩いていて偶然何かに行き当たるイメージ。","eg":"She came across an old friend at the airport.","terms":[["come across + 名詞","photos/an old friend などの名詞と相性が良い（他動詞的な用法）"],["come across on（誤用）","come across は前置詞を伴わず直接目的語を取るため on は不要"]],"think":"偶然の発見を述べる文→動詞は come→粒子は across。","vs":"直訳肢の walked across and met は come across を「歩いて渡って出会う」と身体動作で過剰に分解した不自然な表現。come across on は不要な前置詞を加えた誤用。最後の肢は happened upon/kinda random など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 のエピソード描写、CAE Speaking Part 2 の思い出話で最頻出。","usecase":"探していなかったものを偶然見つけたことを説明する自然な言い方。","opt":["正解。come across が偶然の発見を示す標準形。","身体動作として過剰に分解した表現。","不要な前置詞を加えた誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q04', '発覚・判明系',
   '〔中立〕真実は結局明らかになった。',
   NULL::text,
   '["The truth eventually came out.","The truth eventually walked itself out of the room.","The truth eventually came up.","The truth basically got out eventually, yeah."]',
   0, '[0]', 'single',
   '{"asked":"秘密や真実の発覚を come out で述べられるか。","point":"come out＝（秘密・真実が）明らかになる。隠されていたことが表に出てくることを示す最頻出表現。","kid":"come out＝外に出てくる。隠れていたものが自然と表に姿を現すイメージ。","eg":"It later came out that he had known about the problem all along.","terms":[["come out（自動詞）","the truth/the story/the news などが主語になり発覚を表す"],["come up（誤用寄り）","「話題に上る」という意味合いが強く、真実の発覚とはややずれる"]],"think":"発覚の描写文→動詞は come→粒子は out。","vs":"直訳肢の walked itself out of the room は come out を身体的な移動として過剰に直訳した不自然な表現。come up は「話題に上る」という意味合いが強く、真実そのものが発覚するというニュアンスとはずれる近義語トラップ。最後の肢は got out/yeah など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Reading の調査報道記事、IELTS Speaking Part 3 の真実・発覚トピックで頻出。","usecase":"隠されていた事実が最終的に明らかになったことを説明する自然な言い方。","opt":["正解。came out が真実の発覚を示す標準形。","身体的な移動として過剰に直訳した表現。","ニュアンスがずれる近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q05', '発覚・判明系',
   '〔中立〕自分が間違っていたことに、突然気づいた。',
   NULL::text,
   '["It suddenly dawned on me that I had been wrong.","The sun suddenly rose like dawn on me that I had been wrong.","It suddenly dawned to me that I had been wrong.","It basically hit me that I had been wrong, whoa."]',
   0, '[0]', 'single',
   '{"asked":"突然の気づきを dawn on で述べられるか。","point":"dawn on＝（人に）突然気づかされる。夜明けのように、理解がゆっくりと、しかし確実に訪れるイメージの表現。","kid":"dawn on＝夜明けのように差してくる。太陽が昇るように、気づきが自然と心に差し込んでくるイメージ。","eg":"It finally dawned on her that she had misread the situation.","terms":[["it dawns on + 人 + that節","it を主語にした構文で人に対する気づきを表す"],["dawn to（誤用）","前置詞は on 固定、to は誤り"]],"think":"突然の気づきの文→動詞は dawn→前置詞は on。","vs":"直訳肢の rose like dawn on は dawn を「太陽が昇る」という名詞的な意味で過剰に直訳した不自然な表現。dawn to は前置詞の誤用。最後の肢は hit me/whoa という別の慣用句への言い換えで、意味は近いがこの設問が問う dawn on 特有の表現とはずれる。","why_asked":"CAE Speaking Part 2 の気づきのエピソード、IELTS Speaking Part 3 の内省トピックで頻出。","usecase":"自分の誤りや状況に突然気づいたことを説明する自然な言い方。","opt":["正解。dawned on が突然の気づきを示す標準形。","dawnを名詞的に過剰に直訳した表現。","前置詞の誤用。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3c-q06', '発覚・判明系',
   '〔中立〕最初は理解できなかったが、彼女はすぐに要領をつかんだ。',
   NULL::text,
   '["She could not understand at first, but she quickly caught on.","She could not understand at first, but she quickly caught the thing on top of it.","She could not understand at first, but she quickly caught up.","She could not understand at first, but she basically got it eventually, yeah."]',
   0, '[0]', 'single',
   '{"asked":"理解し始めることを catch on で述べられるか。","point":"catch on＝理解する・要領をつかむ。徐々に仕組みや状況を飲み込んでいくことを示す口語の定番表現。","kid":"catch on＝引っかかって理解が定着する。歯車がかみ合うように、理解がすっとはまるイメージ。","eg":"It took a while, but the new staff soon caught on to the routine.","terms":[["catch on（自動詞）","目的語なしで理解の完了を表す。catch on to + 名詞 の形も可"],["catch up（誤用寄り）","「追いつく」で、理解の獲得というよりは遅れを取り戻す意味合いが強い"]],"think":"理解の進展を述べる文→動詞は catch→粒子は on。","vs":"直訳肢の caught the thing on top of it は on を「物の上」という物理的な意味で誤解した不自然な表現。catch up は「（遅れを）追いつく」という意味合いが強く、catch on が持つ「理解し始める」というニュアンスとはずれる近義語トラップ。最後の肢は got it/yeah など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 3 の学習・適応トピック、IELTS Speaking Part 3 の理解プロセスで頻出。","usecase":"最初は分からなかったことを徐々に理解できるようになったことを説明する自然な言い方。","opt":["正解。caught on が理解の進展を示す標準形。","onを物理的な意味で誤解した表現。","ニュアンスがずれる近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q07', '発覚・判明系',
   '〔中立〕準備の最中に、予期しない問題がいくつか生じた。',
   NULL::text,
   '["Several unexpected problems cropped up during preparation.","Several unexpected problems grew like crops up during preparation.","Several unexpected problems cropped out during preparation.","A bunch of random problems basically popped up during prep, ugh."]',
   0, '[0]', 'single',
   '{"asked":"予期しない出来事の発生を crop up で述べられるか。","point":"crop up＝（予期せず）生じる・持ち上がる。作物が地面から思いがけず芽を出すイメージから転じた表現。","kid":"crop up＝作物のように突然芽を出す。予定していなかった問題がひょっこり現れるイメージ。","eg":"A scheduling conflict cropped up at the last minute.","terms":[["crop up（自動詞）","problems/issues/questions などが主語になり突発的な発生を表す"],["crop out（誤用）","存在しない組み合わせ"]],"think":"予期しない発生を述べる文→動詞は crop→粒子は up。","vs":"直訳肢の grew like crops up は crop を「農作物」という名詞の意味で文字通り直訳した不自然な表現。crop out は存在しない誤用。最後の肢は popped up/ugh という別の近義語への言い換えで、意味は近いがこの設問が問う crop up 特有の表現とはずれる。","why_asked":"CAE Speaking Part 4 のプロジェクト管理トピック、IELTS Writing のプロセス説明で頻出。","usecase":"準備や作業中に予期しない問題が発生したことを説明する自然な言い方。","opt":["正解。cropped up が予期しない発生を示す標準形。","cropを名詞として文字通り直訳した表現。","crop out は存在しない誤用。","別の表現への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3c-q08', '発覚・判明系',
   '〔口語〕インターネットを見ていて、興味深い記事を偶然見つけた。',
   NULL::text,
   '["While browsing online, I stumbled upon an interesting article.","While browsing online, I tripped my foot and fell upon an interesting article.","While browsing online, I stumbled on top an interesting article.","While one was browsing online, one happened to discover an intriguing article."]',
   0, '[0]', 'single',
   '{"asked":"偶然の発見を stumble upon で口語的に述べられるか。","point":"stumble upon＝偶然見つける。つまずくように、予想外に何かに行き当たることを示すやや詩的な口語表現。","kid":"stumble upon＝よろけて偶然出会う。歩いていてつまずくように、思いがけず何かにたどり着くイメージ。","eg":"I stumbled upon a great little cafe while exploring the city.","terms":[["stumble upon + 名詞","article/cafe/idea などの名詞と相性が良い"],["stumble on top（誤用）","upon/on が正しく、top を加えるのは誤り"]],"think":"偶然の発見の口語描写→動詞は stumble→前置詞は upon。","vs":"直訳肢の tripped my foot and fell upon は stumble を「つまずいて転ぶ」という身体動作として過剰に直訳した不自然な表現。stumble on top は不要な語を加えた誤用。最後の肢は one was browsing/one happened to など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 2 の発見のエピソード、IELTS Speaking Part 2 の趣味・興味トピックで頻出。","usecase":"ネットサーフィン中などに偶然良いものを見つけたことをカジュアルに話す言い方。","opt":["正解。stumble upon が偶然の発見を示す口語標準形。","身体動作として過剰に直訳した表現。","不要な語を加えた誤用。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3c-q09', '発覚・判明系',
   '〔フォーマル〕発表前に、機密情報が漏れてしまった。',
   NULL::text,
   '["Confidential information leaked out before the announcement.","Confidential information dripped like water out before the announcement.","Confidential information leaked off before the announcement.","The secret stuff basically got out before the big reveal, yeah."]',
   0, '[0]', 'single',
   '{"asked":"情報漏洩を leak out でフォーマルに述べられるか。","point":"leak out＝（情報が）漏れる。秘密や機密が意図せず外部に伝わることを示す定番のフォーマル表現。","kid":"leak out＝水が漏れるように情報が漏れる。容器の隙間から水がじわじわ漏れ出るイメージ。","eg":"Details of the deal leaked out to the press before the official statement.","terms":[["leak out（自動詞）","information/details/news などが主語になり漏洩を表す"],["leak off（誤用）","存在しない組み合わせ"]],"think":"情報漏洩の報告文→動詞は leak→粒子は out。","vs":"直訳肢の dripped like water out は leak を「水滴が垂れる」という文字通りの意味で過剰に説明した不自然な表現。leak off は存在しない誤用。最後の肢は secret stuff/big reveal/yeah など口語表現でフォーマルな情報漏洩の報告には不適。","why_asked":"CAE Reading の企業・政治スキャンダル記事、IELTS Writing の情報管理パラグラフで頻出。","usecase":"公式発表前に機密情報が漏れたことを客観的に報告する定型表現。","opt":["正解。leaked out が情報漏洩を示す標準形。","水滴として過剰に直訳した表現。","leak off は存在しない誤用。","口語すぎてフォーマルな報告に不適。"]}'),

  ('pv-t3c-q10', '発覚・判明系',
   '〔中立〕彼女の名前が、思いがけず古い名簿に現れた。',
   NULL::text,
   '["Her name unexpectedly showed up on an old list.","Her name unexpectedly made itself appear physically on an old list.","Her name unexpectedly showed off on an old list.","Her name basically popped up on some old list out of nowhere, random."]',
   0, '[0]', 'single',
   '{"asked":"意外な出現を show up で述べられるか。","point":"show up＝（意外な場所や形で）現れる。人だけでなく物や名前などが思いがけず姿を現すことにも使える表現。","kid":"show up＝姿を見せて現れる。予想していなかった場所にひょっこり出てくるイメージ。","eg":"An old photo of hers showed up in a box in the attic.","terms":[["show up + on/in + 名詞","list/photo/box などの場所を示す名詞と相性が良い"],["show off（誤用）","「見せびらかす」で全く別の意味"]],"think":"意外な出現を述べる文→動詞は show→粒子は up。","vs":"直訳肢の made itself appear physically は show up の意味を過剰に説明した冗長な直訳。show off は「見せびらかす」という全く別の意味になる重要な誤用トラップ。最後の肢は popped up/out of nowhere/random など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 2 の意外な発見のエピソード、IELTS Speaking Part 2 の思い出話で頻出。","usecase":"名前や物が予想外の場所に見つかったことを説明する自然な言い方。","opt":["正解。showed up が意外な出現を示す標準形。","過剰に説明した冗長な直訳。","show off は全く別の意味。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q11', '発覚・判明系',
   '〔フォーマル〕記者たちは、その合併のうわさを聞きつけた。',
   NULL::text,
   '["Journalists got wind of the upcoming merger.","Journalists received wind blowing of the upcoming merger.","Journalists got wind on the upcoming merger.","Reporters basically caught wind of the merger thing, heard through the grapevine."]',
   0, '[0]', 'single',
   '{"asked":"うわさを聞きつけることを get wind of でフォーマルに述べられるか。","point":"get wind of＝（うわさや秘密を）聞きつける。風の便りで情報が届くイメージの、やや文語的な定番表現。","kid":"get wind of＝風に乗って情報が届く。噂という風が偶然自分のところまで運ばれてくるイメージ。","eg":"The board got wind of the plan before it was officially proposed.","terms":[["get wind of + 名詞","plan/merger/scandal などの名詞と相性が良い"],["get wind on（誤用）","前置詞は of 固定、on は誤り"]],"think":"うわさの発覚を述べる文→動詞は get→名詞句 wind of。","vs":"直訳肢の received wind blowing of は wind を「吹く風」として文字通り過剰に説明した不自然な直訳。get wind on は前置詞の誤用。最後の肢は caught wind of/heard through the grapevine など別の慣用句を重ねた口語表現で、フォーマルな報道記事の文体には不適。","why_asked":"CAE Reading のビジネス・M&A記事、IELTS Writing のフォーマルな情報伝達パラグラフで頻出。","usecase":"公式発表前にうわさや情報が伝わったことをフォーマルに報告する定型表現。","opt":["正解。got wind of がうわさの発覚を示す標準形。","windを文字通り過剰に説明した直訳。","前置詞の誤用。","口語表現を重ねてフォーマルな文体に不適。"]}'),

  ('pv-t3c-q12', '感情・反応系',
   '〔口語〕突然の大きな音に、みんなパニックになった。',
   NULL::text,
   '["Everyone freaked out at the sudden loud noise.","Everyone became a freak and went out at the sudden loud noise.","Everyone freaked up at the sudden loud noise.","Everyone became considerably alarmed at the sudden loud noise."]',
   0, '[0]', 'single',
   '{"asked":"パニックになることを freak out で口語的に述べられるか。","point":"freak out＝パニックになる・取り乱す。強い驚きや恐怖で冷静さを失うことを示す口語の定番表現。","kid":"freak out＝普通の状態から外れて取り乱す。冷静さがぱっと外に飛び出してしまうイメージ。","eg":"She freaked out when she saw a spider in the bathroom.","terms":[["freak out（自動詞）","目的語を取らず、パニック状態そのものを表す"],["freak up（誤用）","一般的でない誤用形。標準は freak out"]],"think":"パニック描写の口語文→動詞は freak→粒子は out。","vs":"直訳肢の became a freak and went out は freak を「奇人・変人」という名詞の意味で誤解した不自然な直訳。freak up は一般的でない誤用形。最後の肢は became considerably alarmed など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 2 の驚きのエピソード、IELTS Speaking Part 2 の感情描写で最頻出。","usecase":"突然の出来事に驚いてパニックになったことをカジュアルに話す言い方。","opt":["正解。freaked out がパニックを示す口語標準形。","freakを名詞として誤解した直訳。","一般的でない誤用形。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3c-q13', '感情・反応系',
   '〔中立〕深呼吸をして、彼は落ち着こうとした。',
   NULL::text,
   '["He took a deep breath and tried to calm down.","He took a deep breath and tried to make his temperature calm downward.","He took a deep breath and tried to calm off.","He took a breath and basically tried to chill out, yeah."]',
   0, '[0]', 'single',
   '{"asked":"落ち着くことを calm down で述べられるか。","point":"calm down＝落ち着く。興奮や動揺した状態から平静を取り戻すことを示す最頻出表現。","kid":"calm down＝穏やかさが降りてくる。波が静まっていくように、気持ちが落ち着いていくイメージ。","eg":"It took a few minutes for the crowd to calm down.","terms":[["calm down（自動詞）","目的語を取らず、平静を取り戻す様子そのものを表す"],["calm off（誤用）","存在しない組み合わせ"]],"think":"落ち着きを取り戻す描写文→動詞は calm→粒子は down。","vs":"直訳肢の make his temperature calm downward は calm を「温度」として過剰に直訳した不自然な表現。calm off は存在しない誤用。最後の肢は chill out/yeah など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 1 の感情トピック、CAE Speaking Part 2 の対処法の描写で最頻出。","usecase":"興奮や緊張から落ち着こうとする様子を説明する自然な言い方。","opt":["正解。calm down が落ち着きを取り戻すことを示す標準形。","temperatureとして過剰に直訳した表現。","calm off は存在しない誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q14', '感情・反応系',
   '〔中立〕友達を元気づけようと、面白い話をした。',
   NULL::text,
   '["I told a funny story to cheer up my friend.","I told a funny story to make cheering sounds go up for my friend.","I told a funny story to cheer on my friend.","I told a funny story to basically make my friend feel less down, kinda."]',
   0, '[0]', 'single',
   '{"asked":"人を元気づけることを cheer up で述べられるか。","point":"cheer up＝（人を）元気づける・励ます。落ち込んでいる人の気分を明るくすることを示す最頻出表現。","kid":"cheer up＝応援の声で気持ちを持ち上げる。しょんぼりした気持ちを歓声で盛り上げるイメージ。","eg":"A card from her colleagues really cheered her up.","terms":[["cheer + 人 + up","分離動詞。目的語が人称代名詞のときは間に挟むのが必須"],["cheer on（誤用）","「応援する」で、既に頑張っている人を励ます意味になり、落ち込んだ人を元気づける意味とは異なる"]],"think":"人を元気づける描写文→動詞は cheer→粒子は up。","vs":"直訳肢の make cheering sounds go up は cheer を「歓声」という名詞の意味で過剰に直訳した不自然な表現。cheer on は「（頑張っている人を）応援する」という別の意味になる誤用トラップ。最後の肢は feel less down/kinda など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 の人間関係のエピソード、CAE Speaking Part 2 の思いやりの描写で頻出。","usecase":"落ち込んでいる友人を元気づけようとしたことを説明する自然な言い方。","opt":["正解。cheer up が人を元気づけることを示す標準形。","cheerを名詞として過剰に直訳した表現。","cheer on は別の意味になる誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q15', '感情・反応系',
   '〔中立〕忍耐が切れて、彼女は部下にきつく言い返した。',
   NULL::text,
   '["Losing her patience, she snapped at her subordinate.","Losing her patience, she broke like a snapping stick at her subordinate.","Losing her patience, she snapped on her subordinate.","Losing her patience, she basically bit his head off, yikes."]',
   0, '[0]', 'single',
   '{"asked":"苛立って言い返すことを snap at で述べられるか。","point":"snap at＝（人に）きつく言い返す。我慢の限界が来て、突然刺々しい言葉を発することを示す表現。","kid":"snap at＝ポキッと折れて噛みつく。抑えていた我慢が突然パチンと切れて言葉が飛び出すイメージ。","eg":"He snapped at the waiter for no real reason.","terms":[["snap at + 人","subordinate/waiter などの人の名詞と相性が良い"],["snap on（誤用）","前置詞は at 固定、on は誤り"]],"think":"苛立った反応の描写文→動詞は snap→前置詞は at。","vs":"直訳肢の broke like a snapping stick は snap を「棒が折れる」という文字通りの意味で過剰に直訳した不自然な表現。snap on は前置詞の誤用。最後の肢は bit his head off/yikes など別の慣用句を使った口語表現で、意味は近いがこの設問が問う snap at 特有の表現とはずれる。","why_asked":"CAE Speaking Part 3 の職場対立トピック、IELTS Speaking Part 2 の感情エピソードで頻出。","usecase":"我慢が限界に達して誰かにきつく言い返したことを説明する自然な言い方。","opt":["正解。snapped at が苛立った反応を示す標準形。","棒が折れる意味として過剰に直訳した表現。","前置詞の誤用。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3c-q16', '感情・反応系',
   '〔中立〕批判されて、彼は記者たちに激しく言い返した。',
   NULL::text,
   '["Under criticism, he lashed out at the reporters.","Under criticism, he hit them with a whip like a lash at the reporters.","Under criticism, he lashed out on the reporters.","Under criticism, he basically went off on the reporters, whoa."]',
   0, '[0]', 'single',
   '{"asked":"激しい攻撃的反応を lash out at で述べられるか。","point":"lash out at＝（人に）激しく攻撃的に言い返す・反撃する。snap at よりも強い怒りや攻撃性を示す表現。","kid":"lash out at＝むちを振るうように激しく反応する。抑えきれない怒りが鞭のように飛び出すイメージ。","eg":"The politician lashed out at journalists during the press conference.","terms":[["lash out at + 人","reporters/critics などの人の名詞と相性が良い"],["lash out on（誤用）","前置詞は at 固定、on は誤り"]],"think":"激しい反撃の描写文→動詞は lash→粒子は out→前置詞 at。","vs":"直訳肢の hit them with a whip like a lash は lash を「むち」という名詞の意味で文字通り過剰に直訳した表現。lash out on は前置詞の誤用。最後の肢は went off on/whoa など口語表現で、内容は近いが中立的な報告文としてはやや砕けすぎる。","why_asked":"CAE Reading の政治・メディア記事、IELTS Speaking Part 3 の対立トピックで頻出。","usecase":"批判に対して激しく攻撃的に言い返したことを説明する定型表現。","opt":["正解。lashed out at が激しい反撃を示す標準形。","むちとして過剰に直訳した表現。","前置詞の誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q17', '感情・反応系',
   '〔中立〕失恋から立ち直るのに、彼女は数か月かかった。',
   NULL::text,
   '["It took her several months to get over the breakup.","It took her several months to climb over the breakup like a wall.","It took her several months to get over on the breakup.","It took her a few months to basically move on from the breakup, kinda."]',
   0, '[0]', 'single',
   '{"asked":"精神的な立ち直りを get over で述べられるか。","point":"get over＝（つらい経験・失恋などから）立ち直る。困難を乗り越えて回復することを示す最頻出表現。","kid":"get over＝乗り越えて向こう側に行く。壁を乗り越えるように、つらい経験を通り過ぎていくイメージ。","eg":"It took him a long time to get over losing his job.","terms":[["get over + 名詞","breakup/illness/shock などの名詞と相性が良い"],["get over on（誤用）","不要な前置詞を加えた誤り"]],"think":"立ち直りの描写文→動詞は get→前置詞は over。","vs":"直訳肢の climb over ... like a wall は over を「壁を乗り越える」という物理的な意味で過剰に直訳した不自然な表現。get over on は不要な前置詞を加えた誤用。最後の肢は move on from という別のチャンクへの言い換えで、意味は近いがこの設問が問う get over 特有の表現とはずれる。","why_asked":"IELTS Speaking Part 2 の困難克服のエピソード、CAE Speaking Part 2 の感情の回復描写で頻出。","usecase":"つらい経験や失恋から立ち直るまでの過程を説明する自然な言い方。","opt":["正解。get over が精神的な立ち直りを示す標準形。","壁として過剰に直訳した表現。","不要な前置詞を加えた誤用。","別チャンクへの言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3c-q18', '感情・反応系',
   '〔フォーマル〕彼はようやく、自分の限界を受け入れることができた。',
   NULL::text,
   '["He finally came to terms with his own limitations.","He finally arrived at the words with his own limitations.","He finally came to terms on his own limitations.","He basically finally made peace with his limits, yeah."]',
   0, '[0]', 'single',
   '{"asked":"困難な事実の受容を come to terms with でフォーマルに述べられるか。","point":"come to terms with＝（つらい事実を）受け入れる。抵抗や否定を経て、最終的に現実を認めるプロセスを示すフォーマルな表現。","kid":"come to terms with＝条件（terms）に合意する。自分と現実との間で、ようやく折り合いをつけるイメージ。","eg":"It took years for the family to come to terms with the loss.","terms":[["come to terms with + 名詞","limitations/loss/diagnosis などの名詞と相性が良い"],["come to terms on（誤用）","前置詞は with 固定、on は誤り"]],"think":"受容のプロセスを述べる文→動詞は come→名詞句 to terms→前置詞 with。","vs":"直訳肢の arrived at the words with は terms を「言葉」という意味で文字通り誤解した不自然な直訳。come to terms on は前置詞の誤用。最後の肢は made peace with/yeah という別の慣用句への言い換えで、意味は近いがこの設問が問う表現とはずれ、口語的すぎてフォーマルな場面にも不適。","why_asked":"CAE Reading の心理・人生経験記事、IELTS Writing の困難受容パラグラフで頻出。","usecase":"つらい事実や限界を最終的に受け入れたことをフォーマルに説明する定型表現。","opt":["正解。came to terms with が困難な事実の受容を示す標準形。","termsを言葉として誤解した直訳。","前置詞の誤用。","別の慣用句への言い換えでフォーマルな場面に不適。"]}'),

  ('pv-t3c-q19', '感情・反応系',
   '〔中立〕悲しい知らせを聞いて、彼女は泣き崩れた。',
   NULL::text,
   '["She broke down in tears upon hearing the sad news.","She broke her body down into pieces in tears upon hearing the sad news.","She broke down out in tears upon hearing the sad news.","She basically just lost it and started crying, yeah."]',
   0, '[0]', 'single',
   '{"asked":"精神的な崩壊・号泣を break down で述べられるか。","point":"break down＝（感情的に）崩れる・泣き崩れる。精神的な抑制が効かなくなる様子を示す最頻出表現。","kid":"break down＝壊れて機能しなくなる。機械が壊れるように、感情のコントロールが効かなくなるイメージ。","eg":"He broke down when he heard about his grandfather''s passing.","terms":[["break down in tears","tears を伴って泣き崩れる様子を示す定型"],["break down out（誤用）","不要な語を加えた誤り"]],"think":"感情の崩壊を述べる文→動詞は break→粒子は down。","vs":"直訳肢の broke her body down into pieces は break down を「体が粉々に壊れる」という物理的な意味で過剰に直訳した不自然な表現。break down out は不要な語を加えた誤用。最後の肢は lost it/yeah など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 の感情的なエピソード、CAE Speaking Part 2 の悲しみの描写で頻出。","usecase":"悲しい知らせを聞いて感情的に崩れたことを説明する自然な言い方。","opt":["正解。broke down が精神的な崩壊を示す標準形。","身体的な崩壊として過剰に直訳した表現。","不要な語を加えた誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3c-q20', '感情・反応系',
   '〔口語〕忙しい一週間の後、運動をしてストレスを発散した。',
   NULL::text,
   '["After a busy week, she went for a run to let off steam.","After a busy week, she released hot steam physically from a machine to let off steam.","After a busy week, she went for a run to let off the steam out.","Following an arduous week, she engaged in physical exercise to alleviate accumulated stress."]',
   0, '[0]', 'single',
   '{"asked":"ストレス発散を let off steam で口語的に述べられるか。","point":"let off steam＝ストレスを発散する。蒸気機関が余分な蒸気を逃がすイメージから転じた、感情発散を示す口語の定番慣用句。","kid":"let off steam＝溜まった蒸気を逃がす。圧力鍋の蒸気を抜くように、溜まったストレスを外に出すイメージ。","eg":"He plays basketball on weekends just to let off steam.","terms":[["let off steam","慣用句として一体で覚える定型表現"],["let off the steam out（誤用）","steam の前に the を付け、さらに out を加えた冗長な誤り"]],"think":"ストレス発散の口語描写→動詞は let→目的語句 off steam。","vs":"直訳肢の released hot steam physically from a machine は steam を文字通り「機械の蒸気」として過剰に説明した不自然な表現。let off the steam out は不要な語を加えた誤用。最後の肢は arduous week/alleviate accumulated stress など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"IELTS Speaking Part 1 のストレス解消トピック、CAE Speaking Part 1 の余暇活動で頻出の慣用句。","usecase":"忙しさで溜まったストレスを運動などで発散したことをカジュアルに話す言い方。","opt":["正解。let off steam がストレス発散を示す口語標準形。","steamを機械の蒸気として過剰に直訳した表現。","不要な語を加えた誤用。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3c-q21', '感情・反応系',
   '〔中立〕些細なことで、彼は突然妻に激怒した。',
   NULL::text,
   '["He suddenly blew up at his wife over something minor.","He suddenly exploded like a bomb at his wife over something minor.","He suddenly blew up on his wife over something minor.","He basically lost his temper at his wife over nothing, yeah."]',
   0, '[0]', 'single',
   '{"asked":"突然の激怒を blow up at で述べられるか。","point":"blow up at＝（人に）突然激怒する。爆発するように急に怒りが噴き出すことを示す口語の定番表現。","kid":"blow up at＝爆発するように怒る。風船が突然パンと弾けるように、怒りが一気に噴出するイメージ。","eg":"She rarely blows up at her kids, but she was exhausted that day.","terms":[["blow up at + 人","wife/kids/colleague などの人の名詞と相性が良い"],["blow up on（誤用）","前置詞は at 固定、on は誤り"]],"think":"突然の激怒を述べる文→動詞は blow→粒子は up→前置詞 at。","vs":"直訳肢の exploded like a bomb at は blow up を「爆弾のように爆発する」という文字通りの意味で過剰に直訳した表現。blow up on は前置詞の誤用。最後の肢は lost his temper/over nothing/yeah という別の慣用句を使った口語表現で、意味は近いがこの設問が問う blow up at 特有の表現とはずれる。","why_asked":"CAE Speaking Part 2 の感情的なエピソード、IELTS Speaking Part 3 の対立・怒りトピックで頻出。","usecase":"些細な理由で突然誰かに激怒したことを説明する自然な言い方。","opt":["正解。blew up at が突然の激怒を示す標準形。","爆弾として過剰に直訳した表現。","前置詞の誤用。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3c-q22', '感情・反応系',
   '〔中立〕彼女は批判を気にせず、軽く受け流した。',
   NULL::text,
   '["She brushed off the criticism without letting it bother her.","She used a brush to sweep the criticism off without letting it bother her.","She brushed out the criticism without letting it bother her.","She basically just shrugged it off, no big deal, yeah."]',
   0, '[0]', 'single',
   '{"asked":"批判を軽く受け流すことを brush off で述べられるか。","point":"brush off＝（批判・指摘を）軽く受け流す・意に介さない。ブラシで軽く払いのけるイメージの表現。","kid":"brush off＝ブラシで払い落とす。服についたほこりを払うように、気にせず受け流すイメージ。","eg":"He brushed off the negative reviews and kept working.","terms":[["brush off + 名詞","criticism/comment/insult などの名詞と相性が良い"],["brush out（誤用）","「（髪などを）ブラシでとかして整える」で全く別の意味"]],"think":"批判への反応を述べる文→動詞は brush→粒子は off。","vs":"直訳肢の used a brush to sweep ... off は brush を「道具のブラシ」として文字通り過剰に説明した不自然な表現。brush out は「（髪をブラシでとかす）」という全く別の意味になる誤用トラップ。最後の肢は shrugged it off/no big deal/yeah という別の慣用句への言い換えで、意味は近いがこの設問が問う brush off 特有の表現とはずれる。","why_asked":"CAE Speaking Part 3 の批判への対応トピック、IELTS Speaking Part 3 のストレス対処で頻出。","usecase":"批判を気にせず軽く受け流したことを説明する自然な言い方。","opt":["正解。brushed off が批判を軽く受け流すことを示す標準形。","道具のブラシとして過剰に直訳した表現。","brush out は全く別の意味。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'pv-t3-c'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
