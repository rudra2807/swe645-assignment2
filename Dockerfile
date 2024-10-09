# Use the Nginx image from Docker Hub
FROM nginx:alpine

# Set the working directory to nginx asset directory
WORKDIR /usr/share/nginx/html

# Remove the default nginx static assets
RUN rm -rf ./*

# Copy static assets from builder stage
COPY . .

# Containers run nginx with global directives and daemon off
CMD ["nginx", "-g", "daemon off;"]