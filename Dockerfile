# Dockerfile

# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /app

# Copy all source code
COPY . .

# Install all dependencies from the single root package.json
RUN npm install

# Run the build
RUN npm run build

# Stage 2: Runner
FROM node:18-alpine

WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the necessary files for running the app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

USER appuser

ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "start"]
