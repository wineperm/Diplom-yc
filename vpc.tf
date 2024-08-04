# Создание сети для мастер-узлов
resource "yandex_vpc_network" "master-network" {
  name = "master-network"
}

# Создание подсети для мастер-узлов в зоне ru-central1-a
resource "yandex_vpc_subnet" "master-subnet-a" {
  name           = "master-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.master-network.id
  v4_cidr_blocks = ["10.1.1.0/24"]
}

# Создание подсети для мастер-узлов в зоне ru-central1-b
resource "yandex_vpc_subnet" "master-subnet-b" {
  name           = "master-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.master-network.id
  v4_cidr_blocks = ["10.1.2.0/24"]
}

# Создание подсети для мастер-узлов в зоне ru-central1-d
resource "yandex_vpc_subnet" "master-subnet-d" {
  name           = "master-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.master-network.id
  v4_cidr_blocks = ["10.1.3.0/24"]
}

# Создание сети для воркер-узлов
resource "yandex_vpc_network" "worker-network" {
  name = "worker-network"
}

# Создание подсети для воркер-узлов в зоне ru-central1-a
resource "yandex_vpc_subnet" "worker-subnet-a" {
  name           = "worker-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.worker-network.id
  v4_cidr_blocks = ["10.2.1.0/24"]
}

# Создание подсети для воркер-узлов в зоне ru-central1-b
resource "yandex_vpc_subnet" "worker-subnet-b" {
  name           = "worker-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.worker-network.id
  v4_cidr_blocks = ["10.2.2.0/24"]
}

# Создание подсети для воркер-узлов в зоне ru-central1-d
resource "yandex_vpc_subnet" "worker-subnet-d" {
  name           = "worker-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.worker-network.id
  v4_cidr_blocks = ["10.2.3.0/24"]
}

# Создание маршрутной таблицы для мастер-сети
resource "yandex_vpc_route_table" "master-route-table" {
  name       = "master-route-table"
  network_id = yandex_vpc_network.master-network.id

  static_route {
    destination_prefix = "10.2.0.0/16"
    next_hop_address   = "10.1.1.1"  # IP-адрес шлюза для маршрутизации в worker-network
  }
}

# Создание маршрутной таблицы для воркер-сети
resource "yandex_vpc_route_table" "worker-route-table" {
  name       = "worker-route-table"
  network_id = yandex_vpc_network.worker-network.id

  static_route {
    destination_prefix = "10.1.0.0/16"
    next_hop_address   = "10.2.1.1"  # IP-адрес шлюза для маршрутизации в master-network
  }
}

# Привязка маршрутной таблицы к подсетям мастер-сети
resource "yandex_vpc_subnet_route_table_association" "master-subnet-a-route-table" {
  subnet_id      = yandex_vpc_subnet.master-subnet-a.id
  route_table_id = yandex_vpc_route_table.master-route-table.id
}

resource "yandex_vpc_subnet_route_table_association" "master-subnet-b-route-table" {
  subnet_id      = yandex_vpc_subnet.master-subnet-b.id
  route_table_id = yandex_vpc_route_table.master-route-table.id
}

resource "yandex_vpc_subnet_route_table_association" "master-subnet-d-route-table" {
  subnet_id      = yandex_vpc_subnet.master-subnet-d.id
  route_table_id = yandex_vpc_route_table.master-route-table.id
}

# Привязка маршрутной таблицы к подсетям воркер-сети
resource "yandex_vpc_subnet_route_table_association" "worker-subnet-a-route-table" {
  subnet_id      = yandex_vpc_subnet.worker-subnet-a.id
  route_table_id = yandex_vpc_route_table.worker-route-table.id
}

resource "yandex_vpc_subnet_route_table_association" "worker-subnet-b-route-table" {
  subnet_id      = yandex_vpc_subnet.worker-subnet-b.id
  route_table_id = yandex_vpc_route_table.worker-route-table.id
}

resource "yandex_vpc_subnet_route_table_association" "worker-subnet-d-route-table" {
  subnet_id      = yandex_vpc_subnet.worker-subnet-d.id
  route_table_id = yandex_vpc_route_table.worker-route-table.id
}
