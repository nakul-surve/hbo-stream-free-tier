#!/bin/bash
set -e

echo "🚀 HBO-Stream Deployment Script"
echo "================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get EC2 IP from Terraform
cd ../../terraform/environments/dev
EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null)
ALB_DNS=$(terraform output -raw application_url 2>/dev/null | sed 's|http://||')
CLOUDFRONT_URL=$(terraform output -raw cloudfront_url 2>/dev/null)
S3_BUCKET=$(terraform output -raw s3_videos_bucket 2>/dev/null)
SECRET_ARN=$(terraform output -raw rds_secret_arn 2>/dev/null)

echo -e "${GREEN}✓${NC} Infrastructure details retrieved"
echo "  EC2 IP: $EC2_IP"
echo "  RDS: $RDS_ENDPOINT"
echo "  ALB: $ALB_DNS"

# Get DB password
echo ""
echo "🔑 Retrieving database password..."
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --query SecretString \
  --output text | jq -r .password)

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}✗${NC} Failed to retrieve database password"
    exit 1
fi

echo -e "${GREEN}✓${NC} Database password retrieved"

# Create .env file
cd ../../app
echo ""
echo "📝 Creating .env file..."

cat > .env << ENVFILE
# Database Configuration
DATABASE_URL=postgresql://hbo_admin:${DB_PASSWORD}@${RDS_ENDPOINT%:*}/hbostream

# Backend Configuration
SECRET_KEY=$(openssl rand -hex 32)
ENVIRONMENT=production

# Frontend Configuration
REACT_APP_API_URL=http://${ALB_DNS}
REACT_APP_CLOUDFRONT_URL=${CLOUDFRONT_URL}

# AWS Configuration
AWS_REGION=us-east-1
S3_BUCKET=${S3_BUCKET}
ENVFILE

echo -e "${GREEN}✓${NC} .env file created"

# Package application
echo ""
echo "📦 Packaging application..."
cd ..
tar -czf hbo-stream-app.tar.gz app/
echo -e "${GREEN}✓${NC} Application packaged"

# Upload to EC2
echo ""
echo "📤 Uploading to EC2..."
scp -i ~/.ssh/hbo-stream-key.pem \
    -o StrictHostKeyChecking=no \
    hbo-stream-app.tar.gz \
    ubuntu@${EC2_IP}:~/

echo -e "${GREEN}✓${NC} Upload complete"

# Deploy on EC2
echo ""
echo "🔧 Deploying application on EC2..."
ssh -i ~/.ssh/hbo-stream-key.pem \
    -o StrictHostKeyChecking=no \
    ubuntu@${EC2_IP} << 'ENDSSH'

# Extract application
cd ~
tar -xzf hbo-stream-app.tar.gz
cd app

# Stop existing containers
echo "Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Build images
echo "Building Docker images..."
docker-compose build

# Start containers
echo "Starting containers..."
docker-compose up -d

# Wait for services
echo "Waiting for services to start..."
sleep 10

# Check status
echo ""
echo "=== Container Status ==="
docker-compose ps

# Check health
echo ""
echo "=== Health Checks ==="
echo "Backend health:"
curl -s http://localhost:8000/health | jq . || echo "Backend not ready yet"

echo ""
echo "Frontend health:"
curl -s http://localhost:3000/health || echo "Frontend not ready yet"

echo ""
echo "✅ Deployment complete!"

ENDSSH

# Cleanup
rm hbo-stream-app.tar.gz

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}🎉 DEPLOYMENT SUCCESSFUL!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Application URLs:"
echo "  Frontend: http://${ALB_DNS}"
echo "  Backend API: http://${ALB_DNS}/api"
echo "  CloudFront: ${CLOUDFRONT_URL}"
echo ""
echo "SSH to EC2:"
echo "  ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@${EC2_IP}"
echo ""
echo "View logs:"
echo "  ssh ubuntu@${EC2_IP} 'cd app && docker-compose logs -f'"
echo ""
