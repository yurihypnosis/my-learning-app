// 学習ロードマップのデータモデルと既定値。
// これまではクライアントにハードコードしていたが、DB(user_roadmap.doc jsonb)へ
// 保存して各自が編集できるようにする。サーバ(page.tsx)/クライアント双方で使う。

export type RStatus = "done" | "current" | "future";
export type RItemKind = "milestone" | "body";

export interface RItem {
  id: string;
  kind: RItemKind;
  text: string;
  detail?: string;
  slug?: string | null; // 問題集にひも付けると進捗バーを表示（例: gcp-ace）
  done: boolean;
}

export interface RPhase {
  id: string;
  label: string;
  title: string;
  period: string;
  status: RStatus;
  subtitle?: string;
  items: RItem[];
}

export interface RoadmapDoc {
  phases: RPhase[];
}

// 既定ロードマップ。項目 id は「フェーズid.種別index」で、旧 user_roadmap_items の
// キーと一致させてある（完了状態を引き継げるように）。
export const DEFAULT_ROADMAP: RoadmapDoc = {
  phases: [
    {
      id: "A", label: "Phase A", title: "CI/CD 基礎", period: "〜2025", status: "done",
      items: [{ id: "A.b0", kind: "body", text: "GitHub Actions を実務で習得", done: true }],
    },
    {
      id: "B", label: "Phase B", title: "QA 資格の積み上げ", period: "〜2025", status: "done",
      items: [
        { id: "B.b0", kind: "body", text: "GCP CDL 合格", done: true },
        { id: "B.b1", kind: "body", text: "JSTQB AL-TM 合格", done: true },
      ],
    },
    {
      id: "C", label: "Phase C", title: "DevOps 技術の本丸", period: "2026", status: "current",
      subtitle: "QA × DevOps の二刀流を確立する",
      items: [
        { id: "C.m0", kind: "milestone", text: "Terraform", detail: "init/apply/destroy 着手 → 自プロジェクトで実運用", done: false },
        { id: "C.m1", kind: "milestone", text: "GCP Associate Cloud Engineer", detail: "7/11 受験予定", slug: "gcp-ace", done: false },
        { id: "C.m2", kind: "milestone", text: "CKA / Kubernetes", detail: "最難関（実技）· 11月〜 → 2027年3月受験見込み", done: false },
      ],
    },
    {
      id: "1", label: "Phase 1", title: "QA アーキテクト級", period: "2027〜2028", status: "future",
      items: [
        { id: "1.b0", kind: "body", text: "CI/CD・IaC 環境を設計できる状態", done: false },
        { id: "1.b1", kind: "body", text: "GCP Professional 級（Architect / DevOps）", done: false },
      ],
    },
    {
      id: "2", label: "Phase 2", title: "プロダクトビルダー", period: "2029〜2030", status: "future",
      items: [{ id: "2.b0", kind: "body", text: "Q-Entropy を実プロダクト化", done: false }],
    },
  ],
};

// 深いクローン（構造化のため単純に JSON ラウンドトリップ）。
export function cloneDoc(doc: RoadmapDoc): RoadmapDoc {
  return JSON.parse(JSON.stringify(doc)) as RoadmapDoc;
}

// 既定ロードマップに、旧テーブル(user_roadmap_items)の完了状態を適用して返す。
export function defaultDocWithLegacyDone(legacy: Record<string, boolean>): RoadmapDoc {
  const doc = cloneDoc(DEFAULT_ROADMAP);
  for (const ph of doc.phases) {
    for (const it of ph.items) {
      if (legacy[it.id] !== undefined) it.done = legacy[it.id];
    }
  }
  return doc;
}

// 入力(DBの jsonb 等)が RoadmapDoc として妥当かを最低限チェックする。
export function isRoadmapDoc(v: unknown): v is RoadmapDoc {
  if (!v || typeof v !== "object") return false;
  const phases = (v as { phases?: unknown }).phases;
  return Array.isArray(phases);
}

// 新しい安定 id を作る（ユーザー追加のフェーズ/項目用）。
export function newId(prefix: string): string {
  const rand =
    typeof crypto !== "undefined" && "randomUUID" in crypto
      ? crypto.randomUUID().slice(0, 8)
      : Math.floor(Math.random() * 1e9).toString(36);
  return `${prefix}-${rand}`;
}
