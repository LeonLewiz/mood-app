variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

# Имя подставляется в имена всех ресурсов, чтобы в каталоге было понятно, чьи они.
variable "name_prefix" {
  type    = string
  default = "mood-k3s"
}

variable "image_family" {
  type    = string
  default = "ubuntu-2204-lts"
}

# Кто может ходить на узел: ssh, ingress и API кластера. По умолчанию только твой адрес.
variable "allowed_cidrs" {
  type = list(string)
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 4
}

# Доля гарантированной производительности ядра, в процентах. 100 дороже, но Prometheus
# на 20 не успевает и кластер выглядит вечно занятым.
variable "core_fraction" {
  type    = number
  default = 100
}

variable "disk_size" {
  type    = number
  default = 30
}

variable "disk_type" {
  type    = string
  default = "network-ssd"
}
