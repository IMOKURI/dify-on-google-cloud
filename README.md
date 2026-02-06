# Dify on Google Cloud - Terraform Deployment

This Terraform code deploys Dify on Google Cloud Platform (GCP).

It uses the Dify Community Edition with focus on the following principles:

- Follow Dify Community Edition upgrades
- Minimize modifications to the Dify Community Edition codebase
- Use managed services for database and file storage

## Components

This Terraform code creates the following resources:

- **Network**
  - VPC network and subnet
  - Private Service Access (for Cloud SQL)
  - Firewall rules
  - Static external IP address (for Load Balancer)

- **Database**
  - Cloud SQL (PostgreSQL) - Main database
  - Cloud SQL (PostgreSQL with pgvector) - Vector storage

- **Storage**
  - Google Cloud Storage - For file uploads and plugin assets

- **Compute**
  - Managed Instance Group
  - Custom startup script to install and run Dify

- **Load Balancer**
  - HTTPS Load Balancer
  - SSL certificates (managed or self-signed)

- **IAM**
  - Service account for Dify
  - Automatic granting of required permissions

## Prerequisites

1. **Google Cloud SDK**: `gcloud` command installed
2. **Terraform**: Version 1.0 or higher
3. **GCP Project**: Active GCP project
4. **Authentication Setup**:
   ```bash
   gcloud init
   gcloud auth application-default login
   ```
5. **Enable Required APIs**:
   ```bash
   gcloud services enable compute.googleapis.com \
     servicenetworking.googleapis.com \
     sqladmin.googleapis.com \
     storage.googleapis.com \
     cloudresourcemanager.googleapis.com \
     iamcredentials.googleapis.com
   ```

## Quick Start

### 1. Prepare Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set at least the following values:

```hcl
project_id = "your-gcp-project-id"

# Dify version to be deployed
dify_version = "1.11.4"

# If you have a domain name (recommended)
domain_name = "dify.example.com"

# Or use self-signed certificate
# domain_name     = ""
# ssl_certificate = file("certificate.pem")
# ssl_private_key = file("private-key.pem")
```

### 2. Deploy

```bash
# Initialize
terraform init

# Review plan
terraform plan

# Execute deployment
terraform apply
```

### 3. After Deployment

```bash
# Check output information
terraform output

# Access via browser
# https://<load_balancer_ip> or https://your-domain.com
```

## Detailed Configuration

### SSL Certificate Setup

#### Option 1: Google-Managed SSL Certificate (Recommended)

```hcl
domain_name = "dify.example.com"
```

Configure DNS record:

```
A    dify.example.com    <LOAD_BALANCER_IP>
```

Certificate provisioning can take up to 15 minutes.

#### Option 2: Self-Signed Certificate

```bash
# Generate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout private-key.pem -out certificate.pem \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Dify/CN=dify.local"
```

```hcl
domain_name     = ""
ssl_certificate = file("certificate.pem")
ssl_private_key = file("private-key.pem")
```

## Dify Deployment

When Terraform is applied,

1. Dify source code (of the specified version) is automatically downloaded to `/opt/dify-<version>`.
1. Update Dify environment variables by [startup-script.sh](./startup-script.sh).
1. Start Dify application.

### Upgrada Strategy

[Check Dify Release Note](https://github.com/langgenius/dify/releases) and Update [startup-script.sh](./startup-script.sh) if needed.

```hcl
dify_version = "1.12.1"  # Specify new version tag
```

```bash
terraform apply  # Apply upgrade
```

When Terraform is applied,

1. Remove the old VM first. So the service will be temporarily unavailable during the upgrade.
1. Deploy the new VM with the migration process.

## Troubleshooting

### Verify SSL Certificate Provisioning

```bash
# Check certificate status
gcloud compute ssl-certificates list
gcloud compute ssl-certificates describe dify-ssl-cert --global
```

### Check Dify logs

Access VM via ssh and check logs.

```bash
sudo su - ubuntu
cd /opt/dify-<version>/docker
docker compose ps
docker compose logs -f
```

## Resource Cleanup

```bash
# Delete all resources
terraform destroy

# If you get errors due to deletion protection, delete from the console

# Delete all resources
terraform destroy
```

## Known Issues

### plugin_daemon

- There are errors like follows.
  https://github.com/langgenius/dify-plugin-daemon/pull/568
  ```
  installed_bucket.go:81: [ERROR]failed to create PluginUniqueIdentifier from path plugin_packages/<org>/<plugin>:<version>: plugin_unique_identifier is not valid: _packages/<org>/<plugin>:<version>
  ```
