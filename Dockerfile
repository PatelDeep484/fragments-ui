FROM node:18.16.1@sha256:f4698d49371c8a9fa7dd78b97fb2a532213903066e47966542b3b1d403449da4 AS dependancies   

ENV NODE_ENV=production

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

# #######################################################################
FROM node:18.16.1@sha256:f4698d49371c8a9fa7dd78b97fb2a532213903066e47966542b3b1d403449da4 AS builder

WORKDIR /app

COPY --from=dependancies /app /app

COPY . .

CMD npm run build

# ########################################################################

FROM nginx:1.24.0-alpine@sha256:5e1ccef1e821253829e415ac1e3eafe46920aab0bf67e0fe8a104c57dbfffdf7 AS deploy

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
   CMD curl --fail localhost:80 || exit 1