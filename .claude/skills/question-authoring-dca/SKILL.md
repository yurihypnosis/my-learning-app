---
name: question-authoring-dca
description: DCA (Docker Certified Associate) の問題集に問題・解説を追加/修正するときの試験固有ルール（slug、カテゴリ名、code 列の使い方）。「Dockerの問題を追加して」「DCAの解説を直して」で使う。共通ルールは question-authoring スキルにある。
---

# DCA (Docker Certified Associate)

**先に `question-authoring` スキル（共通ルール・適用手順）を読むこと。** ここは試験固有の情報だけ。

## 科目

| slug | 名前 | 問題数 |
|---|---|---|
| `dca` | DCA Docker Certified Associate | 81 |

## source_ref

`dca-q<N>` — **ゼロ埋めしない**（`dca-q1`, `dca-q81`）。次は `dca-q82` から。

## カテゴリ名（完全一致で JOIN。英語のまま）

```
Orchestration
Image Creation, Management, and Registry
Installation and Configuration
Networking
Security
Storage and Volumes
```

## 解説の流儀

`asked` / `terms` / `think` / `vs` / `opt` の 5 キー。`kid` / `why_asked` / `eg` は未使用。

`snippet` は未使用だが、**このファミリーは相性が良い**（Dockerfile やコマンドの模範解答を示せる）。付けるなら描画は実装済みなのでそのまま出る。

## 内容の注意

- **81 問中 13 問が `code` 列を使っている**（Dockerfile / compose / コマンド出力を読ませて解く形式）。このファミリーの持ち味なので活かす
- `code` は問題文と一緒に出る題材、`snippet` は解説の模範解答。混同しない
- `multi` は 0 問。全部 single
- Swarm と Kubernetes の対比、`docker` CLI のサブコマンドの弁別が作りやすい
