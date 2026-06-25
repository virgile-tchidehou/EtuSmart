FROM node:20-alpine

RUN addgroup -S etusmart && adduser -S etusmart -G etusmart

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force

COPY --chown=etusmart:etusmart . .

USER etusmart

EXPOSE 5173

CMD ["npm", "run", "dev"]
