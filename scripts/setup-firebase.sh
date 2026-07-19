#!/bin/bash

# Coffee Meter - Firebase Setup Script
# This script helps set up the Firebase configuration file for local development

set -e  # Exit on error

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIREBASE_CONFIG="$PROJECT_DIR/coffee meter/GoogleService-Info.plist"
FIREBASE_TEMPLATE="$PROJECT_DIR/coffee meter/GoogleService-Info.plist.template"
DOWNLOADS_DIR="$HOME/Downloads"

echo "🔥 Coffee Meter - Firebase Setup"
echo "================================"
echo ""

# Check if config already exists
if [ -f "$FIREBASE_CONFIG" ]; then
    echo "✅ Firebase configuration already exists at:"
    echo "   $FIREBASE_CONFIG"
    echo ""
    read -p "Do you want to replace it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "ℹ️  Keeping existing configuration. Setup cancelled."
        exit 0
    fi
fi

echo "Looking for GoogleService-Info.plist..."
echo ""

# Check common locations
FOUND_FILE=""

# Check Downloads folder
if [ -f "$DOWNLOADS_DIR/GoogleService-Info.plist" ]; then
    echo "✅ Found in Downloads folder"
    FOUND_FILE="$DOWNLOADS_DIR/GoogleService-Info.plist"
fi

if [ -z "$FOUND_FILE" ]; then
    echo "❌ GoogleService-Info.plist not found in Downloads folder"
    echo ""
    echo "Please download it from Firebase Console:"
    echo "1. Go to https://console.firebase.google.com"
    echo "2. Select project: peaky-flow-solution"
    echo "3. Go to Project Settings (⚙️ icon)"
    echo "4. Scroll to 'Your apps' section"
    echo "5. Find iOS app: useless.com.coffee-meter"
    echo "6. Click 'Download GoogleService-Info.plist'"
    echo "7. Save to Downloads folder"
    echo ""
    read -p "Press Enter after downloading the file..."

    # Check again
    if [ -f "$DOWNLOADS_DIR/GoogleService-Info.plist" ]; then
        FOUND_FILE="$DOWNLOADS_DIR/GoogleService-Info.plist"
    else
        echo "❌ File still not found. Exiting."
        exit 1
    fi
fi

# Validate it's a proper plist file
if ! plutil -lint "$FOUND_FILE" > /dev/null 2>&1; then
    echo "❌ The file is not a valid plist file!"
    exit 1
fi

# Check for required keys
if ! grep -q "GOOGLE_APP_ID" "$FOUND_FILE"; then
    echo "❌ The file doesn't contain GOOGLE_APP_ID. Wrong file?"
    exit 1
fi

# Copy to project
echo ""
echo "📋 Copying to project..."
cp "$FOUND_FILE" "$FIREBASE_CONFIG"

echo "✅ Firebase configuration installed successfully!"
echo ""
echo "Next steps:"
echo "1. Open coffee meter.xcodeproj in Xcode"
echo "2. Build the project (⌘B)"
echo "3. Run on simulator or device"
echo ""
echo "Note: This file is in .gitignore and will NOT be committed to git."
echo ""
