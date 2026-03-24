# Use the stable, lightweight version of Nginx
FROM nginx:alpine

# FACTOR 2: Explicitly declare the directory where Nginx looks for files
WORKDIR /usr/share/nginx/html

# Remove the default Nginx welcome page
RUN rm -rf ./*

# FACTOR 1: Copy your specific codebase into the image
# We copy 'index.html' to 'index.html' in the container's web root
COPY index.html .

# FACTOR 7: Port Binding
# Nginx by default listens on port 80
EXPOSE 80

# The default command of the nginx:alpine image will start the server
# so we don't strictly need a CMD here, but it's good for clarity:
CMD ["nginx", "-g", "daemon off;"]
