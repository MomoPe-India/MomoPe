import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  reactCompiler: true,
  allowedDevOrigins: ["172.29.240.1", "192.168.137.1", "localhost"],
};

export default nextConfig;
