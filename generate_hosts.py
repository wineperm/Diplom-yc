import json
import os
from jinja2 import Template

# Проверка существования файла terraform_output.json
if not os.path.exists('/kubespray/terraform_output.json'):
    raise FileNotFoundError("terraform_output.json not found")

# Загрузка данных из terraform_output.json
with open('/kubespray/terraform_output.json') as f:
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

# Проверка и создание директории, если она не существует
output_dir = '/kubespray/inventory/mycluster'
os.makedirs(output_dir, exist_ok=True)

with open
