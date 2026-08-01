// 「コードの読み方」ガイドのデータ。このリポジトリ自体を教材に、
// 未知のコードベースを読む汎用の型を身につけてもらうための静的コンテンツ。
// mindset.ts と同じ思想（ハードコード・進捗DBなし・読み物として置く）。

export type CtSection = "map" | "trace" | "habit";

export const SECTION_META: Record<CtSection, { label: string; color: string; caption: string }> = {
  map: { label: "全体地図", color: "#3b82f6", caption: "どこに何があるか" },
  trace: { label: "実例で追う", color: "#6ab08d", caption: "データはどう流れるか" },
  habit: { label: "読み方の作法", color: "#c9a04a", caption: "初見のコードにどう向き合うか" },
};

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
    kid: "*.test.ts ファイルのテスト名（日本語で書かれていることが多い）を眺めるだけで、そのモジュールの目的がだいたいつかめる。",
    eg: "商品の取扱説明書より先に、パッケージの「できること一覧」を読むようなもの。細かい実装を追う前に、そもそも何を約束しているコードなのかを知っておくと迷わない。",
    detail:
      "fsrs.test.ts や streak.test.ts のようなファイルは、日本語のテスト名で「〜のとき、〜になる」という仕様を1行ずつ列挙している。実装本体（fsrs.ts）をいきなり読むより、対応するテストファイルを先に開いたほうが「このコードが守ろうとしている境界条件」が先に頭に入り、実装を読んだときの理解が早い。逆に、テストが無い・薄いコードは仕様が言葉になっていないということでもあり、変更するときに注意が要るサインでもある。",
    files: ["src/features/quiz/lib/fsrs.test.ts", "src/features/quiz/lib/streak.test.ts"],
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
