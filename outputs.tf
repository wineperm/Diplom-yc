output "master_external_ips" {
  value = yandex_compute_instance.k8s-master[*].network_interface.0.nat_ip_address
}

output "master_internal_ips" {
  value = yandex_compute_instance.k8s-master[*].network_interface.0.ip_address
}

output "worker_internal_ips" {
  value = yandex_compute_instance.k8s-worker[*].network_interface.0.ip_address
}

output "master_hosts" {
  value = [
    for master in yandex_compute_instance.k8s-master : {
      name = master.name
      ip   = master.network_interface.0.nat_ip_address
    }
  ]
}

output "worker_hosts" {
  value = [
    for worker in yandex_compute_instance.k8s-worker : {
      name = worker.name
      ip   = worker.network_interface.0.ip_address
    }
  ]
}
