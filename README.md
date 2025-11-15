# Home Storage Management System

A complete home storage management system with PostgreSQL database and mobile-friendly web interface. Track your storage across multiple floors, rooms, racks, and boxes with NFC tags.

## 🚀 Quick Start with Docker

The easiest way to deploy this application is using Docker Compose. Everything runs in containers - no need to install Node.js or PostgreSQL separately.

### Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/home-storage-manager.git
   cd home-storage-manager
   ```
   
   > **Note**: Replace `YOUR_USERNAME` with your actual GitHub username

2. **Create environment file:**
   ```bash
   cp .env.docker .env
   ```

3. **Edit `.env` and set your configuration:**
   ```bash
   # Database Configuration
   DB_PASSWORD=your_secure_password_here
   DB_NAME=home_storage
   DB_USER=storage_user
   
   # Application Configuration
   APP_PORT=3000
   NEXT_PUBLIC_APP_URL=http://your-server-ip:3000
   # Or if you have a domain:
   # NEXT_PUBLIC_APP_URL=https://yourdomain.com
   ```

4. **Start the application:**
   ```bash
   docker-compose up -d
   ```

5. **Check the logs to ensure everything started correctly:**
   ```bash
   docker-compose logs -f
   ```

6. **Access the application:**
   - Open your browser to `http://your-server-ip:3000`
   - On your iPhone, access via Safari: `http://your-server-ip:3000`

### Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild after code changes
docker-compose up -d --build

# Stop and remove volumes (⚠️ deletes all data)
docker-compose down -v
```

## 📱 Mobile Access

### Add to iPhone Home Screen

1. Open Safari on your iPhone
2. Navigate to your server URL
3. Tap the Share button
4. Select "Add to Home Screen"
5. The app will work like a native app!

## 🏗️ Architecture

### Database Structure

- **Floors**: basement, ground, upstairs
- **Rooms**: Multiple rooms per floor
- **Racks**: Optional storage racks within rooms
- **Boxes**: Storage boxes with NFC tags that can be placed in rooms or racks
- **Items**: Individual items stored in boxes (with name, description, quantity, tag)
- **Item Groups**: Named groups for organizing related items
- **Item Links**: Direct relationships between items (e.g., related, part_of, replacement)

### Technology Stack

- **Frontend**: Next.js 14, React, TypeScript, Tailwind CSS
- **Backend**: Next.js API Routes
- **Database**: PostgreSQL 16
- **Deployment**: Docker & Docker Compose

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_PASSWORD` | PostgreSQL password | `change_me_in_production` |
| `DB_NAME` | Database name | `home_storage` |
| `DB_USER` | Database user | `storage_user` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `APP_PORT` | Application port | `3000` |
| `NEXT_PUBLIC_APP_URL` | Public URL for the app | `http://localhost:3000` |

### Port Configuration

By default, the application uses:
- **Port 3000**: Web application
- **Port 5432**: PostgreSQL database (only exposed on localhost in production)

To change ports, edit the `.env` file and update `APP_PORT` and `DB_PORT`.

## 📊 Features

- **Mobile-First Design**: Optimized for iPhone Safari with touch-friendly interface
- **Clean UI**: Modern, minimalist design with Tailwind CSS
- **Dashboard**: Overview with statistics and quick navigation
- **Floor Navigation**: Browse by floor (basement, ground, upstairs)
- **Room Management**: View rooms and their contents
- **Box Tracking**: Search and view all boxes with NFC tag support
- **Item Management**: Add, view, and manage items in boxes
- **Search & Filter**: Quick search across boxes and items, filter by tags
- **Responsive Layout**: Works seamlessly on mobile and desktop

## 🛠️ Development

### Local Development (without Docker)

1. **Start the database:**
   ```bash
   docker-compose up -d postgres
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Create `.env` file:**
   ```bash
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=home_storage
   DB_USER=storage_user
   DB_PASSWORD=change_me_in_production
   ```

4. **Run development server:**
   ```bash
   npm run dev
   ```

## 🔒 Security Notes

- **Change default passwords** before deploying to production
- **Use strong passwords** for database access
- **Consider using a reverse proxy** (nginx, Traefik) for HTTPS
- **Restrict database port** to localhost only (already configured in `docker-compose.prod.yml`)
- **Keep Docker images updated** regularly

## 📝 Database Schema

The database schema is automatically initialized when the PostgreSQL container starts. The schema includes:

- UUID primary keys for all tables
- Automatic timestamp tracking (created_at, updated_at)
- Unique NFC tag identifiers for boxes
- Flexible box placement (can be in a room or on a rack)
- Item tracking with quantity, tags, and descriptions
- Item grouping system (items can belong to multiple groups)
- Item linking system (direct relationships between items)
- Views for easy location queries (`box_locations`, `item_locations`)
- Initial floor data (basement, ground, upstairs)

## 🐛 Troubleshooting

### Application won't start

1. Check if containers are running:
   ```bash
   docker-compose ps
   ```

2. Check logs:
   ```bash
   docker-compose logs app
   docker-compose logs postgres
   ```

3. Verify environment variables:
   ```bash
   docker-compose config
   ```

### Database connection errors

1. Ensure PostgreSQL container is healthy:
   ```bash
   docker-compose ps postgres
   ```

2. Check database logs:
   ```bash
   docker-compose logs postgres
   ```

3. Verify database credentials in `.env` match docker-compose configuration

### Port already in use

If port 3000 or 5432 is already in use:

1. Edit `.env` file
2. Change `APP_PORT` or `DB_PORT` to available ports
3. Restart containers: `docker-compose up -d`

## 📦 Backup & Restore

### Backup Database

```bash
docker exec home_storage_db pg_dump -U storage_user home_storage > backup.sql
```

### Restore Database

```bash
docker exec -i home_storage_db psql -U storage_user home_storage < backup.sql
```

## 🔄 Updates

To update the application:

1. **Pull latest changes:**
   ```bash
   git pull
   ```

2. **Rebuild and restart:**
   ```bash
   docker-compose up -d --build
   ```

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions, please open an issue on GitHub.
