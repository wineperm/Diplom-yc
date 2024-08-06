variable "yc_cloud_id" {
  description = "Идентификатор облака Yandex"
  type        = string
}

variable "yc_folder_id" {
  description = "Идентификатор папки Yandex"
  type        = string
}

variable "yc_zone" {
  description = "Зона Yandex Cloud"
  default     = "ru-central1-a"
  type        = string
}

variable "yc_service_account_id" {
  description = "Идентификатор сервисного аккаунта"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the instances"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

variable "service_account_key_file_path" {
  description = "Path to the service account key file"
  type        = string
}

variable "yc_bucket_account_id" {
  description = "Идентификатор существующего сервисного аккаунта для бакета"
  type        = string
}

variable "yc_access_key_id" {
  description = "Access key ID for Yandex Cloud Object Storage"
  type        = string
}

variable "yc_secret_access_key" {
  description = "Secret access key for Yandex Cloud Object Storage"
  type        = string
}
