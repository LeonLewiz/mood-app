# Внешняя сеть, через неё узел получит публичный адрес.
data "vkcs_networking_network" "extnet" {
  name = "internet"
}

resource "vkcs_networking_network" "k3s" {
  name        = "${var.name_prefix}-net"
  description = "Сеть для узла k3s"
}

resource "vkcs_networking_subnet" "k3s" {
  name       = "${var.name_prefix}-subnet"
  network_id = vkcs_networking_network.k3s.id
  cidr       = "10.10.0.0/24"
}

resource "vkcs_networking_router" "k3s" {
  name                = "${var.name_prefix}-router"
  external_network_id = data.vkcs_networking_network.extnet.id
}

resource "vkcs_networking_router_interface" "k3s" {
  router_id = vkcs_networking_router.k3s.id
  subnet_id = vkcs_networking_subnet.k3s.id
}

# Правила на исходящий трафик не описываем: VK Cloud создаёт их вместе с группой,
# и они разрешают всё наружу. Нам остаётся закрыть входящие.
resource "vkcs_networking_secgroup" "k3s" {
  name        = "${var.name_prefix}-sg"
  description = "Доступ к узлу k3s"
}

locals {
  ingress_ports = {
    ssh     = 22
    http    = 80
    https   = 443
    k3s-api = 6443
  }
}

# Порт на адрес: если адресов в allowed_cidrs несколько, правил станет больше.
resource "vkcs_networking_secgroup_rule" "ingress" {
  for_each = {
    for pair in setproduct(keys(local.ingress_ports), var.allowed_cidrs) :
    "${pair[0]}-${pair[1]}" => { port = pair[0], cidr = pair[1] }
  }

  security_group_id = vkcs_networking_secgroup.k3s.id
  description       = each.value.port
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = local.ingress_ports[each.value.port]
  port_range_max    = local.ingress_ports[each.value.port]
  remote_ip_prefix  = each.value.cidr
}

resource "vkcs_networking_secgroup_rule" "icmp" {
  for_each = toset(var.allowed_cidrs)

  security_group_id = vkcs_networking_secgroup.k3s.id
  description       = "ping"
  direction         = "ingress"
  protocol          = "icmp"
  remote_ip_prefix  = each.value
}

# Адрес выдаётся до создания узла, поэтому его можно передать в cloud-init
# и сразу получить kubeconfig, который работает снаружи.
resource "vkcs_networking_floatingip" "k3s" {
  pool        = "internet"
  description = "Публичный адрес узла k3s"
}
