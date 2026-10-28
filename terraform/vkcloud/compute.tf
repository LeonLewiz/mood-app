data "vkcs_images_image" "os" {
  visibility  = "public"
  default     = true
  most_recent = true

  properties = {
    mcs_os_distro  = var.image_os_distro
    mcs_os_version = var.image_os_version
  }
}

# Флейвор ищем по числу ядер и минимальной памяти, чтобы не хардкодить имена.
data "vkcs_compute_flavor" "k3s" {
  vcpus   = var.cores
  min_ram = var.memory * 1024
}

# Публичный ключ заливаем как есть, приватный в state не попадает.
resource "vkcs_compute_keypair" "k3s" {
  name       = "${var.name_prefix}-key"
  public_key = file(var.ssh_public_key_path)
}

resource "vkcs_compute_instance" "k3s" {
  name              = "${var.name_prefix}-node"
  availability_zone = var.availability_zone
  flavor_name       = data.vkcs_compute_flavor.k3s.name
  key_pair          = vkcs_compute_keypair.k3s.name

  block_device {
    source_type           = "image"
    uuid                  = data.vkcs_images_image.os.id
    destination_type      = "volume"
    volume_size           = var.disk_size
    volume_type           = var.disk_type
    delete_on_termination = true
  }

  # Публичного адреса у узла нет намеренно, он живёт в приватной сети,
  # а наружу его отдаёт балансировщик.
  network {
    uuid = vkcs_networking_network.k3s.id
  }

  security_group_ids = [vkcs_networking_secgroup.k3s.id]

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    api_hostname = var.api_hostname
  })

  # Без маршрута наружу cloud-init не скачает k3s.
  depends_on = [vkcs_networking_router_interface.k3s]
}
