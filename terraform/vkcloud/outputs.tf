output "loadbalancer_ip" {
  description = "Единственный публичный адрес, сюда идут все имена"
  value       = vkcs_lb_loadbalancer.k3s.vip_address
}

output "node_private_ip" {
  description = "Адрес узла во внутренней сети, снаружи недоступен"
  value       = vkcs_compute_instance.k3s.network[0].fixed_ip_v4
}

output "flavor" {
  value = data.vkcs_compute_flavor.k3s.name
}

output "hosts_entry" {
  description = "Добавить в /etc/hosts на своей машине"
  value       = "${vkcs_lb_loadbalancer.k3s.vip_address} ${var.api_hostname} mood.local grafana.mood.local alertmanager.mood.local"
}

output "kubeconfig_command" {
  description = "Забрать kubeconfig с узла через балансировщик"
  value       = "scp ubuntu@${vkcs_lb_loadbalancer.k3s.vip_address}:~/.kube/config ~/.kube/config-mood-k3s"
}

output "member_check" {
  description = "Проверить, что балансировщик видит узел живым"
  value       = "openstack loadbalancer member list ${var.name_prefix}-api"
}
