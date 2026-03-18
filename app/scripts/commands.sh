#!/bin/bash

cd ../../terraform/environments/dev
EC2_IP=$(terraform output -raw ec2_public_ip)

COMMAND=$1

case $COMMAND in
  "ssh")
    ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@${EC2_IP}
    ;;
  
  "restart")
    echo "🔄 Restarting containers..."
    ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@${EC2_IP} "cd app && docker-compose restart"
    ;;
  
  "stop")
    echo "⏸️  Stopping containers..."
    ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@${EC2_IP} "cd app && docker-compose stop"
    ;;
  
  "start")
    echo "▶️  Starting containers..."
    ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@${EC2_IP} "cd app && docker-compose start"
    ;;
  
  "status")
    echo "📊 Container status:"
    ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@${EC2_IP} "cd app && docker-compose ps"
    ;;
  
  "seed")
    echo "🌱 Seeding database..."
    ALB_DNS=$(terraform output -raw application_url)
    curl -X POST "${ALB_DNS}/api/seed"
    echo ""
    ;;
  
  *)
    echo "HBO-Stream Quick Commands"
    echo "========================"
    echo ""
    echo "Usage: ./commands.sh <command>"
    echo ""
    echo "Available commands:"
    echo "  ssh      - SSH into EC2 instance"
    echo "  restart  - Restart all containers"
    echo "  stop     - Stop all containers"
    echo "  start    - Start all containers"
    echo "  status   - Show container status"
    echo "  seed     - Seed database with sample data"
    ;;
esac
