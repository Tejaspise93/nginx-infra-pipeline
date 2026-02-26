output "nginx_instance_ids" {
  value = aws_instance.nginx_instance[*].id
}

output "nginx_instance_ips" {
  value = aws_instance.nginx_instance[*].private_ip
}
