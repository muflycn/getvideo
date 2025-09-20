# GetVideo Production Docker Image
# Multi-stage build for optimized production deployment

FROM node:18-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    curl \
    && pip3 install --break-system-packages --no-cache-dir yt-dlp \
    && yt-dlp --version

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production && npm cache clean --force

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create nextjs user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy the standalone build output
COPY --from=builder /app/public ./public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Copy initialization scripts
COPY --from=builder --chown=nextjs:nodejs /app/scripts ./scripts

# Create necessary directories
RUN mkdir -p /app/data /app/downloads /app/logs \
    && chown -R nextjs:nodejs /app/data /app/downloads /app/logs \
    && chmod 755 /app/data /app/downloads /app/logs

# Set script permissions
RUN chmod +x /app/scripts/init-admin.js

USER nextjs

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Environment variables
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV DOWNLOAD_PATH="/app/downloads"
ENV DATA_PATH="/app/data"

CMD ["node", "server.js"]