#!/bin/bash
set -e

ENV=${1:-dev}

cd "$(dirname "$0")/../environments/$ENV"

echo "⚠️  WARNING: This will DESTROY all resources in $ENV environment!"
echo ""
echo "Resources to be destroyed:"
echo "  - EC2 instance"
echo "  - RDS database (all data will be lost!)"
echo "  - S3 bucket (all videos will be deleted!)"
echo "  - ALB, VPC, and all networking"
echo ""

read -p "Type '$ENV' to confirm destruction: " CONFIRM

if [ "$CONFIRM" != "$ENV" ]; then
  echo "❌ Destruction cancelled"
  exit 0
fi

echo "🗑️  Destroying infrastructure..."
terraform destroy -auto-approve

echo "✅ Environment $ENV destroyed"
