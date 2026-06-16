import {
  emptyProgress,
  TWO_WEEKS_MS,
  WEEK_MS,
  type Progress,
  type QuizMode,
  type QuizQuestion,
} from "./types";

export type ProgressMap = Record<string, Progress>;

export function getProgress(map: ProgressMap, questionId: string): Progress {
  return map[questionId] ?? emptyProgress(questionId);
}

// 弱点優先の指標: 模試の初期誤答 + 自分の誤答回数
export function totalWrong(q: QuizQuestion, p: Progress): number {
  return q.initial_wrong_weight + p.wrong_count;
}

export function totalCorrect(p: Progress): number {
  return p.correct_count;
}

// 間隔反復: 出題対象から外す（休眠）かどうか
//  - 2週間ルール: 3回連続正解した問題は、最後の解答から2週間出題しない
//  - 1週間ルール: 正解かつ理解度「完璧」の問題は、最後の解答から1週間出題しない
export function isResting(p: Progress, now: number): boolean {
  if (!p.last_answered_at) return false;
  const lastTs = Date.parse(p.last_answered_at);
  if (Number.isNaN(lastTs)) return false;

  const twoWeekRule = p.consecutive_correct >= 3 && now - lastTs < TWO_WEEKS_MS;
  const oneWeekRule =
    p.last_is_correct === true &&
    p.understanding_level === 4 &&
    now - lastTs < WEEK_MS;

  return twoWeekRule || oneWeekRule;
}

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// 出題対象（分野で絞り、休眠を除外）
export function eligibleQuestions(
  questions: QuizQuestion[],
  progressMap: ProgressMap,
  selectedCategoryIds: Set<string>,
  now: number
): QuizQuestion[] {
  return questions.filter(
    (q) =>
      selectedCategoryIds.has(q.category_id) &&
      !isResting(getProgress(progressMap, q.id), now)
  );
}

export interface BuildDeckArgs {
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  selectedCategoryIds: Set<string>;
  count: number;
  mode: QuizMode;
  now: number;
}

// 出題デッキを生成
export function buildDeck({
  questions,
  progressMap,
  selectedCategoryIds,
  count,
  mode,
  now,
}: BuildDeckArgs): QuizQuestion[] {
  const pool = eligibleQuestions(questions, progressMap, selectedCategoryIds, now);

  if (mode === "priority") {
    const sorted = [...pool].sort((a, b) => {
      const pa = getProgress(progressMap, a.id);
      const pb = getProgress(progressMap, b.id);
      const scoreA = totalWrong(a, pa) - totalCorrect(pa) * 0.6;
      const scoreB = totalWrong(b, pb) - totalCorrect(pb) * 0.6;
      return scoreB - scoreA;
    });
    return shuffle(sorted.slice(0, count));
  }

  return shuffle(pool).slice(0, count);
}
