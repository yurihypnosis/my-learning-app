BEGIN;

INSERT INTO public.subjects (slug, name, description, color, sort_order)
VALUES ('g-kentei-i', 'G検定（JDLA ジェネラリスト検定） Set I',
        'JDLA G検定 対策 第9弾。法律・倫理・社会実装の集中セット（カテゴリ7/9/10のみ。シラバス2024掲載でSet A〜H未出題のキーワード中心: CRISP-ML、契約類型、営業秘密三要件、ハードロー/ソフトロー、公平性の定義、ガバナンス実務等）。個人情報保護法は範囲外（保有資格のため意図的に除外）。本番の再現ではなく学習用オリジナル。',
        '#0B5CAB', 58)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.categories (subject_id, name, color, sort_order)
SELECT s.id, v.name, v.color, v.sort_order
FROM public.subjects s
CROSS JOIN (VALUES
  ('7. AIの社会実装に向けて', '#e3b341', 6),
  ('9. AIに関する法律と契約', '#f85149', 8),
  ('10. AI倫理・AIガバナンス', '#ff7b72', 9)
) AS v(name, color, sort_order)
WHERE s.slug = 'g-kentei-i'
ON CONFLICT (subject_id, name) DO NOTHING;

COMMIT;
