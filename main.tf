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

resource "null_resource" "wait_for_outputs" {
  depends_on = [
    yandex_compute_instance.k8s-master,
    yandex_compute_instance.k8s-worker
  ]

  provisioner "local-exec" {
    command = "echo 'Waiting for outputs to be ready...'"
  }
}

resource "null_resource" "check_ssh_connection" {
  depends_on = [
    null_resource.wait_for_outputs
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
      <<-EOT
      #!/bin/bash

      sudo apt-get update -y
      sudo apt install software-properties-common -y
      sudo add-apt-repository ppa:deadsnakes/ppa -y
      sudo apt-get update -y
      sudo apt-get install git pip python3.11 -y

      curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
      python3.11 get-pip.py

      git clone https://github.com/kubernetes-sigs/kubespray.git
      cd kubespray
      python3.11 -m pip install -r requirements.txt
      python3.11 -m pip install ruamel.yaml
      EOT
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
}

resource "null_resource" "copy_inventory" {
  depends_on = [null_resource.run_additional_commands]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/kubespray/inventory/mycluster",
      "cp -rfp ~/kubespray/inventory/sample ~/kubespray/inventory/mycluster"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
}

resource "null_resource" "generate_hosts_yaml" {
  depends_on = [null_resource.copy_inventory]

  provisioner "local-exec" {
    command = <<EOT
      cat <<EOF > hosts.yaml
all:
  hosts:
    %{ for host in yandex_compute_instance.k8s-master ~}
    ${host.name}:
      ansible_host: ${host.network_interface.0.ip_address}
      ip: ${host.network_interface.0.ip_address}
      access_ip: ${host.network_interface.0.ip_address}
    %{ endfor ~}
    %{ for host in yandex_compute_instance.k8s-worker ~}
    ${host.name}:
      ansible_host: ${host.network_interface.0.ip_address}
      ip: ${host.network_interface.0.ip_address}
      access_ip: ${host.network_interface.0.ip_address}
    %{ endfor ~}
  children:
    kube_control_plane:
      hosts:
        %{ for host in yandex_compute_instance.k8s-master ~}
        ${host.name}:
        %{ endfor ~}
    kube_node:
      hosts:
        %{ for host in yandex_compute_instance.k8s-worker ~}
        ${host.name}:
        %{ endfor ~}
    etcd:
      hosts:
        %{ for host in yandex_compute_instance.k8s-master ~}
        ${host.name}:
        %{ endfor ~}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF
    EOT
  }
}

resource "null_resource" "copy_hosts_yaml" {
  depends_on = [null_resource.generate_hosts_yaml]

  provisioner "file" {
    source      = "hosts.yaml"
    destination = "/home/ubuntu/kubespray/inventory/mycluster/hosts.yaml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
}

resource "null_resource" "run_ansible_playbook" {
  depends_on = [null_resource.copy_hosts_yaml]

  provisioner "remote-exec" {
    inline = [
      "cd ~/kubespray",
      "ansible playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -vvv"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
}


