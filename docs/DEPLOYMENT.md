# Ubuntu + Nginx + Docker Deployment Guide

## Server Requirements

- Ubuntu 22.04 LTS or 24.04 LTS
- 4 GB RAM minimum (8 GB recommended)
- 40 GB SSD
- Domain name with DNS configured

## 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Install Nginx
sudo apt install nginx certbot python3-certbot-nginx -y
```

## 2. Clone & Configure

```bash
git clone <your-repo-url> /opt/ridebooking
cd /opt/ridebooking

# Backend environment
cp Backend/.env.example Backend/.env
nano Backend/.env  # Set production values

# Frontend environments
cp User-Panel/.env.example User-Panel/.env
cp Driver-Panel/.env.example Driver-Panel/.env
cp Admin-Panel/.env.example Admin-Panel/.env
```

### Production Environment Variables

```env
APP_ENV=production
DEBUG=false
SECRET_KEY=<generate-strong-secret>
JWT_SECRET_KEY=<generate-strong-jwt-secret>
DATABASE_URL=postgresql+asyncpg://rideuser:<password>@postgres:5432/ridebooking
CORS_ORIGINS=https://app.yourdomain.com,https://driver.yourdomain.com,https://admin.yourdomain.com
```

## 3. SSL with Let's Encrypt

```bash
sudo certbot --nginx -d api.yourdomain.com -d app.yourdomain.com -d driver.yourdomain.com -d admin.yourdomain.com
```

## 4. Nginx Configuration

Create `/etc/nginx/sites-available/ridebooking`:

```nginx
# API Backend
server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /ws/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}

# User Panel
server {
    listen 443 ssl http2;
    server_name app.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/app.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Driver Panel
server {
    listen 443 ssl http2;
    server_name driver.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/driver.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/driver.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Admin Panel
server {
    listen 443 ssl http2;
    server_name admin.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/admin.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/admin.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/ridebooking /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

## 5. Deploy with Docker Compose

```bash
cd /opt/ridebooking
docker compose -f docker-compose.prod.yml up -d --build
```

## 6. Database Migration & Seed

```bash
docker compose exec backend alembic upgrade head
docker compose exec backend python scripts/seed.py
```

## 7. Monitoring

```bash
# Check services
docker compose ps

# View logs
docker compose logs -f backend

# Health check
curl https://api.yourdomain.com/health
```

## 8. Backup

```bash
# Database backup
docker compose exec postgres pg_dump -U rideuser ridebooking > backup_$(date +%Y%m%d).sql

# Automated daily backup (crontab)
0 2 * * * docker compose -f /opt/ridebooking/docker-compose.prod.yml exec -T postgres pg_dump -U rideuser ridebooking | gzip > /backups/ridebooking_$(date +\%Y\%m\%d).sql.gz
```

## Security Checklist

- [ ] Change all default passwords
- [ ] Set strong JWT secrets
- [ ] Enable firewall (UFW): allow 22, 80, 443 only
- [ ] Configure rate limiting in Nginx
- [ ] Enable fail2ban
- [ ] Set up log rotation
- [ ] Configure automated SSL renewal
- [ ] Restrict admin panel by IP if possible
