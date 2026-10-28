# Образ качается самим Proxmox, наружу ходит он, а не terraform.
# тип содержимого Import надо предварительно разрешить на хранилище.
resource "proxmox_download_file" "os" {
  content_type = "import"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name
  url          = var.image_url
  # Расширение qcow2 обязательно, по нему Proxmox понимает формат при импорте.
  file_name = "noble-server-cloudimg-amd64.qcow2"
}

# Snippets тоже надо разрешить на хранилище, и этому ресурсу нужен ssh до узла.
resource "proxmox_virtual_environment_file" "cloud_init" {
  content_type = "snippets"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name

  source_raw {
    data      = file("${path.module}/cloud-init.yaml")
    file_name = "k3s-cloud-init.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "k3s" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id
  tags      = ["k3s", "terraform"]

  # Агент нужен, чтобы Proxmox сообщал адрес ВМ и умел гасить её по-хорошему.
  # Внутрь он ставится тем же cloud-init.
  agent {
    enabled = true
  }

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.disk_datastore_id
    import_from  = proxmox_download_file.os.id
    interface    = "scsi0"
    size         = var.disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [trimspace(file(var.ssh_public_key_path))]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init.id
  }

  network_device {
    bridge = var.bridge
  }

  operating_system {
    type = "l26"
  }

  started = true
}
