BEGIN;

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', v.viz)
FROM (VALUES

  ('ap-server-q64', '<svg viewBox="0 0 340 160" xmlns="http://www.w3.org/2000/svg"><text x="185" y="14" text-anchor="middle" font-size="11" fill="#8892a4">利用者が管理する範囲（青）</text><text x="80" y="28" text-anchor="middle" font-size="10" fill="#e8eaf0">IaaS</text><text x="190" y="28" text-anchor="middle" font-size="10" fill="#e8eaf0">PaaS</text><text x="300" y="28" text-anchor="middle" font-size="10" fill="#e8eaf0">SaaS</text><rect x="50" y="35" width="60" height="18" fill="#3b82f6"/><rect x="50" y="55" width="60" height="18" fill="#3b82f6"/><rect x="50" y="75" width="60" height="18" fill="#6ab08d"/><rect x="50" y="95" width="60" height="18" fill="#6ab08d"/><rect x="160" y="35" width="60" height="18" fill="#3b82f6"/><rect x="160" y="55" width="60" height="18" fill="#6ab08d"/><rect x="160" y="75" width="60" height="18" fill="#6ab08d"/><rect x="160" y="95" width="60" height="18" fill="#6ab08d"/><rect x="270" y="35" width="60" height="18" fill="#6ab08d"/><rect x="270" y="55" width="60" height="18" fill="#6ab08d"/><rect x="270" y="75" width="60" height="18" fill="#6ab08d"/><rect x="270" y="95" width="60" height="18" fill="#6ab08d"/><text x="44" y="47" text-anchor="end" font-size="8" fill="#8892a4">アプリ</text><text x="44" y="67" text-anchor="end" font-size="8" fill="#8892a4">OS/MW</text><text x="44" y="87" text-anchor="end" font-size="8" fill="#8892a4">仮想化</text><text x="44" y="107" text-anchor="end" font-size="8" fill="#8892a4">HW</text><text x="185" y="130" text-anchor="middle" font-size="10" fill="#3b82f6">青=自分で管理</text><text x="185" y="146" text-anchor="middle" font-size="10" fill="#6ab08d">緑=事業者が管理</text></svg>')

) AS v(source_ref, viz)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'ap-server')
  AND q.explanation_data IS NOT NULL;

COMMIT;
