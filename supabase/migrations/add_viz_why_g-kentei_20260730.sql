BEGIN;

-- G検定 g-kentei セット: viz(SVG図解) 後付け + why_asked 補完
-- 生成元: gen_g-kentei.py（手書きSQL禁止・エスケープ事故防止のため機械生成）
-- 既存キーは jsonb_build_object を || で非破壊マージ。options/correct_index/既存キーは変更しない。

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '「知能かどうか」は仕組みが分かった瞬間に評価が変わるという、人の感じ方のクセを問う定番。技術の変化ではなく心理側の話だと気づけるかがカギ。')
WHERE q.source_ref = 'g-kentei-q1'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'AI搭載をうたう製品の多くが実は一番下のレベルという事実を突く問題。レベル分けの数字だけ覚えると、他の選択肢の説明文で引っかかる。')
WHERE q.source_ref = 'g-kentei-q2'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '強いAI/弱いAIは言葉が似ていて、シンギュラリティや特化型/汎用型と混同しやすい。哲学的な区別を用語の定義で正確に選ばせる。')
WHERE q.source_ref = 'g-kentei-q3'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '中国語の部屋はサールの弱いAI擁護（強いAI批判）の思考実験。チューリングテストと混同されやすく、結論（理解していない）を正確に問う。')
WHERE q.source_ref = 'g-kentei-q4'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'フレーム問題は初期AIの根本的な限界として頻出。シンボルグラウンディング問題（意味と記号の結びつき）と混同しやすいので区別させる。')
WHERE q.source_ref = 'g-kentei-q5'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'シンボルグラウンディング問題はフレーム問題と並ぶAIの根本課題。「意味を持たない記号操作」という核心を、フレーム問題との違いで問う。')
WHERE q.source_ref = 'g-kentei-q6'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '探索の基本（深さ優先探索・幅優先探索）はAIの歴史分野で必ず出る。挙動の違い（戻り方・進み方）を正確に区別できるかを問う。')
WHERE q.source_ref = 'g-kentei-q8'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '知識獲得のボトルネックは第2次AIブーム衰退の直接原因として頻出。フレーム問題と混同されがちなので、原因の切り分けを問う。')
WHERE q.source_ref = 'g-kentei-q9'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'ELIZAは初期対話システムの代表として頻出。イライザ効果（中身が浅くても知性を感じる現象）とセットで問われることが多い。')
WHERE q.source_ref = 'g-kentei-q10'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '教師あり/教師なしの分類は最頻出の切り分け問題。名前が『当てる』っぽく見える手法（分類・回帰の仲間）を教師なしと誤答しやすいので、正解ラベルを使うかどうかで判断できるかを問う。')
WHERE q.source_ref = 'g-kentei-q11'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 136" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">入力を確率(0〜1)に変えて分類する</text><line x1="30" y1="100" x2="310" y2="100" stroke="#2a2f3f" stroke-width="1.3"/><path d="M30 96 C 90 96, 130 62, 170 62 C 210 62, 250 28, 310 28" fill="none" stroke="#3b82f6" stroke-width="1.6"/><line x1="30" y1="62" x2="310" y2="62" stroke="#2a2f3f" stroke-dasharray="3 2"/><text x="316" y="65" fill="#8892a4" font-size="9">0.5</text><text x="316" y="99" fill="#8892a4" font-size="9">0</text><text x="316" y="31" fill="#8892a4" font-size="9">1</text><text x="170" y="122" fill="#6ab08d" font-size="9.5" text-anchor="middle">確率が0.5を超えたらクラス1と判定</text></svg>')
WHERE q.source_ref = 'g-kentei-q12'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 126" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="85" y="14" fill="#e8eaf0" font-size="10.5" text-anchor="middle" font-weight="600">k-means（教師なし）</text><text x="255" y="14" fill="#e8eaf0" font-size="10.5" text-anchor="middle" font-weight="600">k-NN（教師あり）</text><line x1="170" y1="20" x2="170" y2="128" stroke="#2a2f3f"/><circle cx="41" cy="49" r="3" fill="#60a5fa"/><circle cx="47" cy="65" r="3" fill="#60a5fa"/><circle cx="35" cy="63" r="3" fill="#60a5fa"/><circle cx="57" cy="53" r="3" fill="#60a5fa"/><circle cx="105" cy="67" r="3" fill="#c9a04a"/><circle cx="119" cy="81" r="3" fill="#c9a04a"/><circle cx="113" cy="89" r="3" fill="#c9a04a"/><circle cx="125" cy="69" r="3" fill="#c9a04a"/><text x="85" y="112" fill="#8892a4" font-size="9" text-anchor="middle">正解なし→似た者同士でグループ分け</text><circle cx="214" cy="56" r="3" fill="#6ab08d"/><circle cx="208" cy="74" r="3" fill="#6ab08d"/><circle cx="226" cy="48" r="3" fill="#6ab08d"/><circle cx="244" cy="60" r="3" fill="#6ab08d"/><circle cx="220" cy="88" r="3" fill="#6ab08d"/><circle cx="240" cy="90" r="3" fill="#6ab08d"/><circle cx="245" cy="60" r="4" fill="#c47070"/><text x="245" y="45" fill="#c47070" font-size="8.5" text-anchor="middle">新規点</text><text x="255" y="112" fill="#8892a4" font-size="9" text-anchor="middle">近くのk個の正解で多数決</text></svg>', 'why_asked', '名前が似ているk-means（教師なし）とk-NN（教師あり）を混同させる定番の引っかけ。kの意味自体も違う点まで区別できるかを問う。')
WHERE q.source_ref = 'g-kentei-q13'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 132" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">たくさんの軸を、少ない軸にまとめる</text><line x1="40" y1="100" x2="300" y2="30" stroke="#3b82f6" stroke-width="1.6"/><circle cx="90" cy="55" r="3" fill="#8892a4"/><line x1="90" y1="55" x2="96" y2="82" stroke="#2a2f3f" stroke-dasharray="2 2"/><circle cx="96" cy="82" r="2.6" fill="#6ab08d"/><circle cx="140" cy="40" r="3" fill="#8892a4"/><line x1="140" y1="40" x2="145" y2="72" stroke="#2a2f3f" stroke-dasharray="2 2"/><circle cx="145" cy="72" r="2.6" fill="#6ab08d"/><circle cx="200" cy="90" r="3" fill="#8892a4"/><line x1="200" y1="90" x2="195" y2="60" stroke="#2a2f3f" stroke-dasharray="2 2"/><circle cx="195" cy="60" r="2.6" fill="#6ab08d"/><circle cx="250" cy="50" r="3" fill="#8892a4"/><line x1="250" y1="50" x2="245" y2="50" stroke="#2a2f3f" stroke-dasharray="2 2"/><circle cx="245" cy="50" r="2.6" fill="#6ab08d"/><circle cx="110" cy="85" r="3" fill="#8892a4"/><line x1="110" y1="85" x2="116" y2="88" stroke="#2a2f3f" stroke-dasharray="2 2"/><circle cx="116" cy="88" r="2.6" fill="#6ab08d"/><text x="170" y="120" fill="#6ab08d" font-size="9.5" text-anchor="middle">元の位置(灰)を、情報を保ったまま軸(緑)へ投影</text></svg>', 'why_asked', 'PCAは次元削減であって、クラスタリングや分類とは目的が違う。「情報を保ちつつ減らす」という目的を正確に問う。')
WHERE q.source_ref = 'g-kentei-q14'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 128" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">訓練誤差は下がり続け、検証誤差だけ途中で反転＝過学習</text><line x1="30" y1="105" x2="310" y2="105" stroke="#2a2f3f" stroke-width="1.3"/><line x1="30" y1="20" x2="30" y2="105" stroke="#2a2f3f" stroke-width="1.3"/><path d="M30 25 C 110 52, 190 78, 300 95" fill="none" stroke="#60a5fa" stroke-width="1.6"/><path d="M30 28 C 100 55, 160 72, 210 76 C 250 79, 280 55, 300 30" fill="none" stroke="#c47070" stroke-width="1.6"/><line x1="210" y1="20" x2="210" y2="105" stroke="#2a2f3f" stroke-dasharray="3 2"/><text x="210" y="115" fill="#c9a04a" font-size="8.5" text-anchor="middle">ここから過学習</text><text x="305" y="103" fill="#60a5fa" font-size="9" text-anchor="end">訓練誤差</text><text x="305" y="26" fill="#c47070" font-size="9" text-anchor="end">検証誤差</text></svg>', 'why_asked', '過学習と未学習は逆の状態として対で出題される定番。訓練データと未知データの成績の差でどちらか判断できるかを問う。')
WHERE q.source_ref = 'g-kentei-q15'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 124" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">テスト役を交代しながらk回評価して平均</text><rect x="60" y="28" width="44" height="24" rx="3" fill="#2f3547"/><text x="82.0" y="44" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><rect x="110" y="28" width="44" height="24" rx="3" fill="#c47070"/><text x="132.0" y="44" fill="#ffffff" font-size="9" text-anchor="middle">検証</text><rect x="160" y="28" width="44" height="24" rx="3" fill="#2f3547"/><text x="182.0" y="44" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><rect x="210" y="28" width="44" height="24" rx="3" fill="#2f3547"/><text x="232.0" y="44" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><rect x="260" y="28" width="44" height="24" rx="3" fill="#2f3547"/><text x="282.0" y="44" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><rect x="60" y="66" width="44" height="24" rx="3" fill="#2f3547"/><text x="82.0" y="82" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><rect x="110" y="66" width="44" height="24" rx="3" fill="#2f3547"/><text x="132.0" y="82" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><rect x="160" y="66" width="44" height="24" rx="3" fill="#2f3547"/><text x="182.0" y="82" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><rect x="210" y="66" width="44" height="24" rx="3" fill="#c47070"/><text x="232.0" y="82" fill="#ffffff" font-size="9" text-anchor="middle">検証</text><rect x="260" y="66" width="44" height="24" rx="3" fill="#2f3547"/><text x="282.0" y="82" fill="#8892a4" font-size="9" text-anchor="middle">訓練</text><text x="170" y="112" fill="#6ab08d" font-size="9.5" text-anchor="middle">回ごとに「検証」役の位置を1つずつずらす</text></svg>', 'why_asked', '限られたデータで信頼できる評価をする方法として頻出。ホールドアウト法との違い（一度きり vs 交代して平均）を問う。')
WHERE q.source_ref = 'g-kentei-q16'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 112" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">前の間違いを重点的に直しながら順番に追加</text><rect x="28" y="45" width="70" height="34" rx="4" fill="#2f3547"/><text x="63" y="66" fill="#e8eaf0" font-size="9.5" text-anchor="middle">学習器1</text><rect x="138" y="45" width="70" height="34" rx="4" fill="#2f3547"/><text x="173" y="66" fill="#e8eaf0" font-size="9.5" text-anchor="middle">学習器2</text><rect x="248" y="45" width="70" height="34" rx="4" fill="#2f3547"/><text x="283" y="66" fill="#e8eaf0" font-size="9.5" text-anchor="middle">学習器3</text><path d="M98 62 L133 62" stroke="#60a5fa" stroke-width="1.6" marker-end="url(#gk17a)"/><path d="M208 62 L243 62" stroke="#60a5fa" stroke-width="1.6" marker-end="url(#gk17a)"/><defs><marker id="gk17a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#60a5fa"/></marker></defs><text x="63" y="95" fill="#c47070" font-size="8.5" text-anchor="middle">間違い多</text><text x="173" y="95" fill="#c9a04a" font-size="8.5" text-anchor="middle">間違い減</text><text x="283" y="95" fill="#6ab08d" font-size="8.5" text-anchor="middle">間違い少</text></svg>', 'why_asked', 'ブースティングとバギングは名前も仕組みも紛らわしいアンサンブル学習の代表2種。順番か並列かの違いを問う定番。')
WHERE q.source_ref = 'g-kentei-q17'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 126" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">誤差の信号が、手前の層に届くほど細る</text><rect x="37.0" y="30" width="6" height="46" rx="3" fill="#3b82f6" opacity="0.75"/><rect x="114.5" y="30" width="11" height="46" rx="3" fill="#3b82f6" opacity="0.75"/><rect x="191.0" y="30" width="18" height="46" rx="3" fill="#3b82f6" opacity="0.75"/><rect x="267.0" y="30" width="26" height="46" rx="3" fill="#3b82f6" opacity="0.75"/><path d="M280 53 L 46 53" stroke="#c47070" stroke-width="1.4" stroke-dasharray="4 2" marker-end="url(#gk18a)"/><defs><marker id="gk18a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#c47070"/></marker></defs><text x="280" y="90" fill="#8892a4" font-size="8.5" text-anchor="middle">出力層</text><text x="40" y="90" fill="#8892a4" font-size="8.5" text-anchor="middle">入力層</text><text x="170" y="112" fill="#c47070" font-size="9.5" text-anchor="middle">シグモイドを通るたび勾配が縮み、ほぼ消える</text></svg>', 'why_asked', '勾配消失は深層学習が長らく抱えた根本課題として頻出。過学習や次元の呪いなど別の問題と混同しやすく、原因がシグモイド由来の信号の減衰であることを正確に問う。')
WHERE q.source_ref = 'g-kentei-q18'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">複数クラスの点数を、合計100%の確率に変える</text><rect x="55" y="45" width="34" height="50" rx="3" fill="#3b82f6"/><text x="72" y="108" fill="#8892a4" font-size="9" text-anchor="middle">犬</text><text x="72" y="39" fill="#e8eaf0" font-size="9" text-anchor="middle">50%</text><rect x="135" y="65" width="34" height="30" rx="3" fill="#60a5fa"/><text x="152" y="108" fill="#8892a4" font-size="9" text-anchor="middle">猫</text><text x="152" y="59" fill="#e8eaf0" font-size="9" text-anchor="middle">30%</text><rect x="215" y="83" width="34" height="12" rx="3" fill="#4d5872"/><text x="232" y="108" fill="#8892a4" font-size="9" text-anchor="middle">鳥</text><text x="232" y="77" fill="#e8eaf0" font-size="9" text-anchor="middle">12%</text><rect x="261" y="87" width="34" height="8" rx="3" fill="#4d5872"/><text x="278" y="108" fill="#8892a4" font-size="9" text-anchor="middle">他</text><text x="278" y="81" fill="#e8eaf0" font-size="9" text-anchor="middle">8%</text><text x="170" y="128" fill="#6ab08d" font-size="9.5" text-anchor="middle">4つの点数を合計すると必ず100%になる</text></svg>', 'why_asked', '多クラス分類の出力層の定番関数。二値分類用のシグモイド関数との使い分けを問う頻出ポイント。')
WHERE q.source_ref = 'g-kentei-q19'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 134" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">勢い(モメンタム)＋歩幅の自動調整(RMSProp)</text><path d="M20 30 Q170 130 320 30" fill="none" stroke="#2a2f3f" stroke-width="10" opacity="0.5"/><path d="M30 45 L60 70 L45 90 L75 100 L70 108 L100 110" fill="none" stroke="#c47070" stroke-width="1.6"/><path d="M30 40 C 100 90, 200 108, 300 40" fill="none" stroke="#6ab08d" stroke-width="1.8"/><text x="100" y="122" fill="#c47070" font-size="8.5" text-anchor="middle">SGD: ジグザグで遅い</text><text x="270" y="122" fill="#6ab08d" font-size="8.5" text-anchor="middle">Adam: まっすぐ速い</text></svg>')
WHERE q.source_ref = 'g-kentei-q20'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 110" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">誤差を出口から入口へ戻し、直し方を求める</text><rect x="30" y="45" width="46" height="34" rx="4" fill="#2f3547"/><text x="53" y="66" fill="#e8eaf0" font-size="9" text-anchor="middle">入力</text><rect x="140" y="45" width="46" height="34" rx="4" fill="#2f3547"/><text x="163" y="66" fill="#e8eaf0" font-size="9" text-anchor="middle">隠れ層</text><rect x="250" y="45" width="46" height="34" rx="4" fill="#2f3547"/><text x="273" y="66" fill="#e8eaf0" font-size="9" text-anchor="middle">出力</text><path d="M76 55 L135 55" stroke="#60a5fa" stroke-width="1.4" marker-end="url(#gk21f)"/><path d="M186 55 L245 55" stroke="#60a5fa" stroke-width="1.4" marker-end="url(#gk21f)"/><path d="M245 72 L186 72" stroke="#c47070" stroke-width="1.4" marker-end="url(#gk21b)"/><path d="M135 72 L76 72" stroke="#c47070" stroke-width="1.4" marker-end="url(#gk21b)"/><defs><marker id="gk21f" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#60a5fa"/></marker><marker id="gk21b" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#c47070"/></marker></defs><text x="270" y="35" fill="#60a5fa" font-size="8.5" text-anchor="end">順伝播（予測）</text><text x="270" y="98" fill="#c47070" font-size="8.5" text-anchor="end">逆伝播（誤差を戻す）</text></svg>', 'why_asked', 'ニューラルネット学習の心臓部で、仕組みそのものを問う頻出テーマ。連鎖律や勾配消失とセットで理解しているか確認される。')
WHERE q.source_ref = 'g-kentei-q21'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 124" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="85" y="14" fill="#e8eaf0" font-size="10.5" text-anchor="middle" font-weight="600">L1: 一部をちょうど0に</text><text x="255" y="14" fill="#e8eaf0" font-size="10.5" text-anchor="middle" font-weight="600">L2: 全体をなだらかに縮小</text><line x1="170" y1="20" x2="170" y2="112" stroke="#2a2f3f"/><line x1="35" y1="95" x2="140" y2="95" stroke="#2a2f3f"/><rect x="45" y="95" width="12" height="0" fill="#8892a4"/><rect x="65" y="53" width="12" height="42" fill="#3b82f6"/><rect x="85" y="95" width="12" height="0" fill="#8892a4"/><rect x="105" y="69" width="12" height="26" fill="#3b82f6"/><line x1="205" y1="95" x2="310" y2="95" stroke="#2a2f3f"/><rect x="215" y="81" width="12" height="14" fill="#60a5fa"/><rect x="235" y="73" width="12" height="22" fill="#60a5fa"/><rect x="255" y="85" width="12" height="10" fill="#60a5fa"/><rect x="275" y="79" width="12" height="16" fill="#60a5fa"/><text x="85" y="112" fill="#6ab08d" font-size="8.5" text-anchor="middle">効かない項目が消える（特徴選択）</text><text x="255" y="112" fill="#8892a4" font-size="8.5" text-anchor="middle">全部残るが小さくなる</text></svg>', 'why_asked', 'L1とL2正則化はよく対比で問われる定番ペア。「ちょうど0になるか、なだらかに縮むか」という違いを正確に区別できるか問う。')
WHERE q.source_ref = 'g-kentei-q22'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 124" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">学習のたびに一部のノードをランダムに休ませる</text><circle cx="90" cy="35" r="7" fill="#3b82f6"/><circle cx="90" cy="60" r="7" fill="none" stroke="#c47070" stroke-width="1.3"/><line x1="85" y1="55" x2="95" y2="65" stroke="#c47070" stroke-width="1.3"/><line x1="85" y1="65" x2="95" y2="55" stroke="#c47070" stroke-width="1.3"/><circle cx="90" cy="85" r="7" fill="#3b82f6"/><circle cx="170" cy="35" r="7" fill="#3b82f6"/><circle cx="170" cy="60" r="7" fill="#3b82f6"/><circle cx="170" cy="85" r="7" fill="#3b82f6"/><circle cx="250" cy="35" r="7" fill="none" stroke="#c47070" stroke-width="1.3"/><line x1="245" y1="30" x2="255" y2="40" stroke="#c47070" stroke-width="1.3"/><line x1="245" y1="40" x2="255" y2="30" stroke="#c47070" stroke-width="1.3"/><circle cx="250" cy="60" r="7" fill="#3b82f6"/><circle cx="250" cy="85" r="7" fill="none" stroke="#c47070" stroke-width="1.3"/><line x1="245" y1="80" x2="255" y2="90" stroke="#c47070" stroke-width="1.3"/><line x1="245" y1="90" x2="255" y2="80" stroke="#c47070" stroke-width="1.3"/><line x1="97" y1="35" x2="163" y2="35" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="35" x2="163" y2="60" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="35" x2="163" y2="85" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="60" x2="163" y2="35" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="60" x2="163" y2="60" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="60" x2="163" y2="85" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="85" x2="163" y2="35" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="85" x2="163" y2="60" stroke="#2a2f3f" stroke-width="1"/><line x1="97" y1="85" x2="163" y2="85" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="35" x2="243" y2="35" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="35" x2="243" y2="60" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="35" x2="243" y2="85" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="60" x2="243" y2="35" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="60" x2="243" y2="60" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="60" x2="243" y2="85" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="85" x2="243" y2="35" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="85" x2="243" y2="60" stroke="#2a2f3f" stroke-width="1"/><line x1="177" y1="85" x2="243" y2="85" stroke="#2a2f3f" stroke-width="1"/><text x="170" y="112" fill="#8892a4" font-size="9" text-anchor="middle">×は今回休んでいるノード（回ごとに変わる）</text></svg>', 'why_asked', '過学習対策の代表手法。バッチ正規化・早期終了など似た目的の別手法と混同しやすいため、仕組み（ノードを休ませる）で区別させる。')
WHERE q.source_ref = 'g-kentei-q23'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 120" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">同じフィルタを画像じゅうで使い回す</text><rect x="50" y="26" width="14" height="14" fill="#2f3547"/><rect x="66" y="26" width="14" height="14" fill="#2f3547"/><rect x="82" y="26" width="14" height="14" fill="#2f3547"/><rect x="98" y="26" width="14" height="14" fill="#2f3547"/><rect x="114" y="26" width="14" height="14" fill="#2f3547"/><rect x="50" y="42" width="14" height="14" fill="#2f3547"/><rect x="66" y="42" width="14" height="14" fill="#2f3547"/><rect x="82" y="42" width="14" height="14" fill="#2f3547"/><rect x="98" y="42" width="14" height="14" fill="#2f3547"/><rect x="114" y="42" width="14" height="14" fill="#2f3547"/><rect x="50" y="58" width="14" height="14" fill="#2f3547"/><rect x="66" y="58" width="14" height="14" fill="#2f3547"/><rect x="82" y="58" width="14" height="14" fill="#2f3547"/><rect x="98" y="58" width="14" height="14" fill="#2f3547"/><rect x="114" y="58" width="14" height="14" fill="#2f3547"/><rect x="50" y="74" width="14" height="14" fill="#2f3547"/><rect x="66" y="74" width="14" height="14" fill="#2f3547"/><rect x="82" y="74" width="14" height="14" fill="#2f3547"/><rect x="98" y="74" width="14" height="14" fill="#2f3547"/><rect x="114" y="74" width="14" height="14" fill="#2f3547"/><rect x="50" y="90" width="14" height="14" fill="#2f3547"/><rect x="66" y="90" width="14" height="14" fill="#2f3547"/><rect x="82" y="90" width="14" height="14" fill="#2f3547"/><rect x="98" y="90" width="14" height="14" fill="#2f3547"/><rect x="114" y="90" width="14" height="14" fill="#2f3547"/><rect x="50" y="26" width="46" height="46" fill="none" stroke="#60a5fa" stroke-width="2"/><rect x="130" y="58" width="46" height="46" fill="none" stroke="#60a5fa" stroke-width="2" stroke-dasharray="4 2"/><path d="M96 49 C 115 49, 115 81, 128 81" fill="none" stroke="#60a5fa" stroke-width="1.3" marker-end="url(#gk24a)"/><defs><marker id="gk24a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#60a5fa"/></marker></defs><text x="245" y="45" fill="#8892a4" font-size="9">同じ1枚のフィルタが</text><text x="245" y="60" fill="#8892a4" font-size="9">スライドしながら</text><text x="245" y="75" fill="#6ab08d" font-size="9">線や角を探す</text></svg>', 'why_asked', 'CNNの中核概念で頻出。全結合層やプーリング層と役割を混同しやすいため、フィルタ共有という仕組みを正確に問う。')
WHERE q.source_ref = 'g-kentei-q24'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 116" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">特徴マップを縮め、位置ズレに強くする</text><rect x="40" y="26" width="18" height="18" fill="#2f3547"/><rect x="60" y="26" width="18" height="18" fill="#2f3547"/><rect x="80" y="26" width="18" height="18" fill="#2f3547"/><rect x="100" y="26" width="18" height="18" fill="#2f3547"/><rect x="40" y="46" width="18" height="18" fill="#2f3547"/><rect x="60" y="46" width="18" height="18" fill="#2f3547"/><rect x="80" y="46" width="18" height="18" fill="#2f3547"/><rect x="100" y="46" width="18" height="18" fill="#2f3547"/><rect x="40" y="66" width="18" height="18" fill="#2f3547"/><rect x="60" y="66" width="18" height="18" fill="#2f3547"/><rect x="80" y="66" width="18" height="18" fill="#2f3547"/><rect x="100" y="66" width="18" height="18" fill="#2f3547"/><rect x="40" y="86" width="18" height="18" fill="#2f3547"/><rect x="60" y="86" width="18" height="18" fill="#2f3547"/><rect x="80" y="86" width="18" height="18" fill="#2f3547"/><rect x="100" y="86" width="18" height="18" fill="#2f3547"/><rect x="40" y="26" width="38" height="38" fill="none" stroke="#c9a04a" stroke-width="1.6"/><path d="M100 45 L140 45" stroke="#60a5fa" stroke-width="1.6" marker-end="url(#gk25a)"/><defs><marker id="gk25a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#60a5fa"/></marker></defs><text x="120" y="35" fill="#8892a4" font-size="8">最大値だけ残す</text><rect x="160" y="40" width="20" height="20" fill="#c9a04a"/><rect x="182" y="40" width="20" height="20" fill="#c9a04a"/><rect x="160" y="62" width="20" height="20" fill="#c9a04a"/><rect x="182" y="62" width="20" height="20" fill="#c9a04a"/><text x="230" y="100" fill="#6ab08d" font-size="9" text-anchor="middle">サイズは縮むが、多少ずれても同じ最大値を拾える</text></svg>', 'why_asked', 'プーリング層は畳み込み層と役割が混同されやすい定番の対。「新しい特徴を拾う」か「縮めて安定させる」かの違いを問う。')
WHERE q.source_ref = 'g-kentei-q25'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 118" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">記憶の通り道と、3つの門で情報を管理</text><line x1="20" y1="35" x2="320" y2="35" stroke="#6ab08d" stroke-width="3"/><text x="20" y="26" fill="#6ab08d" font-size="8.5">セル（記憶）</text><rect x="40" y="55" width="60" height="30" rx="4" fill="#2f3547"/><text x="70" y="74" fill="#e8eaf0" font-size="8.5" text-anchor="middle">忘れる門</text><line x1="70" y1="55" x2="70" y2="38" stroke="#8892a4" stroke-width="1.2" marker-end="url(#gk26a)"/><rect x="140" y="55" width="60" height="30" rx="4" fill="#2f3547"/><text x="170" y="74" fill="#e8eaf0" font-size="8.5" text-anchor="middle">覚える門</text><line x1="170" y1="55" x2="170" y2="38" stroke="#8892a4" stroke-width="1.2" marker-end="url(#gk26a)"/><rect x="240" y="55" width="60" height="30" rx="4" fill="#2f3547"/><text x="270" y="74" fill="#e8eaf0" font-size="8.5" text-anchor="middle">出す門</text><line x1="270" y1="55" x2="270" y2="38" stroke="#8892a4" stroke-width="1.2" marker-end="url(#gk26a)"/><defs><marker id="gk26a" markerWidth="7" markerHeight="7" refX="5" refY="2.5" orient="auto"><path d="M0,0 L5,2.5 L0,5 z" fill="#8892a4"/></marker></defs><text x="170" y="105" fill="#8892a4" font-size="9" text-anchor="middle">門が記憶の出し入れを調整し、長い情報も薄まらず届く</text></svg>')
WHERE q.source_ref = 'g-kentei-q26'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 100" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">関係が強い単語ほど太い線で結ぶ</text><rect x="34" y="58" width="32" height="24" rx="4" fill="#2f3547"/><text x="50" y="74" fill="#e8eaf0" font-size="9" text-anchor="middle">その</text><rect x="114" y="58" width="32" height="24" rx="4" fill="#2f3547"/><text x="130" y="74" fill="#e8eaf0" font-size="9" text-anchor="middle">犬</text><rect x="194" y="58" width="32" height="24" rx="4" fill="#2f3547"/><text x="210" y="74" fill="#e8eaf0" font-size="9" text-anchor="middle">は</text><rect x="274" y="58" width="32" height="24" rx="4" fill="#2f3547"/><text x="290" y="74" fill="#e8eaf0" font-size="9" text-anchor="middle">眠い</text><path d="M146 65 C 190 30, 230 30, 274 62" stroke="#60a5fa" stroke-width="3" fill="none" opacity="0.9"/><path d="M66 75 C 90 95, 110 95, 130 78" stroke="#2a2f3f" stroke-width="1" fill="none"/><path d="M66 65 C 110 40, 190 45, 274 68" stroke="#2a2f3f" stroke-width="1" fill="none"/><text x="170" y="30" fill="#60a5fa" font-size="8.5" text-anchor="middle">「犬」は「眠い」の主語＝関係が強い</text></svg>', 'why_asked', '自己注意はTransformerの中核概念として頻出。プーリングやスキップ結合など他の要素技術と混同されやすい。')
WHERE q.source_ref = 'g-kentei-q27'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 112" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="90" y="14" fill="#e8eaf0" font-size="10.5" text-anchor="middle" font-weight="600">RNN: 一語ずつ順番に</text><text x="250" y="14" fill="#e8eaf0" font-size="10.5" text-anchor="middle" font-weight="600">Transformer: まとめて一度に</text><line x1="170" y1="20" x2="170" y2="112" stroke="#2a2f3f"/><circle cx="35" cy="60" r="9" fill="#c47070"/><circle cx="65" cy="60" r="9" fill="#c47070"/><circle cx="95" cy="60" r="9" fill="#c47070"/><circle cx="125" cy="60" r="9" fill="#c47070"/><path d="M44 60 L56 60" stroke="#c47070" stroke-width="1.4" marker-end="url(#gk28a)"/><path d="M74 60 L86 60" stroke="#c47070" stroke-width="1.4" marker-end="url(#gk28a)"/><path d="M104 60 L116 60" stroke="#c47070" stroke-width="1.4" marker-end="url(#gk28a)"/><defs><marker id="gk28a" markerWidth="7" markerHeight="7" refX="5" refY="2.5" orient="auto"><path d="M0,0 L5,2.5 L0,5 z" fill="#c47070"/></marker></defs><text x="80" y="100" fill="#8892a4" font-size="8.5" text-anchor="middle">遅い（待ち行列）</text><circle cx="220" cy="60" r="9" fill="#6ab08d"/><circle cx="250" cy="60" r="9" fill="#6ab08d"/><circle cx="280" cy="60" r="9" fill="#6ab08d"/><circle cx="310" cy="60" r="9" fill="#6ab08d"/><line x1="220" y1="60" x2="250" y2="60" stroke="#6ab08d" stroke-width="1" opacity="0.5"/><line x1="220" y1="60" x2="280" y2="60" stroke="#6ab08d" stroke-width="1" opacity="0.5"/><line x1="220" y1="60" x2="310" y2="60" stroke="#6ab08d" stroke-width="1" opacity="0.5"/><text x="265" y="100" fill="#8892a4" font-size="8.5" text-anchor="middle">速い（一斉に計算）</text></svg>', 'why_asked', 'TransformerがRNNより優れている理由（並列計算）は頻出の比較ポイント。計算資源が少なく済むという誤答に引っかかりやすい。')
WHERE q.source_ref = 'g-kentei-q28'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">圧縮してから、また元に戻す</text><path d="M30 30 L110 55 L110 75 L30 100 Z" fill="#3b82f6" opacity="0.55"/><path d="M310 30 L230 55 L230 75 L310 100 Z" fill="#60a5fa" opacity="0.55"/><rect x="150" y="55" width="40" height="20" rx="3" fill="#6ab08d"/><text x="170" y="45" fill="#6ab08d" font-size="8.5" text-anchor="middle">圧縮された表現</text><text x="70" y="115" fill="#8892a4" font-size="8.5" text-anchor="middle">エンコーダ</text><text x="270" y="115" fill="#8892a4" font-size="8.5" text-anchor="middle">デコーダ</text><text x="170" y="128" fill="#8892a4" font-size="8.5" text-anchor="middle">うまく戻せる＝大事な特徴をつかめた証拠</text></svg>', 'why_asked', 'オートエンコーダはSVMや決定木など別の手法と混同されやすい。「圧縮して復元する」という構造の理解を問う。')
WHERE q.source_ref = 'g-kentei-q29'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '物体検出はセマンティックセグメンテーションや画像分類と混同されやすい定番の対比。「種類＋位置」を同時に求める点を問う。')
WHERE q.source_ref = 'g-kentei-q30'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'セマンティックセグメンテーションは物体検出との粒度の違い（枠か画素単位か）が頻出の区別ポイント。')
WHERE q.source_ref = 'g-kentei-q31'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '単語埋め込みは自然言語処理の基礎として頻出。one-hot表現との違い（意味的な近さを距離で表す）を問う。')
WHERE q.source_ref = 'g-kentei-q33'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 112" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">本物らしさを競わせて両方が上達する</text><rect x="30" y="45" width="80" height="34" rx="4" fill="#3b82f6"/><text x="70" y="66" fill="#ffffff" font-size="9.5" text-anchor="middle">生成器</text><rect x="230" y="45" width="80" height="34" rx="4" fill="#c9a04a"/><text x="270" y="66" fill="#141720" font-size="9.5" text-anchor="middle">識別器</text><path d="M112 55 L226 55" stroke="#60a5fa" stroke-width="1.4" marker-end="url(#gk34a)"/><path d="M226 70 L112 70" stroke="#c47070" stroke-width="1.4" marker-end="url(#gk34b)"/><defs><marker id="gk34a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#60a5fa"/></marker><marker id="gk34b" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 z" fill="#c47070"/></marker></defs><text x="170" y="40" fill="#60a5fa" font-size="8.5" text-anchor="middle">偽物を渡す</text><text x="170" y="98" fill="#c47070" font-size="8.5" text-anchor="middle">本物か偽物か判定を返す</text></svg>', 'why_asked', 'GANは識別器と生成器という2つの役割を混同しやすい。拡散モデルなど他の生成モデルとの区別も頻出。')
WHERE q.source_ref = 'g-kentei-q34'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 112" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">ノイズを少しずつ取り除いて画像にする</text><rect x="25" y="35" width="50" height="50" rx="4" fill="#4d5872"/><rect x="100" y="35" width="50" height="50" rx="4" fill="#3b6a8a"/><rect x="175" y="35" width="50" height="50" rx="4" fill="#3b8a72"/><rect x="250" y="35" width="50" height="50" rx="4" fill="#6ab08d"/><path d="M78 60 L92 60" stroke="#8892a4" stroke-width="1.4" marker-end="url(#gk35a)"/><path d="M153 60 L167 60" stroke="#8892a4" stroke-width="1.4" marker-end="url(#gk35a)"/><path d="M228 60 L242 60" stroke="#8892a4" stroke-width="1.4" marker-end="url(#gk35a)"/><defs><marker id="gk35a" markerWidth="7" markerHeight="7" refX="5" refY="2.5" orient="auto"><path d="M0,0 L5,2.5 L0,5 z" fill="#8892a4"/></marker></defs><text x="50" y="100" fill="#8892a4" font-size="8" text-anchor="middle">ノイズだけ</text><text x="275" y="100" fill="#6ab08d" font-size="8" text-anchor="middle">きれいな画像</text></svg>', 'why_asked', '拡散モデルは近年の生成AIブームで重要度が増したテーマ。GANとの仕組みの違い（敵対学習かノイズ除去か）を問う。')
WHERE q.source_ref = 'g-kentei-q35'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '転移学習とファインチューニングは意味が近く混同されやすい。両者の関係（土台の再利用か重みの調整か）を問う定番。')
WHERE q.source_ref = 'g-kentei-q36'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'AIプロジェクトの進め方（PoC）は実務プロセスの用語として頻出。本開発との違いを正確に問う。')
WHERE q.source_ref = 'g-kentei-q37'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'アノテーションは教師あり学習の前提となる地味だが頻出の用語。データ収集・前処理の他工程と混同しやすい。')
WHERE q.source_ref = 'g-kentei-q38'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'MLOpsは開発・運用を一体で回す実践として近年重視されるテーマ。DevOpsとの違いも意識して問われる。')
WHERE q.source_ref = 'g-kentei-q39'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 118" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">見逃し(FN)を減らしたい→再現率を重視</text><rect x="80" y="30" width="80" height="34" fill="#6ab08d" opacity="0.55"/><text x="120" y="51" fill="#e8eaf0" font-size="9.5" text-anchor="middle">TP 陽性を的中</text><rect x="160" y="30" width="80" height="34" fill="#3f4658"/><text x="200" y="51" fill="#8892a4" font-size="9.5" text-anchor="middle">FP 誤って陽性</text><rect x="80" y="64" width="80" height="34" fill="#c47070" opacity="0.75"/><text x="120" y="85" fill="#ffffff" font-size="9.5" text-anchor="middle">FN 見逃し</text><rect x="160" y="64" width="80" height="34" fill="#3f4658"/><text x="200" y="85" fill="#8892a4" font-size="9.5" text-anchor="middle">TN 陰性を的中</text><text x="120" y="112" fill="#8892a4" font-size="8.5" text-anchor="middle">実際は陽性</text><text x="200" y="112" fill="#8892a4" font-size="8.5" text-anchor="middle">実際は陰性</text></svg>')
WHERE q.source_ref = 'g-kentei-q40'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 118" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">適合率と再現率、両方のバランスを見る指標</text><line x1="60" y1="70" x2="280" y2="70" stroke="#2a2f3f" stroke-width="2"/><circle cx="170" cy="70" r="4" fill="#c9a04a"/><line x1="170" y1="70" x2="170" y2="45" stroke="#c9a04a" stroke-width="1.4"/><rect x="60" y="90" width="90" height="16" rx="3" fill="#3b82f6"/><text x="105" y="102" fill="#ffffff" font-size="8.5" text-anchor="middle">適合率</text><rect x="190" y="90" width="90" height="16" rx="3" fill="#60a5fa"/><text x="235" y="102" fill="#141720" font-size="8.5" text-anchor="middle">再現率</text><text x="170" y="40" fill="#c9a04a" font-size="9" text-anchor="middle">F値（釣り合う点）</text></svg>', 'why_asked', 'F値は適合率と再現率のトレードオフを一つにまとめる指標として頻出。片方だけを見る誤りを防ぐ視点を問う。')
WHERE q.source_ref = 'g-kentei-q41'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><path d="M20 74 C 90 74, 105 20, 170 20 C 235 20, 250 74, 320 74" fill="none" stroke="#8892a4" stroke-width="1.3"/><line x1="20" y1="74" x2="320" y2="74" stroke="#2a2f3f" stroke-width="1.3"/><line x1="123" y1="16" x2="123" y2="74" stroke="#2a2f3f" stroke-dasharray="3 2"/><text x="123" y="12" fill="#8892a4" font-size="8.5" text-anchor="middle">-1σ</text><line x1="170" y1="16" x2="170" y2="74" stroke="#2a2f3f" stroke-dasharray="3 2"/><text x="170" y="12" fill="#8892a4" font-size="8.5" text-anchor="middle">平均</text><line x1="217" y1="16" x2="217" y2="74" stroke="#2a2f3f" stroke-dasharray="3 2"/><text x="217" y="12" fill="#8892a4" font-size="8.5" text-anchor="middle">+1σ</text><rect x="123" y="90" width="94" height="12" rx="2" fill="#3b82f6" opacity="0.6"/><text x="170" y="106" fill="#60a5fa" font-size="9.5" text-anchor="middle" font-weight="600">±1σ に約68%</text><rect x="80" y="116" width="180" height="12" rx="2" fill="#3b82f6" opacity="0.28"/><text x="170" y="132" fill="#8892a4" font-size="9.5" text-anchor="middle">±2σ に約95%</text></svg>', 'why_asked', '正規分布の68-95ルールは統計知識分野の頻出項目。標準偏差の意味を実感として理解しているかを問う。')
WHERE q.source_ref = 'g-kentei-q42'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 126" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">曲線の下側の面積(AUC)が大きいほど高性能</text><line x1="40" y1="105" x2="300" y2="105" stroke="#2a2f3f" stroke-width="1.3"/><line x1="40" y1="25" x2="40" y2="105" stroke="#2a2f3f" stroke-width="1.3"/><path d="M40 105 L300 25" stroke="#2a2f3f" stroke-width="1" stroke-dasharray="3 2"/><path d="M40 105 C 70 40, 130 25, 300 25 L300 105 Z" fill="#3b82f6" opacity="0.25"/><path d="M40 105 C 70 40, 130 25, 300 25" fill="none" stroke="#60a5fa" stroke-width="1.8"/><text x="270" y="115" fill="#8892a4" font-size="8.5">偽陽性率</text><text x="20" y="30" fill="#8892a4" font-size="8.5">真陽性率</text><text x="170" y="60" fill="#60a5fa" font-size="9" text-anchor="middle">AUC（面積）</text></svg>', 'why_asked', 'ROCとAUCは分類モデルの性能評価で頻出のペア。閾値を変えたときの挙動を正しく理解しているかを問う。')
WHERE q.source_ref = 'g-kentei-q43'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '営業秘密（不正競争防止法）は著作権法・特許法と並ぶ知財分野の頻出項目。保護対象の違いを問う。')
WHERE q.source_ref = 'g-kentei-q45'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '敵対的サンプルはAIの安全性・セキュリティ分野の頻出テーマ。人には気づけない微小な変化という点がポイント。')
WHERE q.source_ref = 'g-kentei-q47'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '説明可能なAI（XAI）はAIガバナンス分野で重視される頻出テーマ。ブラックボックス問題とセットで出る。')
WHERE q.source_ref = 'g-kentei-q48'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'ディープフェイクは生成AIの悪用事例として近年出題が増えている頻出テーマ。')
WHERE q.source_ref = 'g-kentei-q49'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'フィルターバブルはアルゴリズムが引き起こす社会的な問題として頻出。エコーチェンバーとの違いも意識される。')
WHERE q.source_ref = 'g-kentei-q50'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', '<svg viewBox="0 0 340 134" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif"><text x="170" y="14" fill="#e8eaf0" font-size="11" text-anchor="middle" font-weight="600">境界からの余白(マージン)が一番広い線を選ぶ</text><circle cx="60" cy="40" r="4" fill="#60a5fa"/><circle cx="90" cy="60" r="4" fill="#60a5fa"/><circle cx="50" cy="75" r="4" fill="#60a5fa"/><circle cx="100" cy="35" r="4" fill="#60a5fa"/><circle cx="260" cy="45" r="4" fill="#c9a04a"/><circle cx="290" cy="65" r="4" fill="#c9a04a"/><circle cx="250" cy="80" r="4" fill="#c9a04a"/><circle cx="300" cy="35" r="4" fill="#c9a04a"/><line x1="150" y1="20" x2="200" y2="110" stroke="#6ab08d" stroke-width="1.8"/><line x1="130" y1="20" x2="180" y2="110" stroke="#2a2f3f" stroke-dasharray="3 2"/><line x1="170" y1="20" x2="220" y2="110" stroke="#2a2f3f" stroke-dasharray="3 2"/><text x="170" y="120" fill="#6ab08d" font-size="9" text-anchor="middle">両側の点から最も遠い境界＝未知データに強い</text></svg>')
WHERE q.source_ref = 'g-kentei-q51'
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'g-kentei');

COMMIT;
