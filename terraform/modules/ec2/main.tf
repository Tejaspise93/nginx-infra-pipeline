#--------------------------------------------
# Terraform configuration for EC2 instances
#--------------------------------------------


#-------------------------------------------------------
# Data source to get the latest Amazon Linux 2023 AMI
#-------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

#-------------------------------------------------------
# Data source to get available instance types in the region
#-------------------------------------------------------

data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }

  location_type = "availability-zone"
}



resource "aws_instance" "nginx_instance" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.sg_id]

  # Cycles through only valid AZs for your instance type
  # az = data.[count.index % length(data)]
  # 1%4 = 1  ex. us-east-1a
  # 2%4 = 2  ex. us-east-1b
  # 3%4 = 3  ex. us-east-1c
  availability_zone = data.aws_ec2_instance_type_offerings.available.locations[count.index % length(data.aws_ec2_instance_type_offerings.available.locations)]

  tags = {
    Name    = "${var.project_name}-nginx-instance-${count.index + 1}"
    Project = var.project_name
  }
}