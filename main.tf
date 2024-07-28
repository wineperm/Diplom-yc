resource "local_file" "hosts_yaml" {
  content = templatefile("${path.module}/templates/hosts.yaml.tpl", {
    masters = yandex_compute_instance.k8s-master
    workers = yandex_compute_instance.k8s-worker
  })
  filename = "${path.module}/inventory/mycluster/hosts.yaml"
}

resource "time_sleep" "wait_60_seconds_after_hosts_yaml" {
  create_duration = "60s"
  depends_on = [local_file.hosts_yaml]
}

resource "null_resource" "check_inventory" {
  provisioner "local-exec" {
    command = "cat ${path.module}/inventory/mycluster/hosts.yaml"
  }

  depends_on = [
    time_sleep.wait_60_seconds_after_hosts_yaml
  ]
}

resource "time_sleep" "wait_60_seconds_after_check_inventory" {
  create_duration = "60s"
  depends_on = [null_resource.check_inventory]
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
    time_sleep.wait_60_seconds_after_check_inventory
  ]
}

resource "time_sleep" "wait_60_seconds_after_run_kubespray" {
  create_duration = "60s"
  depends_on = [null_resource.run_kubespray]
}

resource "null_resource" "check_kubeconfig" {
  provisioner "remote-exec" {
    inline = [
      "if [ -f /etc/kubernetes/admin.conf ]; then echo 'File exists'; else echo 'File does not exist'; fi"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  # Замените на вашего пользователя
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")  # Замените на путь к вашему приватному ключу
    }
  }

  depends_on = [
    time_sleep.wait_60_seconds_after_run_kubespray
  ]
}

resource "time_sleep" "wait_60_seconds_after_check_kubeconfig" {
  create_duration = "60s"
  depends_on = [null_resource.check_kubeconfig]
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
      user        = "ubuntu"  # Замените на вашего пользователя
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")  # Замените на путь к вашему приватному ключу
    }
  }

  depends_on = [
    time_sleep.wait_60_seconds_after_check_kubeconfig
  ]
}
