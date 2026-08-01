// コードの読み方ガイド専用の図解。DB由来のviz(SVG文字列)とは別物で、
// 静的コンテンツなのでJSXのSVGとして直接書く。配色はquestion-authoringのviz規約と揃える
// （muted #8892a4 / fg #e8eaf0 / accent #3b82f6・#60a5fa / green #6ab08d / red #c47070 / amber #c9a04a）。

const MUTED = "#8892a4";
const FG = "#e8eaf0";
const ACCENT = "#3b82f6";
const ACCENT2 = "#60a5fa";
const LINE = "#2a2f3f";
const GREEN = "#6ab08d";
const AMBER = "#c9a04a";

function Box({
  x,
  y,
  w,
  h,
  stroke = LINE,
  fill = "#1a1e29",
}: {
  x: number;
  y: number;
  w: number;
  h: number;
  stroke?: string;
  fill?: string;
}) {
  return <rect x={x} y={y} width={w} height={h} rx={4} fill={fill} stroke={stroke} strokeWidth={1} />;
}

function T({
  x,
  y,
  children,
  size = 8,
  fill = MUTED,
  weight = "normal",
  anchor = "middle",
}: {
  x: number;
  y: number;
  children: React.ReactNode;
  size?: number;
  fill?: string;
  weight?: string;
  anchor?: "start" | "middle" | "end";
}) {
  return (
    <text x={x} y={y} fontSize={size} fill={fill} fontWeight={weight} textAnchor={anchor}>
      {children}
    </text>
  );
}

export function DiagramHierarchy() {
  return (
    <svg viewBox="0 0 340 168" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={10} fill={FG} weight="600">
        subjects → categories → questions
      </T>
      <Box x={110} y={26} w={120} h={26} stroke={ACCENT} fill="#20263a" />
      <T x={170} y={43} size={9} fill={ACCENT2} weight="600">
        subjects（試験区分）
      </T>
      <line x1={170} y1={52} x2={170} y2={64} stroke={LINE} strokeWidth={1} />
      <Box x={60} y={66} w={220} h={26} stroke={ACCENT} fill="#1a1e29" />
      <T x={170} y={83} size={9} fill={MUTED}>
        categories（分野）× 複数
      </T>
      <line x1={170} y1={92} x2={170} y2={104} stroke={LINE} strokeWidth={1} />
      <Box x={20} y={106} w={300} h={30} stroke={GREEN} fill="#232a1f" />
      <T x={170} y={124} size={9} fill={GREEN}>
        questions（問題）× さらに複数
      </T>
      <T x={170} y={155} size={8} fill={MUTED}>
        DCA・G検定・GCPなど「試験区分」はすべてこの3層に載る
      </T>
    </svg>
  );
}

export function DiagramFolders() {
  return (
    <svg viewBox="0 0 340 190" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={9.5} fill={FG} weight="600">
        3つのフォルダの役割分担
      </T>
      <Box x={10} y={28} w={100} h={70} stroke={ACCENT} />
      <T x={60} y={42} size={8.5} fill={ACCENT2} weight="600">
        app/
      </T>
      <T x={60} y={56} size={7} fill={MUTED}>
        ルーティングと
      </T>
      <T x={60} y={67} size={7} fill={MUTED}>
        画面の入れ物
      </T>
      <T x={60} y={82} size={6.5} fill={MUTED}>
        page.tsx / layout.tsx
      </T>
      <T x={60} y={92} size={6.5} fill={MUTED}>
        なるべく薄く保つ
      </T>

      <Box x={120} y={28} w={100} h={70} stroke={GREEN} />
      <T x={170} y={42} size={8.5} fill={GREEN} weight="600">
        features/
      </T>
      <T x={170} y={56} size={7} fill={MUTED}>
        機能ごとの
      </T>
      <T x={170} y={67} size={7} fill={MUTED}>
        ロジックの塊
      </T>
      <T x={170} y={82} size={6.5} fill={MUTED}>
        quiz/ flashcards/ ...
      </T>
      <T x={170} y={92} size={6.5} fill={MUTED}>
        中身が一番濃い</T>

      <Box x={230} y={28} w={100} h={70} stroke={AMBER} />
      <T x={280} y={42} size={8.5} fill={AMBER} weight="600">
        shared/
      </T>
      <T x={280} y={56} size={7} fill={MUTED}>
        どの機能からも
      </T>
      <T x={280} y={67} size={7} fill={MUTED}>
        呼ばれる共通部品
      </T>
      <T x={280} y={82} size={6.5} fill={MUTED}>
        supabaseクライアント
      </T>
      <T x={280} y={92} size={6.5} fill={MUTED}>
        共通ヘッダー等
      </T>

      <line x1={110} y1={63} x2={120} y2={63} stroke={LINE} strokeWidth={1.2} />
      <line x1={220} y1={63} x2={230} y2={63} stroke={LINE} strokeWidth={1.2} />
      <T x={170} y={114} size={7.5} fill={AMBER}>
        参照する向きは app/ → features/ → shared/ の一方通行が基本
      </T>
      <T x={170} y={140} size={8} fill={MUTED}>
        迷ったら「これは1機能専用か、複数機能で使うか」で判断する。
      </T>
      <T x={170} y={153} size={8} fill={MUTED}>
        1機能専用なら features/&lt;その機能&gt;/、複数で使うなら shared/。
      </T>
    </svg>
  );
}

