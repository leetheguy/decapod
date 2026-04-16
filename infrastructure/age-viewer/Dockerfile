FROM node:18-alpine

RUN apk add --no-cache git python3

WORKDIR /app
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV DANGEROUSLY_DISABLE_HOST_CHECK=true
ENV WDS_SOCKET_PORT=0

COPY fix_import.py /tmp/fix_import.py
RUN git clone https://github.com/apache/age-viewer.git . \
    && npm run setup \
    && cd backend && npm install @babel/runtime \
    && python3 /tmp/fix_import.py

EXPOSE 3000
CMD ["sh", "-c", "cd /app/backend && PORT=3001 npm run start & cd /app/frontend && PORT=3000 npm start"]
