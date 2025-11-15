# Quick Start Guide

Get your Home Storage Manager up and running in 5 minutes!

## Prerequisites

- Docker and Docker Compose installed
- Git installed

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/home-storage-manager.git
cd home-storage-manager
```

### 2. Configure Environment

```bash
# Copy the example environment file
cp .env.docker .env

# Edit with your settings (minimum: change DB_PASSWORD)
nano .env
```

**Minimum required changes in `.env`:**
- `DB_PASSWORD`: Set a strong password
- `NEXT_PUBLIC_APP_URL`: Set to `http://YOUR_SERVER_IP:3000`

### 3. Start the Application

```bash
docker-compose up -d
```

### 4. Verify It's Running

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f
```

### 5. Access the Application

Open your browser (or iPhone Safari) and navigate to:
```
http://YOUR_SERVER_IP:3000
```

## That's It! 🎉

Your Home Storage Manager is now running. The database is automatically initialized with:
- 3 floors: basement, ground, upstairs
- Ready to add rooms, racks, boxes, and items

## Next Steps

1. **Add a Room**: You'll need to add rooms through the database initially, or we can add UI for this later
2. **Add Boxes**: Once you have rooms, you can add boxes with NFC tags
3. **Add Items**: Start tracking items in your boxes!

## Common Commands

```bash
# Stop the application
docker-compose down

# Restart the application
docker-compose restart

# View logs
docker-compose logs -f

# Rebuild after code changes
docker-compose up -d --build
```

## Troubleshooting

**Can't access the app?**
- Check firewall: `sudo ufw allow 3000/tcp`
- Verify containers are running: `docker-compose ps`
- Check logs: `docker-compose logs app`

**Database issues?**
- Check database logs: `docker-compose logs postgres`
- Verify `.env` file has correct credentials

For more details, see [README.md](README.md) or [DEPLOYMENT.md](DEPLOYMENT.md).

