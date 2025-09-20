import { NextRequest } from 'next/server'
import { authMiddleware } from './src/lib/auth/middleware'

export async function middleware(request: NextRequest) {
  return await authMiddleware.handleRequest(request)
}

// 配置中间件匹配路径
export const config = {
  matcher: [
    // 匹配所有 API 路由
    '/api/:path*',
    // 排除 Next.js 内部路由
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ]
}