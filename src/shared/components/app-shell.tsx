"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/shared/lib/supabase/client";

// ── トップバーの見出し／現在の問題集を、配下のページから設定するための器 ──
// レイアウトはルート遷移で再マウントされないので、ダッシュボードで選んだ
// 「現在の問題集」は学習ログや単語カードへ移動しても保持される。
interface Chrome {
  title: string;
  sub: string;
  setHeader: (title: string, sub: string, nav: string) => void;
  subject: { slug: string; name: string } | null;
  setSubject: (s: { slug: string; name: string } | null) => void;
}

const ChromeContext = createContext<Chrome | null>(null);

/**
 * トップバーの見出しを設定する。文字列が変わったときだけ更新される。
 * nav にサイドバーの href を渡すと、その項目をアクティブ表示にする
 * （"/" 配下のサブ画面のように URL だけでは判別できない場合に使う）。
 */
export function usePageHeader(title: string, sub = "", nav = "") {
  const ctx = useContext(ChromeContext);
  const setHeader = ctx?.setHeader;
  useEffect(() => {
    setHeader?.(title, sub, nav);
  }, [setHeader, title, sub, nav]);
}

/** トップバーの問題集スイッチャに、いま開いている問題集を伝える。 */
export function useCurrentSubject(slug: string, name: string) {
  const ctx = useContext(ChromeContext);
  const setSubject = ctx?.setSubject;
  useEffect(() => {
    // 空文字は「未選択（全体ビュー）」の合図。
    setSubject?.(slug ? { slug, name } : null);
  }, [setSubject, slug, name]);
}

export interface ShellExam {
  examKey: string;
  examName: string;
  sets: { slug: string; name: string }[];
}

const NAV_MAIN = [
  {
    href: "/",
    label: "ダッシュボード",
    icon: (
      <>
        <rect x="3" y="3" width="7" height="9" rx="1.5" />
        <rect x="14" y="3" width="7" height="5" rx="1.5" />
        <rect x="14" y="12" width="7" height="9" rx="1.5" />
        <rect x="3" y="16" width="7" height="5" rx="1.5" />
      </>
    ),
  },
  {
    href: "/catalog",
    label: "問題集一覧",
    icon: (
      <>
        <path d="M12 2 2 7l10 5 10-5-10-5z" />
        <path d="M2 17l10 5 10-5" />
        <path d="M2 12l10 5 10-5" />
      </>
    ),
  },
  {
    href: "/flashcards",
    label: "単語カード",
    icon: (
      <>
        <rect x="3" y="4" width="18" height="14" rx="2" />
        <path d="M3 9h18M8 4v14" />
      </>
    ),
  },
  {
    href: "/roadmap",
    label: "ロードマップ",
    icon: <path d="M3 12l4-4 4 4 4-8 6 12" />,
  },
  {
    href: "/log",
    label: "学習ログ",
    icon: (
      <>
        <rect x="3" y="4" width="18" height="18" rx="2" />
        <path d="M3 10h18M8 2v4M16 2v4" />
      </>
    ),
  },
];

const NAV_SUB = [
  {
    href: "/?screen=analysis",
    label: "苦手分析",
    icon: <path d="M3 3v18h18M7 15l4-5 3 3 5-7" />,
  },
  {
    href: "/mindset",
    label: "思考フレーム",
    icon: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M12 8v4l3 2" />
      </>
    ),
  },
  {
    href: "/code-tour",
    label: "コードの読み方",
    icon: <path d="M16 18l6-6-6-6M8 6l-6 6 6 6" />,
  },
  {
    href: "/?screen=export",
    label: "書き出し",
    icon: (
      <>
        <path d="M12 15V3M7 8l5-5 5 5" />
        <path d="M3 15v4a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-4" />
      </>
    ),
  },
];

function NavIcon({ children }: { children: React.ReactNode }) {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {children}
    </svg>
  );
}

