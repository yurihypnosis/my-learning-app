"use client";

import { useEffect, useMemo, useState, type CSSProperties, type ReactNode } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import type { Progress, QuizQuestion } from "@/lib/quiz/types";
import {
  buildDeck,
  eligibleQuestions,
  getProgress,
  type ProgressMap,
} from "@/lib/quiz/selection";
import {
  calcCategoryMastery,
  calcMasteryStats,
  calcSectionMastery,
  questionMastery,
  type SectionCatalogItem,
} from "@/lib/quiz/stats";

/* ============================================================
 * StudyLoop — 理解 → 想起 → 定着
 * Imported from claude.ai/design (StudyLoop.dc.html), ported to
 * React and wired to real Supabase data. The textbook screen keeps
 * the design's demo content (no DB model for it yet).
 * ========================================================== */

const FONT_SANS = "'Noto Sans JP',sans-serif";
const FONT_HEAD = "'Zen Kaku Gothic New',sans-serif";
const FONT_MONO = "'DM Mono',monospace";

type Screen = "today" | "quiz" | "textbook" | "dashboard";

// ── 教科書（デザインのデモコンテンツ）──
type TbBlock =
  | { type: "text"; label: string; color: string; tint: string; text: string }
  | { type: "table"; label: string; color: string; tint: string; headers: string[]; rows: string[][] };
type TbSection = { id: string; cat: string; title: string; blocks: TbBlock[] };

const bg = (text: string): TbBlock => ({ type: "text", label: "背景", color: "#5B6470", tint: "#EEF1F4", text });
const why = (text: string): TbBlock => ({ type: "text", label: "なぜそうなるか", color: "#2E6FB0", tint: "#E9F1F8", text });
const ex = (text: string): TbBlock => ({ type: "text", label: "たとえ話", color: "#3E8E6E", tint: "#E9F4EF", text });
const card = (headers: string[], rows: string[][]): TbBlock => ({
  type: "table", label: "見分けカード", color: "#6E59C0", tint: "#EFECF8", headers, rows,
});

const TEXTBOOK_SECTIONS: TbSection[] = [
  {
    id: "storage-classes", cat: "ストレージ", title: "ストレージクラスの選択",
    blocks: [
      bg("Cloud Storage は1つの API・1つのバケットの中で「ストレージクラス」を切り替えるだけでコスト特性が変わります。バケット既定だけでなく、オブジェクト単位でもクラスを指定できます。"),
      why("保存単価は Standard > Nearline > Coldline > Archive の順で安くなる一方、取り出し（取得）単価と最低保存期間は逆に重くなります。\"安く眠らせる代わりに、起こすと高い\" というトレードオフです。"),
      ex("倉庫の「家賃」と「出庫手数料」の関係。奥にしまうほど月々の家賃は安いが、出すときの手間賃は高くつきます。"),
      card(
        ["クラス", "アクセス頻度", "最低保存", "主な用途"],
        [
          ["Standard", "高頻度", "なし", "配信・稼働中データ"],
          ["Nearline", "月1回程度", "30日", "バックアップ"],
          ["Coldline", "四半期に1回", "90日", "災害復旧"],
          ["Archive", "年1回未満", "365日", "長期アーカイブ・規制保存"],
        ]
      ),
    ],
  },
  {
    id: "iam-roles", cat: "IAM", title: "IAM ロールの選択",
    blocks: [
      bg("GCP の IAM は「誰（プリンシパル）に・何（ロール）を・どこで（リソース階層）」許可するかを決めます。ロールには基本・事前定義・カスタムの3種類があります。"),
      why("基本ロール（オーナー/編集者/閲覧者）は粗く広い旧来の名残。事前定義ロールはサービスごとに最小化された権限束。カスタムロールは権限を自分で選びます。原則は「まず事前定義、足りなければカスタム、基本は極力避ける」。"),
      ex("家全体の合鍵（基本）／部屋ごとの鍵（事前定義）／必要な扉だけ選んで作る特注鍵（カスタム）。"),
      card(
        ["種類", "粒度", "範囲", "使いどき"],
        [
          ["基本ロール", "粗い", "プロジェクト広範", "検証・最小構成のみ"],
          ["事前定義", "中〜細", "サービス単位", "推奨デフォルト"],
          ["カスタム", "細かい", "任意に選択", "事前定義で不足時"],
        ]
      ),
    ],
  },
  {
    id: "compute-options", cat: "コンピューティング", title: "コンピューティングの選択",
    blocks: [
      bg("GCP の主要コンピューティングは抽象度の階段です。VM（自由・手間）→ コンテナ → フルマネージド（楽・制約）へと、管理する範囲が減っていきます。"),
      why("選ぶ軸は3つ。①どこまで自分で管理したいか ②スケール特性（ゼロまで縮む？）③成果物は何か（VM？コンテナ？コード？）。この3軸でほぼ自動的に絞れます。"),
      ex("自炊（Compute Engine）→ ミールキット（GKE / App Engine）→ デリバリー（Cloud Run / Functions）。手間と自由度のトレードオフ。"),
      card(
        ["サービス", "成果物", "管理", "ゼロスケール"],
        [
          ["Compute Engine", "VM", "高い", "×"],
          ["GKE", "コンテナ", "中（クラスタ）", "△"],
          ["Cloud Run", "コンテナ", "最小", "○"],
          ["Cloud Functions", "コード（関数）", "最小", "○"],
        ]
      ),
    ],
  },
];

// カテゴリ名 → 教科書セクション（緩い対応。なければ null）
function sectionForCategory(catName: string): TbSection | null {
  return (
    TEXTBOOK_SECTIONS.find((s) => catName.includes(s.cat) || s.cat.includes(catName)) ?? null
  );
}

// ── 小物 ──
const MS_DAY = 86_400_000;
const WD = ["日", "月", "火", "水", "木", "金", "土"];
const pad2 = (n: number) => String(n).padStart(2, "0");
const trunc = (s: string, n: number) => (s.length > n ? s.slice(0, n) + "…" : s);

function labStyle(c: string, t: string): CSSProperties {
  return {
    fontFamily: FONT_MONO, fontSize: "11px", fontWeight: 500, color: c,
    background: t, padding: "4px 10px", borderRadius: "7px", display: "inline-block",
  };
}

// 復習ステージ（忘却の進み具合）。mastery が低いほど「うろ覚え」
const STAGE_META: Record<number, [string, string, string]> = {
  1: ["うろ覚え", "#C2492E", "#F9ECE8"],
  2: ["要復習", "#C2882E", "#F6EFE0"],
  3: ["定着中", "#2E6FB0", "#E9F1F8"],
  4: ["ほぼ定着", "#3E8E6E", "#E9F4EF"],
};
function masteryStage(m: number): number {
  if (m >= 0.7) return 4;
  if (m >= 0.5) return 3;
  if (m >= 0.3) return 2;
  return 1;
}
function stagePill(stage: number): CSSProperties {
  const [, c, t] = STAGE_META[stage];
  return {
    fontFamily: FONT_MONO, fontSize: "10.5px", padding: "4px 9px", borderRadius: "20px",
    background: t, color: c, fontWeight: 500, whiteSpace: "nowrap", flexShrink: 0,
  };
}

function isDue(p: Progress, now: number): boolean {
  const attempts = p.correct_count + p.wrong_count;
  if (attempts === 0 || !p.last_answered_at) return false;
  const days = (now - Date.parse(p.last_answered_at)) / MS_DAY;
  const interval = p.consecutive_correct >= 3 ? 14 : p.consecutive_correct >= 1 ? 3 : 1;
  return days >= interval;
}

