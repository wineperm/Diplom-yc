#!/bin/bash

# Загрузка данных из terraform_output.json
terraform_output=$(cat /home/ubuntu/terraform_output.json)
master_instances=$(echo $terraform_output | jq -r '.master_internal_ips.value[]')
worker_instances=$(echo $terraform_output | jq -r '.worker_internal_ips.value[]')
master_names=$(echo $terraform_output | jq -r '.master_names.value[]')
worker_names=$(echo $terraform_output | jq -r '.worker_names.value[]')

# Генерация hosts.yaml
cat <<EOF > /home/ubuntu/kubespray/inventory/mycluster/hosts.yaml
all:
  hosts:
$(for i in "${!master_instances[@]}"; do echo "    ${master_names[$i]}:"; echo "      ansible_host: ${master_instances[$i]}"; echo "      ip: ${master_instances[$i]}"; echo "      access_ip: ${master_instances[$i]}"; echo "      ansible_user: sudo"; done)
$(for i in "${!worker_instances[@]}"; do echo "    ${worker_names[$i]}:"; echo "      ansible_host: ${worker_instances[$i]}"; echo "      ip: ${worker_instances[$i]}"; echo "      access_ip: ${worker_instances[$i]}"; echo "      ansible_user: sudo"; done)
  children:
    kube_control_plane:
      hosts:
$(for i in "${!master_instances[@]}"; do echo "        ${master_names[$i]}:"; done)
    kube_node:
      hosts:
$(for i in "${!worker_instances[@]}"; do echo "        ${worker_names[$i]}:"; done)
    etcd:
      hosts:
$(for i in "${!master_instances[@]}"; do echo "        ${master_names[$i]}:"; done)
    k8s_cluster:
      children:
        kube_control_plane: {}
        kube_node: {}
    calico_rr:
      hosts: {}
EOF
