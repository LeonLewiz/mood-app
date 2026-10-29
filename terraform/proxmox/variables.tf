# Доступа в переменных нет, он берётся из окружения, см. versions.tf.

variable "node_name" {
  description = "Имя узла Proxmox, оно же видно в его веб-панели"
  type        = string
  default     = "pve"
}

variable "vm_name" {
  type    = string
  default = "mood-k3s"
}

# Диски ВМ. local-lvm есть на стандартной установке, если выбрал LVM-thin.
variable "disk_datastore_id" {
  type    = string
  default = "local-lvm"
}

# Хранилище для образа и cloud-init. Здесь нужны включённые типы содержимого
# Import и Snippets, см. terraform.tfvars.example.
variable "image_datastore_id" {
  type    = string
  default = "local"
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  description = "Мегабайты"
  type        = number
  default     = 4096
}

variable "disk_size" {
  description = "Гигабайты"
  type        = number
  default     = 30
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "vm_id" {
  description = "Номер ВМ в Proxmox, если оставить пустым, возьмётся следующий свободный"
  type        = number
  default     = null
}
