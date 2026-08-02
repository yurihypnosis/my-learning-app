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

// 間隔反復: 出題対象から外す（休眠）かどうか。
//  - FSRS 復習済みカードは、次の復習日(due)まで休眠（=科学的な間隔）。
//  - まだ FSRS 状態が無いカードは旧ルール（2週間/1週間）にフォールバック。
//    (2週間: 3回連続正解 / 1週間: 正解かつ理解度「完璧」)
export function isResting(p: Progress, now: number): boolean {
  // FSRS が有効なカードは due 基準で判定する
  if (p.fsrs_state === "review" && p.fsrs_due) {
    const due = Date.parse(p.fsrs_due);
    if (!Number.isNaN(due)) return due > now;
  }

  // 旧ロジック（FSRS 未適用カードのフォールバック）
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

// 出題対象かどうか（休眠中でなく、かつ「もう出題しない」で除外されていない）。
export function isEligible(p: Progress, now: number, includeResting = false): boolean {
  return !p.excluded && (includeResting || !isResting(p, now));
}

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// 解説の自由文が選択肢を「位置ラベル」で参照しているかを判定する。
// 例:「選択肢Bは過剰装備」「正解はC」「（A）を決めて…」。これらは DB の元順を
// 前提に書かれているため、表示順をシャッフルすると本文と選択肢が食い違う。
// 円数字（①②③）は単なる箇条書きにも多用され選択肢参照と判別できないため対象外。
// 「選択肢」接頭辞・括弧・「正解は」等の強い文脈を要求し、DB / GB 等の誤検出を避ける。
const OPTION_REF_RE =
  /(選択肢\s*[A-DＡ-Ｄa-dａ-ｄ])|([（(]\s*[A-DＡ-Ｄ]\s*[）)])|(正解は\s*[A-DＡ-Ｄ])|([A-DＡ-Ｄ]\s*が正解)/;

export function referencesOptionPositions(q: QuizQuestion): boolean {
  const d = q.explanation_data;
  // opt（選択肢別解説）は順序に追従して付け替えるので対象外。本文と自由文のみ検査。
  const texts = [q.explanation, d?.asked, d?.think, d?.vs];
  return texts.some((t) => typeof t === "string" && OPTION_REF_RE.test(t));
}

// 選択肢を表示用にシャッフルする。DB のデータ（options / correct_index）はそのままで、
// 返す QuizQuestion 上でのみ順序を入れ替える。正解が A に偏る問題への対策。
// 選択肢の並びに追従して correct_index・correct_indices・選択肢解説(opt) も付け替えるため、
// レンダリング・採点・解説すべてが表示順のインデックスで一貫して動く。
export function shuffleOptions(q: QuizQuestion): QuizQuestion {
  const n = q.options.length;
  if (n <= 1) return q;

  // 選択肢解説が選択肢数と一致しない場合は、付け替えると解説が崩れるためシャッフルしない
  const opt = q.explanation_data?.opt;
  if (opt && opt.length !== n) return q;

  // 解説の自由文が選択肢を位置ラベルで参照している場合、順序を入れ替えると
  // 本文（例:「選択肢Bは過剰装備」）と表示が食い違うためシャッフルしない。
  if (referencesOptionPositions(q)) return q;

  const perm = shuffle(Array.from({ length: n }, (_, i) => i)); // perm[表示index] = 元index
  const origToDisp = new Array<number>(n);
  perm.forEach((orig, disp) => {
    origToDisp[orig] = disp;
  });

  return {
    ...q,
    options: perm.map((orig) => q.options[orig]),
    correct_index: origToDisp[q.correct_index],
    correct_indices: q.correct_indices
      ? q.correct_indices.map((ci) => origToDisp[ci]).sort((a, b) => a - b)
      : null,
    explanation_data:
      q.explanation_data && opt
        ? { ...q.explanation_data, opt: perm.map((orig) => opt[orig]) }
        : q.explanation_data,
    optionOrder: perm,
  };
}

// 出題対象（分野で絞り、休眠を除外）。
// includeResting=true のときは休眠中も含める（「復習したい時に出せない」を避ける手動オプション）。
export function eligibleQuestions(
  questions: QuizQuestion[],
  progressMap: ProgressMap,
  selectedCategoryIds: Set<string>,
  now: number,
  includeResting = false
): QuizQuestion[] {
  return questions.filter(
    (q) =>
      selectedCategoryIds.has(q.category_id) &&
      isEligible(getProgress(progressMap, q.id), now, includeResting)
  );
}

export interface BuildDeckArgs {
  questions: QuizQuestion[];
  progressMap: ProgressMap;
  selectedCategoryIds: Set<string>;
  count: number;
  mode: QuizMode;
  now: number;
  // true なら休眠中の問題も出題対象に含める（手動復習用）。
  includeResting?: boolean;
}

// 出題デッキを生成
export function buildDeck({
  questions,
  progressMap,
  selectedCategoryIds,
  count,
  mode,
  now,
  includeResting = false,
}: BuildDeckArgs): QuizQuestion[] {
  const pool = eligibleQuestions(questions, progressMap, selectedCategoryIds, now, includeResting);

  if (mode === "priority") {
    const sorted = [...pool].sort((a, b) => {
      const pa = getProgress(progressMap, a.id);
      const pb = getProgress(progressMap, b.id);
      const scoreA = totalWrong(a, pa) - totalCorrect(pa) * 0.6;
      const scoreB = totalWrong(b, pb) - totalCorrect(pb) * 0.6;
      return scoreB - scoreA;
    });
    return shuffle(sorted.slice(0, count)).map(shuffleOptions);
  }

  return shuffle(pool).slice(0, count).map(shuffleOptions);
}
