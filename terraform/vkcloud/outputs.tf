output "public_ip" {
  description = "Публичный адрес узла, он же идёт в /etc/hosts"
  value       = vkcs_compute_instance.k3s.network[0].fixed_ip_v4
}

output "flavor" {
  description = "Какой флейвор подобрался, его же смотреть в калькуляторе цен"
  value       = data.vkcs_compute_flavor.k3s.name
}

output "hosts_entry" {
  description = "Добавить в /etc/hosts на своей машине"
  value       = "${vkcs_compute_instance.k3s.network[0].fixed_ip_v4} ${var.api_hostname} mood.local grafana.mood.local alertmanager.mood.local"
}

output "kubeconfig_command" {
  description = "Забрать kubeconfig с узла"
  value       = "scp ubuntu@${vkcs_compute_instance.k3s.network[0].fixed_ip_v4}:~/.kube/config ~/.kube/config-mood-k3s"
}
