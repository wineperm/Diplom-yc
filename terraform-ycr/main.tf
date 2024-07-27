resource "yandex_container_registry" "my_registry" {
  name = "my-registry"
  folder_id = var.yc_folder_id
}
