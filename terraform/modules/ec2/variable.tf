variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "instance_count" {
  description = "The number of EC2 instances to create"
  type        = number
}

variable "instance_type" {
  description = "The type of EC2 instance to create"
  type        = string
}

variable "key_name" {
  description = "aws key pair name for ssh"
  type        = string
}

variable "sg_id" {
  description = "security group id from security module"
  type        = string
}
