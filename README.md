# My Learning App

模試で間違えた問題を反復演習する、拡張可能な学習アプリ。
Next.js 16 + Supabase + Tailwind CSS v4。モバイル / Web 両対応。

`subjects`（科目）→ `categories`（分野）→ `questions`（問題）の階層で、
GCP（ACE / PCA / PCDE）、Docker（DCA）、Terraform Associate、G検定、GH-200、
ISTQB CTAL-TA、英語句動詞（Speak-First）など複数の試験区分の問題集を横断的に扱う。

## 主な機能

- **4択演習**: 解答後に正解と解説を表示。直近の自分の解答を記録
- **理解度フラグ**: 問題ごとに「全く分からない / 怪しい / だいたい理解 / 完璧」の4段階
- **メモ**: 問題ごとに気づきや自分の言葉での説明を保存
- **出題制御**: 問題数（5/10/20/全部）・分野選択・「シャッフル / 弱点優先」切替
  - 弱点優先 = 誤答回数の多い問題から出題
- **FSRS間隔反復**: 解答ログ（answer_events）から FSRS（Free Spaced Repetition Scheduler）で
  各問題の安定度・想起確率を計算し、復習タイミングを決める（`lib/quiz/fsrs.ts`）。
  過去の解答履歴からの一括バックフィル API（`/api/fsrs/backfill`）あり
- **弱点横断演習**: 同じ試験区分（例: GCP ACE の複数セット）の全問題を横断し、
  苦手な問題だけを抽出して演習（`lib/quiz/weak-review` 系ロジック、`examGroupKey` で束ねる）
- **苦手分析**: 分野別正答率 / 最重点問題ランキング / 理解度フラグ分布
- **合格確率モデル**: 試験日までの残り日数・現在の定着度・出題網羅率から、
  ポアソン二項分布で厳密に「今日時点の合格確率」を計算（`lib/quiz/readiness.ts`、機械学習は不使用）
- **目標設定**: 試験区分ごとに受験日・目標名を保存し、上記モデルに反映
- **教科書リンク**: 試験区分ごとに参考書・公式ドキュメントのリンクを保存（`user_textbooks`）
- **CSV書き出し**: 問題・解答・フラグ・メモを CSV ダウンロード（コピーも可）
- **単語カード（フラッシュカード）** (`/flashcards`): G検定・Docker・Cloud DevOps の3デッキ、
  293語。表は用語、裏はやさしい一言＋たとえ＋正確な定義の3層。DB（`user_term_progress`）と
  進捗を同期し、端末をまたいで学習済み/未学習が保たれる
- **学習ロードマップ** (`/roadmap`): フェーズ／マイルストーンを DB（`user_roadmap.doc` jsonb）に
  保存し、各自が編集可能。問題集にひも付けると進捗バーを表示
- **学習ログ** (`/log`): 解答イベントを日次カレンダー形式で可視化（曜日別・分野別・科目別の集計）
- **マインドセット** (`/mindset`): 逆算・回転数・アウトプット重視などの勉強法の思考フレームを、
  自分の現状に落とした行動として並べる静的コンテンツ
- すべての進捗を Supabase に保存し、端末をまたいで同期

## アーキテクチャ

```
src/
  proxy.ts                        # Supabase セッション更新 + 未認証は /login へ（旧 middleware）
  types/database.ts               # DB 型
  lib/supabase/{client,server,middleware}.ts
  lib/quiz/
    types.ts                      # 問題・進捗などの共通型
    selection.ts                  # 出題ロジック・間隔反復
    stats.ts                      # 習熟度スコア・分野別集計・examGroupKey・weak-review
    fsrs.ts                       # FSRS 間隔反復スケジューラ
    readiness.ts                  # 合格確率モデル（ポアソン二項分布）
    csv.ts                        # CSV書き出し
    *.test.ts                     # Vitest ユニットテスト
  lib/flashcards.ts                # フラッシュカードのデータ（3デッキ・ハードコード定数）
  lib/roadmap.ts                   # ロードマップのデータモデル
  lib/mindset.ts                   # マインドセットのデータモデル
  app/(auth)/{login,register}      # メール+パスワード認証
  app/(main)/page.tsx               # サーバーで問題+進捗（同一試験区分の全セット含む）を取得
  app/(main)/learning-app.tsx       # メニュー/演習/結果/分析/書き出し/目標の全画面（クライアント）
  app/(main)/flashcards/            # 単語カード画面
  app/(main)/roadmap/               # ロードマップ画面
  app/(main)/log/                   # 学習ログ画面
  app/(main)/mindset/               # マインドセット画面
  app/api/fsrs/backfill/route.ts    # 解答履歴から FSRS 状態を一括再構築するAPI
  components/header.tsx             # 共通ヘッダー
supabase/migrations/
  00001_initial_schema.sql        # テーブル + RLS + トリガ
  00002_seed_gcp_ace.sql          # GCP ACE 科目 + 分野 + 問題（以降 000xx で各試験区分・各セットを追加）
  ...                              # GCP PCA/PCDE、DCA、Terraform、G検定、GH-200、CTAL-TA、
                                    # 句動詞（pv-t*）などのシード・解説強化・修正マイグレーション
```

進捗は RLS（`auth.uid() = user_id`）で本人のみアクセス可。教材（科目・分野・問題）は全員読み取り可。

## セットアップ（ローカル開発）

1. 依存をインストール

   ```bash
   npm install
   ```

2. `.env.local` を作成（`.env.example` を参照）

   ```
   NEXT_PUBLIC_SUPABASE_URL=...
   NEXT_PUBLIC_SUPABASE_ANON_KEY=...
   ```

3. Supabase にスキーマとシードを適用（下記いずれか）

   - **Supabase ダッシュボード**: SQL Editor に `00001` → `00002` の順で貼り付けて実行
   - **Supabase CLI**: `supabase link --project-ref <ref>` のあと `supabase db push`
   - **ローカル CLI**: `supabase start`（Docker 必要）→ `supabase db reset`

4. 開発サーバー

   ```bash
   npm run dev
   ```

5. `/register` でアカウント作成 → ログイン

> メール確認: 個人利用なら Supabase の Authentication 設定で
> "Confirm email" をオフにすると登録後すぐ使える。

## 本番デプロイ（Vercel）

1. Supabase で新規プロジェクトを作成し、`00001` / `00002` を適用
2. このリポジトリを Vercel にインポート
3. Vercel の Environment Variables に以下を設定
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Deploy。Supabase の Authentication > URL Configuration に本番URLを追加

## 科目を追加するには

`subjects` に行を追加し、その `subject_id` で `categories` と `questions` を追加するだけ。
`00002_seed_gcp_ace.sql` を雛形にすると分かりやすい。試験固有の出題ルールは
`.claude/skills/question-authoring-*` にまとめてある。

## 今後の拡張メモ

- 問題の追加 / 編集 UI（現状は SQL / CSV インポート前提）
