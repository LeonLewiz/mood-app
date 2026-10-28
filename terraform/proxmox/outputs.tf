# Индекс 1, а не 0: нулевым идёт петлевой интерфейс.
output "vm_ip" {
  description = "Адрес ВМ в локальной сети"
  value       = try(proxmox_virtual_environment_vm.k3s.ipv4_addresses[1][0], null)
}

output "vm_id" {
  value = proxmox_virtual_environment_vm.k3s.vm_id
}

output "hosts_entry" {
  description = "Добавить в /etc/hosts на ноутбуке"
  value       = "адрес-из-vm_ip k3s.mood.local mood.local"
}

output "kubeconfig_command" {
  description = "Забрать kubeconfig с узла"
  value       = "scp ubuntu@адрес-из-vm_ip:~/.kube/config ~/.kube/config-mood-k3s"
}
