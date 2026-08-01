// 「コードの読み方」ガイドのデータ。このリポジトリ自体を教材に、
// 未知のコードベースを読む汎用の型を身につけてもらうための静的コンテンツ。
// mindset.ts と同じ思想（ハードコード・進捗DBなし・読み物として置く）。

export type CtSection = "map" | "trace" | "habit" | "practice";

export const SECTION_META: Record<CtSection, { label: string; color: string; caption: string }> = {
  map: { label: "全体地図", color: "#3b82f6", caption: "どこに何があるか" },
  trace: { label: "実例で追う", color: "#6ab08d", caption: "データはどう流れるか" },
  habit: { label: "読み方の作法", color: "#c9a04a", caption: "初見のコードにどう向き合うか" },
  practice: { label: "自分でやってみる", color: "#a855f7", caption: "予想してから答え合わせする" },
};

export interface CtExercise {
  id: string;
  title: string;
  task: string; // 実際にやってみる操作・課題
  reveal: string; // 答え合わせ（予想したあとに読む）
  files: string[];
}

// 読むだけでは「追える」ようにならない。予想を立ててから答え合わせする形で、
// 実際に手を動かす練習を別立てにする（ユウの要望「コードが追える知識を身に付けたい」、2026-08-02）。
export const CODE_TOUR_EXERCISES: CtExercise[] = [
  {
    id: "grep-practice",
    title: "grep で呼び出し元を実地に辿ってみる",
    task:
      "ターミナルで grep -rln \"examGroupKey\" src/features/quiz を実行する前に、何個のファイルがヒットしそうか予想を立てる（0個？1個？5個以上？）。予想してから実行して確かめる。",
    reveal:
      "実際は3ファイル（stats.ts / readiness.ts / exam-group.test.ts）。examGroupKeyは「同じ試験区分の複数セットを1つのキーに束ねる」関数で、苦手横断演習の土台。統計計算・合格確率モデル・テストという3つの離れた場所から呼ばれているとわかれば、この関数がどれだけ多くの機能の基盤になっているかが実感できる。",
    files: ["src/features/quiz/lib/stats.ts", "src/features/quiz/lib/readiness.ts", "src/features/quiz/lib/exam-group.test.ts"],
  },
  {
    id: "type-first",
    title: "型定義から先に画面を予想する",
    task:
      "src/features/quiz/lib/types.ts を開き、ExplanationData 型が持つフィールド（asked / point / kid / eg / terms / think / calc / snippet / vs / why_asked / usecase / opt）を確認する。開く前に、それぞれが解答画面のどのラベルに対応していそうか予想を書き出す。",
    reveal:
      "rich-explanation.tsx がこの型をそのまま描画している。asked→「何を問われているか」、point→「決め手」、kid→「ざっくり言うと」…という対応。型定義とUIラベルの日本語訳がほぼ1対1になっているのがこのアプリの特徴で、型を読むだけで画面の構成が読める。",
    files: ["src/features/quiz/lib/types.ts", "src/features/quiz/components/rich-explanation.tsx"],
  },
  {
    id: "test-summary",
    title: "テストだけ読んでモジュールの目的を一文にする",
    task:
      "fsrs.test.ts を開き、describe/it の英語だけを全部読む（実装コードは見ない）。読み終えたら、fsrs.ts が何を計算するモジュールか、自分の言葉で1文にまとめてみる。",
    reveal:
      "FSRS（Free Spaced Repetition Scheduler）という間隔反復アルゴリズムの実装。テストの並びから「採点(grade)→保持率(retrievability)→次回間隔(interval)→カード更新(review)」という一連の計算だと読み取れれば十分。実装の数式そのものを覚える必要はない。",
    files: ["src/features/quiz/lib/fsrs.test.ts", "src/features/quiz/lib/fsrs.ts"],
  },
  {
    id: "spot-the-difference",
    title: "同じ形に見える値の「由来の違い」を見抜く",
    task:
      "問題数選択のボタンは画面上「5 / 10 / 20 / 39」のように4つとも同じ種類の数字に見える。menu-screen.tsx を開いて、この4つの値が本当に全部同じ由来（固定値）かどうかを確認する。",
    reveal:
      "実際のコードは const countOptions = [5, 10, 20, eligible.length]。最初の3つは固定値だが、4つ目だけ「今出題できる問題の総数」を毎回計算した動的な値。画面に並んだ数字が全部「同じ種類」とは限らない、という読み方の癖を養う練習。",
    files: ["src/features/quiz/screens/menu-screen.tsx"],
  },
  {
    id: "commit-history",
    title: "コミット履歴から機能追加の順番を追体験する",
    task:
      "ターミナルで git log --oneline -15 を実行し、コミットメッセージだけを読む。このリポジトリがどんな順番で機能を足してきたか（問題集が先か、UI改善が先か等）を推測してみる。",
    reveal:
      "正解を当てることが目的ではない。コミットメッセージ自体が機能追加の履歴になっていると気づければ十分。気になったコミットがあれば git show <ハッシュの先頭7文字> で実際の差分を見る。「このコードはなぜこう書かれたか」の答えが、コード自体ではなくコミット履歴に残っていることは多い。",
    files: [],
  },
];

