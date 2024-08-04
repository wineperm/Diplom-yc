resource "yandex_compute_instance" "k8s-master" {
  count       = 3
  name        = "k8s-master-${count.index}"
  platform_id = "standard-v2"
  zone        = element(["ru-central1-a", "ru-central1-b", "ru-central1-d"], count.index)
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = "fd8k2vlv3b3duv812ama"
      type     = "network-hdd"
      size     = 10
    }
  }
  network_interface {
    subnet_id = element([yandex_vpc_subnet.k8s-subnet-a.id, yandex_vpc_subnet.k8s-subnet-b.id, yandex_vpc_subnet.k8s-subnet-d.id], count.index)
    nat       = true
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  service_account_id = var.yc_service_account_id
}

resource "yandex_compute_instance" "k8s-worker" {
  count       = 2
  name        = "k8s-worker-${count.index}"
  platform_id = "standard-v2"
  zone        = element(["ru-central1-a", "ru-central1-b", "ru-central1-d"], count.index % 3)
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = "fd8k2vlv3b3duv812ama"
      type     = "network-hdd"
      size     = 10
    }
  }
  network_interface {
    subnet_id = element([yandex_vpc_subnet.k8s-subnet-a.id, yandex_vpc_subnet.k8s-subnet-b.id, yandex_vpc_subnet.k8s-subnet-d.id], count.index % 3)
    nat       = false
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  service_account_id = var.yc_service_account_id
}
