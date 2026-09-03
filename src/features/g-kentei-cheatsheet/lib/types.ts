export interface TermExample {
  id: string;
  category: string;
  asked: string;
}

export interface TermEntry {
  id: string;
  term: string;
  definition: string;
  altDefinitions: string[];
  categories: string[];
  occurrences: number;
  examples: TermExample[];
}

// 1問の中で意図的に並べられた「区別させたい用語」の組。note はその問題の vs をそのまま使う。
export interface ComparisonGroup {
  id: string;
  category: string;
  terms: string[];
  note: string;
}
