output "master_ips" {
  value = yandex_compute_instance.k8s-master[*].network_interface.0.nat_ip_address
}

output "worker_ips" {
  value = yandex_compute_instance.k8s-worker[*].network_interface.0.nat_ip_address
}
