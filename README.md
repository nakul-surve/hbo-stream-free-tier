# HBO-Stream - Production-Grade Streaming Platform (AWS Free Tier)

![Architecture](https://img.shields.io/badge/AWS-Free_Tier-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-blue)
![Docker](https://img.shields.io/badge/Containers-Docker-blue)
![Cost](https://img.shields.io/badge/Cost-$0--3%2Fmonth-green)

A production-quality video streaming platform built with AWS, optimized for Free Tier ($0-3/month).

## 🏗️ Architecture
```
[User] → [CloudFront CDN] → [S3 Videos]
         ↓
      [ALB] → [EC2 t3.micro]
                ├─ Frontend (React)
                ├─ Backend (FastAPI)
                └─ Nginx
                ↓
            [RDS PostgreSQL]
```

## 💰 Cost Breakdown

**Free Tier (First 12 months):**
- EC2 t3.micro: $0 (750 hrs/month free)
- RDS db.t3.micro: $0 (750 hrs/month free)
- ALB: $0 (750 hrs/month free)
- S3: $0 (5 GB free)
- CloudFront: $0 (1 TB free)
- **Total: $2-3/month** (Secrets Manager only)

## 🚀 Features

- ✅ Infrastructure as Code (Terraform)
- ✅ Docker containerization
- ✅ PostgreSQL database with encryption
- ✅ S3 + CloudFront CDN for video delivery
- ✅ Application Load Balancer
- ✅ Security best practices (IAM, Security Groups, Encryption)
- ✅ Automated deployments
- ✅ Health checks & monitoring

## 📋 Prerequisites

1. AWS Account (Free Tier eligible)
2. AWS CLI configured
3. Terraform >= 1.6
4. SSH key pair created in AWS

## 🛠️ Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/yourusername/hbo-stream-free-tier.git
cd hbo-stream-free-tier
```

### 2. Create SSH Key (if you don't have one)
```bash
# In AWS Console:
# EC2 → Key Pairs → Create key pair
# Name: hbo-stream-key
# Download the .pem file to ~/.ssh/
chmod 400 ~/.ssh/hbo-stream-key.pem
```

### 3. Get Your Public IP
```bash
curl ifconfig.me
# Save this IP, you'll need it
```

### 4. Configure Backend
```bash
cd terraform/global/backend-setup
terraform init
terraform apply
# SAVE THE OUTPUT (S3 bucket name and account ID)
```

### 5. Update Configuration
```bash
cd ../../environments/dev

# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
nano terraform.tfvars

# Fill in:
# your_ip = "YOUR_IP_FROM_STEP_3/32"
# ssh_key_name = "hbo-stream-key"

# Also update backend.tf with your account ID from step 4
nano backend.tf
# Replace YOUR_ACCOUNT_ID with actual number
```

### 6. Deploy Infrastructure
```bash
cd ../../
./scripts/deploy.sh dev
```

**Wait 10-15 minutes for deployment to complete.**

### 7. Access Your Application
```bash
# Get application URL
cd environments/dev
terraform output application_url

# SSH to EC2
terraform output ssh_command
```

## 📊 Useful Commands
```bash
# Get database password
./scripts/get-db-password.sh dev

# SSH to EC2
./scripts/ssh-to-ec2.sh dev

# View all outputs
cd environments/dev && terraform output

# Destroy everything (be careful!)
./scripts/destroy.sh dev
```

## 🔐 Security Features

- VPC with public and database subnets
- Security Groups (principle of least privilege)
- RDS in isolated subnet (no internet access)
- Encrypted EBS volumes
- Encrypted RDS database
- Secrets Manager for credentials
- IAM roles (no hardcoded keys)
- HTTPS via CloudFront

## 📈 Scaling Strategy

**Current:** Single EC2 t3.micro (handles ~50 concurrent users)

**Vertical Scaling:**
1. t3.small (2 GB RAM) - ~100 users
2. t3.medium (4 GB RAM) - ~200 users

**Horizontal Scaling:**
1. Add Auto Scaling Group
2. Multiple EC2 instances behind ALB
3. RDS read replicas

## 🎓 Learning Outcomes

This project demonstrates:
- ✅ AWS service integration
- ✅ Infrastructure as Code
- ✅ Container orchestration
- ✅ Cost optimization
- ✅ Security best practices
- ✅ Production-ready architecture

## 📝 Tech Stack

**Infrastructure:**
- AWS (VPC, EC2, RDS, S3, CloudFront, ALB, Secrets Manager)
- Terraform
- Docker & Docker Compose

**Application:**
- Backend: Python FastAPI
- Frontend: React
- Database: PostgreSQL
- Reverse Proxy: Nginx

## 🤝 Contributing

This is a learning project. Feel free to fork and experiment!

## 📄 License

MIT License - See LICENSE file

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)
- Portfolio: [yourwebsite.com](https://yourwebsite.com)

---

**⭐ If this project helped you learn, please give it a star!**

Built with ❤️ for students learning DevOps
