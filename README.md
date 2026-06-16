# My Learning App

模試で間違えた問題を反復演習する、拡張可能な学習アプリ。
Next.js 16 + Supabase + Tailwind CSS v4。モバイル / Web 両対応。

GCP ACE の弱点問題集として作られているが、`subjects`（科目）→ `categories`（分野）→
`questions`（問題）の階層なので、AWS など他の科目を後から追加できる。

## 主な機能

- **4択演習**: 解答後に正解と解説を表示。直近の自分の解答を記録
- **理解度フラグ**: 問題ごとに「全く分からない / 怪しい / だいたい理解 / 完璧」の4段階
- **メモ**: 問題ごとに気づきや自分の言葉での説明を保存
- **出題制御**: 問題数（5/10/20/全部）・分野選択・「シャッフル / 弱点優先」切替
  - 弱点優先 = 誤答回数の多い問題から出題
- **間隔反復**:
  - 3回連続正解した問題は最後の解答から **2週間** 出題しない
  - 正解かつ理解度「完璧」の問題は最後の解答から **1週間** 出題しない
- **苦手分析**: 分野別正答率 / 最重点問題ランキング / 理解度フラグ分布
- **CSV書き出し**: 問題・解答・フラグ・メモを CSV ダウンロード（コピーも可）
- すべての進捗を Supabase に保存し、端末をまたいで同期

## アーキテクチャ

```
src/
  proxy.ts                      # Supabase セッション更新 + 未認証は /login へ（旧 middleware）
  types/database.ts             # DB 型
  lib/supabase/{client,server,middleware}.ts
  lib/quiz/{types,selection,csv}.ts   # 出題ロジック・間隔反復・CSV
  app/(auth)/{login,register}   # メール+パスワード認証
  app/(main)/page.tsx           # サーバーで問題+進捗を取得
  app/(main)/learning-app.tsx   # メニュー/演習/結果/分析/書き出しの全画面（クライアント）
supabase/migrations/
  00001_initial_schema.sql      # テーブル + RLS + トリガ
  00002_seed_gcp_ace.sql        # GCP科目 + 9分野 + 57問
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
`00002_seed_gcp_ace.sql` を雛形にすると分かりやすい。

## 今後の拡張メモ

- 演習1回ごとの履歴（answer_history）は未実装。学習の時系列トレンドが欲しくなったら追加する
- 問題の追加 / 編集 UI（現状は SQL / CSV インポート前提）
