import type { QuizQuestion, Progress } from "./types";
import type { ProgressMap } from "./selection";
import { getProgress } from "./selection";

// 試験日（目標）。試験区分(exam group)ごとに DB(user_exam_goals)へ保存する。
// 保存/読込は Supabase 経由（RLS で本人のみ）。examKey は examGroupKey(slug)。
export interface UserGoal {
  examDate: string; // YYYY-MM-DD
  targetName: string;
}

// 教科書リンク。試験区分ごとに複数持てる（1 リンク = 1 行）。DB(user_textbooks)。
export interface Textbook {
  id: string;
  label: string;
  url: string;
}

// 進捗(Progress)だけから算出する習得度スコア (0–1)
// accuracy 60% + 確信度 30% + 連続正解ボーナス 10%
// 問題文には依存しないため、問題オブジェクトを持たない集計(試験横断のセクション
// 集計など)からも同じ式を再利用できる。
export function masteryFromProgress(p: Progress): number {
  const attempts = p.correct_count + p.wrong_count;
  if (attempts === 0) return 0;
  const accuracy = p.correct_count / attempts;
  // last_confidence: 1=確信あり→1.0, 2=迷った→0.5, 3=勘→0.0, null→0.0
  const selfScore =
    p.last_confidence === 1 ? 1.0 : p.last_confidence === 2 ? 0.5 : 0.0;
  const streakBonus = Math.min(p.consecutive_correct, 3) / 30; // max 0.1
  return Math.min(1, accuracy * 0.6 + selfScore * 0.3 + streakBonus);
}

// 問題ごとの習得度スコア (0–1)。既存呼び出し互換のための薄いラッパー。
export function questionMastery(_q: QuizQuestion, p: Progress): number {
  return masteryFromProgress(p);
}

// 「間違えた/苦手」問題だけを弱点順に集める。試験区分の全セットを横断させたい場合は
// その試験区分の全問題を questions に渡す（呼び出し側で束ねる）。
//  - 対象: 1回以上解答済み（未着手は「間違えた/苦手」ではないので除外）
//  - 条件: 誤答したことがある(wrong_count>0 か 直近が誤答) OR 習得度 < threshold
//  - 並び: 弱点スコア（誤答が多く正解が少ないほど上位。buildDeck の弱点優先と同基準）
//  - 復習が目的なので休眠(isResting)は無視する（startReview と同じ扱い）。
export function weakReviewPool(
  questions: QuizQuestion[],
  progressMap: ProgressMap,
  opts?: { masteryThreshold?: number; limit?: number }
): QuizQuestion[] {
  const th = opts?.masteryThreshold ?? 0.5;
  const scored: { q: QuizQuestion; score: number }[] = [];
  for (const q of questions) {
    const p = getProgress(progressMap, q.id);
    if (p.correct_count + p.wrong_count === 0) continue; // 未着手は対象外
    const wronged = p.wrong_count > 0 || p.last_is_correct === false;
    const weak = masteryFromProgress(p) < th;
    // Speak-First 科目: MCQ は正解でも口で言えなかった問題は産出の穴として復習対象
    const spokenMiss = p.last_spoken_ok === false;
    if (!wronged && !weak && !spokenMiss) continue;
    const score = q.initial_wrong_weight + p.wrong_count - p.correct_count * 0.6;
    scored.push({ q, score });
  }
  scored.sort((a, b) => b.score - a.score);
  const picked = opts?.limit != null ? scored.slice(0, opts.limit) : scored;
  return picked.map((s) => s.q);
}

export interface MasteryStats {
  avgMastery: number;          // 0–1 全問題平均（未着手=0として含む）
  avgMasteryAttempted: number; // 0–1 試行済みのみの平均
  passProb: number;            // 5–95 (%)
  masteredCount: number;       // mastery >= 0.8（試行済みのみ）
  weakCount: number;           // 試行済み AND mastery < 0.3
  untestedCount: number;       // 未着手（0回答）
  attempted: number;           // 演習済み問題数
  coverage: number;            // attempted / total (0–1)
}

