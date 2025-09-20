/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable standalone output for Docker deployment
  output: 'standalone',
  
  // Disable telemetry in production
  experimental: {
    serverComponentsExternalPackages: ['bcryptjs']
  },
  
  // Environment variables configuration
  env: {
    DOWNLOAD_PATH: process.env.DOWNLOAD_PATH || './downloads',
    DATA_PATH: process.env.DATA_PATH || './data'
  },
  
  // 静态文件服务
  async rewrites() {
    return [
      {
        source: '/downloads/:path*',
        destination: '/api/download/file/:path*',
      },
    ];
  },
  
  // Headers configuration for security
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'X-Frame-Options', 
            value: 'DENY'
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block'
          }
        ]
      }
    ]
  }
}

module.exports = nextConfig