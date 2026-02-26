# -------------------------------------------------------
# Key Pair - uses jenkins user's public key
# -------------------------------------------------------
resource "aws_key_pair" "jenkins_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# -------------------------------------------------------
# Security Group Module
# -------------------------------------------------------
module "security_group" {
  source       = "./modules/security_group"
  project_name = var.project_name
}

# -------------------------------------------------------
# EC2 Module
# -------------------------------------------------------
module "ec2" {
  source         = "./modules/ec2"
  project_name   = var.project_name
  instance_count = var.instance_count
  instance_type  = var.instance_type
  key_name       = aws_key_pair.jenkins_key.key_name
  sg_id          = module.security_group.sg_id

}

# -------------------------------------------------------
# Write Private IPs to Ansible Inventory
# -------------------------------------------------------
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    servers_ips = module.ec2.nginx_instance_ips
  })
  filename = "${path.module}/../ansible/inventory.ini"
}