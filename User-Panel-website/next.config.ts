import type { NextConfig } from "next";

const LOCAL_BACKEND_URL = "http://127.0.0.1:8000";
const STAGING_BACKEND_URL = "https://ride-application-backend.onrender.com";

const backendUrl =
  process.env.BACKEND_URL ||
  process.env.NEXT_PUBLIC_API_URL ||
  (process.env.NODE_ENV === "production" ? STAGING_BACKEND_URL : LOCAL_BACKEND_URL);

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: `${backendUrl}/api/:path*`,
      },
      {
        source: "/uploads/:path*",
        destination: `${backendUrl}/uploads/:path*`,
      },
    ];
  },
};

export default nextConfig;
