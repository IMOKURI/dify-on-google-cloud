packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "project_id" {
  type    = string
  default = "your-gcp-project-id"
}

variable "zone" {
  type    = string
  default = "asia-northeast1-a"
}

variable "dify_version" {
  type    = string
  default = "1.13.0"
}

variable "image_name" {
  type    = string
  default = "dify-golden-1-13-0-20260316"
}

source "googlecompute" "dify" {
  project_id              = var.project_id
  zone                    = var.zone
  source_image_family     = "ubuntu-2404-lts-amd64"
  source_image_project_id = ["ubuntu-os-cloud"]
  image_name              = var.image_name
  image_family            = "dify-golden"
  ssh_username            = "packer"
  machine_type            = "e2-standard-8"
  disk_size               = 50
}

build {
  sources = ["source.googlecompute.dify"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y git curl ca-certificates wget vim nano htop nfs-common",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "curl -L https://github.com/langgenius/dify/archive/refs/tags/${var.dify_version}.tar.gz -o /tmp/dify.tar.gz",
      "sudo mkdir -p /opt",
      "sudo tar -xzf /tmp/dify.tar.gz -C /opt",
      "cd /opt/dify-${var.dify_version}/docker && sudo docker compose pull",
      "sudo docker pull --platform=linux/amd64 downloads.unstructured.io/unstructured-io/unstructured-api:latest",
      "sudo docker image prune -f"
    ]
  }
}
