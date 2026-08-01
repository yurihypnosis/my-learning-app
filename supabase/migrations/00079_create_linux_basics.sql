BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('linux-basics', 'Linuxの教科書（図解ドリル）',
        'コマンドの丸暗記ではなく、OS・シェル・ファイルシステム・プロセスなどLinuxの仕組みそのものを、図解で本質から理解する教養ドリル。読者はLinux・コンテナ未経験のソフトウェアQAエンジニア。学習用オリジナル。',
        '#4fb3bf', 150)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('コンピュータとOSの中身', '#4fb3bf', 0),
  ('シェルとコマンドの正体', '#5ec2cc', 1),
  ('ファイルシステムの本質', '#6dd1d9', 2),
  ('プロセスという考え方', '#7ce0e6', 3),
  ('標準入出力とパイプ', '#3a9aa5', 4),
  ('権限とユーザー', '#c9a04a', 5),
  ('環境変数とPATH', '#60a5fa', 6),
  ('ジョブ管理とシグナル', '#c47070', 7),
  ('コンテナの正体', '#8b5cf6', 8),
  ('ネットワークの基礎', '#3b82f6', 9)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
