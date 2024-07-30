output "master_ips" {
  value = [for instance in yandex_compute_instance.k8s-master : instance.network_interface.0.nat_ip_address]
}

output "master_internal_ips" {
  value = [for instance in yandex_compute_instance.k8s-master : instance.network_interface.0.ip_address]
}

output "worker_internal_ips" {
  value = [for instance in yandex_compute_instance.k8s-worker : instance.network_interface.0.ip_address]
}