function useIsMobile(): boolean {
  const [m, setM] = useState(false);
  useEffect(() => {
    const mq = window.matchMedia("(max-width: 860px)");
    const on = () => setM(mq.matches);
    on();
    mq.addEventListener("change", on);
    return () => mq.removeEventListener("change", on);
  }, []);
  return m;
}

interface ExpBlock {
  label: string;
  text: string;
  labelStyle: CSSProperties;
  pre?: boolean;
}

// 実データの explanation_data → デザインの解説ブロックへマッピング
function buildExplanation(q: QuizQuestion): { kid: string; blocks: ExpBlock[] } {
  const d = q.explanation_data;
  if (!d) {
    return {
      kid: "",
      blocks: q.explanation
        ? [{ label: "解説", text: q.explanation, labelStyle: labStyle("#4B57C4", "#ECEDF8") }]
        : [],
    };
  }
  const blocks: ExpBlock[] = [];
  if (d.terms && d.terms.length) {
    blocks.push({
      label: "キーワード",
      text: d.terms.map(([t, def]) => `${t} — ${def}`).join("\n"),
      labelStyle: labStyle("#6E59C0", "#EFECF8"),
      pre: true,
    });
  }
  if (d.think) blocks.push({ label: "考え方", text: d.think, labelStyle: labStyle("#2E6FB0", "#E9F1F8") });
  if (d.vs) blocks.push({ label: "混同ポイント", text: d.vs, labelStyle: labStyle("#C2882E", "#F6EFE0") });
  if (d.opt && d.opt.length) {
    blocks.push({
      label: "選択肢の解説",
      text: d.opt.map((o, i) => `${"ABCD"[i]}. ${o}`).join("\n"),
      labelStyle: labStyle("#3E8E6E", "#E9F4EF"),
      pre: true,
    });
  }
  return { kid: d.asked ?? "", blocks };
}

interface Props {
  userId: string;
  subjects: { slug: string; name: string }[];
  currentSubjectSlug: string;
  subjectName: string;
  categories: { id: string; name: string; color: string }[];
  questions: QuizQuestion[];
  // 試験(exam)全体の分析用。同一試験の全Setを合算したセクションカタログ。
  examCatalog: SectionCatalogItem[];
  examName: string;
  examSetCount: number;
  initialProgress: ProgressMap;
  streakDays: number;
  calibration: { sureCorrect: number; sureWrong: number; unsureCorrect: number; unsureWrong: number };
}

const CONF_OPTS: [number, string, string, string][] = [
  [1, "自信あり", "#3E8E6E", "#E9F4EF"],
  [2, "うろ覚え", "#C2882E", "#F6EFE0"],
  [3, "勘", "#9A8F7C", "#F0EDE5"],
];

