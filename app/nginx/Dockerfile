FROM nginx:alpine

# Remove default nginx config to avoid conflicts
RUN rm /etc/nginx/conf.d/default.conf

# Copy your custom configuration
COPY nginx.conf /etc/nginx/conf.d/

# Health check to ensure the container is actually serving requests 
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
