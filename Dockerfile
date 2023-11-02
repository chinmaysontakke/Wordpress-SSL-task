FROM nginx:1.22.1
# Copy Default.conf to nginx container.
COPY docker cp /root/default.conf nginx:/etc/nginx/conf.d/default.conf
# Next, validate and reload the Docker Nginx reverse proxy configuration
RUN sudo docker exec nginx-base nginx -t
RUN sudo docker exec nginx-base nginx -s reload
