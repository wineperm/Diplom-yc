all:
  hosts:
    %{ for i, ip in master_ips ~}
    node${i + 1}:
      ansible_host: ${ip}
      ip: ${ip}
      access_ip: ${ip}
    %{ endfor ~}
    %{ for i, ip in worker_ips ~}
    node${i + ${length(master_ips)} + 1}:
      ansible_host: ${ip}
      ip: ${ip}
      access_ip: ${ip}
    %{ endfor ~}
  children:
    kube_control_plane:
      hosts:
        %{ for i, ip in master_ips ~}
        node${i + 1}:
        %{ endfor ~}
    kube_node:
      hosts:
        %{ for i, ip in worker_ips ~}
        node${i + ${length(master_ips)} + 1}:
        %{ endfor ~}
    etcd:
      hosts:
        %{ for i, ip in master_ips ~}
        node${i + 1}:
        %{ endfor ~}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
