FROM nginx:latest

# Install necessary packages for acme.sh
RUN apt-get update && apt-get install -y \
    curl \
    socat \
    cron \
    openssl

# Install acme.sh
RUN curl https://get.acme.sh | sh

# Create necessary directories
RUN mkdir -p /opt/acme.sh/ca/acme-v01.api.letsencrypt.org

# Configure acme.sh auto-renewal with nginx reload
RUN crontab -l | sed "s|acme.sh --cron|acme.sh --cron --renew-hook \"nginx -s reload\"|g" | crontab -

# Create a symbolic link for acme.sh
RUN ln -s /root/.acme.sh/acme.sh /usr/bin/acme.sh

# Copy the start script
COPY start.sh /start.sh


# Make the start script executable
RUN chmod +x /start.sh

# Expose ports
EXPOSE 80 443

# Use the start script as the entrypoint
ENTRYPOINT ["/start.sh"]
