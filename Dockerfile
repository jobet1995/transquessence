# Dockerfile

# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /app

# Copy all source code first
COPY . .

# Install root dependencies
RUN npm install

# Install dependencies for the functions directory
RUN npm --prefix functions install

# Run the build, telling Node where to find the extra modules
RUN env NODE_PATH=./functions/node_modules npm run build

# Stage 2: Runner
FROM node:18-alpine

WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy build artifacts and dependencies
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/functions/node_modules ./functions/node_modules

# Set NODE_PATH for the runtime environment
ENV NODE_PATH=./functions/node_modules

USER appuser

ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "start"]
