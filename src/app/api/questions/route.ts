import { getServerSupabase, getSessionUser } from "@/shared/lib/supabase/server";
import type { ExplanationData, QuizQuestion } from "@/features/quiz/lib/types";

// 現在セット以外の問題は、初期表示では本文だけを送っている（解説だけで数百KBあるため）。
// セット横断の演習を始めるときに、その問題ぶんの全カラムをここで取りに来る。
export async function POST(req: Request) {
  const user = await getSessionUser();
  if (!user) return new Response("unauthorized", { status: 401 });

  const body = (await req.json()) as { ids?: unknown };
  const ids = Array.isArray(body.ids) ? body.ids.filter((v): v is string => typeof v === "string") : [];
  if (ids.length === 0) return Response.json({ questions: [] });
  // 1セッションの上限（WEAK_SESSION_MAX 相当）を大きく超える要求は弾く。
  if (ids.length > 200) return new Response("too many ids", { status: 400 });

  const supabase = await getServerSupabase();
  const { data, error } = await supabase
    .from("questions")
    .select(
      "id, category_id, source_ref, question_text, code, options, correct_index, correct_indices, question_type, explanation, explanation_data, initial_wrong_weight, categories(name, color)"
    )
    .in("id", ids);

  if (error) return new Response(error.message, { status: 500 });

  const questions: QuizQuestion[] = (data ?? []).map((q) => {
    const cat = q.categories as unknown as { name?: string; color?: string } | null;
    return {
      id: q.id,
      source_ref: q.source_ref ?? null,
      question_text: q.question_text,
      code: q.code ?? null,
      options: (q.options as string[]) ?? [],
      correct_index: q.correct_index ?? 0,
      correct_indices: (q.correct_indices as number[] | null) ?? null,
      question_type: (q.question_type === "multi" ? "multi" : "single") as "single" | "multi",
      explanation: q.explanation ?? "",
      explanation_data: (q.explanation_data as ExplanationData | null) ?? null,
      initial_wrong_weight: q.initial_wrong_weight,
      category_id: q.category_id,
      category_name: cat?.name ?? "未分類",
      category_color: cat?.color ?? "#64748b",
    };
  });

  return Response.json({ questions });
}
