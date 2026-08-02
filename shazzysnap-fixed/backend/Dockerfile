FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++ sqlite

COPY package*.json ./
RUN npm ci --only=production

COPY src ./src

RUN mkdir -p data logs

EXPOSE 3000

USER node

CMD ["node", "src/server.js"]
