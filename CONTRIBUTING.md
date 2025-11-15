# Contributing

Thank you for your interest in contributing to Home Storage Manager!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/home-storage-manager.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes
6. Commit: `git commit -m "Add your feature"`
7. Push: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

See the main README.md for setup instructions. Use the development mode for local testing:

```bash
# Start only the database
docker-compose up -d postgres

# Run the app locally
npm install
npm run dev
```

## Code Style

- Follow TypeScript best practices
- Use meaningful variable and function names
- Add comments for complex logic
- Keep components small and focused
- Use Tailwind CSS for styling (mobile-first approach)

## Testing

Before submitting a PR, please:
- Test on mobile devices (especially iPhone Safari)
- Ensure all API routes work correctly
- Check that database queries are efficient
- Verify responsive design

## Pull Request Process

1. Update README.md if needed
2. Update documentation for new features
3. Ensure your code follows the existing style
4. Test thoroughly before submitting

Thank you for contributing! 🎉

