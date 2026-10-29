# Доступа в переменных нет, он берётся из окружения, см. versions.tf.

variable "node_name" {
  description = "Имя узла Proxmox, оно же видно в его веб-панели"
  type        = string
  default     = "proxmox"
}

variable "vm_prefix" {
  type    = string
  default = "mood-k3s"
}

# Диски ВМ. local-lvm это lvmthin на NVMe, там быстро.
variable "disk_datastore_id" {
  type    = string
  default = "local-lvm"
}

# Хранилище для образа и snippets. На нём нужны типы содержимого Import и Snippets.
variable "image_datastore_id" {
  type    = string
  default = "data"
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "gateway" {
  type    = string
  default = "192.168.3.1"
}

variable "dns_servers" {
  type    = list(string)
  default = ["192.168.3.1"]
}

variable "image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

# Стоит ли держать control plane только под управление. Если true, на нём не будут
# селиться обычные поды, и это правильная продовая схема. Осторожно: тогда часть
# штатных компонентов вроде ingress переезжает на воркеры.
variable "dedicated_control_plane" {
  type    = bool
  default = false
}

# Три узла: один сервер k3s и два агента. Адреса из той же сети, что и Proxmox.
variable "nodes" {
  type = map(object({
    address = string
    cores   = number
    memory  = number
    disk    = number
    role    = string
  }))

  default = {
    control = {
      address = "192.168.3.151/24"
      cores   = 2
      memory  = 2048
      disk    = 15
      role    = "server"
    }
    worker1 = {
      address = "192.168.3.152/24"
      cores   = 2
      memory  = 4096
      disk    = 20
      role    = "agent"
    }
    worker2 = {
      address = "192.168.3.153/24"
      cores   = 2
      memory  = 5120
      disk    = 25
      role    = "agent"
    }
  }
}