export function calcMasteryStats(
  questions: QuizQuestion[],
  progressMap: ProgressMap
): MasteryStats {
  if (!questions.length) {
    return {
      avgMastery: 0, avgMasteryAttempted: 0, passProb: 5,
      masteredCount: 0, weakCount: 0, untestedCount: 0, attempted: 0, coverage: 0,
    };
  }
  let totalAll = 0;
  let totalAttempted = 0;
  let masteredCount = 0;
  let weakCount = 0;
  let untestedCount = 0;
  let attempted = 0;

  for (const q of questions) {
    const p = getProgress(progressMap, q.id);
    const m = questionMastery(q, p);
    totalAll += m;
    const hasAttempt = p.correct_count + p.wrong_count > 0;
    if (hasAttempt) {
      attempted++;
      totalAttempted += m;
      if (m >= 0.8) masteredCount++;
      if (m < 0.3) weakCount++;
    } else {
      untestedCount++;
    }
  }

  const avgMastery = totalAll / questions.length;
  const avgMasteryAttempted = attempted > 0 ? totalAttempted / attempted : 0;
  const coverage = attempted / questions.length;

  // 合格確率 = 試行済みの習熟度 をベースに、カバレッジが低い分だけ控えめに割り引く
  // 割引: coverage=1.0→係数1.0 / coverage=0.5→係数0.9 / coverage=0→係数0.8
  // 新問題を追加しても avgMasteryAttempted は変わらず、係数も最大20%の変化に抑えられるため安定する
  const coverageFactor = 1 - 0.2 * (1 - coverage);
  const rawScore = attempted > 0 ? avgMasteryAttempted * coverageFactor : 0;
  // ロジスティック関数: center=0.5, k=8 → rawScore=0で約7%、0.5で50%、1.0で約93%
  const logit = 5 + 90 / (1 + Math.exp(-8 * (rawScore - 0.5)));
  const passProb = attempted === 0 ? 5 : Math.max(5, Math.min(95, Math.round(logit)));

  return {
    avgMastery, avgMasteryAttempted, passProb,
    masteredCount, weakCount, untestedCount, attempted, coverage,
  };
}

export interface DailyRec {
  reviewCount: number;   // スペースド反復で今日復習が必要な問題数
  newCount: number;      // 今日の新規ノルマ
  totalNew: number;      // 未着手の全問題数
  daysRemaining: number; // 試験まで残り日数
  dailyNorm: number;     // 1日あたりのベースライン
}

export function calcDailyRec(
  questions: QuizQuestion[],
  progressMap: ProgressMap,
  now: number,
  examDate: string | null
): DailyRec {
  const MS_DAY = 86_400_000;
  const daysRemaining = examDate
    ? Math.max(1, Math.round((new Date(examDate).getTime() - now) / MS_DAY))
    : 30;

  let reviewCount = 0;
  let totalNew = 0;
  for (const q of questions) {
    const p = getProgress(progressMap, q.id);
    const attempts = p.correct_count + p.wrong_count;
    if (attempts === 0) {
      totalNew++;
    } else if (p.last_answered_at) {
      const daysSince = (now - new Date(p.last_answered_at).getTime()) / MS_DAY;
      // 3連続正解→14日、1回以上正解→3日、それ以外→1日で復習
      const interval =
        p.consecutive_correct >= 3 ? 14 : p.consecutive_correct >= 1 ? 3 : 1;
      if (daysSince >= interval) reviewCount++;
    }
  }
  const dailyNorm = Math.max(1, Math.ceil(totalNew / daysRemaining));
  const newCount = Math.min(dailyNorm, totalNew);
  return { reviewCount, newCount, totalNew, daysRemaining, dailyNorm };
}

// 分野別習得率（カテゴリ単位）
export interface CategoryMastery {
  id: string;
  name: string;
  color: string;
  mastery: number;       // 0–1 試行済み問題のみの平均（未着手は含まない）
  masteredCount: number; // mastery >= 0.8
  total: number;         // カテゴリ内全問題数
  attempted: number;     // 試行済み問題数
}

export function calcCategoryMastery(
  categories: { id: string; name: string; color: string }[],
  questions: QuizQuestion[],
  progressMap: ProgressMap
): CategoryMastery[] {
  return categories.map((c) => {
    const qs = questions.filter((q) => q.category_id === c.id);
    if (!qs.length) return { ...c, mastery: 0, masteredCount: 0, total: 0, attempted: 0 };
    let totalMastery = 0;
    let masteredCount = 0;
    let attempted = 0;
    for (const q of qs) {
      const p = getProgress(progressMap, q.id);
      const m = questionMastery(q, p);
      if (p.correct_count + p.wrong_count > 0) {
        attempted++;
        totalMastery += m;
        if (m >= 0.8) masteredCount++;
      }
    }
    return {
      ...c,
      mastery: attempted > 0 ? totalMastery / attempted : 0,
      masteredCount,
      total: qs.length,
      attempted,
    };
  });
}

