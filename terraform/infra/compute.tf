data "yandex_compute_image" "os" {
  family = var.image_family
}

# Адрес резервируется заранее, а не выдаётся при создании. Так его можно передать
# в cloud-init и сразу получить kubeconfig, который работает снаружи.
resource "yandex_vpc_address" "k3s" {
  name = "${var.name_prefix}-ip"

  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_compute_instance" "k3s" {
  name        = "${var.name_prefix}-node"
  hostname    = "${var.name_prefix}-node"
  platform_id = "standard-v3"
  zone        = var.zone

  # Позволяет менять параметры ВМ без пересоздания.
  allow_stopping_for_update = true

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.os.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.k3s.id
    nat                = true
    nat_ip_address     = yandex_vpc_address.k3s.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.k3s.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      public_ip = yandex_vpc_address.k3s.external_ipv4_address[0].address
    })
  }

  # Образ обновляется сам по семейству, пересоздавать ВМ из-за этого не нужно.
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }
}
