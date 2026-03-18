terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "HBO-Stream-Free-Tier"
      ManagedBy   = "Terraform"
      CostCenter  = "Student-Learning"
    }
  }
}

locals {
  environment = var.environment
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment = local.environment
  vpc_cidr    = "10.0.0.0/16"
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = module.vpc.vpc_cidr
  your_ip     = var.your_ip
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  environment       = local.environment
  subnet_id         = module.vpc.public_subnet_ids[0]  # Use first public subnet
  security_group_id = module.security_groups.ec2_security_group_id
  key_name          = var.ssh_key_name
  instance_type     = "t3.micro"
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment         = local.environment
  vpc_id              = module.vpc.vpc_id
  database_subnet_ids = module.vpc.database_subnet_ids
  security_group_id   = module.security_groups.rds_security_group_id
}

# S3 Module
module "s3" {
  source = "../../modules/s3"

  environment = local.environment
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  environment       = local.environment
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids  # FIXED: Now passes list of both subnets
  security_group_id = module.security_groups.alb_security_group_id
  ec2_instance_id   = module.ec2.instance_id

  depends_on = [module.ec2]
}

