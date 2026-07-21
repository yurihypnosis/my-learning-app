-- 英語・句動詞（Set T1-A）: 学術・フォーマル系25問（原因・結果系9／実行・遂行系8／除外・特定系8）
-- question-authoring-pv スキル準拠。docs/pv-seed-strategy.md により 9/1 投入予定を前倒し実行。
BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('pv-t1-a',
        '英語・句動詞（Set T1-A）',
        '【Speak-First】日本語の場面を見たら、選択肢を見る前に3秒以内で英文を声に出す。言ってから表示。口で言えなかったら解答後にチップを押す。',
        '#6ab08d', 64, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('原因・結果系', '#6ab08d', 1),
  ('実行・遂行系', '#3b82f6', 2),
  ('除外・特定系', '#f59e0b', 3)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'pv-t1-a'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('pv-t1a-q01', '原因・結果系',
   '〔フォーマル〕この問題の多くは、初期段階での曖昧なコミュニケーションに起因する、と論文で述べる。',
   NULL::text,
   '["Many of these problems stem from ambiguous communication at the early stages.","These many problems come from the fact that the communication was vague at the early stages.","These problems stem out of ambiguous communication at the early stages.","These problems are basically down to fuzzy communication early on, to be honest."]',
   0, '[0]', 'single',
   '{"asked":"原因を論文調の書き言葉で述べられるか。","point":"stem from＝根から生える。原因の根源をたどるイメージで学術文に定番。","kid":"stem from＝〜に起因する。原因の「根っこ」を示す語。","eg":"The delay stems from a miscommunication between teams.","terms":[["stem from + 名詞","前置詞は from 固定"],["the root cause","stem from と相性の良い語彙"]],"think":"論文調→原因を述べる→動詞は stem→前置詞は from。","vs":"直訳肢は the fact that を挟む説明的な構造で学術文としては冗長。stem out of は from と out of を混ぜた誤用で存在しない組み合わせ。down to は口語で因果を軽く言う表現でフォーマルな論文には不適。","why_asked":"CAE Use of English Part 1・IELTS Writing Task 2 の原因説明パラグラフで頻出。","usecase":"レポートや論文の Discussion セクションで原因を述べる定型。","opt":["正解。stem from が学術文の定型。","説明的すぎる直訳調。","stem out of は誤った組み合わせ。","口語すぎてフォーマルな論文に合わない。"]}'),

  ('pv-t1a-q02', '原因・結果系',
   '〔フォーマル〕新しい規制がサプライチェーンに大きな変化をもたらした、と報告書に書く。',
   NULL::text,
   '["The new regulation has brought about significant changes in the supply chain.","The new regulation made the supply chain change a lot.","The new regulation has brought on significant changes in the supply chain.","The new rules totally shook up the supply chain, you know."]',
   0, '[0]', 'single',
   '{"asked":"制度的な変化の結果を報告書の語彙で述べられるか。","point":"bring about＝中立的に変化を引き起こす。良い変化にも悪い変化にも使える万能語。","kid":"bring about＝〜をもたらす。結果としての変化を作り出すイメージ。","eg":"The merger brought about a complete restructuring of the department.","terms":[["bring about + 名詞","他動詞、目的語は結果の名詞句"],["significant changes","bring about と好相性のコロケーション"]],"think":"報告書→変化をもたらす→動詞は bring→粒子は about。","vs":"直訳肢は made … change a lot で口語的かつ稚拙。bring on は主に病気や好ましくない事態を「引き起こす」ニュアンスが強く、中立的な制度変化には硬さが合わない。totally shook up は完全に口語のスラング表現。","why_asked":"IELTS Writing のデータ変化の説明、CAE のレポートライティングで頻出。","usecase":"政策・規制の影響を説明するレポート文の骨格。","opt":["正解。中立的な変化の記述に最適。","口語的直訳で報告書に不向き。","bring on はネガティブな事態向けでニュアンスが硬すぎる。","スラングでフォーマル文脈に不適。"]}'),

  ('pv-t1a-q03', '原因・結果系',
   '〔中立〕在庫管理の甘さが今回の欠品を招いた、と説明する言い方として自然なものを2つ。',
   NULL::text,
   '["Poor inventory management resulted in this stock shortage.","Poor inventory management led to this stock shortage.","Poor inventory management resulted from this stock shortage.","Poor inventory management was the result that this stock shortage happened for."]',
   0, '[0,1]', 'multi',
   '{"asked":"result in と lead to を因果の同義表現として使い分けられるか。","point":"result in / lead to はどちらも「原因→結果」の順で使える。方向を間違えないことが最重要。","kid":"result in＝〜という結果になる。lead to＝〜につながる。どちらも原因が主語。","eg":"The new policy resulted in / led to a drop in complaints.","terms":[["result in vs result from","in は原因が主語、from は結果が主語で向きが逆"],["lead to + 名詞/動名詞","目的語は名詞か -ing"]],"think":"中立の説明→原因が主語→result in か lead to のどちらでも成立。","vs":"result from は方向が逆（結果が主語になる形）で、この文の主語（在庫管理の甘さ＝原因）には合わない。最後の直訳肢は the result that … happened for という不自然な構造で、原因と結果の関係が説明的すぎる。","why_asked":"IELTS Writing Task 1 のデータ因果説明、CAE の類義語選択問題で頻出のペア。","usecase":"レポートで同じ因果関係を言い換える際の定番2択。","opt":["正解。result in は原因が主語の標準形。","正解。lead to も同じ向きで使える近義語。","方向が逆。result from は結果が主語のときの形。","説明的な直訳調で不自然。"]}'),

  ('pv-t1a-q04', '原因・結果系',
   '〔フォーマル〕生産コストの上昇の大部分は、原材料価格の高騰で説明できる、と分析する。',
   NULL::text,
   '["Rising raw material prices account for most of the increase in production costs.","Rising raw material prices are the reason that explains most of the increase in production costs.","Rising raw material prices account to most of the increase in production costs.","Basically it is the raw material prices that are pushing costs up, right?"]',
   0, '[0]', 'single',
   '{"asked":"数量・割合の原因説明を分析文の語彙で述べられるか。","point":"account for＝割合や量を占める形で原因を説明する。数値分析の定番動詞。","kid":"account for＝〜の説明になる／〜の割合を占める。原因を数量で示すときに使う。","eg":"Transport costs account for nearly 30% of the total budget.","terms":[["account for + 割合","most of / X% など数量表現と相性が良い"],["account to（誤用）","account for が正しく、to は使わない"]],"think":"分析文→割合で原因を示す→動詞は account→前置詞は for。","vs":"直訳肢は the reason that explains という冗長な二重構造で分析文としては不自然。account to は前置詞の誤用で存在しない形。疑問形＋口語の basically/right は分析文の断定調に合わない。","why_asked":"IELTS Writing Task 1 のグラフ説明、CAE のビジネス記事読解で頻出語彙。","usecase":"コスト分析・要因分析のレポートで割合を示すときの定型。","opt":["正解。account for は割合を占める形の標準表現。","冗長な直訳調。","account to は誤った前置詞。","口語の疑問文で分析文に不適。"]}'),

  ('pv-t1a-q05', '原因・結果系',
   '〔中立〕長時間労働が従業員の離職につながっている、と指摘する。',
   NULL::text,
   '["Long working hours are leading to higher employee turnover.","Long working hours are connecting to higher employee turnover.","Long working hours are leading on higher employee turnover.","Working crazy hours is basically driving people to quit, tbh."]',
   0, '[0]', 'single',
   '{"asked":"進行中の傾向としての因果を lead to で述べられるか。","point":"lead to＝結果へと導く。進行形（be leading to）で「今まさに進んでいる傾向」を示せる。","kid":"lead to＝〜につながる。原因から結果への一本道のイメージ。","eg":"Rising rents are leading to more people moving out of the city.","terms":[["lead to + 名詞","目的語は名詞か動名詞"],["lead on（誤用）","「人を誤解させ続ける」という別の意味で因果には使わない"]],"think":"進行中の傾向→原因が主語→動詞は lead→粒子は to。","vs":"直訳肢の connecting to は「つながる」の直訳だが因果関係を表す動詞としては不自然。lead on は「（人を）だまして期待させ続ける」という全く別の意味になる重要な誤用トラップ。tbh 付きの口語文は指摘・分析のトーンに合わない。","why_asked":"CAE Speaking Part 3 の社会問題ディスカッション、IELTS Writing の因果パラグラフで頻出。","usecase":"労働環境などの社会的傾向を指摘する際の定番表現。","opt":["正解。進行形で傾向を示す標準形。","直訳調で不自然な動詞選択。","lead on は「誤解させる」で意味が全く違う。","口語すぎて指摘のトーンに合わない。"]}'),

  ('pv-t1a-q06', '原因・結果系',
   '〔フォーマル〕この曖昧な条項が、後の解釈上の対立を生んだ、と契約書レビューで述べる。',
   NULL::text,
   '["This ambiguous clause gave rise to later disputes over interpretation.","This ambiguous clause created the birth of later disputes over interpretation.","This ambiguous clause gave rise for later disputes over interpretation.","That vague bit in the contract basically kicked off a whole fight later."]',
   0, '[0]', 'single',
   '{"asked":"法務・契約文書調で「〜を生んだ」を言えるか。","point":"give rise to＝（問題などを）生じさせる。契約書レビューやフォーマルな指摘文の定番。","kid":"give rise to＝〜を引き起こす。何かが「生まれ出る」きっかけになるイメージ。","eg":"The unclear wording gave rise to several legal challenges.","terms":[["give rise to + 名詞","目的語は問題・対立などのネガティブな名詞が多い"],["前置詞は to 固定","for などに置き換え不可"]],"think":"契約書レビュー→問題を生じさせる→動詞は give rise→前置詞は to。","vs":"直訳肢の created the birth of は比喩を直訳した不自然な表現。give rise for は前置詞の誤用。最後の肢は vague bit や kicked off a whole fight など完全に口語で契約書レビューの文体と乖離している。","why_asked":"CAE の Use of English Part 1、法務・ビジネス文書読解で頻出のコロケーション。","usecase":"契約・規約の曖昧さが招いた問題を指摘するフォーマルな一文。","opt":["正解。give rise to が契約書レビューの定型。","比喩の直訳調で不自然。","前置詞の誤用。","口語すぎて契約書レビューに不適。"]}'),

  ('pv-t1a-q07', '原因・結果系',
   '〔フォーマル・受動〕今回の遅延は、承認プロセスの複雑さから生じたものである、と報告する。',
   NULL::text,
   '["The delay arose from the complexity of the approval process.","The delay was born from the complexity of the approval process.","The delay arose out from the complexity of the approval process.","The holdup was basically down to how complicated approvals are."]',
   0, '[0]', 'single',
   '{"asked":"arise from を使って原因を受動的・客観的に述べられるか。","point":"arise from＝〜から生じる。原因が主語ではなく結果が主語になる、result in とは逆向きの構文。","kid":"arise from＝〜に起因する。結果（The delay）が先に来て、そこから原因を説明する形。","eg":"Most of the confusion arose from a lack of clear instructions.","terms":[["arise from + 名詞","結果が主語、原因は from の後ろ"],["arise out of","from の代わりに out of も可だが out from は誤り"]],"think":"報告文→結果が主語→動詞は arise→前置詞は from。","vs":"直訳肢の was born from は比喩の直訳で不自然。arise out from は out of と from を混同した誤用で存在しない形。最後の肢は holdup や down to など口語表現で報告文の客観的トーンに合わない。","why_asked":"CAE Use of English Part 1 の前置詞問題、IELTS Writing のフォーマルな原因説明で頻出。","usecase":"インシデント報告書やプロジェクト報告での遅延理由の説明。","opt":["正解。arise from が結果主語の標準形。","比喩の直訳調で不自然。","out from は誤った組み合わせ。","口語すぎて報告文に不適。"]}'),

  ('pv-t1a-q08', '原因・結果系',
   '〔中立〕過度なストレスが今回の体調不良を引き起こした、と医師に説明する。',
   NULL::text,
   '["Excessive stress brought on this bout of poor health.","Excessive stress made this bad health condition come.","Excessive stress brought about this bout of poor health.","Stress basically brought this on, innit."]',
   0, '[0]', 'single',
   '{"asked":"体調・発作系の原因には bring on を使うと自然だとわかるか。","point":"bring on＝（病気・発作などの好ましくない事態を）引き起こす。体調関連はこの語が定番。","kid":"bring on＝〜を引き起こす（悪いことに使うことが多い）。ストレスや疲労が体調に直結するイメージ。","eg":"Skipping meals can bring on headaches.","terms":[["bring on + 症状","病気・発作などネガティブな名詞と相性が良い"],["bring about","中立的な変化に使う語で体調にはやや硬い"]],"think":"医師への説明→体調不良の原因→動詞は bring→粒子は on。","vs":"直訳肢の made … come は「来させる」の直訳で不自然な動詞選択。bring about は中立的な変化には合うが、体調不良のような具体的な発作・症状の表現としては硬すぎてこの場面のニュアンスに合わない。innit 付きの文は方言的スラングで医師への説明に不適。","why_asked":"IELTS Speaking Part 1 の健康トピック、日常会話での体調説明で頻出。","usecase":"医師や同僚に体調不良の原因を話すときの自然な言い方。","opt":["正解。体調不良の原因には bring on が定番。","直訳調で不自然な動詞。","bring about は中立的すぎてニュアンスが弱い。","スラングで医師への説明に不適。"]}'),

  ('pv-t1a-q09', '原因・結果系',
   '〔フォーマル〕不十分な換気が、今回の事故の一因になった、と調査報告に記す。',
   NULL::text,
   '["Inadequate ventilation contributed to the accident.","Inadequate ventilation became one cause that contributed to the accident.","Inadequate ventilation contributed for the accident.","Bad airflow was kind of a factor in the accident, I guess."]',
   0, '[0]', 'single',
   '{"asked":"複数要因のうちの一因を contribute to で述べられるか。","point":"contribute to＝（複数ある要因の）一つとして貢献する・寄与する。単一原因ではなく一因を示すときの標準語。","kid":"contribute to＝〜の一因となる。良いことにも悪いことにも使える中立的な語。","eg":"Poor lighting also contributed to the near-miss incident.","terms":[["contribute to + 名詞","前置詞は to 固定、for は不可"],["one of the factors that contributed to","一因であることを強調する定型"]],"think":"調査報告→一因を述べる→動詞は contribute→前置詞は to。","vs":"直訳肢の became one cause that contributed to は同じ動詞を二重に使う冗長な構造で不自然。contributed for は前置詞の誤用。最後の肢は kind of や I guess など曖昧なヘッジ表現で調査報告の断定的なトーンに合わない。","why_asked":"CAE Use of English、IELTS Writing の複数要因分析パラグラフで頻出。","usecase":"事故調査・原因分析報告で複数要因の一つを示す定型。","opt":["正解。contribute to が一因を示す標準形。","動詞の重複で冗長な直訳調。","前置詞の誤用。","曖昧な口語表現で調査報告に不適。"]}'),

  ('pv-t1a-q10', '実行・遂行系',
   '〔フォーマル〕独立委員会が全面的な調査を実施した、と発表する。',
   NULL::text,
   '["An independent committee carried out a full investigation.","An independent committee did the execution of a full investigation.","An independent committee carried through a full investigation.","Some independent panel basically did the whole investigation thing."]',
   0, '[0]', 'single',
   '{"asked":"「実施する」を carry out で客観的に述べられるか。","point":"carry out＝（計画・調査・指示などを）実施する。フォーマルな発表文の最頻出動詞の一つ。","kid":"carry out＝〜を実行する・実施する。計画を最後まで運び切るイメージ。","eg":"The team carried out a series of tests before the launch.","terms":[["carry out + 名詞","調査・任務・命令などの名詞と相性が良い"],["carry out vs carry through","out は実施そのもの、through は最後までやり遂げる過程を強調"]],"think":"発表文→調査を実施した→動詞は carry→粒子は out。","vs":"直訳肢の did the execution of は execution を名詞のまま直訳的に使う不自然な構造。carry through は「最後までやり遂げる」という過程の強調が強く、単なる「実施した」という事実の報告にはニュアンスが重すぎる。最後の肢は panel/basically/thing などカジュアルな語彙で発表文の格に合わない。","why_asked":"CAE Use of English Part 1、ニュース記事・報告書読解で最頻出のコロケーション。","usecase":"調査・監査・実験などの実施を発表する定型表現。","opt":["正解。carry out が「実施する」の標準形。","名詞化した直訳調で不自然。","ニュアンスが重すぎる（過程の強調）。","口語すぎて発表文に不適。"]}'),

  ('pv-t1a-q11', '実行・遂行系',
   '〔フォーマル〕このプロジェクトは当初、コスト削減を目的として計画された、と述べる。',
   NULL::text,
   '["The project set out to reduce costs from the beginning.","The project was set at the beginning with the purpose of reducing costs.","The project set off to reduce costs from the beginning.","The project was basically meant to cut costs from the get-go."]',
   0, '[0]', 'single',
   '{"asked":"当初の目的を set out to で述べられるか。","point":"set out to do＝〜することを目指して着手する。プロジェクトや取り組みの当初の意図を述べる定番。","kid":"set out to＝〜しようと乗り出す。旅に出るように目的に向かって進み始めるイメージ。","eg":"The researchers set out to test a simple hypothesis.","terms":[["set out to + 動詞原形","目的を表す不定詞が続く"],["set off（誤用）","「出発する」「（警報などを）作動させる」の意味で目的の宣言には使わない"]],"think":"当初の目的を述べる文→動詞は set→粒子は out→不定詞 to reduce。","vs":"直訳肢の was set at the beginning with the purpose of は受動＋名詞句の冗長な直訳構造。set off は「出発する」「引き金になる」という別の意味で、目的の宣言には意味が合わない重要な誤用トラップ。get-go は口語表現でフォーマルな文脈に不適。","why_asked":"IELTS Writing のプロジェクト・研究目的の説明、CAE のレポート導入文で頻出。","usecase":"プロジェクトや研究の当初の目的を述べる導入文の定型。","opt":["正解。set out to が目的の宣言の標準形。","冗長な受動の直訳調。","set off は別の意味で誤用。","口語すぎてフォーマル文に不適。"]}'),

  ('pv-t1a-q12', '実行・遂行系',
   '〔中立〕約束した改善策を最後までやり遂げることが重要だ、と強調する。',
   NULL::text,
   '["It is important to follow through on the promised improvements.","It is important to follow to the end the promised improvements.","It is important to follow up on the promised improvements.","Gotta actually follow through on what we promised, yeah?"]',
   0, '[0]', 'single',
   '{"asked":"「最後までやり遂げる」を follow through で表現できるか。","point":"follow through on＝約束・計画を最後までやり遂げる。開始しただけでなく完了させる点が核心。","kid":"follow through on＝〜を最後までやり通す。始めたことを途中で投げ出さないイメージ。","eg":"Managers who follow through on feedback earn more trust from their teams.","terms":[["follow through on + 名詞","約束・計画・戦略などと相性が良い"],["follow up on","「経過を確認する・追跡する」で完遂とはニュアンスが異なる"]],"think":"重要性を強調する文→やり遂げる→動詞は follow→粒子は through→前置詞 on。","vs":"直訳肢の follow to the end は語順・構造ともに不自然な直訳。follow up on は「後で確認・フォローする」という意味合いが強く、「最後までやり遂げる」という完遂のニュアンスが follow through ほど強くない重要な近義語トラップ。最後の肢は Gotta/yeah など口語表現で強調文の格に合わない。","why_asked":"CAE Speaking Part 3・4 のビジネストピック、IELTS Writing の提言パラグラフで頻出。","usecase":"約束や計画の完遂を強調するビジネス・提言文の定番。","opt":["正解。follow through on が完遂を示す標準形。","直訳調で語順が不自然。","follow up on は確認寄りでニュアンスが弱い。","口語すぎて強調文に不適。"]}'),

  ('pv-t1a-q13', '実行・遂行系',
   '〔フォーマル〕研修で学んだ理論を、実際の現場で実践することが求められる。',
   NULL::text,
   '["Employees are expected to put the theory learned in training into practice.","Employees are expected to make the learned theory into the practice.","Employees are expected to put the theory learned in training in practice.","Staff should basically try out what they learned in training, right."]',
   0, '[0]', 'single',
   '{"asked":"「実践する」を put ... into practice で正しい前置詞とともに使えるか。","point":"put ... into practice＝〜を実践に移す。into が必須で in に置き換えられない。","kid":"put ... into practice＝理論を実際の行動に「入れる」イメージ。","eg":"It took months before the new safety rules were put into practice.","terms":[["put + 名詞 + into practice","目的語が長い場合は into practice を後ろに置く語順に注意"],["in practice（別表現）","「実際には」という副詞句で動詞句としては使わない"]],"think":"研修レポート→理論を実践に移す→動詞は put→前置詞は into。","vs":"直訳肢の make ... into the practice は動詞選択・冠詞ともに不自然な直訳。in practice は into practice と紛らわしいが「実際には」という別の意味の副詞句であり、この文脈の動詞句としては誤り。最後の肢は try out や basically/right など口語表現でフォーマルな要求文に合わない。","why_asked":"CAE Use of English の前置詞問題、ビジネス・教育系読解で頻出のコロケーション。","usecase":"研修・理論の現場適用を求めるフォーマルな指示・レポート文。","opt":["正解。put … into practice が標準の実践表現。","動詞・冠詞ともに不自然な直訳。","in practice は別の意味の副詞句で誤用。","口語すぎてフォーマルな要求文に不適。"]}'),

  ('pv-t1a-q14', '実行・遂行系',
   '〔フォーマル〕経営陣は、この改革を最後まで貫徹すると約束した。',
   NULL::text,
   '["Management promised to carry the reform through to the end.","Management promised to carry the reform to the completion.","Management promised to carry the reform out to the end.","The bosses promised to see the reform through, no matter what, yeah."]',
   0, '[0]', 'single',
   '{"asked":"「貫徹する」を carry through で述べられるか。","point":"carry ... through＝（困難があっても）最後までやり遂げる。carry out より完遂・忍耐のニュアンスが強い。","kid":"carry ... through＝最後までやり通す。carry out より「途中で投げ出さない」意味が強い語。","eg":"Despite the setbacks, the team carried the plan through.","terms":[["carry + 目的語 + through","分離動詞。目的語が名詞のときは間に挟むのが自然"],["carry out","「実施する」で開始・遂行の事実を指し、貫徹の強い意味合いは carry through ほど強くない"]],"think":"貫徹の約束文→やり遂げる→動詞は carry→粒子は through。","vs":"直訳肢の carry ... to the completion は completion を名詞のまま直訳的に置いた不自然な構造。carry ... out は「実施する」の意味で、開始・遂行は表せても「最後まで貫徹する」という強い完遂のニュアンスが carry through ほど出ない近義語トラップ。最後の肢は bosses/no matter what, yeah など口語表現で経営陣の公式発言としては不自然。","why_asked":"CAE Reading & Use of English のビジネス記事、IELTS Writing の決意表明パラグラフで頻出。","usecase":"改革・計画の完遂を約束する経営層の公式発言の定型。","opt":["正解。carry … through が貫徹の標準表現。","直訳調で不自然な名詞化。","carry out は貫徹の強い意味合いが弱い。","口語すぎて経営陣の発言として不自然。"]}'),

  ('pv-t1a-q15', '実行・遂行系',
   '〔フォーマル〕同社は来年、大規模なデジタル改革に着手する予定だ。',
   NULL::text,
   '["The company plans to embark on a major digital transformation next year.","The company plans to get on board a major digital transformation next year.","The company plans to embark in a major digital transformation next year.","The company is basically gonna dive into some big digital overhaul next year."]',
   0, '[0]', 'single',
   '{"asked":"「（大きな取り組みに）着手する」を embark on で述べられるか。","point":"embark on＝（大きく重要な取り組みに）乗り出す。船出のイメージで大規模な事業の開始を示す格式高い語。","kid":"embark on＝〜に着手する。船に「乗り込む」イメージから、大きな挑戦を始める意味に発展した語。","eg":"The university is set to embark on an ambitious research programme.","terms":[["embark on + 名詞","大規模な計画・改革・旅などの名詞と相性が良い"],["embark on vs embark in","前置詞は on 固定、in は誤り"]],"think":"発表文→大規模な取り組みに着手→動詞は embark→前置詞は on。","vs":"直訳肢の get on board は「（比喩的に）乗る・賛同する」という別の意味で、着手そのものを表す語ではない不自然な言い換え。embark in は前置詞の誤用。最後の肢は gonna/dive into/overhaul などカジュアルな語彙でフォーマルな企業発表に合わない。","why_asked":"CAE Reading の企業・組織記事、IELTS Writing の将来計画パラグラフで頻出。","usecase":"企業や組織の大規模な新規事業着手を発表する定型表現。","opt":["正解。embark on が大規模な着手を示す標準形。","比喩がずれた不自然な言い換え。","前置詞の誤用。","口語すぎて企業発表に不適。"]}'),

  ('pv-t1a-q16', '実行・遂行系',
   '〔中立〕彼女はプレゼンを見事にやってのけた、と評価する。',
   NULL::text,
   '["She carried off the presentation brilliantly.","She carried the presentation off in a brilliant way.","She carried out the presentation brilliantly.","She totally nailed the presentation, no cap."]',
   0, '[0]', 'single',
   '{"asked":"「見事にやってのけた」という達成の評価を carry off で述べられるか。","point":"carry off＝（難しいことを）見事にやってのける。成功の評価・称賛のニュアンスを含む点が carry out と違う。","kid":"carry off＝うまくやり遂げる。難しいことを軽々とこなした、という称賛のニュアンスが乗る語。","eg":"He carried off the negotiation without a single hitch.","terms":[["carry off + 名詞","難易度の高いタスクの名詞と相性が良い"],["carry out","単に「実施した」という事実のみで、成功の評価は含まない"]],"think":"評価の文→見事にやり遂げた→動詞は carry→粒子は off。","vs":"直訳肢の carried … off in a brilliant way は副詞句を後ろに回した不自然な語順の直訳。carry out は「実施した」という中立的な事実のみを表し、carry off が持つ「見事に」という称賛のニュアンスが消えてしまう近義語トラップ。最後の肢は totally/no cap などZ世代スラングで中立的な評価文には砕けすぎ。","why_asked":"CAE Speaking の人物評価トピック、IELTS Speaking Part 2 の描写問題で頻出。","usecase":"人の成果や実演を称賛して評価するときの自然な言い方。","opt":["正解。carry off が「見事にやってのけた」の標準形。","語順が不自然な直訳調。","carry out は称賛のニュアンスが消える。","スラングで中立的な評価文に不適。"]}'),

  ('pv-t1a-q17', '実行・遂行系',
   '〔口語〕あんな難しい交渉をよくやり遂げたな、と同僚に言う。',
   NULL::text,
   '["I can''t believe you pulled off such a difficult negotiation.","I can''t believe you succeeded to pull such a difficult negotiation.","I can''t believe you pulled out such a difficult negotiation.","One is astonished that you managed to accomplish such an arduous negotiation."]',
   0, '[0]', 'single',
   '{"asked":"口語で「よくやり遂げたな」という驚き＋称賛を pull off で言えるか。","point":"pull off＝（困難なことを）驚くほど見事にやってのける。口語で驚嘆を込めて使う定番表現。","kid":"pull off＝うまくやってのける。想定より難しいことを成功させたときの驚きを含む語。","eg":"They actually pulled off the deal at the last minute.","terms":[["pull off + 名詞","難しい・意外性のあるタスクの名詞と相性が良い"],["pull out（誤用）","「（合意や約束から）撤退する」で正反対の意味"]],"think":"同僚への口語コメント→驚き＋称賛→動詞は pull→粒子は off。","vs":"直訳肢の succeeded to pull は文法的にも succeed to ではなく succeed in が正しく、直訳が生んだ誤文。pull out は「撤退する」という正反対の意味になる重要な誤用トラップ。最後の肢は one is astonished / arduous など極端にフォーマルな語彙で、口語の同僚コメントとしては場違いに硬い。","why_asked":"CAE Speaking Part 2・4 の口語表現力、IELTS Speaking の日常会話語彙で評価される。","usecase":"同僚や友人の成果に驚きと称賛を込めてカジュアルに伝える一言。","opt":["正解。pull off が口語の「やってのけた」の標準形。","文法的に誤った直訳。","pull out は「撤退する」で正反対の意味。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t1a-q18', '除外・特定系',
   '〔フォーマル〕現時点では、機械的な故障の可能性を排除できない、と技術者が述べる。',
   NULL::text,
   '["At this stage, the engineer cannot rule out mechanical failure.","At this stage, the engineer cannot exclude out the possibility of mechanical failure.","At this stage, the engineer cannot rule off mechanical failure.","At this point the engineer basically cannot say it is not a mechanical thing, you know."]',
   0, '[0]', 'single',
   '{"asked":"可能性の排除を rule out で客観的に述べられるか。","point":"rule out＝（可能性を）排除する・除外する。原因究明の途中経過を述べる定番動詞。","kid":"rule out＝〜の可能性を消す。線を引いて除外するイメージの語。","eg":"Doctors have ruled out a serious infection.","terms":[["rule out + 名詞","可能性・原因などの名詞と相性が良い"],["rule off（誤用）","存在しない組み合わせ"]],"think":"技術者コメント→可能性の否定→動詞は rule→粒子は out。","vs":"直訳肢の exclude out は exclude と rule out の動詞を混ぜた誤用で out を重複させた不自然な形。rule off は存在しない誤用パターン。最後の肢は basically/you know など口語のヘッジ表現で技術者の公式コメントとしては不自然に曖昧。","why_asked":"CAE Reading の事故調査・技術系記事、IELTS Listening のニュース素材で頻出。","usecase":"原因究明の途中段階で可能性を否定する専門家コメントの定型。","opt":["正解。rule out が可能性排除の標準形。","動詞を混ぜた誤用の直訳調。","rule off は存在しない誤用。","口語すぎて技術者コメントに不適。"]}'),

  ('pv-t1a-q19', '除外・特定系',
   '〔中立〕上司は彼のプレゼンだけを名指しで褒めた。',
   NULL::text,
   '["The manager singled out his presentation for praise.","The manager picked only his presentation and praised it specially.","The manager singled off his presentation for praise.","The boss basically called out his slides specifically, which was nice."]',
   0, '[0]', 'single',
   '{"asked":"「名指しで取り上げる」を single out で述べられるか。","point":"single out＝（多数の中から）一つだけを名指しで取り上げる。称賛にも批判にも使える中立的な語。","kid":"single out＝一人・一つだけを選び出す。他と分けて特別扱いするイメージ。","eg":"The teacher singled out two students for their outstanding essays.","terms":[["single out ... for + 名詞","for の後に praise / criticism など理由を置く"],["single off（誤用）","存在しない組み合わせ"]],"think":"評価の文→一つだけ取り上げる→動詞は single→粒子は out。","vs":"直訳肢の picked only ... and praised it specially は「選んで特別に褒めた」を二文的に直訳した冗長な構造。single off は存在しない誤用。call out は「（問題点を）指摘する」という批判寄りの意味合いが強く、称賛の文脈では誤解を招く近義語トラップ。","why_asked":"CAE Reading の人物評価記事、IELTS Speaking Part 2 の職場エピソードで頻出。","usecase":"職場や学校で誰かが特別に取り上げられた場面を描写する表現。","opt":["正解。single out が名指しの標準表現。","冗長な二文的直訳。","single off は存在しない誤用。","call out は批判寄りのニュアンスで場面に合わない。"]}'),

  ('pv-t1a-q20', '除外・特定系',
   '〔フォーマル〕最新データが需要の緩やかな回復を示している、と分析官が言う言い方として自然なものを2つ。',
   NULL::text,
   '["The latest data points to a gradual recovery in demand.","The latest data points toward a gradual recovery in demand.","The latest data points at a gradual recovery in demand.","The latest data is pointing at the direction of a gradual recovery in demand."]',
   0, '[0,1]', 'multi',
   '{"asked":"point to / point toward をデータの示唆を表す表現として使い分けられるか。","point":"point to／point toward＝データや兆候が〜を示唆する。to と toward はほぼ同義で置き換え可能。","kid":"point to＝〜を指し示す。データが方向を指差しているイメージ。","eg":"Several indicators point to / point toward a slowdown next quarter.","terms":[["point to/toward + 名詞","示唆・兆候の対象を続ける"],["point at","物理的に指をさす意味合いが強く、データの比喩的な示唆にはやや不向き"]],"think":"分析官のコメント→データが示唆する→動詞は point→前置詞は to か toward。","vs":"point at は「（物理的に）指をさす」ニュアンスが強く出るため、データの比喩的な示唆としてはやや不自然な近義語トラップ。最後の肢は the direction of を加えた冗長な直訳調でフォーマルな分析文としては回りくどい。","why_asked":"IELTS Writing Task 1 のデータ描写、CAE の経済記事読解で頻出の類義語ペア。","usecase":"データ分析コメントで同じ示唆を言い換える際の定番2択。","opt":["正解。point to がデータの示唆を示す標準形。","正解。point toward も同義で置き換え可能。","point at は物理的な指差しのニュアンスが強く不自然。","冗長な直訳調で回りくどい。"]}'),

  ('pv-t1a-q21', '除外・特定系',
   '〔中立〕候補者リストを最終的に3名まで絞り込んだ、と人事担当者が報告する。',
   NULL::text,
   '["HR narrowed down the candidate list to three finalists.","HR made the candidate list narrow until three finalists remained.","HR narrowed off the candidate list to three finalists.","HR basically whittled the list down to three, more or less."]',
   0, '[0]', 'single',
   '{"asked":"「絞り込む」を narrow down で正しい前置詞とともに使えるか。","point":"narrow down＝選択肢を絞り込む。to の後に最終的な数・候補を置く形が定番。","kid":"narrow down＝範囲を狭めて絞る。多数の候補を少数に減らすイメージ。","eg":"We need to narrow down the options before the next meeting.","terms":[["narrow down + 名詞 + to + 数","絞り込んだ結果の数・候補を to の後に置く"],["narrow off（誤用）","存在しない組み合わせ"]],"think":"人事報告→選択肢を絞る→動詞は narrow→粒子は down→前置詞 to。","vs":"直訳肢の made ... narrow until ... remained は形容詞 narrow を動詞的に使う回りくどい直訳構造。narrow off は存在しない誤用。whittle down は「（時間をかけて少しずつ）削る」という近い意味の口語表現だが、people寄りのカジュアルな語彙で人事報告の格には合わない。","why_asked":"IELTS Writing のプロセス説明、CAE のビジネスレポート読解で頻出。","usecase":"採用・選考プロセスで候補を絞り込んだことを報告する定型。","opt":["正解。narrow down to が絞り込みの標準形。","回りくどい直訳調。","narrow off は存在しない誤用。","口語表現で人事報告の格に合わない。"]}'),

  ('pv-t1a-q22', '除外・特定系',
   '〔フォーマル〕この見積もりには、為替変動のリスクも織り込まれている、と財務部は説明する。',
   NULL::text,
   '["The estimate factors in the risk of currency fluctuation.","The estimate is made by factoring the risk of currency fluctuation inside.","The estimate factors on the risk of currency fluctuation.","The estimate has basically got currency risk baked in, I think."]',
   0, '[0]', 'single',
   '{"asked":"「（要因を）織り込む」を factor in で述べられるか。","point":"factor in＝（計算・見積もりに）要因を織り込む。財務・分析文書の定番動詞。","kid":"factor in＝計算に入れる。見積もりの中にリスクや要因を組み込むイメージ。","eg":"The forecast factors in seasonal demand changes.","terms":[["factor in + 名詞","要因・リスクなどの名詞と相性が良い"],["factor on（誤用）","前置詞は in 固定、on は誤り"]],"think":"財務部の説明文→要因を織り込む→動詞は factor→粒子は in。","vs":"直訳肢の is made by factoring ... inside は受動＋副詞 inside を使う回りくどい直訳構造。factors on は前置詞の誤用。最後の肢は baked in や basically/I think など口語表現で財務部の公式説明としては砕けすぎる。","why_asked":"CAE Reading の財務・経済記事、IELTS Writing Task 1 の予測データ説明で頻出。","usecase":"見積もりや予測にリスク要因を織り込んだことを説明する定型。","opt":["正解。factor in がリスク織り込みの標準形。","回りくどい受動の直訳調。","前置詞の誤用。","口語すぎて財務部の説明に不適。"]}'),

  ('pv-t1a-q23', '除外・特定系',
   '〔中立〕最初のドラフトでは、重要な統計データが一つ抜け落ちていた。',
   NULL::text,
   '["One key statistic was left out of the first draft.","One key statistic was made to be outside of the first draft.","One key statistic was left off the first draft.","They basically forgot to chuck in one key stat in the first draft."]',
   0, '[0]', 'single',
   '{"asked":"「抜け落ちていた」を leave out の受動形で述べられるか。","point":"leave out＝（意図的・偶発的に）抜かす・省く。受動形 be left out of で「〜から抜け落ちている」を表す定番。","kid":"leave out＝入れ忘れる・省く。全体の中から一つだけ外れているイメージ。","eg":"A crucial detail was left out of the summary.","terms":[["be left out of + 名詞","抜け落ちた対象を of の後に置く"],["leave off","「（リストなどから）省く」で似た意味だが標準は leave out"]],"think":"欠落の指摘文→抜け落ちている→動詞は leave→粒子は out→前置詞 of。","vs":"直訳肢の was made to be outside of は「外側にされた」という不自然な直訳構造。leave off は leave out と似た意味で使われることもあるが標準はleave out で、この文脈では違和感のある近義語トラップ。最後の肢は chuck in や basically など口語表現で客観的な指摘文に不適。","why_asked":"CAE Use of English の受動態問題、IELTS Writing のプロセス・欠陥指摘パラグラフで頻出。","usecase":"文書や報告書の欠落箇所を客観的に指摘する定型表現。","opt":["正解。be left out of が欠落を示す標準形。","不自然な直訳構造。","leave off は近義語だが標準からずれる。","口語すぎて客観的な指摘文に不適。"]}'),

  ('pv-t1a-q24', '除外・特定系',
   '〔フォーマル〕新しい審査プロセスは、質の低い応募を早い段階で除外することを目指す。',
   NULL::text,
   '["The new screening process aims to weed out low-quality applications early on.","The new screening process aims to remove like weeds the low-quality applications early on.","The new screening process aims to weed off low-quality applications early on.","The new screening is basically meant to kick out the rubbish applications early, yeah."]',
   0, '[0]', 'single',
   '{"asked":"「（質の低いものを）除外する」を weed out で述べられるか。","point":"weed out＝（雑草を抜くように）質の低いもの・不要なものを除外する。選考・審査文脈の定番比喩表現。","kid":"weed out＝雑草を抜くように不要なものを取り除く。選考で悪いものを間引くイメージ。","eg":"The first interview round is designed to weed out unqualified candidates.","terms":[["weed out + 名詞","低品質・不適格な対象の名詞と相性が良い"],["weed off（誤用）","存在しない組み合わせ"]],"think":"審査プロセスの説明文→質の低いものを除外→動詞は weed→粒子は out。","vs":"直訳肢の remove like weeds は比喩を直訳的に説明してしまい不自然。weed off は存在しない誤用。最後の肢は kick out や rubbish/yeah など口語・スラング表現でフォーマルな審査プロセスの説明に不適。","why_asked":"CAE Reading の採用・審査プロセス記事、IELTS Writing の選考制度説明で頻出。","usecase":"審査・選考プロセスが低品質なものを除外する目的を説明する定型。","opt":["正解。weed out が除外の標準比喩表現。","比喩を説明しすぎた不自然な直訳。","weed off は存在しない誤用。","スラングでフォーマルな説明に不適。"]}'),

  ('pv-t1a-q25', '除外・特定系',
   '〔中立〕チームは、問題の根本原因を特定することに焦点を絞った。',
   NULL::text,
   '["The team zeroed in on the root cause of the problem.","The team made zero and focused on the root cause of the problem.","The team zeroed out on the root cause of the problem.","The team basically homed in on what was actually causing it, I guess."]',
   0, '[0]', 'single',
   '{"asked":"「焦点を絞る」を zero in on で述べられるか。","point":"zero in on＝（照準を合わせるように）一点に焦点を絞る。原因究明・分析の場面で使う定番表現。","kid":"zero in on＝的を絞って狙う。銃の照準を合わせるイメージから「集中して特定する」の意味に。","eg":"Investigators zeroed in on a single faulty component.","terms":[["zero in on + 名詞","原因・問題点などの名詞と相性が良い"],["zero out（誤用）","「ゼロにする・相殺する」で全く別の意味"]],"think":"分析の文→焦点を絞る→動詞は zero→粒子は in→前置詞 on。","vs":"直訳肢の made zero and focused on は zero を動詞的に誤用した不自然な直訳。zero out は「ゼロにする・相殺する」という全く別の意味になる重要な誤用トラップ。最後の肢は homed in on という近い意味の表現を含むが、basically/I guess などの口語ヘッジが客観的な分析文に合わない。","why_asked":"CAE Reading の問題解決・分析記事、IELTS Writing のプロセス説明パラグラフで頻出。","usecase":"チームや調査が原因究明に焦点を絞ったことを述べる定型表現。","opt":["正解。zero in on が焦点を絞る標準形。","zero を誤って動詞的に使った直訳。","zero out は全く別の意味で誤用。","口語のヘッジ表現で分析文に不適。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'pv-t1-a'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
