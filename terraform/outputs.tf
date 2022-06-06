output "instance_private_ip" {
  description = "Instance private IP address"
  value = yandex_compute_instance.test.network_interface.0.ip_address
}

output "instance_public_ip" {
  description = "Instance public IP address"
  value = yandex_compute_instance.test.network_interface.0.nat_ip_address
}

output "instance_subnet_id" {
  description = "Subnet ID of the instance"
  value = yandex_vpc_subnet.subnet.id
}

output "yc_sa_account_id" {
  description = "Service account ID"
  value = data.yandex_iam_service_account.default.service_account_id
}