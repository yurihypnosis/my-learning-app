# Architecture Decision Records

このアプリの「なぜそう作ったか」を残す場所。コードは How を語るが Why は語らないので、
設計判断のたびに 1 ファイル追加する。形式は Status / Context / Decision / Consequences。

| # | タイトル | Status |
|---|---------|--------|
| [0001](0001-fsrs-for-spaced-repetition.md) | 間隔反復エンジンに FSRS-4.5 を自前実装で採用 | Accepted |
| [0002](0002-poisson-binomial-pass-probability.md) | 合格確率はポアソン二項分布で厳密計算（ML 不使用） | Accepted |
| [0003](0003-supabase-write-path.md) | 本番 DB への書き込みは Management API 経由に限定 | Accepted |
| [0004](0004-feature-based-frontend.md) | フロントエンドを feature-based 構成へ移行 | Accepted |

## 書き方のルール

- 1 判断 = 1 ファイル。番号は連番、ファイル名は `NNNN-kebab-case.md`
- 決定を覆すときは新しい ADR を書き、古い方の Status を `Superseded by NNNN` に変える（上書きしない）
- 「採用しなかった選択肢」と「その理由」を必ず書く。ここが将来いちばん価値を持つ
