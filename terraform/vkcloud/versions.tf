terraform {
  required_version = ">= 1.5"

  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.19"
    }
  }
}

# Логин, пароль и id проекта берутся из вкладки Terraform в панели VK Cloud,
# там же лежит готовый файл провайдера с username и project_id.
provider "vkcs" {
  username   = var.username
  password   = var.password
  project_id = var.project_id
}
