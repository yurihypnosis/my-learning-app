# Migration 台帳

## この台帳の目的

`supabase/migrations/` は Supabase CLI の管理下にない（[ADR 0003](adr/0003-supabase-write-path.md)
参照）。本番への書き込みは Supabase Management API 経由の直接 SQL 実行で行っており、
このディレクトリのファイルは「実行予定の SQL」ではなく **「本番に対して実際に実行した
SQL の記録」** に過ぎない。

そのため中身は大きく性質の違う2種類が混在している。

- **スキーマの歴史**: テーブル定義・カラム追加・RLS・インデックスなど、アプリの構造そのもの
- **コンテンツ操作の記録**: 問題・解説の投入(seed)、既存の問題文/選択肢/解説の修正
  (content-fix)、特定ユーザーの進捗レコードへの直接操作(progress-op)

この2つはファイル名だけでは見分けにくく（連番ファイルにも seed が混じり、日付サフィックス
ファイルにもスキーマ変更は無いが content-fix と progress-op が混ざる）、うっかりスキーマ
移行ツールとして扱うと事故る。この台帳は全ファイルを実際に読んで種別を分類し、一覧できる
ようにしたもの。

**命名が2系統ある理由**: 連番 `000NN_*.sql` は元々 Supabase CLI 風の migration 番号として
始まったが、教材 seed が増えるにつれ番号を使い切る形で運用された。日付サフィックス
`<verb>_<対象>_YYYYMMDD.sql` は、教材の修正系（既存問題の解説を直す・選択肢を均す等）が
増えた際に、連番を使わず「いつ・何に対して」が分かる名前で作業単位ごとに残す方式へ切り替
わったもの。以後、スキーマ変更のみ連番を使う運用にする（下記「今後のルール」）。

**番号衝突の注記**: `00052_seed_gcp_pca_g.sql` と `00053_seed_gcp_pca_g_m2.sql` は、本番へは
実際には `00042` と `00052` の番号で実行された。作業時点で `00042` は
`00042_user_term_progress.sql`（本ファイル）としてすでに追跡済みだったため、番号が衝突して
いることに気づき、リポジトリ側では衝突を避けた番号（52, 53）に付け直して記録している。
つまりこの2ファイルの連番はリポジトリ内の並び用であり、本番の実行順・実行時の番号とは
一致しない。

**欠番**: `00006`、`00019`〜`00024` は存在しない。本番で実行されたが記録が失われたのか、
最初から使われなかった単なる欠番なのかは不明。実行内容が分からない以上、削除や採番のやり
直しはせず「欠番」として扱う。

**番号重複の注記**: `00016_user_roadmap_items.sql` と `00016_user_textbooks.sql` は同じ番号
`00016` を持つ別ファイル（別の日に作業し、採番を確認せず重複させたと見られる）。両方とも
実際に本番へ実行済みのため、どちらもリネームせずそのまま残す。

## 一覧

