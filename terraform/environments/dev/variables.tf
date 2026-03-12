variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "your_ip" {
  description = "Your public IP for SSH access (format: x.x.x.x/32)"
  type        = string
  # Get your IP: curl ifconfig.me
}

variable "ssh_key_name" {
  description = "Name of your AWS EC2 key pair"
  type        = string
  # You need to create this in AWS Console first
}
