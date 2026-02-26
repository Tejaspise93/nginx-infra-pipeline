variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
}

variable "instance_count" {
  description = "Number of nginx servers to create"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for nginx servers"
  type        = string
}

variable "key_name" {
  description = "Name of existing AWS key pair for SSH"
  type        = string
}

variable "public_key_path" {
  description = "Path to public key file"
  type        = string
}