// ── 試験(exam)横断のセクション別分析 ──────────────────────────────
//
// 同じ試験の問題集でも Set ごとに subject が分かれるため、そのままでは
// 苦手傾向がセット単位に分断される。ここでは「試験」を単位に、共通の
// セクション(=カテゴリ名)で習熟度を合算し、試験全体の苦手傾向を出す。

// 命名規約の例外（同じ試験だが slug 接頭辞が異なるもの）を明示対応付ける。
// 規約（"-<英字>" 除去）では拾えないケースをここで吸収する。
const EXAM_ALIAS: Record<string, string> = {
  // ISTQB CTAL-TA は「CTAL-TA テストアナリスト」と同一試験
  "istqb-ctal-ta": "ctal-ta",
  // 英語・句動詞ドリルはティア(T1/T2/T3)をまたいで1試験として束ねる。
  // 規約の "-<英字>" 除去では pv-t1/pv-t2/pv-t3 の3区分に割れてしまうため明示する。
  "pv-t1-a": "pv",
  "pv-t1-b": "pv",
  "pv-t2-a": "pv",
  "pv-t2-b": "pv",
  "pv-t2-c": "pv",
  "pv-t3-a": "pv",
  "pv-t3-b": "pv",
  "pv-t3-c": "pv",
  "pv-t3-d": "pv",
  "pv-test": "pv",
};

// 英語・句動詞（文産出）ドリルの科目か。この科目では選択肢を見る前に
// 声に出して英作する Speak-First フローを quiz 画面が強制する。
export function isSpeakFirstSubject(slug: string): boolean {
  return slug.startsWith("pv-");
}

// slug から試験キーを返す。まず別名表、無ければ Set 接尾辞 "-<英字1文字>" を除去。
//   istqb-ctal-ta → ctal-ta（別名）
//   gcp-pcde-c → gcp-pcde,  ctal-ta-f → ctal-ta
//   gcp-ace → gcp-ace(不変), dca → dca, gh-200 → gh-200(不変)
export function examGroupKey(slug: string): string {
  return EXAM_ALIAS[slug] ?? slug.replace(/-[a-z]$/, "");
}

// subject 名から Set 表記「(Set X)」等を除いた試験名を返す(表示用)。
export function examDisplayName(subjectName: string): string {
  return subjectName
    .replace(/[（(]\s*Set\s+[A-Za-z][^）)]*[）)]/g, "")
    .replace(/\s+Set\s+[A-Za-z].*$/i, "")
    .replace(/\s{2,}/g, " ")
    .trim();
}

// セクション集計に必要な最小限の問題情報。習熟度は Progress のみから決まるため
// 問題本文や選択肢は不要で、id とセクション(カテゴリ)属性だけを渡せばよい。
export interface SectionCatalogItem {
  id: string;            // question id（progress 参照キー）
  category_name: string; // セクション名（Set 間で共通）
  category_color: string;
  sort: number;          // カテゴリの sort_order（表示順の安定化用）
}

export interface SectionMastery {
  name: string;
  color: string;
  mastery: number;       // 0–1 試行済み問題のみの平均
  masteredCount: number; // mastery >= 0.8 の問題数
  total: number;         // セクション内の全問題数（全Set合算）
  attempted: number;     // 試行済み問題数（全Set合算）
}

// カテゴリ名(=試験セクション)単位で、複数Setをまたいで習熟度を集計する。
export function calcSectionMastery(
  items: SectionCatalogItem[],
  progressMap: ProgressMap
): SectionMastery[] {
  interface Agg {
    color: string;
    sort: number;
    total: number;
    attempted: number;
    sum: number;
    mastered: number;
  }
  const bySection = new Map<string, Agg>();

  for (const it of items) {
    let agg = bySection.get(it.category_name);
    if (!agg) {
      agg = { color: it.category_color, sort: it.sort, total: 0, attempted: 0, sum: 0, mastered: 0 };
      bySection.set(it.category_name, agg);
    }
    agg.sort = Math.min(agg.sort, it.sort);
    agg.total++;
    const p = getProgress(progressMap, it.id);
    if (p.correct_count + p.wrong_count > 0) {
      const m = masteryFromProgress(p);
      agg.attempted++;
      agg.sum += m;
      if (m >= 0.8) agg.mastered++;
    }
  }

  return [...bySection.entries()]
    .sort((x, y) => x[1].sort - y[1].sort || x[0].localeCompare(y[0]))
    .map(([name, a]) => ({
      name,
      color: a.color,
      mastery: a.attempted > 0 ? a.sum / a.attempted : 0,
      masteredCount: a.mastered,
      total: a.total,
      attempted: a.attempted,
    }));
}

