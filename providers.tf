terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
 
#backend "s3" {
#    endpoints = {
#      s3 = "https://storage.yandexcloud.net"
#    }
#    bucket = "wineperm-tfstate"
#    region = "ru-central1"
#    key    = "terraform.tfstate"

#    skip_region_validation      = true
#    skip_credentials_validation = true
#    skip_requesting_account_id  = true 
#    skip_s3_checksum            = true
#  }
}

provider "yandex" {
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.yc_zone
  service_account_key_file = file("~/.ssh/authorized_key.json")
}

provider "local" {}

provider "null" {}
