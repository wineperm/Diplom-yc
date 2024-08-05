#!/bin/bash

# Загрузка данных из terraform_output.json
terraform_output=$(cat terraform_output.json)
master_instances=$(echo $terraform_output | jq -r '.master_internal_ips.value[]')
worker_instances=$(echo $terraform_output | jq -r '.worker_internal_ips.value[]')

# Генерация hosts.yaml
cat <<EOF > /home/ubuntu/kubespray/inventory/mycluster/hosts.yaml
all:
  hosts:
$(for i in $(seq 0 $((${#master_instances[@]} - 1))); do echo "    k8s-master-$i:"; echo "      ansible_host: ${master_instances[$i]}"; echo "      ip: ${master_instances[$i]}"; echo "      access_ip: ${master_instances[$i]}"; echo "      ansible_user: sudo"; done)
$(for i in $(seq 0 $((${#worker_instances[@]} - 1))); do echo "    k8s-worker-$i:"; echo "      ansible_host: ${worker_instances[$i]}"; echo "      ip: ${worker_instances[$i]}"; echo "      access_ip: ${worker_instances[$i]}"; echo "      ansible_user: sudo"; done)
  children:
    kube_control_plane:
      hosts:
$(for i in $(seq 0 $((${#master_instances[@]} - 1))); do echo "        k8s-master-$i:"; done)
    kube_node:
      hosts:
$(for i in $(seq 0 $((${#worker_instances[@]} - 1))); do echo "        k8s-worker-$i:"; done)
    etcd:
      hosts:
$(for i in $(seq 0 $((${#master_instances[@]} - 1))); do echo "        k8s-master-$i:"; done)
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF
