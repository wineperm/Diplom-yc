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
}
#  provisioner "remote-exec" {
#    inline = [
#      "echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo"
#    ]
#    connection {
#      type        = "ssh"
#      user        = "ubuntu"
#      private_key = file(var.ssh_private_key_path)
#      host        = self.network_interface.0.nat_ip_address
#    }
#  }
#}

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
    subnet_id = element([yandex_vpc_subnet.worker-subnet-a.id, yandex_vpc_subnet.worker-subnet-b.id, yandex_vpc_subnet.worker-subnet-d.id], count.index % 3)
    nat       = false  # Установите nat в false для рабочих узлов
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
  service_account_id = var.yc_service_account_id
}

#  provisioner "remote-exec" {
#    inline = [
#      "echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo"
#    ]
#    connection {
#      type        = "ssh"
#      user        = "ubuntu"
#      private_key = file(var.ssh_private_key_path)
#      host        = self.network_interface.0.nat_ip_address
#    }
#  }
#}





#resource "null_resource" "wait_for_outputs" {
#  depends_on = [
#    yandex_compute_instance.k8s-master,
#    yandex_compute_instance.k8s-worker
#  ]
#
#  provisioner "local-exec" {
#    command = "echo 'Waiting for outputs to be ready...'"
#  }
#}

#resource "null_resource" "check_ssh_connection" {
#  depends_on = [
#    null_resource.wait_for_outputs
#  ]

#  provisioner "local-exec" {
#    command = <<EOT
#      #!/bin/sh
#      MASTER_IPS=$(terraform output -json master_external_ips | jq -r '.[]')
#      if [ -z "$MASTER_IPS" ]; then
#        echo "Не найдено внешних IP-адресов мастеров."
#        exit 1
#      fi
#      for host in $MASTER_IPS; do
#        while ! nc -zv $host 22; do
#          echo "Ожидание SSH-соединения с $host..."
#          sleep 10
#        done
#        echo "SSH-соединение с $host установлено"
#      done
#    EOT
#  }
#}

