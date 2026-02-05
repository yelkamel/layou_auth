# Contributing to LayouAuth

First off, thank you for considering contributing to LayouAuth! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)

## 📜 Code of Conduct

This project adheres to a simple code of conduct:
- Be respectful and inclusive
- Focus on what is best for the community
- Show empathy towards others

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title** describing the issue
- **Detailed description** of the problem
- **Steps to reproduce** the behavior
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Environment details**:
  - Flutter version (`flutter --version`)
  - Device/OS
  - Package version

**Example:**
```markdown
## Bug: Google Sign-In fails on iOS

**Description:** When tapping "Continue with Google", nothing happens on iOS 15.

**Steps to reproduce:**
1. Open app on iPhone 12 (iOS 15.0)
2. Tap "Continue with Google"
3. No Google sign-in dialog appears

**Expected:** Google sign-in dialog should appear
**Actual:** Nothing happens, no error shown

**Environment:**
- Flutter: 3.24.0
- layou_auth: ^1.0.0
- Device: iPhone 12, iOS 15.0
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Include:

- **Clear title** with feature name
- **Use case** - why is this needed?
- **Proposed solution** - how should it work?
- **Alternatives considered**
- **Examples** or mockups if applicable

### Pull Requests

We love pull requests! Here's how:

1. **Fork** the repo
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Commit** with clear messages
6. **Push** to your fork
7. **Open a Pull Request**

## 🛠️ Development Setup

### Prerequisites

- Flutter SDK (stable channel)
- Git
- Your favorite IDE (VS Code, Android Studio, IntelliJ)

### Setup Steps

```bash
# 1. Fork and clone
git clone https://github.com/YOUR_USERNAME/layou_auth.git
cd layou_auth

# 2. Install dependencies
flutter pub get

# 3. Run tests
flutter test

# 4. Run example app
cd example
flutter pub get
flutter run
```

### Project Structure

```
layou_auth/
├── lib/
│   ├── src/
│   │   ├── config/          # Configuration classes
│   │   ├── core/            # Core auth service & models
│   │   ├── exceptions/      # Type-safe exceptions
│   │   ├── providers/       # Riverpod providers
│   │   └── widgets/         # UI components
│   └── layou_auth.dart      # Public API
├── test/                    # Unit tests
├── example/                 # Example app
└── screenshots/             # Screenshots for README
```

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/auth_service_test.dart

# With coverage
flutter test --coverage
```

### Testing Your Changes

Always test your changes:

1. **Unit tests** - Add tests for new code
2. **Widget tests** - Test UI components
3. **Manual testing** - Run the example app
4. **Platform testing** - Test on iOS and Android
5. **Edge cases** - Test error scenarios

## 🔀 Pull Request Process

1. **Update documentation** if you change the API
2. **Add/update tests** for your changes
3. **Run `flutter analyze`** - fix all warnings
4. **Run `flutter format .`** - format code
5. **Update CHANGELOG.md** with your changes
6. **Fill out the PR template**

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated (if needed)
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] No new warnings from analyzer
- [ ] CHANGELOG.md updated

### PR Title Format

Use conventional commits:

```
feat: add phone authentication support
fix: handle network errors in sign-in flow
docs: update README with new examples
refactor: simplify auth state management
test: add tests for delete account flow
chore: update dependencies
```

## 🎨 Style Guidelines

### Dart Code Style

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

```dart
// ✅ Good
class AuthService {
  final FirebaseAuth _firebaseAuth;

  Future<AuthResult<AuthUser>> signIn() async {
    try {
      // Implementation
    } catch (e) {
      return AuthResult.error(UnknownAuthException(e.toString()));
    }
  }
}

// ❌ Bad
class authService {
  var firebaseAuth;

  signIn() async {
    try {
      // Implementation
    } catch (e) {
      return null;
    }
  }
}
```

### Widget Guidelines

```dart
// ✅ Good: Composable, testable, well-documented
/// Button for Google sign-in with loading state support.
class LayouGoogleButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Called when button is pressed
  final VoidCallback? onPressed;

  const LayouGoogleButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
        ? const CircularProgressIndicator()
        : Text(label),
    );
  }
}
```

### Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add phone authentication support

- Add PhoneProviderConfig
- Implement phone sign-in flow
- Add phone verification UI

Closes #123

---

fix(widgets): handle email form validation errors

The email form was not showing validation errors properly.
Now displays errors inline below the field.

Fixes #456
```

## 🧪 Testing Guidelines

### Write Tests For

- New features
- Bug fixes
- Edge cases
- Error handling

### Test Structure

```dart
void main() {
  group('AuthService', () {
    late AuthService service;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      service = AuthService(firebaseAuth: mockAuth);
    });

    test('signInWithGoogle returns user on success', () async {
      // Arrange
      when(mockAuth.signInWithCredential(any))
        .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await service.signInWithGoogle();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.user?.email, equals('test@example.com'));
    });

    test('signInWithGoogle returns error on failure', () async {
      // Arrange
      when(mockAuth.signInWithCredential(any))
        .thenThrow(FirebaseAuthException(code: 'network-error'));

      // Act
      final result = await service.signInWithGoogle();

      // Assert
      expect(result.isError, isTrue);
      expect(result.error, isA<NetworkException>());
    });
  });
}
```

## 📝 Documentation Guidelines

### Code Documentation

```dart
/// Signs in the user with their Google account.
///
/// Returns [AuthResult] containing either:
/// - [AuthUser] on success
/// - [AuthException] on failure
///
/// Throws no exceptions - all errors are wrapped in [AuthResult].
///
/// Example:
/// ```dart
/// final result = await service.signInWithGoogle();
/// result.when(
///   success: (user) => print('Signed in: ${user.email}'),
///   error: (error) => print('Error: ${error.message}'),
/// );
/// ```
Future<AuthResult<AuthUser>> signInWithGoogle() async {
  // Implementation
}
```

### README Updates

When adding features:
- Add to [Features](#-features) section
- Add usage example
- Update [Advanced Usage](#-advanced-usage) if needed
- Add to [Roadmap](#-roadmap) when complete

## 🚀 Release Process

(For maintainers)

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Commit: `chore: bump version to X.Y.Z`
4. Tag: `git tag vX.Y.Z`
5. Push: `git push --tags`
6. Publish: `flutter pub publish`

## ❓ Questions?

- Open a [Discussion](https://github.com/yourusername/layou_auth/discussions)
- Join our [Discord](#) (if applicable)
- Email: support@layou.dev (if applicable)

## 🙏 Thank You!

Every contribution makes LayouAuth better for the Flutter community. Thank you for being part of it! 🎉
