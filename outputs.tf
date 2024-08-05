output "runner_external_ip" {
  value = yandex_compute_instance.runner.network_interface.0.nat_ip_address
}

output "master_names" {
  value = yandex_compute_instance.k8s-master[*].name
}

output "master_external_ips" {
  value = yandex_compute_instance.k8s-master[*].network_interface.0.nat_ip_address
}

output "master_internal_ips" {
  value = yandex_compute_instance.k8s-master[*].network_interface.0.ip_address
}

output "worker_names" {
  value = yandex_compute_instance.k8s-worker[*].name
}

output "worker_internal_ips" {
  value = yandex_compute_instance.k8s-worker[*].network_interface.0.ip_address
}

