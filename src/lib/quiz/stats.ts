import type { QuizQuestion, Progress } from "./types";
import type { ProgressMap } from "./selection";
import { getProgress } from "./selection";

// ゴール設定（localStorage に保存）
export interface UserGoal {
  examDate: string; // YYYY-MM-DD
  targetName: string;
}

export function loadGoal(subjectSlug: string): UserGoal | null {
  try {
    const raw = localStorage.getItem(`goal_${subjectSlug}`);
    return raw ? (JSON.parse(raw) as UserGoal) : null;
  } catch {
    return null;
  }
}

export function saveGoal(subjectSlug: string, goal: UserGoal | null): void {
  try {
    if (goal) {
      localStorage.setItem(`goal_${subjectSlug}`, JSON.stringify(goal));
    } else {
      localStorage.removeItem(`goal_${subjectSlug}`);
    }
  } catch {
    // ignore
  }
}

// 問題ごとの習得度スコア (0–1)
// accuracy 60% + 確信度 30% + 連続正解ボーナス 10%
export function questionMastery(q: QuizQuestion, p: Progress): number {
  const attempts = p.correct_count + p.wrong_count;
  if (attempts === 0) return 0;
  const accuracy = p.correct_count / attempts;
  // last_confidence: 1=確信あり→1.0, 2=迷った→0.5, 3=勘→0.0, null→0.0
  const selfScore =
    p.last_confidence === 1 ? 1.0 : p.last_confidence === 2 ? 0.5 : 0.0;
  const streakBonus = Math.min(p.consecutive_correct, 3) / 30; // max 0.1
  return Math.min(1, accuracy * 0.6 + selfScore * 0.3 + streakBonus);
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
