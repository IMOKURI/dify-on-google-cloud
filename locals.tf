locals {
  # Read SSH keys from files if they exist
  ssh_public_key_content  = fileexists("${path.module}/ssh/id_ed25519.pub") ? file("${path.module}/ssh/id_ed25519.pub") : var.ssh_public_key
  ssh_private_key_content = fileexists("${path.module}/ssh/id_ed25519") ? file("${path.module}/ssh/id_ed25519") : var.ssh_private_key
}
