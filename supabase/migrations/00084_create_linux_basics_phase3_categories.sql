BEGIN;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('systemdとサービス管理', '#5aa3d0', 15),
  ('SSHとリモートアクセスの基礎', '#6ab08d', 16),
  ('定期実行とcronの仕組み', '#c9a04a', 17),
  ('圧縮とアーカイブの基本', '#8892a4', 18),
  ('ディストリビューションの違い', '#c47070', 19)
) AS v(name, color, sort_order)
WHERE s.slug = 'linux-basics'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
