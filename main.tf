// Создание виртуальных машин для мастер-узлов
resource "yandex_compute_instance" "k8s-master" {
  count       = var.master_vm_count
  name        = "k8s-master-${count.index}"
  platform_id = "standard-v2"
  zone        = element(var.zones, count.index % length(var.zones))
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
    subnet_id = element(yandex_vpc_subnet.master-subnet.*.id, count.index)
    nat       = true
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  service_account_id = var.yc_service_account_id

  provisioner "file" {
    source      = "${path.module}/.ssh/id_ed25519"
    destination = "/home/ubuntu/.ssh/id_ed25519"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("${path.module}/.ssh/id_ed25519")
    }
  }
}

// Создание виртуальных машин для воркер-узлов
resource "yandex_compute_instance" "k8s-worker" {
  count       = var.worker_vm_count
  name        = "k8s-worker-${count.index}"
  platform_id = "standard-v2"
  zone        = element(var.zones, count.index % length(var.zones))
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
    subnet_id = element(yandex_vpc_subnet.worker-subnet.*.id, count.index)
    nat       = true
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  service_account_id = var.yc_service_account_id

  provisioner "file" {
    source      = "${path.module}/.ssh/id_ed25519"
    destination = "/home/ubuntu/.ssh/id_ed25519"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("${path.module}/.ssh/id_ed25519")
    }
  }
}
