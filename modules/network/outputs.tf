output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.network.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.network.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "lb_ip_address" {
  description = "The IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "private_vpc_connection_id" {
  description = "The ID of the private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection.id
}
