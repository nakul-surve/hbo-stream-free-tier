#!/bin/bash
set -e

ENV=${1:-dev}

cd "$(dirname "$0")/../environments/$ENV"

SECRET_ARN=$(terraform output -raw rds_secret_arn 2>/dev/null)

if [ -z "$SECRET_ARN" ]; then
  echo "❌ Error: Could not find RDS secret ARN"
  echo "Make sure infrastructure is deployed"
  exit 1
fi

echo "🔑 Retrieving database credentials..."
echo ""

aws secretsmanager get-secret-value \\
  --secret-id "$SECRET_ARN" \\
  --query SecretString \\
  --output text | jq -r '
    "Database Credentials:",
    "==================",
    "Host:     " + .host,
    "Port:     " + (.port | tostring),
    "Database: " + .dbname,
    "Username: " + .username,
    "Password: " + .password,
    "",
    "Connection String:",
    "postgresql://" + .username + ":" + .password + "@" + .host + ":" + (.port | tostring) + "/" + .dbname
  '
