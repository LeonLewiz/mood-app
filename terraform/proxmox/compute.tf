# Адрес сервера берём из описания узлов, чтобы не дублировать его руками.
locals {
  server_ip = split("/", [for n in var.nodes : n.address if n.role == "server"][0])[0]
}

# Образ качается самим Proxmox, наружу ходит он, а не terraform.
resource "proxmox_download_file" "os" {
  content_type = "import"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name
  url          = var.image_url
  # Расширение qcow2 обязательно, по нему Proxmox понимает формат при импорте.
  file_name = "ubuntu-server-cloudimg-amd64.qcow2"
}

# Токен задаём сами, иначе агенты не смогут присоединиться: свой токен сервер
# генерирует только при первом запуске, и Terraform его не увидит.
resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "proxmox_virtual_environment_file" "cloud_init" {
  for_each = var.nodes

  content_type = "snippets"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name

  source_raw {
    data = each.value.role == "server" ? templatefile("${path.module}/cloud-init-server.yaml.tftpl", {
      token     = random_password.k3s_token.result
      server_ip = local.server_ip
      taint     = var.dedicated_control_plane ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""
      }) : templatefile("${path.module}/cloud-init-agent.yaml.tftpl", {
      token     = random_password.k3s_token.result
      server_ip = local.server_ip
    })

    file_name = "k3s-${each.key}-cloud-init.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "k3s" {
  for_each = var.nodes

  name      = "${var.vm_prefix}-${each.key}"
  node_name = var.node_name
  tags      = ["k3s", "terraform", each.value.role]

  # Агент нужен, чтобы Proxmox сообщал адрес ВМ и гасил её по-хорошему.
  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.disk_datastore_id
    import_from  = proxmox_download_file.os.id
    interface    = "scsi0"
    size         = each.value.disk
  }

  initialization {
    ip_config {
      ipv4 {
        address = each.value.address
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = "ubuntu"
      keys     = [trimspace(file(var.ssh_public_key_path))]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }

  network_device {
    bridge = var.bridge
  }

  operating_system {
    type = "l26"
  }

  started = true
}
