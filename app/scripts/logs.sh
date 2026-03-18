#!/bin/bash

cd ../../terraform/environments/dev
EC2_IP=$(terraform output -raw ec2_public_ip)

SERVICE=${1:-all}

echo "📋 Viewing logs for: $SERVICE"
echo ""

ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@${EC2_IP} << ENDSSH
cd app
if [ "$SERVICE" = "all" ]; then
    docker-compose logs --tail=100 -f
else
    docker-compose logs --tail=100 -f $SERVICE
fi
ENDSSH