export function StudyLoopClient({
  userId,
  subjects,
  currentSubjectSlug,
  subjectName,
  categories,
  questions,
  examCatalog,
  examName,
  examSetCount,
  initialProgress,
  streakDays,
  calibration,
}: Props) {
  const router = useRouter();
  const m = useIsMobile();
  const supabase = useMemo(() => createClient(), []);

  const [now, setNow] = useState(0);
  const [progressMap, setProgressMap] = useState<ProgressMap>(initialProgress);
  const [screen, setScreen] = useState<Screen>("today");

  const [deck, setDeck] = useState<QuizQuestion[]>([]);
  const [qIndex, setQIndex] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [multiSel, setMultiSel] = useState<Set<number>>(new Set());
  const [confidence, setConfidence] = useState<number | null>(null);
  const [submitted, setSubmitted] = useState(false);
  const [reTaught, setReTaught] = useState(false);

  const [highlightSection, setHighlightSection] = useState<string | null>(null);
  const [returnBanner, setReturnBanner] = useState(false);

  useEffect(() => {
    setNow(Date.now());
  }, []);

  // ── persistence (existing learning-app と同じ流儀) ──
  const recordAnswer = (q: QuizQuestion, isCorrect: boolean, conf: number | null) => {
    supabase
      .from("answer_events")
      .insert({
        user_id: userId,
        question_id: q.id,
        category_id: q.category_id,
        category_name: q.category_name,
        category_color: q.category_color,
        subject_slug: currentSubjectSlug,
        is_correct: isCorrect,
        confidence: conf,
      })
      .then(({ error }) => {
        if (error) console.error("[answer_events] insert failed:", error.code, error.message);
      });
  };

  const persist = async (qid: string, partial: Partial<Progress>) => {
    const cur = getProgress(progressMap, qid);
    const next: Progress = { ...cur, ...partial };
    setProgressMap((mp) => ({ ...mp, [qid]: next }));
    const { error } = await supabase.from("user_question_progress").upsert(
      {
        user_id: userId,
        question_id: qid,
        correct_count: next.correct_count,
        wrong_count: next.wrong_count,
        consecutive_correct: next.consecutive_correct,
        last_is_correct: next.last_is_correct,
        last_selected_index: next.last_selected_index,
        last_answered_at: next.last_answered_at,
        understanding_level: next.understanding_level,
        memo: next.memo,
        last_confidence: next.last_confidence,
      },
      { onConflict: "user_id,question_id" }
    );
    if (error) console.error("save failed", error);
  };

  // ── derived data ──
  const allCatIds = useMemo(() => new Set(categories.map((c) => c.id)), [categories]);

  const dueList = useMemo(() => {
    if (!now) return [];
    return questions
      .filter((q) => isDue(getProgress(progressMap, q.id), now))
      .map((q) => ({ q, mst: questionMastery(q, getProgress(progressMap, q.id)) }))
      .sort((a, b) => a.mst - b.mst);
  }, [questions, progressMap, now]);

  const eligibleNew = useMemo(() => {
    if (!now) return [];
    return eligibleQuestions(questions, progressMap, allCatIds, now)
      .map((q) => ({ q, mst: questionMastery(q, getProgress(progressMap, q.id)) }))
      .sort((a, b) => a.mst - b.mst);
  }, [questions, progressMap, allCatIds, now]);

  const queue = dueList.length ? dueList : eligibleNew;
  const todayDue = queue.length;

  const masteryStats = useMemo(() => calcMasteryStats(questions, progressMap), [questions, progressMap]);
  const catMastery = useMemo(
    () => calcCategoryMastery(categories, questions, progressMap),
    [categories, questions, progressMap]
  );
  // 試験全体（同一試験の全Set合算）のセクション別習熟度。分析(Dashboard)で使う。
  const examSectionMastery = useMemo(
    () => calcSectionMastery(examCatalog, progressMap),
    [examCatalog, progressMap]
  );

  const avgAccuracy = useMemo(() => {
    let ok = 0;
    let total = 0;
    for (const q of questions) {
      const p = getProgress(progressMap, q.id);
      ok += p.correct_count;
      total += p.correct_count + p.wrong_count;
    }
    return total ? Math.round((ok / total) * 100) : 0;
  }, [questions, progressMap]);

  const weakCatCount = catMastery.filter((c) => c.attempted > 0 && c.mastery < 0.4).length;

  // ── navigation / actions ──
  const goTo = (s: Screen) => {
    if (s === "quiz") {
      startReview();
      return;
    }
    setScreen(s);
    setHighlightSection(null);
    setReturnBanner(false);
  };

  const resetQuizState = () => {
    setSelected(null);
    setMultiSel(new Set());
    setConfidence(null);
    setSubmitted(false);
  };

  const startReview = () => {
    const pool = buildDeck({
      questions,
      progressMap,
      selectedCategoryIds: allCatIds,
      count: 10,
      mode: "priority",
      now: now || Date.now(),
    });
    setDeck(pool);
    setQIndex(0);
    resetQuizState();
    setReTaught(false);
    setReturnBanner(false);
    setHighlightSection(null);
    setScreen("quiz");
  };

  const q = deck[qIndex];
  const total = deck.length;
  const correctSet = useMemo(
    () => new Set(q ? q.correct_indices ?? [q.correct_index] : []),
    [q]
  );

  const selectOption = (i: number) => {
    if (submitted || !q) return;
    if (q.question_type === "multi") {
      setMultiSel((prev) => {
        const s = new Set(prev);
        s.has(i) ? s.delete(i) : s.add(i);
        return s;
      });
    } else {
      setSelected(i);
    }
  };

  const hasSelection = q?.question_type === "multi" ? multiSel.size > 0 : selected !== null;

  const isCorrect = useMemo(() => {
    if (!submitted || !q) return false;
    if (q.question_type === "multi") {
      const sel = [...multiSel].sort((a, b) => a - b);
      const exp = [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b);
      return sel.length === exp.length && sel.every((v, i) => v === exp[i]);
    }
    return selected === q.correct_index;
  }, [submitted, q, multiSel, selected]);

  const submit = () => {
    if (submitted || !q || confidence === null || !hasSelection) return;
    setSubmitted(true);
    const cur = getProgress(progressMap, q.id);
    const correct =
      q.question_type === "multi"
        ? (() => {
            const sel = [...multiSel].sort((a, b) => a - b);
            const exp = [...(q.correct_indices ?? [q.correct_index])].sort((a, b) => a - b);
            return sel.length === exp.length && sel.every((v, i) => v === exp[i]);
          })()
        : selected === q.correct_index;
    const magure = correct && confidence === 3;
    // 表示順でシャッフルしているため、保存は元(DB)のインデックスに戻す
    const selectedOrig =
      q.optionOrder && selected != null ? q.optionOrder[selected] : selected;
    const partial: Partial<Progress> = correct
      ? {
          correct_count: cur.correct_count + 1,
          consecutive_correct: magure ? 0 : cur.consecutive_correct + 1,
          last_is_correct: true,
          last_selected_index: q.question_type === "multi" ? cur.last_selected_index : selectedOrig,
          last_answered_at: new Date().toISOString(),
          last_confidence: confidence,
        }
      : {
          wrong_count: cur.wrong_count + 1,
          consecutive_correct: 0,
          last_is_correct: false,
          last_selected_index: q.question_type === "multi" ? cur.last_selected_index : selectedOrig,
          last_answered_at: new Date().toISOString(),
          last_confidence: confidence,
        };
    persist(q.id, partial);
    recordAnswer(q, correct, confidence);
  };

  const nextAction = () => {
    if (qIndex >= total - 1) {
      setScreen("dashboard");
    } else {
      setQIndex((i) => i + 1);
      resetQuizState();
      setReTaught(false);
      setReturnBanner(false);
    }
  };

  const gotoLink = () => {
    if (!q) return;
    const sec = sectionForCategory(q.category_name);
    setScreen("textbook");
    setHighlightSection(sec ? sec.id : null);
    setReturnBanner(true);
  };
  const backToQuiz = () => {
    setScreen("quiz");
    setReturnBanner(false);
  };
  const reQuiz = () => {
    resetQuizState();
    setReTaught(true);
    setReturnBanner(false);
    setHighlightSection(null);
    setScreen("quiz");
  };

  const switchSubject = (slug: string) => {
    router.push(slug ? `/studyloop?subject=${slug}` : "/studyloop");
  };

  // ── loading ──
  if (!now) {
    return (
      <div style={{ background: "#ECE8E0", height: "calc(100vh - 48px)", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <span style={{ fontFamily: FONT_MONO, fontSize: "12px", color: "#A9A496" }}>読み込み中…</span>
      </div>
    );
  }

  // ── shared styles ──
  const padPage = m ? "18px 16px 30px" : "36px 44px 52px";
  const mainStyle: CSSProperties = { flex: 1, overflowY: "auto", minWidth: 0, background: "#F7F5F0" };
  const screenBox: CSSProperties = m
    ? { height: "100%", display: "flex", flexDirection: "column", background: "#F7F5F0", overflow: "hidden" }
    : { height: "100%", display: "flex", flexDirection: "row-reverse" };
  const navStyle: CSSProperties = m
    ? { height: "62px", flexShrink: 0, background: "#FBFAF6", borderTop: "1px solid #EAE6DC", display: "flex", flexDirection: "row", padding: "0 6px" }
    : { width: "236px", flexShrink: 0, height: "100%", background: "#FBFAF6", borderRight: "1px solid #EAE6DC", display: "flex", flexDirection: "column", padding: "18px 14px", gap: "3px" };

  const navDefs: [Screen, string][] = [
    ["today", "今日"],
    ["quiz", "学習"],
    ["textbook", "教科書"],
    ["dashboard", "進捗"],
  ];

  const todayDateLabel = (() => {
    const d = new Date(now);
    return `${d.getFullYear()}.${pad2(d.getMonth() + 1)}.${pad2(d.getDate())} — ${WD[d.getDay()]}曜日`;
  })();

  const overallPct = masteryStats.passProb;

  return (
    <div style={{ fontFamily: FONT_SANS, height: "calc(100vh - 48px)", background: "#ECE8E0", color: "#1C1B18", overflow: "hidden" }}>
      <link rel="preconnect" href="https://fonts.googleapis.com" />
      <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      <link
        href="https://fonts.googleapis.com/css2?family=Zen+Kaku+Gothic+New:wght@400;500;700&family=Noto+Sans+JP:wght@400;500;700&family=DM+Mono:wght@400;500&display=swap"
        rel="stylesheet"
      />
      <style>{`
        @keyframes slGlow{0%,100%{box-shadow:0 0 0 0 rgba(75,87,196,0);}50%{box-shadow:0 0 0 6px rgba(75,87,196,.10);}}
        .sl-row{transition:all .15s;}
        .sl-row:hover{border-color:#C9C4B8 !important;background:#FCFBF8 !important;}
        .sl-opt{transition:all .15s;}
        .sl-opt:hover{border-color:#B7B1A2 !important;}
        .sl-nav{transition:all .15s;}
        .sl-nav:hover{background:#F0EDE5 !important;}
        .sl-scroll::-webkit-scrollbar{width:10px;height:10px;}
        .sl-scroll::-webkit-scrollbar-track{background:transparent;}
        .sl-scroll::-webkit-scrollbar-thumb{background:#D8D3C7;border-radius:8px;border:3px solid transparent;background-clip:padding-box;}
      `}</style>

      <div style={screenBox}>
        {/* ── main ── */}
        <main className="sl-scroll" style={mainStyle}>
          {screen === "today" && (
            <TodayScreen
              padPage={padPage}
              todayDateLabel={todayDateLabel}
              streakDays={streakDays}
              todayDue={todayDue}
              onStart={startReview}
              miniStats={[
                { label: "習得した概念", value: String(masteryStats.masteredCount) },
                { label: "弱点カテゴリ", value: String(weakCatCount) },
                { label: "平均正答率", value: `${avgAccuracy}%` },
              ]}
              queue={queue.slice(0, 6).map(({ q: it, mst }) => {
                const stage = masteryStage(mst);
                return {
                  concept: trunc(it.question_text, 26),
                  cat: it.category_name,
                  due: "今日",
                  stageLabel: STAGE_META[stage][0],
                  stageStyle: stagePill(stage),
                };
              })}
            />
          )}

          {screen === "quiz" && (
            <QuizScreen
              m={m}
              padPage={padPage}
              q={q}
              total={total}
              qIndex={qIndex}
              submitted={submitted}
              isCorrect={isCorrect}
              selected={selected}
              multiSel={multiSel}
              correctSet={correctSet}
              confidence={confidence}
              reTaught={reTaught}
              onBack={() => goTo("today")}
              onSelect={selectOption}
              onConf={setConfidence}
              onSubmit={submit}
              hasSelection={hasSelection}
              onGotoLink={gotoLink}
              hasSection={!!(q && sectionForCategory(q.category_name))}
              onNext={nextAction}
            />
          )}

          {screen === "textbook" && (
            <TextbookScreen
              m={m}
              padPage={padPage}
              highlightSection={highlightSection}
              returnBanner={returnBanner}
              onBackToQuiz={backToQuiz}
              onReQuiz={reQuiz}
            />
          )}

          {screen === "dashboard" && (
            <DashboardScreen
              m={m}
              padPage={padPage}
              subjectName={subjectName}
              streakDays={streakDays}
              stats={[
                { label: "学習した問題", value: String(masteryStats.attempted), sub: "演習済み", subColor: "#8A867B" },
                { label: "平均正答率", value: `${avgAccuracy}%`, sub: "累計", subColor: "#8A867B" },
                { label: "連続学習", value: `${streakDays}日`, sub: "継続中", subColor: "#3E8E6E" },
                { label: "定着した概念", value: String(masteryStats.masteredCount), sub: "習得済み", subColor: "#3E8E6E" },
              ]}
              calibration={calibration}
              examName={examName}
              examSetCount={examSetCount}
              cats={examSectionMastery
                .filter((c) => c.total > 0)
                .map((c) => ({ name: c.name, pct: Math.round(c.mastery * 100), color: c.color, attempted: c.attempted }))}
            />
          )}
        </main>

        {/* ── side / bottom nav ── */}
        <nav style={navStyle}>
          {!m && (
            <div style={{ padding: "4px 6px 16px", marginBottom: "6px", borderBottom: "1px solid #EAE6DC" }}>
              <div style={{ fontFamily: FONT_MONO, fontSize: "10px", color: "#A9A496", letterSpacing: ".06em" }}>学習中の試験</div>
              {subjects.length > 1 ? (
                <select
                  value={currentSubjectSlug}
                  onChange={(e) => switchSubject(e.target.value)}
                  style={{
                    width: "100%", margin: "6px 0 9px", border: "1px solid #EAE6DC", borderRadius: "8px",
                    background: "#fff", color: "#1C1B18", fontFamily: FONT_HEAD, fontWeight: 700,
                    fontSize: "13px", padding: "6px 8px", outline: "none", cursor: "pointer",
                  }}
                >
                  {subjects.map((s) => (
                    <option key={s.slug} value={s.slug}>{s.name}</option>
                  ))}
                </select>
              ) : (
                <div style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "14px", lineHeight: 1.4, margin: "5px 0 9px" }}>{subjectName}</div>
              )}
              <div style={{ height: "6px", background: "#EAE6DC", borderRadius: "4px", overflow: "hidden" }}>
                <div style={{ height: "100%", width: `${overallPct}%`, background: "#4B57C4", borderRadius: "4px", transition: "width .5s" }} />
              </div>
              <div style={{ fontFamily: FONT_MONO, fontSize: "10px", color: "#8A867B", marginTop: "5px" }}>合格確率 {overallPct}%</div>
            </div>
          )}

          {navDefs.map(([k, label]) => {
            const active = screen === k;
            const ic = active ? (m ? "#4B57C4" : "#FFFFFF") : m ? "#9C988C" : "#8A867B";
            const style: CSSProperties = m
              ? { flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: "3px", padding: "8px 0 6px", border: "none", background: "transparent", cursor: "pointer", color: active ? "#4B57C4" : "#9C988C", fontWeight: active ? 700 : 500, fontFamily: FONT_SANS, fontSize: "10.5px" }
              : { display: "flex", alignItems: "center", gap: "12px", width: "100%", padding: "11px 13px", borderRadius: "11px", border: "none", cursor: "pointer", background: active ? "#4B57C4" : "transparent", color: active ? "#FFFFFF" : "#57544C", fontFamily: FONT_SANS, fontSize: "14px", fontWeight: active ? 700 : 500, transition: "all .15s", textAlign: "left" };
            return (
              <button
                key={k}
                onClick={() => goTo(k)}
                className={!m && !active ? "sl-nav" : undefined}
                style={style}
              >
                <span style={{ display: "flex" }}>{navIcon(k, ic)}</span>
                <span>{label}</span>
              </button>
            );
          })}

          {!m && (
            <div style={{ marginTop: "auto", padding: "12px 6px 2px", borderTop: "1px solid #EAE6DC", display: "flex", alignItems: "center", gap: "8px" }}>
              <div style={{ width: "30px", height: "30px", borderRadius: "9px", background: "#ECEDF8", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: FONT_MONO, fontSize: "13px", color: "#4B57C4", fontWeight: 500, flexShrink: 0 }}>{streakDays}</div>
              <div style={{ fontSize: "11.5px", color: "#57544C", lineHeight: 1.3 }}>連続学習<br /><span style={{ color: "#A9A496", fontSize: "10.5px" }}>継続中</span></div>
            </div>
          )}
        </nav>
      </div>
    </div>
  );
}

