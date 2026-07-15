-- =============================================================
-- 00014_organize_subjects_and_categories.sql
-- 本番データの整理（DML のみ・スキーマ変更なし）。
--
-- 目的:
--   1) 試験横断の苦手分析が正しく合算されるよう、同一試験内でセット間の
--      カテゴリ(セクション)名の表記ゆれを正規名に統一する。
--   2) 未使用の空セットをプルダウンから隠す(is_active=false)。
--   3) ISTQB CTAL-TA の名称を CTAL-TA テストアナリストへ揃える。
--      （試験グルーピング自体は examGroupKey の別名対応でコード側が吸収する）
--
-- 安全性: questions は category_id を参照するため、categories.name の変更で
--   参照は壊れない。UNIQUE(subject_id, name) も、旧名は該当セットにしか
--   存在しないため衝突しない。すべて冪等（該当行が無ければ 0 件更新）。
--
-- Set F/G（技法専科/応用編）の技法別カテゴリ（デシジョンテーブル 等）は、
--   Ch3 テスト技法の詳細分解として意図的に別粒度のため、本整理では触れない。
-- =============================================================

BEGIN;

-- ── ① カテゴリ名の正規化 ─────────────────────────────────────

-- GCP Professional Cloud DevOps Engineer（正: 多数派の5セクション）
UPDATE public.categories SET name = '組織のブートストラップと維持'
  WHERE name = 'S1 組織のブートストラップ（IaC・階層）';
UPDATE public.categories SET name = 'CI/CDパイプラインの構築と実装'
  WHERE name = 'S2 CI/CD パイプラインの構築';
UPDATE public.categories SET name = 'SREの手法の適用'
  WHERE name = 'S3 SRE 実践（SLO・エラーバジェット）';
UPDATE public.categories SET name = 'オブザーバビリティの実践'
  WHERE name = 'S4 可観測性とトラブルシュート';
UPDATE public.categories SET name = 'パフォーマンス最適化とトラブルシューティング'
  WHERE name = 'S5 パフォーマンス最適化とインシデント';

-- GCP Professional Cloud Architect（正: 多数派の6セクション）
UPDATE public.categories SET name = '設計・計画'
  WHERE name = 'S1 設計・計画';
UPDATE public.categories SET name = 'インフラのプロビジョニングと管理'
  WHERE name = 'S2 インフラ構築・プロビジョニング';
UPDATE public.categories SET name = 'セキュリティとコンプライアンス'
  WHERE name = 'S3 セキュリティとコンプライアンス';
UPDATE public.categories SET name = 'プロセスの分析と最適化'
  WHERE name = 'S4 プロセスの分析と最適化';
UPDATE public.categories SET name = '実装の管理'
  WHERE name = 'S5 実装の管理';
UPDATE public.categories SET name = '信頼性の確保'
  WHERE name = 'S6 信頼性の確保';

-- CTAL-TA テストアナリスト（Ch5 の表記ゆれを4セット側の正規名へ）
UPDATE public.categories SET name = 'Ch5 レビューと欠陥分析におけるTAのタスク'
  WHERE name = 'Ch5 レビュー';

-- ISTQB CTAL-TA（独自表記 → CTAL-TA テストアナリストの正規名へ）
UPDATE public.categories SET name = 'Ch1 テストプロセスにおけるTAのタスク'
  WHERE name = 'Ch1: TAのタスクとテストプロセス';
UPDATE public.categories SET name = 'Ch2 リスクベースドテストにおけるTAのタスク'
  WHERE name = 'Ch2: リスクベーステスト';
UPDATE public.categories SET name = 'Ch3 テスト技法'
  WHERE name = 'Ch3: テスト技法';
UPDATE public.categories SET name = 'Ch4 ソフトウェア品質特性のテスト'
  WHERE name = 'Ch4: 品質特性のテスト';
UPDATE public.categories SET name = 'Ch5 レビューと欠陥分析におけるTAのタスク'
  WHERE name = 'Ch5: レビューと欠陥管理';

-- ── ② 空セットを非表示 ───────────────────────────────────────
UPDATE public.subjects SET is_active = false
  WHERE slug IN ('ctal-ta-i', 'ctal-ta-j');

-- ── ③ ISTQB CTAL-TA の名称を CTAL-TA 試験へ揃える ────────────
--     （グループ見出しは他セットの短い名前が採用されるため、行名のみ調整）
UPDATE public.subjects SET name = 'CTAL-TA テストアナリスト（初版）'
  WHERE slug = 'istqb-ctal-ta';

COMMIT;
