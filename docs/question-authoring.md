# 問題・解説の追加ルール

このドキュメントの内容は **Claude Code のスキル**に移動した。実データ（本番 DB）から起こし直してあるので、そちらが正。

| 対象 | スキル |
|---|---|
| 共通（スキーマ、explanation_data、適用手順、検証） | `.claude/skills/question-authoring/` |
| GCP ACE | `.claude/skills/question-authoring-gcp-ace/` |
| GCP PCA | `.claude/skills/question-authoring-gcp-pca/` |
| GCP PCDE (DevOps) | `.claude/skills/question-authoring-gcp-pcde/` |
| Terraform Associate | `.claude/skills/question-authoring-terraform/` |
| DCA (Docker) | `.claude/skills/question-authoring-dca/` |
| GH-200 (GitHub Actions) | `.claude/skills/question-authoring-gh200/` |
| CTAL-TA (ISTQB) | `.claude/skills/question-authoring-ctal-ta/` |

Claude Code では「Terraform の問題を追加して」のように頼めば該当スキルが読み込まれる。人間が読む場合は上のディレクトリの `SKILL.md` を直接開く。

## 旧版からの訂正

移動にあたり、実態と食い違っていた 3 点を直した（旧版の記述は git 履歴にある）。

- **適用手順**: `supabase db push` は使わない。`supabase/migrations/` は適用済みと未適用が混在しており、push は履歴を壊す。`.claude/skills/question-authoring/scripts/db.sh` 経由で適用する
- **source_ref**: 「NN はゼロ埋め 2 桁」が当てはまるのは `gcp-ace` の m4 以降（`m4q01`）だけ。同じ `gcp-ace` でも m2/m3 は非ゼロ埋め（`m2q2`）で、他のファミリーは全て `q1` 形式
- **GCP ACE のカテゴリ**: 「データベース・データ分析」「App Engine・Cloud Run」「ネットワーキング」は `00014_organize_subjects_and_categories.sql` で統合済みで、現在は存在しない

また、旧版になかった `why_asked` / `kid` / `snippet` / `eg` を explanation_data のスキーマに追加した。
