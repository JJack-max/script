#!/bin/bash

# Clean script for Flutter KeePass project
# Removes all build artifacts and temporary files

echo "Cleaning Flutter KeePass project..."

# Remove Flutter build directories
echo "Removing build directories..."
rm -rf build/
rm -rf .dart_tool/
rm -rf .packages
rm -rf pubspec.lock

# Remove platform-specific build files
echo "Removing platform-specific build files..."
rm -rf android/.gradle/
rm -rf android/build/
rm -rf android/app/build/
rm -rf ios/build/
rm -rf ios/Pods/
rm -rf ios/.symlinks/
rm -rf ios/Flutter/App.framework/
rm -rf ios/Flutter/Flutter.framework/
rm -rf macos/build/
rm -rf macos/Pods/
rm -rf macos/.symlinks/
rm -rf macos/Flutter/ephemeral/

# Remove web build files
echo "Removing web build files..."
rm -rf web/build/

# Remove temporary files
echo "Removing temporary files..."
find . -name "*.log" -delete
find . -name "*.tmp" -delete
find . -name "*~" -delete
find . -name ".DS_Store" -delete

# Remove coverage files if they exist
echo "Removing coverage files..."
rm -rf coverage/
rm -f *.lcov
rm -f *.info

# Remove IDE specific files
echo "Removing IDE specific files..."
rm -rf .idea/
rm -rf .vscode/
rm -f *.iml

# Clean Flutter cache
echo "Cleaning Flutter cache..."
flutter clean
flutter pub cache repair

echo "Clean completed successfully!"
echo "To rebuild the project, run 'flutter pub get' followed by 'flutter run'"