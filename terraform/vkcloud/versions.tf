terraform {
  required_version = ">= 1.5"

  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.19"
    }
  }
}

provider "vkcs" {
  username   = var.username
  password   = var.password
  project_id = var.project_id
}
