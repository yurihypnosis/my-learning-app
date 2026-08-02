BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('kcna', 'KCNA（Kubernetes and Cloud Native Associate）',
        'CNCF公式のKCNA試験ドメインに沿った、Kubernetesの図解ドリル。kubectlコマンドやYAMLの丸暗記ではなく、なぜその設計になっているかという仕組みを小学生にも分かるレベルまで噛み砕いて理解する。読者はLinux・コンテナ未経験のソフトウェアQAエンジニア。学習用オリジナル。',
        '#5b8def', 170)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('Kubernetesとは何か', '#5b8def', 0),
  ('クラスタの構造（コントロールプレーンとノード）', '#6d9bf2', 1),
  ('Podという最小単位', '#7ba6f5', 2),
  ('宣言的な管理とkubectl', '#c9a04a', 3),
  ('ReplicaSetとDeployment', '#6ab08d', 4),
  ('Serviceとラベル・セレクタ', '#3b82f6', 5),
  ('ConfigMapとSecretによる設定分離', '#8b5cf6', 6),
  ('Volumeとデータの永続化', '#4fb3bf', 7)
) AS v(name, color, sort_order)
WHERE s.slug = 'kcna'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
