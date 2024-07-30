all:
  hosts:
    %{ for master in masters ~}
    k8s-master-${master.index}:
      ansible_host: ${master.network_interface.0.nat_ip_address}
    %{ endfor ~}
    %{ for worker in workers ~}
    k8s-worker-${worker.index}:
      ansible_host: ${worker.network_interface.0.nat_ip_address}
    %{ endfor ~}
  children:
    kube_control_plane:
      hosts:
        %{ for master in masters ~}
        k8s-master-${master.index}:
        %{ endfor ~}
    kube_node:
      hosts:
        %{ for worker in workers ~}
        k8s-worker-${worker.index}:
        %{ endfor ~}
    etcd:
      hosts:
        %{ for master in masters ~}
        k8s-master-${master.index}:
        %{ endfor ~}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts:
        %{ for master in masters ~}
        k8s-master-${master.index}:
        %{ endfor ~}
