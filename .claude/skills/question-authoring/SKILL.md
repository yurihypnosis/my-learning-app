---
name: question-authoring
description: この学習アプリの問題集に問題・解説を追加/修正するときの共通ルール（DBスキーマ、explanation_data の書き方、本番への適用手順、検証）。試験固有の情報は question-authoring-<試験> スキルにあるので、そちらを併せて読む。「問題を追加して」「解説を厚くして」「新しい問題集を作って」で使う。
---

# 問題・解説オーサリング（共通）

試験固有のカテゴリ名・source_ref 形式・解説の流儀は **試験別スキル**にある。必ず両方読むこと。

| 試験 | スキル |
|---|---|
| GCP ACE | `question-authoring-gcp-ace` |
| GCP PCA | `question-authoring-gcp-pca` |
| GCP PCDE (DevOps) | `question-authoring-gcp-pcde` |
| Terraform Associate | `question-authoring-terraform` |
| DCA (Docker) | `question-authoring-dca` |
| GH-200 (GitHub Actions) | `question-authoring-gh200` |
| CTAL-TA (ISTQB) | `question-authoring-ctal-ta` |

新しい試験を足すときは、既存の試験別スキルを雛形にして 1 枚追加する。

## 大前提

- **本番 Supabase が唯一の DB。** ローカル DB もステージングも無い。書いた SQL はそのまま本番に当たる。
- **`supabase db push` は使わない。** `supabase/migrations/` には適用済みと未適用が混在しており、push は履歴を壊す。適用は必ず下記スクリプトで行う。
- anon key は読み取り専用。書き込みは Management API（keychain の CLI トークンを使用）。

```bash
.claude/skills/question-authoring/scripts/db.sh query "select ..."   # 確認用
.claude/skills/question-authoring/scripts/db.sh apply path/to.sql    # 適用
```

## 手順

### 1. 現状を DB で確認する（推測しない）

`docs/` や過去の SQL ファイルは古いことがある。カテゴリ名も問題数も、必ず DB に聞く。

```bash
db.sh query "select c.name, count(q.id) from public.categories c
  join public.subjects s on s.id = c.subject_id
  left join public.questions q on q.category_id = c.id
  where s.slug = '<slug>' group by 1 order by 1;"

db.sh query "select source_ref, left(question_text, 60) from public.questions q
  join public.subjects s on s.id = q.subject_id
  where s.slug = '<slug>' order by source_ref;"
```

### 2. 重複を避ける

既存の問題文・選択肢とほぼ同じものは足さない。同じテーマを別角度・別難易度で問うのは可。手順 1 の一覧に目を通してから書く。

### 3. SQL を書く

ファイル名は 2 パターン。新規の問題追加は前者。

- 問題の追加 : `supabase/migrations/000<N>_seed_<slug>.sql`（`<N>` は既存の最大 +1）
- 既存の更新 : `supabase/migrations/add_<内容>_<slug>_<YYYYMMDD>.sql`

```sql
BEGIN;

INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('<source_ref>', '<カテゴリ名>',
   '問題文',
   NULL::text,        -- code: 問題文に見せるコードがあれば文字列、無ければ NULL
   '["選択肢A","選択肢B","選択肢C","選択肢D"]',
   0,                 -- correct_index（0 始まり。multi では正解の先頭を入れる）
   '[0]',             -- correct_indices（multi なら '[0,2]'）
   'single',          -- 'single' | 'multi'
   '{"asked":"...","think":"...","vs":"...","opt":["...","...","...","..."]}'),

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = '<slug>'
ON CONFLICT (subject_id, source_ref) DO NOTHING;

COMMIT;
```

既存問題への項目の後付けは、既存キーを消さないよう `||` でマージする。

```sql
UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('snippet', v.value)
FROM jsonb_each_text('{"<source_ref>": "<値>"}'::jsonb) AS v(key, value)
WHERE q.source_ref = v.key
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = '<slug>')
  AND q.explanation_data IS NOT NULL;
```

### 4. 適用して検証する

```bash
db.sh apply supabase/migrations/000NN_seed_<slug>.sql

# 入った件数とキーの充足を必ず確認する
db.sh query "select count(*) total,
  count(*) filter (where explanation_data ? 'opt') with_opt
  from public.questions q join public.subjects s on s.id=q.subject_id
  where s.slug='<slug>';"
```

UI での見え方まで変えた場合（新しい explanation_data のキーを足したときなど）は、`npm run dev` で実際に 1 問解いて解説の描画を確認する。**キーを足しただけでは画面には出ない** — `RichExplanation`（`src/app/(main)/learning-app.tsx`）に描画コードが要る。

## explanation_data のスキーマ

`src/lib/quiz/types.ts` の `ExplanationData` と一致させること。片方だけ足しても表示されない。

| キー | 必須 | 内容 |
|---|---|---|
| `asked` | ○ | 何を問うているか。1 文 |
| `why_asked` | | なぜ試験に出るか。作問者の意図・受験者が落ちる思考の癖 |
| `kid` | | ざっくり言うと。噛み砕いた 1〜2 文 |
| `terms` | | キーワード。`[["用語","説明"], ...]` を 2〜4 個 |
| `think` | ○ | 考え方。解法の流れ |
| `snippet` | | 正しい書き方。コード/コマンドの模範解答。`<pre>` で等幅描画される |
| `eg` | | たとえると。身近な比喩 |
| `vs` | | 混同ポイント。紛らわしい選択肢との違い |
| `opt` | | 選択肢の解説。**選択肢と同数**。正解は「正解。」で始める |

`code`（questions の列）と `snippet`（explanation_data 内）は別物。

- `code` … 問題文と一緒に出る。これを読んで解く題材
- `snippet` … 解答後の解説に出る。模範解答

## つまずきどころ

- `ON CONFLICT (subject_id, source_ref)` は複合ユニーク制約。`(source_ref)` 単体は不可
- カテゴリ名は完全一致で `JOIN`。1 文字でも違うと**その行が黙って落ちる**（エラーにならない）。適用後に件数を数えて確かめる
- SQL 文字列内のシングルクォートは `''` にエスケープ
- `terms` は配列の配列。オブジェクトではない
- `question_type='multi'` では `correct_indices` を必ず入れる
- 全キーを全問に付けなくてよい。`snippet` はコードで示す価値のある問題にだけ付ける（概念問題に無理に付けない）
