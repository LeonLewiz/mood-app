output "public_ip" {
  description = "Адрес узла, его же подставлять в /etc/hosts"
  value       = yandex_compute_instance.k3s.network_interface[0].nat_ip_address
}

output "instance_id" {
  value = yandex_compute_instance.k3s.id
}

output "kubeconfig_command" {
  description = "Забрать kubeconfig с узла"
  value       = "scp ubuntu@${yandex_compute_instance.k3s.network_interface[0].nat_ip_address}:~/.kube/config ~/.kube/config-mood-k3s"
}
