output "public_ip" {
  description = "Адрес узла, его же подставлять в /etc/hosts"
  value       = vkcs_networking_floatingip.k3s.address
}

output "instance_id" {
  value = vkcs_compute_instance.k3s.id
}

output "flavor" {
  value = data.vkcs_compute_flavor.k3s.name
}

output "kubeconfig_command" {
  description = "Забрать kubeconfig с узла"
  value       = "scp ubuntu@${vkcs_networking_floatingip.k3s.address}:~/.kube/config ~/.kube/config-mood-k3s"
}
