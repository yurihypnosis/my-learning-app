# 0003: 本番 DB への書き込みは Supabase Management API 経由に限定

- Status: Accepted
- Date: 2026-06

## Context

教材（問題・解説）の追加は開発の中心的な作業で、ほぼ毎回 Claude Code のセッション内で
行われる。本番 Supabase に SQL を流す経路として、`supabase db push`・service_role キー・
Management API の3択があった。誤操作でスキーマや他人のデータを壊さないことが最優先。

## Decision

- アプリが持つ **anon キーは実質読み取り専用**として扱う（RLS で教材は全員 SELECT 可、
  進捗は `auth.uid() = user_id` の本人のみ）
- 教材の投入・修正は **Supabase Management API**（`/v1/projects/{ref}/database/query`）で
  SQL を直接実行する。アクセストークンは macOS キーチェーンに保管し、
  `.claude/skills/question-authoring/scripts/db.sh` がラップする
- **`supabase db push` は使わない**。migration ファイルはあくまで「実行した SQL の記録」
  であり、Supabase CLI のマイグレーション履歴とは同期していない

### 採用しなかった選択肢

- **`supabase db push`**: ローカルの migration 履歴と本番の履歴テーブルの整合を常に
  保つ必要があり、ズレたときの復旧が高コスト。教材追加のような高頻度・低リスクな
  operation に対して仕組みが重すぎた
- **service_role キーをローカルに置く**: RLS を全バイパスする鍵を平文で持つことになる。
  Management API トークンはキーチェーン保管で、実行経路も db.sh 一本に絞れる

## Consequences

- 良: アプリ側の鍵が漏れても書き込みはできない。書き込み経路が1本で監査しやすい
- 良: SQL ファイル（supabase/ 以下）が「本番に流したものの記録」として git に残る
- 悪: migration ディレクトリが Supabase CLI の管理外になり、命名・番号の規律が
  自然には保たれない（実際に崩れた — 台帳 docs/migration-ledger.md で補正）
- 悪: ローカル開発 DB と本番の差分管理は手動。現状ユーザー1人なので許容
