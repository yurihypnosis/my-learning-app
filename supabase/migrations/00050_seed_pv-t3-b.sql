-- 英語・句動詞（Set T3-B）: 日常・語り22問（関係・対立系11／増減・変化系11）
-- question-authoring-pv スキル準拠。docs/pv-seed-strategy.md により継続投入（T1/T2/T3-A に続く）。
BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('pv-t3-b',
        '英語・句動詞（Set T3-B）',
        '【Speak-First】日本語の場面を見たら、選択肢を見る前に3秒以内で英文を声に出す。言ってから表示。口で言えなかったら解答後にチップを押す。',
        '#6ab08d', 114, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('関係・対立系', '#fb7185', 1),
  ('増減・変化系', '#22d3ee', 2)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'pv-t3-b'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('pv-t3b-q01', '関係・対立系',
   '〔中立〕新しい同僚とはとてもうまくやっている。',
   NULL::text,
   '["I get along with my new colleague really well.","I go together along with my new colleague really well.","I get along on my new colleague really well.","One maintains an excellent relationship with the new colleague."]',
   0, '[0]', 'single',
   '{"asked":"良好な人間関係を get along with で述べられるか。","point":"get along with＝（人と）うまくやっていく。日常会話で人間関係の良好さを述べる最頻出表現。","kid":"get along with＝一緒にうまく進んでいく。並んで歩くように、摩擦なく関係を続けるイメージ。","eg":"She gets along with almost everyone in the office.","terms":[["get along with + 人","colleague/sibling/neighbour などの人の名詞と相性が良い"],["get along on（誤用）","前置詞は with 固定、on は誤り"]],"think":"人間関係の描写文→動詞は get→粒子は along→前置詞 with。","vs":"直訳肢の go together along with は get を go と混同し along を重複させた不自然な直訳。get along on は前置詞の誤用。最後の肢は maintains an excellent relationship など極端にフォーマルな語彙で、中立的な日常描写としては重すぎる。","why_asked":"IELTS Speaking Part 1 の人間関係トピック、CAE Speaking Part 2 の同僚描写で最頻出。","usecase":"職場や学校で誰かとうまくやっていることを説明する自然な言い方。","opt":["正解。get along with が良好な関係を示す標準形。","動詞を混同した不自然な直訳。","前置詞の誤用。","フォーマルすぎて中立的な描写に不適。"]}'),

  ('pv-t3b-q02', '関係・対立系',
   '〔中立〕くだらないことで親友と仲違いした。',
   NULL::text,
   '["She fell out with her best friend over something trivial.","She fell down and went out with her best friend over something trivial.","She fell out on her best friend over something trivial.","She basically had a massive falling out with her bestie, ugh."]',
   0, '[0]', 'single',
   '{"asked":"仲違いを fall out with で述べられるか。","point":"fall out with＝（人と）仲違いする・けんかする。友人関係の破綻を示すイギリス英語由来の定番表現。","kid":"fall out with＝一緒にいたところから落ちて離れる。仲良しの関係から転げ落ちるイメージ。","eg":"The two brothers fell out with each other over the inheritance.","terms":[["fall out with + 人","best friend/colleague/sibling などの人の名詞と相性が良い"],["fall out on（誤用）","前置詞は with 固定、on は誤り"]],"think":"仲違いの描写文→動詞は fall→粒子は out→前置詞 with。","vs":"直訳肢の fell down and went out with は fall を「転ぶ」という文字通りの意味で誤解し、二文的に説明しすぎた不自然な表現。fall out on は前置詞の誤用。最後の肢は bestie/ugh などスラングで中立的な描写文としては砕けすぎる。","why_asked":"IELTS Speaking Part 2 の人間関係のエピソード、CAE Speaking Part 3 の対立トピックで頻出。","usecase":"些細な理由で友人と仲違いしたことを説明する自然な言い方。","opt":["正解。fall out with が仲違いを示す標準形。","fallを文字通り誤解し説明しすぎた表現。","前置詞の誤用。","スラングで中立的な描写に不適。"]}'),

  ('pv-t3b-q03', '関係・対立系',
   '〔中立〕大げんかの後、二人はついに仲直りした。',
   NULL::text,
   '["After a big argument, the two of them finally made up.","After a big argument, the two of them finally created themselves up again.","After a big argument, the two of them finally made out.","After a big argument, they basically kissed and made up, aw."]',
   0, '[0]', 'single',
   '{"asked":"仲直りを make up（自動詞）で述べられるか。","point":"make up＝仲直りする。けんかの後に関係を修復することを示す口語の定番表現（「構成する」の make up とは別の語義）。","kid":"make up＝再び作り直す。壊れかけた関係をもう一度組み立て直すイメージ。","eg":"They had a huge fight but made up by the end of the day.","terms":[["make up（自動詞）","目的語を取らず、関係修復そのものを表す"],["make out（誤用）","「ある程度うまくいく」「いちゃつく」で全く別の意味"]],"think":"仲直りの描写文→動詞は make→粒子は up。","vs":"直訳肢の created themselves up again は make を「作る」という文字通りの意味で誤解した不自然な表現。make out は「ある程度うまくいく」「いちゃつく」という全く別の意味になる誤用トラップ。最後の肢は kissed and make up/aw など別の慣用句を足した口語表現で、意味は近いがこの設問が問う make up 単体の表現とはずれる。","why_asked":"IELTS Speaking Part 2 の人間関係のエピソード、CAE Speaking Part 3 の対立解消トピックで頻出。","usecase":"けんかの後に関係を修復したことを説明する自然な言い方。","opt":["正解。made up が仲直りを示す標準形。","makeを文字通り誤解した不自然な表現。","make out は全く別の意味。","別の慣用句を足した表現でこの設問の狙いとずれる。"]}'),

  ('pv-t3b-q04', '関係・対立系',
   '〔口語〕二人は初対面からすぐに意気投合した。',
   NULL::text,
   '["They hit it off right from their first meeting.","They hit something and it went off right from their first meeting.","They hit it up right from their first meeting.","They established an immediate rapport upon their initial encounter."]',
   0, '[0]', 'single',
   '{"asked":"すぐに意気投合することを hit it off で述べられるか。","point":"hit it off＝すぐに意気投合する。初対面で自然に馬が合うことを示す口語の定番慣用句。","kid":"hit it off＝いきなりぴったりはまる。ボタンがカチッとはまるように、初対面から相性が良いイメージ。","eg":"We hit it off immediately and have been friends ever since.","terms":[["hit it off","it は特定の対象を指さない慣用句の一部。一体で覚える"],["hit up（誤用）","「（人に）連絡する」で全く別の意味"]],"think":"初対面の好印象を述べる文→動詞は hit→目的語 it→粒子 off。","vs":"直訳肢の hit something and it went off は it を「何か」として文字通り解釈し、慣用句を分解してしまった不自然な表現。hit up は「（人に）連絡する」という全く別の意味になる誤用トラップ。最後の肢は established an immediate rapport/initial encounter など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 2 の出会いのエピソード、IELTS Speaking Part 2 の人物紹介で頻出の慣用句。","usecase":"初対面からすぐに気が合ったことをカジュアルに話す言い方。","opt":["正解。hit it off が意気投合を示す口語標準形。","itを文字通り解釈し慣用句を分解した表現。","hit up は全く別の意味。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3b-q05', '関係・対立系',
   '〔中立〕彼はクラスメートにすっかり恋に落ちた。',
   NULL::text,
   '["He fell for a classmate almost immediately.","He fell down toward a classmate almost immediately.","He fell in a classmate almost immediately.","He basically caught feelings for a classmate, not gonna lie."]',
   0, '[0]', 'single',
   '{"asked":"恋に落ちることを fall for で述べられるか。","point":"fall for＝（人に）恋に落ちる。fall in love with より短くカジュアルに使える定番表現。","kid":"fall for＝〜に向かって落ちる。恋という落とし穴にすとんと落ちてしまうイメージ。","eg":"She fell for him the moment they met.","terms":[["fall for + 人","classmate/colleague などの人の名詞と相性が良い"],["fall in（誤用）","fall in love with の一部だけを取った不完全な形"]],"think":"恋愛描写の文→動詞は fall→前置詞は for。","vs":"直訳肢の fell down toward は fall を「物理的に落ちる」と文字通り直訳した不自然な表現。fall in は fall in love with を中途半端に切り取った不完全な誤用トラップ。最後の肢は caught feelings/not gonna lie など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 の人間関係のエピソード、CAE Speaking Part 2 の恋愛・友情トピックで頻出。","usecase":"誰かに恋をしたことを説明する自然な言い方。","opt":["正解。fall for が恋に落ちることを示す標準形。","fallを文字通り直訳した不自然な表現。","fall in は不完全な誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q06', '関係・対立系',
   '〔中立〕彼らは長い交際の末、別れることにした。',
   NULL::text,
   '["They decided to break up after a long relationship.","They decided to break their relationship up into pieces after a long relationship.","They decided to break off after a long relationship.","They basically called it quits after being together forever, yeah."]',
   0, '[0]', 'single',
   '{"asked":"恋愛関係の終わりを break up で述べられるか。","point":"break up＝（恋人関係を）解消する・別れる。日常会話で最も中立的な破局の表現。","kid":"break up＝壊れて分かれる。一つだった関係が二つに分かれてしまうイメージ。","eg":"They broke up after dating for three years.","terms":[["break up（自動詞）","目的語を取らず、破局そのものを表す。break up with + 人 の形も可"],["break off（誤用寄り）","「（交渉・関係を）打ち切る」でやや事務的・硬いニュアンス"]],"think":"破局の描写文→動詞は break→粒子は up。","vs":"直訳肢の break their relationship up into pieces は「粉々に壊す」という過剰な比喩の直訳。break off は「（交渉などを）打ち切る」という硬いニュアンスが強く、恋愛関係の別れを示す break up よりも事務的な近義語トラップ。最後の肢は called it quits/forever/yeah など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 の人間関係のエピソード、CAE Speaking Part 2 の恋愛トピックで最頻出。","usecase":"長い交際の末に別れたことを説明する自然な言い方。","opt":["正解。break up が破局を示す標準形。","過剰な比喩の直訳。","break offは硬いニュアンスの近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q07', '関係・対立系',
   '〔中立〕けんかの後、二人は関係を修復しようとした。',
   NULL::text,
   '["After the fight, they tried to patch things up.","After the fight, they tried to sew a patch onto things to fix them.","After the fight, they tried to patch things over.","After the fight, they basically tried to smooth things over, kinda."]',
   0, '[0]', 'single',
   '{"asked":"関係の修復を patch up で述べられるか。","point":"patch up＝（関係やけんかを）修復する。破れた布に当て布をするイメージから転じた口語の定番表現。","kid":"patch up＝当て布をして直す。破れた関係に当て布をあてて、応急処置的に直すイメージ。","eg":"They managed to patch things up before the wedding.","terms":[["patch + 名詞 + up","分離動詞。目的語が名詞のときは間に挟むのが自然"],["patch over（誤用）","存在しない組み合わせ"]],"think":"関係修復の描写文→動詞は patch→粒子は up。","vs":"直訳肢の sew a patch onto things to fix them は patch を「布切れを縫い付ける」という文字通りの意味で過剰に説明した表現。patch over は存在しない誤用。最後の肢は smooth things over という別の慣用句への言い換えで、意味は近いがこの設問が問う patch up 特有の表現とはずれる。","why_asked":"IELTS Speaking Part 2 の人間関係のエピソード、CAE Speaking Part 3 の対立解消トピックで頻出。","usecase":"けんかの後に関係を修復しようとしたことを説明する自然な言い方。","opt":["正解。patch things up が関係修復を示す標準形。","patchを文字通り説明しすぎた表現。","patch over は存在しない誤用。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3b-q08', '関係・対立系',
   '〔中立〕彼女は姉をずっと尊敬してきた。',
   NULL::text,
   '["She has always looked up to her older sister.","She has always looked her eyes up toward her older sister.","She has always looked up on her older sister.","She has basically always thought her sister was the best, you know."]',
   0, '[0]', 'single',
   '{"asked":"尊敬の念を look up to で述べられるか。","point":"look up to＝（人を）尊敬する。目上や手本にしたい相手への敬意を示す最頻出表現。","kid":"look up to＝見上げる。憧れの相手を見上げるように尊敬するイメージ。","eg":"Many young athletes look up to her as a role model.","terms":[["look up to + 人","older sister/mentor/role model などの人の名詞と相性が良い"],["look up on（誤用）","前置詞は to 固定、on は誤り"]],"think":"尊敬を述べる文→動詞は look→粒子は up→前置詞 to。","vs":"直訳肢の looked her eyes up toward は look を身体動作として過剰に直訳した不自然な表現。look up on は前置詞の誤用。最後の肢は thought her sister was the best/you know など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 の尊敬する人物トピック、CAE Speaking Part 2 の人物紹介で最頻出。","usecase":"家族や恩師など尊敬する相手について説明する自然な言い方。","opt":["正解。look up to が尊敬を示す標準形。","身体動作として過剰に直訳した表現。","前置詞の誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q09', '関係・対立系',
   '〔中立〕彼はいつも他人を見下しているように見える。',
   NULL::text,
   '["He always seems to look down on other people.","He always seems to look his eyes downward on other people.","He always seems to look down at other people.","He is basically always acting like he is better than everyone, ugh."]',
   0, '[0]', 'single',
   '{"asked":"軽蔑の態度を look down on で述べられるか。","point":"look down on＝（人を）見下す・軽蔑する。相手を劣ったものとして扱う態度を示す最頻出表現。","kid":"look down on＝上から見下ろす。高い場所から他人を見下げるように、軽蔑する態度のイメージ。","eg":"She never looks down on people who make mistakes.","terms":[["look down on + 人","other people/colleagues などの人の名詞と相性が良い"],["look down at（誤用寄り）","物理的に見下ろすニュアンスが強く、軽蔑の意味の look down on とはずれる"]],"think":"軽蔑の態度を述べる文→動詞は look→粒子は down→前置詞 on。","vs":"直訳肢の look his eyes downward on は look を身体動作として過剰に直訳した不自然な表現。look down at は物理的に見下ろすニュアンスが強く、軽蔑を意味する look down on とはずれる近義語トラップ。最後の肢は acting like he is better than everyone/ugh など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 3 の人物評価トピック、IELTS Writing の態度描写パラグラフで頻出。","usecase":"他人を見下す態度の人物を説明する自然な言い方。","opt":["正解。look down on が軽蔑を示す標準形。","身体動作として過剰に直訳した表現。","物理的なニュアンスが強い近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q10', '関係・対立系',
   '〔口語〕週末はたいてい友達とただ一緒に過ごしている。',
   NULL::text,
   '["On weekends, I usually just hang out with my friends.","On weekends, I usually just hang my body outside with my friends.","On weekends, I usually just hang out on my friends.","During weekends, one typically spends leisure time in the company of friends."]',
   0, '[0]', 'single',
   '{"asked":"友人とのカジュアルな時間の過ごし方を hang out with で述べられるか。","point":"hang out with＝（人と）ただ一緒に時間を過ごす。特別な予定なくのんびり過ごすことを示す最頻出の口語表現。","kid":"hang out with＝ぶらぶらと一緒にいる。目的なく、ただその場にいて時間を共にするイメージ。","eg":"We usually just hang out at a cafe on Sundays.","terms":[["hang out with + 人","friends/family などの人の名詞と相性が良い"],["hang out on（誤用）","前置詞は with 固定、on は誤り"]],"think":"週末の過ごし方を述べる文→動詞は hang→粒子は out→前置詞 with。","vs":"直訳肢の hang my body outside は hang を身体的に「吊るす」と文字通り直訳した不自然な表現。hang out on は前置詞の誤用。最後の肢は spends leisure time in the company of など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"IELTS Speaking Part 1 の余暇・友人トピック、CAE Speaking Part 1 の日常描写で最頻出。","usecase":"友人とのんびり時間を過ごす週末の習慣を話す自然な言い方。","opt":["正解。hang out with が友人との時間の過ごし方を示す口語標準形。","hangを身体的に直訳した不自然な表現。","前置詞の誤用。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3b-q11', '関係・対立系',
   '〔中立〕彼の考え方はしばしばチームの他のメンバーと対立する。',
   NULL::text,
   '["His approach often clashes with the rest of the team.","His approach often hits and crashes with the rest of the team.","His approach often clashes on the rest of the team.","His whole vibe basically clashes with everyone else, honestly."]',
   0, '[0]', 'single',
   '{"asked":"意見や考え方の対立を clash with で述べられるか。","point":"clash with＝（考え方・意見が）対立する。物理的な衝突の比喩から転じた、意見の不一致を示す定番表現。","kid":"clash with＝ガチャンとぶつかる。シンバルがぶつかり合うように、考え方が衝突するイメージ。","eg":"Her views often clash with those of her manager.","terms":[["clash with + 名詞","approach/views/personality などの名詞と相性が良い"],["clash on（誤用）","前置詞は with 固定、on は誤り"]],"think":"意見の対立を述べる文→動詞は clash→前置詞は with。","vs":"直訳肢の hits and crashes with は clash を「ぶつかって衝突する」という物理的な意味で二重に強調した不自然な表現。clash on は前置詞の誤用。最後の肢は whole vibe/honestly など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 3 の職場対立トピック、IELTS Writing の意見対立パラグラフで頻出。","usecase":"考え方や意見が他者と対立することを説明する自然な言い方。","opt":["正解。clashes with が意見の対立を示す標準形。","物理的な衝突として二重に強調した表現。","前置詞の誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q12', '増減・変化系',
   '〔中立〕先月から野菜の値段がかなり上がった。',
   NULL::text,
   '["Vegetable prices have gone up quite a bit since last month.","Vegetable prices have moved their position upward quite a bit since last month.","Vegetable prices have gone off quite a bit since last month.","Veggie prices have basically shot through the roof, ugh."]',
   0, '[0]', 'single',
   '{"asked":"価格の上昇を go up で述べられるか。","point":"go up＝（価格・数値が）上がる。日常会話で最も中立的な上昇表現。","kid":"go up＝上に向かって進む。数字がすっと上に登っていくイメージ。","eg":"The rent has gone up twice in the past year.","terms":[["go up + since/by + 期間/数量","起点や幅を示す語句と相性が良い"],["go off（誤用）","「（アラームが）鳴る」「（食品が）腐る」で全く別の意味"]],"think":"価格変動の描写文→動詞は go→粒子は up。","vs":"直訳肢の moved their position upward は go up の意味を説明的に言い換えた冗長な直訳。go off は「（アラームが）鳴る」「（食品が）腐る」という全く別の意味になる重要な誤用トラップ。最後の肢は shot through the roof/ugh など強すぎる口語表現で、中立的な描写としては大げさすぎる。","why_asked":"IELTS Speaking Part 1・Writing Task 1 の物価トピック、CAE Speaking の日常描写で最頻出。","usecase":"物価や数値が上がったことを客観的に説明する自然な言い方。","opt":["正解。gone up が価格の上昇を示す標準形。","説明的に言い換えた冗長な直訳。","go off は全く別の意味。","大げさすぎる口語表現。"]}'),

  ('pv-t3b-q13', '増減・変化系',
   '〔中立〕健康のため、コーヒーの量を減らそうとしている。',
   NULL::text,
   '["She is trying to cut down on coffee for her health.","She is trying to cut coffee down into smaller pieces for her health.","She is trying to cut down in coffee for her health.","She is basically trying to lay off the coffee a bit, yeah."]',
   0, '[0]', 'single',
   '{"asked":"量を減らすことを cut down on で述べられるか。","point":"cut down on＝（量・頻度を）減らす。健康や生活習慣の改善で使う最頻出表現。","kid":"cut down on＝切り詰めて減らす。多すぎる量を刃物で切って少なくするイメージ。","eg":"He is trying to cut down on sugar this year.","terms":[["cut down on + 名詞","coffee/sugar/spending などの名詞と相性が良い"],["cut down in（誤用）","前置詞は on 固定、in は誤り"]],"think":"生活習慣の改善文→動詞は cut→粒子は down→前置詞 on。","vs":"直訳肢の cut coffee down into smaller pieces は cut を「物理的に切り刻む」という文字通りの意味で誤解した不自然な表現。cut down in は前置詞の誤用。最後の肢は lay off the coffee/yeah など口語表現で、内容は近いが中立的な健康習慣の説明としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 1 の健康・食生活トピック、CAE Speaking の生活習慣描写で最頻出。","usecase":"健康のために特定のものの量を減らそうとしていることを説明する自然な言い方。","opt":["正解。cut down on が量の削減を示す標準形。","cutを文字通り誤解した不自然な表現。","前置詞の誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q14', '増減・変化系',
   '〔中立〕小さな誤解が、あっという間に大きな口論に変わった。',
   NULL::text,
   '["A small misunderstanding quickly turned into a big argument.","A small misunderstanding quickly changed its body into a big argument.","A small misunderstanding quickly turned in a big argument.","A tiny misunderstanding basically blew up into a huge fight, yeah."]',
   0, '[0]', 'single',
   '{"asked":"状態の変化を turn into で述べられるか。","point":"turn into＝〜に変わる。ある状態が別の状態へと質的に変化することを示す最頻出表現。","kid":"turn into＝向きを変えて別のものになる。曲がり角を曲がるように、別の状態に変わっていくイメージ。","eg":"A minor delay turned into a major crisis for the company.","terms":[["turn into + 名詞","argument/crisis/disaster などの名詞と相性が良い"],["turn in（誤用）","前置詞は into 固定、in は誤り"]],"think":"状態変化の描写文→動詞は turn→前置詞は into。","vs":"直訳肢の changed its body into は turn を身体的な変化として過剰に直訳した不自然な表現。turn in は前置詞の誤用。最後の肢は blew up into/yeah など口語表現で、内容は近いが中立的な描写文としてはやや強すぎる印象を与える。","why_asked":"IELTS Speaking Part 2 のエピソード描写、CAE Speaking Part 3 の状況変化の説明で最頻出。","usecase":"小さな出来事が大きな問題に発展したことを説明する自然な言い方。","opt":["正解。turned into が状態の変化を示す標準形。","身体的な変化として過剰に直訳した表現。","前置詞の誤用。","口語すぎてやや強すぎる表現。"]}'),

  ('pv-t3b-q15', '増減・変化系',
   '〔中立〕新しい割引のおかげで、売上の落ち込みは徐々に緩やかになっている。',
   NULL::text,
   '["Thanks to the new discount, sales are not going down as fast as before.","Thanks to the new discount, sales are not moving their position downward as fast as before.","Thanks to the new discount, sales are not going off as fast as before.","Thanks to the discount, sales are not basically tanking as hard, yeah."]',
   0, '[0]', 'single',
   '{"asked":"数値の下降を go down で述べられるか。","point":"go down＝（価格・数値が）下がる。go up の対になる、最も中立的な下降表現。","kid":"go down＝下に向かって進む。数字がすっと下に降りていくイメージ。","eg":"Traffic accidents have gone down significantly this year.","terms":[["go down + as fast as/by + 数量","比較や幅を示す語句と相性が良い"],["go off（誤用）","「（アラームが）鳴る」「（食品が）腐る」で全く別の意味"]],"think":"数値の下降を述べる文→動詞は go→粒子は down。","vs":"直訳肢の moving their position downward は go down の意味を説明的に言い換えた冗長な直訳。go off は「（アラームが）鳴る」「（食品が）腐る」という全く別の意味になる誤用トラップ。最後の肢は tanking/yeah など強い口語表現で、中立的な描写としてはやや大げさ。","why_asked":"IELTS Writing Task 1 のデータ描写、CAE Speaking の日常的な数値変化の説明で最頻出。","usecase":"売上や数値の下降傾向が緩やかになっていることを説明する自然な言い方。","opt":["正解。going down が数値の下降を示す標準形。","説明的に言い換えた冗長な直訳。","go off は全く別の意味。","大げさな口語表現。"]}'),

  ('pv-t3b-q16', '増減・変化系',
   '〔中立〕不況の後、経済はようやく回復し始めている。',
   NULL::text,
   '["After the recession, the economy is finally starting to pick up.","After the recession, the economy is finally starting to lift itself up with its hands.","After the recession, the economy is finally starting to pick out.","After the recession, the economy is basically finally getting better, kinda."]',
   0, '[0]', 'single',
   '{"asked":"景気や状況の好転を pick up で述べられるか。","point":"pick up＝（景気・調子が）上向く・回復する。停滞していた状況が改善に向かうことを示す定番表現。","kid":"pick up＝拾い上げて持ち直す。落ちていたものを拾い上げるように、状況が上向くイメージ。","eg":"Business has been picking up since the new branch opened.","terms":[["pick up（自動詞）","economy/business/sales などが主語になり回復を表す"],["pick out（誤用）","「選び出す」で全く別の意味"]],"think":"景気回復の描写文→動詞は pick→粒子は up。","vs":"直訳肢の lift itself up with its hands は pick up を身体動作として過剰に直訳した不自然な表現。pick out は「選び出す」という全く別の意味になる誤用トラップ。最後の肢は getting better/kinda など口語表現で、内容は近いが中立的な経済描写としてはやや砕けすぎる。","why_asked":"IELTS Writing Task 1 の経済データ描写、CAE Reading の経済記事で頻出。","usecase":"景気や状況が回復傾向にあることを説明する自然な言い方。","opt":["正解。picking up が景気回復を示す標準形。","身体動作として過剰に直訳した表現。","pick out は全く別の意味。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q17', '増減・変化系',
   '〔中立〕数週間の急増の後、感染者数はようやく横ばいになった。',
   NULL::text,
   '["After weeks of sharp increases, case numbers have finally levelled off.","After weeks of sharp increases, case numbers have finally made themselves flat like a level tool.","After weeks of sharp increases, case numbers have finally levelled out on.","After weeks of craziness, the numbers have basically flattened out, finally."]',
   0, '[0]', 'single',
   '{"asked":"数値の横ばい化を level off で述べられるか。","point":"level off＝（急な変化の後）横ばいになる。上昇や下降が落ち着いて安定することを示す定番表現。","kid":"level off＝水平にして落ち着かせる。ジェットコースターが平らな区間に入るように、変化が止まるイメージ。","eg":"After the initial spike, temperatures levelled off for the rest of the week.","terms":[["level off（自動詞）","numbers/prices/temperatures などが主語になり安定を表す"],["level out on（誤用）","level off/level out は正しいが、不要な on を付けるのは誤り"]],"think":"数値の安定化を述べる文→動詞は level→粒子は off。","vs":"直訳肢の made themselves flat like a level tool は level を「水平器という道具」と文字通り直訳した不自然な表現。levelled out on は不要な前置詞を加えた誤用。最後の肢は flattened out/finally など口語表現で、内容は近いが中立的なデータ描写としてはやや砕けすぎる。","why_asked":"IELTS Writing Task 1 のグラフ描写、CAE Reading の統計記事で頻出。","usecase":"急増・急減の後に数値が安定したことを説明する定型表現。","opt":["正解。levelled off が数値の横ばいを示す標準形。","levelを道具として文字通り直訳した表現。","不要な前置詞を加えた誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q18', '増減・変化系',
   '〔フォーマル〕四半期の終わりに向けて、需要は徐々に減少していった。',
   NULL::text,
   '["Demand gradually tapered off toward the end of the quarter.","Demand gradually became narrow like a taper candle toward the end of the quarter.","Demand gradually tapered out toward the end of the quarter.","Demand basically kind of fizzled out by the end of the quarter, yeah."]',
   0, '[0]', 'single',
   '{"asked":"緩やかな減少を taper off でフォーマルに述べられるか。","point":"taper off＝徐々に減少していく。ろうそくの先が細くなるように、緩やかに減っていく様子を示すフォーマルな表現。","kid":"taper off＝先細りになる。ろうそくの形のように、少しずつ細く小さくなっていくイメージ。","eg":"Sales typically taper off after the holiday season.","terms":[["taper off（自動詞）","demand/sales/interest などが主語になり緩やかな減少を表す"],["taper out（誤用）","標準は taper off。out を使う形は一般的でない誤用"]],"think":"緩やかな減少を述べる文→動詞は taper→粒子は off。","vs":"直訳肢の became narrow like a taper candle は taper を「ろうそく」という名詞として文字通り直訳した不自然な表現。taper out は標準的でない誤用形。最後の肢は fizzled out/kind of/yeah など口語表現でフォーマルな需要分析には不適。","why_asked":"CAE Reading の経済・需要分析記事、IELTS Writing Task 1 のグラフ描写で頻出。","usecase":"需要や関心が緩やかに減少していったことをフォーマルに説明する定型表現。","opt":["正解。tapered off が緩やかな減少を示す標準形。","taperを名詞として文字通り直訳した表現。","taper out は標準的でない誤用形。","口語すぎてフォーマルな分析に不適。"]}'),

  ('pv-t3b-q19', '増減・変化系',
   '〔中立〕発表の直後、株価が急上昇した。',
   NULL::text,
   '["The stock price shot up immediately after the announcement.","The stock price fired itself up like a gun immediately after the announcement.","The stock price shot out immediately after the announcement.","The stock price basically went bananas immediately after the announcement."]',
   0, '[0]', 'single',
   '{"asked":"急上昇を shoot up で述べられるか。","point":"shoot up＝急上昇する。弾丸のように勢いよく一気に上がることを示す定番表現。","kid":"shoot up＝勢いよく撃ち上がる。花火が一気に打ち上がるように、急激に上昇するイメージ。","eg":"Temperatures shot up to 35 degrees over the weekend.","terms":[["shoot up（自動詞）","price/temperature/demand などが主語になり急上昇を表す"],["shoot out（誤用寄り）","「勢いよく飛び出す」で方向性が横・外向きになり、上昇のニュアンスが弱い"]],"think":"急上昇の描写文→動詞は shoot→粒子は up。","vs":"直訳肢の fired itself up like a gun は shoot を「銃で撃つ」という文字通りの意味で過剰に説明した不自然な表現。shoot out は「勢いよく飛び出す」という横・外向きのニュアンスが強く、上向きの急上昇を示す shoot up とはずれる近義語トラップ。最後の肢は went bananas など強すぎる口語スラングで、中立的な描写としては大げさ。","why_asked":"IELTS Writing Task 1 のグラフ描写、CAE Reading の経済記事で頻出。","usecase":"株価や数値が急激に上昇したことを説明する自然な言い方。","opt":["正解。shot up が急上昇を示す標準形。","shootを文字通り説明しすぎた表現。","方向性がずれる近義語。","大げさな口語スラング。"]}'),

  ('pv-t3b-q20', '増減・変化系',
   '〔中立〕午後になると、来客数が急に減る。',
   NULL::text,
   '["The number of visitors drops off sharply in the afternoon.","The number of visitors falls and drops itself off sharply in the afternoon.","The number of visitors drops out sharply in the afternoon.","Visitor numbers basically nosedive in the afternoon, yeah."]',
   0, '[0]', 'single',
   '{"asked":"急な減少を drop off で述べられるか。","point":"drop off＝急に減る。数値やペースが急激に下がることを示す定番表現。","kid":"drop off＝ぽとりと落ちて外れる。急に落ち込むように数が減っていくイメージ。","eg":"Website traffic tends to drop off after 9pm.","terms":[["drop off（自動詞）","visitors/traffic/interest などが主語になり急減を表す"],["drop out（誤用）","「中退する・脱落する」で全く別の意味"]],"think":"急な減少の描写文→動詞は drop→粒子は off。","vs":"直訳肢の falls and drops itself off は drop を動詞として二重に使った冗長な直訳。drop out は「中退する・脱落する」という全く別の意味になる重要な誤用トラップ。最後の肢は nosedive/yeah など強い口語表現で、中立的な描写としてはやや大げさ。","why_asked":"IELTS Writing Task 1 のグラフ描写、CAE Speaking の日常パターンの説明で頻出。","usecase":"時間帯によって数値が急に減ることを客観的に説明する定型表現。","opt":["正解。drops off が急な減少を示す標準形。","dropを二重に使った冗長な直訳。","drop out は全く別の意味。","大げさな口語表現。"]}'),

  ('pv-t3b-q21', '増減・変化系',
   '〔中立〕数か月かけて、月ごとの売上の差は徐々に均されていった。',
   NULL::text,
   '["Over several months, the monthly sales gap gradually evened out.","Over several months, the monthly sales gap gradually became a flat even surface.","Over several months, the monthly sales gap gradually evened up.","Over a few months, the sales gap basically balanced itself out, kinda."]',
   0, '[0]', 'single',
   '{"asked":"差の平準化を even out で述べられるか。","point":"even out＝（差が）均される・平準化する。ばらつきが徐々になくなり均一に近づくことを示す定番表現。","kid":"even out＝平らにする。でこぼこだった地面がならされて平らになるイメージ。","eg":"Prices across regions tend to even out over time.","terms":[["even out（自動詞）","gap/difference/prices などが主語になり平準化を表す"],["even up（誤用寄り）","似た意味で使われることもあるが標準は even out"]],"think":"差の平準化を述べる文→動詞は even→粒子は out。","vs":"直訳肢の became a flat even surface は even を「平らな表面」という名詞的な意味で過剰に直訳した不自然な表現。even up は似た意味で使われることもあるが、even out が標準的でこの文脈ではニュアンスがわずかにずれる近義語トラップ。最後の肢は balanced itself out/kinda など口語表現で、内容は近いが中立的なデータ描写としてはやや砕けすぎる。","why_asked":"IELTS Writing Task 1 のグラフ描写、CAE Reading の統計・分析記事で頻出。","usecase":"数値のばらつきが時間をかけて均されていったことを説明する定型表現。","opt":["正解。evened out が差の平準化を示す標準形。","evenを名詞的に過剰に直訳した表現。","ニュアンスがわずかにずれる近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3b-q22', '増減・変化系',
   '〔中立〕何年もかけて、彼は誠実な仕事ぶりで信頼を築き上げた。',
   NULL::text,
   '["Over the years, he built up trust through honest work.","Over the years, he constructed trust upward like a building through honest work.","Over the years, he built out trust through honest work.","Over the years, he basically earned trust from people bit by bit, you know."]',
   0, '[0]', 'single',
   '{"asked":"時間をかけた蓄積を build up で述べられるか。","point":"build up＝（信頼・評判などを）少しずつ築き上げる。時間をかけた積み重ねによる増加を示す定番表現。","kid":"build up＝積み上げて作る。レンガを一つずつ積み上げるように、信頼を少しずつ蓄積していくイメージ。","eg":"It takes years to build up a loyal customer base.","terms":[["build up + 名詞","trust/reputation/savings などの名詞と相性が良い"],["build out（誤用寄り）","「（インフラなどを）拡張する」で信頼の蓄積とは意味が異なる"]],"think":"信頼の蓄積を述べる文→動詞は build→粒子は up。","vs":"直訳肢の constructed trust upward like a building は build を「建築物を建てる」という文字通りの意味で過剰に直訳した不自然な表現。build out は「（インフラや事業を）拡張する」という別の意味になる誤用トラップ。最後の肢は earned trust/bit by bit/you know など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 3 の信頼・評判トピック、IELTS Writing の人物・企業描写で頻出。","usecase":"時間をかけて信頼や評判を築き上げたことを説明する自然な言い方。","opt":["正解。built up が時間をかけた蓄積を示す標準形。","buildを建築として過剰に直訳した表現。","build out は別の意味になる誤用。","口語すぎてやや砕けすぎる。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'pv-t3-b'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
