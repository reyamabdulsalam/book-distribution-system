# تشغيل تطبيق Flutter
# Run from Windows PowerShell

Write-Host "🚀 تشغيل تطبيق Flutter..." -ForegroundColor Green

# Change to the Flutter project directory
Set-Location "\\wsl$\Ubuntu\home\reyam\ketabi\mobile\book_distribution_system"

# Check for devices
Write-Host "`n📱 الأجهزة المتاحة:" -ForegroundColor Yellow
flutter devices

# Get dependencies
Write-Host "`n📦 تحميل المكتبات..." -ForegroundColor Yellow
flutter pub get

# Run the app
Write-Host "`n▶️  تشغيل التطبيق..." -ForegroundColor Green
flutter run
