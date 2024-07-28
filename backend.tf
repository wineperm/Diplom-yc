terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "ru-central1"
    access_key = var.yc_access_key
    secret_key = var.yc_secret_key
    endpoint = "storage.yandexcloud.net"
  }
}
