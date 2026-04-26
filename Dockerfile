FROM node:22-bookworm-slim AS deps

WORKDIR /usr/src/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund

FROM node:22-bookworm-slim AS runner

WORKDIR /usr/src/app

COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY src ./src
COPY package*.json server.js entrypoint.sh ./

RUN chmod +x entrypoint.sh

ENV PORT=5007
ENV ACTUAL_DATA_DIR=/data
ENV NODE_ENV=production

EXPOSE 5007

ENTRYPOINT ["./entrypoint.sh"]
