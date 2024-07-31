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
      "pip3 install ruamel.yaml"
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
  depends_on = [null_resource.run_additional_commands]

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF > hosts.yaml
all:
  hosts:
EOF

for i in range(length(yandex_compute_instance.k8s-master)):
  cat <<EOF >> hosts.yaml
    node${i + 1}:
      ansible_host: ${yandex_compute_instance.k8s-master[i].network_interface.0.ip_address}
      ip: ${yandex_compute_instance.k8s-master[i].network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.k8s-master[i].network_interface.0.ip_address}
EOF

for i in range(length(yandex_compute_instance.k8s-worker)):
  cat <<EOF >> hosts.yaml
    node${i + length(yandex_compute_instance.k8s-master) + 1}:
      ansible_host: ${yandex_compute_instance.k8s-worker[i].network_interface.0.ip_address}
      ip: ${yandex_compute_instance.k8s-worker[i].network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.k8s-worker[i].network_interface.0.ip_address}
EOF

cat <<EOF >> hosts.yaml
  children:
    kube_control_plane:
      hosts:
EOF

for i in range(length(yandex_compute_instance.k8s-master)):
  cat <<EOF >> hosts.yaml
        node${i + 1}:
EOF

cat <<EOF >> hosts.yaml
    kube_node:
      hosts:
EOF

for i in range(length(yandex_compute_instance.k8s-worker)):
  cat <<EOF >> hosts.yaml
        node${i + length(yandex_compute_instance.k8s-master) + 1}:
EOF

cat <<EOF >> hosts.yaml
    etcd:
      hosts:
EOF

for i in range(length(yandex_compute_instance.k8s-master)):
  cat <<EOF >> hosts.yaml
        node${i + 1}:
EOF

cat <<EOF >> hosts.yaml
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

resource "null_resource" "copy_files_to_master" {
  depends_on = [null_resource.generate_hosts_yaml]

  provisioner "file" {
    source      = "hosts.yaml"
    destination = "/home/ubuntu/inventory/mycluster/hosts.yaml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }

  provisioner "file" {
    source      = var.ssh_private_key_path
    destination = "/home/ubuntu/.ssh/id_ed25519"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_ed25519"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
}

resource "null_resource" "run_ansible_playbook" {
  depends_on = [null_resource.copy_files_to_master]

  provisioner "remote-exec" {
    inline = [
      "source venv/bin/activate",
      "ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -vvv"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = yandex_compute_instance.k8s-master[0].network_interface.0.nat_ip_address
    }
  }
}
