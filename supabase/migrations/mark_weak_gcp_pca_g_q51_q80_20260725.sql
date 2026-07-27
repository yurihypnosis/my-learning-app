BEGIN;

INSERT INTO public.user_question_progress
  (user_id, question_id, correct_count, wrong_count, consecutive_correct,
   last_is_correct, last_confidence, understanding_level)
SELECT 'b2b67b17-2354-414e-a433-18964bddbf43'::uuid, q.id, 0, 1, 0, false, 3, 0
FROM public.questions q
JOIN public.subjects s ON s.id = q.subject_id
WHERE s.slug = 'gcp-pca-g'
  AND q.source_ref ~ '^gcp-pca-g-q(5[1-9]|6[0-9]|7[0-9]|80)$'
ON CONFLICT (user_id, question_id) DO UPDATE
SET wrong_count = user_question_progress.wrong_count + 1,
    last_is_correct = false,
    consecutive_correct = 0,
    updated_at = now();

COMMIT;
