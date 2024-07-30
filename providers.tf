terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"

  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "wineperm12354464"
    region   = "ru-central1"
    key      = "terraform.tfstate"
    access_key = var.yc_access_key
    secret_key = var.yc_secret_key

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
  service_account_key_file = file("~/.ssh/authorized_key.json")
}

provider "local" {}

provider "null" {}
