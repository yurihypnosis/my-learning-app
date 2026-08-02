"use client";

import { useMemo, useState } from "react";
import { getProgress, isEligible, type ProgressMap } from "@/features/quiz/lib/selection";
import type { QuizQuestion } from "@/features/quiz/lib/types";
import type { SectionQuestionRef } from "@/features/quiz/lib/stats";

interface Props {
  // 試験区分の全セットの問題（横断プール）
  examQuestions: QuizQuestion[];
  // 分野の表示順（カテゴリ sort_order）を引くためのカタログ
  examSections: SectionQuestionRef[];
  progressMap: ProgressMap;
  now: number;
  // 詳細設定「休眠中も出す」に追従
  includeResting: boolean;
  onStart: (names: Set<string>, count: number, force?: boolean) => void;
}

// テーマ横断演習: 試験区分の全セットから、同じテーマ（分野名）の問題だけを
// 集めて出題する入口。複数テーマ選択可。セット単位の「分野」選択とは独立した
// 選択状態を持ち、セットごとの学習とは切り分けて使う。
export function ThemePractice({
  examQuestions,
  examSections,
  progressMap,
  now,
  includeResting,
  onStart,
}: Props) {
  const [selNames, setSelNames] = useState<Set<string>>(new Set());
  // 0 は「全部」（そのとき出題できる問題ぜんぶ）
  const [count, setCount] = useState(10);

  // 分野名 → 表示順（同名カテゴリが複数セットにあるので sort_order の最小値）
  const sortMap = useMemo(() => {
    const m = new Map<string, number>();
    for (const s of examSections) {
      const cur = m.get(s.section);
      if (cur === undefined || s.sort < cur) m.set(s.section, s.sort);
    }
    return m;
  }, [examSections]);

  // セット横断でテーマ（分野名）に集約。active = 休眠を除いた出題可能数。
  const themes = useMemo(() => {
    const m = new Map<string, { name: string; color: string; total: number; active: number }>();
    for (const q of examQuestions) {
      let t = m.get(q.category_name);
      if (!t) {
        t = { name: q.category_name, color: q.category_color, total: 0, active: 0 };
        m.set(q.category_name, t);
      }
      t.total += 1;
      if (isEligible(getProgress(progressMap, q.id), now)) t.active += 1;
    }
    return [...m.values()].sort(
      (a, b) =>
        (sortMap.get(a.name) ?? 0) - (sortMap.get(b.name) ?? 0) ||
        a.name.localeCompare(b.name, "ja")
    );
  }, [examQuestions, progressMap, now, sortMap]);

  const pool = useMemo(
    () => examQuestions.filter((q) => selNames.has(q.category_name)),
    [examQuestions, selNames]
  );
  const activePool = useMemo(
    () => pool.filter((q) => isEligible(getProgress(progressMap, q.id), now, includeResting)),
    [pool, progressMap, now, includeResting]
  );

  const toggle = (name: string) => {
    const s = new Set(selNames);
    s.has(name) ? s.delete(name) : s.add(name);
    setSelNames(s);
  };

  return (
    <section className="mb-6">
      <p className="mb-1 text-[10px] font-semibold uppercase tracking-widest text-[#555e70]">
        テーマ横断演習
      </p>
      <p className="mb-2 text-xs text-[#555e70]">
        全セットから選んだテーマだけを集めて出題（複数選択可）
      </p>

      <div className="mb-3 flex flex-wrap gap-1.5">
        {themes.map((t) => {
          const on = selNames.has(t.name);
          return (
            <button
              key={t.name}
              onClick={() => toggle(t.name)}
              className="flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs transition"
              style={{
                borderColor: on ? t.color + "55" : "#2a2f3f",
                color: on ? t.color : "#8892a4",
                background: on ? t.color + "0f" : "transparent",
              }}
            >
              <span
                className="h-1.5 w-1.5 shrink-0 rounded-full"
                style={{ background: on ? t.color : "#3a4050" }}
              />
              {t.name}
              <span className="text-[10px] opacity-60">{t.active}</span>
            </button>
          );
        })}
      </div>

      {selNames.size > 0 && (
        <>
          <div className="mb-2 flex overflow-hidden rounded-xl border border-[#2a2f3f]">
            {([5, 10, 20, 0] as const).map((n, i) => {
              const on = count === n;
              return (
                <button
                  key={i}
                  onClick={() => setCount(n)}
                  className="flex-1 border-r border-[#2a2f3f] py-2 text-xs font-medium last:border-r-0 transition"
                  style={{
                    background: on ? "#1e2230" : "transparent",
                    color: on ? "#e8eaf0" : "#8892a4",
                  }}
                >
                  {n === 0 ? `全部 ${activePool.length}` : n}
                </button>
              );
            })}
          </div>

          {activePool.length > 0 ? (
            <button
              onClick={() => onStart(selNames, count || activePool.length)}
              className="w-full rounded-xl border border-[#2a2f3f] py-3 text-sm font-medium text-[#60a5fa] transition hover:border-[#3b82f6]"
            >
              横断スタート — {Math.min(count || activePool.length, activePool.length)} 問
            </button>
          ) : pool.length > 0 ? (
            // 選んだテーマが全問休眠中でも「今やりたい」に応える脱出口
            <div>
              <button
                onClick={() => onStart(selNames, count || pool.length, true)}
                className="w-full rounded-xl border border-[#2a2f3f] py-3 text-sm font-medium text-[#60a5fa] transition hover:border-[#3b82f6]"
              >
                休眠中も含めて横断スタート — {Math.min(count || pool.length, pool.length)} 問
              </button>
              <p className="mt-1.5 text-center text-xs text-[#555e70]">
                選んだテーマはいま全問が休眠中（復習日は先）
              </p>
            </div>
          ) : null}
        </>
      )}
    </section>
  );
}
