# ---- Build stage new----
FROM node:20-alpine AS builder

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Install deps
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
# Prefer npm ci; falls back to npm i if lock not present
RUN if [ -f package-lock.json ]; then npm ci --include=dev; \
    elif [ -f pnpm-lock.yaml ]; then npm i -g pnpm && pnpm i --frozen-lockfile; \
    elif [ -f yarn.lock ]; then corepack enable && yarn install --frozen-lockfile; \
    else npm i --include=dev; fi

# Copy the rest and build
COPY . .
# IMPORTANT: standalone output keeps runtime image small
RUN npm run build

# ---- Runtime stage ----
FROM node:20-alpine AS runner

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
# Cloud Run provides PORT, but set a sane default for local runs
ENV PORT=8080
ENV HOSTNAME=0.0.0.0

# Non-root user for security
RUN addgroup -S nextjs && adduser -S nextjs -G nextjs
WORKDIR /app

# Copy only the standalone runtime bit
# - .next/standalone has server.js and node_modules subset
# - .next/static and public assets are required at specific paths
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER nextjs

# Cloud Run will route traffic to $PORT. Next's standalone server reads it.
EXPOSE 8080
CMD ["node", "server.js"]