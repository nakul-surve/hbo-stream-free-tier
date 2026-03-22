#!/bin/bash

echo "======================================"
echo "GITHUB SECRETS FOR HBO-STREAM PROJECT"
echo "======================================"
echo ""

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
echo ""

# Get EC2 Host
cd terraform/environments/dev
EC2_HOST=$(terraform output -raw ec2_public_ip 2>/dev/null)
echo "EC2_HOST: $EC2_HOST"
echo ""

# Get RDS Secret ARN
RDS_SECRET_ARN=$(terraform output -raw rds_secret_arn 2>/dev/null)
echo "RDS_SECRET_ARN: $RDS_SECRET_ARN"
echo ""

echo "======================================"
echo "INSTRUCTIONS:"
echo "======================================"
echo ""
echo "1. Go to your GitHub repository"
echo "2. Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Add these secrets:"
echo ""
echo "   Name: AWS_ACCESS_KEY_ID"
echo "   Value: [Your AWS Access Key]"
echo ""
echo "   Name: AWS_SECRET_ACCESS_KEY"
echo "   Value: [Your AWS Secret Key]"
echo ""
echo "   Name: EC2_SSH_PRIVATE_KEY"
echo "   Value: [Contents of ~/.ssh/hbo-stream-key.pem]"
echo ""
echo "   Name: EC2_HOST"
echo "   Value: $EC2_HOST"
echo ""
echo "   Name: RDS_SECRET_ARN"
echo "   Value: $RDS_SECRET_ARN"
echo ""
echo "   Name: AWS_REGION"
echo "   Value: us-east-1"
echo ""
echo "======================================"
echo "TO GET SSH PRIVATE KEY CONTENT:"
echo "======================================"
echo "cat ~/.ssh/hbo-stream-key.pem"
echo ""
