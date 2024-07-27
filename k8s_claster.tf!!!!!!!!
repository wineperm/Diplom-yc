resource "local_file" "hosts_yaml" {
  content = templatefile("${path.module}/templates/hosts.yaml.tpl", {
    masters = yandex_compute_instance.k8s-master
    workers = yandex_compute_instance.k8s-worker
  })
  filename = "${path.module}/inventory/mycluster/hosts.yaml"
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
    local_file.hosts_yaml
  ]
}

resource "null_resource" "configure_kubeconfig" {
  provisioner "remote-exec" {
    inline = [
      "mkdir ~/.kube",
      "sudo cp /etc/kubernetes/admin.conf ~/.kube/config",
      "sudo chown $(id -u):$(id -g) ~/.kube/config"
    ]

    connection {
      type        = "ssh"
      user        = "your_username"  # Замените на вашего пользователя
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
      private_key = file("~/.ssh/id_rsa")  # Замените на путь к вашему приватному ключу
    }
  }

  depends_on = [
    null_resource.run_kubespray
  ]
}
