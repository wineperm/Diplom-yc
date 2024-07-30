import sys
import ruamel.yaml

def generate_inventory(master_ips, worker_ips):
    inventory = {
        'all': {
            'hosts': {},
            'children': {
                'kube_control_plane': {
                    'hosts': {}
                },
                'kube_node': {
                    'hosts': {}
                },
                'etcd': {
                    'hosts': {}
                },
                'k8s_cluster': {
                    'children': {
                        'kube_control_plane': {},
                        'kube_node': {}
                    }
                },
                'calico_rr': {
                    'hosts': {}
                }
            }
        }
    }

    for i, ip in enumerate(master_ips):
        hostname = f'k8s-master-{i}'
        inventory['all']['hosts'][hostname] = {'ansible_host': ip}
        inventory['all']['children']['kube_control_plane']['hosts'][hostname] = None
        inventory['all']['children']['etcd']['hosts'][hostname] = None
        inventory['all']['children']['k8s_cluster']['children']['kube_control_plane'][hostname] = None
        inventory['all']['children']['calico_rr']['hosts'][hostname] = None

    for i, ip in enumerate(worker_ips):
        hostname = f'k8s-worker-{i}'
        inventory['all']['hosts'][hostname] = {'ansible_host': ip}
        inventory['all']['children']['kube_node']['hosts'][hostname] = None
        inventory['all']['children']['k8s_cluster']['children']['kube_node'][hostname] = None

    return inventory

if __name__ == "__main__":
    master_ips = [line.strip() for line in open(sys.argv[1])]
    worker_ips = [line.strip() for line in open(sys.argv[2])]

    inventory = generate_inventory(master_ips, worker_ips)

    yaml = ruamel.yaml.YAML()
    yaml.dump(inventory, sys.stdout)
