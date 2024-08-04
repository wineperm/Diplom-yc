import json
from jinja2 import Template

# Загрузка данных из terraform_output.json
with open('terraform_output.json') as f:
    data = json.load(f)

# Предположим, что структура данных соответствует ожидаемой
master_instances = data.get('master_internal_ips', {}).get('value', [])
worker_instances = data.get('worker_internal_ips', {}).get('value', [])

template = Template('''
all:
  hosts:
{% for host in master_instances %}
    k8s-master-{{ loop.index0 }}:
      ansible_host: {{ host }}
      ip: {{ host }}
      access_ip: {{ host }}
{% endfor %}
{% for host in worker_instances %}
    k8s-worker-{{ loop.index0 }}:
      ansible_host: {{ host }}
      ip: {{ host }}
      access_ip: {{ host }}
{% endfor %}
  children:
    kube_control_plane:
      hosts:
{% for host in master_instances %}
        k8s-master-{{ loop.index0 }}:
{% endfor %}
    kube_node:
      hosts:
{% for host in worker_instances %}
        k8s-worker-{{ loop.index0 }}:
{% endfor %}
    etcd:
      hosts:
{% for host in master_instances %}
        k8s-master-{{ loop.index0 }}:
{% endfor %}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
''')

with open('kubespray/inventory/mycluster/hosts.yaml', 'w') as f:
    f.write(template.render(master_instances=master_instances, worker_instances=worker_instances))
