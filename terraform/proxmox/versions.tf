terraform {
  required_version = ">= 1.6"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Доступа в конфиге нет, как и в VK Cloud: адрес и токен берутся из окружения.
#   PROXMOX_VE_ENDPOINT    https://192.168.3.100:8006/
#   PROXMOX_VE_API_TOKEN   terraform-prov@pve!terraform-token=...
provider "proxmox" {
  # Сертификат на Proxmox самоподписанный, в локальной сети это нормально.
  insecure = true

  # Snippet заливается по ssh, а у токена пароля нет, поэтому имя узла и ключ
  # берутся из ssh-агента. Перед terraform нужен ssh-add.
  ssh {
    agent    = true
    username = "root"
  }
}
