terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

locals {
  common_tags = {
    Project     = "HBO-Stream-Free-Tier"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "hbo-stream-db-subnet-${var.environment}"
  subnet_ids = var.database_subnet_ids

  tags = merge(local.common_tags, {
    Name = "hbo-stream-db-subnet-${var.environment}"
  })
}

# Random Password
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Store in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name        = "hbo-stream/${var.environment}/db-password"
  description = "RDS PostgreSQL password"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "hbo_admin"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = 5432
    dbname   = "hbostream"
  })
}

# RDS Instance (FREE TIER)
resource "aws_db_instance" "main" {
  identifier = "hbo-stream-db-${var.environment}"

  engine               = "postgres"
  engine_version       = "16.4"
  instance_class       = "db.t3.micro"  # FREE TIER
  allocated_storage    = 20              # FREE TIER limit
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = "hbostream"
  username = "hbo_admin"
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false
  port                   = 5432

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  multi_az                = false  # Single AZ for free tier

  skip_final_snapshot       = true
  deletion_protection       = false
  auto_minor_version_upgrade = true

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(local.common_tags, {
    Name = "hbo-stream-db-${var.environment}"
  })
}
