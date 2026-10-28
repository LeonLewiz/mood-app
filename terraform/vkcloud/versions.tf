terraform {
  required_version = ">= 1.5"

  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.19"
    }
  }
}

# Пустой блок не случаен: доступа в конфиге нет вообще.
# Провайдер читает окружение, и источник один: экспорт переменных перед запуском.
#   OS_USERNAME       логин от аккаунта VK Cloud
#   OS_PASSWORD       пароль
#   OS_PROJECT_ID     id проекта
#   OS_AUTH_URL       адрес авторизации, по умолчанию https://msk.cloud.vk.ru/infra/identity/v3/
#   OS_USER_DOMAIN_NAME  домен, по умолчанию users
#   OS_REGION_NAME    регион, по умолчанию RegionOne
provider "vkcs" {}
