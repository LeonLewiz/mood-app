terraform {
  required_version = ">= 1.6"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.118"
    }
  }
}

# Доступа в конфиге нет, как и в VK Cloud: адрес и токен берутся из окружения.
#   PROXMOX_VE_ENDPOINT    https://адрес-второго-пк:8006/
#   PROXMOX_VE_API_TOKEN   terraform@pve!provider=...
# См. terraform.tfvars.example.
provider "proxmox" {
  # Сертификат на Proxmox самоподписанный, в локальной сети это нормально.
  insecure = true
}
