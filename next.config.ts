import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // 親ディレクトリにも lockfile があるためワークスペースルートを明示
  turbopack: {
    root: __dirname,
  },
};

export default nextConfig;
