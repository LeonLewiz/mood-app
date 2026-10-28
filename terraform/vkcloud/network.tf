# Узел подключён во внешнюю сеть, поэтому роутер и плавающий адрес не нужны.
# Сеть ищем через data, чтобы промах в имени вылез на plan, а не на apply.
data "vkcs_networking_network" "extnet" {
  name = "internet"
}

# Исходящие правила VK Cloud создаёт сама и разрешает всё наружу, закрываем вход.
resource "vkcs_networking_secgroup" "k3s" {
  name        = "${var.name_prefix}-sg"
  description = "Доступ к узлу k3s"
}

locals {
  exposed_ports = {
    ssh   = 22
    api   = 6443
    http  = 80
    https = 443
  }
}

resource "vkcs_networking_secgroup_rule" "ingress" {
  for_each = {
    for pair in setproduct(keys(local.exposed_ports), var.allowed_cidrs) :
    "${pair[0]}-${pair[1]}" => { port = pair[0], cidr = pair[1] }
  }

  security_group_id = vkcs_networking_secgroup.k3s.id
  description       = "порт ${each.value.port} для ${each.value.cidr}"
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = local.exposed_ports[each.value.port]
  port_range_max    = local.exposed_ports[each.value.port]
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
