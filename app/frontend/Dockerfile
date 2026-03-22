# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# 1. Fixed the npm ci flag to avoid the "npm error" you saw earlier
RUN npm install --omit=dev

# 2. Fixed the COPY command (removed the extra lines/numbers)
COPY . .

# Build app
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built app
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# 3. Cleaned up the Health check syntax to be on a single line for reliability
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
