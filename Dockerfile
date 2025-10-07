# Dockerfile

# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /app

# First, install dependencies for the functions directory
COPY functions/package*.json ./functions/
RUN npm install --prefix ./functions

# Next, install dependencies for the root directory
COPY package*.json ./
RUN npm install

# Now, copy the rest of the source code
COPY . .

# Run the build
RUN npm run build

# Stage 2: Runner
FROM node:18-alpine

WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/functions/node_modules ./functions/node_modules
COPY --from=builder /app/package.json ./package.json

USER appuser

ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "start"]
