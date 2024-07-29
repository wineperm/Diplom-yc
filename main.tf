// Создание виртуальных машин для мастер-узлов
resource "yandex_compute_instance" "k8s-master" {
  count       = 1
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
    subnet_id = element([yandex_vpc_subnet.master-subnet-a.id, yandex_vpc_subnet.master-subnet-b.id, yandex_vpc_subnet.master-subnet-d.id], count.index)
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
    source      = "~/.ssh/id_ed25519"
    destination = "/home/ubuntu/.ssh/id_ed25519"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_ed25519")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_ed25519"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}

// Создание виртуальных машин для воркер-узлов
resource "yandex_compute_instance" "k8s-worker" {
  count       = 1
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
    subnet_id = element([yandex_vpc_subnet.worker-subnet-a.id, yandex_vpc_subnet.worker-subnet-b.id, yandex_vpc_subnet.worker-subnet-d.id], count.index % 3)
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
    source      = "~/.ssh/id_ed25519"
    destination = "/home/ubuntu/.ssh/id_ed25519"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_ed25519")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_ed25519"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/hosts.yaml.tpl", {
    masters = yandex_compute_instance.k8s-master
    workers = yandex_compute_instance.k8s-worker
  })
  filename = "${path.module}/inventory/mycluster/hosts.yaml"
}

resource "null_resource" "replace_text" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = <<EOT
      sed -i 's/hosts: \*\*\*/hosts: {}/' ${path.module}/inventory/mycluster/hosts.yaml
    EOT
  }
}
