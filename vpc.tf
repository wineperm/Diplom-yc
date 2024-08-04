resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s-subnet-a" {
  name           = "k8s-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.1.1.0/24"]
}

resource "yandex_vpc_subnet" "k8s-subnet-b" {
  name           = "k8s-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.1.2.0/24"]
}

resource "yandex_vpc_subnet" "k8s-subnet-d" {
  name           = "k8s-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.1.3.0/24"]
}
