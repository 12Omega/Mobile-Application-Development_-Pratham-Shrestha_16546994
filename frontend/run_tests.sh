#!/bin/bash

echo "🚀 Starting ParkEase Test Suite..."

# Navigate to frontend directory
cd frontend

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate mock files
echo "🔧 Generating mock files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run unit and widget tests
echo "🧪 Running unit and widget tests..."
flutter test --coverage

# Run integration tests (if available)
echo "🔗 Running integration tests..."
flutter test integration_test/

# Generate coverage report
echo "📊 Generating coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "✅ All tests completed!"
echo "📊 Coverage report available at: coverage/html/index.html"