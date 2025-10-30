# ---- Build stage ----
FROM node:20-alpine AS builder
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# --- ADD THESE TWO LINES ---
# 1. Declare the build-time argument
ARG NEXT_PUBLIC_CHATKIT_WORKFLOW_ID
# 2. Set it as an environment variable for the build process
ENV NEXT_PUBLIC_CHATKIT_WORKFLOW_ID=$NEXT_PUBLIC_CHATKIT_WORKFLOW_ID
# ---------------------------

WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN if [ -f package-lock.json ]; \
    then npm ci --include=dev; \
    elif [ -f pnpm-lock.yaml ]; \
    then npm i -g pnpm && pnpm i --frozen-lockfile; \
    elif [ -f yarn.lock ]; \
    then corepack enable && yarn install --frozen-lockfile; \
    else npm i --include=dev; fi
COPY . .

# This command will now correctly embed the variable into the app
RUN npm run build
# shrink node_modules to prod-only for smaller copy
RUN npm prune --omit=dev

# ---- Runtime stage ----
FROM node:20-alpine AS runner
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=8080
ENV HOSTNAME=0.0.0.0

RUN addgroup -S nextjs && adduser -S nextjs -G nextjs
WORKDIR /app

# copy only what runtime needs
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

USER nextjs
EXPOSE 8080
# Use next's server instead of server.js
CMD ["node", "node_modules/next/dist/bin/next", "start", "-p", "8080"]