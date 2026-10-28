# Внешняя сеть, на ней будет стоять балансировщик и получать публичный адрес.
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

# Роутер нужен не для входящих, а для исходящих: узел без публичного адреса,
# и без маршрута наружу cloud-init не скачает k3s.
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
  # Порты, которые узел принимает снаружи. Наружу их публикует балансировщик,
  # а сам узел пускает только с твоего адреса и из своей подсети.
  exposed_ports = {
    ssh   = 22
    api   = 6443
    http  = 80
    https = 443
  }

  # Подсеть узла нужна в списке, потому что к нему ходит балансировщик,
  # и приходит он именно из этой подсети.
  ingress_sources = concat(var.allowed_cidrs, [vkcs_networking_subnet.k3s.cidr])
}

resource "vkcs_networking_secgroup_rule" "ingress" {
  for_each = {
    for pair in setproduct(keys(local.exposed_ports), local.ingress_sources) :
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
