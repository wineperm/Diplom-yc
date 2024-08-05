import json
from jinja2 import Template

# Загрузка данных из terraform_output.json
with open('/home/ubuntu/terraform_output.json') as f:
    data = json.load(f)

# Предположим, что структура данных соответствует ожидаемой
master_instances = data.get('master_internal_ips', {}).get('value', [])
worker_instances = data.get('worker_internal_ips', {}).get('value', [])
master_names = data.get('master_names', {}).get('value', [])
worker_names = data.get('worker_names', {}).get('value', [])

template = Template('''
all:
  hosts:
{% for host, name in zip(master_instances, master_names) %}
    {{ name }}:
      ansible_host: {{ host }}
      ip: {{ host }}
      access_ip: {{ host }}
{% endfor %}
{% for host, name in zip(worker_instances, worker_names) %}
    {{ name }}:
      ansible_host: {{ host }}
      ip: {{ host }}
      access_ip: {{ host }}
{% endfor %}
  children:
    kube_control_plane:
      hosts:
{% for name in master_names %}
        {{ name }}:
{% endfor %}
    kube_node:
      hosts:
{% for name in worker_names %}
        {{ name }}:
{% endfor %}
    etcd:
      hosts:
{% for name in master_names %}
        {{ name }}:
{% endfor %}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
''')

# Запись сгенерированного файла hosts.yaml в нужное место
with open('/home/ubuntu/kubespray/inventory/mycluster/hosts.yaml', 'w') as f:
    f.write(template.render(master_instances=master_instances, worker_instances=worker_instances, master_names=master_names, worker_names=worker_names, zip=zip))
