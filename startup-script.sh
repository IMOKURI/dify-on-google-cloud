#!/bin/bash
set -e

echo "Setup started." >/var/log/startup-script.log

# =============================================================================
# System Upgrade
# =============================================================================

# Update system
apt-get update
apt-get upgrade -y

# Install additional tools
apt-get install -y git curl wget vim nano htop nfs-common

echo "System upgraded." >>/var/log/startup-script.log

# =============================================================================
# Docker Setup
# =============================================================================

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
echo "Docker service started." >>/var/log/startup-script.log

# =============================================================================
# Download Dify
# =============================================================================

# Download and extract Dify
DIFY_VERSION="${dify_version}"
curl -L "https://github.com/langgenius/dify/archive/refs/tags/$DIFY_VERSION.tar.gz" -o /tmp/dify-$DIFY_VERSION.tar.gz
mkdir -p /opt
tar -xzf /tmp/dify-$DIFY_VERSION.tar.gz -C /opt/

# =============================================================================
# Configure Dify
# =============================================================================

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

# Disable Default DB
sed -i "s|^COMPOSE_PROFILES=.*|COMPOSE_PROFILES=|" .env

chown -R ubuntu:ubuntu /opt/dify-$DIFY_VERSION
echo "Dify was configured." >>/var/log/startup-script.log

# =============================================================================
# Filestore Setup
# =============================================================================

# Mount Filestore to Dify volumes directory
FILESTORE_IP="${filestore_ip}"
FILESTORE_SHARE="${filestore_share_name}"
DIFY_DIR="/opt/dify-$DIFY_VERSION"
VOLUMES_DIR="$DIFY_DIR/docker/volumes"
TEMP_MOUNT="/mnt/filestore_temp"

# Create temporary mount point and mount Filestore
mkdir -p "$TEMP_MOUNT"
mount -t nfs -o rw,intr "$FILESTORE_IP:/$FILESTORE_SHARE" "$TEMP_MOUNT"

# Check if Filestore is empty (only lost+found exists)
ITEM_COUNT=$(ls -A "$TEMP_MOUNT" | grep -v '^lost+found$' | wc -l)
if [ "$ITEM_COUNT" -eq 0 ]; then
    echo "Filestore is empty (only lost+found exists). Copying initial volumes data..." >>/var/log/startup-script.log

    # Copy contents from source volumes directory to Filestore
    if [ -d "$VOLUMES_DIR" ]; then
        cp -a "$VOLUMES_DIR/." "$TEMP_MOUNT/"
        echo "Initial volumes data copied to Filestore." >>/var/log/startup-script.log
    else
        echo "Warning: Source volumes directory not found." >>/var/log/startup-script.log
    fi
else
    echo "Filestore already contains data. Skipping initial copy." >>/var/log/startup-script.log
fi

# Unmount temporary mount
umount "$TEMP_MOUNT"
rmdir "$TEMP_MOUNT"

# Remove existing volumes directory if it exists
if [ -d "$VOLUMES_DIR" ]; then
    rm -rf "$VOLUMES_DIR"
fi

# Create mount point and mount Filestore
mkdir -p "$VOLUMES_DIR"
mount -t nfs -o rw,intr "$FILESTORE_IP:/$FILESTORE_SHARE" "$VOLUMES_DIR"

# Add to /etc/fstab for automatic mounting on reboot
echo "$FILESTORE_IP:/$FILESTORE_SHARE $VOLUMES_DIR nfs rw,intr 0 0" >>/etc/fstab

echo "Filestore mounted successfully." >>/var/log/startup-script.log

# =============================================================================
# Start Dify
# =============================================================================

# Start Dify with Docker Compose
sudo -u ubuntu docker-compose up -d

echo "Setup completed successfully!" >>/var/log/startup-script.log
