# 問題・解説の追加ルール

## ファイルの作り方

### ファイル名

```
supabase/migrations/000<N>_seed_<subject-slug>_m<M>.sql
```

- `<N>` はシリアル番号（既存の最大番号 +1）
- `<subject-slug>` は科目スラッグ（`gcp-ace` / `gh-200` / `dca`）
- `<M>` はその科目の追加バッチ番号

**例:** `00012_seed_gcp_ace_m6.sql`

---

## INSERT テンプレート

```sql
INSERT INTO public.questions
  (subject_id, category_id, source_ref, question_text, code, options,
   correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight)
SELECT s.id, c.id, v.source_ref, v.question_text, v.code, v.options::jsonb,
       v.correct_index, v.correct_indices::jsonb, v.question_type, '', v.explanation_data::jsonb, 1
FROM public.subjects s
JOIN public.categories c ON c.subject_id = s.id
JOIN (VALUES

  ('m6q01', 'カテゴリ名',
   '問題文',
   NULL::text,   -- コードブロックがあれば文字列、なければ NULL::text
   '["選択肢A","選択肢B","選択肢C","選択肢D"]',
   0,            -- correct_index（0始まり）
   '[0]',        -- correct_indices（複数選択なら '[0,2]' など）
   'single',     -- 'single' または 'multi'
   '{"asked":"...","terms":[...],"think":"...","vs":"...","opt":["..."]}'),

  -- 以下同様

) AS v(source_ref, category_name, question_text, code, options,
       correct_index, correct_indices, question_type, explanation_data)
  ON c.name = v.category_name AND s.slug = 'gcp-ace'   -- スラッグは科目に合わせる
ON CONFLICT (subject_id, source_ref) DO NOTHING;
```

> **注意:** `ON CONFLICT (subject_id, source_ref)` は複合制約。`(source_ref)` 単体は使えない。

---

## source_ref の命名規則

| 科目 | フォーマット | 例 |
|---|---|---|
| GCP ACE | `m<M>q<NN>` | `m6q01`, `m6q50` |
| GH-200 | `gh200-q<NN>` | `gh200-q36` |
| DCA | `dca-q<NN>` | `dca-q32` |

NN はゼロ埋め2桁（01〜50 など）。既存の source_ref と重複させない。

---

## カテゴリ名（既存の名前と完全一致させる）

### GCP ACE（`gcp-ace`）

| カテゴリ名 | 備考 |
|---|---|
| IAM・組織ポリシー | |
| コンピュート・VM | |
| GKE | |
| ストレージ | |
| ネットワーク | |
| サーバーレス | |
| 監視・ログ | |
| データ分析 | |
| 運用・CLI | |
| データベース・データ分析 | m5 以降追加 |
| App Engine・Cloud Run | m5 以降追加 |
| ネットワーキング | m5 以降追加 |

### GH-200（`gh-200`）

| カテゴリ名 |
|---|
| Author and Manage Workflows |
| Consume and Troubleshoot Workflows |
| Author and Maintain Actions |
| Manage GitHub Actions for the Enterprise |
| Secure and Optimize Automation |

### DCA（`dca`）

| カテゴリ名 |
|---|
| Orchestration |
| Image Creation, Management, and Registry |
| Installation and Configuration |
| Networking |
| Security |
| Storage and Volumes |

---

## explanation_data の JSON スキーマ

```jsonc
{
  "asked": "この問題が何を問うているか（1文）",
  "terms": [
    ["用語名", "説明文"],
    ["用語名2", "説明文2"]
  ],
  "think": "解き方の思考プロセス（身近な例え交え）",
  "vs": "混同しやすい選択肢の区別ポイント",
  "opt": [
    "選択肢A の解説（正解なら「正解。〜」）",
    "選択肢B の解説",
    "選択肢C の解説",
    "選択肢D の解説"
  ]
}
```

- `terms` は配列の配列（`[["用語", "説明"], ...]`）
- `opt` の要素数は選択肢の数と一致させる
- JSON 内のシングルクォートは `''` にエスケープ（SQL 内では文字列全体をシングルクォートで囲むため）

---

## 解説の厚みガイドライン

| フィールド | 書くべき内容 |
|---|---|
| `asked` | 「〜を理解しているかを問う」形式で1文 |
| `terms` | 問題に登場するサービス・概念・フラグを2〜4個。それぞれに丁寧な説明 |
| `think` | 身近な例え（引越し・社員証・図書館など）を使って解法の流れを説明 |
| `vs` | 正解と紛らわしい選択肢がなぜ違うかを明確に |
| `opt` | 全選択肢を1文ずつ。正解は「正解。〜」で始める |

---

## 重複チェック

- **内容の完全一致**を避ける（問題文・選択肢がほぼ同じものは追加しない）
- 既存問題のテーマを違う角度・難易度で問う形は OK

---

## 適用手順

```bash
# Supabase にログイン（初回または未ログイン時）
npx supabase login
npx supabase link --project-ref pliqeyrzhmoaehodoqjk

# マイグレーション適用
npx supabase db push
```

または Supabase ダッシュボードの「SQL Editor」に SQL を貼り付けて実行。
