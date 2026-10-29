locals {
  server_ip = split("/", [for n in var.nodes : n.address if n.role == "server"][0])[0]
  dns       = join(", ", var.dns_servers)
  ssh_key   = trimspace(file(var.ssh_public_key_path))

  cloud_init_args = {
    for name, node in var.nodes : name => {
      token     = random_password.k3s_token.result
      server_ip = local.server_ip
      ssh_key   = local.ssh_key
      hostname  = "${var.vm_prefix}-${name}"
      address   = node.address
      gateway   = var.gateway
      dns       = local.dns
      mac       = node.mac
      taint     = var.dedicated_control_plane ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""
    }
  }
}

resource "proxmox_download_file" "os" {
  content_type = "import"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name
  url          = var.image_url
  file_name    = "ubuntu-server-cloudimg-amd64.qcow2"
}

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
    data      = each.value.role == "server" ? templatefile("${path.module}/cloud-init-server.yaml.tftpl", local.cloud_init_args[each.key]) : templatefile("${path.module}/cloud-init-agent.yaml.tftpl", local.cloud_init_args[each.key])
    file_name = "k3s-${each.key}-cloud-init.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "k3s" {
  for_each = var.nodes

  name      = "${var.vm_prefix}-${each.key}"
  node_name = var.node_name
  tags      = ["k3s", "terraform", each.value.role]

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
      keys     = [local.ssh_key]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }

  network_device {
    bridge      = var.bridge
    mac_address = each.value.mac
  }

  operating_system {
    type = "l26"
  }

  started = true
}
