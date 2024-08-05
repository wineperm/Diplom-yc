resource "yandex_compute_instance" "runner" {
  name        = "runner"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 4
    core_fraction = 50
  }
  boot_disk {
    initialize_params {
      image_id = "fd8k2vlv3b3duv812ama"
      type     = "network-ssd"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-subnet-a.id
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
