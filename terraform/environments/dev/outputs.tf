# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# EC2 Outputs
output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = module.ec2.instance_public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${module.ec2.instance_public_ip}"
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_endpoint
}

output "rds_secret_arn" {
  description = "ARN of RDS credentials in Secrets Manager"
  value       = module.rds.db_secret_arn
}

output "get_db_password_command" {
  description = "Command to retrieve DB password"
  value       = "aws secretsmanager get-secret-value --secret-id ${module.rds.db_secret_arn} --query SecretString --output text | jq -r .password"
}

# S3 Outputs
output "s3_videos_bucket" {
  description = "S3 bucket for videos"
  value       = module.s3.videos_bucket_id
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${module.s3.cloudfront_domain_name}"
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "application_url" {
  description = "Application URL (via ALB)"
  value       = "http://${module.alb.alb_dns_name}"
}

# Summary
output "deployment_summary" {
  description = "Quick reference for your deployment"
  value       = <<-EOT
  
  ========================================
  HBO-STREAM DEPLOYMENT SUMMARY
  ========================================
  
  Application URL: http://${module.alb.alb_dns_name}
  CloudFront CDN:  https://${module.s3.cloudfront_domain_name}
  
  SSH to EC2:
  ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${module.ec2.instance_public_ip}
  
  Get DB Password:
  aws secretsmanager get-secret-value --secret-id ${module.rds.db_secret_arn} --query SecretString --output text | jq -r .password
  
  Upload video to S3:
  aws s3 cp video.mp4 s3://${module.s3.videos_bucket_id}/videos/
  
  ========================================
  EOT
}
