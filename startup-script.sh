#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Docker Compose
DOCKER_COMPOSE_VERSION="${docker_compose_version}"
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create docker-compose symlink
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Enable Docker service
systemctl enable docker
systemctl start docker

# Install additional tools
apt-get install -y git curl wget vim nano htop

# Download and extract Dify
DIFY_VERSION="${dify_version}"
curl -L "https://github.com/langgenius/dify/archive/refs/tags/$DIFY_VERSION.tar.gz" -o /tmp/dify-$DIFY_VERSION.tar.gz
mkdir -p /opt
tar -xzf /tmp/dify-$DIFY_VERSION.tar.gz -C /opt/

# Create .env file from .env.example
cd /opt/dify-$DIFY_VERSION/docker
cp .env.example .env

# Replace configuration values using sed
# Database Configuration
sed -i "s|^DB_HOST=.*|DB_HOST=${db_host}|" .env
sed -i "s|^DB_USERNAME=.*|DB_USERNAME=${database_user}|" .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD='${database_password}'|" .env
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${database_name}|" .env

# pgvector Configuration
sed -i "s|^VECTOR_STORE=.*|VECTOR_STORE=pgvector|" .env
sed -i "s|^PGVECTOR_HOST=.*|PGVECTOR_HOST=${pgvector_private_ip}|" .env
sed -i "s|^PGVECTOR_USER=.*|PGVECTOR_USER=${pgvector_database_user}|" .env
sed -i "s|^PGVECTOR_PGUSER=.*|PGVECTOR_PGUSER=${pgvector_database_user}|" .env
sed -i "s|^PGVECTOR_PASSWORD=.*|PGVECTOR_PASSWORD='${pgvector_database_password}'|" .env
sed -i "s|^PGVECTOR_POSTGRES_PASSWORD=.*|PGVECTOR_POSTGRES_PASSWORD='${pgvector_database_password}'|" .env
sed -i "s|^PGVECTOR_DATABASE=.*|PGVECTOR_DATABASE=${pgvector_database_name}|" .env
sed -i "s|^PGVECTOR_POSTGRES_DB=.*|PGVECTOR_POSTGRES_DB=${pgvector_database_name}|" .env

# GCS Configuration for file storage
sed -i "s|^STORAGE_TYPE=.*|STORAGE_TYPE=google-storage|" .env
sed -i "s|^GOOGLE_STORAGE_BUCKET_NAME=.*|GOOGLE_STORAGE_BUCKET_NAME=${gcs_bucket_name}|" .env
sed -i "s|^GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64=.*|GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64=${google_storage_service_account_json_base64}|" .env

# GCS Configuration for plugin storage
sed -i "s|^PLUGIN_STORAGE_TYPE=.*|PLUGIN_STORAGE_TYPE=google-storage|" .env
sed -i "s|^PLUGIN_STORAGE_OSS_BUCKET=.*|PLUGIN_STORAGE_OSS_BUCKET=${gcs_plugin_bucket_name}|" .env
# https://github.com/IMOKURI/dify-on-google-cloud/issues/1
# Dify does not yet support GCS credentials in .env for plugin storage, so we modify docker-compose.yaml directly.
#sed -i "s|^PLUGIN_GCS_CREDENTIALS=.*|PLUGIN_GCS_CREDENTIALS=${google_storage_service_account_json_base64}|" .env
sed -i "s|^      AZURE_BLOB_STORAGE_CONNECTION_STRING: .*|      GCS_CREDENTIALS: ${google_storage_service_account_json_base64}|" docker-compose.yaml
# https://github.com/langgenius/dify-plugin-daemon/pull/568
# There are errors like "installed_bucket.go:81: [ERROR]failed to create PluginUniqueIdentifier" in plugin_daemon.
# But it seems to work fine regardless.

chown -R ubuntu:ubuntu /opt/dify-$DIFY_VERSION

# Disable Default DB
sed -i "s|^COMPOSE_PROFILES=.*|COMPOSE_PROFILES=|" .env

# Start Dify with Docker Compose
sudo -u ubuntu docker-compose up -d

# Install Nginx for reverse proxy
apt-get install -y nginx

# Configure Nginx as reverse proxy
cat >/etc/nginx/sites-available/dify <<'EOF'
server {
    listen 1080;
    server_name _;

    client_max_body_size 100M;

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    location / {
        proxy_pass http://localhost:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/dify /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "Setup completed successfully!" >/var/log/startup-script.log
