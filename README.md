# Dify on Google Cloud - Terraform Deployment

このTerraformコードは、Google Cloud Platform (GCP)上にDifyをデプロイします。



## 構成要素

このTerraformコードは以下のリソースを作成します:

TODO: Need to update



## 前提条件

1. **Google Cloud SDK**: `gcloud` コマンドがインストール済み
2. **Terraform**: バージョン 1.0 以上
3. **GCPプロジェクト**: アクティブなGCPプロジェクト
4. **認証設定**:
   ```bash
   gcloud init
   gcloud auth application-default login
   ```
5. **必要なAPIの有効化**:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable servicenetworking.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   ```
   TODO: Need to update


## クイックスタート

### 1. 変数ファイルの準備

```bash
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars`を編集し、最低限以下の値を設定:

```hcl
project_id = "your-gcp-project-id"

# ドメイン名がある場合（推奨）
domain_name = "dify.example.com"

# または自己署名証明書用の設定
# domain_name     = ""
# ssl_certificate = file("certificate.pem")
# ssl_private_key = file("private-key.pem")
```

### 2. デプロイ

```bash
# 初期化
terraform init

# プランの確認
terraform plan

# デプロイ実行
terraform apply
```

### 3. デプロイ完了後

```bash
# 出力情報の確認
terraform output

# ブラウザでアクセス
# https://<load_balancer_ip> または https://your-domain.com
```

## 詳細設定

### SSL証明書の設定

#### オプション1: Google管理SSL証明書（推奨）

```hcl
domain_name = "dify.example.com"
```

DNSレコードを設定:
```
A    dify.example.com    <LOAD_BALANCER_IP>
```

証明書のプロビジョニングは最大15分かかります。

#### オプション2: 自己署名証明書

```bash
# 証明書の生成
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout private-key.pem -out certificate.pem \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Dify/CN=dify.local"
```

```hcl
domain_name     = ""
ssl_certificate = file("certificate.pem")
ssl_private_key = file("private-key.pem")
```

## Difyのデプロイ

Terraform適用時に、Difyのソースコード（指定されたバージョン）が自動的に `/opt/dify` にダウンロード・配置されます。

デフォルトのバージョンは `1.11.4` ですが、`terraform.tfvars` で変更できます:

```hcl
dify_version = "1.11.4"  # 任意のバージョンタグを指定
```



## オートスケーリングの設定

このTerraform構成には、トラフィックに応じて自動的にVMインスタンスを増減するオートスケーリング機能が含まれています。

### 基本設定

```hcl
# オートスケーリングを有効化
autoscaling_enabled = true

# 最小インスタンス数（常に実行される数）
autoscaling_min_replicas = 2

# 最大インスタンス数（ピーク時の上限）
autoscaling_max_replicas = 10

# CPU使用率の目標値（0.0-1.0）
# 平均CPU使用率がこの値を超えるとスケールアウト
autoscaling_cpu_target = 0.7  # 70%
```

### 高度な設定

```hcl
# スケーリングイベント間のクールダウン期間（秒）
autoscaling_cooldown_period = 60

# 一度のスケールイン時に削除する最大インスタンス数
autoscaling_scale_in_max_replicas = 3

# スケールイン判断に使用する時間枠（秒）
autoscaling_scale_in_time_window = 120
```

### カスタムメトリクスによるスケーリング（オプション）

CPU使用率だけでなく、カスタムメトリクスでもスケーリングできます:

```hcl
autoscaling_custom_metrics = [
  {
    name   = "custom.googleapis.com/request_queue_depth"
    target = 100
    type   = "GAUGE"
  },
  {
    name   = "custom.googleapis.com/active_connections"
    target = 1000
    type   = "GAUGE"
  }
]
```

### オートスケーリングの無効化

固定数のインスタンスで実行する場合:

```hcl
autoscaling_enabled = false
autoscaling_min_replicas = 3  # 常に3インスタンスで実行
```

### インスタンスの確認

```bash
# Managed Instance Groupの状態を確認
gcloud compute instance-groups managed describe dify-mig \
  --region asia-northeast1 \
  --project your-project-id

# インスタンスの一覧を表示
gcloud compute instance-groups managed list-instances dify-mig \
  --region asia-northeast1 \
  --project your-project-id

# Autoscalerの詳細を確認
gcloud compute instance-groups managed describe-instance dify-mig \
  --region asia-northeast1 \
  --project your-project-id
