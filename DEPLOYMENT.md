# Deployment Guide

## Production Deployment on Linux Server

### Step 1: Server Preparation

1. **Update your system:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install Docker and Docker Compose:**
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Add your user to docker group (optional, to run without sudo)
   sudo usermod -aG docker $USER
   # Log out and back in for this to take effect
   ```

3. **Verify installation:**
   ```bash
   docker --version
   docker-compose --version
   ```

### Step 2: Clone and Configure

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/home-storage-manager.git
   cd home-storage-manager
   ```

2. **Create environment file:**
   ```bash
   cp .env.docker .env
   ```

3. **Edit `.env` with production values:**
   ```bash
   nano .env
   ```
   
   Set at minimum:
   - `DB_PASSWORD`: Strong password for database
   - `NEXT_PUBLIC_APP_URL`: Your server's IP or domain (e.g., `http://192.168.1.100:3000`)

### Step 3: Deploy

1. **Start the application:**
   ```bash
   docker-compose up -d
   ```

2. **Check status:**
   ```bash
   docker-compose ps
   ```

3. **View logs:**
   ```bash
   docker-compose logs -f
   ```

### Step 4: Firewall Configuration

If you have a firewall enabled, allow the application port:

```bash
# UFW (Ubuntu Firewall)
sudo ufw allow 3000/tcp

# Or for specific IP only:
sudo ufw allow from 192.168.1.0/24 to any port 3000
```

### Step 5: Access the Application

- **Local network**: `http://your-server-ip:3000`
- **From iPhone**: `http://your-server-ip:3000` (make sure you're on the same network)

## Using a Reverse Proxy (Optional but Recommended)

### Nginx Setup

1. **Install Nginx:**
   ```bash
   sudo apt install nginx
   ```

2. **Create Nginx configuration:**
   ```bash
   sudo nano /etc/nginx/sites-available/home-storage
   ```

3. **Add configuration:**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;  # or your-server-ip
       
       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

4. **Enable the site:**
   ```bash
   sudo ln -s /etc/nginx/sites-available/home-storage /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

5. **Update `.env`:**
   ```bash
   NEXT_PUBLIC_APP_URL=http://your-domain.com
   ```

6. **Restart the application:**
   ```bash
   docker-compose restart app
   ```

## SSL/HTTPS Setup (Optional)

### Using Let's Encrypt with Certbot

1. **Install Certbot:**
   ```bash
   sudo apt install certbot python3-certbot-nginx
   ```

2. **Get SSL certificate:**
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

3. **Update `.env`:**
   ```bash
   NEXT_PUBLIC_APP_URL=https://your-domain.com
   ```

4. **Restart the application:**
   ```bash
   docker-compose restart app
   ```

## Maintenance

### Update the Application

```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose up -d --build
```

### Backup Database

```bash
# Create backup
docker exec home_storage_db pg_dump -U storage_user home_storage > backup_$(date +%Y%m%d_%H%M%S).sql

# Or automate with cron (daily at 2 AM)
# Add to crontab: 0 2 * * * cd /path/to/app && docker exec home_storage_db pg_dump -U storage_user home_storage > backups/backup_$(date +\%Y\%m\%d).sql
```

### Monitor Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f postgres
```

### Check Resource Usage

```bash
docker stats
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs app

# Check if port is in use
sudo netstat -tulpn | grep 3000

# Restart everything
docker-compose down
docker-compose up -d
```

### Database connection issues

```bash
# Check database logs
docker-compose logs postgres

# Test database connection
docker exec -it home_storage_db psql -U storage_user -d home_storage

# Verify environment variables
docker-compose config
```

### Out of disk space

```bash
# Clean up Docker
docker system prune -a

# Remove old images
docker image prune -a
```

