# Contributing to Katya AI REChain Mesh

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

## Pull Request Process

1. Update the README.md with details of changes to the interface, if applicable
2. Update the version numbers in any examples files and the README.md to the new version that this Pull Request would represent
3. Follow the PR template when creating your pull request
4. The PR will be merged once you have the sign-off of at least one maintainer

## Commit Message Format

We follow the [Conventional Commits](https://conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to auxiliary tools and libraries

Examples:
- `feat: add blockchain wallet support`
- `fix: resolve IoT device connection issue`
- `docs: update README with deployment instructions`

## Development Setup

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Android Studio or VS Code
- Git

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/katya-ai-rechain-mesh.git
   cd katya-ai-rechain-mesh
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up development environment:
   ```bash
   make setup  # or bash setup.sh
   ```

4. Run tests:
   ```bash
   make test  # or flutter test
   ```

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` before committing
- Write comprehensive tests for new features
- Update documentation for API changes

## Project Structure

```
lib/
├── src/
│   ├── models/           # Data models and entities
│   ├── services/         # Business logic and API services
│   ├── state/           # State management (Provider/Bloc)
│   ├── ui/              # UI components and screens
│   ├── theme/           # Theme and styling
│   └── utils/           # Utilities and helpers
├── main.dart            # Application entry point
└── ...

test/                    # Unit and widget tests
integration_test/        # Integration tests
docs/                   # Documentation
.github/                # GitHub workflows
```

## Testing

- Write tests for all new features
- Maintain minimum 80% code coverage
- Use descriptive test names
- Test both success and failure scenarios

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/blockchain_service_test.dart

# Run integration tests
flutter test integration_test/
```

## Documentation

- Update README.md for user-facing changes
- Add inline documentation for public APIs
- Update API documentation for breaking changes
- Keep examples current and working

## Security

- Never commit secrets or API keys
- Use environment variables for sensitive data
- Follow security best practices
- Report security vulnerabilities privately

## Performance

- Profile and optimize slow operations
- Use appropriate data structures
- Minimize memory usage
- Test on real devices, not just emulators

## Internationalization

- Use Flutter's internationalization features
- Provide translations for all user-facing strings
- Test with different locales and text directions

## Platform Support

When adding new features:

- Test on all supported platforms (Android, iOS, Web, Desktop)
- Consider platform-specific limitations
- Use platform channels when necessary
- Document platform-specific behavior

## Community Guidelines

- Be respectful and inclusive
- Use welcoming and inclusive language
- Be collaborative
- Focus on what is best for the community

## Recognition

Contributors will be recognized in the README.md and release notes. We appreciate all contributions, no matter how small!

## License

By contributing, you agree that your contributions will be licensed under the same license as the original project (MIT License).

## Questions?

Feel free to open an issue or join our Discord community for questions and discussions.
