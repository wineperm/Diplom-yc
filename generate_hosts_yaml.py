import json
from jinja2 import Template

# Загрузка данных из JSON файлов
with open('master_ips.json') as f:
    master_external_ips = json.load(f)

with open('master_internal_ips.json') as f:
    master_internal_ips = json.load(f)

with open('worker_internal_ips.json') as f:
    worker_internal_ips = json.load(f)

# Подготовка данных для шаблона
master_hosts = [{"name": f"k8s-master-{i}", "ip": ip} for i, ip in enumerate(master_external_ips)]
worker_hosts = [{"name": f"k8s-worker-{i}", "ip": ip} for i, ip in enumerate(worker_internal_ips)]

# Загрузка шаблона
with open('templates/hosts.yaml.tpl') as f:
    template = Template(f.read())

# Генерация hosts.yaml файла
hosts_yaml = template.render(master_hosts=master_hosts, worker_hosts=worker_hosts)

with open('hosts.yaml', 'w') as f:
    f.write(hosts_yaml)
