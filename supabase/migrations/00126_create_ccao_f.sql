BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('ccao-f', 'Claude Certified Associate – Foundations (CCAO-F)',
        'Anthropic公式パートナー認定試験 Claude Certified Associate: Foundations の公式7ドメインに準拠した問題集。問題文は英語（本試験と同じ）、解説は小学生にも分かるレベルの日本語。コンサル・セールス・デリバリーリードなど、開発者ではなく業務でClaudeを使う人向けの基礎知識（プロンプト設計、出力評価、モデル選定、ワークフロー統合、設定・知識管理、ガバナンス、トラブルシューティング）を扱う。学習用オリジナル。',
        '#d97757', 180)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('Prompting and Task Execution（プロンプト設計とタスク実行）', '#d97757', 0),
  ('Output Evaluation and Validation（出力の評価と検証）', '#c9a04a', 1),
  ('Product and Model Selection（製品・モデル選定）', '#6ab08d', 2),
  ('Workflow Integration and Solution Design（ワークフロー統合と解決策設計）', '#3b82f6', 3),
  ('Configuration and Knowledge Management（設定と知識管理）', '#8b5cf6', 4),
  ('Governance, Risk, and Responsible Use（ガバナンス・リスクと責任ある利用）', '#c47070', 5),
  ('Troubleshooting and Optimization（トラブルシューティングと最適化）', '#4fb3bf', 6)
) AS v(name, color, sort_order)
WHERE s.slug = 'ccao-f'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