export function DiagramServerClient() {
  return (
    <svg viewBox="0 0 340 178" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={9.3} fill={FG} weight="600">
        サーバーとブラウザ、実行される場所が違う
      </T>
      <T x={170} y={27} size={7} fill={AMBER}>
        props（値だけ）が右へ渡る
      </T>
      <Box x={15} y={34} w={140} h={68} stroke={ACCENT} fill="#20263a" />
      <T x={85} y={48} size={8.5} fill={ACCENT2} weight="600">
        Server Component
      </T>
      <T x={85} y={62} size={7} fill={MUTED}>
        「use client」が無い
      </T>
      <T x={85} y={73} size={7} fill={MUTED}>
        サーバーで実行される
      </T>
      <T x={85} y={84} size={7} fill={MUTED}>
        DBに直接アクセス可
      </T>
      <T x={85} y={95} size={7} fill={MUTED}>
        onClick は書けない
      </T>

      <line x1={155} y1={68} x2={185} y2={68} stroke={AMBER} strokeWidth={1.3} />

      <Box x={185} y={34} w={140} h={68} stroke={GREEN} fill="#232a1f" />
      <T x={255} y={48} size={8.5} fill={GREEN} weight="600">
        Client Component
      </T>
      <T x={255} y={62} size={7} fill={MUTED}>
        先頭に「use client」
      </T>
      <T x={255} y={73} size={7} fill={MUTED}>
        ブラウザで実行される
      </T>
      <T x={255} y={84} size={7} fill={MUTED}>
        onClick 等が使える
      </T>
      <T x={255} y={95} size={7} fill={MUTED}>
        DBには直接触れない
      </T>

      <T x={170} y={125} size={8} fill={MUTED}>
        境界を越えられるのは「シリアライズできる値」だけ。
      </T>
      <T x={170} y={138} size={8} fill={MUTED}>
        関数やDBの接続そのものはクライアント側へ渡せない。
      </T>
      <T x={170} y={161} size={8} fill={AMBER}>
        learning-app.tsx の先頭に「use client」 があるのはこのため
      </T>
    </svg>
  );
}

export function DiagramDataFlow() {
  const nodes = [
    { label: "page.tsx", sub: "サーバー: 問題を取得" },
    { label: "learning-app.tsx", sub: "クライアント: 状態管理" },
    { label: "use-quiz-session.ts", sub: "フック: 出題ロジック" },
    { label: "grading.ts", sub: "採点する" },
    { label: "Supabase", sub: "進捗を保存" },
  ];
  return (
    <svg viewBox="0 0 340 210" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={9} fill={FG} weight="600">
        「答えて正誤が出るまで」の一本道
      </T>
      {nodes.map((n, i) => {
        const y = 28 + i * 36;
        return (
          <g key={n.label}>
            <Box x={40} y={y} w={260} h={28} stroke={i === 4 ? GREEN : ACCENT} fill={i === 4 ? "#232a1f" : "#1a1e29"} />
            <T x={170} y={y + 12} size={8} fill={FG} weight="600">
              {n.label}
            </T>
            <T x={170} y={y + 23} size={6.5} fill={MUTED}>
              {n.sub}
            </T>
            {i < nodes.length - 1 && (
              <line x1={170} y1={y + 28} x2={170} y2={y + 36} stroke={LINE} strokeWidth={1.2} />
            )}
          </g>
        );
      })}
    </svg>
  );
}

export function DiagramFeatureAnatomy() {
  return (
    <svg viewBox="0 0 340 178" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={9.5} fill={FG} weight="600">
        features/&lt;機能&gt;/ の中の4部屋
      </T>
      {[
        { name: "screens/", desc: "画面まるごと。componentsを組み合わせる", color: ACCENT },
        { name: "components/", desc: "見た目のパーツ（ボタン等）", color: GREEN },
        { name: "hooks/", desc: "状態とロジックの結線（use-〜）", color: AMBER },
        { name: "lib/", desc: "純粋なロジック・型・計算（DB以外）", color: ACCENT2 },
      ].map((r, i) => {
        const y = 30 + i * 34;
        return (
          <g key={r.name}>
            <Box x={15} y={y} w={90} h={26} stroke={r.color} fill="#1a1e29" />
            <T x={60} y={y + 17} size={8} fill={r.color} weight="600">
              {r.name}
            </T>
            <Box x={115} y={y} w={210} h={26} stroke={LINE} />
            <T x={220} y={y + 17} size={7.5} fill={MUTED}>
              {r.desc}
            </T>
          </g>
        );
      })}
      <T x={170} y={168} size={7.5} fill={AMBER}>
        依存の向き: screens → components + hooks → lib（逆向きは書かない）
      </T>
    </svg>
  );
}

