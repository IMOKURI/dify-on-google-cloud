#!/bin/bash
set -e

# ログ設定
LOG_FILE="/var/log/startup-script.log"
exec > >(tee -a $${LOG_FILE})
exec 2>&1

# ログ出力関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $$1"
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ $$1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ ERROR: $$1" >&2
}

# エラーハンドリング
trap 'log_error "Script failed at line $$LINENO"' ERR

log "=========================================="
log "Dify インストールスクリプト開始"
log "=========================================="

# Update system
log "システムアップデート開始..."
apt-get update
apt-get upgrade -y
log_success "システムアップデート完了"

# Install Docker
log "Docker インストール開始..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
log_success "Docker インストール完了"

# Add ubuntu user to docker group
log "ubuntu ユーザーを docker グループに追加中..."
usermod -aG docker ubuntu
log_success "ubuntu ユーザーを docker グループに追加完了"

# Install Docker Compose
log "Docker Compose インストール開始..."
log "Docker Compose バージョン: ${docker_compose_version}"
curl -L "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
log_success "Docker Compose インストール完了"

# Create docker-compose symlink
log "Docker Compose シンボリックリンク作成中..."
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
log_success "Docker Compose シンボリックリンク作成完了"

# Enable Docker service
log "Docker サービス有効化中..."
systemctl enable docker
systemctl start docker
log_success "Docker サービス有効化完了"

# Install additional tools
log "追加ツールインストール中..."
apt-get install -y git curl wget vim nano htop
log_success "追加ツールインストール完了"

# Download and extract Dify
log "Dify ダウンロード開始..."
log "Dify バージョン: ${dify_version}"
curl -L "https://github.com/langgenius/dify/archive/refs/tags/${dify_version}.tar.gz" -o /tmp/dify-${dify_version}.tar.gz
log_success "Dify ダウンロード完了"

log "Dify 展開中..."
mkdir -p /opt
tar -xzf /tmp/dify-${dify_version}.tar.gz -C /opt/
log_success "Dify 展開完了: /opt/dify-${dify_version}"

# Create .env file from .env.example
log "環境設定ファイル作成中..."
cd /opt/dify-${dify_version}/docker
cp .env.example .env
log_success ".env ファイル作成完了"

# Replace configuration values using sed
log "データベース設定を構成中..."
# Database Configuration
sed -i "s|^DB_HOST=.*|DB_HOST=${db_host}|" .env
sed -i "s|^DB_USERNAME=.*|DB_USERNAME=${database_user}|" .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD='${database_password}'|" .env
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${database_name}|" .env
log_success "データベース設定完了 (DB_HOST: ${db_host})"

log "pgvector 設定を構成中..."
# pgvector Configuration
sed -i "s|^VECTOR_STORE=.*|VECTOR_STORE=pgvector|" .env
sed -i "s|^PGVECTOR_HOST=.*|PGVECTOR_HOST=${pgvector_private_ip}|" .env
sed -i "s|^PGVECTOR_USER=.*|PGVECTOR_USER=${pgvector_database_user}|" .env
sed -i "s|^PGVECTOR_PGUSER=.*|PGVECTOR_PGUSER=${pgvector_database_user}|" .env
sed -i "s|^PGVECTOR_PASSWORD=.*|PGVECTOR_PASSWORD='${pgvector_database_password}'|" .env
sed -i "s|^PGVECTOR_POSTGRES_PASSWORD=.*|PGVECTOR_POSTGRES_PASSWORD='${pgvector_database_password}'|" .env
sed -i "s|^PGVECTOR_DATABASE=.*|PGVECTOR_DATABASE=${pgvector_database_name}|" .env
sed -i "s|^PGVECTOR_POSTGRES_DB=.*|PGVECTOR_POSTGRES_DB=${pgvector_database_name}|" .env
log_success "pgvector 設定完了 (PGVECTOR_HOST: ${pgvector_private_ip})"

log "GCS ストレージ設定を構成中..."
# GCS Configuration for file storage
sed -i "s|^STORAGE_TYPE=.*|STORAGE_TYPE=google-storage|" .env
sed -i "s|^GOOGLE_STORAGE_BUCKET_NAME=.*|GOOGLE_STORAGE_BUCKET_NAME=${gcs_bucket_name}|" .env
sed -i "s|^GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64=.*|GOOGLE_STORAGE_SERVICE_ACCOUNT_JSON_BASE64=${google_storage_service_account_json_base64}|" .env
log_success "GCS ファイルストレージ設定完了 (Bucket: ${gcs_bucket_name})"

log "GCS プラグインストレージ設定を構成中..."
# GCS Configuration for plugin storage
sed -i "s|^PLUGIN_STORAGE_TYPE=.*|PLUGIN_STORAGE_TYPE=google-storage|" .env
sed -i "s|^PLUGIN_STORAGE_OSS_BUCKET=.*|PLUGIN_STORAGE_OSS_BUCKET=${gcs_plugin_bucket_name}|" .env
# https://github.com/IMOKURI/dify-on-google-cloud/issues/1
# Dify does not yet support GCS credentials in .env for plugin storage, so we modify docker-compose.yaml directly.
#sed -i "s|^PLUGIN_GCS_CREDENTIALS=.*|PLUGIN_GCS_CREDENTIALS=${google_storage_service_account_json_base64}|" .env
sed -i "s|^      AZURE_BLOB_STORAGE_CONNECTION_STRING: .*|      GCS_CREDENTIALS: ${google_storage_service_account_json_base64}|" docker-compose.yaml
log_success "GCS プラグインストレージ設定完了 (Bucket: ${gcs_plugin_bucket_name})"

log "ファイル所有者を変更中..."
chown -R ubuntu:ubuntu /opt/dify-${dify_version}
log_success "ファイル所有者変更完了"

log "Dify プロファイル設定中..."
# Disable Default DB
sed -i "s|^COMPOSE_PROFILES=.*|COMPOSE_PROFILES=|" .env
log_success "デフォルトDB無効化完了"

# Start Dify with Docker Compose
log "Dify 起動中..."
log "Docker Compose を実行します (これには数分かかる場合があります)..."
sudo -u ubuntu docker-compose up -d
log_success "Dify 起動完了"

log "=========================================="
log "✓ セットアップが正常に完了しました！"
log "=========================================="
log "Dify バージョン: ${dify_version}"
log "インストールパス: /opt/dify-${dify_version}"
log "ログファイル: $${LOG_FILE}"
log "=========================================="
