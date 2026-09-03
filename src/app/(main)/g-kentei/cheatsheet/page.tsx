import { CheatsheetScreen } from "@/features/g-kentei-cheatsheet/screens/cheatsheet-screen";
import termsData from "@/features/g-kentei-cheatsheet/data/terms.json";
import comparisonsData from "@/features/g-kentei-cheatsheet/data/comparisons.json";
import type { ComparisonGroup, TermEntry } from "@/features/g-kentei-cheatsheet/lib/types";

export default function GKenteiCheatsheetPage() {
  return (
    <CheatsheetScreen
      terms={termsData as TermEntry[]}
      comparisons={comparisonsData as ComparisonGroup[]}
    />
  );
}
