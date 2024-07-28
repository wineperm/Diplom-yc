terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-state-bucket"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = "${YC_ACCESS_KEY}"
    secret_key = "${YC_SECRET_KEY}"
  }
}
