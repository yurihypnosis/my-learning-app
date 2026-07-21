-- 英語・句動詞（Set T1-B）: 学術・フォーマル系25問（依拠・構成系12／要約・帰着系13）
-- question-authoring-pv スキル準拠。docs/pv-seed-strategy.md により継続投入（pv-t1-a に続く）。
BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('pv-t1-b',
        '英語・句動詞（Set T1-B）',
        '【Speak-First】日本語の場面を見たら、選択肢を見る前に3秒以内で英文を声に出す。言ってから表示。口で言えなかったら解答後にチップを押す。',
        '#6ab08d', 74, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('依拠・構成系', '#a78bfa', 1),
  ('要約・帰着系', '#f472b6', 2)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'pv-t1-b'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('pv-t1b-q01', '依拠・構成系',
   '〔フォーマル〕この論文は、過去10年間の現地調査データに基づいている、と述べる。',
   NULL::text,
   '["This paper draws on a decade of field survey data.","This paper is based by using a decade of field survey data.","This paper draws in a decade of field survey data.","This paper''s basically using a bunch of survey data from the last ten years, you know."]',
   0, '[0]', 'single',
   '{"asked":"論文の根拠を draw on で述べられるか。","point":"draw on＝（資料・経験を）引き出して活用する。学術文で根拠を示す定番動詞。","kid":"draw on＝〜を頼りにする・引き出して使う。井戸から水を汲むように資料を引くイメージ。","eg":"The report draws on interviews with over 200 employees.","terms":[["draw on + 名詞","データ・経験・知識などの名詞と相性が良い"],["draw in（誤用）","「引き込む・呼び込む」で全く別の意味"]],"think":"論文の根拠説明→資料を引く→動詞は draw→粒子は on。","vs":"直訳肢の is based by using は受動と using を無理に組み合わせた不自然な構造。draw in は「引き込む・呼び込む」という別の意味になる誤用トラップ。最後の肢は a bunch of/you know など口語表現で論文の文体に合わない。","why_asked":"CAE Reading の学術記事、IELTS Writing の根拠提示パラグラフで頻出。","usecase":"論文・レポートで使用データや根拠を述べる導入文の定型。","opt":["正解。draw on が根拠提示の標準形。","受動＋usingの不自然な直訳。","draw in は「引き込む」で意味が違う。","口語すぎて論文の文体に不適。"]}'),

  ('pv-t1b-q02', '依拠・構成系',
   '〔フォーマル〕今回の研究は、先行研究の知見を土台にしている、と説明する。',
   NULL::text,
   '["This study builds on the findings of previous research.","This study is built with the findings of previous research on top.","This study builds up the findings of previous research.","This study''s basically piggybacking off earlier research, I guess."]',
   0, '[0]', 'single',
   '{"asked":"先行研究を土台にすることを build on で述べられるか。","point":"build on＝既存の成果を土台にしてさらに積み上げる。学術文の最頻出コロケーション。","kid":"build on＝〜を土台にする。既にある建物の上にさらに積み増すイメージ。","eg":"Our model builds on the framework proposed by Lee et al.","terms":[["build on + 名詞","findings/framework など既存の成果の名詞と相性が良い"],["build up（誤用）","「蓄積する・強化する」で土台にするニュアンスが弱い"]],"think":"研究の位置づけを述べる文→土台にする→動詞は build→粒子は on。","vs":"直訳肢の is built with ... on top は受動＋副詞 on top を無理に組み合わせた不自然な構造。build up は「徐々に強化・蓄積する」という意味合いが強く、既存研究を土台にするという build on の核心的ニュアンスが弱い近義語トラップ。最後の肢は piggyback off/I guess など口語表現で学術文に不適。","why_asked":"CAE Reading の学術記事、IELTS Writing の先行研究への言及パラグラフで頻出。","usecase":"研究の位置づけ・独自性を説明する導入文の定型。","opt":["正解。build on が土台にする標準形。","受動＋副詞の不自然な直訳。","build up はニュアンスが弱い近義語。","口語すぎて学術文に不適。"]}'),

  ('pv-t1b-q03', '依拠・構成系',
   '〔フォーマル〕女性がこの業界の労働力の約40%を構成している、と統計で示す。',
   NULL::text,
   '["Women make up around 40% of the workforce in this industry.","Women are composing around 40% of the workforce in this industry.","Women make out around 40% of the workforce in this industry.","Women are basically like 40% of the workforce here or something."]',
   0, '[0]', 'single',
   '{"asked":"構成比を make up で述べられるか。","point":"make up＝（全体の一部として）構成する。割合を示す統計文の定番動詞。","kid":"make up＝〜を構成する。パズルのピースが集まって全体を作るイメージ。","eg":"Part-time staff make up nearly a third of the total workforce.","terms":[["make up + 割合","X% / a third など数量表現と相性が良い"],["make out（誤用）","「かろうじて理解する・うまくやる」で全く別の意味"]],"think":"統計文→割合を構成する→動詞は make→粒子は up。","vs":"直訳肢の are composing は compose を進行形で使う不自然な直訳（compose は主に音楽・文章の「作成」に使う語で人口構成には make up が標準）。make out は「かろうじて理解する」という全く別の意味になる誤用トラップ。最後の肢は like/or something など曖昧な口語表現で統計文の断定的なトーンに合わない。","why_asked":"IELTS Writing Task 1 のデータ描写、CAE Reading の統計記事で最頻出のコロケーション。","usecase":"人口・労働力構成の割合を述べる統計文の定型。","opt":["正解。make up が構成比の標準形。","composeの進行形は不自然な直訳。","make out は全く別の意味。","曖昧な口語表現で統計文に不適。"]}'),

  ('pv-t1b-q04', '依拠・構成系',
   '〔フォーマル〕この結論は、いくつかの検証されていない仮定の上に成り立っている、と批判する。',
   NULL::text,
   '["This conclusion rests on several untested assumptions.","This conclusion is standing on top of several untested assumptions.","This conclusion rests in several untested assumptions.","This conclusion''s basically propped up by some shaky assumptions, tbh."]',
   0, '[0]', 'single',
   '{"asked":"論拠への批判を rest on で述べられるか。","point":"rest on＝（議論・結論が）〜に依拠している。批判的な指摘によく使う客観的な語。","kid":"rest on＝〜の上に乗っている。結論が仮定という土台の上に静かに乗っているイメージ。","eg":"The whole argument rests on a single, unverified statistic.","terms":[["rest on + 名詞","assumption/evidence など論拠の名詞と相性が良い"],["rest in（誤用）","前置詞は on 固定、in は誤り"]],"think":"批判の文→論拠に依拠している→動詞は rest→前置詞は on。","vs":"直訳肢の is standing on top of は比喩を直訳的に説明しすぎた不自然な構造。rest in は前置詞の誤用。最後の肢は propped up/tbh など口語表現で学術的な批判文の客観的なトーンに合わない。","why_asked":"CAE Reading の批評記事、IELTS Writing の批判的分析パラグラフで頻出。","usecase":"論文や主張の論拠の弱さを客観的に指摘する定型表現。","opt":["正解。rest on が論拠への依拠を示す標準形。","比喩を説明しすぎた直訳調。","前置詞の誤用。","口語すぎて批判文に不適。"]}'),

  ('pv-t1b-q05', '依拠・構成系',
   '〔フォーマル〕プロジェクトの成否は、初期段階での資金調達にかかっている、と分析する。',
   NULL::text,
   '["The success of the project hinges on securing funding in the early stages.","The success of the project is like a door hinge that depends on securing funding in the early stages.","The success of the project hinges in securing funding in the early stages.","Whether this thing works out is basically all down to getting cash early, right."]',
   0, '[0]', 'single',
   '{"asked":"成否を左右する決定的要因を hinge on で述べられるか。","point":"hinge on＝〜次第で決まる。蝶番（ちょうつがい）のように、その一点で全体が回るイメージ。","kid":"hinge on＝〜にかかっている。ドアの蝶番のように、そこが動くかどうかで全体が決まる語。","eg":"Whether the merger goes ahead hinges on regulatory approval.","terms":[["hinge on + 名詞","成否・結果を左右する要因の名詞と相性が良い"],["hinge in（誤用）","前置詞は on 固定、in は誤り"]],"think":"分析文→成否を左右する要因→動詞は hinge→前置詞は on。","vs":"直訳肢の is like a door hinge that depends on は比喩をそのまま説明してしまう冗長な直訳。hinge in は前置詞の誤用。最後の肢は this thing/right など口語表現で分析文の客観的なトーンに合わない。","why_asked":"CAE Reading のビジネス・政策分析記事、IELTS Writing の要因分析パラグラフで頻出。","usecase":"プロジェクトや計画の成否を左右する決定的要因を述べる定型。","opt":["正解。hinge on が決定的要因を示す標準形。","比喩を説明しすぎた直訳調。","前置詞の誤用。","口語すぎて分析文に不適。"]}'),

  ('pv-t1b-q06', '依拠・構成系',
   '〔フォーマル・受動〕この予測は、過去5年間の販売実績に基づいている。',
   NULL::text,
   '["This forecast is based on sales performance over the past five years.","This forecast has its basis from sales performance over the past five years.","This forecast is based in sales performance over the past five years.","This forecast''s basically going off the last five years of sales, yeah."]',
   0, '[0]', 'single',
   '{"asked":"be based on を受動形で正しい前置詞とともに使えるか。","point":"be based on＝〜に基づいている。前置詞は on 固定で、in にすると「〜に拠点を置く」という別の意味になる。","kid":"be based on＝〜を根拠にしている。土台（base）の上に予測が乗っているイメージ。","eg":"The recommendation is based on customer feedback collected last quarter.","terms":[["be based on + 名詞","根拠となるデータ・実績の名詞と相性が良い"],["be based in（別の意味）","「（場所に）拠点を置く」の意味になり根拠を表さない"]],"think":"予測の根拠を述べる受動文→動詞は base→前置詞は on。","vs":"直訳肢の has its basis from は base を名詞化した回りくどい直訳構造。based in は「（場所に）拠点を置く」という全く別の意味になる重要な誤用トラップ。最後の肢は going off/yeah など口語表現で予測の根拠説明としては砕けすぎる。","why_asked":"CAE Use of English の前置詞問題、IELTS Writing Task 1 の予測データ説明で頻出。","usecase":"予測・推定の根拠を客観的に述べる定型表現。","opt":["正解。based on が根拠を示す標準形。","名詞化した回りくどい直訳。","based in は「拠点を置く」で別の意味。","口語すぎて根拠説明に不適。"]}'),

  ('pv-t1b-q07', '依拠・構成系',
   '〔フォーマル〕現場からのフィードバックは、次回の製品設計に反映される、と述べる。',
   NULL::text,
   '["Feedback from the field will feed into the next product design.","Feedback from the field will be put as food into the next product design.","Feedback from the field will feed in the next product design.","Feedback from the field''s basically gonna shape the next design somehow."]',
   0, '[0]', 'single',
   '{"asked":"情報が別のプロセスに反映されることを feed into で述べられるか。","point":"feed into＝（情報・要素が）別のプロセスに流れ込んで反映される。プロセス間の連携を示す定番動詞。","kid":"feed into＝〜に流れ込む・反映される。パイプで水が次の工程に流れ込むイメージ。","eg":"These survey results will feed into next year''s budget planning.","terms":[["feed into + 名詞","次のプロセス・計画などの名詞と相性が良い"],["feed in（誤用）","前置詞 into の into が抜けた形で不完全"]],"think":"プロセス連携の文→情報が反映される→動詞は feed→粒子は into。","vs":"直訳肢の be put as food into は feed を「食べ物」と直訳した誤解に基づく不自然な表現。feed in は into の一部が抜けた不完全な形。最後の肢は gonna/somehow など口語表現でフォーマルな説明文に不適。","why_asked":"CAE Reading のビジネスプロセス記事、IELTS Writing のプロセス説明パラグラフで頻出。","usecase":"情報やフィードバックが次の工程に反映される仕組みを説明する定型。","opt":["正解。feed into がプロセス反映の標準形。","feedを食べ物と誤解した直訳。","into の一部が抜けた不完全な形。","口語すぎてフォーマルな説明に不適。"]}'),

  ('pv-t1b-q08', '依拠・構成系',
   '〔中立〕この新方針は、会社全体の長期戦略と整合している、と説明する。',
   NULL::text,
   '["This new policy ties in with the company''s long-term strategy.","This new policy is tied together with the company''s long-term strategy in a knot.","This new policy ties up with the company''s long-term strategy.","This new policy basically fits with the big-picture strategy, I think."]',
   0, '[0]', 'single',
   '{"asked":"整合性・一貫性を tie in with で述べられるか。","point":"tie in with＝〜と整合している・つながっている。方針や計画の一貫性を説明する定番表現。","kid":"tie in with＝〜と結びついている。糸で結ばれてつながっているイメージ。","eg":"This marketing campaign ties in with our sustainability goals.","terms":[["tie in with + 名詞","戦略・目標などの名詞と相性が良い"],["tie up（誤用）","「拘束する・（資金などを）固定する・終わらせる」で意味が違う"]],"think":"整合性を説明する文→つながっている→動詞は tie→粒子は in→前置詞 with。","vs":"直訳肢の is tied together ... in a knot は比喩（結び目）を説明しすぎた不自然な直訳。tie up with は「（資金や時間を）拘束する」「終わらせる」という別の意味合いが強く、整合性を表す tie in with とは意味がずれる誤用トラップ。最後の肢は basically/I think など口語表現で説明文としてはやや弱い。","why_asked":"CAE Reading のビジネス戦略記事、IELTS Writing の一貫性説明パラグラフで頻出。","usecase":"新方針や施策が既存の戦略と整合していることを説明する定型。","opt":["正解。tie in with が整合性を示す標準形。","比喩を説明しすぎた直訳調。","tie up with は意味がずれる誤用。","口語表現で説明文としてはやや弱い。"]}'),

  ('pv-t1b-q09', '依拠・構成系',
   '〔中立〕新しいマネージャーは、経験豊富な同僚のサポートに頼っている。',
   NULL::text,
   '["The new manager leans on the support of experienced colleagues.","The new manager is leaning her body on the support of experienced colleagues.","The new manager leans in the support of experienced colleagues.","The new manager''s basically leaning hard on the old-timers, ngl."]',
   0, '[0]', 'single',
   '{"asked":"人への依存を lean on で比喩的に述べられるか。","point":"lean on＝（人や支援に）頼る。物理的に寄りかかるイメージを比喩的に転用した表現。","kid":"lean on＝〜に寄りかかる。壁に体を預けるように、人の支えに頼るイメージ。","eg":"New employees often lean on their mentors during the first few months.","terms":[["lean on + 名詞","人・支援などの名詞と相性が良い"],["lean in（誤用）","「身を乗り出す・積極的に関わる」で全く別の意味"]],"think":"依存を述べる文→人に頼る→動詞は lean→前置詞は on。","vs":"直訳肢の is leaning her body on は「体を預ける」という物理的動作を強調しすぎた不自然な直訳。lean in は「身を乗り出す・積極的に関わる」という別の意味になる誤用トラップ。最後の肢は old-timers/ngl などスラングで中立的な説明文には砕けすぎる。","why_asked":"CAE Speaking Part 3 の職場トピック、IELTS Writing の人間関係描写で頻出。","usecase":"新人が経験者に頼っている状況を説明する自然な言い方。","opt":["正解。lean on が依存を示す標準形。","物理的動作を強調しすぎた直訳。","lean in は全く別の意味。","スラングで中立的な説明に不適。"]}'),

  ('pv-t1b-q10', '依拠・構成系',
   '〔中立〕チームは、天候が持つことを当てにして屋外イベントを計画した。',
   NULL::text,
   '["The team banked on the weather holding and planned an outdoor event.","The team put their money in the bank on the weather holding and planned an outdoor event.","The team banked in the weather holding and planned an outdoor event.","The team basically gambled on decent weather for the outdoor thing."]',
   0, '[0]', 'single',
   '{"asked":"当てにすることを bank on で述べられるか。","point":"bank on＝〜を当てにする・頼りにする。銀行に預けるように確実視するイメージの比喩表現。","kid":"bank on＝〜を頼りにする。お金を銀行に預けるくらい確実だと思うイメージ。","eg":"You cannot always bank on the trains running on time.","terms":[["bank on + 名詞/動名詞","確実だと期待する対象の名詞や -ing 形と相性が良い"],["bank in（誤用）","存在しない組み合わせ"]],"think":"計画の前提を述べる文→当てにする→動詞は bank→前置詞は on。","vs":"直訳肢の put their money in the bank on は bank を「銀行」と文字通り直訳した誤解。bank in は存在しない誤用。最後の肢は gamble という近い意味の語を使うが「賭ける」という語感が強すぎ、天候を「当てにする」という穏やかなニュアンスとはずれる近義語トラップ。","why_asked":"CAE Speaking Part 4 の計画トピック、IELTS Writing のリスク説明パラグラフで頻出。","usecase":"確実ではない前提を当てにして計画したことを説明する自然な言い方。","opt":["正解。bank on が当てにする標準形。","bankを銀行と誤解した直訳。","bank in は存在しない誤用。","gambleは語感が強すぎる近義語。"]}'),

  ('pv-t1b-q11', '依拠・構成系',
   '〔中立〕彼女はいつも締め切りを守ってくれると同僚は当てにしている。',
   NULL::text,
   '["Colleagues count on her to always meet deadlines.","Colleagues are counting the number that she always meets deadlines.","Colleagues count in her to always meet deadlines.","Colleagues are basically like, she always hits deadlines, you can bet on it."]',
   0, '[0]', 'single',
   '{"asked":"人への信頼・依存を count on で述べられるか。","point":"count on＝（人が期待通りに動くことを）当てにする。信頼に基づく依存を示す最頻出表現の一つ。","kid":"count on＝〜を頼りにする。数を数えるように「確実に大丈夫」と見込むイメージ。","eg":"You can always count on him to double-check the figures.","terms":[["count on + 人 + to do","人＋不定詞の形が定番"],["count in（誤用）","「（仲間に）加える」で全く別の意味"]],"think":"信頼を述べる文→人を当てにする→動詞は count→前置詞は on。","vs":"直訳肢の are counting the number that は count を「数える」の意味で直訳した誤解に基づく不自然な構造。count in は「仲間に加える」という全く別の意味になる誤用トラップ。最後の肢は like/you can bet on it など口語表現で説明文としては砕けすぎる。","why_asked":"CAE Speaking の人物評価トピック、IELTS Writing の信頼性説明パラグラフで頻出。","usecase":"同僚や友人の信頼性を説明するときの自然な言い方。","opt":["正解。count on が信頼を示す標準形。","countを数える意味で誤解した直訳。","count in は全く別の意味。","口語すぎて説明文に不適。"]}'),

  ('pv-t1b-q12', '依拠・構成系',
   '〔フォーマル〕主要な供給元が失敗した場合に備え、企業は予備の計画に頼れるようにしている。',
   NULL::text,
   '["The company ensures it can fall back on a backup plan if the main supplier fails.","The company ensures it can fall backward onto a backup plan if the main supplier fails.","The company ensures it can fall back in a backup plan if the main supplier fails.","The company''s basically got a plan B to fall back on if stuff goes wrong, yeah."]',
   0, '[0]', 'single',
   '{"asked":"緊急時の頼みの綱を fall back on で述べられるか。","point":"fall back on＝（他の手段が失敗したときの）頼みの綱として使う。リスク対策文書の定番表現。","kid":"fall back on＝いざというとき頼る。倒れそうになったときに支えてもらうイメージ。","eg":"If negotiations collapse, the firm can fall back on its existing contract.","terms":[["fall back on + 名詞","backup plan/savings など予備の手段の名詞と相性が良い"],["fall back in（誤用）","前置詞は on 固定、in は誤り"]],"think":"リスク対策の文→頼みの綱にする→動詞は fall→粒子は back→前置詞 on。","vs":"直訳肢の fall backward onto は「後ろ向きに倒れる」という物理的動作を強調しすぎた不自然な直訳。fall back in は前置詞の誤用。最後の肢は plan B/stuff goes wrong/yeah など口語表現でフォーマルなリスク対策文書に不適。","why_asked":"CAE Reading のリスクマネジメント記事、IELTS Writing の対策説明パラグラフで頻出。","usecase":"企業や個人が緊急時の代替手段を確保していることを説明する定型。","opt":["正解。fall back on が頼みの綱の標準形。","物理的動作を強調した不自然な直訳。","前置詞の誤用。","口語すぎてリスク対策文書に不適。"]}'),

  ('pv-t1b-q13', '要約・帰着系',
   '〔中立〕結局のところ、この議論は予算の問題に帰着する、とまとめる。',
   NULL::text,
   '["In the end, this debate boils down to a question of budget.","In the end, this debate is boiled and reduced down to a question of budget.","In the end, this debate boils up to a question of budget.","At the end of the day, it is fundamentally a matter pertaining to budgetary considerations."]',
   0, '[0]', 'single',
   '{"asked":"議論の核心への帰着を boil down to で述べられるか。","point":"boil down to＝煮詰めていくと結局〜になる。複雑な議論を核心の一点に絞るときの定番表現。","kid":"boil down to＝結局〜に尽きる。鍋を煮詰めて水分を飛ばし、中身だけ残すイメージ。","eg":"Most complaints boil down to a lack of communication.","terms":[["boil down to + 名詞","core issue/question など核心の名詞と相性が良い"],["boil up（誤用）","「（怒りなどが）沸き立つ・爆発する」で全く別の意味"]],"think":"まとめの文→核心に帰着する→動詞は boil→粒子は down→前置詞 to。","vs":"直訳肢の is boiled and reduced down to は「煮る」を文字通り強調しすぎた不自然な直訳。boil up は「感情が沸き立つ」という別の意味になる誤用トラップ。最後の肢は budgetary considerations など過度にフォーマルな語彙で、この場面の「中立」なまとめのトーンには重すぎる。","why_asked":"CAE Speaking Part 3・4 の議論まとめ、IELTS Speaking Part 3 の結論表現で頻出。","usecase":"複雑な議論を一言でまとめて核心を示す自然な言い方。","opt":["正解。boil down to が核心への帰着を示す標準形。","「煮る」を強調しすぎた不自然な直訳。","boil up は全く別の意味。","過度にフォーマルでこの場面には重すぎる。"]}'),

  ('pv-t1b-q14', '要約・帰着系',
   '〔中立〕最終的に、この選択は時間とコストのどちらを優先するかに行き着く。',
   NULL::text,
   '["In the end, this choice comes down to prioritizing time or cost.","In the end, this choice comes down until prioritizing time or cost.","In the end, this choice comes down on prioritizing time or cost.","At the end of the day, it is essentially reducible to a trade-off between temporal and financial priorities."]',
   0, '[0]', 'single',
   '{"asked":"最終的な判断基準への帰着を come down to で述べられるか。","point":"come down to＝結局のところ〜に行き着く。複数の要因を一つの判断軸に絞るときの定番表現。","kid":"come down to＝結局〜次第になる。話が最終的に一点まで降りてくるイメージ。","eg":"The decision usually comes down to which option offers better long-term value.","terms":[["come down to + 名詞/動名詞","判断軸・要因の名詞や -ing 形と相性が良い"],["come down to vs come down on（誤用）","on は「（人を）厳しく叱る」という別の句動詞になる"]],"think":"まとめの文→判断軸に行き着く→動詞は come→粒子は down→前置詞 to。","vs":"直訳肢の comes down until は until を無理に当てはめた前置詞の誤用。comes down on は「（人を）厳しく叱る」という全く別の句動詞になる重要な誤用トラップ。最後の肢は temporal and financial priorities など専門用語的で過度にフォーマルなため、この場面の自然な話し言葉のまとめには合わない。","why_asked":"IELTS Speaking Part 3 の意思決定トピック、CAE Speaking の議論まとめで頻出。","usecase":"複数の選択肢の判断基準を一言でまとめる自然な言い方。","opt":["正解。come down to が判断軸への帰着を示す標準形。","前置詞の誤用。","come down on は「叱る」で全く別の意味。","専門用語的で過度にフォーマル。"]}'),

  ('pv-t1b-q15', '要約・帰着系',
   '〔フォーマル〕個々の小さな遅延が積み重なり、結局は大きな損失につながった、と分析する。',
   NULL::text,
   '["Individually small delays added up to a significant overall loss.","Individually small delays were added and became a significant overall loss.","Individually small delays added up on a significant overall loss.","All those little delays basically snowballed into a massive loss, yeah."]',
   0, '[0]', 'single',
   '{"asked":"積み重なった結果を add up to で述べられるか。","point":"add up to＝積み重なって結局〜になる。小さな要素の合計が大きな結果に至ることを示す分析文の定番。","kid":"add up to＝合計すると〜になる。小さな数字を足し算していくと大きな数字になるイメージ。","eg":"These minor inefficiencies add up to a substantial waste of resources over a year.","terms":[["add up to + 名詞","結果としての合計・総量の名詞と相性が良い"],["add up on（誤用）","前置詞は to 固定、on は誤り"]],"think":"分析文→積み重なった結果→動詞は add→粒子は up→前置詞 to。","vs":"直訳肢の were added and became は受動＋becomeを二重に使った冗長な直訳構造。add up on は前置詞の誤用。最後の肢は snowballed/yeah など口語表現でフォーマルな分析文には不適だが、意味自体は近い近義語トラップ。","why_asked":"CAE Reading の分析記事、IELTS Writing Task 1 の累積データ説明で頻出。","usecase":"小さな要因の積み重ねが大きな結果を生んだことを分析する定型表現。","opt":["正解。add up to が積み重ねの結果を示す標準形。","冗長な受動の直訳調。","前置詞の誤用。","口語すぎて分析文に不適。"]}'),

  ('pv-t1b-q16', '要約・帰着系',
   '〔フォーマル〕今回の値上げは、実質的な賃金カットに等しい、と労働組合は主張する。',
   NULL::text,
   '["The union argues that the price hike amounts to a real wage cut.","The union argues that the price hike becomes the same amount as a real wage cut.","The union argues that the price hike amounts for a real wage cut.","The union''s basically saying this price hike is kind of like a pay cut, right."]',
   0, '[0]', 'single',
   '{"asked":"実質的に等しいことを amount to で述べられるか。","point":"amount to＝実質的に〜に等しい。数値上は違っても実質的な意味が同じであることを示す定番表現。","kid":"amount to＝結局〜と同じことになる。合計すると同じ額になるイメージから、実質的に等しいという意味に発展した語。","eg":"Ignoring the warning signs amounts to negligence.","terms":[["amount to + 名詞","実質的に等しいとされる結果の名詞と相性が良い"],["amount for（誤用）","前置詞は to 固定、for は誤り"]],"think":"主張の文→実質的に等しい→動詞は amount→前置詞は to。","vs":"直訳肢の becomes the same amount as は amount を名詞として直訳的に説明しすぎた冗長な構造。amounts for は前置詞の誤用。最後の肢は kind of/right など口語表現で労働組合の公式主張としては砕けすぎる。","why_asked":"CAE Reading の経済・労働記事、IELTS Writing の実質的影響を論じるパラグラフで頻出。","usecase":"数値上の変化が実質的に何を意味するかを主張する定型表現。","opt":["正解。amounts to が実質的な等価を示す標準形。","名詞化した冗長な直訳。","前置詞の誤用。","口語すぎて公式主張に不適。"]}'),

  ('pv-t1b-q17', '要約・帰着系',
   '〔フォーマル〕結論として、今回のプロジェクトの主な成果を要約する。',
   NULL::text,
   '["To sum up, let us review the main achievements of this project.","To make a sum, let us review the main achievements of this project.","To sum out, let us review the main achievements of this project.","So yeah, basically, here''s the main stuff we got done."]',
   0, '[0]', 'single',
   '{"asked":"結論部での要約導入を to sum up で述べられるか。","point":"to sum up＝要約すると。プレゼンテーションやレポートの結論部を導入する定番の決まり文句。","kid":"to sum up＝まとめると。ここまでの話を合計してひとことで言うイメージ。","eg":"To sum up, the pilot programme exceeded expectations in three key areas.","terms":[["to sum up,","文頭に置く独立した導入句。カンマで区切る"],["sum out（誤用）","存在しない組み合わせ"]],"think":"結論部の導入→要約する→動詞は sum→粒子は up。","vs":"直訳肢の To make a sum は sum を名詞として直訳的に使った不自然な構造。sum out は存在しない誤用。最後の肢は So yeah/basically/here''s など口語表現でプレゼンテーションの結論部としては砕けすぎる。","why_asked":"CAE Speaking Part 4 のプレゼンテーション、IELTS Writing の結論パラグラフで最頻出の定型句。","usecase":"プレゼンテーションやレポートの結論部を始める決まり文句。","opt":["正解。To sum up が結論部導入の標準形。","sumを名詞として使った不自然な直訳。","sum out は存在しない誤用。","口語すぎて結論部に不適。"]}'),

  ('pv-t1b-q18', '要約・帰着系',
   '〔中立〕そろそろ会議を締めくくりましょう、と司会が言う。',
   NULL::text,
   '["Let''s wrap up the meeting now.","Let''s put a wrap on top of the meeting now.","Let''s wrap out the meeting now.","Right, shall we call it a day on this meeting or what."]',
   0, '[0]', 'single',
   '{"asked":"会議を締めくくる合図を wrap up で述べられるか。","point":"wrap up＝（会議・作業を）締めくくる・終える。司会進行の最頻出フレーズ。","kid":"wrap up＝包んで終える。プレゼントを包装紙で包むように、話をきれいにまとめて終えるイメージ。","eg":"Let''s wrap up this discussion and move on to the next agenda item.","terms":[["wrap up + 名詞","meeting/discussion などの名詞と相性が良い"],["wrap out（誤用）","存在しない組み合わせ"]],"think":"司会の進行文→会議を締めくくる→動詞は wrap→粒子は up。","vs":"直訳肢の put a wrap on top of は wrap を「包装紙」と文字通り直訳した誤解に基づく不自然な表現。wrap out は存在しない誤用。最後の肢は call it a day/or what など口語表現でやや投げやりに響き、司会の進行としてはトーンが強すぎる。","why_asked":"CAE Speaking Part 4 の会議運営トピック、IELTS Speaking の日常会話表現で頻出。","usecase":"会議や作業を締めくくる際の司会・進行役の自然な一言。","opt":["正解。wrap up が締めくくりの標準形。","wrapを包装紙と誤解した直訳。","wrap out は存在しない誤用。","口語すぎて司会の進行に不適。"]}'),

  ('pv-t1b-q19', '要約・帰着系',
   '〔フォーマル〕研修は、実践的なワークショップで締めくくられた。',
   NULL::text,
   '["The training was rounded off with a hands-on workshop.","The training was made round at the end with a hands-on workshop.","The training was rounded up with a hands-on workshop.","The training basically ended with a fun little workshop, cool."]',
   0, '[0]', 'single',
   '{"asked":"締めくくりを round off で受動形で述べられるか。","point":"round off＝（イベント・活動を）きれいに締めくくる。仕上げとして最後を整えるニュアンスの定番語。","kid":"round off＝角を丸めて仕上げる。ぎざぎざだったものを丸く整えて終わらせるイメージ。","eg":"The conference was rounded off with a networking dinner.","terms":[["be rounded off with + 名詞","締めくくりの行事・活動の名詞と相性が良い"],["round up（誤用）","「（人や数を）集める・切り上げる」で全く別の意味"]],"think":"研修報告文→締めくくられた→動詞は round→粒子は off。","vs":"直訳肢の was made round at the end は round を「丸い形」と文字通り直訳した誤解に基づく不自然な表現。round up は「（人を集める・数を切り上げる）」という全く別の意味になる重要な誤用トラップ。最後の肢は fun little/cool など口語表現でフォーマルな研修報告に不適。","why_asked":"CAE Reading の研修・イベント報告記事、IELTS Writing のプロセス完了報告で頻出。","usecase":"研修やイベントが最後にどう締めくくられたかを報告する定型表現。","opt":["正解。round off が締めくくりの標準形。","roundを丸い形と誤解した直訳。","round up は全く別の意味。","口語すぎて研修報告に不適。"]}'),

  ('pv-t1b-q20', '要約・帰着系',
   '〔中立〕プロジェクトの前に、いくつかの未解決事項を片付けておく必要がある。',
   NULL::text,
   '["We need to tie up a few loose ends before the project starts.","We need to tie the ends of the rope up before the project starts.","We need to tie in a few loose ends before the project starts.","Gotta sort out a couple of loose bits before we kick this off, yeah."]',
   0, '[0]', 'single',
   '{"asked":"未解決事項の処理を tie up loose ends で述べられるか。","point":"tie up loose ends＝未解決の細かい事項を片付ける。プロジェクト開始・終了前の定番の決まり文句。","kid":"tie up loose ends＝ほつれた糸の端を結んで片付ける。細かい未解決事項をきちんと処理するイメージ。","eg":"Before I leave, I want to tie up a few loose ends with the client.","terms":[["tie up loose ends","慣用句として一体で覚える定型表現"],["tie in（誤用）","「関連づける・整合させる」で全く別の意味"]],"think":"準備の文→未解決事項を片付ける→動詞は tie→粒子は up→目的語 loose ends。","vs":"直訳肢の tie the ends of the rope up は loose ends を文字通り「縄の端」と直訳した誤解に基づく不自然な表現。tie in は「関連づける・整合させる」という全く別の意味になる誤用トラップ。最後の肢は Gotta/kick this off/yeah など口語表現で中立的な準備の説明としてはやや砕けすぎる。","why_asked":"CAE Speaking Part 4 のプロジェクト管理トピック、IELTS Writing のプロセス説明で頻出の慣用句。","usecase":"プロジェクトや作業の前後に細かい未解決事項を処理することを述べる定型。","opt":["正解。tie up loose ends が未解決事項の処理を示す標準形。","loose endsを文字通り誤解した直訳。","tie in は全く別の意味。","口語すぎて中立的な説明にやや不適。"]}'),

  ('pv-t1b-q21', '要約・帰着系',
   '〔フォーマル〕総費用は、当初の見積もりよりわずかに高く出た、と報告する。',
   NULL::text,
   '["The total cost worked out slightly higher than the initial estimate.","The total cost was calculated and came out slightly higher than the initial estimate.","The total cost worked in slightly higher than the initial estimate.","The total cost basically ended up a bit more than we first thought, meh."]',
   0, '[0]', 'single',
   '{"asked":"最終的な計算結果を work out で述べられるか。","point":"work out＝（計算・結果が）最終的に〜という数値になる。予測との差を報告する分析文の定番動詞。","kid":"work out＝計算して結果が出る。計算を進めていって、最終的な答えにたどり着くイメージ。","eg":"The average cost per unit worked out at just under 10 dollars.","terms":[["work out + 比較表現","higher/lower than など比較の表現と相性が良い"],["work in（誤用）","前置詞は out 固定、in は誤り"]],"think":"報告文→最終的な計算結果→動詞は work→粒子は out。","vs":"直訳肢の was calculated and came out は「計算されて出てきた」を二重の動詞で説明しすぎた冗長な直訳。work in は前置詞の誤用。最後の肢は ended up/meh など口語表現でフォーマルな報告文に不適。","why_asked":"CAE Reading の財務報告記事、IELTS Writing Task 1 の予測と実績の比較で頻出。","usecase":"見積もりと実績の差を報告する財務・分析文の定型表現。","opt":["正解。worked out が最終計算結果を示す標準形。","二重動詞の冗長な直訳。","前置詞の誤用。","口語すぎて報告文に不適。"]}'),

  ('pv-t1b-q22', '要約・帰着系',
   '〔中立〕レシートをすべて合計してみたら、思ったより高かった。',
   NULL::text,
   '["When I totted up all the receipts, it came to more than expected.","When I made a total of all the receipts, it came to more than expected.","When I totted in all the receipts, it came to more than expected.","When I basically added up all the receipts, it was more than I thought, ugh."]',
   0, '[0]', 'single',
   '{"asked":"手作業での合計を tot up で述べられるか（イギリス英語の口語寄り中立表現）。","point":"tot up＝（数字を）ちまちまと合計する。add up より口語的でカジュアルな計算作業を指す語。","kid":"tot up＝合計を出す。レシートや小さな数字を一つずつ足していくイメージ。","eg":"I totted up the scores at the end of the game.","terms":[["tot up + 名詞","receipts/scores など小さな数字の集まりの名詞と相性が良い"],["tot in（誤用）","前置詞は up 固定、in は誤り"]],"think":"日常の計算作業→合計する→動詞は tot→粒子は up。","vs":"直訳肢の made a total of は tot を名詞 total として直訳的に使った回りくどい表現。tot in は前置詞の誤用。最後の肢は basically/ugh など口語表現に加え add up という別の近義語も混ぜており、tot up 特有のニュアンスからずれる。","why_asked":"IELTS Speaking Part 1 の日常生活トピック、CAE Speaking の家計・買い物の話題で使われる口語寄り表現。","usecase":"レシートや点数など、小さな数字を手作業で合計する場面の自然な言い方。","opt":["正解。totted up が手作業の合計を示す標準形。","totを名詞として使った回りくどい直訳。","前置詞の誤用。","口語すぎ、かつ別の近義語が混ざり不自然。"]}'),

  ('pv-t1b-q23', '要約・帰着系',
   '〔中立〕彼の説明の数字がどうしても合わない、と会計士は指摘する。',
   NULL::text,
   '["The accountant points out that the numbers in his explanation simply do not add up.","The accountant points out that the numbers in his explanation do not become added correctly.","The accountant points out that the numbers in his explanation do not add on.","The accountant''s basically saying his numbers don''t add up, which is sus."]',
   0, '[0]', 'single',
   '{"asked":"計算・説明の整合性のなさを add up で述べられるか（自動詞用法）。","point":"add up＝（数字や説明の筋が）合う・つじつまが合う。否定形 do not add up で「つじつまが合わない」という重要な慣用表現。","kid":"add up＝足し算した結果が合う。数字だけでなく、説明の筋が通っているかにも使う語。","eg":"His story about being late does not add up.","terms":[["add up（自動詞）","目的語を取らず、数字や話の筋そのものが主語になる"],["add on（誤用）","「追加する」で他動詞的に使う全く別の意味"]],"think":"会計士の指摘文→つじつまが合わない→動詞は add→粒子は up（自動詞）。","vs":"直訳肢の do not become added correctly は受動＋becomeを組み合わせた冗長な直訳構造。add on は「追加する」という他動詞的な全く別の意味になる誤用トラップ。最後の肢は don''t/sus などスラングで会計士の指摘としては砕けすぎる。","why_asked":"CAE Reading の会計・不正調査記事、IELTS Speaking Part 3 の論理性を問う議論で頻出の慣用表現。","usecase":"説明や数字のつじつまが合わないことを指摘する自然な言い方。","opt":["正解。do not add up がつじつまの合わなさを示す標準形。","受動＋becomeの冗長な直訳。","add on は全く別の意味。","スラングで会計士の指摘に不適。"]}'),

  ('pv-t1b-q24', '要約・帰着系',
   '〔中立〕会計は、税込みで合計52ドルになった。',
   NULL::text,
   '["The bill came to 52 dollars including tax.","The bill arrived at the number of 52 dollars including tax.","The bill came at 52 dollars including tax.","The bill was basically like 52 bucks with tax, or something."]',
   0, '[0]', 'single',
   '{"asked":"合計金額の提示を come to で述べられるか。","point":"come to＝（合計が）〜になる。会計・請求額を提示するときの最頻出の定番動詞。","kid":"come to＝合計すると〜に来る。数字を足していった最終地点にたどり着くイメージ。","eg":"With the discount applied, the total came to just 30 dollars.","terms":[["come to + 金額","合計金額の名詞と相性が良い"],["come at（誤用）","前置詞は to 固定、at は誤り"]],"think":"会計場面→合計金額を提示→動詞は come→前置詞は to。","vs":"直訳肢の arrived at the number of は「到着する」を直訳的に使った回りくどい表現。come at は前置詞の誤用。最後の肢は bucks/or something など口語表現で会計金額の提示としてはやや曖昧すぎる。","why_asked":"IELTS Speaking Part 1 の買い物トピック、CAE Speaking の日常会話語彙で頻出。","usecase":"レジや請求で合計金額を伝える自然な言い方。","opt":["正解。came to が合計金額の提示の標準形。","回りくどい直訳調。","前置詞の誤用。","口語すぎ、かつ曖昧な金額表現。"]}'),

  ('pv-t1b-q25', '要約・帰着系',
   '〔フォーマル〕四半期ごとの経費をすべて合計する必要がある、と経理部が指示する。',
   NULL::text,
   '["The finance team instructs that all quarterly expenses be totalled up.","The finance team instructs that all quarterly expenses be made into a total up.","The finance team instructs that all quarterly expenses be totalled on.","Finance basically wants someone to add up all the quarterly spending, kinda urgent."]',
   0, '[0]', 'single',
   '{"asked":"フォーマルな指示文で total up を受動形で使えるか。","point":"total up＝（経費・数値を）合計する。add up より事務的・フォーマルな響きを持つ語。","kid":"total up＝全体の合計を出す。総額（total）を動詞的に使って合計するイメージ。","eg":"All expense reports must be totalled up before the end of the quarter.","terms":[["be totalled up","受動形での指示文に多い定型"],["total on（誤用）","前置詞は不要、on を付けると誤り"]],"think":"経理部の指示文→合計する→動詞は total→粒子は up。","vs":"直訳肢の be made into a total up は total を名詞として不自然に組み込んだ回りくどい直訳。totalled on は不要な前置詞を付けた誤用。最後の肢は basically/kinda urgent など口語表現で経理部の公式指示としては砕けすぎる。","why_asked":"CAE Reading の社内通達・業務指示文、IELTS Writing のフォーマルな指示表現で頻出。","usecase":"経費や数値の集計を指示するフォーマルな業務連絡の定型。","opt":["正解。totalled up が合計指示の標準形。","名詞化した回りくどい直訳。","不要な前置詞を付けた誤用。","口語すぎて経理部の指示に不適。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'pv-t1-b'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
