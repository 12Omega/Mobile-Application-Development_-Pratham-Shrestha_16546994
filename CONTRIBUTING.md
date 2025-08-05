# 🤝 Contributing to ParkEase

Thank you for your interest in contributing to ParkEase! This document provides guidelines and instructions for contributing to this project.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing Requirements](#testing-requirements)
- [Commit Message Format](#commit-message-format)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:
- Node.js (v16+)
- Flutter SDK (v3.0+)
- Git
- MongoDB (local or cloud)
- Android Studio or VS Code

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/parkease.git
   cd parkease
   ```

2. **Install Dependencies**
   ```bash
   npm run install:all
   ```

3. **Setup Environment**
   ```bash
   cp backend/.env.example backend/.env
   # Edit backend/.env with your configurations
   ```

4. **Seed Database**
   ```bash
   npm run seed
   ```

5. **Run Tests**
   ```bash
   npm run test:quick
   ```

## 🎨 Code Style Guidelines

### Flutter/Dart

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Maximum line length: 80 characters
- Use meaningful variable and function names
- Add documentation comments for public APIs

**Example:**
```dart
/// Calculates the total parking fee including taxes and service charges.
/// 
/// [baseAmount] The base parking fee
/// [duration] Parking duration in minutes
/// Returns the total amount to be charged
double calculateTotalFee(double baseAmount, int duration) {
  final taxes = baseAmount * 0.08; // 8% tax
  final serviceFee = 2.50;
  return baseAmount + taxes + serviceFee;
}
```

### Node.js/JavaScript

- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use ES6+ features
- Use meaningful variable names
- Add JSDoc comments for functions
- Use async/await over promises

**Example:**
```javascript
/**
 * Creates a new parking booking
 * @param {Object} bookingData - The booking information
 * @param {string} userId - The user ID making the booking
 * @returns {Promise<Object>} The created booking object
 */
async function createBooking(bookingData, userId) {
  try {
    const booking = new Booking({
      ...bookingData,
      user: userId,
      status: 'reserved'
    });
    
    return await booking.save();
  } catch (error) {
    throw new Error(`Failed to create booking: ${error.message}`);
  }
}
```

## 🧪 Testing Requirements

### Test Coverage
- Maintain minimum 80% test coverage
- Write unit tests for all business logic
- Include integration tests for API endpoints
- Add widget tests for Flutter components

### Running Tests
```bash
# Run all tests
npm run test

# Run quick tests
npm run test:quick

# Run backend tests only
npm run test:backend

# Run frontend tests only
npm run test:frontend
```

### Test Structure

**Flutter Tests:**
```dart
group('BookingService', () {
  late BookingService bookingService;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    bookingService = BookingService(mockApiService);
  });

  test('should create booking successfully', () async {
    // Arrange
    final bookingData = BookingModel(/* test data */);
    when(mockApiService.createBooking(any))
        .thenAnswer((_) async => bookingData);

    // Act
    final result = await bookingService.createBooking(bookingData);

    // Assert
    expect(result, equals(bookingData));
    verify(mockApiService.createBooking(bookingData)).called(1);
  });
});
```

**Node.js Tests:**
```javascript
describe('Booking Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = { body: {}, params: {}, user: { id: 'user123' } };
    res = { status: jest.fn().mockReturnThis(), json: jest.fn() };
    next = jest.fn();
  });

  test('should create booking successfully', async () => {
    // Arrange
    const bookingData = { /* test data */ };
    req.body = bookingData;

    // Act
    await createBooking(req, res, next);

    // Assert
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: true })
    );
  });
});
```

## 📝 Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```bash
feat(auth): add JWT token refresh functionality

fix(maps): resolve marker clustering performance issue

docs(setup): update installation instructions for Windows

test(booking): add unit tests for booking validation

refactor(api): extract common middleware functions

chore(deps): update Flutter dependencies to latest versions
```

## 🔄 Pull Request Process

### Before Submitting

1. **Update your fork**
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes and test**
   ```bash
   # Make your changes
   npm run test:quick
   npm run test
   ```

4. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

### Pull Request Template

When creating a PR, include:

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Test coverage maintained/improved

## Screenshots (if applicable)
Add screenshots for UI changes.

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Code is commented where necessary
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### Review Process

1. **Automated Checks**: All CI/CD checks must pass
2. **Code Review**: At least one maintainer review required
3. **Testing**: All tests must pass
4. **Documentation**: Update docs if needed
5. **Merge**: Squash and merge after approval

## 🐛 Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
**Bug Description**
Clear description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**
What you expected to happen.

**Screenshots**
Add screenshots if applicable.

**Environment**
- OS: [e.g. iOS, Android, Windows]
- Flutter Version: [e.g. 3.0.0]
- Device: [e.g. iPhone 12, Samsung Galaxy S21]

**Additional Context**
Any other context about the problem.
```

### Feature Requests

Use the feature request template:

```markdown
**Feature Description**
Clear description of the feature.

**Problem Statement**
What problem does this solve?

**Proposed Solution**
How should this feature work?

**Alternatives Considered**
Other solutions you've considered.

**Additional Context**
Any other context or screenshots.
```

## 🏷️ Labels

We use these labels for issues and PRs:

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `priority:high`: High priority
- `priority:medium`: Medium priority
- `priority:low`: Low priority

## 🎯 Development Guidelines

### Architecture Principles

1. **Clean Architecture**: Maintain separation of concerns
2. **SOLID Principles**: Follow SOLID design principles
3. **DRY**: Don't Repeat Yourself
4. **KISS**: Keep It Simple, Stupid
5. **YAGNI**: You Aren't Gonna Need It

### Performance Guidelines

1. **Optimize for mobile**: Consider battery and data usage
2. **Lazy loading**: Load data when needed
3. **Caching**: Implement appropriate caching strategies
4. **Memory management**: Dispose resources properly
5. **Network efficiency**: Minimize API calls

### Security Guidelines

1. **Input validation**: Validate all user inputs
2. **Authentication**: Secure all protected endpoints
3. **Data encryption**: Encrypt sensitive data
4. **API security**: Use HTTPS and proper headers
5. **Error handling**: Don't expose sensitive information

## 📞 Getting Help

- **Documentation**: Check existing documentation first
- **Issues**: Search existing issues before creating new ones
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact maintainers for sensitive issues

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to ParkEase! 🚀