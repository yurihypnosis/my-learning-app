import path from "node:path";
import { defineConfig } from "vitest/config";

// tsconfig.json の "paths": { "@/*": ["./src/*"] } と揃える。
// これまでのテストは "@/..." を経由しないモジュールしか import していなかったため
// 顕在化していなかったが、use-quiz-session.ts などは "@/features/..." を使うため必要。
export default defineConfig({
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
