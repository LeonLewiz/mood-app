output "nodes" {
  description = "Узлы кластера: роль, адрес, ресурсы"
  value = {
    for name, node in var.nodes : name => {
      role   = node.role
      ip     = split("/", node.address)[0]
      cores  = node.cores
      memory = node.memory
      disk   = node.disk
    }
  }
}

output "control_plane_ip" {
  value = local.server_ip
}

output "kubeconfig_command" {
  description = "Забрать kubeconfig с управляющего узла"
  value       = "scp ubuntu@${local.server_ip}:~/.kube/config ~/.kube/config-mood-k3s"
}

output "check_command" {
  description = "Проверить, что все три узла в кластере"
  value       = "kubectl --kubeconfig ~/.kube/config-mood-k3s get nodes -o wide"
}
