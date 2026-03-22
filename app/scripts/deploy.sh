#!/bin/bash
set -e

echo "🚀 HBO-Stream Deployment Script"
echo "================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

# 1. Get Infrastructure details
cd ../../terraform/environments/dev
EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null)
ALB_DNS=$(terraform output -raw application_url 2>/dev/null | sed 's|http://||')
CLOUDFRONT_URL=$(terraform output -raw cloudfront_url 2>/dev/null)
S3_BUCKET=$(terraform output -raw s3_videos_bucket 2>/dev/null)
SECRET_ARN=$(terraform output -raw rds_secret_arn 2>/dev/null)

echo -e "${GREEN}✓${NC} Infrastructure details retrieved"

# 2. Get DB password
echo ""
echo "🔑 Retrieving database password..."
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --query SecretString \
  --output text | jq -r .password)

echo -e "${GREEN}✓${NC} Database password retrieved"

# 3. Create .env file
# We use the parent directory of the script as the root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo ""
echo "📝 Creating .env file..."
# Fixed the DATABASE_URL format to remove the extra characters
cat > .env << ENVFILE
DATABASE_URL=postgresql://hbo_admin:${DB_PASSWORD}@${RDS_ENDPOINT}/hbostream
SECRET_KEY=$(openssl rand -hex 32)
ENVIRONMENT=production
REACT_APP_API_URL=http://${ALB_DNS}
REACT_APP_CLOUDFRONT_URL=${CLOUDFRONT_URL}
AWS_REGION=us-east-1
S3_BUCKET=${S3_BUCKET}
ENVFILE

echo -e "${GREEN}✓${NC} .env file created"

# 4. Package application
echo ""
echo "📦 Packaging application..."
# Packaging current directory (.) instead of 'app/' because we are already in the app folder
tar --exclude="hbo-stream-app.tar.gz" --warning=no-file-changed -czf hbo-stream-app.tar.gz .
echo -e "${GREEN}✓${NC} Application packaged"

# 5. Upload and Deploy
echo ""
echo "📤 Uploading to EC2..."
scp -i ~/.ssh/hbo-stream-key.pem -o StrictHostKeyChecking=no hbo-stream-app.tar.gz ubuntu@${EC2_IP}:~/

echo ""
echo "🔧 Deploying on EC2..."
ssh -i ~/.ssh/hbo-stream-key.pem -o StrictHostKeyChecking=no ubuntu@${EC2_IP} << 'ENDSSH'
    set -e
    mkdir -p ~/app
    tar -xzf ~/hbo-stream-app.tar.gz -C ~/app
    cd ~/app
    docker-compose down 2>/dev/null || true
    docker-compose build
    docker-compose up -d
    sleep 10
    docker-compose ps
ENDSSH

rm hbo-stream-app.tar.gz
echo -e "${GREEN}🎉 DEPLOYMENT SUCCESSFUL!${NC}"