/* ============================ Today ============================ */
function TodayScreen({
  padPage, todayDateLabel, streakDays, todayDue, onStart, miniStats, queue,
}: {
  padPage: string;
  todayDateLabel: string;
  streakDays: number;
  todayDue: number;
  onStart: () => void;
  miniStats: { label: string; value: string }[];
  queue: { concept: string; cat: string; due: string; stageLabel: string; stageStyle: CSSProperties }[];
}) {
  return (
    <div style={{ maxWidth: "840px", margin: "0 auto", padding: padPage }}>
      <div style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#A9A496", letterSpacing: ".05em" }}>{todayDateLabel}</div>
      <h1 style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "26px", margin: "6px 0 2px" }}>おかえりなさい</h1>
      <p style={{ margin: "0 0 22px", color: "#57544C", fontSize: "14px" }}>
        今日のループを1周まわしましょう。<span style={{ color: "#4B57C4", fontWeight: 700 }}>{streakDays}日</span>連続で学習中です。
      </p>

      <div style={{ position: "relative", background: "linear-gradient(135deg,#4B57C4,#5E54B8)", borderRadius: "20px", padding: "26px", color: "#fff", overflow: "hidden", boxShadow: "0 12px 30px rgba(75,87,196,.28)" }}>
        <div style={{ fontFamily: FONT_MONO, fontSize: "11px", opacity: 0.85, letterSpacing: ".06em" }}>定着 / 間隔反復</div>
        <div style={{ display: "flex", alignItems: "flex-end", gap: "10px", margin: "8px 0 4px" }}>
          <span style={{ fontSize: "46px", fontWeight: 700, fontFamily: FONT_HEAD, lineHeight: 1 }}>{todayDue}</span>
          <span style={{ fontSize: "15px", opacity: 0.9, paddingBottom: "7px" }}>問が、いま復習どき</span>
        </div>
        <p style={{ margin: "6px 0 18px", fontSize: "13px", opacity: 0.92, maxWidth: "460px", lineHeight: 1.7 }}>
          忘却曲線にのって、忘れかけのタイミングで戻ってきた問題です。ここで想起すると記憶が長期に固定されます。
        </p>
        <button onClick={onStart} style={{ border: "none", cursor: "pointer", background: "#fff", color: "#3A3F9E", fontWeight: 700, fontFamily: FONT_SANS, fontSize: "14px", padding: "12px 22px", borderRadius: "12px", boxShadow: "0 4px 12px rgba(0,0,0,.12)" }}>
          今日の復習を始める →
        </button>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: "12px", margin: "16px 0 26px" }}>
        {miniStats.map((ms, i) => (
          <div key={i} style={{ background: "#fff", border: "1px solid #EAE6DC", borderRadius: "14px", padding: "15px 16px" }}>
            <div style={{ fontSize: "12px", color: "#8A867B" }}>{ms.label}</div>
            <div style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "24px", marginTop: "3px", color: "#1C1B18" }}>{ms.value}</div>
          </div>
        ))}
      </div>

      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "12px" }}>
        <h2 style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "16px", margin: 0 }}>今日のキュー</h2>
        <span style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#A9A496" }}>忘却ステージ順</span>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
        {queue.length === 0 && (
          <div style={{ background: "#fff", border: "1px solid #EAE6DC", borderRadius: "14px", padding: "20px", textAlign: "center", color: "#8A867B", fontSize: "13px" }}>
            いま復習どきの問題はありません。新しい問題から始めましょう。
          </div>
        )}
        {queue.map((it, i) => (
          <button key={i} onClick={onStart} className="sl-row" style={{ display: "flex", alignItems: "center", gap: "14px", textAlign: "left", background: "#fff", border: "1px solid #EAE6DC", borderRadius: "14px", padding: "13px 16px", cursor: "pointer" }}>
            <span style={it.stageStyle}>{it.stageLabel}</span>
            <span style={{ flex: 1, minWidth: 0 }}>
              <span style={{ display: "block", fontWeight: 700, fontSize: "14px", color: "#1C1B18" }}>{it.concept}</span>
              <span style={{ display: "block", fontFamily: FONT_MONO, fontSize: "11px", color: "#A9A496", marginTop: "2px" }}>{it.cat}</span>
            </span>
            <span style={{ fontSize: "12px", color: "#8A867B" }}>{it.due}</span>
            <span style={{ color: "#C9C4B8" }}>→</span>
          </button>
        ))}
      </div>
    </div>
  );
}

