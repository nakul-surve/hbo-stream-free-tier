# HBO-Stream Application

Production-grade streaming platform deployed on AWS.

## Architecture
```
User → ALB → EC2 (Docker Compose)
              ├─ Nginx (Reverse Proxy)
              ├─ React Frontend
              ├─ FastAPI Backend
              └─ PostgreSQL (RDS)
```

## Quick Start

### Deploy Application
```bash
cd scripts
./deploy.sh
```

### View Logs
```bash
# All services
./logs.sh

# Specific service
./logs.sh backend
./logs.sh frontend
./logs.sh nginx
```

### Manage Containers
```bash
# SSH to EC2
./commands.sh ssh

# Restart containers
./commands.sh restart

# Check status
./commands.sh status

# Seed database
./commands.sh seed
```

## API Endpoints

### Backend (FastAPI)

- `GET /` - API info
- `GET /health` - Health check
- `GET /api/videos` - List all videos
- `GET /api/videos/{id}` - Get specific video
- `POST /api/videos` - Create video
- `GET /api/categories` - List categories
- `POST /api/seed` - Seed sample data

### Frontend (React)

- Accessible via ALB URL
- HBO-themed UI
- Video browsing
- Category filtering

## Environment Variables

See `.env.example` for required configuration.

## Manual Deployment

If scripts don't work, deploy manually:
```bash
# 1. Get infrastructure details
cd ../terraform/environments/dev
terraform output

# 2. Create .env file with your values

# 3. Package app
cd ../..
tar -czf hbo-stream-app.tar.gz app/

# 4. Upload to EC2
scp -i ~/.ssh/hbo-stream-key.pem hbo-stream-app.tar.gz ubuntu@EC2_IP:~/

# 5. SSH and deploy
ssh -i ~/.ssh/hbo-stream-key.pem ubuntu@EC2_IP
tar -xzf hbo-stream-app.tar.gz
cd app
docker-compose up -d
```

## Troubleshooting

### Backend won't start
```bash
# Check logs
docker-compose logs backend

# Verify database connection
docker-compose exec backend env | grep DATABASE_URL
```

### Frontend won't load
```bash
# Check nginx logs
docker-compose logs nginx

# Verify frontend is running
curl http://localhost:3000/health
```

### Database connection issues
```bash
# Test RDS connectivity from EC2
psql -h RDS_ENDPOINT -U hbo_admin -d hbostream
```

## Tech Stack

- **Frontend**: React 18, Custom CSS
- **Backend**: FastAPI (Python), SQLAlchemy
- **Database**: PostgreSQL (RDS)
- **Proxy**: Nginx
- **Containerization**: Docker, Docker Compose
- **Infrastructure**: AWS (EC2, RDS, S3, CloudFront, ALB)
- **IaC**: Terraform

## Monitoring
```bash
# Container stats
docker stats

# Container logs
docker-compose logs -f

# System resources
htop
df -h
free -m
```

## Cost Optimization

- EC2: t3.micro (Free Tier)
- RDS: db.t3.micro (Free Tier)
- S3: Under 5GB (Free Tier)
- ALB: First year free

**Estimated cost: $2-3/month**

---


