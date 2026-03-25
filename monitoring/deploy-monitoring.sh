#!/bin/bash
set -e

echo "🔍 Deploying Monitoring Stack"
echo "=============================="

# Get the absolute path to the root of the repository
# This ensures the script works no matter where you run it from
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 1. Get EC2 details
# Move to the terraform directory relative to the repo root
cd "$REPO_ROOT/terraform/environments/dev"
EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)

if [ -z "$EC2_IP" ]; then
    echo "❌ Failed to get EC2 IP. Make sure you have run terraform apply."
    exit 1
fi

echo "✅ EC2 IP: $EC2_IP"

# 2. Package monitoring configs
cd "$REPO_ROOT"
echo "📦 Packaging monitoring configuration..."

# Use the exact paths found in your file structure
tar -czf monitoring-stack.tar.gz \
  app/docker-compose.monitoring.yml \
  monitoring/

echo "✅ Package created"

# Upload to EC2
echo "📤 Uploading to EC2..."
scp -i ~/.ssh/hbo-stream-key.pem \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    monitoring-stack.tar.gz \
    ubuntu@${EC2_IP}:~/

# Deploy on EC2
echo "🚀 Deploying monitoring stack..."
ssh -i ~/.ssh/hbo-stream-key.pem \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    ubuntu@${EC2_IP} << 'DEPLOY'

# Extract
tar -xzf monitoring-stack.tar.gz

cd app

# Stop existing services
docker-compose down 2>/dev/null || true

# Start with monitoring
docker-compose -f docker-compose.monitoring.yml up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 30

# Check status
echo ""
echo "📊 Service Status:"
docker-compose -f docker-compose.monitoring.yml ps

echo ""
echo "✅ Monitoring deployed!"
echo ""
echo "Access points:"
echo "  Grafana:      http://localhost:3001 (admin/hbo-stream-admin)"
echo "  Prometheus:   http://localhost:9090"
echo "  Alertmanager: http://localhost:9093"
echo "  Node Exporter: http://localhost:9100/metrics"

DEPLOY

# Cleanup
rm monitoring-stack.tar.gz

echo ""
echo "=============================="
echo "✅ Deployment Complete!"
echo "=============================="
echo ""
echo "Access Monitoring:"
echo "  Grafana: http://${EC2_IP}:3001"
echo "    Username: admin"
echo "    Password: hbo-stream-admin"
echo ""
echo "  Prometheus: http://${EC2_IP}:9090"
echo "  Alertmanager: http://${EC2_IP}:9093"
echo ""
echo "⚠️  Security Note: Update security group to allow ports 3001, 9090, 9093 from your IP"
