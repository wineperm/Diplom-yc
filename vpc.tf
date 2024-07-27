// Создание сети для мастер-узлов
resource "yandex_vpc_network" "master-network" {
  name = "master-network"
}

// Создание подсети для мастер-узлов в зоне ru-central1-a
resource "yandex_vpc_subnet" "master-subnet-a" {
  name           = "master-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.master-network.id
  v4_cidr_blocks = ["10.1.1.0/24"]
}

// Создание подсети для мастер-узлов в зоне ru-central1-b
resource "yandex_vpc_subnet" "master-subnet-b" {
  name           = "master-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.master-network.id
  v4_cidr_blocks = ["10.1.2.0/24"]
}

// Создание подсети для мастер-узлов в зоне ru-central1-d
resource "yandex_vpc_subnet" "master-subnet-d" {
  name           = "master-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.master-network.id
  v4_cidr_blocks = ["10.1.3.0/24"]
}

// Создание сети для воркер-узлов
resource "yandex_vpc_network" "worker-network" {
  name = "worker-network"
}

// Создание подсети для воркер-узлов в зоне ru-central1-a
resource "yandex_vpc_subnet" "worker-subnet-a" {
  name           = "worker-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.worker-network.id
  v4_cidr_blocks = ["10.2.1.0/24"]
}

// Создание подсети для воркер-узлов в зоне ru-central1-b
resource "yandex_vpc_subnet" "worker-subnet-b" {
  name           = "worker-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.worker-network.id
  v4_cidr_blocks = ["10.2.2.0/24"]
}

// Создание подсети для воркер-узлов в зоне ru-central1-d
resource "yandex_vpc_subnet" "worker-subnet-d" {
  name           = "worker-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.worker-network.id
  v4_cidr_blocks = ["10.2.3.0/24"]
}
