#!/bin/bash

echo "========================================"
echo "🚀 ParkEase Installation Script"
echo "========================================"
echo ""

echo "📋 This script will set up ParkEase on your system"
echo ""

echo "🔍 Checking prerequisites..."
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js from https://nodejs.org/"
    exit 1
else
    echo "✅ Node.js found"
    node --version
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter from https://flutter.dev/"
    exit 1
else
    echo "✅ Flutter found"
    flutter --version | head -1
fi

echo ""
echo "📦 Installing dependencies..."
echo ""

# Install root dependencies
echo "🔧 Installing root dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install root dependencies"
    exit 1
fi

# Install backend dependencies
echo "🔧 Installing backend dependencies..."
cd backend
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install backend dependencies"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env with your configurations"
fi

cd ..

# Install frontend dependencies
echo "🔧 Installing frontend dependencies..."
cd frontend
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to install frontend dependencies"
    exit 1
fi

cd ..

echo ""
echo "🗄️ Setting up database..."
cd backend
node src/data/seedDatabase.js
if [ $? -ne 0 ]; then
    echo "⚠️  Database seeding failed. Make sure MongoDB is running."
    echo "💡 You can run 'npm run seed' later to populate the database."
fi

cd ..

echo ""
echo "🧪 Running quick test..."
node quick_test.js

echo ""
echo "========================================"
echo "🎉 Installation Complete!"
echo "========================================"
echo ""
echo "📋 Next Steps:"
echo "1. Edit backend/.env with your configurations"
echo "2. Set up Google Maps API key (see frontend/GOOGLE_MAPS_SETUP.md)"
echo "3. Start the backend: npm run start:backend"
echo "4. Start the frontend: npm run start:frontend"
echo ""
echo "📚 Documentation:"
echo "- Setup Guide: SETUP.md"
echo "- Google Maps: frontend/GOOGLE_MAPS_SETUP.md"
echo "- Contributing: CONTRIBUTING.md"
echo ""
echo "🚀 Happy coding!"
echo ""