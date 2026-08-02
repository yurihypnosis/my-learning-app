-- explanation_data.calc が文字列ではなくオブジェクト({steps, formula})になっている行を修正。
-- RichExplanation が <pre>{data.calc}</pre> で直接描画するため、オブジェクトだと
-- 「Objects are not valid as a React child」でアプリ全体がクラッシュしていた。
-- steps を改行結合し、formula を最後の行に追記して1本の文字列に変換する。
BEGIN;

UPDATE questions
SET explanation_data = jsonb_set(
  explanation_data,
  '{calc}',
  to_jsonb(
    (SELECT string_agg(step, E'\n') FROM jsonb_array_elements_text(explanation_data->'calc'->'steps') AS step)
    || E'\n' || (explanation_data->'calc'->>'formula')
  )
)
WHERE jsonb_typeof(explanation_data->'calc') = 'object';

COMMIT;
