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

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection successful'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface.0.nat_ip_address
    }
  }
}

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

resource "null_resource" "check_ssh_connection" {
  depends_on = [yandex_compute_instance.k8s-master, yandex_compute_instance.k8s-worker]

  provisioner "local-exec" {
    command = "ssh -o ConnectTimeout=5 -i ${var.ssh_private_key_path} ubuntu@${yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address} echo 'SSH connection successful'"
  }
}

resource "null_resource" "run_additional_commands" {
  depends_on = [null_resource.check_ssh_connection]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install python3.12-venv -y",
      "python3 -m venv venv",
      "source venv/bin/activate",
      "git clone https://github.com/kubernetes-sigs/kubespray",
      "cd kubespray/",
      "pip3 install -r requirements.txt",
      "pip3 install ruamel.yaml",
      "cp -rfp inventory/sample inventory/mycluster"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
}
