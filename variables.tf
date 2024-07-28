variable "yc_cloud_id" {
  description = "Идентификатор облака Yandex"
}

variable "yc_folder_id" {
  description = "Идентификатор папки Yandex"
}

variable "yc_zone" {
  description = "Зона Yandex Cloud"
  default     = "ru-central1-a"
}

variable "yc_service_account_id" {
  description = "Идентификатор сервисного аккаунта"
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the instances"
  type        = string
}

#variable "yc_token" {
#  type = string
#}
