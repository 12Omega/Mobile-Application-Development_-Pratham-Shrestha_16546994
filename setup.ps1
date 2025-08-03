# ParkEase Setup Script
Write-Host "Setting up ParkEase application..." -ForegroundColor Green

# Check if MongoDB is running
Write-Host "Checking MongoDB connection..." -ForegroundColor Yellow
try {
    $mongoTest = & "C:\Program Files\MongoDB\Server\8.0\bin\mongo.exe" --eval "db.runCommand('ping')" --quiet 2>$null
    Write-Host "MongoDB is running!" -ForegroundColor Green
} catch {
    Write-Host "Starting MongoDB..." -ForegroundColor Yellow
    Start-Process -FilePath "C:\Program Files\MongoDB\Server\8.0\bin\mongod.exe" -ArgumentList "--dbpath", "C:\data\db" -WindowStyle Minimized
    Start-Sleep 3
}

# Install backend dependencies
Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
Set-Location backend
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "Backend dependencies installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to install backend dependencies. Please restart PowerShell and try again." -ForegroundColor Red
    exit 1
}

# Start backend server
Write-Host "Starting backend server..." -ForegroundColor Yellow
Start-Process -FilePath "npm" -ArgumentList "run", "dev" -WindowStyle Normal

# Install frontend dependencies
Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location ../frontend
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "Frontend dependencies installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to install frontend dependencies." -ForegroundColor Red
}

Write-Host "Setup complete! You can now:" -ForegroundColor Green
Write-Host "1. Open MongoDB Compass and connect to mongodb://localhost:27017" -ForegroundColor Cyan
Write-Host "2. Register a new user in the app or use the test credentials:" -ForegroundColor Cyan
Write-Host "   Email: testuser@example.com" -ForegroundColor White
Write-Host "   Password: password123" -ForegroundColor White
Write-Host "3. Run 'flutter run' in the frontend directory to start the app" -ForegroundColor Cyan