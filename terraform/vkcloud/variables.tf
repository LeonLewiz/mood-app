variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "project_id" {
  type = string
}

variable "availability_zone" {
  type    = string
  default = "MS1"
}

variable "name_prefix" {
  type    = string
  default = "mood-k3s"
}

variable "image_os_distro" {
  type    = string
  default = "ubuntu"
}

variable "image_os_version" {
  type    = string
  default = "22.04"
}

# Кто может ходить на узел: ssh, ingress и API кластера.
# Префикс обязателен, одиночный адрес без /32 не принимается.
# Узнать: curl -s https://ifconfig.me
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

# В гигабайтах. Флейвор подбирается по этим двум числам, руками имя не пишем.
variable "memory" {
  type    = number
  default = 4
}

variable "disk_size" {
  type    = number
  default = 30
}

variable "disk_type" {
  type    = string
  default = "ceph-ssd"
}
