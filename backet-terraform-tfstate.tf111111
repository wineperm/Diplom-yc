# Используйте существующий сервисный аккаунт
data "yandex_iam_service_account" "sa" {
  service_account_id = var.yc_service_account_id
}

# Используйте существующий сервисный аккаунт для бакета
data "yandex_iam_service_account" "bucket_sa" {
  service_account_id = var.yc_bucket_account_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${data.yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = data.yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "wineperm_tfstate_bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "wineperm-tfstate-bucket"
  max_size   = 1073741824
  acl        = "private"
}
