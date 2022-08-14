FROM nginx
LABEL maintainer="Ankur Singh"

COPY website/ /usr/share/nginx/html/

# Uncomment below line if you have a custom nginx.conf in current dir
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80