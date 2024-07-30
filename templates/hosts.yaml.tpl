all:
  hosts:
    %{ for host in master_hosts ~}
    ${host.name}:
      ansible_host: ${host.ip}
      ip: ${host.ip}
      access_ip: ${host.ip}
    %{ endfor ~}
    %{ for host in worker_hosts ~}
    ${host.name}:
      ansible_host: ${host.ip}
      ip: ${host.ip}
      access_ip: ${host.ip}
    %{ endfor ~}
  children:
    kube_control_plane:
      hosts:
        %{ for host in master_hosts ~}
        ${host.name}:
        %{ endfor ~}
    kube_node:
      hosts:
        %{ for host in worker_hosts ~}
        ${host.name}:
        %{ endfor ~}
    etcd:
      hosts:
        %{ for host in master_hosts ~}
        ${host.name}:
        %{ endfor ~}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
