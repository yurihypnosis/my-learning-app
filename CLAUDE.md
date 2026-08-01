# my-learning-app

Yuu 個人の学習アプリ。G検定・統計・Linux・各種資格の図解ドリルを問題集として蓄積している。詳しい作問ルールは `.claude/skills/question-authoring*` を参照。

## 標準ワークフローへの標準許可（確認なしで進めてよいこと）

このリポジトリでの日常的な作業フローについては、都度「コミットしていいですか」「pushしていいですか」と確認を挟まなくてよい。以下は既に本人から包括的に許可されている:

- **問題集・スキルファイルのコミットとpush。** `supabase/migrations/*.sql`（作問・DB適用済みの内容）、`.claude/skills/*` の追加・更新は、作業が一段落した時点でコミットして `main` に push してよい（Vercelへの自動デプロイもこの一部）。単発の確認は不要
- **本番DBへの適用。** `.claude/skills/question-authoring/scripts/db.sh apply` によるSupabase本番反映は、この問題集ワークフローの一部として確認なしで実行してよい（[[project_prod_db_write_path]]参照）
- **軽微な判断は聞かずに進めてよい。** 作業中に見つかった、今のタスクと無関係な未使用ファイル・半端な状態のファイル（例: 中身が空のまま残っている `src/features/quiz/lib/streak.ts` のような未使用スタブ）は、削除などの実際の変更はせずそのまま放置してよい。「削除していいですか」と聞かずに、気づいたことだけ一言メンションすれば十分

2026-08-02、ユウから「今回許可を求めたことは全部デフォルトで許可するので、以降は聞かないでほしい」という明示の指示があった。上記はその指示を反映したもの。**このルールが及ばないもの**（引き続き通常通り確認する）: force push、`git reset --hard` 等の破壊的操作、既存コミットの書き換え、コード本体（`src/` 配下のロジック）に対する大きめの変更、ファイルの実削除、このリストに無い新しい種類のリスクの高い操作。迷ったら確認する。

## 参照

- 作問共通ルール: `.claude/skills/question-authoring/SKILL.md`
- 試験別ルール: `.claude/skills/question-authoring-*/SKILL.md`
- 本番DB書き込み経路: memory の `project_prod_db_write_path.md`
