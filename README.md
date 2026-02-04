# Dify on Google Cloud - Terraform Deployment

このTerraformコードは、Google Cloud Platform (GCP)上にDifyをデプロイします。

## 📁 プロジェクト構成

```
.
├── main.tf                      # メインの構成ファイル（モジュール呼び出し）
├── locals.tf                    # ローカル変数と共通設定
├── variables-*.tf               # カテゴリ別の変数定義
│   ├── variables-core.tf        # プロジェクト・リージョン設定
│   ├── variables-network.tf     # ネットワーク関連
│   ├── variables-compute.tf     # Compute Engine設定
│   ├── variables-database.tf    # Cloud SQL設定
│   ├── variables-storage.tf     # Cloud Storage & IAM設定
│   ├── variables-redis.tf       # Redis Memorystore設定
│   └── variables-application.tf # アプリケーション設定
├── outputs-*.tf                 # カテゴリ別の出力定義
│   ├── outputs-infrastructure.tf
│   ├── outputs-database.tf
│   ├── outputs-storage.tf
│   └── outputs-redis.tf
├── startup-script.sh            # VMインスタンスの初期化スクリプト
├── terraform.tfvars.example     # 設定例
└── modules/                     # 各種モジュール
    ├── network/                 # VPC, サブネット, ファイアウォール
    ├── storage/                 # Cloud Storage
    ├── iam/                     # サービスアカウント
    ├── cloudsql/                # Cloud SQL (PostgreSQL & pgvector)
    ├── redis/                   # Redis Memorystore
    ├── loadbalancer/            # ロードバランサー
    └── compute/                 # Managed Instance Group
```

## 構成要素

このTerraformコードは以下のリソースを作成します:

- **ネットワーク**
  - VPCネットワークとサブネット
  - Private Service Access（Cloud SQLとRedis用）
  - ファイアウォールルール
  - 静的外部IPアドレス（Load Balancer用）

- **データベース**
  - Cloud SQL (PostgreSQL) - メインデータベース
  - Cloud SQL (PostgreSQL with pgvector) - ベクトルストレージ
  - 自動バックアップと高可用性オプション

- **ストレージ**
  - Google Cloud Storage - ファイルアップロード用
  - CORS設定とライフサイクルポリシー

- **コンピュート**
  - Managed Instance Group（自動スケーリング対応）
  - カスタムスタートアップスクリプト
  - ヘルスチェック

- **ロードバランサー**
  - HTTPS Load Balancer
  - SSL証明書（マネージドまたは自己署名）

- **Redis**
  - Memorystore for Redis
  - キャッシュとセッション管理用

- **IAM**
  - Dify用サービスアカウント
  - 必要な権限の自動付与

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
   gcloud services enable compute.googleapis.com \
     servicenetworking.googleapis.com \
     sqladmin.googleapis.com \
     storage.googleapis.com \
     redis.googleapis.com \
     cloudresourcemanager.googleapis.com \
     iamcredentials.googleapis.com
   ```

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

```hcl
dify_version = "1.12.0"  # 任意のバージョンタグを指定
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

## リソースの削除

```bash
# すべてのリソースを削除
terraform destroy

# 削除保護のついたリソースでエラーになるので、コンソールから削除する

# すべてのリソースを削除
terraform destroy
```
