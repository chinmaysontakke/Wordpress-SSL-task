#!/bin/sh

# Start Nginx
nginx -g "daemon off;" &

# Wait for Nginx to start (you can adjust the sleep duration)
sleep 10

# Iterate through provided domain names and configure Nginx with SSL
for DOMAIN in $DOMAINS; do
    if [ -n "$DOMAIN" ]; then
        # Execute acme.sh command for each domain with custom options
        acme.sh --register-account -m clientaccess@perimattic.com --server zerossl
        acme.sh --issue --cert-home /etc/nginx/ssl -w /usr/share/nginx/html -d "$DOMAIN" --keylength 2048 --debug

        # Generate Nginx configuration dynamically
        echo "Configuring Nginx for $DOMAIN..."
        cat > /etc/nginx/conf.d/"$DOMAIN".conf <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;
    ssl_certificate /etc/nginx/ssl/$DOMAIN/$DOMAIN.cer;
    ssl_certificate_key /etc/nginx/ssl/$DOMAIN/$DOMAIN.key;
    # Add SSL settings like protocols, ciphers, etc.
    # ...

    location / {
        root /usr/share/nginx/html;
        # Your SSL-enabled site configuration
        # ...

        # Proxy settings
        proxy_pass http://$PROXY_URL:$PROXY_PORT;  # Use environment variables
        proxy_set_header Host \$host;  # Corrected syntax to reference variables
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
    fi
done

# Reload Nginx to apply the new configurations
nginx -s reload

# Keep the container running
tail -f /dev/null
