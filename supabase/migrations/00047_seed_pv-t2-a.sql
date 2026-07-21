-- 英語・句動詞（Set T2-A）: 議論動詞20問（主張・提起系10／賛否・譲歩系10）
-- question-authoring-pv スキル準拠。docs/pv-seed-strategy.md により継続投入（pv-t1-a/b に続く）。
BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order, is_active)
VALUES ('pv-t2-a',
        '英語・句動詞（Set T2-A）',
        '【Speak-First】日本語の場面を見たら、選択肢を見る前に3秒以内で英文を声に出す。言ってから表示。口で言えなかったら解答後にチップを押す。',
        '#6ab08d', 84, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
JOIN (VALUES
  ('主張・提起系', '#38bdf8', 1),
  ('賛否・譲歩系', '#fb923c', 2)
) AS v(name, color, sort_order) ON true
WHERE s.slug = 'pv-t2-a'
ON CONFLICT (subject_id, name) DO NOTHING;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('pv-t2a-q01', '主張・提起系',
   '〔フォーマル〕会議で、新しいマーケティング案を提案する。',
   NULL::text,
   '["She put forward a new marketing proposal at the meeting.","She put the new marketing proposal forward in front at the meeting.","She put out a new marketing proposal at the meeting.","She basically threw out a new marketing idea at the meeting, you know."]',
   0, '[0]', 'single',
   '{"asked":"議論の場で提案することを put forward で述べられるか。","point":"put forward＝（案・意見を）提案する。会議やディスカッションで最も中立的な提案動詞。","kid":"put forward＝前に出す。案をテーブルの前面に押し出すイメージ。","eg":"The committee put forward three possible solutions.","terms":[["put forward + 名詞","proposal/idea/argument などの名詞と相性が良い"],["put out（誤用）","「公表する・発表する」で提案よりも一方的な発信のニュアンス"]],"think":"会議での提案文→案を出す→動詞は put→粒子は forward。","vs":"直訳肢の put ... forward in front は forward と in front を重複させた冗長な直訳。put out は「公表する」というニュアンスが強く、議論の場での「提案」よりも一方的な発信寄りの近義語トラップ。最後の肢は threw out/you know など口語表現でフォーマルな会議記録に不適。","why_asked":"CAE Speaking Part 3・4 の提案表現、IELTS Writing Task 2 の意見提示パラグラフで頻出。","usecase":"会議やディスカッションで新しい案を提案する定型表現。","opt":["正解。put forward が提案の標準形。","forward の重複で冗長な直訳。","put out はニュアンスが一方的すぎる近義語。","口語すぎて会議記録に不適。"]}'),

  ('pv-t2a-q02', '主張・提起系',
   '〔中立〕誰も触れたがらない話題を持ち出す。',
   NULL::text,
   '["He brought up a topic that no one wanted to discuss.","He brought the topic that no one wanted to discuss up to the surface.","He brought out a topic that no one wanted to discuss.","He basically went there with a topic nobody wanted to touch, lol."]',
   0, '[0]', 'single',
   '{"asked":"話題を切り出すことを bring up で述べられるか。","point":"bring up＝（話題を）持ち出す。会話やディスカッションで新しい話題を切り出す最頻出動詞。","kid":"bring up＝話題を持ち上げてくる。会話のテーブルに新しい話を運んでくるイメージ。","eg":"I hate to bring this up, but we are behind schedule.","terms":[["bring up + 名詞","topic/issue/subject などの名詞と相性が良い"],["bring out（誤用）","「引き出す・際立たせる」で全く別の意味"]],"think":"話題を切り出す文→動詞は bring→粒子は up。","vs":"直訳肢の brought ... up to the surface は比喩（水面に浮かび上がらせる）を説明しすぎた冗長な直訳。bring out は「（才能や特徴を）引き出す・際立たせる」という別の意味になる誤用トラップ。最後の肢は lol/nobody など口語表現で中立的な説明文としては砕けすぎる。","why_asked":"CAE Speaking Part 3 のディスカッション、IELTS Speaking Part 3 の話題転換で頻出。","usecase":"会話や会議で話しにくい話題を切り出す自然な言い方。","opt":["正解。bring up が話題提起の標準形。","比喩を説明しすぎた冗長な直訳。","bring out は全く別の意味。","口語すぎて中立的な説明に不適。"]}'),

  ('pv-t2a-q03', '主張・提起系',
   '〔中立〕データに矛盾があると指摘する。',
   NULL::text,
   '["She pointed out an inconsistency in the data.","She pointed her finger out at an inconsistency in the data.","She pointed at an inconsistency in the data.","She basically called it out, which was kind of awkward."]',
   0, '[0]', 'single',
   '{"asked":"客観的な指摘を point out で述べられるか。","point":"point out＝（事実や問題を）指摘する。議論やレビューで最も中立的な指摘動詞。","kid":"point out＝指し示して伝える。指をさすように、相手の注意を特定の点に向けるイメージ。","eg":"The reviewer pointed out a flaw in the methodology.","terms":[["point out + 名詞/that節","inconsistency/mistake/that ... の形と相性が良い"],["point at（誤用寄り）","物理的に指をさすニュアンスが強く、抽象的な指摘にはやや不向き"]],"think":"指摘の文→客観的に指摘する→動詞は point→粒子は out。","vs":"直訳肢の pointed her finger out at は「指を指す」動作を過剰に直訳した不自然な表現。point at は物理的な指差しのニュアンスが強く、データの矛盾という抽象的な対象への指摘としてはやや不自然な近義語トラップ。最後の肢は call it out/kind of awkward など口語表現で客観的な指摘文には砕けすぎる。","why_asked":"CAE Reading の批評記事、IELTS Writing の批判的分析パラグラフで最頻出の指摘動詞。","usecase":"レビューや議論でデータや論理の問題点を客観的に指摘する定型。","opt":["正解。point out が客観的指摘の標準形。","身体動作を過剰に直訳した不自然な表現。","point at は物理的な指差しのニュアンスが強い。","口語すぎて客観的な指摘に不適。"]}'),

  ('pv-t2a-q04', '主張・提起系',
   '〔フォーマル〕潜在的なリスクを事前に問題提起する。',
   NULL::text,
   '["The auditor flagged up a potential risk in advance.","The auditor put up a flag about a potential risk in advance.","The auditor flagged out a potential risk in advance.","The auditor basically waved a red flag about some risk, you know."]',
   0, '[0]', 'single',
   '{"asked":"事前の問題提起を flag up で述べられるか。","point":"flag up＝（問題やリスクを）事前に警告・問題提起する。監査・レビューの報告書で頻出のビジネス動詞。","kid":"flag up＝旗を立てて知らせる。注意すべき点に目印の旗を立てるイメージ。","eg":"The system automatically flags up any unusual transactions.","terms":[["flag up + 名詞","risk/issue/concern などの名詞と相性が良い"],["flag out（誤用）","存在しない組み合わせ"]],"think":"監査報告文→事前に警告する→動詞は flag→粒子は up。","vs":"直訳肢の put up a flag about は flag を「旗」という名詞のまま直訳した回りくどい表現。flag out は存在しない誤用。最後の肢は waved a red flag/you know など口語的な比喩表現でフォーマルな監査報告書に不適。","why_asked":"CAE Reading の監査・コンプライアンス記事、IELTS Writing のリスク報告パラグラフで頻出。","usecase":"監査やレビューで潜在的なリスクを事前に警告する定型表現。","opt":["正解。flag up が事前の問題提起を示す標準形。","flagを名詞のまま直訳した回りくどい表現。","flag out は存在しない誤用。","口語的な比喩でフォーマルな報告書に不適。"]}'),

  ('pv-t2a-q05', '主張・提起系',
   '〔中立〕プレゼンで予算の話に軽く触れる。',
   NULL::text,
   '["The presentation touched on the issue of budget.","The presentation touched the issue of budget with its hand lightly.","The presentation touched at the issue of budget.","The presentation kind of mentioned budget stuff, I think."]',
   0, '[0]', 'single',
   '{"asked":"軽く言及することを touch on で述べられるか。","point":"touch on＝（話題に）軽く触れる。深く掘り下げずに簡単に言及するニュアンスの定番表現。","kid":"touch on＝軽く手で触れる。深追いせず、表面だけそっと触れるイメージ。","eg":"The lecture briefly touched on the history of the field.","terms":[["touch on + 名詞","話題・論点の名詞と相性が良い"],["touch at（誤用）","前置詞は on 固定、at は誤り"]],"think":"軽い言及の文→動詞は touch→前置詞は on。","vs":"直訳肢の touched ... with its hand lightly は「手で触れる」という身体動作を過剰に直訳した不自然な表現。touch at は前置詞の誤用。最後の肢は kind of/stuff/I think など曖昧な口語表現で、内容自体は近いが客観的な説明文としては弱い。","why_asked":"CAE Reading のレビュー記事、IELTS Speaking Part 3 の話題範囲の説明で頻出。","usecase":"プレゼンや講義が特定の話題に軽く言及したことを説明する定型。","opt":["正解。touch on が軽い言及を示す標準形。","身体動作を過剰に直訳した表現。","前置詞の誤用。","曖昧な口語表現で説明文としては弱い。"]}'),

  ('pv-t2a-q06', '主張・提起系',
   '〔フォーマル〕監査が不正会計を明るみに出した。',
   NULL::text,
   '["The audit brought the accounting fraud to light.","The audit brought the accounting fraud into the sunlight.","The audit brought the accounting fraud in light.","The audit basically dug up some shady accounting stuff, yeah."]',
   0, '[0]', 'single',
   '{"asked":"隠れていた事実の発覚を bring to light で述べられるか。","point":"bring ... to light＝〜を明るみに出す。隠されていた不正や事実が発覚することを示す定番のフォーマル表現。","kid":"bring ... to light＝光の下に持ってくる。暗闇に隠れていたものを明るい場所に出すイメージ。","eg":"The investigation brought several safety violations to light.","terms":[["bring ... to light","light は不可算名詞で冠詞なし固定"],["bring ... in light（誤用）","前置詞・形の誤り。to light が正しい定型"]],"think":"発覚の報告文→隠れた事実を明るみに出す→動詞は bring→句は to light。","vs":"直訳肢の into the sunlight は light を「太陽光」という具体的な光と直訳した過剰な表現。bring ... in light は定型句の前置詞を誤った形。最後の肢は dug up/shady/yeah など口語表現でフォーマルな監査報告に不適。","why_asked":"CAE Reading の監査・調査報道記事、IELTS Writing の発覚・暴露パラグラフで頻出の定型句。","usecase":"監査や調査が不正・問題を発覚させたことを報告する定型表現。","opt":["正解。bring ... to light が発覚を示す標準形。","lightを太陽光と直訳した過剰な表現。","定型句の前置詞を誤った形。","口語すぎて監査報告に不適。"]}'),

  ('pv-t2a-q07', '主張・提起系',
   '〔フォーマル〕新方針の詳細を明確に説明するよう求める。',
   NULL::text,
   '["Employees asked management to spell out the details of the new policy.","Employees asked management to write out letter by letter the details of the new policy.","Employees asked management to spell up the details of the new policy.","Employees basically wanted management to break it down for them, kinda."]',
   0, '[0]', 'single',
   '{"asked":"詳細な説明を求めることを spell out で述べられるか。","point":"spell out＝（誤解の余地なく）詳細に説明する。曖昧さを許さない明確な説明を求めるときの定番表現。","kid":"spell out＝一字一字つづるように説明する。誰にでもわかるよう丁寧に説明するイメージ。","eg":"The manual spells out exactly what to do in an emergency.","terms":[["spell out + 名詞","details/requirements などの名詞と相性が良い"],["spell up（誤用）","存在しない組み合わせ"]],"think":"要求の文→明確に説明を求める→動詞は spell→粒子は out。","vs":"直訳肢の write out letter by letter は spell を文字通り「つづる」と直訳しすぎた不自然な表現。spell up は存在しない誤用。最後の肢は break it down/kinda など口語表現でフォーマルな要求文に不適。","why_asked":"CAE Reading のビジネス・規則説明記事、IELTS Writing の明確化要求パラグラフで頻出。","usecase":"方針や規則の詳細な説明を求めるフォーマルな要求表現。","opt":["正解。spell out が詳細な説明の標準形。","spellを文字通り直訳しすぎた表現。","spell up は存在しない誤用。","口語すぎてフォーマルな要求に不適。"]}'),

  ('pv-t2a-q08', '主張・提起系',
   '〔フォーマル〕CEOが今後5年の計画を提示する。',
   NULL::text,
   '["The CEO laid out the plan for the next five years.","The CEO put the plan for the next five years down flat on the table.","The CEO laid off the plan for the next five years.","The CEO basically threw out a five-year plan, I guess."]',
   0, '[0]', 'single',
   '{"asked":"計画の提示を lay out で述べられるか。","point":"lay out＝（計画・情報を）整理して提示する。プレゼンテーションで全体像を示すときの定番表現。","kid":"lay out＝広げて並べる。地図を机の上に広げて全体を見せるイメージ。","eg":"The report lays out three possible strategies for growth.","terms":[["lay out + 名詞","plan/strategy/options などの名詞と相性が良い"],["lay off（誤用）","「解雇する」で全く別の意味"]],"think":"プレゼン文→計画を提示する→動詞は lay→粒子は out。","vs":"直訳肢の put ... down flat on the table は「机に平らに置く」という物理的動作を過剰に直訳した表現。lay off は「解雇する」という全く別の意味になる重要な誤用トラップ。最後の肢は threw out/I guess など口語表現でCEOの公式発表としては不適切。","why_asked":"CAE Reading のビジネス戦略記事、IELTS Writing の計画提示パラグラフで頻出。","usecase":"経営層が計画や戦略の全体像を提示する定型表現。","opt":["正解。lay out が計画提示の標準形。","物理的動作を過剰に直訳した表現。","lay off は「解雇する」で全く別の意味。","口語すぎてCEOの発表に不適。"]}'),

  ('pv-t2a-q09', '主張・提起系',
   '〔フォーマル〕契約書が両者の義務を明記する。',
   NULL::text,
   '["The contract sets forth the obligations of both parties.","The contract sends the obligations of both parties forward in writing.","The contract sets out forth the obligations of both parties.","The contract basically spells out what both sides gotta do, right."]',
   0, '[0]', 'single',
   '{"asked":"契約書などの法的文書で明記することを set forth で述べられるか。","point":"set forth＝（正式に）明記する・提示する。法律・契約文書で使われる格式高い表現。","kid":"set forth＝前へ据えて示す。文書の中に条項をきちんと据え置くイメージ。","eg":"The agreement sets forth the terms of payment in detail.","terms":[["set forth + 名詞","obligations/terms/conditions など法的な名詞と相性が良い"],["set out forth（誤用）","set out と set forth を混ぜた重複表現"]],"think":"契約文書→義務を明記する→動詞は set→粒子は forth。","vs":"直訳肢の sends ... forward in writing は set を send と混同した誤った直訳。set out forth は set out と set forth を無理に組み合わせた冗長な誤用。最後の肢は spells out/gotta/right など口語表現で法的文書の格式に合わない。","why_asked":"CAE Reading の契約・法律文書、IELTS Writing のフォーマルな規定説明で頻出。","usecase":"契約書や規約が義務・条件を正式に明記していることを述べる定型。","opt":["正解。sets forth が正式な明記を示す標準形。","動詞を混同した誤った直訳。","set out と set forth を混ぜた誤用。","口語すぎて法的文書の格式に合わない。"]}'),

  ('pv-t2a-q10', '主張・提起系',
   '〔中立〕講師が安全の重要性を繰り返し強調する。',
   NULL::text,
   '["The instructor drove home the importance of safety.","The instructor drove the importance of safety all the way to its home.","The instructor drove in the importance of safety.","The instructor basically hammered on about safety again, ugh."]',
   0, '[0]', 'single',
   '{"asked":"強く印象づけて伝えることを drive home で述べられるか。","point":"drive ... home＝〜を強く印象づける。運転して確実に目的地に届けるように、要点を確実に相手に届けるイメージ。","kid":"drive ... home＝家まで運転して届ける。要点を相手の頭にしっかり届けるイメージ。","eg":"The statistics really drove home the scale of the problem.","terms":[["drive ... home","home は副詞的に使われ、目的語の後に置く"],["drive in（誤用）","「運転して入る」という文字通りの意味で比喩には使わない"]],"think":"強調の文→要点を印象づける→動詞は drive→副詞 home。","vs":"直訳肢の all the way to its home は home を文字通り「家」と直訳した過剰な表現。drive in は「運転して入る」という文字通りの意味になり、比喩的な強調のニュアンスが消える誤用トラップ。最後の肢は hammered on/ugh など口語表現で中立的な説明文としてはやや強すぎる。","why_asked":"CAE Speaking Part 4 の説得・強調表現、IELTS Writing の強調パラグラフで頻出。","usecase":"講義やプレゼンで重要な点を繰り返し強く印象づけたことを述べる表現。","opt":["正解。drive home が強い印象づけを示す標準形。","homeを文字通り直訳した過剰な表現。","drive in は文字通りの意味で比喩が消える。","口語表現でやや強すぎる。"]}'),

  ('pv-t2a-q11', '賛否・譲歩系',
   '〔中立〕気は進まないがチームの決定に同調する。',
   NULL::text,
   '["She reluctantly went along with the team''s decision.","She reluctantly walked along together with the team''s decision.","She reluctantly went along on the team''s decision.","She basically just rolled with whatever the team decided, meh."]',
   0, '[0]', 'single',
   '{"asked":"消極的な同調を go along with で述べられるか。","point":"go along with＝（積極的ではないが）同調する・従う。reluctantly のような副詞と組み合わせて消極性を示せる。","kid":"go along with＝一緒についていく。気は進まなくても流れに合わせて進むイメージ。","eg":"He went along with the plan even though he had doubts.","terms":[["go along with + 名詞","decision/plan などの名詞と相性が良い"],["go along on（誤用）","前置詞は with 固定、on は誤り"]],"think":"消極的同調の文→動詞は go→粒子は along→前置詞 with。","vs":"直訳肢の walked along together with は「一緒に歩く」という物理的動作を過剰に直訳した表現。go along on は前置詞の誤用。最後の肢は rolled with/meh など口語表現で中立的な説明としてはやや投げやりに響く。","why_asked":"CAE Speaking Part 3 の意見の一致・不一致トピック、IELTS Speaking Part 3 の妥協表現で頻出。","usecase":"気が進まないながらも集団の決定に従うことを説明する自然な言い方。","opt":["正解。go along with が消極的同調を示す標準形。","物理的動作を過剰に直訳した表現。","前置詞の誤用。","口語すぎてやや投げやりに響く。"]}'),

  ('pv-t2a-q12', '賛否・譲歩系',
   '〔フォーマル〕同僚の主張をデータで裏付けて支持する。',
   NULL::text,
   '["She backed up her colleague''s argument with solid data.","She put her back behind her colleague''s argument with solid data.","She backed her colleague''s argument off with solid data.","She basically had her colleague''s back with some solid numbers, yeah."]',
   0, '[0]', 'single',
   '{"asked":"根拠を伴う支持を back up で述べられるか。","point":"back up＝（証拠・データで）裏付けて支持する。単なる賛同ではなく根拠を伴う支持を示す定番表現。","kid":"back up＝後ろから支える。誰かの主張の背後に回って支えるイメージ。","eg":"The report backs up its conclusions with extensive data.","terms":[["back up + 名詞 + with + 根拠","目的語の後に根拠を with で続ける形が定番"],["back off（誤用）","「後退する・引き下がる」で正反対の意味"]],"think":"根拠を伴う支持の文→動詞は back→粒子は up。","vs":"直訳肢の put her back behind は back を身体部位として直訳した不自然な表現。back off は「後退する・引き下がる」という正反対の意味になる重要な誤用トラップ。最後の肢は had her back/yeah など口語的な慣用表現でフォーマルな説明文に不適。","why_asked":"CAE Reading の学術・ビジネス議論記事、IELTS Writing の根拠提示パラグラフで頻出。","usecase":"議論で他者の主張を根拠とともに支持する定型表現。","opt":["正解。back up が根拠を伴う支持を示す標準形。","backを身体部位として直訳した表現。","back off は正反対の意味。","口語すぎてフォーマルな説明に不適。"]}'),

  ('pv-t2a-q13', '賛否・譲歩系',
   '〔フォーマル〕組合が値下げ要求に抵抗し続けている。',
   NULL::text,
   '["The union continues to hold out against demands for a pay cut.","The union continues to keep holding its position against demands for a pay cut without moving.","The union continues to hold out for demands for a pay cut.","The union is basically not budging on the pay cut thing, no way."]',
   0, '[0]', 'single',
   '{"asked":"抵抗を継続する姿勢を hold out against で述べられるか。","point":"hold out against＝（圧力や要求に）抵抗し続ける。長期にわたり譲らない姿勢を示す定番のフォーマル表現。","kid":"hold out against＝持ちこたえて抵抗する。城が包囲されても持ちこたえるようなイメージ。","eg":"The small business held out against pressure to sell for months.","terms":[["hold out against + 名詞","demands/pressure などの名詞と相性が良い"],["hold out for（誤用）","「〜を粘り強く要求する」で意味の方向が逆になる"]],"think":"抵抗を述べる文→動詞は hold→粒子は out→前置詞 against。","vs":"直訳肢の keep holding its position ... without moving は冗長な説明を重ねた不自然な直訳。hold out for は「〜を強く要求する」という意味で、抵抗の対象を求める側に逆転させてしまう重要な誤用トラップ。最後の肢は not budging/no way など口語表現でフォーマルな労使関係の報告に不適。","why_asked":"CAE Reading の労使関係・交渉記事、IELTS Writing の対立構造の説明で頻出。","usecase":"組織や個人が要求に長期間抵抗していることを報告する定型表現。","opt":["正解。hold out against が抵抗の継続を示す標準形。","冗長な説明を重ねた不自然な直訳。","hold out for は意味の方向が逆転する誤用。","口語すぎてフォーマルな報告に不適。"]}'),

  ('pv-t2a-q14', '賛否・譲歩系',
   '〔中立〕会議で上司の意見に味方する。',
   NULL::text,
   '["In the meeting, he sided with his manager''s opinion.","In the meeting, he stood on the side of his manager''s opinion.","In the meeting, he sided on his manager''s opinion.","In the meeting, he basically backed his boss up, no surprise there."]',
   0, '[0]', 'single',
   '{"asked":"意見の対立で一方に味方することを side with で述べられるか。","point":"side with＝（対立するどちらかに）味方する。議論や対立構造の中で立場を明確にするときの定番表現。","kid":"side with＝〜の側につく。対立する二つの陣営のどちらかに加わるイメージ。","eg":"Most of the committee sided with the original proposal.","terms":[["side with + 人/意見","対立する人や意見の名詞と相性が良い"],["side on（誤用）","前置詞は with 固定、on は誤り"]],"think":"対立構造の文→一方に味方する→動詞は side→前置詞 with。","vs":"直訳肢の stood on the side of は side を場所として直訳した回りくどい表現。side on は前置詞の誤用。最後の肢は backed ... up という別のチャンク（back up）と混同させた表現で、意味は近いが side with 特有の「対立の中で立場を選ぶ」ニュアンスが弱まる近義語トラップ。","why_asked":"CAE Speaking Part 3 の意見対立トピック、IELTS Writing の立場表明パラグラフで頻出。","usecase":"会議や議論で対立する意見のどちらかに味方することを述べる自然な言い方。","opt":["正解。side with が味方することを示す標準形。","sideを場所として直訳した表現。","前置詞の誤用。","別チャンクと混同した近義語でニュアンスが弱い。"]}'),

  ('pv-t2a-q15', '賛否・譲歩系',
   '〔フォーマル〕会社が当初の発表内容を支持し続けると述べる。',
   NULL::text,
   '["The company states that it will stand by its original announcement.","The company states that it will stand next to its original announcement.","The company states that it will stand for its original announcement.","The company is basically saying it is sticking with what it first said, yeah."]',
   0, '[0]', 'single',
   '{"asked":"当初の立場を維持し続けることを stand by で述べられるか。","point":"stand by＝（発言・約束を）支持し続ける・変えない。公式声明で立場の一貫性を示す定番表現。","kid":"stand by＝そばに立ち続ける。発表した内容のそばにずっと立って支え続けるイメージ。","eg":"The government continues to stand by its earlier statement on the policy.","terms":[["stand by + 名詞","announcement/statement/decision などの名詞と相性が良い"],["stand for（誤用）","「〜を意味する・象徴する」で全く別の意味"]],"think":"公式声明文→立場を維持する→動詞は stand→前置詞 by。","vs":"直訳肢の stand next to は「物理的にそばに立つ」という文字通りの意味に直訳した不自然な表現。stand for は「〜を意味する・象徴する」という全く別の意味になる重要な誤用トラップ。最後の肢は basically/sticking with/yeah など口語表現で企業の公式声明としては砕けすぎる。","why_asked":"CAE Reading の企業広報・声明記事、IELTS Writing の立場表明パラグラフで頻出。","usecase":"企業や組織が当初の発表内容を変えないと表明する定型表現。","opt":["正解。stand by が立場の維持を示す標準形。","物理的に立つ意味に直訳した表現。","stand for は全く別の意味。","口語すぎて公式声明に不適。"]}'),

  ('pv-t2a-q16', '賛否・譲歩系',
   '〔中立〕圧力に屈して要求を受け入れた。',
   NULL::text,
   '["Eventually, management gave in to the pressure.","Eventually, management entered inside the pressure and gave it.","Eventually, management gave in on the pressure.","Eventually, management basically caved, no big deal."]',
   0, '[0]', 'single',
   '{"asked":"抵抗をやめて屈することを give in to で述べられるか。","point":"give in to＝（圧力・要求に）屈する。抵抗をやめて相手の要求を受け入れることを示す定番表現。","kid":"give in to＝中に入って明け渡す。抵抗の壁を明け渡して相手を受け入れるイメージ。","eg":"After weeks of protest, the company gave in to public pressure.","terms":[["give in to + 名詞","pressure/demands/temptation などの名詞と相性が良い"],["give in on（誤用）","前置詞は to 固定、on は誤り"]],"think":"屈服の文→動詞は give→粒子は in→前置詞 to。","vs":"直訳肢の entered inside the pressure and gave it は give と in を意味不明に組み合わせた誤った直訳。give in on は前置詞の誤用。最後の肢は caved/no big deal など口語表現で「圧力に屈した」という重みが軽くなりすぎる。","why_asked":"CAE Reading の交渉・対立記事、IELTS Writing の譲歩パラグラフで頻出。","usecase":"組織や個人が最終的に圧力や要求に屈したことを説明する定型表現。","opt":["正解。give in to が屈服を示す標準形。","意味不明に組み合わせた誤った直訳。","前置詞の誤用。","口語すぎて重みが軽くなりすぎる。"]}'),

  ('pv-t2a-q17', '賛否・譲歩系',
   '〔中立〕提案されたスケジュールに反対意見を出す。',
   NULL::text,
   '["The team pushed back on the proposed schedule.","The team pushed the proposed schedule back with their hands.","The team pushed back in the proposed schedule.","The team basically was not having the proposed schedule, nope."]',
   0, '[0]', 'single',
   '{"asked":"提案への反対意見を push back on で述べられるか。","point":"push back on＝（提案・意見に）反対意見を出す・押し返す。ビジネスの議論で異議を唱えるときの定番表現。","kid":"push back on＝押し返す。相手が出してきた案を押し戻すように反対するイメージ。","eg":"Several members pushed back on the proposed budget cuts.","terms":[["push back on + 名詞","proposal/schedule/idea などの名詞と相性が良い"],["push back in（誤用）","前置詞は on 固定、in は誤り"]],"think":"反対意見の文→動詞は push→粒子は back→前置詞 on。","vs":"直訳肢の pushed ... back with their hands は「手で押し返す」という物理的動作を過剰に直訳した表現。push back in は前置詞の誤用。最後の肢は was not having/nope など口語表現で中立的な反対意見の説明としてはやや強すぎる。","why_asked":"CAE Speaking Part 3・4 の異議表明、IELTS Writing の反対意見パラグラフで頻出。","usecase":"会議や議論で提案に対して反対意見を出すことを説明する定型表現。","opt":["正解。push back on が反対意見を示す標準形。","物理的動作を過剰に直訳した表現。","前置詞の誤用。","口語すぎてやや強すぎる表現。"]}'),

  ('pv-t2a-q18', '賛否・譲歩系',
   '〔中立〕当初反対していた人が徐々に賛成に転じた。',
   NULL::text,
   '["Those who initially opposed the idea gradually came round to it.","Those who initially opposed the idea gradually came in a circle to it.","Those who initially opposed the idea gradually came round on it.","Those who were against it basically stopped fighting it after a while, I guess."]',
   0, '[0]', 'single',
   '{"asked":"時間をかけて賛成に転じることを come round to で述べられるか。","point":"come round to＝（時間をかけて）賛成するようになる。徐々に意見を変えていくプロセスを示す定番表現。","kid":"come round to＝ぐるっと回って賛成側に来る。反対の立場からゆっくり回り込んで賛成側にたどり着くイメージ。","eg":"It took a while, but the board eventually came round to the new strategy.","terms":[["come round to + 名詞","idea/plan/proposal などの名詞と相性が良い"],["come round on（誤用）","前置詞は to 固定、on は誤り"]],"think":"意見変化の文→徐々に賛成する→動詞は come→粒子は round→前置詞 to。","vs":"直訳肢の came in a circle to は round を「円」という形として文字通り直訳した不自然な表現。come round on は前置詞の誤用。最後の肢は stopped fighting it/I guess など口語表現で、内容は近いが「積極的に賛成へ転じた」というニュアンスが弱い近義語トラップ。","why_asked":"CAE Speaking Part 3 の意見変化の描写、IELTS Writing の譲歩・転換パラグラフで頻出。","usecase":"時間をかけて反対から賛成へ意見が変化したことを説明する定型表現。","opt":["正解。come round to が意見変化を示す標準形。","roundを円として直訳した不自然な表現。","前置詞の誤用。","ニュアンスが弱い近義語表現。"]}'),

  ('pv-t2a-q19', '賛否・譲歩系',
   '〔口語〕批判にもかかわらず一歩も譲らない。',
   NULL::text,
   '["Despite the criticism, she dug in and refused to change her position.","Despite the criticism, she dug a hole in the ground and refused to change her position.","Despite the criticism, she dug out and refused to change her position.","Notwithstanding the criticism directed at her, she remained steadfastly resolute in her position."]',
   0, '[0]', 'single',
   '{"asked":"頑として譲らない態度を口語で dig in と言えるか。","point":"dig in＝頑として譲らない。塹壕を掘って持ちこたえるイメージから、頑固に立場を守る口語表現に発展した語。","kid":"dig in＝穴を掘って踏ん張る。兵士が塹壕を掘って動かないように、意見も変えないイメージ。","eg":"Even after the backlash, he just dug in and would not budge.","terms":[["dig in（自動詞）","目的語を取らず、態度そのものを表す"],["dig out（誤用）","「掘り出す・見つけ出す」で全く別の意味"]],"think":"口語での態度描写→頑として譲らない→動詞は dig→粒子は in。","vs":"直訳肢の dug a hole in the ground は比喩を文字通りの穴掘りと直訳した不自然な表現。dig out は「掘り出す・見つけ出す」という全く別の意味になる誤用トラップ。最後の肢は notwithstanding/steadfastly resolute など極端にフォーマルな語彙で、口語指定のこの場面には重すぎる。","why_asked":"CAE Speaking Part 4 の口語表現力、IELTS Speaking Part 3 の態度描写で評価される慣用表現。","usecase":"批判を受けても意見を変えない人の態度をカジュアルに描写する言い方。","opt":["正解。dig in が頑固な態度を示す口語の標準形。","比喩を文字通りの穴掘りと直訳した表現。","dig out は全く別の意味。","フォーマルすぎて口語の場面に不適。"]}'),

  ('pv-t2a-q20', '賛否・譲歩系',
   '〔中立〕最初は懐疑的だった聴衆が徐々に案に好意的になった。',
   NULL::text,
   '["The initially skeptical audience gradually warmed to the idea.","The initially skeptical audience gradually became warm in temperature to the idea.","The initially skeptical audience gradually warmed on the idea.","The initially skeptical crowd basically started liking it after a bit, kinda."]',
   0, '[0]', 'single',
   '{"asked":"徐々に好意的になる過程を warm to で述べられるか。","point":"warm to＝（人や案に）徐々に好意的になる。come round to より穏やかで感情面の変化を強調する表現。","kid":"warm to＝温まっていく。冷たかった態度が少しずつ温かく好意的になるイメージ。","eg":"The audience warmed to the speaker as the talk went on.","terms":[["warm to + 名詞","idea/proposal/person などの名詞と相性が良い"],["warm on（誤用）","前置詞は to 固定、on は誤り"]],"think":"感情変化の文→徐々に好意的になる→動詞は warm→前置詞は to。","vs":"直訳肢の became warm in temperature to は warm を「温度」として文字通り直訳した不自然な表現。warm on は前置詞の誤用。最後の肢は started liking it/kinda など口語表現で、内容は近いが「徐々に」という時間の経過のニュアンスが弱い近義語トラップ。","why_asked":"CAE Speaking Part 3 の聴衆・反応の描写、IELTS Writing の感情変化の説明で頻出。","usecase":"聴衆や関係者が時間をかけて好意的になっていく過程を描写する定型表現。","opt":["正解。warm to が徐々に好意的になる過程を示す標準形。","温度として直訳した不自然な表現。","前置詞の誤用。","時間経過のニュアンスが弱い近義語。"]}')

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'pv-t2-a'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