```

### スケーリングのベストプラクティス

1. **最小レプリカ数**: 高可用性のため、最低2以上を推奨
2. **CPU目標値**: 0.6-0.8 (60-80%) が一般的。余裕を持たせることで急激なトラフィック増加に対応
3. **クールダウン期間**: スケールアウト後の安定化に必要な時間を設定
4. **スケールイン制限**: 急激なトラフィック減少時に過度なスケールインを防ぐ

### 推奨構成例

#### 小規模〜中規模デプロイ
```hcl
autoscaling_enabled = true
autoscaling_min_replicas = 2
autoscaling_max_replicas = 5
autoscaling_cpu_target = 0.7
machine_type = "n1-standard-2"
```

#### 大規模デプロイ
```hcl
autoscaling_enabled = true
autoscaling_min_replicas = 3
autoscaling_max_replicas = 20
autoscaling_cpu_target = 0.6
machine_type = "n1-standard-4"
```

#### 固定サイズ（開発環境）
```hcl
autoscaling_enabled = false
autoscaling_min_replicas = 1
machine_type = "n1-standard-1"
```

## パフォーマンスチューニング

### 推奨インスタンスサイズ

| ユースケース | VM | Cloud SQL | pgvector (オプション) |
|------------|-----|-----------|---------------------|
| 開発/テスト | n1-standard-2 | db-custom-2-7680 | db-custom-2-8192 |
| 小規模本番 | n1-standard-2 | db-custom-2-7680 | db-custom-4-16384 |
| 中規模本番 | n1-standard-4 | db-custom-4-15360 | db-custom-8-32768 |
| 大規模本番 | n1-standard-8 | db-custom-8-30720 | db-custom-16-65536 |

## 高可用性構成

### Cloud SQLの高可用性

```hcl
# main.tfの google_sql_database_instance リソースで
availability_type = "REGIONAL"  # ZONALからREGIONALに変更
```

### pgvectorのリードレプリカ

```hcl
pgvector_enable_read_replica = true
pgvector_replica_region = "us-central1"  # オプション: 別リージョン
pgvector_replica_tier = "db-custom-2-8192"  # オプション: 小さいマシンタイプ
```

## トラブルシューティング

### SSL証明書のプロビジョニング確認

```bash
# 証明書の状態確認
gcloud compute ssl-certificates list
gcloud compute ssl-certificates describe dify-ssl-cert --global
```


## セキュリティのベストプラクティス

1. **SSH接続の制限**: `ssh_source_ranges`を特定のIPに限定
   ```hcl
   ssh_source_ranges = ["203.0.113.0/24"]
   ```

2. **プライベートIP接続**: Cloud SQLはプライベートIPのみを使用
   ```hcl
   pgvector_enable_public_ip = false
   ```

3. **強力なパスワード**: 自動生成を使用するか、強力なパスワードを設定

4. **削除保護**: 本番環境では有効化
   ```hcl
   deletion_protection = true
   pgvector_deletion_protection = true
   ```

5. **バックアップ**: 定期的なバックアップを有効化
   ```hcl
   cloudsql_backup_enabled = true
   pgvector_backup_enabled = true
   ```

6. **監査ログ**: Cloud Auditログを有効化
   ```hcl
   cloudsql.enable_pgaudit = "on"
   ```

## モニタリング

### Cloud Monitoringでの確認項目

- **Database connections**: 接続数の監視
- **CPU utilization**: CPUの使用率
- **Memory utilization**: メモリの使用率
- **Disk utilization**: ディスクの使用率
- **Replication lag**: レプリカの遅延（リードレプリカ使用時）

### Query Insightsの活用

```bash
# GCPコンソールで確認
# Cloud SQL > [インスタンス名] > Query Insights
```

Query Insightsを有効化:
```hcl
pgvector_query_insights_enabled = true
```

## コスト最適化

### 開発環境

```hcl
# 小さいインスタンス
machine_type = "n1-standard-1"
cloudsql_tier = "db-custom-1-3840"
pgvector_tier = "db-custom-2-8192"

# バックアップを無効化
cloudsql_backup_enabled = false
pgvector_backup_enabled = false

# 削除保護を無効化
deletion_protection = false
pgvector_deletion_protection = false

# Query Insightsを無効化
pgvector_query_insights_enabled = false
```

### 本番環境

```hcl
# 適切なサイズのインスタンス
machine_type = "n1-standard-2"
cloudsql_tier = "db-custom-2-7680"
pgvector_tier = "db-custom-4-16384"

# バックアップを有効化
cloudsql_backup_enabled = true
pgvector_backup_enabled = true
pgvector_backup_retention_count = 7

# 削除保護を有効化
deletion_protection = true
pgvector_deletion_protection = true

# Query Insightsを有効化
pgvector_query_insights_enabled = true

# 高可用性（オプション）
availability_type = "REGIONAL"
pgvector_availability_type = "REGIONAL"
```

### その他のコスト削減

- **Committed Use Discounts**: 1年または3年の契約で割引
- **スケジューリング**: 夜間や週末にVMを停止
- **ディスク最適化**: 必要なサイズのみを使用
- **リージョン選択**: コストの低いリージョンを選択

## リソースの削除

```bash
# 削除保護を無効化
# terraform.tfvars または main.tf で deletion_protection = false に設定

terraform apply

# すべてのリソースを削除
terraform destroy
```