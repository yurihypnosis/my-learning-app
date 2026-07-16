-- 選択肢に混入した「なぜ誤りか」の説明を除去 (CTAL-TA 技法セット 7問) 2026-07-16
--
-- 誤答が括弧内で自分の誤りを自白しており（例:「深く考えずに単純に2倍しただけの数である」）、
-- 知識ゼロでも消去法で正解できてしまっていた。正解だけが根拠つきで長くなる偏りも生んでいた。
-- 同じ説明は explanation_data.opt に既に入っているため、選択肢からは落として素の値だけを残す。
-- correct_index は変えない（選択肢の順序は維持）。
BEGIN;

UPDATE public.questions q
SET options = v.options::jsonb
FROM (VALUES
  -- 1-switch のペア数。括弧内の計算過程は opt 側にある
  ('ctal-ta-f', 'ctal-ta-f-q20', '["5","10","25","6"]'),
  -- 全組み合わせ数
  ('ctal-ta-f', 'ctal-ta-f-q26', '["24通り","16通り","48通り","11通り"]'),
  -- DDP。計算式を選択肢から外し、受験者に計算させる
  ('ctal-ta-f', 'ctal-ta-f-q39', '["10%","約83%","50%","90%"]'),
  -- 2値境界値分析のテスト値
  ('ctal-ta-f', 'ctal-ta-f-q6',  '["0, 1, 2, 5, 6, 7 の6点","1, 5 の2点のみ","0, 1, 5, 6 の4点","1, 2, 4, 5 の4点"]'),
  -- 1-switch カバレッジ率
  ('ctal-ta-g', 'ctal-ta-g-q14', '["約67%","50%","150%","100%"]'),
  -- 拡張エントリーの組み合わせ総数
  ('ctal-ta-g', 'ctal-ta-g-q2',  '["7通り","9通り","12通り","8通り"]'),
  -- 各選択網羅の最小テストケース数
  ('ctal-ta-g', 'ctal-ta-g-q23', '["12件","4件","9件","24件"]')
) AS v(slug, source_ref, options)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = v.slug);

COMMIT;
