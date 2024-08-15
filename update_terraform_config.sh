# #!/bin/bash

# # Изменяем конфигурацию Terraform для закрытия внешней сети у воркеров
# sed -i '/resource "yandex_compute_instance" "k8s-worker"/,/}/ {
#   /nat       = true/ {
#     s/nat       = true/nat       = false/
#   }
# }' terraform/main.tf

# # Применяем изменения
# terraform apply -auto-approve
