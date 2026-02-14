# SportConnect - Production Build Setup (Windows PowerShell)
# Use these commands to set up native splash screens, app icons, and prepare for release

Write-Host "=== SportConnect Production Setup ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get dependencies
Write-Host "[1/5] Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# Step 2: Generate native splash screens
Write-Host "`n[2/5] Generating native splash screens..." -ForegroundColor Yellow
flutter pub run flutter_native_splash:create

# Step 3: Generate app icons for all platforms
Write-Host "`n[3/5] Generating app icons for all platforms..." -ForegroundColor Yellow
flutter pub run flutter_launcher_icons

# Step 4: Get dependencies again (after code generation)
Write-Host "`n[4/5] Refreshing dependencies after code generation..." -ForegroundColor Yellow
flutter pub get

# Step 5: Verify everything is good
Write-Host "`n[5/5] Running diagnostics..." -ForegroundColor Yellow
flutter doctor -v

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Update lib/main.dart to use SplashScreenManager (see SPLASH_AND_ICONS_SETUP.md)"
Write-Host "2. Test on Android device: flutter run -d <device-id>"
Write-Host "3. Test on web: flutter run -d chrome"
Write-Host "`nBuild for release:" -ForegroundColor Cyan
Write-Host "  • Android APK: flutter build apk --release"
Write-Host "  • Android Bundle: flutter build appbundle"
Write-Host "  • Web: flutter build web --release"
Write-Host ""
