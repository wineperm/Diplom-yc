#!/bin/bash

# Изменяем конфигурацию Terraform для закрытия внешней сети у воркеров
sed -i 's/nat       = true/nat       = false/g' terraform/main.tf

# Применяем изменения
terraform apply -auto-approve