| ファイル名 | 種別 | 対象 | 説明 |
|---|---|---|---|
| 00001_initial_schema.sql | schema | 全体 | questions/subjects/categories/user_question_progress 等、初期スキーマ一式 |
| 00002_seed_gcp_ace.sql | seed | gcp-ace | GCP ACE 科目＋9分野＋57問のシード |
| 00003_extend_schema.sql | schema | questions, user_question_progress | code列/複数正解/rich解説列、confidence列を追加 |
| 00004_seed_gh200.sql | seed | gh200 | GH-200（GitHub Actions認定）5ドメイン35問のシード |
| 00005_seed_dca.sql | seed | dca | DCA（Docker Certified Associate）6ドメイン31問のシード |
| 00007_seed_gcp_ace_m4.sql | seed | gcp-ace | 練習問題セット追加（m4qプレフィックス） |
| 00008_seed_gcp_ace_m5.sql | seed | gcp-ace | 練習問題セット追加（m5qプレフィックス） |
| 00009_answer_events.sql | schema | answer_events | 回答イベント履歴テーブル新設（全履歴を保持） |
| 00010_seed_gh200_m2.sql | seed | gh200 | 追加50問（q36〜q85） |
| 00011_seed_dca_m2.sql | seed | dca | 追加50問（q32〜q81） |
| 00012_fix_and_seed_istqb_ctal_ta.sql | schema + seed | answer_events, istqb-ctal-ta | answer_events テーブル作成（IF NOT EXISTS、00009の再定義）とCTAL-TA Set C 45問のシードが1ファイルに同居 |
| 00013_seed_ctal_ta_f.sql | seed | ctal-ta-f | CTAL-TA テストアナリスト Set F（テスト技法専科）40問 |
| 00014_organize_subjects_and_categories.sql | schema | categories, subjects | カテゴリ名の表記ゆれ統一・空セット非表示化・CTAL-TA名称統一（DMLのみだがスキーマではなく整理作業、判断に迷った1本＝下記参照） |
| 00015_user_exam_goals.sql | schema | user_exam_goals | 試験日（目標）を試験区分ごとに持つテーブル新設 |
| 00016_user_roadmap_items.sql | schema | user_roadmap_items | ロードマップ項目の完了状態をユーザー単位で持つテーブル新設（番号00016が重複、下記参照） |
| 00016_user_textbooks.sql | schema | user_textbooks | 試験区分ごとの教科書リンクを持つテーブル新設（番号00016が重複、下記参照） |
| 00017_user_roadmap.sql | schema | user_roadmap | ロードマップ本体（フェーズ/マイルストン）をユーザー編集可能にするテーブル新設 |
| 00018_fsrs_columns.sql | schema | user_question_progress | FSRS（記憶エンジン）の状態を保持するカラム追加 |
| 00025_seed_terraform_associate.sql | seed | terraform-associate | Terraform Associate (004) Set A 50問／8ドメイン |
| 00026_seed_terraform_associate_b.sql | seed | terraform-associate-b | Set B 問題1〜16 |
| 00027_seed_terraform_associate_b_m2.sql | seed | terraform-associate-b | Set B 問題17〜33（構成/モジュール） |
| 00028_seed_terraform_associate_b_m3.sql | seed | terraform-associate-b | Set B 問題34〜50（State管理/保守/HCP Terraform） |
| 00029_fix_option_balance_terraform_b.sql | content-fix | terraform-associate-b | 正解が単独最長だった3問の選択肢の字数バランス調整 |
| 00030_seed_g_kentei.sql | seed | g-kentei | G検定 Set A 50問／10カテゴリ |
| 00031_seed_g_kentei_b.sql | seed | g-kentei-b | G検定 Set B |
| 00032_seed_g_kentei_c.sql | seed | g-kentei-c | G検定 Set C |
| 00033_seed_g_kentei_d.sql | seed | g-kentei-d | G検定 Set D |
| 00034_seed_g_kentei_svm.sql | seed | g-kentei | サポートベクターマシン問題1問を新規追加 |
| 00035_g_kentei_a_causal_think.sql | content-fix | g-kentei | 仕組み系8問のthinkに因果の背骨を通す（非破壊マージ） |
| 00036_g_kentei_bcd_causal_think.sql | content-fix | g-kentei-b/c/d | 仕組み系21問のthinkに因果の背骨を通す |
| 00037_dca_causal_think.sql | content-fix | dca | 仕組み系5問のthinkに因果の背骨を通す |
| 00038_pcde_causal_think.sql | content-fix | gcp-pcde | コアSRE概念6問のthinkに因果の背骨を通す |
| 00039_terraform_causal_think.sql | content-fix | terraform-associate | 仕組み系5問のthinkに因果の背骨を通す |
| 00040_seed_g_kentei_e.sql | seed | g-kentei-e | G検定 Set E 50問（投入時点からclarity対応済） |
| 00041_balance_options_g_kentei_e.sql | content-fix | g-kentei-e | 正解が単独最長だった5問の選択肢を均す |
| 00042_user_term_progress.sql | schema | user_term_progress | 単語カード（フラッシュカード）の学習進捗をDBで持つテーブル新設 |
| 00043_flashcard_events.sql | schema | flashcard_events | 単語カードの1採点ごとの履歴テーブル新設 |
| 00044_speak_first.sql | schema | user_question_progress | Speak-First（句動詞ドリル）用の口頭産出自己申告フラグ列追加 |
| 00045_seed_pv-t1-a.sql | seed | pv-t1-a | 句動詞 学術・フォーマル系25問 |
| 00046_seed_pv-t1-b.sql | seed | pv-t1-b | 句動詞 学術・フォーマル系25問（依拠・構成/要約・帰着） |
| 00047_seed_pv-t2-a.sql | seed | pv-t2-a | 句動詞 議論動詞20問（主張・提起/賛否・譲歩） |
| 00048_seed_pv-t2-b.sql | seed | pv-t2-b | 句動詞 議論動詞20問（検討・判断/継続・断念） |
| 00049_seed_pv-t3-a.sql | seed | pv-t3-a | 句動詞 日常・語り22問（先送り・回避/開始・着手） |
| 00050_seed_pv-t3-b.sql | seed | pv-t3-b | 句動詞 日常・語り22問（関係・対立/増減・変化） |
| 00051_seed_pv-t3-c.sql | seed | pv-t3-c | 句動詞 日常・語り22問（発覚・判明/感情・反応＝補助クラスタ） |
| 00052_seed_gcp_pca_g.sql | seed | gcp-pca-g | GCP PCA Set G のシード。**本番では番号00042で実行**（下記「番号衝突の注記」参照） |
| 00053_seed_gcp_pca_g_m2.sql | seed | gcp-pca-g | GCP PCA Set G 追加分。**本番では番号00052で実行**（下記「番号衝突の注記」参照） |
| add_balance_options_g_kentei_20260716.sql | content-fix | g-kentei | 正解が単独最長だった問題の選択肢の長さ均し |
| add_eg_g_kentei_20260716.sql | content-fix | g-kentei | 50問にeg（たとえ）を追加 |
| add_kid_usecase_dca_20260716.sql | content-fix | dca | 全81問にkid（噛み砕き）とusecase（実務での使いどころ）を追加 |
| add_kid_usecase_g_kentei_20260716.sql | content-fix | g-kentei | kid未整備分の追加とusecaseの全問追加 |
| add_length_fix_pv-t1-a_20260721.sql | content-fix | pv-t1-a | 長さリークが出ていた直訳肢2問を冗長化修正 |
| add_point_and_naturalize_g_kentei_20260716.sql | content-fix | g-kentei | 58問にpoint（決め手）を追加し表現を平易化 |
| add_point_eg_dca_20260716.sql | content-fix | dca | 82問にpoint/egを追加 |
| add_snippet_terraform_20260716.sql | content-fix | terraform-associate-b | 正しい書き方のsnippetを31問に追加 |
| add_why_asked_devops_20260715.sql | content-fix | gcp-pcde | why_asked（出題意図）を240問に追加 |
| balance_options_g_kentei_b_20260716.sql | content-fix | g-kentei-b | 17問の選択肢の字数バランス調整 |
| fix_lazy_distractors_pcde_20260716_1.sql | content-fix | gcp-pcde | 投げやりな誤答の差し替え バッチ1（12問） |
| fix_lazy_distractors_pcde_20260716_2.sql | content-fix | gcp-pcde | 投げやりな誤答の差し替え バッチ2（12問） |
| fix_lazy_distractors_pcde_20260716_3.sql | content-fix | gcp-pcde | 投げやりな誤答の差し替え バッチ3（12問） |
| fix_lazy_distractors_pcde_20260716_4.sql | content-fix | gcp-pcde | 投げやりな誤答の差し替え バッチ4（12問） |
| fix_lazy_distractors_pcde_20260716_6.sql | content-fix | gcp-pcde | 投げやりな誤答の差し替え バッチ6（11問、初回検出パターン漏れ分） |
| fix_lazy_distractors_pcde_20260716_7.sql | content-fix | gcp-pcde | 投げやりな誤答の差し替え バッチ7（20問）＋文字化け修正1件 |
| fix_lazy_distractors_pcde_20260716_12.sql | content-fix | gcp-pcde | 投げやりな誤答の差し替え＋正解の刈り込み（最後の20問） |
| fix_lazy_distractors_pcde_20260716_13.sql | content-fix | gcp-pcde | 残った投げやり誤答4問と短すぎる誤答2問の仕上げ |
| fix_option_giveaways_ctal_ta_20260716.sql | content-fix | ctal-ta（技法セット） | 選択肢に混入していた「なぜ誤りか」の自白を除去（7問） |
| fix_option_position_refs_20260716.sql | content-fix | 複数科目 | 解説の自由文にあった位置参照（選択肢A等）を解消し選択肢シャッフルを機能させる（6問） |
| fix_rich_correct_options_pcde_20260716_5.sql | content-fix | gcp-pcde | 正解の選択肢に付いた括弧補足を解説側へ移す（17問） |
| fix_rich_correct_options_pcde_20260716_8.sql | content-fix | gcp-pcde | 正解の選択肢から列挙・括弧補足を除去（8問） |
| fix_rich_correct_options_pcde_20260716_9.sql | content-fix | gcp-pcde | 正解の選択肢から括弧補足を除去（30問） |
| fix_rich_correct_options_pcde_20260716_10.sql | content-fix | gcp-pcde | 正解の選択肢から用語の英語表記を除去し解説へ移す（22問） |
| fix_rich_correct_options_pcde_20260716_11.sql | content-fix | gcp-pcde | 正解の選択肢の刈り込み（16問、誤答は現実的なため対象外） |
| fix_stale_vs_pcde_20260716_14.sql | content-fix | gcp-pcde | 選択肢差し替えで古い記述のまま残っていたvs（混同ポイント）の書き直し（92問） |
| mark_weak_gcp_pca_g_q51_q80_20260725.sql | progress-op | user_question_progress（gcp-pca-g q51〜80） | 特定ユーザーの進捗レコードに直接INSERT/UPDATEし、q51〜80を苦手状態としてマーク |
| reground_dl_internals_g_kentei_20260716.sql | content-fix | g-kentei | 深層学習内部（勾配消失等）の解説を再接地（4問） |
| reground_remaining_g_kentei_20260716.sql | content-fix | g-kentei | 残りの解説の再接地（4問） |
| rewrite_granularity_gcp_pca_20260721.sql | content-fix | gcp-pca-g | 粒度（抽象度）の書き直し（50問） |
| rewrite_plain_g_kentei_20260716.sql | content-fix | g-kentei | Set A 全50問の解説を「一度読んで100%わかる」水準に全面書き換え |
| update_explanations_20260618.sql | content-fix | gcp-ace | 5問（m2q21, m3q3, m3q16, m2q34, m2q44）の解説文を更新 |

**分類に迷ったファイル**:

- `00012_fix_and_seed_istqb_ctal_ta.sql` — answer_events テーブルの作成（`CREATE TABLE IF NOT EXISTS`、00009 と同一定義）と CTAL-TA Set C 45問のシードが1ファイルに同居している。schema と seed の複合として記載した。
- `00014_organize_subjects_and_categories.sql` — 中身は UPDATE 文のみ（DDL ではない）だが、対象が個々の問題データではなく `categories`/`subjects` という構造寄りのマスタデータの整理（表記ゆれ統一・非表示化）のため、seed でも content-fix でもなく schema 側に寄せて分類した。

## 今後のルール

- **スキーマ変更**（`CREATE TABLE`、`ALTER TABLE`、RLS、インデックス等）は `supabase/migrations/` に連番 `000NN_*.sql` で置く。
- **教材の seed・修正・進捗操作**（問題の投入、解説/選択肢の修正、特定ユーザーの進捗への直接操作）は新設する `supabase/content/` に `YYYYMMDD_<verb>_<対象>.sql` で置く。日付が先頭になるので、ファイル名でソートすればそのまま時系列になる。
- 既存ファイルは本番実行時の名前のままとし、リネームや番号の振り直しはしない（歴史を改変しない）。