// ── 問題集セット一覧: 試験ごとにまとめ、いつ/どれだけ/得点率を出す ──────
//
// セット(subject)が増えて一覧がごちゃつくため、試験(exam)単位にグループ化し、
// 各セットの学習状況(最終学習日・演習量・得点率)を一目で分かるようにする。

// 1問を「どの試験セット(subject)に属するか」で引くための最小参照。
export interface QuestionSubjectRef {
  id: string;   // question id（progress 参照キー）
  slug: string; // subject slug
}

export interface SubjectStat {
  slug: string;
  name: string;
  examKey: string;
  total: number;            // セット内の全問題数
  attempted: number;        // 演習済み問題数（1回以上解答）
  answers: number;          // 総解答回数（correct + wrong の累計）
  correct: number;          // 正解回数の累計
  accuracy: number;         // 0–1 得点率（answers>0 のとき correct/answers）
  lastAnsweredAt: string | null; // 最終学習日時（ISO）
}

export interface ExamGroup {
  examKey: string;
  examName: string;         // 見出し用の試験名（Set 表記を除いた最短名）
  sets: SubjectStat[];
  total: number;            // 試験全体の全問題数
  attempted: number;        // 試験全体の演習済み問題数
  answers: number;          // 試験全体の総解答回数
  correct: number;          // 試験全体の正解回数
  accuracy: number;         // 0–1 試験全体の得点率
  lastAnsweredAt: string | null;
}

// 各セットの学習統計を、全問題の id×slug と進捗から算出する。
export function buildSubjectStats(
  subjects: { slug: string; name: string }[],
  refs: QuestionSubjectRef[],
  progressMap: ProgressMap
): SubjectStat[] {
  interface Agg {
    total: number;
    attempted: number;
    answers: number;
    correct: number;
    last: string | null;
  }
  const agg = new Map<string, Agg>();
  for (const s of subjects) {
    agg.set(s.slug, { total: 0, attempted: 0, answers: 0, correct: 0, last: null });
  }

  for (const ref of refs) {
    const a = agg.get(ref.slug);
    if (!a) continue; // 非アクティブ等、一覧に無いセットは無視
    a.total++;
    const p = getProgress(progressMap, ref.id);
    const answered = p.correct_count + p.wrong_count;
    if (answered > 0) {
      a.attempted++;
      a.answers += answered;
      a.correct += p.correct_count;
      if (p.last_answered_at && (!a.last || p.last_answered_at > a.last)) {
        a.last = p.last_answered_at;
      }
    }
  }

  return subjects.map((s) => {
    const a = agg.get(s.slug)!;
    return {
      slug: s.slug,
      name: s.name,
      examKey: examGroupKey(s.slug),
      total: a.total,
      attempted: a.attempted,
      answers: a.answers,
      correct: a.correct,
      accuracy: a.answers > 0 ? a.correct / a.answers : 0,
      lastAnsweredAt: a.last,
    };
  });
}

// セット統計を試験(exam)単位にまとめる。並びは入力(=sort_order)を維持。
export function groupSubjectsByExam(stats: SubjectStat[]): ExamGroup[] {
  const order: string[] = [];
  const byExam = new Map<string, SubjectStat[]>();
  for (const st of stats) {
    let sets = byExam.get(st.examKey);
    if (!sets) {
      sets = [];
      byExam.set(st.examKey, sets);
      order.push(st.examKey);
    }
    sets.push(st);
  }

  return order.map((examKey) => {
    const sets = byExam.get(examKey)!;
    // 見出しは Set 表記を除いた最短の試験名を採用（無ければ最初の名前）。
    const examName = sets
      .map((s) => examDisplayName(s.name))
      .filter((n) => n.length > 0)
      .sort((a, b) => a.length - b.length)[0] ?? sets[0].name;
    const total = sets.reduce((n, s) => n + s.total, 0);
    const attempted = sets.reduce((n, s) => n + s.attempted, 0);
    const answers = sets.reduce((n, s) => n + s.answers, 0);
    const correct = sets.reduce((n, s) => n + s.correct, 0);
    const lastAnsweredAt = sets.reduce<string | null>(
      (acc, s) => (s.lastAnsweredAt && (!acc || s.lastAnsweredAt > acc) ? s.lastAnsweredAt : acc),
      null
    );
    return {
      examKey,
      examName,
      sets,
      total,
      attempted,
      answers,
      correct,
      accuracy: answers > 0 ? correct / answers : 0,
      lastAnsweredAt,
    };
  });
}

