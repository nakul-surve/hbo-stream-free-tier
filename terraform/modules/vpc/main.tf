terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

locals {
  common_tags = {
    Project     = "HBO-Stream-Free-Tier"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "hbo-stream-vpc-${var.environment}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "hbo-stream-igw-${var.environment}"
  })
}

# Public Subnet 1 (us-east-1a) - CHANGED CIDR
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"  # Changed from 10.0.1.0/24
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "hbo-stream-public-1-${var.environment}"
    Type = "Public"
  })
}

# Public Subnet 2 (us-east-1b) - CHANGED CIDR
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/24"  # Changed from 10.0.2.0/24
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "hbo-stream-public-2-${var.environment}"
    Type = "Public"
  })
}

# Database Subnet 1 (us-east-1a) - CHANGED CIDR
resource "aws_subnet" "database_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.50.0/24"  # Changed from 10.0.11.0/24
  availability_zone = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = "hbo-stream-db-1-${var.environment}"
    Type = "Database"
  })
}

# Database Subnet 2 (us-east-1b) - CHANGED CIDR
resource "aws_subnet" "database_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.60.0/24"  # Changed from 10.0.12.0/24
  availability_zone = "us-east-1b"

  tags = merge(local.common_tags, {
    Name = "hbo-stream-db-2-${var.environment}"
    Type = "Database"
  })
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "hbo-stream-public-rt-${var.environment}"
  })
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Route Table for Database Subnets
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "hbo-stream-db-rt-${var.environment}"
  })
}

resource "aws_route_table_association" "database_1" {
  subnet_id      = aws_subnet.database_1.id
  route_table_id = aws_route_table.database.id
}

resource "aws_route_table_association" "database_2" {
  subnet_id      = aws_subnet.database_2.id
  route_table_id = aws_route_table.database.id
}
