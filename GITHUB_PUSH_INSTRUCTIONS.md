# GitHub Push Instructions

Your git repository has been initialized and your first commit is ready! Follow these steps to push to GitHub:

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Repository name: `home-storage-manager`
5. Description: "Home storage management system with PostgreSQL and mobile-friendly web interface"
6. Choose **Public** or **Private**
7. **DO NOT** initialize with README, .gitignore, or license (we already have these)
8. Click "Create repository"

## Step 2: Connect and Push

After creating the repository, GitHub will show you commands. Use these:

```bash
# Navigate to your project directory
cd "C:\Users\kutis\Downloads\Development\House storage"

# Add your GitHub repository as remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/home-storage-manager.git

# Push to GitHub
git push -u origin main
```

## Alternative: Using SSH

If you prefer SSH:

```bash
git remote add origin git@github.com:YOUR_USERNAME/home-storage-manager.git
git push -u origin main
```

## Verify

After pushing, refresh your GitHub repository page. You should see all your files!

## Next Steps

Once pushed to GitHub, you can:
1. Clone it on your Linux server
2. Deploy using Docker (see DEPLOYMENT.md)
3. Set up CI/CD (GitHub Actions workflow is already included)

## Troubleshooting

**If you get authentication errors:**
- Use a Personal Access Token instead of password
- Or set up SSH keys

**If remote already exists:**
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/home-storage-manager.git
```

**To check your remote:**
```bash
git remote -v
```

