import json
from jinja2 import Template

with open('terraform_output.json') as f:
    data = json.load(f)

master_instances = data['master_internal_ips']['value']
worker_instances = data['worker_internal_ips']['value']

template = Template('''
all:
  hosts:
{% for host in master_instances %}
    {{ host }}:
      ansible_host: {{ host }}
      ip: {{ host }}
      access_ip: {{ host }}
{% endfor %}
{% for host in worker_instances %}
    {{ host }}:
      ansible_host: {{ host }}
      ip: {{ host }}
      access_ip: {{ host }}
{% endfor %}
  children:
    kube_control_plane:
      hosts:
{% for host in master_instances %}
        {{ host }}:
{% endfor %}
    kube_node:
      hosts:
{% for host in worker_instances %}
        {{ host }}:
{% endfor %}
    etcd:
      hosts:
{% for host in master_instances %}
        {{ host }}:
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
