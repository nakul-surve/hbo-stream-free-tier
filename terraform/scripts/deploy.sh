#!/bin/bash
set -e

ENV=${1:-dev}

echo "🚀 Deploying HBO-Stream to $ENV environment..."

cd "$(dirname "$0")/../environments/$ENV"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
  echo "❌ Error: terraform.tfvars not found!"
  echo "Please copy terraform.tfvars.example to terraform.tfvars and fill in your values"
  exit 1
fi

echo "📦 Initializing Terraform..."
terraform init -upgrade

echo "✅ Validating configuration..."
terraform validate

echo "🎨 Formatting code..."
terraform fmt -recursive

echo "📋 Creating execution plan..."
terraform plan -out=tfplan

echo ""
read -p "Apply this plan? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Deployment cancelled"
  rm -f tfplan
  exit 0
fi

echo "🔧 Applying changes..."
terraform apply tfplan

rm -f tfplan

echo ""
echo "✅ Deployment complete!"
echo ""
terraform output deployment_summary
