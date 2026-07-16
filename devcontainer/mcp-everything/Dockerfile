FROM node:22-alpine

RUN apk add --no-cache socat

RUN npm install -g @modelcontextprotocol/server-everything

# node:22-alpine already ships a non-root "node" user at uid 1000 for this
# purpose, so there's no need to create a separate one.
USER node

EXPOSE 3001
CMD ["socat", "TCP-LISTEN:3001,fork,reuseaddr", "EXEC:mcp-server-everything"]
