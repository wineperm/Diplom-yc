import json
from jinja2 import Template

with open('terraform_output.json') as f:
    data = json.load(f)

# Отладочный вывод для проверки структуры JSON-данных
print(json.dumps(data, indent=2))

# Предположим, что структура данных соответствует ожидаемой
master_instances = data.get('yandex_compute_instance', {}).get('k8s-master', {}).get('value', [])
worker_instances = data.get('yandex_compute_instance', {}).get('k8s-worker', {}).get('value', [])

template = Template('''
all:
  hosts:
{% for host in master_instances %}
    {{ host.name }}:
      ansible_host: {{ host.network_interface.0.ip_address }}
      ip: {{ host.network_interface.0.ip_address }}
      access_ip: {{ host.network_interface.0.ip_address }}
{% endfor %}
{% for host in worker_instances %}
    {{ host.name }}:
      ansible_host: {{ host.network_interface.0.ip_address }}
      ip: {{ host.network_interface.0.ip_address }}
      access_ip: {{ host.network_interface.0.ip_address }}
{% endfor %}
  children:
    kube_control_plane:
      hosts:
{% for host in master_instances %}
        {{ host.name }}:
{% endfor %}
    kube_node:
      hosts:
{% for host in worker_instances %}
        {{ host.name }}:
{% endfor %}
    etcd:
      hosts:
{% for host in master_instances %}
        {{ host.name }}:
{% endfor %}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
''')

with open('hosts.yaml', 'w') as f:
    f.write(template.render(master_instances=master_instances, worker_instances=worker_instances))
