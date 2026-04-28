#!/bin/bash

# Vercel does not have Flutter pre-installed.
# This script securely clones the stable Flutter SDK and builds the web app.

echo "Cloning Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running flutter pub get..."
flutter pub get

echo "Building Flutter Web App..."
# Note: $BACKEND_BASE_URL will be provided via Vercel Environment Variables
flutter build web --release --dart-define=BACKEND_BASE_URL=$BACKEND_BASE_URL
