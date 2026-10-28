# Публичный адрес даёт балансировщик, а не плавающий IP: квота на плавающие
# адреса в проекте исчерпана, а балансировщик берёт свой адрес из внешней сети
# сам и в той квоте не считается.
resource "vkcs_lb_loadbalancer" "k3s" {
  name           = "${var.name_prefix}-lb"
  description    = "Вход в кластер k3s"
  vip_network_id = data.vkcs_networking_network.extnet.id
}

# Слушатель на каждый порт: 22 для ssh, 6443 для kubectl, 80 и 443 под ingress.
# allowed_cidrs у слушателя сужает круг тех, кто вообще может подключиться к
# публичному адресу, чтобы API кластера не оказался открыт всему интернету.
resource "vkcs_lb_listener" "k3s" {
  for_each = local.exposed_ports

  name            = "${var.name_prefix}-${each.key}"
  description     = "порт ${each.value}"
  loadbalancer_id = vkcs_lb_loadbalancer.k3s.id
  protocol        = "TCP"
  protocol_port   = each.value
  allowed_cidrs   = var.allowed_cidrs
}

resource "vkcs_lb_pool" "k3s" {
  for_each = local.exposed_ports

  name        = "${var.name_prefix}-${each.key}"
  description = "узел k3s, порт ${each.value}"
  listener_id = vkcs_lb_listener.k3s[each.key].id
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
}

# Проверка живости: без неё балансировщик не понимает, живёт узел или нет.
resource "vkcs_lb_monitor" "k3s" {
  for_each = local.exposed_ports

  name        = "${var.name_prefix}-${each.key}"
  pool_id     = vkcs_lb_pool.k3s[each.key].id
  type        = "TCP"
  delay       = 10
  timeout     = 5
  max_retries = 3
}

resource "vkcs_lb_member" "k3s" {
  for_each = local.exposed_ports

  name          = "${var.name_prefix}-${each.key}"
  pool_id       = vkcs_lb_pool.k3s[each.key].id
  address       = vkcs_compute_instance.k3s.network[0].fixed_ip_v4
  protocol_port = each.value
  subnet_id     = vkcs_networking_subnet.k3s.id
}
