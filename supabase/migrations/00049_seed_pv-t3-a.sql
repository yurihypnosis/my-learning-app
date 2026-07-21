-- 英語・句動詞（Set T3-A）: 日常・語り22問（先送り・回避系11／開始・着手系11）
-- question-authoring-pv スキル準拠。docs/pv-seed-strategy.md により継続投入（T1/T2 に続く）。
BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('pv-t3-a',
        '英語・句動詞（Set T3-A）',
        '【Speak-First】日本語の場面を見たら、選択肢を見る前に3秒以内で英文を声に出す。言ってから表示。口で言えなかったら解答後にチップを押す。',
        '#6ab08d', 104, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('先送り・回避系', '#f87171', 1),
  ('開始・着手系', '#34d399', 2)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'pv-t3-a'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('pv-t3a-q01', '先送り・回避系',
   '〔口語〕気が重い電話をずっと後回しにしている。',
   NULL::text,
   '["I keep putting off that phone call I do not want to make.","I keep placing that phone call I do not want to make to a later position.","I keep putting away that phone call I do not want to make.","One continues to defer the telephone call one is reluctant to make."]',
   0, '[0]', 'single',
   '{"asked":"先延ばしを口語で put off と言えるか。","point":"put off＝先延ばしにする。keep -ing と組み合わせて「ずっと後回し」を表す最頻出の句動詞。","kid":"put off＝後ろへ置く。やるべきことを未来の自分に押しやるイメージ。","eg":"Do not put off going to the dentist any longer.","terms":[["put off + 名詞/動名詞","phone call/appointment/going to など幅広い名詞・動名詞と相性が良い"],["put away（誤用）","「片づける・しまう」で全く別の意味"]],"think":"口語での先延ばし描写→動詞は put→粒子は off。","vs":"直訳肢の placing ... to a later position は put off の意味を説明的に言い換えた冗長な直訳。put away は「片づける・しまう」という全く別の意味になる誤用トラップ。最後の肢は one continues to defer/one is reluctant など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"IELTS Speaking Part 1 の日常習慣トピック、CAE Speaking の先延ばし癖の描写で最頻出。","usecase":"気が重いタスクを後回しにしていることをカジュアルに話す言い方。","opt":["正解。put off が先延ばしの口語標準形。","説明的に言い換えた冗長な直訳。","put away は全く別の意味。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3a-q02', '先送り・回避系',
   '〔中立〕日曜の家族の集まりに行きたくないので、何とか理由をつけて逃れようとしている。',
   NULL::text,
   '["She is trying to get out of the family gathering on Sunday.","She is trying to get herself out from inside the family gathering on Sunday.","She is trying to get out on the family gathering on Sunday.","She is basically trying to dodge the whole family thing, not gonna lie."]',
   0, '[0]', 'single',
   '{"asked":"義務や約束からの回避を get out of で述べられるか。","point":"get out of＝（義務・約束から）逃れる。理由をつけて参加を回避することを示す最頻出表現。","kid":"get out of＝中から抜け出る。参加しなければならない箱の中から、なんとか抜け出すイメージ。","eg":"He tried to get out of doing the dishes by pretending to be busy.","terms":[["get out of + 名詞/動名詞","gathering/doing the dishes などの名詞・動名詞と相性が良い"],["get out on（誤用）","前置詞は of 固定、on は誤り"]],"think":"回避の文→義務から逃れる→動詞は get→粒子は out→前置詞 of。","vs":"直訳肢の get herself out from inside は「中から自分を出す」という冗長で不自然な直訳。get out on は前置詞の誤用。最後の肢は dodge/not gonna lie など口語表現で、内容は近いが get out of 特有の「理由をつけて逃れる」ニュアンスが弱い近義語トラップ。","why_asked":"CAE Speaking Part 1 の家族・社交トピック、IELTS Speaking Part 3 の義務回避の話題で頻出。","usecase":"気が進まない予定から理由をつけて逃れようとする自然な言い方。","opt":["正解。get out of が義務からの回避を示す標準形。","冗長で不自然な直訳。","前置詞の誤用。","ニュアンスが弱い近義語表現。"]}'),

  ('pv-t3a-q03', '先送り・回避系',
   '〔口語〕相手が本気で怒っていたので、それ以上言うのをやめて引き下がった。',
   NULL::text,
   '["Since he was clearly furious, I decided to back off and stop pushing.","Since he was clearly furious, I decided to move my back away and stop pushing.","Since he was clearly furious, I decided to back out and stop pushing.","Given his evident fury, I elected to withdraw and cease my insistence."]',
   0, '[0]', 'single',
   '{"asked":"対立から引き下がることを back off で述べられるか。","point":"back off＝（対立や圧力から）引き下がる。相手の怒りを見て一歩下がる様子を示す口語の定番表現。","kid":"back off＝後ろに離れる。詰め寄っていた距離をすっと取るイメージ。","eg":"When she raised her voice, he quickly backed off.","terms":[["back off（自動詞）","目的語を取らず、態度そのものを表す"],["back out（誤用寄り）","「（約束・合意から）手を引く」で対立から引き下がる場面とは状況が異なる"]],"think":"対立の場面→引き下がる→動詞は back→粒子は off。","vs":"直訳肢の move my back away は back を身体部位として直訳した不自然な表現。back out は「約束や合意から手を引く」という意味で、この場面（言い争いから引き下がる）とは状況がずれる誤用トラップ。最後の肢は elected to withdraw/cease my insistence など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 2 の対立エピソード、IELTS Speaking Part 3 の人間関係トピックで頻出。","usecase":"相手の怒りを見て言い争いから引き下がったことをカジュアルに話す言い方。","opt":["正解。back off が対立からの後退を示す口語標準形。","backを身体部位として直訳した表現。","back out は状況がずれる誤用。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3a-q04', '先送り・回避系',
   '〔中立〕彼はいつも対立を避け、難しい会話から尻込みする。',
   NULL::text,
   '["He always shies away from difficult conversations.","He is always shy and moves away from difficult conversations.","He always shies out of difficult conversations.","He is basically always dodging the awkward chats, yeah."]',
   0, '[0]', 'single',
   '{"asked":"性格的な尻込みを shy away from で述べられるか。","point":"shy away from＝（性格的に）尻込みする・避ける。習慣的な回避傾向を述べるときの定番表現。","kid":"shy away from＝おびえて離れる。臆病な動物がそっと後ずさりするイメージ。","eg":"She never shies away from asking difficult questions.","terms":[["shy away from + 名詞/動名詞","conversations/challenges などの名詞・動名詞と相性が良い"],["shy out of（誤用）","前置詞は away from 固定、out of は誤り"]],"think":"性格描写の文→尻込みする→動詞は shy→粒子は away→前置詞 from。","vs":"直訳肢の is always shy and moves away は shy を形容詞として直訳し、動詞句を二文的に分解した不自然な表現。shy out of は前置詞の誤用。最後の肢は dodging/awkward chats/yeah など口語表現で、内容は近いが中立的な性格描写としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 2 の性格描写、IELTS Speaking Part 3 の人物評価トピックで頻出。","usecase":"人が習慣的に難しい状況を避ける傾向を説明する自然な言い方。","opt":["正解。shy away from が習慣的な尻込みを示す標準形。","shyを形容詞化した不自然な直訳。","前置詞の誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3a-q05', '先送り・回避系',
   '〔中立〕健康のため、揚げ物は避けるようにしている。',
   NULL::text,
   '["For the sake of her health, she tries to steer clear of fried food.","For the sake of her health, she tries to drive her car clear away from fried food.","For the sake of her health, she tries to steer clear off fried food.","For her health, she is basically staying away from the fried stuff, kinda."]',
   0, '[0]', 'single',
   '{"asked":"意識的な回避を steer clear of で述べられるか。","point":"steer clear of＝（意識的に）避ける。運転で障害物をよける比喩から、習慣的な回避に転用された表現。","kid":"steer clear of＝ハンドルを切って避ける。車を操縦して障害物をよけるように、意識的に距離を取るイメージ。","eg":"Doctors advise patients to steer clear of excessive salt.","terms":[["steer clear of + 名詞","food/trouble/certain topics などの名詞と相性が良い"],["steer clear off（誤用）","of が正しく、off を付け足すのは誤り"]],"think":"健康習慣の文→意識的に避ける→動詞は steer→形容詞句 clear of。","vs":"直訳肢の drive her car clear away from は steer を「車を運転する」と文字通り直訳し過剰に説明した表現。steer clear off は不要な off を加えた誤用。最後の肢は fried stuff/kinda など口語表現で、内容は近いが中立的な健康習慣の説明としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 1 の健康・食生活トピック、IELTS Speaking Part 3 の習慣描写で頻出。","usecase":"健康のために特定のものを意識的に避けていることを説明する自然な言い方。","opt":["正解。steer clear of が意識的な回避を示す標準形。","steerを過剰に直訳した表現。","不要な前置詞を加えた誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3a-q06', '先送り・回避系',
   '〔フォーマル〕交渉担当者は、最終的な回答を意図的に先延ばしにしている。',
   NULL::text,
   '["The negotiator is deliberately stalling on the final answer.","The negotiator is deliberately making the final answer stop moving like a stalled engine.","The negotiator is deliberately stalling in the final answer.","The negotiator is basically dragging their feet on this, yeah."]',
   0, '[0]', 'single',
   '{"asked":"意図的な先延ばしを stall on でフォーマルに述べられるか。","point":"stall on＝（意図的に）先延ばしにする。交渉やビジネスの場面で使う格式高い表現。","kid":"stall on＝エンストしたように止める。前に進めるはずのものを意図的に止めてしまうイメージ。","eg":"The supplier has been stalling on delivery for weeks.","terms":[["stall on + 名詞","answer/decision/payment などの名詞と相性が良い"],["stall in（誤用）","前置詞は on 固定、in は誤り"]],"think":"交渉報告文→意図的に先延ばしにする→動詞は stall→前置詞は on。","vs":"直訳肢の making ... stop moving like a stalled engine は stall を「エンストする」という文字通りの意味で説明しすぎた冗長な直訳。stall in は前置詞の誤用。最後の肢は dragging their feet/yeah など口語表現でフォーマルな交渉報告には不適。","why_asked":"CAE Reading の交渉・ビジネス記事、IELTS Writing の交渉プロセス説明で頻出。","usecase":"交渉や合意形成の場面で意図的な先延ばしを報告する定型表現。","opt":["正解。stall on が意図的な先延ばしを示す標準形。","stallを文字通り説明しすぎた冗長な直訳。","前置詞の誤用。","口語すぎてフォーマルな報告に不適。"]}'),

  ('pv-t3a-q07', '先送り・回避系',
   '〔口語〕退屈な会議から早めにこっそり抜け出した。',
   NULL::text,
   '["He ducked out of the boring meeting early.","He bent his head down and went out of the boring meeting early.","He ducked out on the boring meeting early.","He discreetly absented himself from the tedious meeting prematurely."]',
   0, '[0]', 'single',
   '{"asked":"こっそり抜け出すことを duck out of で述べられるか。","point":"duck out of＝こっそり抜け出す。身をかがめて人目を避けるように、目立たず退出するイメージの口語表現。","kid":"duck out of＝頭を低くして抜け出る。アヒルのように身をかがめて、こっそり出ていくイメージ。","eg":"She ducked out of the party without saying goodbye.","terms":[["duck out of + 名詞","meeting/party/class などの名詞と相性が良い"],["duck out on（誤用寄り）","「（約束を）すっぽかす」でニュアンスがずれる"]],"think":"口語での退出描写→こっそり抜け出す→動詞は duck→粒子は out→前置詞 of。","vs":"直訳肢の bent his head down and went out は duck を身体動作として直訳し、二文的に説明しすぎた不自然な表現。duck out on は「（約束を）すっぽかす」という意味合いに寄り、単に「こっそり退出する」というニュアンスとはずれる誤用トラップ。最後の肢は discreetly absented himself/prematurely など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 4 の日常会話語彙、IELTS Speaking Part 2 のエピソード描写で頻出。","usecase":"退屈な集まりからこっそり早退したことをカジュアルに話す言い方。","opt":["正解。duck out of がこっそり抜け出すことを示す口語標準形。","身体動作として直訳し説明しすぎた表現。","ニュアンスがずれる誤用。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3a-q08', '先送り・回避系',
   '〔中立〕この問題は今は脇に置いて、後で対処しよう。',
   NULL::text,
   '["Let us put this issue aside for now and deal with it later.","Let us place this issue to the side area for now and deal with it later.","Let us put this issue apart for now and deal with it later.","Let us basically shelve this thing for now, kinda, yeah."]',
   0, '[0]', 'single',
   '{"asked":"問題の一時保留を put aside で述べられるか。","point":"put aside＝（問題や感情を）脇に置く。優先順位を下げて一時的に扱いを保留するときの定番表現。","kid":"put aside＝横に置く。今すぐ扱わないものを、机の脇にそっと置いておくイメージ。","eg":"Let us put our differences aside and focus on the goal.","terms":[["put + 名詞 + aside","分離動詞。目的語が名詞のときは間に挟むのが自然"],["put apart（誤用）","存在しない組み合わせ"]],"think":"一時保留の提案文→問題を脇に置く→動詞は put→副詞 aside。","vs":"直訳肢の place ... to the side area は aside を「横の領域」と過剰に説明した冗長な直訳。put apart は存在しない誤用。最後の肢は shelve/kinda/yeah など口語表現で、内容は近いが中立的な提案文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 3 の議論運営トピック、IELTS Writing の優先順位付けパラグラフで頻出。","usecase":"議論や作業で特定の問題を一時的に保留することを提案する定型表現。","opt":["正解。put aside が問題の一時保留を示す標準形。","asideを過剰に説明した冗長な直訳。","put apart は存在しない誤用。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3a-q09', '先送り・回避系',
   '〔口語〕割り勘の支払いをせずにこっそり抜け出した。',
   NULL::text,
   '["He skipped out on paying his share of the bill.","He jumped and skipped outside without paying his share of the bill.","He skipped out of paying his share of the bill.","He failed to remit his portion of the bill prior to departing the establishment."]',
   0, '[0]', 'single',
   '{"asked":"支払いなどの責任放棄を skip out on で述べられるか。","point":"skip out on＝（支払いや責任を）果たさずにこっそり逃げる。無責任な離脱を示すかなりカジュアルな表現。","kid":"skip out on＝ぴょんと跳ねて義務の上から逃げる。果たすべき責任を飛び越えて逃げてしまうイメージ。","eg":"He skipped out on his part of the rent last month.","terms":[["skip out on + 名詞/動名詞","paying/rent/responsibility などの名詞・動名詞と相性が良い"],["skip out of（誤用）","前置詞は on 固定、of は誤り"]],"think":"口語での責任放棄の描写→動詞は skip→粒子は out→前置詞 on。","vs":"直訳肢の jumped and skipped outside は skip を「跳ねる」という文字通りの意味で二重に強調した不自然な表現。skip out of は前置詞の誤用。最後の肢は remit his portion/prior to departing the establishment など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 4 のカジュアルな逸話、IELTS Speaking Part 2 のエピソード描写で頻出。","usecase":"支払いをせずにこっそり逃げた人の行動をカジュアルに話す言い方。","opt":["正解。skip out on が責任放棄の口語標準形。","skipを文字通り二重に強調した表現。","前置詞の誤用。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t3a-q10', '先送り・回避系',
   '〔中立〕彼女はいつも言い訳をして、面倒な仕事から何とか逃れる。',
   NULL::text,
   '["She always manages to wriggle out of tedious tasks with excuses.","She always manages to twist her body out of tedious tasks with excuses.","She always manages to wriggle out on tedious tasks with excuses.","She basically always weasels her way out, not gonna lie."]',
   0, '[0]', 'single',
   '{"asked":"言い訳を使った巧みな回避を wriggle out of で述べられるか。","point":"wriggle out of＝（言い訳やごまかしで）巧みに逃れる。うなぎのようにするりと責任から抜け出すイメージの表現。","kid":"wriggle out of＝身をくねらせて抜け出る。魚が網の隙間からするりと逃げるように、責任を逃れるイメージ。","eg":"He always finds a way to wriggle out of doing chores.","terms":[["wriggle out of + 名詞/動名詞","tasks/responsibility/doing chores などの名詞・動名詞と相性が良い"],["wriggle out on（誤用）","前置詞は of 固定、on は誤り"]],"think":"巧みな回避の描写文→動詞は wriggle→粒子は out→前置詞 of。","vs":"直訳肢の twist her body out of は wriggle を身体動作として直訳し過剰に強調した不自然な表現。wriggle out on は前置詞の誤用。最後の肢は weasels her way out という別の慣用句に言い換えた口語表現で、意味は近いがこの設問が問う wriggle out of 特有の表現とはずれる。","why_asked":"CAE Speaking Part 2 の人物描写、IELTS Speaking Part 3 の性格・行動パターンで頻出。","usecase":"言い訳を使って面倒な仕事から逃れる人の行動を説明する自然な言い方。","opt":["正解。wriggle out of が巧みな回避を示す標準形。","身体動作として過剰に直訳した表現。","前置詞の誤用。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3a-q11', '先送り・回避系',
   '〔フォーマル〕承認が下りるまで、発表を保留するよう求められた。',
   NULL::text,
   '["They were asked to hold off on the announcement until approval was granted.","They were asked to make the announcement stop and wait on until approval was granted.","They were asked to hold off in the announcement until approval was granted.","They were basically told to sit on the announcement for now, yeah."]',
   0, '[0]', 'single',
   '{"asked":"正式な保留の指示を hold off on で述べられるか。","point":"hold off on＝（正式に）保留する・延期する。承認待ちなど明確な理由がある延期を示すフォーマルな表現。","kid":"hold off on＝止めて距離を保つ。今は動かず、そのまま距離を置いて待つイメージ。","eg":"Management asked the team to hold off on any hiring until the budget was approved.","terms":[["hold off on + 名詞","announcement/decision/hiring などの名詞と相性が良い"],["hold off in（誤用）","前置詞は on 固定、in は誤り"]],"think":"承認待ちの指示文→保留する→動詞は hold→粒子は off→前置詞 on。","vs":"直訳肢の make the announcement stop and wait on は hold off の意味を冗長に説明した不自然な直訳。hold off in は前置詞の誤用。最後の肢は sit on the announcement/yeah など口語表現でフォーマルな指示文には不適だが、sit on 自体は近い意味の慣用句でもある。","why_asked":"CAE Reading のビジネス指示・承認プロセス記事、IELTS Writing のフォーマルな指示表現で頻出。","usecase":"承認や許可が下りるまで発表や行動を保留するよう指示する定型表現。","opt":["正解。hold off on が正式な保留を示す標準形。","冗長に説明した不自然な直訳。","前置詞の誤用。","口語すぎてフォーマルな指示に不適。"]}'),

  ('pv-t3a-q12', '開始・着手系',
   '〔中立〕早朝に、彼らは長い旅に出発した。',
   NULL::text,
   '["They set off on a long journey early in the morning.","They set their bodies off toward a long journey early in the morning.","They set out on a long journey early in the morning.","They basically hit the road super early, yeah."]',
   0, '[0]', 'single',
   '{"asked":"単純な出発を set off で述べられるか。","point":"set off＝出発する。旅や移動の開始を示す最も中立的で標準的な表現。","kid":"set off＝出発地点から離れて動き出す。旅の第一歩を踏み出すイメージ。","eg":"We set off before sunrise to avoid the traffic.","terms":[["set off + on/for + 名詞","journey/trip などの旅の名詞と相性が良い"],["set out（近義語）","目的や決意を伴う出発のニュアンスがあり、単純な移動の開始を示す set off とは微妙に異なる"]],"think":"出発の描写文→動詞は set→粒子は off。","vs":"直訳肢の set their bodies off toward は set off の意味を身体的に過剰に説明した不自然な直訳。set out は「目的を持って出発する」というニュアンスがやや強く、単純な移動開始を示す set off とはわずかにずれる近義語トラップ。最後の肢は hit the road/super early/yeah など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 1・2 の旅行トピック、CAE Speaking の日常描写で最頻出。","usecase":"旅行や移動の出発を客観的に描写する自然な言い方。","opt":["正解。set off が単純な出発を示す標準形。","身体的に過剰に説明した不自然な直訳。","目的のニュアンスがやや強い近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3a-q13', '開始・着手系',
   '〔中立〕退職後、彼は絵画を新しい趣味として始めた。',
   NULL::text,
   '["After retiring, he took up painting as a new hobby.","After retiring, he picked painting up into his hands as a new hobby.","After retiring, he took on painting as a new hobby.","After retiring, he basically got into painting or whatever."]',
   0, '[0]', 'single',
   '{"asked":"新しい趣味の開始を take up で述べられるか。","point":"take up＝（趣味・活動を）新しく始める。特に長期的に続ける新しい活動の開始を示す定番表現。","kid":"take up＝手に取って持ち上げる。新しい活動を自分の生活の中に取り入れるイメージ。","eg":"She took up yoga after her doctor recommended more exercise.","terms":[["take up + 名詞","painting/yoga/a new sport などの趣味・活動の名詞と相性が良い"],["take on（誤用寄り）","「（仕事や責任を）引き受ける」で趣味を始める場面とは意味が異なる"]],"think":"趣味の開始を述べる文→動詞は take→粒子は up。","vs":"直訳肢の picked painting up into his hands は take up の意味を身体動作として過剰に直訳した不自然な表現。take on は「（仕事や責任を）引き受ける」という別の意味になる誤用トラップ。最後の肢は got into/or whatever など口語表現で、内容は近いが中立的な描写文としてはやや投げやりに響く。","why_asked":"IELTS Speaking Part 1 の趣味トピック、CAE Speaking Part 2 の活動描写で最頻出。","usecase":"退職や転機を機に新しい趣味を始めたことを説明する自然な言い方。","opt":["正解。take up が新しい趣味の開始を示す標準形。","身体動作として過剰に直訳した表現。","take on は別の意味になる誤用。","口語すぎてやや投げやりに響く。"]}'),

  ('pv-t3a-q14', '開始・着手系',
   '〔中立〕世間話はもう十分なので、そろそろ本題に取り掛かろう。',
   NULL::text,
   '["We have chatted enough; let us get down to business.","We have chatted enough; let us go down low to business.","We have chatted enough; let us get down on business.","We have chatted enough; let us basically dive in, yeah."]',
   0, '[0]', 'single',
   '{"asked":"本題への移行を get down to で述べられるか。","point":"get down to＝本腰を入れて〜に取り掛かる。雑談を終えて本題に集中する場面で使う定番の慣用表現。","kid":"get down to＝腰を落として本題に向かう。しゃがみ込んで本気で作業に取り掛かるイメージ。","eg":"Let us stop small talk and get down to the details.","terms":[["get down to + 名詞/動名詞","business/work/the details などの名詞・動名詞と相性が良い"],["get down on（誤用）","前置詞は to 固定、on は誤り"]],"think":"雑談から本題への移行文→動詞は get→粒子は down→前置詞 to。","vs":"直訳肢の go down low to business は down を「低い位置」と文字通り直訳した不自然な表現。get down on は前置詞の誤用。最後の肢は dive in/yeah という別のチャンクへの言い換えで、意味は近いがこの設問が問う get down to 特有の表現とはずれる。","why_asked":"CAE Speaking Part 4 の会議運営トピック、IELTS Speaking Part 3 の議論の進行で頻出。","usecase":"雑談を終えて本題に取り掛かることを提案する定型の慣用表現。","opt":["正解。get down to が本題への移行を示す標準形。","downを文字通り直訳した不自然な表現。","前置詞の誤用。","別の表現への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3a-q15', '開始・着手系',
   '〔中立〕会議は、簡単な自己紹介から始まった。',
   NULL::text,
   '["The meeting kicked off with a brief round of introductions.","The meeting used its foot to kick and start with a brief round of introductions.","The meeting kicked out with a brief round of introductions.","The meeting basically got going with everyone saying hi, yeah."]',
   0, '[0]', 'single',
   '{"asked":"イベントの開始を kick off で述べられるか。","point":"kick off＝（イベント・行事が）始まる。スポーツの試合開始から転じて、会議やイベントの開始を示す定番表現。","kid":"kick off＝キックオフする。サッカーの試合開始のキックのように、物事が動き出すイメージ。","eg":"The conference kicked off with a keynote speech.","terms":[["kick off + with + 名詞","開始の内容を with で続ける形が定番"],["kick out（誤用）","「追い出す」で全く別の意味"]],"think":"イベント開始の描写文→動詞は kick→粒子は off。","vs":"直訳肢の used its foot to kick and start は kick を文字通りの身体動作として過剰に説明した不自然な表現。kick out は「（人を）追い出す」という全く別の意味になる誤用トラップ。最後の肢は got going/saying hi/yeah など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Reading のイベント・会議記事、IELTS Writing Task 1 のプロセス開始の描写で頻出。","usecase":"会議やイベントが特定の内容から始まったことを説明する定型表現。","opt":["正解。kicked off がイベントの開始を示す標準形。","身体動作として過剰に直訳した表現。","kick out は全く別の意味。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3a-q16', '開始・着手系',
   '〔中立〕彼はためらうことなく、新しいプロジェクトに飛び込んだ。',
   NULL::text,
   '["He dived into the new project without hesitation.","He jumped into the water of the new project without hesitation.","He dived in the new project without hesitation.","He basically just went for it with the new project, no cap."]',
   0, '[0]', 'single',
   '{"asked":"勢いよく取り組み始めることを dive into で述べられるか。","point":"dive into＝勢いよく取り組み始める。水に飛び込むように、ためらわず全力で始める様子を示す表現。","kid":"dive into＝頭から飛び込む。プールに飛び込むように、新しいことに一気に取り組み始めるイメージ。","eg":"She dived into the new role with enthusiasm.","terms":[["dive into + 名詞","project/role/topic などの名詞と相性が良い"],["dive in（前置詞脱落）","into の一部が抜けた不完全な形"]],"think":"勢いのある着手を述べる文→動詞は dive→粒子は into。","vs":"直訳肢の jumped into the water of は dive を「水に飛び込む」という文字通りの意味に過剰に直訳した不自然な表現。dive in は into の一部が抜けた不完全な形。最後の肢は went for it/no cap など口語表現で、内容は近いが中立的な描写文としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 2 の挑戦エピソード、IELTS Speaking Part 3 の取り組み方の描写で頻出。","usecase":"新しいことに迷わず全力で取り組み始めたことを説明する自然な言い方。","opt":["正解。dive into が勢いのある着手を示す標準形。","diveを文字通り直訳した過剰な表現。","前置詞の一部が抜けた不完全な形。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3a-q17', '開始・着手系',
   '〔フォーマル〕彼女は前置きもなく、長い説明を勢いよく始めた。',
   NULL::text,
   '["She launched into a lengthy explanation without any introduction.","She fired herself like a rocket into a lengthy explanation without any introduction.","She launched in a lengthy explanation without any introduction.","She basically just went off on a long explanation, out of nowhere."]',
   0, '[0]', 'single',
   '{"asked":"前置きなく勢いよく始めることを launch into で述べられるか。","point":"launch into＝（前置きなく）勢いよく始める。ロケットの打ち上げのイメージから転じた、フォーマルな場面での唐突な開始を示す表現。","kid":"launch into＝ロケットのように打ち上げて突入する。準備なしにいきなり本題に飛び込むイメージ。","eg":"The professor launched into a detailed critique without warning.","terms":[["launch into + 名詞","explanation/speech/discussion などの名詞と相性が良い"],["launch in（誤用）","前置詞は into 固定、in は誤り"]],"think":"唐突な開始を述べる文→動詞は launch→粒子は into。","vs":"直訳肢の fired herself like a rocket into は比喩（ロケット）を過剰に説明してしまった不自然な直訳。launch in は前置詞の誤用。最後の肢は went off/out of nowhere など口語表現でフォーマルな場面の描写には不適。","why_asked":"CAE Reading の講義・プレゼン記事、IELTS Writing のフォーマルな描写パラグラフで頻出。","usecase":"前置きなく突然本題に入った様子をフォーマルに描写する定型表現。","opt":["正解。launch into が唐突な開始を示す標準形。","比喩を過剰に説明した不自然な直訳。","前置詞の誤用。","口語すぎてフォーマルな場面に不適。"]}'),

  ('pv-t3a-q18', '開始・着手系',
   '〔中立〕もう出発しないと遅れてしまうので、そろそろ動き出そう。',
   NULL::text,
   '["We should get going soon, or we will be late.","We should get ourselves going forward soon, or we will be late.","We should get going on soon, or we will be late.","We should probably get a move on, or we will be late, yeah."]',
   0, '[0]', 'single',
   '{"asked":"行動の開始を促す get going を述べられるか。","point":"get going＝動き出す。ぐずぐずせずに行動を開始することを促す最も基本的な表現。","kid":"get going＝動く状態になる。止まっていたものが動き始めるイメージ。","eg":"If we do not get going now, we will miss the train.","terms":[["get going（自動詞句）","目的語を取らず、行動開始そのものを表す"],["get going on（誤用）","going の後に不要な on を付けるのは誤り"]],"think":"出発を促す文→動き出す→動詞は get→分詞 going。","vs":"直訳肢の get ourselves going forward は forward を余計に加えた冗長な直訳。get going on は不要な前置詞を付けた誤用。最後の肢は get a move on という別の慣用句への言い換えで、意味は近いがこの設問が問う get going 特有の表現とはずれる。","why_asked":"CAE Speaking Part 4 の日常の行動促進表現、IELTS Speaking Part 1 の日常描写で頻出。","usecase":"遅れそうな状況で行動を開始するよう促す自然な言い方。","opt":["正解。get going が行動開始を促す標準形。","forwardを余計に加えた冗長な直訳。","不要な前置詞を加えた誤用。","別の慣用句への言い換えでこの設問の狙いとずれる。"]}'),

  ('pv-t3a-q19', '開始・着手系',
   '〔フォーマル〕企業は、繁忙期に向けて準備を整えている。',
   NULL::text,
   '["The company is gearing up for the busy season.","The company is putting on gears mechanically for the busy season.","The company is gearing up on the busy season.","The company is basically getting ready for the crazy busy time, yeah."]',
   0, '[0]', 'single',
   '{"asked":"来るべき事態への準備を gear up for で述べられるか。","point":"gear up for＝（来るべき事態に向けて）準備を整える。機械のギアを入れて動き出す準備をするイメージのビジネス表現。","kid":"gear up for＝ギアを入れて備える。車が発進の準備をするように、組織が体制を整えるイメージ。","eg":"Retailers are gearing up for the holiday shopping rush.","terms":[["gear up for + 名詞","busy season/launch/event などの名詞と相性が良い"],["gear up on（誤用）","前置詞は for 固定、on は誤り"]],"think":"準備態勢の文→動詞は gear→粒子は up→前置詞 for。","vs":"直訳肢の putting on gears mechanically は gear を機械の歯車として文字通り直訳した過剰な表現。gear up on は前置詞の誤用。最後の肢は crazy busy time/yeah など口語表現でフォーマルな企業報告には不適。","why_asked":"CAE Reading のビジネス・小売業記事、IELTS Writing の準備プロセス説明で頻出。","usecase":"企業や組織が繁忙期や大きなイベントに向けて準備していることを述べる定型表現。","opt":["正解。gearing up for が準備態勢を示す標準形。","gearを機械として文字通り直訳した表現。","前置詞の誤用。","口語すぎてフォーマルな報告に不適。"]}'),

  ('pv-t3a-q20', '開始・着手系',
   '〔フォーマル〕チームは、問題を体系的に解決することに取り掛かった。',
   NULL::text,
   '["The team set about solving the problem systematically.","The team set themselves around solving the problem systematically.","The team set out solving the problem systematically.","The team basically got stuck into solving the problem, yeah."]',
   0, '[0]', 'single',
   '{"asked":"体系的な着手を set about で述べられるか。","point":"set about＝（計画的に）取り掛かる。動名詞を直接続けられる、着手を示すフォーマルな表現。","kid":"set about＝周りを固めて取り掛かる。準備を整えてから本腰で作業に入るイメージ。","eg":"The committee set about drafting a new policy.","terms":[["set about + 動名詞","動名詞を直接目的語に取る構文が特徴"],["set out（誤用寄り）","目的の宣言では to 不定詞を伴うのが標準で、動名詞を直接続ける構文としてはやや不自然"]],"think":"着手を述べる文→動詞は set→粒子は about→動名詞 solving。","vs":"直訳肢の set themselves around は about を「周り」と文字通り直訳した不自然な表現。set out は本来 to 不定詞を伴う目的宣言の構文が標準で、動名詞を直接取るこの文脈ではやや不自然な近義語トラップ。最後の肢は got stuck into/yeah など口語表現でフォーマルな報告文には不適。","why_asked":"CAE Reading のプロジェクト報告記事、IELTS Writing のプロセス開始の説明で頻出。","usecase":"チームや個人が計画的に問題解決に取り掛かったことを報告する定型表現。","opt":["正解。set about が体系的な着手を示す標準形。","aboutを文字通り直訳した不自然な表現。","構文がやや不自然な近義語。","口語すぎてフォーマルな報告に不適。"]}'),

  ('pv-t3a-q21', '開始・着手系',
   '〔中立〕彼女はキャリアを、小さな地方新聞社での仕事から始めた。',
   NULL::text,
   '["She started off working for a small local newspaper.","She started her career from the beginning point of a small local newspaper.","She started out working for a small local newspaper.","She basically kicked things off at some small local paper, yeah."]',
   0, '[0]', 'single',
   '{"asked":"キャリアの出発点を start off で述べられるか。","point":"start off＝（キャリアや物事の）最初の段階から始める。その後の展開を含意しつつ、出発点を示す表現。","kid":"start off＝最初の一歩を踏み出す。物語の冒頭のように、キャリアの始まりを語るイメージ。","eg":"He started off as an intern before becoming a full-time employee.","terms":[["start off + 動名詞/as + 名詞","working as/as an intern などの形と相性が良い"],["start out（近義語）","スタート地点そのものを指すニュアンスがやや強く、その後の展開を含意する start off とは微妙に異なる"]],"think":"キャリアの出発点を述べる文→動詞は start→粒子は off。","vs":"直訳肢の from the beginning point of は start off の意味を説明的に言い換えた冗長な直訳。start out は似た意味だが、start off が持つ「その後の展開につながる出発点」というニュアンスがやや弱い近義語トラップ。最後の肢は kicked things off/yeah など口語表現で、内容は近いが中立的な経歴描写としてはやや砕けすぎる。","why_asked":"IELTS Speaking Part 2 の経歴描写、CAE Speaking Part 2 の人物紹介で頻出。","usecase":"人のキャリアの出発点を語る自然な言い方。","opt":["正解。started off がキャリアの出発点を示す標準形。","説明的に言い換えた冗長な直訳。","ニュアンスがやや弱い近義語。","口語すぎてやや砕けすぎる。"]}'),

  ('pv-t3a-q22', '開始・着手系',
   '〔口語〕もうぐずぐずしていられないので、早速取り掛かろう。',
   NULL::text,
   '["We cannot waste any more time, so let us get cracking on it.","We cannot waste any more time, so let us break something and start on it.","We cannot waste any more time, so let us get cracking at it.","One must commence the task without further delay."]',
   0, '[0]', 'single',
   '{"asked":"勢いよく取り掛かることを口語で get cracking on と言えるか。","point":"get cracking on＝すぐに勢いよく取り掛かる。むちを鳴らすような音（crack）から転じた、活気ある着手を示す口語表現。","kid":"get cracking on＝パチッと音を立てて動き出す。ぐずぐずせず、勢いよく作業に飛び込むイメージ。","eg":"We only have an hour, so let us get cracking on the presentation.","terms":[["get cracking on + 名詞","task/it/the presentation などの名詞と相性が良い"],["get cracking at（誤用）","前置詞は on 固定、at は誤り"]],"think":"口語での着手の呼びかけ→動詞は get→粒子は cracking on。","vs":"直訳肢の break something and start on it は cracking を「何かを割る」という文字通りの意味で誤解した不自然な直訳。get cracking at は前置詞の誤用。最後の肢は one must commence/without further delay など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 4 の作業開始表現、IELTS Speaking Part 3 の行動促進の慣用句として頻出。","usecase":"時間がない状況で勢いよく作業に取り掛かろうとカジュアルに呼びかける言い方。","opt":["正解。get cracking on が勢いのある着手を示す口語標準形。","crackingを文字通り誤解した不自然な直訳。","前置詞の誤用。","フォーマルすぎて口語の場面に不適。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'pv-t3-a'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