// ── 体系的な苦手分析: 試験全体を分野(セクション)単位に、さらに各分野を
//    Set 別に分解して「全体観 → 分野 → セット」で見渡せるようにする ──────

// 1問を「どのセット・どの分野」に属するかで引くための参照。
export interface SectionQuestionRef {
  id: string;      // question id（progress 参照キー）
  slug: string;    // subject(セット) slug
  section: string; // カテゴリ名（=分野・Set 間で共通化済み前提）
  color: string;
  sort: number;    // カテゴリ sort_order（表示順の安定化）
}

export interface SetBreakdown {
  slug: string;
  total: number;
  attempted: number;
  mastery: number; // 0–1
}

export interface SectionAnalysis {
  name: string;
  color: string;
  sort: number;
  total: number;       // 分野内の全問題数（全Set合算）
  attempted: number;   // 演習済み問題数（全Set合算）
  mastery: number;     // 0–1 分野の習熟度（試行済みのみ平均）
  sets: SetBreakdown[]; // この分野を含むセットごとの内訳（sort 済み: slug 昇順）
}

// 分野ごとに、全Set合算の習熟度＋Set別内訳を算出する。
export function analyzeSections(
  refs: SectionQuestionRef[],
  progressMap: ProgressMap
): SectionAnalysis[] {
  interface SetAgg { total: number; attempted: number; sum: number }
  interface SecAgg {
    color: string;
    sort: number;
    total: number;
    attempted: number;
    sum: number;
    sets: Map<string, SetAgg>;
  }
  const secs = new Map<string, SecAgg>();

  for (const r of refs) {
    let s = secs.get(r.section);
    if (!s) {
      s = { color: r.color, sort: r.sort, total: 0, attempted: 0, sum: 0, sets: new Map() };
      secs.set(r.section, s);
    }
    s.sort = Math.min(s.sort, r.sort);
    s.total++;
    let se = s.sets.get(r.slug);
    if (!se) {
      se = { total: 0, attempted: 0, sum: 0 };
      s.sets.set(r.slug, se);
    }
    se.total++;
    const p = getProgress(progressMap, r.id);
    if (p.correct_count + p.wrong_count > 0) {
      const m = masteryFromProgress(p);
      s.attempted++;
      s.sum += m;
      se.attempted++;
      se.sum += m;
    }
  }

  return [...secs.entries()]
    .sort((a, b) => a[1].sort - b[1].sort || a[0].localeCompare(b[0]))
    .map(([name, s]) => ({
      name,
      color: s.color,
      sort: s.sort,
      total: s.total,
      attempted: s.attempted,
      mastery: s.attempted > 0 ? s.sum / s.attempted : 0,
      sets: [...s.sets.entries()]
        .sort((a, b) => a[0].localeCompare(b[0]))
        .map(([slug, se]) => ({
          slug,
          total: se.total,
          attempted: se.attempted,
          mastery: se.attempted > 0 ? se.sum / se.attempted : 0,
        })),
    }));
}

export interface SectionOverview {
  total: number;
  attempted: number;
  coverage: number;    // 0–1
  mastery: number;     // 0–1 演習済み加重平均
  weakSections: number; // 演習済みで mastery < 0.5 の分野数
  sectionCount: number;
}

// 分野分析から試験全体のサマリ（全体観の見出し用）を作る。
export function sectionOverview(sections: SectionAnalysis[]): SectionOverview {
  let total = 0, attempted = 0, sum = 0, weak = 0;
  for (const s of sections) {
    total += s.total;
    attempted += s.attempted;
    sum += s.mastery * s.attempted;
    if (s.attempted > 0 && s.mastery < 0.5) weak++;
  }
  return {
    total,
    attempted,
    coverage: total > 0 ? attempted / total : 0,
    mastery: attempted > 0 ? sum / attempted : 0,
    weakSections: weak,
    sectionCount: sections.length,
  };
}
