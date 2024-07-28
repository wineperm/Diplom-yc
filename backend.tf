// Создание сервисного аккаунта
resource "yandex_iam_service_account" "sa" {
  folder_id = var.yc_folder_id
  name      = "wineperm"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "статический ключ доступа для объектного хранилища"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "winepermqeqweq"
  max_size   = 1073741824

  versioning {
    enabled = true
  }
}

terraform {
  backend "http" {
    address        = "https://storage.yandexcloud.net/terraform-state-bucket/terraform.tfstate"
    lock_address   = "https://storage.yandexcloud.net/terraform-state-bucket/terraform.tflock"
    unlock_address = "https://storage.yandexcloud.net/terraform-state-bucket/terraform.tflock"
    username       = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    password       = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  }
}