export function DiagramSupabaseClients() {
  return (
    <svg viewBox="0 0 340 168" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={9.5} fill={FG} weight="600">
        client.ts と server.ts、2つの窓口</T>
      <Box x={15} y={30} w={140} h={64} stroke={ACCENT} fill="#20263a" />
      <T x={85} y={44} size={8.5} fill={ACCENT2} weight="600">
        client.ts
      </T>
      <T x={85} y={58} size={7} fill={MUTED}>
        ブラウザで実行
      </T>
      <T x={85} y={69} size={7} fill={MUTED}>
        ユーザーのCookie/</T>
      <T x={85} y={80} size={7} fill={MUTED}>
        セッションで動く
      </T>

      <Box x={185} y={30} w={140} h={64} stroke={GREEN} fill="#232a1f" />
      <T x={255} y={44} size={8.5} fill={GREEN} weight="600">
        server.ts
      </T>
      <T x={255} y={58} size={7} fill={MUTED}>
        Next.jsのサーバーで実行
      </T>
      <T x={255} y={69} size={7} fill={MUTED}>
        Cookieを読んで
      </T>
      <T x={255} y={80} size={7} fill={MUTED}>
        セッションを復元
      </T>

      <line x1={85} y1={98} x2={85} y2={112} stroke={LINE} strokeWidth={1} />
      <line x1={255} y1={98} x2={255} y2={112} stroke={LINE} strokeWidth={1} />
      <Box x={90} y={114} w={160} h={24} stroke={AMBER} fill="#2a2416" />
      <T x={170} y={130} size={8} fill={AMBER}>
        同じSupabaseプロジェクト
      </T>
      <T x={170} y={153} size={8} fill={MUTED}>
        どちらもRLSで「本人のデータだけ」に絞られる
      </T>
    </svg>
  );
}

export function DiagramTestAsSpec() {
  return (
    <svg viewBox="0 0 340 165" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={9.5} fill={FG} weight="600">
        テスト名を読むだけで仕様がわかる
      </T>
      <Box x={20} y={28} w={300} h={30} stroke={ACCENT} fill="#1a1e29" />
      <T x={170} y={44} size={7.5} fill={ACCENT2}>
        test(同じ日に連続で解いてもストリークは1のまま)
      </T>
      <T x={170} y={56} size={6.5} fill={MUTED}>
        ↳ fsrs.test.ts / streak.test.ts の実例
      </T>
      <Box x={20} y={68} w={300} h={44} stroke={LINE} />
      <T x={170} y={84} size={7.5} fill={MUTED}>
        入力（既知の過去ログ）を用意する
      </T>
      <T x={170} y={98} size={7.5} fill={MUTED}>
        → 期待する出力と比べる、の繰り返し
      </T>
      <T x={170} y={126} size={8} fill={MUTED}>
        コード本体を読む前にテストファイルを読むと、
      </T>
      <T x={170} y={139} size={8} fill={MUTED}>
        「このモジュールが何を保証したいか」が先にわかる
      </T>
      <T x={170} y={155} size={7.5} fill={AMBER}>
        実装より先に、期待される振る舞いから読む
      </T>
    </svg>
  );
}

export function DiagramUnknownCodeFlow() {
  const steps = [
    "① grepで名前を探す（機能名・エラー文言・UIのラベル文字列）",
    "② types.ts で型を見る（何のデータを扱っているか）",
    "③ *.test.ts を見る（期待される振る舞い）",
    "④ git blame / git log -p でその行が「なぜ」書かれたかを見る",
    "⑤ それでも謎なら実際に動かし console.log で確かめる",
  ];
  return (
    <svg viewBox="0 0 340 208" xmlns="http://www.w3.org/2000/svg">
      <T x={170} y={14} size={9.5} fill={FG} weight="600">
        わからないコードに出会ったときの動き方
      </T>
      {steps.map((s, i) => {
        const y = 28 + i * 34;
        return (
          <g key={i}>
            <Box x={15} y={y} w={310} h={26} stroke={i === 0 ? ACCENT : LINE} fill={i === 0 ? "#20263a" : "#1a1e29"} />
            <T x={170} y={y + 16} size={7.3} fill={i === 0 ? ACCENT2 : MUTED}>
              {s}
            </T>
          </g>
        );
      })}
    </svg>
  );
}
