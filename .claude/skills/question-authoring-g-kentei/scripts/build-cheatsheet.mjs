#!/usr/bin/env node
// 標準入力から build-cheatsheet.sh の生クエリ結果(質問単位の配列)を受け取り、
// 「用語ごとの辞書(terms.json)」と「紛らわしい概念グループ(comparisons.json)」を書き出す。
// 新しい解説文は作らない — 既存の terms/vs をそのまま集約・再配置するだけ。
import fs from "node:fs";

const raw = JSON.parse(fs.readFileSync(0, "utf8"));
const [termsOut, comparisonsOut] = process.argv.slice(2);

const categorySort = new Map();
for (const row of raw) categorySort.set(row.category, row.category_sort);

// ── 用語辞書: 同じ用語が複数問で少しずつ違う言い回しの定義を持つので、
//    最も長い(=情報量が多いとみなせる)ものを代表定義にし、他は言い換えとして残す。
const termAgg = new Map();
for (const row of raw) {
  for (const [term, def] of row.terms) {
    let t = termAgg.get(term);
    if (!t) {
      t = { defs: new Map(), categories: new Map(), questionIds: new Set(), examples: [] };
      termAgg.set(term, t);
    }
    t.defs.set(def, (t.defs.get(def) ?? 0) + 1);
    t.categories.set(row.category, (t.categories.get(row.category) ?? 0) + 1);
    t.questionIds.add(row.source_ref);
    // point は設問全体の答え(=別の用語の場合がある)なので、この用語自体の説明として出さない。
    // asked(問われ方)だけを、この用語が登場した文脈として残す。
    t.examples.push({ id: row.source_ref, category: row.category, asked: row.asked });
  }
}

function pickCanonical(defs) {
  let best = null;
  for (const def of defs.keys()) {
    if (!best || def.length > best.length) best = def;
  }
  return best;
}

const terms = [...termAgg.entries()]
  .map(([term, t]) => {
    const canonical = pickCanonical(t.defs);
    const categories = [...t.categories.entries()].sort((a, b) => b[1] - a[1]).map(([c]) => c);
    return {
      id: term,
      term,
      definition: canonical,
      altDefinitions: [...t.defs.keys()].filter((d) => d !== canonical),
      categories,
      occurrences: t.questionIds.size,
      examples: t.examples,
    };
  })
  .sort(
    (a, b) =>
      (categorySort.get(a.categories[0]) ?? 0) - (categorySort.get(b.categories[0]) ?? 0) ||
      a.term.localeCompare(b.term, "ja")
  );

// ── 比較グループ: 1問の terms に2つ以上の用語が入っているものは、
//    その問題が「これらを区別させる」ために意図的に並べた組。vs はそのままの解説として使う。
const comparisons = raw
  .filter((row) => row.terms.length >= 2)
  .map((row) => ({
    id: row.source_ref,
    category: row.category,
    terms: row.terms.map(([term]) => term),
    note: row.vs,
  }));

fs.writeFileSync(termsOut, JSON.stringify(terms));
fs.writeFileSync(comparisonsOut, JSON.stringify(comparisons));

console.log(`terms: ${terms.length} 件 → ${termsOut}`);
console.log(`comparisons: ${comparisons.length} 件 → ${comparisonsOut}`);
