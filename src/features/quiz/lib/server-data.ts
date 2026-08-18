import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";
import type { Progress } from "@/features/quiz/lib/types";
import type { ProgressMap } from "@/features/quiz/lib/selection";
import type { SubjectStat } from "@/features/quiz/lib/stats";
import { examGroupKey } from "@/features/quiz/lib/stats";

type Client = SupabaseClient<Database>;

// PostgREST は 1リクエストの返却行数に上限（既定 1000）がある。
// 上限に張り付いた場合は続きがあるとみなし、range で追いかける。
const PAGE = 1000;
const MAX_PAGES = 20;

export async function fetchAllRows<T>(
  page: (from: number, to: number) => PromiseLike<{ data: T[] | null; error: unknown }>
): Promise<T[]> {
  const out: T[] = [];
  for (let i = 0; i < MAX_PAGES; i++) {
    const { data } = await page(i * PAGE, (i + 1) * PAGE - 1);
    if (!data || data.length === 0) break;
    out.push(...data);
    if (data.length < PAGE) break;
  }
  return out;
}

// RPC 未適用（マイグレーション 00144 を流していない）環境では
// PostgREST が 404/PGRST202 を返す。その場合だけ従来経路にフォールバックする。
function isMissingFunction(error: { code?: string; message?: string } | null): boolean {
  if (!error) return false;
  return error.code === "PGRST202" || /function .* does not exist/i.test(error.message ?? "");
}

export interface SubjectStatsRow {
  subjectId: string;
  total: number;
  attempted: number;
  answers: number;
  correct: number;
  lastAnsweredAt: string | null;
}

/**
 * 科目(セット)ごとの学習統計。RPC が使えれば十数行で済み、
 * 使えない場合のみ questions と progress を全件ページングして同じ形に組み立てる。
 */
export async function fetchSubjectStats(
  supabase: Client,
  userId: string
): Promise<{ stats: Map<string, SubjectStatsRow>; usedRpc: boolean }> {
  const { data, error } = await supabase.rpc("subject_stats");

  if (!error && data) {
    const stats = new Map<string, SubjectStatsRow>(
      data.map((r) => [
        r.subject_id,
        {
          subjectId: r.subject_id,
          total: Number(r.total),
          attempted: Number(r.attempted),
          answers: Number(r.answers),
          correct: Number(r.correct),
          lastAnsweredAt: r.last_answered_at,
        },
      ])
    );
    return { stats, usedRpc: true };
  }
  if (!isMissingFunction(error)) {
    console.warn("[server-data] subject_stats failed:", error);
  }

  // ── フォールバック: 全件ページングしてアプリ側で集計 ──
  const [questions, progress] = await Promise.all([
    fetchAllRows<{ id: string; subject_id: string }>((from, to) =>
      supabase.from("questions").select("id, subject_id").eq("is_active", true).range(from, to)
    ),
    fetchAllRows<{
      question_id: string;
      correct_count: number;
      wrong_count: number;
      last_answered_at: string | null;
    }>((from, to) =>
      supabase
        .from("user_question_progress")
        .select("question_id, correct_count, wrong_count, last_answered_at")
        .eq("user_id", userId)
        .range(from, to)
    ),
  ]);

  const byQuestion = new Map(progress.map((p) => [p.question_id, p]));
  const stats = new Map<string, SubjectStatsRow>();
  for (const q of questions) {
    let s = stats.get(q.subject_id);
    if (!s) {
      s = {
        subjectId: q.subject_id,
        total: 0,
        attempted: 0,
        answers: 0,
        correct: 0,
        lastAnsweredAt: null,
      };
      stats.set(q.subject_id, s);
    }
    s.total++;
    const p = byQuestion.get(q.id);
    if (!p) continue;
    const answered = p.correct_count + p.wrong_count;
    if (answered > 0) {
      s.attempted++;
      s.answers += answered;
      s.correct += p.correct_count;
      if (p.last_answered_at && (!s.lastAnsweredAt || p.last_answered_at > s.lastAnsweredAt)) {
        s.lastAnsweredAt = p.last_answered_at;
      }
    }
  }
  return { stats, usedRpc: false };
}

/** SubjectStat[]（既存の集計型）へ変換する。並びは渡した subjects の順を保つ。 */
export function toSubjectStats(
  subjects: { id: string; slug: string; name: string }[],
  stats: Map<string, SubjectStatsRow>
): SubjectStat[] {
  return subjects.map((s) => {
    const a = stats.get(s.id);
    const answers = a?.answers ?? 0;
    return {
      slug: s.slug,
      name: s.name,
      examKey: examGroupKey(s.slug),
      total: a?.total ?? 0,
      attempted: a?.attempted ?? 0,
      answers,
      correct: a?.correct ?? 0,
      accuracy: answers > 0 ? (a?.correct ?? 0) / answers : 0,
      lastAnsweredAt: a?.lastAnsweredAt ?? null,
    };
  });
}

export interface DayCount {
  total: number;
  correct: number;
}

/**
 * JST の暦日キー(YYYY-MM-DD)ごとの解答数。
 *
 * subjectSlugs を渡すとその問題集だけに絞る（問題集スコープのダッシュボード用）。
 * 全体集計は RPC 一発で済むが、絞り込みは対象行数が元々少ないので
 * answer_events を直接引いてアプリ側で畳む（RPC を増やさない）。
 */
