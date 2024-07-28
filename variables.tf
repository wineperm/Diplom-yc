variable "yc_cloud_id" {
  description = "Идентификатор облака Yandex"
  type        = string
}

variable "yc_folder_id" {
  description = "Идентификатор папки Yandex"
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

variable "master_vm_count" {
  description = "Количество мастер-узлов"
  type        = number
  default     = 1
}

variable "worker_vm_count" {
  description = "Количество воркер-узлов"
  type        = number
  default     = 1
}

variable "zones" {
  description = "Список зон для создания подсетей"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}
