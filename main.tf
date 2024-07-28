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
}

resource "local_file" "hosts_yaml" {
  content = templatefile("${path.module}/templates/hosts.yaml.tpl", {
    masters = yandex_compute_instance.k8s-master
    workers = yandex_compute_instance.k8s-worker
  })
  filename = "${path.module}/inventory/mycluster/hosts.yaml"
}

resource "null_resource" "check_inventory" {
  provisioner "local-exec" {
    command = "cat ${path.module}/inventory/mycluster/hosts.yaml"
  }

  depends_on = [
    local_file.hosts_yaml
  ]
}

resource "null_resource" "run_kubespray" {
  provisioner "local-exec" {
    command = <<EOT
      git clone https://github.com/kubernetes-sigs/kubespray.git
      cd kubespray
      cp -rfp inventory/sample inventory/mycluster
      ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml
    EOT
  }

  depends_on = [
    yandex_compute_instance.k8s-master,
    yandex_compute_instance.k8s-worker,
    local_file.hosts_yaml,
    null_resource.check_inventory
  ]
}

resource "null_resource" "check_kubeconfig" {
  provisioner "remote-exec" {
    inline = [
      "if [ -f /etc/kubernetes/admin.conf ]; then echo 'File exists'; else echo 'File does not exist'; fi"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_ed25519")
    }
  }

  depends_on = [
    null_resource.run_kubespray
  ]
}

resource "null_resource" "configure_kubeconfig" {
  provisioner "remote-exec" {
    inline = [
      "echo 'Starting configuration...'",
      "ls -l /etc/kubernetes/admin.conf",
      "mkdir -p ~/.kube",
      "sudo cp /etc/kubernetes/admin.conf ~/.kube/config",
      "sudo chown $(id -u):$(id -g) ~/.kube/config",
      "echo 'Configuration completed.'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_ed25519")
    }
  }

  depends_on = [
    null_resource.check_kubeconfig
  ]
}
