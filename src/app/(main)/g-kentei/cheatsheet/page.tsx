import { CheatsheetScreen } from "@/features/g-kentei-cheatsheet/screens/cheatsheet-screen";
import cheatsheetData from "@/features/g-kentei-cheatsheet/data/cheatsheet.json";
import type { CheatsheetEntry } from "@/features/g-kentei-cheatsheet/lib/types";

export default function GKenteiCheatsheetPage() {
  return <CheatsheetScreen entries={cheatsheetData as CheatsheetEntry[]} />;
}
