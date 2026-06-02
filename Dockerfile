# OpenWA - Dockerfile (pasos separados para ver el error en Railway)

# ===== Stage 1: Builder =====
FROM node:22-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY dashboard/package.json dashboard/package-lock.json dashboard/.npmrc ./dashboard/

# Sin postinstall: el script del root falla en silencio por peer deps del dashboard
RUN echo ">>> STEP: npm ci (API)" && npm ci --ignore-scripts

RUN echo ">>> STEP: npm ci (dashboard)" && npm ci --prefix dashboard

RUN test -f dashboard/node_modules/vite/package.json && \
    echo "OK: vite instalado en dashboard/node_modules"

COPY . .

RUN echo ">>> STEP: npm run build (API NestJS)" && npm run build

RUN echo ">>> STEP: npm run dashboard:build (UI)" && npm run dashboard:build

RUN echo ">>> STEP: verificar archivos generados" && \
    test -f dist/main.js && \
    test -f dashboard/dist/index.html && \
    echo "OK: dist/main.js y dashboard/dist/index.html existen"

# ===== Stage 2: Production =====
FROM node:22-slim AS production

RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

WORKDIR /app

COPY package*.json ./

RUN echo ">>> STEP: npm ci production" && npm ci --omit=dev && npm cache clean --force

RUN echo ">>> STEP: copiar API compilada"
COPY --from=builder /app/dist ./dist

RUN echo ">>> STEP: copiar dashboard compilado"
COPY --from=builder /app/dashboard/dist ./public/dashboard

RUN mkdir -p ./data/sessions ./data/media

EXPOSE 2785

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:2785/api/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/main"]