/* ============================ Quiz ============================ */
function QuizScreen({
  m, padPage, q, total, qIndex, submitted, isCorrect, selected, multiSel, correctSet,
  confidence, reTaught, onBack, onSelect, onConf, onSubmit, hasSelection, onGotoLink, hasSection, onNext,
}: {
  m: boolean;
  padPage: string;
  q: QuizQuestion | undefined;
  total: number;
  qIndex: number;
  submitted: boolean;
  isCorrect: boolean;
  selected: number | null;
  multiSel: Set<number>;
  correctSet: Set<number>;
  confidence: number | null;
  reTaught: boolean;
  onBack: () => void;
  onSelect: (i: number) => void;
  onConf: (c: number) => void;
  onSubmit: () => void;
  hasSelection: boolean;
  onGotoLink: () => void;
  hasSection: boolean;
  onNext: () => void;
}) {
  if (!q) {
    return (
      <div style={{ maxWidth: "720px", margin: "0 auto", padding: padPage }}>
        <div style={{ background: "#fff", border: "1px solid #EAE6DC", borderRadius: "16px", padding: "40px 24px", textAlign: "center" }}>
          <p style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "18px", margin: "0 0 8px" }}>今日のループは完了です</p>
          <p style={{ color: "#57544C", fontSize: "13.5px", margin: 0 }}>復習できる問題がありません。お疲れさまでした。</p>
          <button onClick={onBack} style={{ marginTop: "20px", border: "none", cursor: "pointer", background: "#1C1B18", color: "#fff", fontWeight: 700, fontFamily: FONT_SANS, fontSize: "14px", padding: "12px 22px", borderRadius: "12px" }}>キューに戻る</button>
        </div>
      </div>
    );
  }

  const progPct = Math.round(((qIndex + (submitted ? 1 : 0)) / Math.max(1, total)) * 100);
  const exp = buildExplanation(q);
  const isWrong = submitted && !isCorrect;
  const showLink = submitted && hasSection && (isWrong || confidence !== 1);
  const ready = hasSelection && confidence !== null;
  const linkTitle = isWrong ? "なぜ間違えた？を、教科書で。" : "正解。でも確信は低めですね。";
  const linkSub = isWrong
    ? `誤答した概念「${q.category_name}」の "なぜ" に、1タップで戻れます。`
    : `「${q.category_name}」を読んで、まぐれを実力に変えましょう。`;

  return (
    <div style={{ maxWidth: "720px", margin: "0 auto", padding: padPage }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "14px" }}>
        <button onClick={onBack} style={{ background: "none", border: "none", cursor: "pointer", color: "#8A867B", fontSize: "13px", fontFamily: FONT_SANS, display: "flex", alignItems: "center", gap: "6px" }}>← キュー</button>
        <span style={{ fontFamily: FONT_MONO, fontSize: "12px", color: "#8A867B" }}>問題 {qIndex + 1} / {total}</span>
      </div>
      <div style={{ height: "5px", background: "#EAE6DC", borderRadius: "4px", overflow: "hidden", marginBottom: "22px" }}>
        <div style={{ height: "100%", background: "#4B57C4", borderRadius: "4px", width: `${progPct}%`, transition: "width .4s" }} />
      </div>

      {reTaught && !submitted && (
        <div style={{ background: "#E9F4EF", border: "1px solid #BFDCCB", borderRadius: "12px", padding: "11px 14px", marginBottom: "16px", fontSize: "13px", color: "#2E7D55", display: "flex", gap: "8px", alignItems: "center", lineHeight: 1.5 }}>
          <b style={{ fontFamily: FONT_MONO, fontSize: "11px", whiteSpace: "nowrap" }}>理解 → 想起</b>
          <span>教科書で固めた状態で、もう一度。今度は想起できますか？</span>
        </div>
      )}

      <div style={{ display: "inline-flex", alignItems: "center", gap: "8px", marginBottom: "10px" }}>
        <span style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#fff", background: "#5B6470", padding: "3px 9px", borderRadius: "6px" }}>{q.category_name}</span>
        <span style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#A9A496" }}>想起フェーズ{q.question_type === "multi" ? " · 複数選択" : ""}</span>
      </div>
      <h1 style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "20px", lineHeight: 1.65, margin: "0 0 22px" }}>{q.question_text}</h1>

      {q.code && (
        <pre style={{ margin: "0 0 22px", overflowX: "auto", borderRadius: "12px", background: "#1C1B18", color: "#E7E3D9", padding: "14px 16px", fontFamily: FONT_MONO, fontSize: "12.5px", lineHeight: 1.6 }}>
          <code>{q.code}</code>
        </pre>
      )}

      <div style={{ display: "flex", flexDirection: "column", gap: "10px", marginBottom: "22px" }}>
        {q.options.map((text, i) => {
          const sel = q.question_type === "multi" ? multiSel.has(i) : selected === i;
          const showC = submitted && correctSet.has(i);
          const showW = submitted && sel && !correctSet.has(i);
          let bgc = "#FFFFFF", border = "#E2DDD2", badgeBg = "#F0EDE5", badgeColor = "#8A867B", mark: string | null = null, markColor = "";
          if (!submitted && sel) { bgc = "#F1F0FB"; border = "#4B57C4"; badgeBg = "#4B57C4"; badgeColor = "#fff"; }
          if (showC) { bgc = "#ECF5EF"; border = "#3E8E6E"; badgeBg = "#3E8E6E"; badgeColor = "#fff"; mark = "正解"; markColor = "#2E7D55"; }
          if (showW) { bgc = "#F9ECE8"; border = "#C2492E"; badgeBg = "#C2492E"; badgeColor = "#fff"; mark = "あなたの解答"; markColor = "#B0432B"; }
          return (
            <button
              key={i}
              onClick={() => onSelect(i)}
              disabled={submitted}
              className={!submitted ? "sl-opt" : undefined}
              style={{ display: "flex", alignItems: "center", gap: "14px", width: "100%", textAlign: "left", padding: m ? "13px 14px" : "15px 18px", borderRadius: "14px", border: "1.5px solid " + border, background: bgc, cursor: submitted ? "default" : "pointer", fontFamily: FONT_SANS, fontSize: m ? "14px" : "15px", color: "#1C1B18", lineHeight: 1.5 }}
            >
              <span style={{ width: "26px", height: "26px", borderRadius: "8px", flexShrink: 0, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: FONT_MONO, fontSize: "13px", fontWeight: 500, background: badgeBg, color: badgeColor }}>{"ABCD"[i] ?? i + 1}</span>
              <span style={{ flex: 1 }}>{text}</span>
              {mark && <span style={{ fontFamily: FONT_MONO, fontSize: "11px", fontWeight: 500, color: markColor, whiteSpace: "nowrap" }}>{mark}</span>}
            </button>
          );
        })}
      </div>

      {!submitted && (
        <>
          <div style={{ marginBottom: "16px" }}>
            <div style={{ fontSize: "12px", color: "#8A867B", marginBottom: "8px" }}>どれくらい自信がありますか？</div>
            <div style={{ display: "flex", gap: "8px" }}>
              {CONF_OPTS.map(([lvl, label, c, t]) => {
                const a = confidence === lvl;
                return (
                  <button key={lvl} onClick={() => onConf(lvl)} style={{ flex: 1, padding: "10px 8px", borderRadius: "11px", border: "1.5px solid " + (a ? c : "#E2DDD2"), background: a ? t : "#fff", color: a ? c : "#8A867B", fontWeight: a ? 700 : 500, cursor: "pointer", fontFamily: FONT_SANS, fontSize: m ? "13px" : "13.5px", transition: "all .15s" }}>{label}</button>
                );
              })}
            </div>
          </div>
          <button onClick={onSubmit} disabled={!ready} style={{ width: "100%", border: "none", cursor: ready ? "pointer" : "not-allowed", background: ready ? "#4B57C4" : "#D8D3C7", color: "#fff", fontWeight: 700, fontFamily: FONT_SANS, fontSize: "15px", padding: "14px", borderRadius: "12px", transition: "all .15s" }}>解答する</button>
        </>
      )}

      {submitted && (
        <>
          <div style={{ display: "flex", gap: "12px", alignItems: "center", padding: "14px 16px", borderRadius: "14px", background: isCorrect ? "#EAF4EE" : "#F9ECE8", border: "1px solid " + (isCorrect ? "#BFDCCB" : "#E6C8BD") }}>
            <span style={{ fontFamily: FONT_MONO, fontSize: "12px", fontWeight: 500, color: "#fff", background: isCorrect ? "#3E8E6E" : "#C2492E", padding: "6px 11px", borderRadius: "8px", flexShrink: 0 }}>{isCorrect ? "正解" : "要復習"}</span>
            <span>
              <b style={{ display: "block", fontFamily: FONT_HEAD, fontSize: "15px" }}>{isCorrect ? "想起に成功" : "惜しい — ここが伸びしろ"}</b>
              <span style={{ fontSize: "12.5px", color: "#57544C" }}>{isCorrect ? "この概念は定着キューへ。次は間隔をあけて再出題されます。" : "誤答こそ価値。理解に戻って、もう一度想起しましょう。"}</span>
            </span>
          </div>

          {showLink && (
            <div style={{ display: "flex", gap: "14px", alignItems: "center", marginTop: "14px", padding: "16px", borderRadius: "14px", background: "#fff", border: "1.5px solid #4B57C4", animation: "slGlow 2.4s ease-in-out infinite" }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#4B57C4", marginBottom: "4px" }}>理解 ⇄ 想起 をつなぐ</div>
                <div style={{ fontWeight: 700, fontSize: "14px", marginBottom: "3px" }}>{linkTitle}</div>
                <div style={{ fontSize: "12.5px", color: "#57544C", lineHeight: 1.55 }}>{linkSub}</div>
              </div>
              <button onClick={onGotoLink} style={{ flexShrink: 0, border: "none", cursor: "pointer", background: "#4B57C4", color: "#fff", fontWeight: 700, fontFamily: FONT_SANS, fontSize: "13px", padding: "11px 16px", borderRadius: "11px", whiteSpace: "nowrap" }}>教科書で理解する →</button>
            </div>
          )}

          {(exp.kid || exp.blocks.length > 0) && (
            <div style={{ background: "#fff", border: "1px solid #EAE6DC", borderRadius: "16px", padding: "20px", marginTop: "14px" }}>
              {exp.kid && (
                <div style={{ display: "flex", gap: "10px", alignItems: "flex-start", marginBottom: "16px", paddingBottom: "16px", borderBottom: "1px dashed #E2DDD2" }}>
                  <span style={{ fontFamily: FONT_MONO, fontSize: "10.5px", color: "#fff", background: "#4B57C4", padding: "4px 8px", borderRadius: "6px", flexShrink: 0, marginTop: "1px", whiteSpace: "nowrap" }}>何を問う</span>
                  <span style={{ fontSize: "14px", lineHeight: 1.65, color: "#1C1B18" }}>{exp.kid}</span>
                </div>
              )}
              <div style={{ display: "flex", flexDirection: "column", gap: "14px" }}>
                {exp.blocks.map((bl, i) => (
                  <div key={i}>
                    <span style={bl.labelStyle}>{bl.label}</span>
                    <p style={{ margin: "7px 0 0", fontSize: "13.5px", lineHeight: 1.8, color: "#33312C", whiteSpace: bl.pre ? "pre-line" : "normal" }}>{bl.text}</p>
                  </div>
                ))}
              </div>
            </div>
          )}

          <button onClick={onNext} style={{ marginTop: "18px", width: "100%", border: "none", cursor: "pointer", background: "#1C1B18", color: "#fff", fontWeight: 700, fontFamily: FONT_SANS, fontSize: "14px", padding: "14px", borderRadius: "12px" }}>{qIndex >= total - 1 ? "結果を見る →" : "次の問題 →"}</button>
        </>
      )}
    </div>
  );
}

