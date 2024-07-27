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
