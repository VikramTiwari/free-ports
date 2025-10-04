# Contributing to Port Manager

Thank you for your interest in contributing to Port Manager! This document provides guidelines for contributing to this project.

## Getting Started

### Prerequisites
- macOS 14.0 or later
- Swift 5.0 or later
- Git

### Setting Up the Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/free-ports.git
   cd free-ports
   ```

3. **Run the app** to make sure everything works:
   ```bash
   swift run PortManager
   ```

## Development Workflow

### Making Changes

1. **Create a new branch** for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-description
   ```

2. **Make your changes** to the code
3. **Test your changes** thoroughly:
   ```bash
   swift run PortManager
   ```

4. **Build the app bundle** to test distribution:
   ```bash
   ./build_app.sh
   open PortManager.app
   ```

### Code Style

- Follow Swift naming conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small
- Use `guard` statements for early returns

### Testing

Before submitting a pull request, please:

1. **Test the app** runs without crashes
2. **Test port scanning** works correctly
3. **Test process killing** works as expected
4. **Test menu bar** functionality
5. **Test memory usage** stays reasonable
6. **Test on different macOS versions** if possible

## Submitting Changes

### Commit Messages

Use clear, descriptive commit messages:

```bash
# Good
git commit -m "Add refresh button to menu bar"
git commit -m "Fix memory leak in port scanning"
git commit -m "Update README with installation instructions"

# Avoid
git commit -m "fix"
git commit -m "update"
git commit -m "changes"
```

### Pull Request Process

1. **Push your branch** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** on GitHub with:
   - Clear title describing the change
   - Detailed description of what was changed and why
   - Screenshots if UI changes were made
   - Testing instructions

3. **Wait for review** and address any feedback

## Areas for Contribution

### Features
- Additional port filtering options
- Process information display
- Customizable refresh intervals
- Dark mode support
- Keyboard shortcuts

### Bug Fixes
- Memory optimization
- Performance improvements
- UI/UX enhancements
- Error handling improvements

### Documentation
- Code comments
- README improvements
- Installation guides
- Troubleshooting guides

## Code Structure

The project is organized as follows:

```
free-ports/
├── Package.swift              # Swift Package Manager configuration
├── README.md                  # Main documentation
├── LICENSE                    # MIT License
├── CONTRIBUTING.md           # This file
├── build_app.sh              # Build script for distribution
└── Sources/
    └── PortManager/
        └── main.swift        # Main application code
```

### Key Components

- **`PortInfoMenuBar`**: Data structure for port information
- **`PortManagerMenuBar`**: Core port scanning and process management
- **`AppDelegateMenuBar`**: Menu bar UI and user interactions

## Questions?

If you have questions about contributing, please:

1. Check existing issues and discussions
2. Create a new issue with the "question" label
3. Reach out to maintainers

## Thank You!

Your contributions help make Port Manager better for everyone. We appreciate your time and effort!

---

**Happy coding!** 🚀
