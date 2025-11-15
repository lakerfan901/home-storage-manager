# GitHub Repository Setup Guide

Follow these steps to create your GitHub repository and push your code.

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the "+" icon in the top right
3. Select "New repository"
4. Repository name: `home-storage-manager`
5. Description: "Home storage management system with PostgreSQL and mobile-friendly web interface"
6. Choose **Public** or **Private**
7. **DO NOT** initialize with README, .gitignore, or license (we already have these)
8. Click "Create repository"

## Step 2: Initialize Git and Push

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Home Storage Manager with Docker support"

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/home-storage-manager.git

# Push to GitHub
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 3: Update Repository URLs

After pushing, update these files with your actual GitHub URL:

1. **package.json**: Update the `repository.url` field
2. **README.md**: Update any GitHub URLs in the documentation

## Step 4: Add Repository Topics (Optional)

On your GitHub repository page:
1. Click the gear icon next to "About"
2. Add topics: `storage`, `inventory`, `postgresql`, `nextjs`, `docker`, `home-management`

## Step 5: Verify Everything

- ✅ All files are pushed
- ✅ README displays correctly
- ✅ LICENSE file is present
- ✅ .gitignore is working (no node_modules, .env files pushed)
- ✅ Docker files are included

## Next: Deploy to Your Server

Once your code is on GitHub, follow the deployment instructions in [DEPLOYMENT.md](DEPLOYMENT.md) to set it up on your Linux server.

## Cloning on Your Server

On your Linux server, you can now clone and deploy:

```bash
git clone https://github.com/YOUR_USERNAME/home-storage-manager.git
cd home-storage-manager
cp .env.docker .env
# Edit .env with your settings
docker-compose up -d
```

That's it! Your repository is ready for GitHub! 🚀

