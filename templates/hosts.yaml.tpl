all:
  hosts:
    {% for master in masters %}
    k8s-master-{{ loop.index }}:
      ansible_host: {{ master }}
      ip: {{ master }}
      access_ip: {{ master }}
    {% endfor %}
    {% for worker in workers %}
    k8s-worker-{{ loop.index }}:
      ansible_host: {{ worker }}
      ip: {{ worker }}
      access_ip: {{ worker }}
    {% endfor %}
  children:
    kube_control_plane:
      hosts:
        {% for master in masters %}
        k8s-master-{{ loop.index }}:
        {% endfor %}
    kube_node:
      hosts:
        {% for worker in workers %}
        k8s-worker-{{ loop.index }}:
        {% endfor %}
    etcd:
      hosts:
        {% for master in masters %}
        k8s-master-{{ loop.index }}:
        {% endfor %}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
        hosts: {}
