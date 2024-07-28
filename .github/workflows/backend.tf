terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "wineperm"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = var.yc_access_key
    secret_key = var.yc_secret_key
  }
}