export async function fetchDailyCounts(
  supabase: Client,
  userId: string,
  days = 120,
  subjectSlugs?: string[]
): Promise<Map<string, DayCount>> {
  if (!subjectSlugs) {
    const { data, error } = await supabase.rpc("daily_answer_counts", { p_days: days });
    if (!error && data) {
      return new Map(
        data.map((r) => [r.day, { total: Number(r.total), correct: Number(r.correct) }])
      );
    }
    if (!isMissingFunction(error)) {
      console.warn("[server-data] daily_answer_counts failed:", error);
    }
  }

  const since = new Date(Date.now() - days * 86_400_000).toISOString();
  const events = await fetchAllRows<{ answered_at: string; is_correct: boolean }>((from, to) => {
    const q = supabase
      .from("answer_events")
      .select("answered_at, is_correct")
      .eq("user_id", userId)
      .gte("answered_at", since);
    return (subjectSlugs ? q.in("subject_slug", subjectSlugs) : q)
      .order("answered_at", { ascending: false })
      .range(from, to);
  });

  const byDay = new Map<string, DayCount>();
  for (const e of events) {
    const key = jstDayKey(e.answered_at);
    const cur = byDay.get(key) ?? { total: 0, correct: 0 };
    cur.total++;
    if (e.is_correct) cur.correct++;
    byDay.set(key, cur);
  }
  return byDay;
}

/** UTC の ISO 文字列を JST の暦日キーにする。 */
export function jstDayKey(iso: string): string {
  return new Date(new Date(iso).getTime() + 9 * 60 * 60 * 1000).toISOString().slice(0, 10);
}

/** 指定した科目群に属する問題の進捗だけを ProgressMap にして返す。 */
export async function fetchFamilyProgress(
  supabase: Client,
  userId: string,
  subjectIds: string[]
): Promise<ProgressMap> {
  const { data, error } = await supabase.rpc("progress_for_subjects", {
    p_subject_ids: subjectIds,
  });

  let rows = data;
  if (error || !rows) {
    if (!isMissingFunction(error)) {
      console.warn("[server-data] progress_for_subjects failed:", error);
    }
    // ── フォールバック: 全進捗をページングで取り、アプリ側で絞る ──
    const [allProgress, familyQ] = await Promise.all([
      fetchAllRows<Database["public"]["Tables"]["user_question_progress"]["Row"]>((from, to) =>
        supabase.from("user_question_progress").select("*").eq("user_id", userId).range(from, to)
      ),
      fetchAllRows<{ id: string }>((from, to) =>
        supabase
          .from("questions")
          .select("id")
          .eq("is_active", true)
          .in("subject_id", subjectIds)
          .range(from, to)
      ),
    ]);
    const familyIds = new Set(familyQ.map((q) => q.id));
    rows = allProgress.filter((p) => familyIds.has(p.question_id));
  }

  const map: ProgressMap = {};
  for (const p of rows) {
    const prog: Progress = {
      question_id: p.question_id,
      correct_count: p.correct_count,
      wrong_count: p.wrong_count,
      consecutive_correct: p.consecutive_correct,
      last_is_correct: p.last_is_correct,
      last_selected_index: p.last_selected_index,
      last_answered_at: p.last_answered_at,
      understanding_level: p.understanding_level,
      memo: p.memo,
      last_confidence: p.last_confidence ?? null,
      excluded: p.excluded ?? false,
      last_spoken_ok: p.last_spoken_ok ?? null,
      fsrs_stability: p.fsrs_stability ?? null,
      fsrs_difficulty: p.fsrs_difficulty ?? null,
      fsrs_due: p.fsrs_due ?? null,
      fsrs_last_review: p.fsrs_last_review ?? null,
      fsrs_reps: p.fsrs_reps ?? 0,
      fsrs_lapses: p.fsrs_lapses ?? 0,
      fsrs_state: p.fsrs_state ?? "new",
    };
    map[p.question_id] = prog;
  }
  return map;
}

export interface TrendDay {
  day: string; // JST 暦日 YYYY-MM-DD
  total: number;
  correct: number;
  // 確信度の内訳（1=確信あり, 2=迷った, 3=勘, 0=未申告）
  c1: number;
  c2: number;
  c3: number;
}

/**
 * 問題集スコープの推移グラフ用。日別の解答数・正答数・確信度内訳をまとめて返す。
 * 対象が1試験区分ぶんなので行数は数百程度、RPC を足さずに直接引いて畳む。
 */
export async function fetchDailyBreakdown(
  supabase: Client,
  userId: string,
  days: number,
  subjectSlugs: string[]
): Promise<TrendDay[]> {
  const since = new Date(Date.now() - days * 86_400_000).toISOString();
  const events = await fetchAllRows<{
    answered_at: string;
    is_correct: boolean;
    confidence: number | null;
  }>((from, to) =>
    supabase
      .from("answer_events")
      .select("answered_at, is_correct, confidence")
      .eq("user_id", userId)
      .in("subject_slug", subjectSlugs)
      .gte("answered_at", since)
      .order("answered_at", { ascending: false })
      .range(from, to)
  );

  const byDay = new Map<string, TrendDay>();
  for (const e of events) {
    const day = jstDayKey(e.answered_at);
    let d = byDay.get(day);
    if (!d) {
      d = { day, total: 0, correct: 0, c1: 0, c2: 0, c3: 0 };
      byDay.set(day, d);
    }
    d.total++;
    if (e.is_correct) d.correct++;
    if (e.confidence === 1) d.c1++;
    else if (e.confidence === 2) d.c2++;
    else if (e.confidence === 3) d.c3++;
  }

  return [...byDay.values()].sort((a, b) => a.day.localeCompare(b.day));
}
