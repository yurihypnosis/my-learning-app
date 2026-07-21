-- 英語・句動詞（Set T2-B）: 議論動詞20問（検討・判断系10／継続・断念系10）
-- question-authoring-pv スキル準拠。docs/pv-seed-strategy.md により継続投入（pv-t1-a/b, pv-t2-a に続く）。
BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('pv-t2-b',
        '英語・句動詞（Set T2-B）',
        '【Speak-First】日本語の場面を見たら、選択肢を見る前に3秒以内で英文を声に出す。言ってから表示。口で言えなかったら解答後にチップを押す。',
        '#6ab08d', 94, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('検討・判断系', '#c084fc', 1),
  ('継続・断念系', '#facc15', 2)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'pv-t2-b'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('pv-t2b-q01', '検討・判断系',
   '〔フォーマル〕決断する前に、両方の選択肢の長所と短所を比較検討する。',
   NULL::text,
   '["Before deciding, we should weigh up the pros and cons of both options.","Before deciding, we should put the pros and cons of both options on a scale to measure the weight.","Before deciding, we should weigh in the pros and cons of both options.","Before deciding, we should basically think about the good and bad stuff, you know."]',
   0, '[0]', 'single',
   '{"asked":"比較検討を weigh up で述べられるか。","point":"weigh up＝（両方の要素を天秤にかけて）比較検討する。決断前の慎重な検討を示す定番表現。","kid":"weigh up＝天秤で重さを量る。長所と短所を両手に乗せて比べるイメージ。","eg":"It is worth weighing up the risks before investing.","terms":[["weigh up + 名詞","pros and cons/risks and benefits などの名詞と相性が良い"],["weigh in（誤用）","「意見を述べる・体重を量る」で全く別の意味"]],"think":"決断前の検討文→比較する→動詞は weigh→粒子は up。","vs":"直訳肢の put ... on a scale to measure the weight は weigh を文字通り「重さを量る」と直訳した過剰な表現。weigh in は「議論に割って入って意見を述べる」という別の意味になる誤用トラップ。最後の肢は good and bad stuff/you know など口語表現でフォーマルな検討文に不適。","why_asked":"CAE Speaking Part 3 の意思決定トピック、IELTS Writing Task 2 の両論併記パラグラフで頻出。","usecase":"決断前に選択肢を比較検討することを説明する定型表現。","opt":["正解。weigh up が比較検討の標準形。","weighを文字通り直訳した過剰な表現。","weigh in は全く別の意味。","口語すぎてフォーマルな検討文に不適。"]}'),

  ('pv-t2b-q02', '検討・判断系',
   '〔中立〕その申し出について、一晩よく考えたいと伝える。',
   NULL::text,
   '["She said she wanted to think over the offer for a night.","She said she wanted to think the offer over inside her head for a night.","She said she wanted to think out the offer for a night.","She was basically like, gotta think about it overnight, yeah."]',
   0, '[0]', 'single',
   '{"asked":"じっくり考える意向を think over で述べられるか。","point":"think over＝（決定前に）じっくり考える。即答を避けて時間をかけて検討する意向を示す定番表現。","kid":"think over＝考えを行き来させる。案の上を何度も思考が通り過ぎるイメージ。","eg":"Can I think it over and get back to you tomorrow?","terms":[["think over + 名詞","offer/proposal/decision などの名詞と相性が良い"],["think out（誤用寄り）","「考え抜いて解決策を出す」で単に検討時間が欲しいというニュアンスとは異なる"]],"think":"検討の意向を伝える文→動詞は think→粒子は over。","vs":"直訳肢の think the offer over inside her head は「頭の中で」を余計に付け足した冗長な直訳。think out は「考え抜いて答えを出す」という結果志向のニュアンスが強く、単に時間が欲しいという think over とはずれる近義語トラップ。最後の肢は gotta/like/yeah など口語表現で丁寧な意向表明としては砕けすぎる。","why_asked":"CAE Speaking Part 2・4 の意思決定表現、IELTS Speaking Part 3 の熟考表現で頻出。","usecase":"即答を避けて検討時間が欲しいことを丁寧に伝える定型表現。","opt":["正解。think over が検討の意向を示す標準形。","冗長な直訳調。","think out は結果志向のニュアンスでずれる。","口語すぎて丁寧な意向表明に不適。"]}'),

  ('pv-t2b-q03', '検討・判断系',
   '〔中立〕長い議論の末、チームは一つの案に決めた。',
   NULL::text,
   '["After a long discussion, the team settled on one option.","After a long discussion, the team made itself settle down on one option.","After a long discussion, the team settled in one option.","After going back and forth forever, the team basically just picked one, finally."]',
   0, '[0]', 'single',
   '{"asked":"議論の末の決定を settle on で述べられるか。","point":"settle on＝（複数の候補から）一つに決める。議論やブレインストーミングの締めくくりで使う定番表現。","kid":"settle on＝落ち着いて一つの上に定まる。ふわふわ揺れていた議論が一点に落ち着くイメージ。","eg":"After reviewing several designs, the client settled on the simplest one.","terms":[["settle on + 名詞","option/design/name などの名詞と相性が良い"],["settle in（誤用）","「新しい環境に慣れる」で全く別の意味"]],"think":"決定の文→一つに決める→動詞は settle→前置詞は on。","vs":"直訳肢の made itself settle down on は settle down（落ち着く・定住する）と settle on を混同した不自然な直訳。settle in は「新しい環境に慣れる」という全く別の意味になる誤用トラップ。最後の肢は forever/finally など口語表現で中立的な報告文としてはやや大げさ。","why_asked":"CAE Speaking Part 4 の意思決定プロセス、IELTS Writing のプロセス説明パラグラフで頻出。","usecase":"議論やブレインストーミングの末に一つの案に決まったことを説明する定型。","opt":["正解。settle on が決定を示す標準形。","settle downと混同した不自然な直訳。","settle in は全く別の意味。","口語すぎてやや大げさな表現。"]}'),

  ('pv-t2b-q04', '検討・判断系',
   '〔フォーマル〕取締役会は、その買収案をしばらくじっくり検討する予定だ。',
   NULL::text,
   '["The board plans to mull over the acquisition proposal for a while.","The board plans to grind over the acquisition proposal for a while.","The board plans to mull on the acquisition proposal for a while.","The board is basically gonna chew on the buyout thing for a bit."]',
   0, '[0]', 'single',
   '{"asked":"時間をかけたじっくりとした検討を mull over で述べられるか。","point":"mull over＝（時間をかけて）じっくり熟考する。取締役会や重要な決定の場面で使う格式高い表現。","kid":"mull over＝ゆっくりこねるように考える。ワインを温めてゆっくり味を出すように、案をじっくり練るイメージ。","eg":"The committee is mulling over several candidates for the position.","terms":[["mull over + 名詞","proposal/idea/decision などの名詞と相性が良い"],["mull on（誤用）","前置詞は over 固定、on は誤り"]],"think":"取締役会の検討文→じっくり熟考する→動詞は mull→粒子は over。","vs":"直訳肢の grind over は mull を「挽く・すりつぶす」という別の語 grind と混同した誤った直訳。mull on は前置詞の誤用。最後の肢は gonna/chew on/buyout thing など口語表現でフォーマルな取締役会の文脈に不適。","why_asked":"CAE Reading の企業意思決定記事、IELTS Writing のフォーマルな熟考表現で頻出。","usecase":"経営層が重要な決定を時間をかけて検討していることを述べる定型表現。","opt":["正解。mull over がじっくりとした熟考を示す標準形。","動詞を混同した誤った直訳。","前置詞の誤用。","口語すぎて取締役会の文脈に不適。"]}'),

  ('pv-t2b-q05', '検討・判断系',
   '〔中立〕即答せず、一晩考えさせてほしいと頼む。',
   NULL::text,
   '["He asked for a night to sleep on the decision before answering.","He asked to sleep physically on top of the decision before answering.","He asked for a night to sleep in the decision before answering.","He basically said give me a night, gotta sleep on it, yeah."]',
   0, '[0]', 'single',
   '{"asked":"一晩考える猶予を sleep on で述べられるか。","point":"sleep on＝一晩寝かせて考える。即答を避けて翌日まで結論を持ち越すときの定番の慣用表現。","kid":"sleep on＝決定の上に寝る。答えの上でぐっすり眠って、翌朝すっきり考え直すイメージ。","eg":"I would rather sleep on it before giving you a final answer.","terms":[["sleep on + 名詞","decision/offer/it などの名詞と相性が良い"],["sleep in（誤用）","「朝寝坊する」で全く別の意味"]],"think":"猶予を求める文→一晩考える→動詞は sleep→前置詞は on。","vs":"直訳肢の sleep physically on top of は「物理的にその上に寝る」という文字通りの意味に直訳した不自然な表現。sleep in は「朝寝坊する」という全く別の意味になる誤用トラップ。最後の肢は gotta/yeah など口語表現で丁寧な依頼文としては砕けすぎる。","why_asked":"CAE Speaking Part 2 の意思決定表現、IELTS Speaking Part 3 の熟考の慣用句として頻出。","usecase":"即答を避けて一晩考える猶予を丁寧に求める定型表現。","opt":["正解。sleep on が一晩の熟考を示す標準形。","物理的な意味に直訳した不自然な表現。","sleep in は全く別の意味。","口語すぎて丁寧な依頼に不適。"]}'),

  ('pv-t2b-q06', '検討・判断系',
   '〔フォーマル〕チームは、複雑な問題を順を追って検討する必要がある。',
   NULL::text,
   '["The team needs to work through the complex issue step by step.","The team needs to work by passing through the complex issue step by step.","The team needs to work out the complex issue step by step.","The team basically has to wade through the messy issue bit by bit, I guess."]',
   0, '[0]', 'single',
   '{"asked":"順を追った検討過程を work through で述べられるか。","point":"work through＝（問題を）順を追って検討する。結果よりも過程そのものに焦点を当てる表現。","kid":"work through＝通り抜けるように作業する。複雑な問題を一つずつくぐり抜けていくイメージ。","eg":"We need to work through each scenario before making a decision.","terms":[["work through + 名詞","issue/problem/scenario などの名詞と相性が良い"],["work out（誤用寄り）","「解決する・答えを出す」で結果に焦点があり、検討過程を示す work through とはニュアンスが異なる"]],"think":"検討過程の文→段階的に検討する→動詞は work→粒子は through。","vs":"直訳肢の work by passing through は through の意味を by passing through と冗長に言い換えた不自然な表現。work out は「解決する」という結果志向のニュアンスが強く、work through が持つ「過程を順に検討する」という意味合いが弱い近義語トラップ。最後の肢は wade through/bit by bit/I guess など口語表現でフォーマルな検討文に不適。","why_asked":"CAE Reading のプロセス説明記事、IELTS Writing のプロセス・手順パラグラフで頻出。","usecase":"複雑な問題を段階的に検討する必要性を説明する定型表現。","opt":["正解。work through が段階的検討を示す標準形。","throughを冗長に言い換えた不自然な表現。","work out は結果志向でニュアンスが異なる。","口語すぎてフォーマルな検討文に不適。"]}'),

  ('pv-t2b-q07', '検討・判断系',
   '〔中立〕会議の前に、いくつかの重要な問題を整理して決めておく必要がある。',
   NULL::text,
   '["We need to sort out a few key issues before the meeting.","We need to put in order a few key issues before the meeting.","We need to sort in a few key issues before the meeting.","We basically gotta sort a few things before the meeting, yeah."]',
   0, '[0]', 'single',
   '{"asked":"問題の整理・解決を sort out で述べられるか。","point":"sort out＝（問題を）整理して解決する。会議前の準備や課題処理を示す最頻出動詞の一つ。","kid":"sort out＝分類して外に出す。散らかった問題を仕分けして片付けるイメージ。","eg":"Let us sort out the logistics before the trip.","terms":[["sort out + 名詞","issues/problems/details などの名詞と相性が良い"],["sort in（誤用）","前置詞は out 固定、in は誤り"]],"think":"準備の文→問題を整理して片付ける→動詞は sort→粒子は out。","vs":"直訳肢の put in order は sort out の意味を別の表現で説明的に言い換えた冗長な直訳。sort in は前置詞の誤用。最後の肢は gotta/yeah など口語表現で中立的な準備の説明としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 4 の準備・計画トピック、IELTS Writing のプロセス説明で頻出。","usecase":"会議や作業の前に問題を整理・解決しておくことを述べる定型表現。","opt":["正解。sort out が問題整理を示す標準形。","説明的に言い換えた冗長な直訳。","前置詞の誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t2b-q08', '検討・判断系',
   '〔中立〕この問題の最適な解決策をまだ見出せていない。',
   NULL::text,
   '["We have not yet figured out the best solution to this problem.","We have not yet calculated with our fingers the best solution to this problem.","We have not yet figured in the best solution to this problem.","We basically have not worked it out yet, kinda stuck, you know."]',
   0, '[0]', 'single',
   '{"asked":"解決策の模索を figure out で述べられるか。","point":"figure out＝（考えて）解決策を見出す・理解する。試行錯誤の末に答えにたどり着くニュアンスの定番表現。","kid":"figure out＝図（figure）を描くように理解する。頭の中でパズルのピースを組み立てて答えを出すイメージ。","eg":"It took us weeks to figure out what was causing the error.","terms":[["figure out + 名詞","solution/answer/what is going on などの名詞・節と相性が良い"],["figure in（誤用）","「考慮に入れる」で全く別の意味"]],"think":"未解決の状況を述べる文→解決策を見出す→動詞は figure→粒子は out。","vs":"直訳肢の calculated with our fingers は figure を「指で数える」と文字通り直訳した過剰な表現。figure in は「（要因として）考慮に入れる」という全く別の意味になる誤用トラップ。最後の肢は worked it out/kinda stuck/you know など口語表現で中立的な報告文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 3 の問題解決トピック、IELTS Writing のプロセス・課題説明で頻出。","usecase":"未解決の問題に対してまだ答えが見出せていないことを説明する定型表現。","opt":["正解。figure out が解決策の模索を示す標準形。","figureを文字通り直訳した過剰な表現。","figure in は全く別の意味。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t2b-q09', '検討・判断系',
   '〔フォーマル〕両者は、契約の細部を議論して詰める必要がある。',
   NULL::text,
   '["Both parties need to hash out the details of the contract.","Both parties need to chop and mix up the details of the contract like hash.","Both parties need to hash over the details of the contract.","Both sides basically gotta hammer out the nitty-gritty, yeah."]',
   0, '[0]', 'single',
   '{"asked":"議論を通じて細部を詰めることを hash out で述べられるか。","point":"hash out＝（議論を重ねて）細部を詰める。交渉や契約締結の場面で使う定番のビジネス表現。","kid":"hash out＝細かく刻んで混ぜ合わせる。料理のハッシュのように、意見を細かく刻んで一つにまとめるイメージ。","eg":"The two companies spent weeks hashing out the terms of the merger.","terms":[["hash out + 名詞","details/terms/differences などの名詞と相性が良い"],["hash over（誤用）","標準は hash out。over を使う形は一般的でない誤用"]],"think":"契約交渉の文→議論して詰める→動詞は hash→粒子は out。","vs":"直訳肢の chop and mix up ... like hash は hash を料理の「ハッシュ」として文字通り説明しすぎた不自然な表現。hash over は標準的でない誤用形。最後の肢は hammer out/nitty-gritty/yeah など口語表現でフォーマルな契約交渉の文脈に不適だが、hammer out自体は近い意味を持つ近義語でもある。","why_asked":"CAE Reading のビジネス交渉記事、IELTS Writing の交渉プロセス説明で頻出。","usecase":"契約や合意の細部を議論して詰めることを説明する定型表現。","opt":["正解。hash out が細部を詰めることを示す標準形。","hashを料理として直訳しすぎた表現。","hash over は標準的でない誤用形。","口語すぎてフォーマルな交渉に不適。"]}'),

  ('pv-t2b-q10', '検討・判断系',
   '〔中立〕発表の前に、スライドを一通り確認しておく。',
   NULL::text,
   '["Let us run through the slides once before the presentation.","Let us run with our legs through the slides once before the presentation.","Let us run over the slides once before the presentation.","Let us basically just skim the slides real quick, yeah."]',
   0, '[0]', 'single',
   '{"asked":"一通りの確認を run through で述べられるか。","point":"run through＝（内容を）一通り確認する・リハーサルする。発表前の最終確認で使う定番表現。","kid":"run through＝走り抜けるように一通り目を通す。最初から最後まで素早く確認するイメージ。","eg":"Let us run through the agenda before the client arrives.","terms":[["run through + 名詞","slides/agenda/script などの名詞と相性が良い"],["run over（誤用）","「（車で）轢く」「時間を超過する」で全く別の意味"]],"think":"発表前の確認文→一通り確認する→動詞は run→粒子は through。","vs":"直訳肢の run with our legs through は「足で走る」という身体動作を過剰に直訳した不自然な表現。run over は「（車で）轢く」「時間を超過する」という全く別の意味になる重要な誤用トラップ。最後の肢は skim/real quick/yeah など口語表現で発表準備の説明としてはやや軽すぎる。","why_asked":"CAE Speaking Part 4 のプレゼン準備トピック、IELTS Writing のプロセス説明で頻出。","usecase":"発表や会議の前に内容を一通り確認することを述べる定型表現。","opt":["正解。run through が一通りの確認を示す標準形。","身体動作を過剰に直訳した表現。","run over は全く別の意味。","口語すぎてやや軽すぎる表現。"]}'),

  ('pv-t2b-q11', '継続・断念系',
   '〔中立〕この作業のペースを維持するのは難しいと感じている。',
   NULL::text,
   '["She finds it difficult to keep up with the pace of this work.","She finds it difficult to keep her body up with the pace of this work.","She finds it difficult to keep on with the pace of this work.","She is basically struggling to keep pace, not gonna lie."]',
   0, '[0]', 'single',
   '{"asked":"ペースについていく難しさを keep up with で述べられるか。","point":"keep up with＝（ペース・水準に）ついていく。他者や状況の速さに追いつき続ける様子を示す定番表現。","kid":"keep up with＝一緒のペースを保つ。走る相手に遅れないよう並走し続けるイメージ。","eg":"It is hard to keep up with all the changes in this industry.","terms":[["keep up with + 名詞","pace/changes/demand などの名詞と相性が良い"],["keep on（誤用寄り）","「続ける」の意味で、ペースに「ついていく」ニュアンスが弱い"]],"think":"苦労を述べる文→ペースについていく→動詞は keep→粒子は up→前置詞 with。","vs":"直訳肢の keep her body up with は「体を保つ」という身体的な直訳で不自然な表現。keep on は単に「続ける」の意味が強く、keep up with が持つ「追いつき続ける」という核心的ニュアンスが弱い近義語トラップ。最後の肢は not gonna lie など口語表現で中立的な説明文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 3 の仕事・生活トピック、IELTS Speaking Part 3 のペース描写で頻出。","usecase":"仕事や変化のペースについていく難しさを説明する自然な言い方。","opt":["正解。keep up with がペースへの追随を示す標準形。","身体的な直訳で不自然な表現。","keep on はニュアンスが弱い近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t2b-q12', '継続・断念系',
   '〔フォーマル〕悪天候にもかかわらず、チームは登頂を目指して進み続けた。',
   NULL::text,
   '["Despite the bad weather, the team pressed on toward the summit.","Despite the bad weather, the team pushed with pressure toward the summit.","Despite the bad weather, the team pressed in toward the summit.","Despite the bad weather, the team basically kept going, no big deal."]',
   0, '[0]', 'single',
   '{"asked":"困難にもかかわらず進み続けることを press on で述べられるか。","point":"press on＝（困難があっても）進み続ける。決意を持って前進し続ける様子を示す格式高い表現。","kid":"press on＝押し進める。抵抗があっても前へ前へと押し進むイメージ。","eg":"Despite the setbacks, the researchers pressed on with the experiment.","terms":[["press on + 前置詞(toward/with)","目的地や作業対象を続く前置詞句で示す"],["press in（誤用）","前置詞は on 固定、in は誤り"]],"think":"困難下の継続文→進み続ける→動詞は press→粒子は on。","vs":"直訳肢の pushed with pressure は press を「圧力をかけて押す」と文字通り直訳した不自然な表現。press in は前置詞の誤用。最後の肢は no big deal など口語表現でフォーマルな報告文の決意のニュアンスが軽くなりすぎる。","why_asked":"CAE Reading の探検・プロジェクト記事、IELTS Writing の困難克服パラグラフで頻出。","usecase":"困難な状況でも目標に向かって進み続けたことを報告する定型表現。","opt":["正解。press on が困難下の継続を示す標準形。","pressを文字通り直訳した不自然な表現。","前置詞の誤用。","口語すぎて決意のニュアンスが軽くなる。"]}'),

  ('pv-t2b-q13', '継続・断念系',
   '〔中立〕契約に署名する土壇場で、彼は取引から手を引いた。',
   NULL::text,
   '["At the last minute, he backed out of the deal before signing.","At the last minute, he walked his back out of the deal before signing.","At the last minute, he backed off the deal before signing.","At the last minute, he basically bailed on the deal, yikes."]',
   0, '[0]', 'single',
   '{"asked":"土壇場での離脱を back out of で述べられるか。","point":"back out of＝（約束・合意から）土壇場で手を引く。合意直前の離脱を示す定番表現。","kid":"back out of＝後ずさりして外へ出る。一度は前に進んでいたのに、後ろに下がって抜け出るイメージ。","eg":"She backed out of the trip at the last minute due to illness.","terms":[["back out of + 名詞","deal/agreement/plan などの名詞と相性が良い"],["back off（誤用寄り）","「後退する・引き下がる」で似ているが、合意からの離脱という決定的な意味合いがやや弱い"]],"think":"土壇場の離脱文→動詞は back→粒子は out→前置詞 of。","vs":"直訳肢の walked his back out of は back を身体部位として直訳した不自然な表現。back off は「後退する・引き下がる」という似た意味だが、back out of が持つ「約束や合意から完全に離脱する」という決定的なニュアンスがやや弱い近義語トラップ。最後の肢は bailed on/yikes など口語表現で中立的な報告文としては砕けすぎる。","why_asked":"CAE Reading の契約・交渉決裂記事、IELTS Writing の計画変更パラグラフで頻出。","usecase":"合意直前に取引や約束から手を引いたことを説明する定型表現。","opt":["正解。back out of が土壇場の離脱を示す標準形。","backを身体部位として直訳した表現。","back off はニュアンスがやや弱い近義語。","口語すぎて中立的な報告に不適。"]}'),

  ('pv-t2b-q14', '継続・断念系',
   '〔中立〕中断にもかかわらず、講師は説明を続けた。',
   NULL::text,
   '["Despite the interruption, the instructor carried on with the explanation.","Despite the interruption, the instructor carried the explanation on his shoulder.","Despite the interruption, the instructor carried out with the explanation.","Despite the interruption, the instructor basically just kept talking, whatever."]',
   0, '[0]', 'single',
   '{"asked":"中断後の再開・継続を carry on with で述べられるか。","point":"carry on with＝（中断があっても）続ける。日常的な継続を示す定番表現で、carry out（実施する）とは構文が異なる。","kid":"carry on with＝そのまま運び続ける。中断があっても、荷物を運ぶように作業を続けるイメージ。","eg":"Please carry on with your work; do not let me interrupt you.","terms":[["carry on with + 名詞","explanation/work/discussion などの名詞と相性が良い"],["carry out（誤用）","「実施する」という別の構文・意味で、carry on with の代わりにはならない"]],"think":"中断後の継続文→動詞は carry→粒子は on→前置詞 with。","vs":"直訳肢の carried the explanation on his shoulder は carry を「肩に担いで運ぶ」と文字通り直訳した不自然な表現。carry out は「実施する」という別の意味・構文になる誤用トラップ（with を伴わない他動詞用法が標準）。最後の肢は kept talking/whatever など口語表現で中立的な報告文としてはややぞんざい。","why_asked":"CAE Reading の講義・授業記事、IELTS Writing のプロセス継続の説明で頻出。","usecase":"中断があっても作業や説明を続けたことを説明する定型表現。","opt":["正解。carry on with が中断後の継続を示す標準形。","carryを文字通り直訳した不自然な表現。","carry out は別の意味・構文になる誤用。","口語すぎてぞんざいな表現。"]}'),

  ('pv-t2b-q15', '継続・断念系',
   '〔中立〕何度も失敗したにもかかわらず、彼女は決してあきらめなかった。',
   NULL::text,
   '["Despite repeated failures, she never gave up.","Despite repeated failures, she never gave her effort up to the sky.","Despite repeated failures, she never gave in.","Despite repeated failures, she basically never threw in the towel, no way."]',
   0, '[0]', 'single',
   '{"asked":"あきらめないことを give up で述べられるか（否定形）。","point":"give up＝あきらめる。否定形 never gave up で「決してあきらめなかった」という最も中立的で汎用性の高い表現。","kid":"give up＝手放してあきらめる。持っていた努力や希望を手から離してしまうイメージ。","eg":"He never gave up on his dream, no matter how many times he failed.","terms":[["give up（自動詞/他動詞）","目的語なしでも、on + 名詞を伴っても使える"],["give in（誤用寄り）","「（圧力や要求に）屈する」で、あきらめるという意味とは微妙にニュアンスが異なる"]],"think":"不屈の精神を述べる文→動詞は give→粒子は up。","vs":"直訳肢の gave her effort up to the sky は「努力を空に手放す」という過剰な比喩の直訳。give in は「圧力に屈する」という意味合いが強く、give up が持つ「努力や希望を手放す」というニュアンスとはややずれる近義語トラップ。最後の肢は threw in the towel という別の慣用句を使っており意味は近いが、give up 特有の表現を問う設問としては別チャンクへの言い換えになってしまう。","why_asked":"CAE Speaking Part 3 の忍耐・不屈トピック、IELTS Writing の人物描写パラグラフで最頻出。","usecase":"困難にもかかわらずあきらめなかったことを説明する最も基本的な表現。","opt":["正解。never gave up があきらめなかったことを示す標準形。","過剰な比喩の直訳。","give in はニュアンスがずれる近義語。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t2b-q16', '継続・断念系',
   '〔中立〕彼は経済的な理由で大学を中退した。',
   NULL::text,
   '["He dropped out of university for financial reasons.","He fell out of university downward for financial reasons.","He dropped off university for financial reasons.","He basically quit uni because of money stuff, yeah."]',
   0, '[0]', 'single',
   '{"asked":"中退・脱落を drop out of で述べられるか。","point":"drop out of＝（学校・プログラムなどを）中退する・脱落する。教育や競技の文脈で最も標準的な表現。","kid":"drop out of＝ぽとりと落ちて外に出る。集団やコースから途中で外れ落ちるイメージ。","eg":"Nearly 10% of students drop out of the programme in the first year.","terms":[["drop out of + 名詞","university/school/programme などの名詞と相性が良い"],["drop off（誤用）","「送り届ける」「徐々に減る」で全く別の意味"]],"think":"中退の報告文→動詞は drop→粒子は out→前置詞 of。","vs":"直訳肢の fell out of ... downward は drop を fall と混同し、さらに downward を余計に加えた不自然な直訳。drop off は「（人を）送り届ける」「徐々に減少する」という全く別の意味になる誤用トラップ。最後の肢は quit uni/money stuff/yeah など口語表現で客観的な報告文としては砕けすぎる。","why_asked":"CAE Reading の教育統計記事、IELTS Writing Task 1 の教育データ説明で頻出。","usecase":"経済的・個人的理由で学業を中退したことを客観的に説明する定型表現。","opt":["正解。dropped out of が中退を示す標準形。","動詞を混同し余計な語を加えた不自然な直訳。","drop off は全く別の意味。","口語すぎて客観的な報告に不適。"]}'),

  ('pv-t2b-q17', '継続・断念系',
   '〔フォーマル〕最終合意の直前に、投資家は取引から撤退した。',
   NULL::text,
   '["Just before the final agreement, the investor pulled out of the deal.","Just before the final agreement, the investor pulled its body out of the deal.","Just before the final agreement, the investor pulled off the deal.","Just before the final agreement, the investor basically ditched the deal, whoa."]',
   0, '[0]', 'single',
   '{"asked":"投資・交渉からの撤退を pull out of で述べられるか。","point":"pull out of＝（合意・交渉から）撤退する。ビジネスの合意直前の離脱を示す定番のフォーマル表現。","kid":"pull out of＝引っ張って外に出る。関わっていた案件から自分を引き抜くイメージ。","eg":"The company pulled out of the merger talks after the audit findings.","terms":[["pull out of + 名詞","deal/negotiation/agreement などの名詞と相性が良い"],["pull off（誤用）","「（難しいことを）見事にやり遂げる」で正反対に近い意味"]],"think":"撤退の報告文→動詞は pull→粒子は out→前置詞 of。","vs":"直訳肢の pulled its body out of は pull を身体的動作として直訳した不自然な表現。pull off は「（困難なことを）見事にやり遂げる」という正反対に近い意味になる重要な誤用トラップ。最後の肢は ditched/whoa など口語表現でフォーマルな投資報告に不適。","why_asked":"CAE Reading のM&A・投資記事、IELTS Writing の契約変更パラグラフで頻出。","usecase":"投資家や企業が合意直前に取引から撤退したことを報告する定型表現。","opt":["正解。pulled out of が撤退を示す標準形。","身体的動作として直訳した不自然な表現。","pull off は正反対に近い意味。","口語すぎてフォーマルな投資報告に不適。"]}'),

  ('pv-t2b-q18', '継続・断念系',
   '〔中立〕批判にもかかわらず、彼は当初の計画を貫いた。',
   NULL::text,
   '["Despite the criticism, he stuck with the original plan.","Despite the criticism, he glued himself with the original plan.","Despite the criticism, he stuck out the original plan.","Despite the criticism, he basically stuck to his guns, no matter what."]',
   0, '[0]', 'single',
   '{"asked":"方針の一貫性を stick with で述べられるか。","point":"stick with＝（計画・方針を）貫く・変えない。批判があっても当初の選択を維持する様子を示す定番表現。","kid":"stick with＝くっついて離れない。接着剤で貼り付けたように、選んだ計画から離れないイメージ。","eg":"Despite the poor early results, the coach stuck with his original strategy.","terms":[["stick with + 名詞","plan/decision/strategy などの名詞と相性が良い"],["stick out（誤用寄り）","「目立つ」「辛抱して耐える」で stick with とは異なる意味"]],"think":"方針維持の文→計画を貫く→動詞は stick→前置詞は with。","vs":"直訳肢の glued himself with は stick を「接着剤でくっつく」と文字通り直訳した不自然な表現。stick out は「目立つ」「辛抱して耐え抜く」という別の意味になる誤用トラップ。最後の肢は stuck to his guns という別の慣用句を使った口語表現で、意味は近いがこの設問が問う stick with 特有の表現とはずれる。","why_asked":"CAE Speaking Part 3 の意思決定の一貫性トピック、IELTS Writing の立場維持パラグラフで頻出。","usecase":"批判があっても当初の計画や方針を変えなかったことを説明する定型表現。","opt":["正解。stuck with が方針の維持を示す標準形。","stickを文字通り直訳した不自然な表現。","stick out は別の意味になる誤用。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t2b-q19', '継続・断念系',
   '〔口語〕もう遅いので、今日の作業はここで終わりにしようと提案する。',
   NULL::text,
   '["It is getting late, so let us call it a day.","It is getting late, so let us name it a day and stop.","It is getting late, so let us call it a night.","Given the lateness of the hour, one ought to conclude the work for today."]',
   0, '[0]', 'single',
   '{"asked":"作業の切り上げを口語で call it a day と言えるか。","point":"call it a day＝その日の作業をここで終わりにする。日中の作業や仕事を切り上げるときの口語の決まり文句。","kid":"call it a day＝これで一日とする。まだ続けられても、ここまでにしようと区切りをつけるイメージ。","eg":"We have covered a lot today, so let us call it a day.","terms":[["call it a day","慣用句として一体で覚える定型表現"],["call it a night（時間帯ミスマッチ）","夜の作業終了に使う表現で、日中の作業には a day が標準"]],"think":"口語での作業終了の提案→動詞は call→目的語 it a day。","vs":"直訳肢の name it a day and stop は call を name と混同した誤った直訳。call it a night は似た表現だが夜の終わりを指す言い方で、時間帯やニュアンスがこの場面とずれる近義語トラップ。最後の肢は one ought to/lateness of the hour など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 4 の日常会話表現、IELTS Speaking の作業終了表現で頻出の慣用句。","usecase":"同僚や友人にその日の作業を切り上げようとカジュアルに提案する言い方。","opt":["正解。call it a day が作業の切り上げを示す口語の標準形。","callをnameと混同した誤った直訳。","call it a night は時間帯がずれる近義語。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t2b-q20', '継続・断念系',
   '〔口語〕何度も挑戦した末、ついに彼はあきらめた。',
   NULL::text,
   '["After many attempts, he finally threw in the towel.","After many attempts, he finally threw a towel into the ring to give up.","After many attempts, he finally threw out the towel.","Following numerous unsuccessful endeavours, he ultimately conceded defeat."]',
   0, '[0]', 'single',
   '{"asked":"完全な断念を口語の慣用句 throw in the towel で言えるか。","point":"throw in the towel＝完全にあきらめる。ボクシングでセコンドがタオルを投げ入れて試合を止める動作に由来する口語表現。","kid":"throw in the towel＝タオルを投げ入れる。ボクシングの試合をやめさせる合図から、完全な断念を意味するようになった語。","eg":"After the third rejection, she finally threw in the towel and changed careers.","terms":[["throw in the towel","慣用句として一体で覚える定型表現。ボクシング由来"],["throw out（誤用）","「捨てる」で全く別の意味"]],"think":"口語での断念描写→動詞は throw→粒子は in→目的語 the towel。","vs":"直訳肢の threw a towel into the ring to give up は由来の説明を文中に加えすぎた冗長な直訳。throw out は「捨てる」という全く別の意味になる誤用トラップ。最後の肢は unsuccessful endeavours/conceded defeat など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 4 の口語表現力、IELTS Speaking Part 3 の断念の慣用句として頻出。","usecase":"何度も挑戦した末に完全にあきらめたことをカジュアルに描写する言い方。","opt":["正解。threw in the towel が完全な断念を示す口語の標準形。","由来を説明しすぎた冗長な直訳。","throw out は全く別の意味。","フォーマルすぎて口語の場面に不適。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'pv-t2-b'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
