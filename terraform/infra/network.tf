resource "yandex_vpc_network" "k3s" {
  name = "${var.name_prefix}-net"
}

resource "yandex_vpc_subnet" "k3s" {
  name           = "${var.name_prefix}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.k3s.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_security_group" "k3s" {
  name       = "${var.name_prefix}-sg"
  network_id = yandex_vpc_network.k3s.id

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.allowed_cidrs
  }

  # Traefik: сайт и панели мониторинга.
  ingress {
    description    = "http"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = var.allowed_cidrs
  }

  ingress {
    description    = "https"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = var.allowed_cidrs
  }

  # API кластера. Открыт только мне, наружу в интернет его выставлять нельзя.
  ingress {
    description    = "k3s api"
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = var.allowed_cidrs
  }

  ingress {
    description    = "ping"
    protocol       = "ICMP"
    v4_cidr_blocks = var.allowed_cidrs
  }

  egress {
    description    = "all outbound"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