export function AppShell({
  email,
  exams,
  children,
}: {
  email: string | null;
  exams: ShellExam[];
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [title, setTitle] = useState("My Learning");
  const [sub, setSub] = useState("");
  const [navOverride, setNavOverride] = useState("");
  const [subject, setSubject] = useState<{ slug: string; name: string } | null>(null);
  const [menuOpen, setMenuOpen] = useState(false);

  const setHeader = useCallback((t: string, s: string, nav: string) => {
    setTitle(t);
    setSub(s);
    setNavOverride(nav);
  }, []);

  const chrome = useMemo<Chrome>(
    () => ({ title, sub, setHeader, subject, setSubject }),
    [title, sub, setHeader, subject]
  );

  const userName = email ? email.split("@")[0] : "ゲスト";
  const initial = userName.charAt(0).toUpperCase();

  const logout = async () => {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  };

  // 苦手分析・書き出しはダッシュボードと同じデータで描ける画面なので、
  // すでに "/" にいるならサーバへ行かずクライアント状態だけ切り替える。
  // （URL 遷移にすると 500KB 超の RSC ペイロードを取り直すことになる）
  const go = (href: string) => {
    if (href === "/") {
      window.dispatchEvent(new Event("app:home"));
      // 問題集を選んでいる状態から「ダッシュボード」= 全体ビューへ戻るのは
      // サーバのデータが変わるので本物の遷移が要る。
      if (pathname === "/" && !subject) {
        window.history.replaceState(null, "", "/");
        return;
      }
      router.push("/");
      return;
    }

    const screen = href.startsWith("/?screen=") ? href.slice("/?screen=".length) : null;
    // 問題集スコープで表示中なら、その画面のデータはもう手元にある。
    if (screen && pathname === "/" && subject) {
      window.dispatchEvent(new CustomEvent("app:screen", { detail: screen }));
      // URL は履歴 API だけで合わせる（再フェッチを起こさない）。
      window.history.replaceState(null, "", `/?subject=${subject.slug}&screen=${screen}`);
      return;
    }

    router.push(href);
  };

  // "/" 配下はサブ画面が URL を持たないため、ページ側の申告（navOverride）を優先する。
  const isActive = (href: string) => {
    if (navOverride) return href === navOverride;
    if (href.startsWith("/?")) return false;
    return href === "/" ? pathname === "/" : pathname.startsWith(href);
  };

  const currentExamKey = exams.find((e) =>
    e.sets.some((s) => s.slug === subject?.slug)
  )?.examKey;

  return (
    <ChromeContext.Provider value={chrome}>
      <div className="shell">
        <aside className="sidebar">
          <div className="brand">
            <div className="brand-mark">学</div>
            <div>
              <div className="brand-name">My Learning</div>
              <div className="brand-sub">試験対策スイート</div>
            </div>
          </div>

          <div>
            <div className="nav-group-label">メイン</div>
            <div className="nav">
              {NAV_MAIN.map((item) => (
                <button
                  key={item.href}
                  onClick={() => go(item.href)}
                  className={`nav-item ${isActive(item.href) ? "active" : ""}`}
                >
                  <NavIcon>{item.icon}</NavIcon>
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          <div>
            <div className="nav-group-label">分析・その他</div>
            <div className="nav">
              {NAV_SUB.map((item) => (
                <button
                  key={item.href}
                  onClick={() => go(item.href)}
                  className={`nav-item ${isActive(item.href) ? "active" : ""}`}
                >
                  <NavIcon>{item.icon}</NavIcon>
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          <div className="sidebar-footer">
            <div className="avatar-sm">{initial}</div>
            <div className="min-w-0 flex-1">
              <p className="truncate text-[12.5px] font-semibold text-fg">{userName}</p>
              <p className="text-[10.5px] text-muted2">個人プラン</p>
            </div>
            <button className="icon-btn" onClick={logout} title="ログアウト" aria-label="ログアウト">
              <svg
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                <path d="M16 17l5-5-5-5M21 12H9" />
              </svg>
            </button>
          </div>
        </aside>

        <main className="main-col">
          <div className="topbar">
            <div className="greeting">
              <h1>{title}</h1>
              {sub && <p>{sub}</p>}
            </div>
            <div className="topbar-actions">
              {exams.length > 0 && (
                <div className="subject-switcher">
                  <button className="subject-trigger" onClick={() => setMenuOpen((o) => !o)}>
                    <span className="kicker">問題集</span>
                    <span
                      className="dot"
                      style={{ background: subject ? "#3b82f6" : "#59627a" }}
                    />
                    <span className="max-w-[150px] truncate">
                      {subject?.name ?? "すべて"}
                    </span>
                    <svg className="chev" width="10" height="10" viewBox="0 0 10 10" fill="none">
                      <path
                        d="M2 3.5L5 6.5L8 3.5"
                        stroke="currentColor"
                        strokeWidth="1.4"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </button>

                  {menuOpen && (
                    <>
                      <button
                        aria-label="閉じる"
                        onClick={() => setMenuOpen(false)}
                        className="fixed inset-0 z-40 cursor-default"
                      />
                      <div className="subject-menu">
                        <button
                          onClick={() => {
                            setMenuOpen(false);
                            window.dispatchEvent(new Event("app:home"));
                            router.push("/");
                          }}
                          className={`subject-menu-item ${!subject ? "current" : ""}`}
                        >
                          <span className="dot" style={{ background: "#59627a" }} />
                          <span className="min-w-0 flex-1 truncate">すべて（全体の状況）</span>
                        </button>
                        <div className="my-1.5 h-px bg-border" />
                        {exams.map((g) =>
                          g.sets.map((s) => (
                            <button
                              key={s.slug}
                              onClick={() => {
                                setMenuOpen(false);
                                window.dispatchEvent(new Event("app:home"));
                                router.push(`/?subject=${s.slug}`);
                              }}
                              className={`subject-menu-item ${
                                s.slug === subject?.slug ? "current" : ""
                              }`}
                            >
                              <span
                                className="dot"
                                style={{
                                  background:
                                    g.examKey === currentExamKey ? "#3b82f6" : "#343a4a",
                                }}
                              />
                              <span className="min-w-0 flex-1 truncate">
                                {g.sets.length > 1 ? s.name : g.examName}
                              </span>
                            </button>
                          ))
                        )}
                      </div>
                    </>
                  )}
                </div>
              )}
              <div className="avatar-top">{initial}</div>
            </div>
          </div>

          {children}
        </main>
      </div>
    </ChromeContext.Provider>
  );
}
