BEGIN;

UPDATE public.questions q
SET explanation_data = q.explanation_data || jsonb_build_object('viz', v.viz)
FROM (VALUES
  ('linux-q231', '<svg viewBox="0 0 340 140" xmlns="http://www.w3.org/2000/svg"><rect x="16" y="28" width="98" height="48" rx="8" fill="none" stroke="#3b82f6" stroke-width="1.6"/><text x="65" y="59" font-family="monospace" font-size="15" font-weight="600" fill="#e8eaf0" text-anchor="middle">mkfs</text><text x="128" y="48" font-size="12" fill="#e8eaf0" text-anchor="start"><tspan fill="#60a5fa" font-weight="700">mk</tspan> = make</text><text x="128" y="66" font-size="12" fill="#e8eaf0" text-anchor="start"><tspan fill="#c9a04a" font-weight="700">fs</tspan> = file system</text><line x1="16" y1="92" x2="324" y2="92" stroke="#2a2f3f" stroke-width="1"/><text x="170" y="112" font-size="10.5" fill="#8892a4" text-anchor="middle">区画の中にファイルシステムを新規作成</text></svg>')
) AS v(source_ref, viz)
WHERE q.source_ref = v.source_ref
  AND q.subject_id = (SELECT id FROM public.subjects WHERE slug = 'linux-basics');

COMMIT;
