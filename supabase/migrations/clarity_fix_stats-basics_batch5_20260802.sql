BEGIN;

UPDATE public.questions
SET explanation_data = explanation_data || '{"point": "クラスター抽出法は「塊を選び、選ばれた塊は全部調べる」という形。塊の中をさらに絞り込むことはしない。"}'::jsonb
WHERE source_ref = 'stats17-q04'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

UPDATE public.questions
SET explanation_data = explanation_data || '{"asked": "市区町村、学校、生徒の順に、大きい単位から小さい単位へ段階を踏んで絞り込む抽出方法の名前。", "point": "「大きい単位を選び、その中でさらに小さい単位を選ぶ」を繰り返すのが多段抽出法。段階が複数あることが決め手。", "think": "なぜ1回で生徒を直接選ばず、段階を踏むのかがカギ。全国の中学生から直接生徒を無作為に選ぶと、選ばれた生徒が全国のあちこちに散らばってしまい、訪問や調査の手間がクラスター抽出法の課題と同じように膨らむ。市区町村を選び、その中の学校を選ぶというように大きい単位から順に絞り込んでいけば、最終的に訪問する場所は絞られた学校だけで済み、手間を抑えながらも、1段階だけのクラスター抽出法よりもさらに細かく標本の範囲を調整できる。", "usecase": "全国学力調査、大規模な世帯調査、健康調査など、対象が全国に広がっていて、かつ段階ごとに扱いやすい単位(都道府県、市区町村、世帯のように大きさの違う単位がそろっている)がある調査で使われる。"}'::jsonb
WHERE source_ref = 'stats17-q07'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

UPDATE public.questions
SET explanation_data = explanation_data || '{"vs": "層別抽出は、前のセットで学んだ層化抽出法と同じ手法の別名(呼び方が違うだけ)。無作為抽出は母集団から標本を選ぶときの話、乱塊法は実験の中でグループ分けをする話で、場面が違う。層別抽出(=層化抽出法)とは、「グループに分ける」発想は共通しているが、抽出のための分け方(層別抽出)か、余計な影響を抑えるための分け方(乱塊法)かという目的が異なる。", "opt": ["正解。似た条件どうしをブロックにまとめ、各ブロックの中で全部の水準を試すことで、実験条件以外の余計な影響を抑えるのが乱塊法。", "無作為抽出は母集団から標本を偏りなく選び出す方法で、実験の中で条件をブロックに分ける乱塊法とは目的も場面も異なる。", "多重比較は分散分析で有意差が出たあとに、具体的にどの群が違うかを個別に比べ直す手続きで、実験を組む段階の乱塊法とは別の話。", "層別抽出は、前のセットで学んだ層化抽出法と同じ手法の別名。母集団をいくつかの層に分けて標本を取る方法で、実験の余計な影響を抑えるためにブロックへ分ける乱塊法とは目的が異なる。"]}'::jsonb
WHERE source_ref = 'stats18-q05'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

UPDATE public.questions
SET options = jsonb_set(options, '{3}', '"層別抽出（層化抽出法と同じ手法の別名。母集団をいくつかの層に分けたうえで、各層から標本を抽出する方法）"'::jsonb)
WHERE source_ref = 'stats18-q05'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

UPDATE public.questions
SET explanation_data = explanation_data || '{"viz": "<svg viewBox=\"0 0 340 150\" xmlns=\"http://www.w3.org/2000/svg\" font-family=\"sans-serif\"><text x=\"170\" y=\"14\" fill=\"#e8eaf0\" font-size=\"10\" text-anchor=\"middle\" font-weight=\"600\">27通り全部ではなく、選び抜いた9通りで試す</text><text x=\"90\" y=\"32\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">全要因配置(27通り)</text><g fill=\"#2a2f3f\"><rect x=\"35\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"46\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"57\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"68\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"79\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"90\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"101\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"112\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"123\" y=\"38\" width=\"9\" height=\"9\"/><rect x=\"35\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"46\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"57\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"68\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"79\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"90\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"101\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"112\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"123\" y=\"49\" width=\"9\" height=\"9\"/><rect x=\"35\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"46\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"57\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"68\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"79\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"90\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"101\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"112\" y=\"60\" width=\"9\" height=\"9\"/><rect x=\"123\" y=\"60\" width=\"9\" height=\"9\"/></g><text x=\"84\" y=\"80\" fill=\"#8892a4\" font-size=\"8\" text-anchor=\"middle\">27マスすべて試す</text><text x=\"255\" y=\"32\" fill=\"#8892a4\" font-size=\"8.5\" text-anchor=\"middle\">直交表(9通り)</text><g fill=\"#3b82f6\"><rect x=\"205\" y=\"38\" width=\"12\" height=\"12\"/><rect x=\"235\" y=\"38\" width=\"12\" height=\"12\"/><rect x=\"265\" y=\"38\" width=\"12\" height=\"12\"/><rect x=\"220\" y=\"53\" width=\"12\" height=\"12\"/><rect x=\"250\" y=\"53\" width=\"12\" height=\"12\"/><rect x=\"280\" y=\"53\" width=\"12\" height=\"12\"/><rect x=\"235\" y=\"68\" width=\"12\" height=\"12\"/><rect x=\"265\" y=\"68\" width=\"12\" height=\"12\"/><rect x=\"205\" y=\"68\" width=\"12\" height=\"12\"/></g><text x=\"255\" y=\"98\" fill=\"#8892a4\" font-size=\"8\" text-anchor=\"middle\">9マスだけ選ぶ</text><text x=\"170\" y=\"122\" fill=\"#e8eaf0\" font-size=\"9.5\" text-anchor=\"middle\" font-weight=\"600\">少ない回数でも、偏りなく各要因の効果を見積もれる</text></svg>"}'::jsonb
WHERE source_ref = 'stats18-q06'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

UPDATE public.questions
SET explanation_data = explanation_data || '{"eg": "よく行くスーパーでの買い物の動きに近い。今立っている棚の場所によって、次にどの棚へ向かいやすいかが決まる。それまでどんな順番で棚を回ってきたかは、次にどこへ行くかにはほとんど関係ない。"}'::jsonb
WHERE source_ref = 'stats20-q04'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

UPDATE public.questions
SET explanation_data = explanation_data || '{"eg": "的当てで例えると近い。正方形の板の中に円を描いておき、目をつぶってでたらめに矢をたくさん投げる。的に刺さった矢のうち円の中に入った割合を数えれば、円の面積のだいたいの見当がつく。数式で正確に面積を計算しなくても、でたらめな試行を大量に繰り返せば答えに近づく、という発想が同じ。"}'::jsonb
WHERE source_ref = 'stats20-q07'
  AND subject_id = (SELECT id FROM public.subjects WHERE slug = 'stats-basics');

COMMIT;
