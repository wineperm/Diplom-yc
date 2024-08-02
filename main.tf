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
  depends_on = [
    yandex_compute_instance.k8s-master,
    yandex_compute_instance.k8s-worker
  ]

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/sh
      MASTER_IPS=$(terraform output -json master_external_ips | jq -r '.[]')
      if [ -z "$MASTER_IPS" ]; then
        echo "Не найдено внешних IP-адресов мастеров."
        exit 1
      fi
      for host in $MASTER_IPS; do
        while ! nc -zv $host 22; do
          echo "Ожидание SSH-соединения с $host..."
          sleep 10
        done
        echo "SSH-соединение с $host установлено"
      done
    EOT
  }
}

 resource "null_resource" "run_additional_commands" {
  depends_on = [null_resource.check_ssh_connection]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install python3.12-venv -y",
      "python3 -m venv venv",
      "venv/bin/pip install --upgrade pip",
      "git clone https://github.com/kubernetes-sigs/kubespray",
      "cd kubespray/",
      "venv/bin/pip install -r requirements.txt",
      "venv/bin/pip install ruamel.yaml"
    ]
  
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
 }

# locals {
#   master_hosts = [for master in yandex_compute_instance.k8s-master : {
#     name = master.name
#     ip   = master.network_interface.0.ip_address
#   }]
#   worker_hosts = [for worker in yandex_compute_instance.k8s-worker : {
#     name = worker.name
#     ip   = worker.network_interface.0.ip_address
#   }]
# }

# resource "local_file" "hosts_yaml" {
#   content = templatefile("${path.module}/hosts.yaml.tpl", {
#     master_hosts = local.master_hosts
#     worker_hosts = local.worker_hosts
#   })
#   filename = "hosts.yaml"
# }

# resource "null_resource" "create_directory_on_master" {
#   depends_on = [null_resource.run_additional_commands]

#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p /home/ubuntu/inventory/mycluster"
#     ]
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(var.ssh_private_key_path)
#       host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
#     }
#   }
# }

# resource "null_resource" "copy_files_to_master" {
#   depends_on = [null_resource.create_directory_on_master, local_file.hosts_yaml]

#   provisioner "file" {
#     source      = "hosts.yaml"
#     destination = "/home/ubuntu/inventory/mycluster/hosts.yaml"
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(var.ssh_private_key_path)
#       host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
#     }
#   }

#   provisioner "file" {
#     source      = var.ssh_private_key_path
#     destination = "/home/ubuntu/.ssh/id_ed25519"
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(var.ssh_private_key_path)
#       host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod 600 /home/ubuntu/.ssh/id_ed25519"
#     ]
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(var.ssh_private_key_path)
#       host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
#     }
#   }
# }

# resource "null_resource" "run_ansible_playbook" {
#   depends_on = [null_resource.copy_files_to_master]

#   provisioner "remote-exec" {
#     inline = [
#       "source venv/bin/activate",
#       "ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -vvv"
#     ]
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(var.ssh_private_key_path)
#       host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
#     }
#   }
# }
