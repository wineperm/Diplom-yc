// Создание сети для мастер-узлов
resource "yandex_vpc_network" "master-network" {
  name = "master-network"
}

// Создание подсетей для мастер-узлов
resource "yandex_vpc_subnet" "master-subnet" {
  count          = var.master_vm_count
  name           = "master-subnet-${count.index}"
  zone           = element(var.zones, count.index % length(var.zones))
  network_id     = yandex_vpc_network.master-network.id
  v4_cidr_blocks = ["10.1.${count.index + 1}.0/24"]
}

// Создание сети для воркер-узлов
resource "yandex_vpc_network" "worker-network" {
  name = "worker-network"
}

// Создание подсетей для воркер-узлов
resource "yandex_vpc_subnet" "worker-subnet" {
  count          = var.worker_vm_count
  name           = "worker-subnet-${count.index}"
  zone           = element(var.zones, count.index % length(var.zones))
  network_id     = yandex_vpc_network.worker-network.id
  v4_cidr_blocks = ["10.2.${count.index + 1}.0/24"]
}