/* ============================ Textbook ============================ */
function TextbookScreen({
  m, padPage, highlightSection, returnBanner, onBackToQuiz, onReQuiz,
}: {
  m: boolean;
  padPage: string;
  highlightSection: string | null;
  returnBanner: boolean;
  onBackToQuiz: () => void;
  onReQuiz: () => void;
}) {
  const hlSec = TEXTBOOK_SECTIONS.find((s) => s.id === highlightSection);
  return (
    <div>
      {returnBanner && (
        <div style={{ position: "sticky", top: 0, zIndex: 5, background: "#4B57C4", color: "#fff", padding: "11px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px", fontSize: "13px" }}>
          <span style={{ display: "flex", gap: "8px", alignItems: "center", lineHeight: 1.4 }}>
            <b style={{ fontFamily: FONT_MONO, fontSize: "11px", whiteSpace: "nowrap" }}>想起から来ました</b>
            <span>{hlSec ? `「${hlSec.title}」を読んで、理解したら問題に戻りましょう。` : "理解したら問題に戻りましょう。"}</span>
          </span>
          <button onClick={onBackToQuiz} style={{ border: "none", cursor: "pointer", background: "#fff", color: "#3A3F9E", fontWeight: 700, fontFamily: FONT_SANS, fontSize: "12.5px", padding: "7px 13px", borderRadius: "9px", whiteSpace: "nowrap" }}>問題に戻る</button>
        </div>
      )}

      <div style={{ display: "flex", gap: "28px", maxWidth: "980px", margin: "0 auto", padding: padPage }}>
        {!m && (
          <aside style={{ width: "188px", flexShrink: 0, position: "sticky", top: "24px", alignSelf: "flex-start" }}>
            <div style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#A9A496", marginBottom: "10px", letterSpacing: ".04em" }}>目次</div>
            <div style={{ display: "flex", flexDirection: "column", gap: "2px" }}>
              {TEXTBOOK_SECTIONS.map((s) => {
                const a = highlightSection === s.id;
                return (
                  <a key={s.id} href={`#${s.id}`} style={{ textDecoration: "none", fontSize: "13px", padding: "7px 10px", borderRadius: "8px", color: a ? "#4B57C4" : "#57544C", background: a ? "#ECEDF8" : "transparent", fontWeight: a ? 700 : 500, borderLeft: "2px solid " + (a ? "#4B57C4" : "transparent") }}>{s.title}</a>
                );
              })}
            </div>
            <div style={{ marginTop: "18px", fontFamily: FONT_MONO, fontSize: "10.5px", color: "#A9A496", borderTop: "1px solid #EAE6DC", paddingTop: "12px", lineHeight: 1.7 }}>デモ教科書<br />GCP ACE</div>
          </aside>
        )}

        <div style={{ flex: 1, minWidth: 0, display: "flex", flexDirection: "column", gap: "24px" }}>
          {TEXTBOOK_SECTIONS.map((sec) => {
            const hl = highlightSection === sec.id;
            return (
              <section
                key={sec.id}
                id={sec.id}
                style={hl
                  ? { background: "#fff", border: "2px solid #4B57C4", borderRadius: "18px", padding: m ? "20px" : "26px", boxShadow: "0 8px 24px rgba(75,87,196,.12)", scrollMarginTop: "12px" }
                  : { background: "#fff", border: "1px solid #EAE6DC", borderRadius: "18px", padding: m ? "20px" : "26px", scrollMarginTop: "12px" }}
              >
                {hl && <div style={{ fontFamily: FONT_MONO, fontSize: "10.5px", color: "#4B57C4", background: "#ECEDF8", display: "inline-block", padding: "3px 9px", borderRadius: "6px", marginBottom: "10px" }}>ここから来ました ↓</div>}
                <div style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#A9A496" }}>{sec.cat}</div>
                <h2 style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "22px", margin: "4px 0 18px" }}>{sec.title}</h2>
                <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                  {sec.blocks.map((b, i) => (
                    <div key={i}>
                      <span style={labStyle(b.color, b.tint)}>{b.label}</span>
                      {b.type === "text" ? (
                        <p style={{ margin: "8px 0 0", fontSize: "14px", lineHeight: 1.85, color: "#33312C" }}>{b.text}</p>
                      ) : (
                        <TbTable headers={b.headers} rows={b.rows} />
                      )}
                    </div>
                  ))}
                </div>
                {hl && returnBanner && (
                  <button onClick={onReQuiz} style={{ marginTop: "20px", border: "none", cursor: "pointer", background: "#3E8E6E", color: "#fff", fontWeight: 700, fontFamily: FONT_SANS, fontSize: "13.5px", padding: "12px 18px", borderRadius: "11px" }}>理解した。もう一度解く →</button>
                )}
              </section>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function TbTable({ headers, rows }: { headers: string[]; rows: string[][] }) {
  const cols = `1.2fr ${Array(headers.length - 1).fill("1fr").join(" ")}`;
  return (
    <div style={{ marginTop: "10px", border: "1px solid #EAE6DC", borderRadius: "12px", overflow: "hidden", overflowX: "auto" }}>
      <div style={{ display: "grid", gridTemplateColumns: cols, background: "#F4F1EA", fontFamily: FONT_MONO, fontSize: "11px", color: "#57544C", minWidth: "520px" }}>
        {headers.map((h, i) => (
          <div key={i} style={{ padding: "9px 12px" }}>{h}</div>
        ))}
      </div>
      {rows.map((r, ri) => (
        <div key={ri} style={{ display: "grid", gridTemplateColumns: cols, borderTop: "1px solid #EFEBE2", background: ri % 2 ? "#FCFBF8" : "#FFFFFF", minWidth: "520px", alignItems: "center" }}>
          {r.map((c, ci) => (
            <div key={ci} style={ci === 0
              ? { padding: "10px 12px", fontWeight: 700, fontSize: "12.5px", color: "#1C1B18" }
              : { padding: "10px 12px", fontSize: "12.5px", color: "#57544C" }}>{c}</div>
          ))}
        </div>
      ))}
    </div>
  );
}

/* ============================ Dashboard ============================ */
function DashboardScreen({
  m, padPage, subjectName, stats, calibration, cats, examName, examSetCount,
}: {
  m: boolean;
  padPage: string;
  subjectName: string;
  streakDays: number;
  stats: { label: string; value: string; sub: string; subColor: string }[];
  calibration: { sureCorrect: number; sureWrong: number; unsureCorrect: number; unsureWrong: number };
  cats: { name: string; pct: number; color: string; attempted: number }[];
  examName: string;
  examSetCount: number;
}) {
  // 分野別分析は試験全体（全Set合算）。複数Setがある試験のみ合算バッジを出す。
  const sectionScope =
    examSetCount > 1 ? `${examName || "この試験"}・全${examSetCount}セット合算` : subjectName;
  const barColor = (p: number) => (p >= 70 ? "#3E8E6E" : p >= 50 ? "#2E6FB0" : p >= 40 ? "#C2882E" : "#C2492E");
  const heatStyle = (p: number, attempted: number): CSSProperties => {
    let bgc: string, col: string, bd: string;
    if (attempted === 0) { bgc = "#F4F1EA"; col = "#A9A496"; bd = "#EAE6DC"; }
    else if (p >= 70) { bgc = "#2E7D55"; col = "#fff"; bd = "#2E7D55"; }
    else if (p >= 55) { bgc = "#DCEBE0"; col = "#2E7D55"; bd = "#C4DDCB"; }
    else if (p >= 42) { bgc = "#F4E6CC"; col = "#9A6A1E"; bd = "#E6D2A8"; }
    else { bgc = "#F2D9D2"; col = "#B0432B"; bd = "#E6C0B5"; }
    return { background: bgc, color: col, border: "1px solid " + bd, borderRadius: "12px", padding: "12px 13px" };
  };

  return (
    <div style={{ maxWidth: "880px", margin: "0 auto", padding: padPage }}>
      <h1 style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "24px", margin: "0 0 4px" }}>学習サマリー</h1>
      <p style={{ margin: "0 0 22px", color: "#57544C", fontSize: "13.5px", lineHeight: 1.6 }}>
        {subjectName} ・「自信」を添えた解答が、次のループの優先度を決めます。
      </p>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(140px,1fr))", gap: "12px", marginBottom: "22px" }}>
        {stats.map((s, i) => (
          <div key={i} style={{ background: "#fff", border: "1px solid #EAE6DC", borderRadius: "14px", padding: "16px" }}>
            <div style={{ fontSize: "12px", color: "#8A867B" }}>{s.label}</div>
            <div style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "26px", margin: "4px 0 2px", color: "#1C1B18" }}>{s.value}</div>
            <div style={{ fontFamily: FONT_MONO, fontSize: "10.5px", color: s.subColor }}>{s.sub}</div>
          </div>
        ))}
      </div>

      <div style={{ display: "grid", gridTemplateColumns: m ? "1fr" : "1.1fr 1fr", gap: "14px", marginBottom: "24px" }}>
        <div style={{ background: "#F9ECE8", border: "1px solid #E6C8BD", borderRadius: "16px", padding: "20px" }}>
          <div style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#B0432B", marginBottom: "8px" }}>確信度キャリブレーション</div>
          <div style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "19px", lineHeight: 1.5, color: "#1C1B18" }}>
            「自信あり」なのに誤答 <span style={{ color: "#C2492E" }}>{calibration.sureWrong}問</span>
          </div>
          <p style={{ margin: "8px 0 0", fontSize: "13px", color: "#57544C", lineHeight: 1.65 }}>
            {calibration.sureWrong > 0
              ? "思い込みの危険ゾーン。正答より価値の高い、最優先の復習対象です。"
              : "いまのところ思い込みの誤答はありません。キャリブレーション良好です。"}
          </p>
        </div>
        <div style={{ background: "#fff", border: "1px solid #EAE6DC", borderRadius: "16px", padding: "18px" }}>
          <div style={{ fontSize: "12px", color: "#8A867B", marginBottom: "12px" }}>確信度 × 正誤</div>
          <div style={{ display: "grid", gridTemplateColumns: "62px 1fr 1fr", gap: "6px" }}>
            <div />
            <div style={{ textAlign: "center", fontFamily: FONT_MONO, fontSize: "10.5px", color: "#8A867B" }}>正解</div>
            <div style={{ textAlign: "center", fontFamily: FONT_MONO, fontSize: "10.5px", color: "#8A867B" }}>誤答</div>
            <div style={{ fontFamily: FONT_MONO, fontSize: "10.5px", color: "#8A867B", display: "flex", alignItems: "center" }}>自信あり</div>
            <div style={{ background: "#EAF4EE", borderRadius: "8px", padding: "9px", textAlign: "center", fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "18px", color: "#2E7D55" }}>{calibration.sureCorrect}</div>
            <div style={{ background: "#F9ECE8", border: "1.5px solid #C2492E", borderRadius: "8px", padding: "9px", textAlign: "center", fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "18px", color: "#C2492E" }}>{calibration.sureWrong}</div>
            <div style={{ fontFamily: FONT_MONO, fontSize: "10.5px", color: "#8A867B", display: "flex", alignItems: "center" }}>自信なし</div>
            <div style={{ background: "#F4F1EA", borderRadius: "8px", padding: "9px", textAlign: "center", fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "18px", color: "#57544C" }}>{calibration.unsureCorrect}</div>
            <div style={{ background: "#F4F1EA", borderRadius: "8px", padding: "9px", textAlign: "center", fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "18px", color: "#57544C" }}>{calibration.unsureWrong}</div>
          </div>
        </div>
      </div>

      <div style={{ display: "flex", alignItems: "baseline", flexWrap: "wrap", gap: "8px", margin: "0 0 14px" }}>
        <h2 style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "16px", margin: 0 }}>分野別マスタリー</h2>
        <span style={{ fontFamily: FONT_MONO, fontSize: "11px", color: "#8A867B" }}>{sectionScope}</span>
        {examSetCount > 1 && (
          <span style={{ fontFamily: FONT_MONO, fontSize: "10px", color: "#4B57C4", background: "#ECEDF8", borderRadius: "6px", padding: "2px 7px" }}>
            セット横断
          </span>
        )}
      </div>
      <div style={{ background: "#fff", border: "1px solid #EAE6DC", borderRadius: "16px", padding: "20px", marginBottom: "24px", display: "flex", flexDirection: "column", gap: "14px" }}>
        {cats.length === 0 && <div style={{ color: "#8A867B", fontSize: "13px" }}>まだデータがありません。</div>}
        {cats.map((c, i) => (
          <div key={i}>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: "13px", marginBottom: "6px" }}>
              <span style={{ fontWeight: 500 }}>{c.name}</span>
              <span style={{ fontFamily: FONT_MONO, color: "#8A867B" }}>{c.attempted === 0 ? "未着手" : `${c.pct}%`}</span>
            </div>
            <div style={{ height: "8px", background: "#F0EDE5", borderRadius: "5px", overflow: "hidden" }}>
              <div style={{ height: "100%", borderRadius: "5px", width: `${c.attempted === 0 ? 0 : c.pct}%`, background: barColor(c.pct), transition: "width .5s" }} />
            </div>
          </div>
        ))}
      </div>

      <h2 style={{ fontFamily: FONT_HEAD, fontWeight: 700, fontSize: "16px", margin: "0 0 6px" }}>弱点ヒートマップ</h2>
      <p style={{ margin: "0 0 14px", color: "#8A867B", fontSize: "12.5px" }}>赤いほど弱点。緑は定着しているカテゴリです。</p>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(128px,1fr))", gap: "8px" }}>
        {cats.map((c, i) => (
          <div key={i} style={heatStyle(c.pct, c.attempted)}>
            <div style={{ fontSize: "12px", fontWeight: 700, lineHeight: 1.3 }}>{c.name}</div>
            <div style={{ fontFamily: FONT_MONO, fontSize: "15px", marginTop: "6px" }}>{c.attempted === 0 ? "—" : `${c.pct}%`}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ============================ Icons ============================ */
function navIcon(k: Screen, c: string): ReactNode {
  const common = { width: 18, height: 18, viewBox: "0 0 18 18", fill: "none" as const };
  if (k === "today")
    return (
      <svg {...common}>
        <circle cx={9} cy={9} r={5.4} stroke={c} strokeWidth={1.6} />
        <circle cx={9} cy={9} r={1.7} fill={c} />
      </svg>
    );
  if (k === "quiz")
    return (
      <svg {...common}>
        <rect x={3} y={3} width={12} height={12} rx={3.4} stroke={c} strokeWidth={1.6} />
        <path d="M6 9.2l2 2 4-4.2" stroke={c} strokeWidth={1.6} strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    );
  if (k === "textbook")
    return (
      <svg {...common}>
        <rect x={3.5} y={3.5} width={11} height={11} rx={1.6} stroke={c} strokeWidth={1.6} />
        <line x1={9} y1={3.5} x2={9} y2={14.5} stroke={c} strokeWidth={1.4} />
      </svg>
    );
  return (
    <svg {...common}>
      <line x1={5} y1={14} x2={5} y2={9} stroke={c} strokeWidth={1.8} strokeLinecap="round" />
      <line x1={9} y1={14} x2={9} y2={6} stroke={c} strokeWidth={1.8} strokeLinecap="round" />
      <line x1={13} y1={14} x2={13} y2={11} stroke={c} strokeWidth={1.8} strokeLinecap="round" />
    </svg>
  );
}
