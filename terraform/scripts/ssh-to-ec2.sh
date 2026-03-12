#!/bin/bash
set -e

ENV=${1:-dev}

cd "$(dirname "$0")/../environments/$ENV"

EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
KEY_NAME=$(terraform output -raw ssh_command 2>/dev/null | grep -oP '(?<=-i ~/.ssh/)[^ ]*' | sed 's/.pem//')

if [ -z "$EC2_IP" ]; then
  echo "❌ Error: Could not find EC2 IP"
  echo "Make sure infrastructure is deployed"
  exit 1
fi

echo "🔐 Connecting to EC2 instance..."
ssh -i ~/.ssh/${KEY_NAME}.pem ubuntu@${EC2_IP}
