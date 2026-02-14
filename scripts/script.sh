#!/bin/bash
# SportConnect - Production Build Setup Commands
# Use these commands to set up native splash screens, app icons, and prepare for release

echo "=== SportConnect Production Setup ==="

# Step 1: Get dependencies
echo "\n[1/5] Installing dependencies..."
flutter pub get

# Step 2: Generate native splash screens
echo "\n[2/5] Generating native splash screens..."
flutter pub run flutter_native_splash:create

# Step 3: Generate app icons for all platforms
echo "\n[3/5] Generating app icons for all platforms..."
flutter pub run flutter_launcher_icons

# Step 4: Get dependencies again (after code generation)
echo "\n[4/5] Refreshing dependencies after code generation..."
flutter pub get

# Step 5: Verify everything is good
echo "\n[5/5] Running diagnostics..."
flutter doctor -v

echo "\n=== Setup Complete! ==="
echo "\nNext steps:"
echo "1. Update lib/main.dart to use SplashScreenManager (see SPLASH_AND_ICONS_SETUP.md)"
echo "2. Test on iOS device: flutter run -d <device-id>"
echo "3. Test on Android device: flutter run -d <device-id>"
echo "4. Test on web: flutter run -d chrome"
echo "\nBuild for release:"
echo "• iOS: flutter build ios --release"
echo "• Android APK: flutter build apk --release"
echo "• Android Bundle: flutter build appbundle"
echo "• Web: flutter build web --release"
echo ""