export interface CtTopic {
  id: string;
  section: CtSection;
  title: string;
  point: string; // 決め手・一言でいうと
  kid: string; // ざっくり言うと
  eg: string; // たとえると
  detail: string; // もう少し詳しく（thinkに相当）
  files: string[]; // このリポジトリの実例ファイル
  diagram: "hierarchy" | "folders" | "server-client" | "data-flow" | "feature-anatomy" | "supabase-clients" | "test-spec" | "unknown-flow";
}

export const CODE_TOUR_DATA: CtTopic[] = [
  {
    id: "hierarchy",
    section: "map",
    title: "このアプリの全体像は3層だけ",
    point: "subjects（試験区分）→ categories（分野）→ questions（問題）。これさえ分かれば全画面が読める。",
    kid: "G検定もDockerもGCPも、扱いは全部同じ3段の棚。棚の名前が違うだけで、仕組みは1つしかない。",
    eg: "本屋の「ジャンル（試験区分）→棚（分野）→本（問題）」の3段構成。新しいジャンルが増えても、棚と本の並べ方は変わらない。",
    detail:
      "画面や機能がどれだけ増えても、データの土台はこの3層から外れない。新しい試験区分を1つ追加したいときも「subjectsに1行、categoriesに数行、questionsに数十行」を足すだけで既存の画面（演習・分析・書き出し等）が全部そのまま動く。逆に言うと、新しい概念を追加するときにこの3層のどれにも当てはまらないなら、設計を疑ったほうがいい。",
    files: ["supabase/migrations/00001_initial_schema.sql", "src/features/quiz/lib/types.ts"],
    diagram: "hierarchy",
  },
  {
    id: "folders",
    section: "map",
    title: "app/ features/ shared/ の役割分担",
    point: "「1機能専用か、複数機能で使うか」で置き場所が決まる。",
    kid: "app/ はルーティングの入れ物、features/ は機能ごとの中身、shared/ はどこからも呼ばれる共通部品。",
    eg: "app/ が建物の各部屋の「扉」、features/ が各部屋の「家具一式」、shared/ が建物全体の「電気・水道」。",
    detail:
      "app/ 配下は Next.js のルーティング規約（page.tsx・layout.tsx）に従うための場所で、中身は薄く保つのが基本。実際のロジックは features/<機能名>/ に集約し、components・hooks・lib・screens の4部屋に分ける（次のトピックで詳しく扱う）。複数の機能から同時に使われるもの（Supabaseクライアント、共通ヘッダー等）だけが shared/ に上がる。初めて機能を追加するときは、まず features/ に自分の機能名フォルダを作るところから始めるとこの構造に馴染む。",
    files: ["src/app", "src/features", "src/shared"],
    diagram: "folders",
  },
  {
    id: "server-client",
    section: "map",
    title: "Server Component と Client Component の境界",
    point: "\"use client\" が無ければサーバー実行、あればブラウザ実行。境界を越えられるのは値だけ。",
    kid: "サーバー側で動く部品とブラウザ側で動く部品が混在している。ファイルの先頭を見れば、今どちらの世界にいるかがわかる。",
    eg: "サーバー側は厨房（お客からは見えない、DBという食材庫に直接アクセスできる）。クライアント側はホール（お客の目の前で動く、注文ボタンを押せる）。厨房から出せるのは完成した皿（値）だけで、包丁（関数）そのものは渡せない。",
    detail:
      "Next.js の App Router では、既定で全部が Server Component。onClick のようなブラウザ操作や useState のような状態管理が必要になった時点で、そのファイルの先頭に \"use client\" と書いて Client Component に切り替える。page.tsx がサーバーでデータを取得し、それを props として learning-app.tsx のようなクライアント側の入り口に渡す、という受け渡しの形が全体で繰り返される。DB接続やAPIキーのような機密はサーバー側に留めたまま、必要な値だけをクライアントへ渡すのがこの分離の狙い。",
    files: ["src/app/(main)/page.tsx", "src/app/(main)/learning-app.tsx"],
    diagram: "server-client",
  },
  {
    id: "data-flow",
    section: "trace",
    title: "「答えて正誤が出るまで」を1本の線で追う",
    point: "page.tsx→learning-app.tsx→use-quiz-session.ts→grading.ts→Supabase、の一直線。",
    kid: "問題に答えたときに裏で何が起きているかを、ファイルをまたいで最初から最後まで1本の線として追ってみる練習。",
    eg: "宅配便が「発送→中継所→中継所→配達」と拠点を渡り歩くのと同じ。1つの拠点だけ見ても全体の流れはわからないが、全部つなげると1本の道になる。",
    detail:
      "実際にこの並びで読むと迷いにくい: ① page.tsx（サーバー）が Supabase から問題一覧を取得する ② learning-app.tsx（クライアント）がその一覧を受け取り、どの画面を出すかの状態を持つ ③ use-quiz-session.ts というフックが「次にどの問題を出すか」「今の解答をどう記録するか」のロジックを担う ④ grading.ts が正誤判定そのものの純粋なロジック ⑤ 判定結果が Supabase の answer_events テーブルへ書き戻される。ファイルを開く前に、まず「これは①〜⑤のどの役割を担っているか」を予想してから読むと理解が早い。",
    files: [
      "src/app/(main)/page.tsx",
      "src/app/(main)/learning-app.tsx",
      "src/features/quiz/hooks/use-quiz-session.ts",
      "src/features/quiz/lib/grading.ts",
    ],
    diagram: "data-flow",
  },
  {
    id: "feature-anatomy",
    section: "trace",
    title: "features/quiz/ の中の4部屋",
    point: "screens は組み立て役、components は見た目、hooks は結線、lib は純粋ロジック。",
    kid: "1つの機能フォルダの中身は、いつも同じ4種類の部屋に分かれている。部屋の役割を知っていれば、初めて見るフォルダでも迷わない。",
    eg: "料理番組のスタジオ。lib は「レシピ（手順書、材料に依存しない）」、components は「食器や盛り付け道具」、hooks は「シェフの手（材料と道具をつなぐ）」、screens は「完成した1皿の盛り付け全体」。",
    detail:
      "lib/ は DB や画面の都合を知らない純粋な計算・型・ロジックの置き場（テストが書きやすい）。hooks/ はその lib のロジックと React の状態（useState等）を結びつける役割で、名前は use- から始まる。components/ は再利用可能な見た目の部品。screens/ はそれらを組み合わせて1つの画面を完成させる場所。依存の向きは screens → components・hooks → lib の一方通行が基本で、逆向き（lib が React の状態を知っている、など）は設計が壊れているサイン。",
    files: [
      "src/features/quiz/lib",
      "src/features/quiz/hooks",
      "src/features/quiz/components",
      "src/features/quiz/screens",
    ],
    diagram: "feature-anatomy",
  },
  {
    id: "supabase-clients",
    section: "trace",
    title: "client.ts と server.ts、なぜ2つあるか",
    point: "実行される場所（ブラウザ／サーバー）が違うので、Supabaseへの繋ぎ方も2種類ある。",
    kid: "同じSupabaseに話しかけるのに、ブラウザから話しかける窓口とサーバーから話しかける窓口が別々に用意されている。",
    eg: "同じ役所（Supabase）に、窓口A（オンライン申請＝client.ts）と窓口B（郵送申請＝server.ts）がある。どちらも最終的に同じ台帳を見るが、本人確認の方法（セッションの持ち方）が違う。",
    detail:
      "client.ts はブラウザで実行され、ブラウザのCookieに保存されたセッションをそのまま使う。server.ts はNext.jsのサーバー側で実行され、リクエストに乗ってきたCookieを読み取ってセッションを復元してからSupabaseに問い合わせる。実行される場所が違う以上、繋ぎ方の実装も分けざるを得ない。どちらを使うかは「今書いているファイルがServer ComponentかClient Componentか」で機械的に決まる。",
    files: ["src/shared/lib/supabase/client.ts", "src/shared/lib/supabase/server.ts"],
    diagram: "supabase-clients",
  },
  {
    id: "test-spec",
    section: "habit",
    title: "テストは仕様書として読む",
    point: "実装より先にテストを読むと、「このコードは何を保証したいか」が先にわかる。",
    kid: "*.test.ts ファイルの describe / it の文字列（このリポジトリでは英語）を眺めるだけで、そのモジュールの目的がだいたいつかめる。",
    eg: "商品の取扱説明書より先に、パッケージの「できること一覧」を読むようなもの。細かい実装を追う前に、そもそも何を約束しているコードなのかを知っておくと迷わない。",
    detail:
      "fsrs.test.ts や weak-review.test.ts のようなファイルは、describe/it の英語の文で「何を保証したいか」を1行ずつ列挙している（例: keeps difficulty within [1,10] and raises it on Again）。実装本体（fsrs.ts）をいきなり読むより、対応するテストファイルを先に開いたほうが「このコードが守ろうとしている境界条件」が先に頭に入り、実装を読んだときの理解が早い。逆に、テスト名が「tdd test for calcStreak」のように内容を語っていない・薄いコードは、仕様がまだ言葉になっていないということでもあり、変更するときに注意が要るサイン（streak.test.tsが実例）。",
    files: ["src/features/quiz/lib/fsrs.test.ts", "src/features/quiz/lib/weak-review.test.ts"],
    diagram: "test-spec",
  },
  {
    id: "unknown-flow",
    section: "habit",
    title: "わからないコードに出会ったときの動き方",
    point: "ファイルツリーを頭から読まない。grep→型→テスト→履歴→実行、の順で狭めていく。",
    kid: "初めて見るコードベースで迷子にならないための、いつでも使える5手順。このリポジトリに限らず、次の現場でもそのまま使える。",
    eg: "知らない街に着いたとき、地図を端から丸暗記する人はいない。まず目的地の名前で検索し、次に大通り（型）を確認し、案内板（テスト）を読み、最後に実際に歩いて（実行して）確かめる。",
    detail:
      "① 機能名・エラー文言・画面に表示される日本語文字列でリポジトリ全体をgrepし、当たりを付ける。② 出てきたファイルの型定義（types.ts）を見て「何のデータを扱っているか」を先に把握する。③ 対応する*.test.tsがあれば読む（前のトピック参照）。④ それでも「なぜこう書いたか」が謎なら git blame / git log -p でその行が追加されたコミットを見る（このリポジトリはmigrationやコミットメッセージに意図が残っていることが多い）。⑤ すべて試しても分からなければ、実際にnpm run devで動かしてconsole.logを挟んで確かめる。この順番自体が、次に読む未知のコードベースにもそのまま持ち込める型になる。",
    files: [],
    diagram: "unknown-flow",
  },
];
