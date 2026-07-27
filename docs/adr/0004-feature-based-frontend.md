# 0004: フロントエンドを feature-based 構成へ移行

- Status: Accepted
- Date: 2026-07-28

## Context

機能追加を重ねた結果、UI 層に技術的負債が集中した。

- `app/(main)/learning-app.tsx` が 2,259 行・useState 35 個・6 画面のモノリスに成長
- `flashcards-client.tsx`（762 行）も同じパターンで肥大中
- 一方 `lib/quiz/` は分割・テスト済みで健全。「ロジック層は美しいが UI 層が無法地帯」
  という非対称が生まれていた
- 機能ごとのコード配置に規約がなく（quiz は lib+page、roadmap はハードコード定数）、
  新機能のたびに置き場を発明していた

このリポジトリ自体を「アーキテクチャの学習資料」にするという目標もあり、
再現可能なパターンとして構造を規約化したい。

## Decision

feature-based 構成に移行する。

```
src/
  features/<name>/   # quiz, flashcards, roadmap, mindset, readiness
    screens/         # 画面単位のコンポーネント
    hooks/           # 状態は custom hook + reducer に集約
    lib/             # 純粋ロジック（テスト対象）
  shared/            # header, utils, supabase クライアント
  app/               # ルーティングと SSR データ取得だけの薄い層
```

移行手順は「状態を先に出す」を原則とする:
1. useState 群を `useQuizSession` 等の hook + reducer へ抽出（挙動を変えない）
2. Screen 型の値ごとに screens/ へファイル分割
3. lib の移動と import 修正
4. 同パターンを flashcards へ適用（1〜3 の成果物を見本にする）

### 採用しなかった選択肢

- **状態管理ライブラリ（Zustand / Jotai 等）**: reducer + hook で足りる規模。
  依存を増やすほど「見本リポジトリ」としての純度が下がる
- **技術レイヤ別構成（components/ hooks/ utils/ の全機能共有）**: 機能を跨いで
  ファイルが散り、1機能を読むのに全ディレクトリを巡ることになる。
  「1機能 = 1ディレクトリで完結して読める」ことを学習資料として優先
- **モノリスの容認**: 動いてはいるが、変更のたびに 2,000 行を読む税金を
  払い続けることになり、新機能のパターンにもならない

## Consequences

- 良: 新機能の置き場が規約で決まる。機能単位で読める・消せる・テストできる
- 良: hook 抽出により UI と状態遷移が分離され、状態遷移だけの単体テストが書ける
- 悪: 移行中は git 履歴が追いにくくなる（大規模な移動）。フェーズを分けた
  コミットで緩和する
- 悪: 小さな機能（mindset 等）には器がやや大袈裟。ただし一貫性を優先する
