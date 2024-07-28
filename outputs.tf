output "master_ips" {
  value = [for master in yandex_compute_instance.k8s-master : master.network_interface.0.nat_ip_address]
}

output "worker_ips" {
  value = [for worker in yandex_compute_instance.k8s-worker : worker.network_interface.0.nat_ip_address]
}

output "k8s_master_ips" {
  value = yandex_compute_instance.k8s-master[*].network_interface.0.nat_ip_address
}

output "k8s_worker_ips" {
  value = yandex_compute_instance.k8s-worker[*].network_interface.0.nat_ip_address
}
