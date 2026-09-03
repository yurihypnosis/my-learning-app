export interface CheatsheetEntry {
  id: string;
  category: string;
  asked: string;
  point: string;
  whyAsked: string;
  eg: string;
  vs: string;
  think: string;
  calc: string | null;
  terms: [string, string][];
}
