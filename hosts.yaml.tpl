all:
  hosts:
    {% for master in master_hosts %}
    {{ master.name }}:
      ansible_host: {{ master.ip }}
      ip: {{ master.ip }}
      access_ip: {{ master.ip }}
    {% endfor %}
    {% for worker in worker_hosts %}
    {{ worker.name }}:
      ansible_host: {{ worker.ip }}
      ip: {{ worker.ip }}
      access_ip: {{ worker.ip }}
    {% endfor %}
  children:
    kube_control_plane:
      hosts:
        {% for master in master_hosts %}
        {{ master.name }}:
        {% endfor %}
    kube_node:
      hosts:
        {% for worker in worker_hosts %}
        {{ worker.name }}:
        {% endfor %}
    etcd:
      hosts:
        {% for master in master_hosts %}
        {{ master.name }}:
        {% endfor %}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
