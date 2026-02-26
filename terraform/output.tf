output "nginx_instance_ids" {
  description = "IDs of nginx servers"
  value       = module.ec2.nginx_instance_ids
}

output "nginx_private_ips" {
  description = "Private IPs of nginx servers"
  value       = module.ec2.nginx_instance_ips
}