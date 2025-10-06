import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  output: 'export',
  images: {
    unoptimized: true,
  },
  // Ensure static files are served correctly
  trailingSlash: true,
  // Note: CORS headers are configured in vercel.json for static export
  // The headers() function doesn't work with output: 'export'
}

export default nextConfig

