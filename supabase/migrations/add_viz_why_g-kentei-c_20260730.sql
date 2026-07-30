BEGIN;
-- g-kentei-c: viz(仕組み系 18問) + why_asked(全50問) の非破壊マージ
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '強いAIと弱いAIの区別は頻出の対比。「賢く振る舞うこと」と「本当に意識を持つこと」を混同しやすいので狙われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q1';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'AIの能力段階(単純な制御・ルールベース・機械学習・特徴表現学習)の順序を問う定番テーマ。どこまで人が特徴を設計しているかで段階が変わる点が狙われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q2';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '記号接地問題やフレーム問題と並ぶAI思想史の頻出語。身体性と記号接地の違いを問う形で出やすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q3';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'モラベックのパラドックスは名前と内容が結びつきにくく、フレーム問題や組合せ爆発と混同されやすいので狙われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q4';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'MYCINとELIZAは初期AI史の定番ペア。対話を装うプログラムと診断を行うエキスパートシステムの違いが問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q5';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '探索アルゴリズムの基本語。総当たり(ブルートフォース)との対比で経験則の意味が問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q6';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'オントロジーは知識表現の章の頻出語。ただのデータベースとの違いが狙われやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q7';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '第五世代コンピュータ計画は日本のAI史の定番テーマ。ダートマス会議など年代の近い出来事と混同しやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q8';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'Watsonはクイズ番組での実績で知られる代表事例。AlphaGoやMYCINと並ぶ「AIの実績年表」として頻出。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q9';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'AlphaGoは第3次AIブームの象徴として繰り返し出題される。Deep Blueとの年代・手法の違いが狙われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q10';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '回帰と分類の区別は機械学習で最も頻出のペア。出力が数値かグループかで見分ける基本が問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q11';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '半教師あり学習は教師あり/教師なし/強化学習と並べて問われる。ラベル付けコストの文脈で出やすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q12';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '階層的クラスタリングとk-means法の違いは頻出の対比。グループ数を事前に決めるかどうかが分かれ目。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.5" text-anchor="middle" font-weight="600">近いものから順につないで樹形図にする</text>
<circle cx="40" cy="100" r="4" fill="#60a5fa"/><circle cx="70" cy="100" r="4" fill="#60a5fa"/>
<circle cx="120" cy="100" r="4" fill="#60a5fa"/><circle cx="150" cy="100" r="4" fill="#60a5fa"/>
<circle cx="220" cy="100" r="4" fill="#60a5fa"/><circle cx="250" cy="100" r="4" fill="#60a5fa"/>
<circle cx="290" cy="100" r="4" fill="#60a5fa"/>
<path d="M40 100 L40 76 L70 76 L70 100" fill="none" stroke="#8892a4"/>
<path d="M120 100 L120 76 L150 76 L150 100" fill="none" stroke="#8892a4"/>
<path d="M55 76 L55 56 L135 56 L135 76" fill="none" stroke="#8892a4"/>
<path d="M220 100 L220 82 L250 82 L250 100" fill="none" stroke="#8892a4"/>
<path d="M235 82 L235 64 L290 64 L290 100" fill="none" stroke="#8892a4"/>
<path d="M95 56 L95 34 L262 34 L262 64" fill="none" stroke="#3b82f6" stroke-width="1.6"/>
<text x="30" y="118" fill="#8892a4" font-size="8.5" text-anchor="middle">近い順に合流</text>
<text x="262" y="118" fill="#8892a4" font-size="8.5" text-anchor="middle">最後に全体が1つに</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q13';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 't-SNEは可視化に特化した次元削減手法として、PCAとの役割の違いを問う形で頻出。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">高次元でも近いものは近くに来るよう2次元に落とす</text>
<text x="80" y="34" fill="#8892a4" font-size="9" text-anchor="middle">高次元データ(数十項目)</text>
<circle cx="55" cy="60" r="3" fill="#60a5fa"/><circle cx="95" cy="52" r="3" fill="#c9a04a"/>
<circle cx="70" cy="80" r="3" fill="#6ab08d"/><circle cx="105" cy="90" r="3" fill="#60a5fa"/>
<circle cx="60" cy="100" r="3" fill="#c9a04a"/><circle cx="85" cy="66" r="3" fill="#6ab08d"/>
<circle cx="110" cy="60" r="3" fill="#60a5fa"/><circle cx="45" cy="85" r="3" fill="#6ab08d"/>
<path d="M135 76 L175 76" stroke="#e8eaf0" stroke-width="1.5" marker-end="url(#a)"/>
<polygon points="175,76 168,72 168,80" fill="#e8eaf0"/>
<text x="255" y="34" fill="#8892a4" font-size="9" text-anchor="middle">2次元の散布図</text>
<circle cx="220" cy="55" r="3.5" fill="#60a5fa"/><circle cx="228" cy="60" r="3.5" fill="#60a5fa"/><circle cx="215" cy="63" r="3.5" fill="#60a5fa"/>
<circle cx="270" cy="50" r="3.5" fill="#c9a04a"/><circle cx="278" cy="56" r="3.5" fill="#c9a04a"/>
<circle cx="245" cy="95" r="3.5" fill="#6ab08d"/><circle cx="255" cy="100" r="3.5" fill="#6ab08d"/><circle cx="238" cy="102" r="3.5" fill="#6ab08d"/>
<text x="255" y="120" fill="#e8eaf0" font-size="9.5" text-anchor="middle">かたまり(クラスタ)が目で見える</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q14';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'グリッドサーチはハイパーパラメータ探索の基本語。ランダムサーチとの違いも合わせて狙われやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q15';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'データリーケージは実務でも重要な落とし穴。訓練に合わせすぎる過学習と原因が違う点を問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q16';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'アンサンブル学習はバギング・ブースティングの上位概念として、用語の階層関係を問う定番。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">クセのある予測を集めて多数決すると安定する</text>
<line x1="20" y1="60" x2="150" y2="60" stroke="#2a2f3f"/>
<path d="M20 60 C40 40,60 75,80 50 C100 30,120 65,150 45" fill="none" stroke="#8892a4" stroke-width="1.2"/>
<path d="M20 65 C40 78,60 45,80 68 C100 85,120 50,150 62" fill="none" stroke="#8892a4" stroke-width="1.2"/>
<path d="M20 55 C40 70,60 55,80 40 C100 55,120 42,150 55" fill="none" stroke="#8892a4" stroke-width="1.2"/>
<text x="85" y="90" fill="#8892a4" font-size="8.5" text-anchor="middle">単体では間違えやすい</text>
<path d="M175 60 L215 60" stroke="#e8eaf0" stroke-width="1.5"/>
<polygon points="215,60 208,56 208,64" fill="#e8eaf0"/>
<text x="195" y="50" fill="#e8eaf0" font-size="9" text-anchor="middle">多数決・平均</text>
<line x1="235" y1="90" x2="320" y2="90" stroke="#2a2f3f"/>
<path d="M235 68 C260 55,290 62,320 55" fill="none" stroke="#3b82f6" stroke-width="2.2"/>
<text x="277" y="105" fill="#3b82f6" font-size="8.5" text-anchor="middle" font-weight="600">全体では安定して当たる</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q17';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '単純パーセプトロンの限界(XOR問題)は歴史的にも重要で、層を増やす意義を問う定番テーマ。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">1本の直線ではXORを分けられない</text>
<text x="85" y="26" fill="#8892a4" font-size="8" text-anchor="middle">単純パーセプトロン</text>
<rect x="30" y="30" width="110" height="80" fill="none" stroke="#2a2f3f"/>
<circle cx="45" cy="45" r="5" fill="#60a5fa"/><circle cx="125" cy="95" r="5" fill="#60a5fa"/>
<circle cx="125" cy="45" r="5" fill="#c9a04a"/><circle cx="45" cy="95" r="5" fill="#c9a04a"/>
<line x1="25" y1="70" x2="145" y2="70" stroke="#c47070" stroke-dasharray="3 3"/>
<text x="85" y="122" fill="#c47070" font-size="8.5" text-anchor="middle">直線1本では不可能</text>
<text x="250" y="26" fill="#8892a4" font-size="8" text-anchor="middle">多層パーセプトロン</text>
<rect x="195" y="30" width="110" height="80" fill="none" stroke="#2a2f3f"/>
<circle cx="210" cy="45" r="5" fill="#60a5fa"/><circle cx="290" cy="95" r="5" fill="#60a5fa"/>
<circle cx="290" cy="45" r="5" fill="#c9a04a"/><circle cx="210" cy="95" r="5" fill="#c9a04a"/>
<circle cx="210" cy="45" r="16" fill="none" stroke="#6ab08d" stroke-width="1.3" stroke-dasharray="3 2"/>
<circle cx="290" cy="95" r="16" fill="none" stroke="#6ab08d" stroke-width="1.3" stroke-dasharray="3 2"/>
<text x="250" y="122" fill="#6ab08d" font-size="8.5" text-anchor="middle">2つの区切りを組み合わせる</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q18';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '活性化関数の役割(非線形性)は、正則化・正規化・最適化といった別の工夫と混同されやすいので狙われる。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">活性化関数が無いと、層を重ねても直線のまま</text>
<line x1="30" y1="100" x2="150" y2="100" stroke="#2a2f3f"/>
<line x1="30" y1="30" x2="150" y2="100" stroke="#8892a4" stroke-width="1.6"/>
<text x="90" y="118" fill="#8892a4" font-size="8.5" text-anchor="middle">非線形性なし → まっすぐな関係</text>
<line x1="200" y1="100" x2="320" y2="100" stroke="#2a2f3f"/>
<path d="M200 95 C230 95,235 30,260 30 C285 30,290 95,320 90" fill="none" stroke="#3b82f6" stroke-width="1.8"/>
<text x="260" y="118" fill="#3b82f6" font-size="8.5" text-anchor="middle" font-weight="600">非線形性あり → 曲がった複雑な形</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q19';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'モメンタムはSGD→Adamの進化順で問われる頻出語。ドロップアウトなど別の工夫と混同しやすい。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">前回の勢いを引き継ぐと、揺れが減って速く進む</text>
<path d="M30 30 C60 90,100 100,130 108" fill="none" stroke="#2a2f3f" stroke-width="10" opacity="0.5"/>
<path d="M30 40 L45 55 L38 68 L52 80 L44 92 L60 100 L52 106 L70 110" fill="none" stroke="#8892a4" stroke-width="1.6"/>
<text x="90" y="126" fill="#8892a4" font-size="8.5" text-anchor="middle">勾配降下だけ: 左右に揺れて遅い</text>
<path d="M200 30 C230 90,270 100,300 108" fill="none" stroke="#2a2f3f" stroke-width="10" opacity="0.5"/>
<path d="M200 40 C220 60,250 90,300 106" fill="none" stroke="#3b82f6" stroke-width="1.8"/>
<text x="250" y="126" fill="#3b82f6" font-size="8.5" text-anchor="middle" font-weight="600">モメンタム: 揺れを抑え谷底へ速く進む</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q20';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '局所最適解と大域最適解の違いは最適化の基本対比として頻出。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">まわりより低いだけの「偽の底」に、はまり込む</text>
<path d="M20 60 C60 55,70 85,100 88 C130 90,140 60,170 30 C200 60,210 108,240 112 C270 108,290 65,320 60" fill="none" stroke="#8892a4" stroke-width="1.6"/>
<circle cx="100" cy="88" r="5" fill="#c47070"/>
<text x="100" y="104" fill="#c47070" font-size="9" text-anchor="middle" font-weight="600">局所最適解</text>
<text x="100" y="114" fill="#c47070" font-size="8" text-anchor="middle">「底だ」と勘違いして停止</text>
<circle cx="240" cy="112" r="5" fill="#6ab08d"/>
<text x="240" y="128" fill="#6ab08d" font-size="9" text-anchor="middle" font-weight="600">大域最適解(本当の最小)</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q21';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '勾配クリッピングは勾配爆発への対策。勾配消失への対策(別物)と混同しやすいので狙われる。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">大きくなりすぎた勾配を、上限で頭打ちにする</text>
<line x1="30" y1="105" x2="150" y2="105" stroke="#2a2f3f"/>
<line x1="30" y1="40" x2="150" y2="40" stroke="#c47070" stroke-dasharray="3 3"/>
<path d="M40 105 L55 100 L70 60 L85 15 L100 90 L115 95 L130 88" fill="none" stroke="#c47070" stroke-width="1.6"/>
<text x="85" y="122" fill="#c47070" font-size="8.5" text-anchor="middle">クリッピングなし: 値が跳ね上がり発散</text>
<line x1="200" y1="105" x2="320" y2="105" stroke="#2a2f3f"/>
<line x1="200" y1="60" x2="320" y2="60" stroke="#c9a04a" stroke-dasharray="3 3"/>
<text x="316" y="56" fill="#c9a04a" font-size="8" text-anchor="end">上限</text>
<path d="M210 105 L225 100 L240 60 L255 60 L270 90 L285 95 L300 88" fill="none" stroke="#6ab08d" stroke-width="1.8"/>
<text x="255" y="122" fill="#6ab08d" font-size="8.5" text-anchor="middle" font-weight="600">クリッピングあり: 上限で頭打ち</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q22';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'ハイパーパラメータとパラメータ(重み)の違いは超頻出の対比。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q23';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '変分オートエンコーダはGANと並ぶ生成モデルの代表で、仕組みの違いを問う形で頻出。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">特徴を「1点」でなく「確率のばらつき」として覚える</text>
<rect x="20" y="45" width="55" height="40" rx="5" fill="none" stroke="#8892a4"/>
<text x="47" y="68" fill="#e8eaf0" font-size="9" text-anchor="middle">入力</text>
<line x1="75" y1="65" x2="115" y2="65" stroke="#8892a4"/>
<ellipse cx="150" cy="65" rx="35" ry="24" fill="#3b82f6" opacity="0.18" stroke="#3b82f6"/>
<circle cx="150" cy="65" r="3" fill="#60a5fa"/>
<text x="150" y="100" fill="#60a5fa" font-size="8.5" text-anchor="middle">平均＋ばらつき(分布)</text>
<circle cx="163" cy="58" r="3" fill="#6ab08d"/>
<line x1="185" y1="65" x2="225" y2="65" stroke="#8892a4"/>
<text x="205" y="58" fill="#8892a4" font-size="8" text-anchor="middle">分布からサンプル</text>
<rect x="225" y="45" width="90" height="40" rx="5" fill="none" stroke="#6ab08d"/>
<text x="270" y="68" fill="#e8eaf0" font-size="9" text-anchor="middle">新しいデータを生成</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q24';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'ストライドとパディングは畳み込みの基本設定として対で問われる定番。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">ずらす幅(ストライド)が大きいほど出力は小さくなる</text>
<g>
<rect x="20" y="30" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="36" y="30" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="52" y="30" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="68" y="30" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="20" y="46" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="36" y="46" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="52" y="46" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="68" y="46" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="20" y="30" width="32" height="32" fill="none" stroke="#3b82f6" stroke-width="1.8"/>
<rect x="52" y="30" width="32" height="32" fill="none" stroke="#60a5fa" stroke-width="1.8" opacity="0.7"/>
</g>
<text x="70" y="78" fill="#8892a4" font-size="8" text-anchor="middle">ストライド=2: 1マスおきに移動</text>
<text x="55" y="90" fill="#e8eaf0" font-size="8.5" text-anchor="middle" font-weight="600">出力: 2×2</text>
<g>
<rect x="190" y="30" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="206" y="30" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="222" y="30" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="238" y="30" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="190" y="46" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="206" y="46" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="222" y="46" width="16" height="16" fill="none" stroke="#8892a4"/><rect x="238" y="46" width="16" height="16" fill="none" stroke="#8892a4"/>
<rect x="190" y="30" width="32" height="32" fill="none" stroke="#3b82f6" stroke-width="1.8"/>
<rect x="206" y="30" width="32" height="32" fill="none" stroke="#60a5fa" stroke-width="1.8" opacity="0.7"/>
</g>
<text x="222" y="78" fill="#8892a4" font-size="8" text-anchor="middle">ストライド=1: 1マスずつ移動</text>
<text x="222" y="90" fill="#e8eaf0" font-size="8.5" text-anchor="middle" font-weight="600">出力: 3×3(より大きい)</text>
<text x="170" y="112" fill="#e8eaf0" font-size="9" text-anchor="middle">幅を広げる→通る回数が減る→出力が縮む</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q25';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'パディングとストライドの対比は上記と同様のテーマで、逆方向から問われることが多い。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">外側に余白(0)を足して、端の情報とサイズを守る</text>
<g transform="translate(60,30)">
<rect x="0" y="0" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="18" y="0" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="36" y="0" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="54" y="0" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="72" y="0" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="0" y="18" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="72" y="18" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="0" y="36" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="72" y="36" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="0" y="54" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="18" y="54" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="36" y="54" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="54" y="54" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="72" y="54" width="18" height="18" fill="#c9a04a" opacity="0.25" stroke="#2a2f3f"/>
<rect x="18" y="18" width="18" height="18" fill="#3b82f6" opacity="0.35" stroke="#8892a4"/>
<rect x="36" y="18" width="18" height="18" fill="#3b82f6" opacity="0.35" stroke="#8892a4"/>
<rect x="54" y="18" width="18" height="18" fill="#3b82f6" opacity="0.35" stroke="#8892a4"/>
<rect x="18" y="36" width="18" height="18" fill="#3b82f6" opacity="0.35" stroke="#8892a4"/>
<rect x="36" y="36" width="18" height="18" fill="#3b82f6" opacity="0.35" stroke="#8892a4"/>
<rect x="54" y="36" width="18" height="18" fill="#3b82f6" opacity="0.35" stroke="#8892a4"/>
<rect x="9" y="9" width="18" height="18" fill="none" stroke="#6ab08d" stroke-width="1.8"/>
</g>
<text x="170" y="112" fill="#c9a04a" font-size="8.5" text-anchor="middle">外側の帯がパディング(余白)</text>
<text x="170" y="124" fill="#6ab08d" font-size="8.5" text-anchor="middle">端も同じ回数フィルタが通る</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q26';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'エンコーダ・デコーダはオートエンコーダと名前も構造も似ており混同されやすいので狙われる。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">入力を意味のベクトルに凝縮し、別の系列を作る</text>
<rect x="15" y="45" width="90" height="34" rx="5" fill="none" stroke="#8892a4"/>
<text x="60" y="66" fill="#e8eaf0" font-size="9" text-anchor="middle">入力の系列(原文)</text>
<text x="60" y="30" fill="#8892a4" font-size="8" text-anchor="middle">エンコーダ(前半)</text>
<line x1="105" y1="62" x2="140" y2="62" stroke="#8892a4"/>
<circle cx="170" cy="62" r="20" fill="#3b82f6" opacity="0.25" stroke="#3b82f6"/>
<text x="170" y="66" fill="#60a5fa" font-size="8.5" text-anchor="middle">意味の</text>
<text x="170" y="76" fill="#60a5fa" font-size="8.5" text-anchor="middle">ベクトル</text>
<line x1="200" y1="62" x2="235" y2="62" stroke="#8892a4"/>
<rect x="235" y="45" width="90" height="34" rx="5" fill="none" stroke="#6ab08d"/>
<text x="280" y="66" fill="#e8eaf0" font-size="9" text-anchor="middle">別の系列(訳文)</text>
<text x="280" y="30" fill="#8892a4" font-size="8" text-anchor="middle">デコーダ(後半)</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q27';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '双方向RNNは単方向RNNとの対比で、前後どちらの文脈を使えるかを問う頻出テーマ。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">前からと後ろから、両方向で文脈を読む</text>
<circle cx="60" cy="55" r="12" fill="none" stroke="#8892a4"/><circle cx="130" cy="55" r="12" fill="none" stroke="#8892a4"/>
<circle cx="200" cy="55" r="12" fill="none" stroke="#8892a4"/><circle cx="270" cy="55" r="12" fill="none" stroke="#8892a4"/>
<path d="M72 50 L118 50" stroke="#3b82f6" stroke-width="1.4"/><polygon points="118,50 111,46 111,54" fill="#3b82f6"/>
<path d="M142 50 L188 50" stroke="#3b82f6" stroke-width="1.4"/><polygon points="188,50 181,46 181,54" fill="#3b82f6"/>
<path d="M212 50 L258 50" stroke="#3b82f6" stroke-width="1.4"/><polygon points="258,50 251,46 251,54" fill="#3b82f6"/>
<path d="M258 62 L212 62" stroke="#6ab08d" stroke-width="1.4"/><polygon points="212,62 219,58 219,66" fill="#6ab08d"/>
<path d="M188 62 L142 62" stroke="#6ab08d" stroke-width="1.4"/><polygon points="142,62 149,58 149,66" fill="#6ab08d"/>
<path d="M118 62 L72 62" stroke="#6ab08d" stroke-width="1.4"/><polygon points="72,62 79,58 79,66" fill="#6ab08d"/>
<text x="60" y="90" fill="#8892a4" font-size="8.5" text-anchor="middle">単語1</text><text x="130" y="90" fill="#8892a4" font-size="8.5" text-anchor="middle">単語2</text>
<text x="200" y="90" fill="#8892a4" font-size="8.5" text-anchor="middle">単語3</text><text x="270" y="90" fill="#8892a4" font-size="8.5" text-anchor="middle">単語4</text>
<text x="90" y="112" fill="#3b82f6" font-size="8.5" text-anchor="middle">前から読む</text>
<text x="240" y="126" fill="#6ab08d" font-size="8.5" text-anchor="middle">後ろから読む</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q28';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '位置エンコーディングはTransformerの仕組みの中でも「なぜ必要か」がよく問われる。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">失われる語順を、位置の情報で補ってあげる</text>
<rect x="30" y="35" width="46" height="24" rx="4" fill="none" stroke="#8892a4"/><text x="53" y="51" fill="#e8eaf0" font-size="8.5" text-anchor="middle">単語A</text>
<rect x="90" y="35" width="46" height="24" rx="4" fill="none" stroke="#8892a4"/><text x="113" y="51" fill="#e8eaf0" font-size="8.5" text-anchor="middle">単語B</text>
<rect x="150" y="35" width="46" height="24" rx="4" fill="none" stroke="#8892a4"/><text x="173" y="51" fill="#e8eaf0" font-size="8.5" text-anchor="middle">単語C</text>
<circle cx="53" cy="26" r="9" fill="#c9a04a" opacity="0.8"/><text x="53" y="29" fill="#1a1a1a" font-size="8" text-anchor="middle" font-weight="700">1</text>
<circle cx="113" cy="26" r="9" fill="#c9a04a" opacity="0.8"/><text x="113" y="29" fill="#1a1a1a" font-size="8" text-anchor="middle" font-weight="700">2</text>
<circle cx="173" cy="26" r="9" fill="#c9a04a" opacity="0.8"/><text x="173" y="29" fill="#1a1a1a" font-size="8" text-anchor="middle" font-weight="700">3</text>
<line x1="113" y1="59" x2="113" y2="80" stroke="#8892a4"/>
<polygon points="113,80 109,73 117,73" fill="#8892a4"/>
<rect x="70" y="80" width="150" height="30" rx="5" fill="none" stroke="#3b82f6"/>
<text x="145" y="99" fill="#60a5fa" font-size="9" text-anchor="middle">Transformer(一度にまとめて処理)</text>
<text x="170" y="126" fill="#8892a4" font-size="8.5" text-anchor="middle">番号の札が無いと、まとめて渡した瞬間に順番が消える</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q29';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '姿勢推定は物体検出・画像分類と出力の違いで区別される、応用タスクの定番。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q30';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'インスタンスセグメンテーションとセマンティックセグメンテーションの違いは頻出の対比。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q31';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'ニューラル機械翻訳はルールベース翻訳との違いで、翻訳手法の進化を問う定番テーマ。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q32';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '画像キャプション生成は他の画像応用タスクと並べて出力の違いを問われやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q33';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '感情分析は自然言語処理タスクの一覧の中で定義を問われる頻出語。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q34';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '異常検知は分類や外れ値の考え方と絡めて問われやすいテーマ。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q35';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'RLHFは生成AI関連で近年出題が増えている語。事前学習との段階の違いが問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q36';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '特徴量エンジニアリングはAIプロジェクトの工程の中で、前処理やデプロイなど他工程と区別して問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q37';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'コンセプトドリフトは運用後に精度が落ちる原因。学習時の問題である過学習と対比されやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q38';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'オープンデータはデータの収集・共有の枠組みとして、関連用語と対比される形で問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q39';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'クラス不均衡と正解率の落とし穴は評価指標の最頻出テーマ。数字が実力以上に見えるため誤解されやすい。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">全員「陰性」と答えても、正解率は99%になる</text>
<text x="130" y="27" fill="#8892a4" font-size="8" text-anchor="middle">陽性予測</text>
<text x="210" y="27" fill="#8892a4" font-size="8" text-anchor="middle">陰性予測</text>
<rect x="90" y="30" width="80" height="34" fill="#2a2f3f" stroke="#8892a4"/>
<text x="130" y="47" fill="#e8eaf0" font-size="8" text-anchor="middle">0人</text>
<text x="130" y="59" fill="#e8eaf0" font-size="8" text-anchor="middle">(FP)</text>
<rect x="170" y="30" width="80" height="34" fill="#6ab08d" opacity="0.35" stroke="#8892a4"/>
<text x="210" y="47" fill="#e8eaf0" font-size="8.5" text-anchor="middle">99人 正解</text>
<text x="210" y="59" fill="#e8eaf0" font-size="8" text-anchor="middle">(TN)</text>
<rect x="90" y="64" width="80" height="34" fill="#2a2f3f" stroke="#8892a4"/>
<text x="130" y="81" fill="#e8eaf0" font-size="8" text-anchor="middle">0人</text>
<text x="130" y="93" fill="#e8eaf0" font-size="8" text-anchor="middle">(TP)</text>
<rect x="170" y="64" width="80" height="34" fill="#c47070" opacity="0.35" stroke="#8892a4"/>
<text x="210" y="81" fill="#e8eaf0" font-size="8.5" text-anchor="middle">1人 見逃し</text>
<text x="210" y="93" fill="#e8eaf0" font-size="8" text-anchor="middle">(FN)</text>
<text x="65" y="47" fill="#8892a4" font-size="8" text-anchor="middle">実際は</text>
<text x="65" y="58" fill="#8892a4" font-size="8" text-anchor="middle">陰性</text>
<text x="65" y="81" fill="#8892a4" font-size="8" text-anchor="middle">実際は</text>
<text x="65" y="92" fill="#8892a4" font-size="8" text-anchor="middle">陽性</text>
<text x="210" y="112" fill="#c9a04a" font-size="9" text-anchor="middle" font-weight="600">病気を1人も見つけられていない</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q40';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '標準偏差は基礎統計の最頻出語で、中央値や最頻値との役割の違いが問われる。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">平均からの散らばりの大きさを1つの数でまとめる</text>
<line x1="30" y1="80" x2="310" y2="80" stroke="#2a2f3f"/>
<line x1="170" y1="30" x2="170" y2="80" stroke="#c9a04a" stroke-dasharray="3 3"/>
<text x="170" y="24" fill="#c9a04a" font-size="9" text-anchor="middle">平均</text>
<circle cx="90" cy="80" r="4" fill="#60a5fa"/><circle cx="130" cy="80" r="4" fill="#60a5fa"/>
<circle cx="210" cy="80" r="4" fill="#60a5fa"/><circle cx="255" cy="80" r="4" fill="#60a5fa"/>
<path d="M90 66 L170 66" stroke="#6ab08d" stroke-width="1.3"/>
<path d="M255 66 L170 66" stroke="#6ab08d" stroke-width="1.3" transform="translate(0,14)"/>
<text x="130" y="60" fill="#6ab08d" font-size="8" text-anchor="middle">平均との差</text>
<text x="170" y="108" fill="#e8eaf0" font-size="9.5" text-anchor="middle">差を2乗して平均し、√で戻したのが標準偏差</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q41';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'ベイズの定理は検査の的中率など「直感に反する確率」の題材でよく出題される。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="14" fill="#e8eaf0" font-size="10" text-anchor="middle" font-weight="600">新しい証拠が入るたび、確率を計算し直す</text>
<text x="170" y="32" fill="#8892a4" font-size="8.5" text-anchor="middle">最初の見込み(事前確率)</text>
<rect x="30" y="38" width="280" height="18" fill="#2a2f3f"/>
<rect x="30" y="38" width="10" height="18" fill="#60a5fa"/>
<text x="170" y="72" fill="#8892a4" font-size="8.5" text-anchor="middle">検査結果が陽性と出た(新しい証拠)</text>
<rect x="30" y="78" width="280" height="18" fill="#2a2f3f"/>
<rect x="30" y="78" width="160" height="18" fill="#3b82f6"/>
<text x="170" y="110" fill="#e8eaf0" font-size="8.5" text-anchor="middle" font-weight="600">更新後(事後確率)は大きく変わる</text>
<text x="170" y="126" fill="#60a5fa" font-size="9" text-anchor="middle">これがベイズの定理の考え方</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q42';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '相関係数は因果関係と混同されやすく、範囲(-1〜1)や意味を問う形で頻出。', 'viz', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
<text x="170" y="16" fill="#e8eaf0" font-size="10.3" text-anchor="middle" font-weight="600">直線的な関係の強さと向きを-1〜+1で表す</text>
<line x1="34" y1="30" x2="34" y2="98" stroke="#2a2f3f"/><line x1="34" y1="98" x2="150" y2="98" stroke="#2a2f3f"/>
<circle cx="50" cy="88" r="3" fill="#60a5fa"/><circle cx="65" cy="80" r="3" fill="#60a5fa"/><circle cx="80" cy="70" r="3" fill="#60a5fa"/>
<circle cx="95" cy="60" r="3" fill="#60a5fa"/><circle cx="110" cy="50" r="3" fill="#60a5fa"/><circle cx="125" cy="42" r="3" fill="#60a5fa"/>
<line x1="45" y1="92" x2="135" y2="38" stroke="#3b82f6" stroke-width="1.6"/>
<text x="90" y="112" fill="#3b82f6" font-size="8.5" text-anchor="middle" font-weight="600">正の相関(+1に近い)</text>
<line x1="204" y1="30" x2="204" y2="98" stroke="#2a2f3f"/><line x1="204" y1="98" x2="320" y2="98" stroke="#2a2f3f"/>
<circle cx="220" cy="42" r="3" fill="#c9a04a"/><circle cx="235" cy="50" r="3" fill="#c9a04a"/><circle cx="250" cy="60" r="3" fill="#c9a04a"/>
<circle cx="265" cy="70" r="3" fill="#c9a04a"/><circle cx="280" cy="80" r="3" fill="#c9a04a"/><circle cx="295" cy="88" r="3" fill="#c9a04a"/>
<line x1="215" y1="38" x2="305" y2="92" stroke="#c9a04a" stroke-width="1.6"/>
<text x="260" y="112" fill="#c9a04a" font-size="8.5" text-anchor="middle" font-weight="600">負の相関(-1に近い)</text>
</svg>') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q43';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '生成AIの著作権は近年の改訂で重要度が増した論点。断定的な選択肢に引っかかりやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q44';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '限定提供データは営業秘密との違いが問われる、不正競争防止法の頻出語。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q45';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '引用の要件は著作権法の頻出テーマで、私的複製など似た概念との違いが問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q46';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'ハルシネーションは生成AIの代表的な課題語。ディープフェイクなど類似語と混同しやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q47';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'トロッコ問題はAI倫理の思考実験として頻出。中国語の部屋など他の思考実験と混同しやすい。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q48';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', 'AI事業者ガイドラインは法律・倫理カテゴリの頻出指針。上位の原則(人間中心のAI社会原則)との違いが問われる。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q49';
UPDATE public.questions q SET explanation_data = q.explanation_data || jsonb_build_object('why_asked', '大規模モデルの環境負荷は近年の倫理的論点として出題増加が指摘されているテーマ。') FROM public.subjects s WHERE q.subject_id = s.id AND s.slug = 'g-kentei-c' AND q.source_ref = 'g-kentei-c-q50';

COMMIT;
