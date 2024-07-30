all:
  hosts:
    %{ for i, master in masters ~}
    k8s-master-${i}:
      ansible_host: ${master.network_interface.0.nat_ip_address}
    %{ endfor ~}
    %{ for i, worker in workers ~}
    k8s-worker-${i}:
      ansible_host: ${worker.network_interface.0.nat_ip_address}
    %{ endfor ~}
  children:
    kube_control_plane:
      hosts:
        %{ for i, master in masters ~}
        k8s-master-${i}:
        %{ endfor ~}
    kube_node:
      hosts:
        %{ for i, worker in workers ~}
        k8s-worker-${i}:
        %{ endfor ~}
    etcd:
      hosts:
        %{ for i, master in masters ~}
        k8s-master-${i}:
        %{ endfor ~}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts:
        %{ for i, master in masters ~}
        k8s-master-${i}:
        %{ endfor ~}
