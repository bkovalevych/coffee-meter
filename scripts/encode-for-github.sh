#!/bin/bash

# Coffee Meter - GitHub Secret Encoder
# This script encodes GoogleService-Info.plist for GitHub Actions secrets

set -e  # Exit on error

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIREBASE_CONFIG="$PROJECT_DIR/coffee meter/GoogleService-Info.plist"

echo "🔐 Coffee Meter - GitHub Secret Encoder"
echo "======================================="
echo ""

# Check if config exists
if [ ! -f "$FIREBASE_CONFIG" ]; then
    echo "❌ GoogleService-Info.plist not found!"
    echo ""
    echo "Please run setup-firebase.sh first:"
    echo "   ./scripts/setup-firebase.sh"
    echo ""
    exit 1
fi

# Validate it's a proper plist file
if ! plutil -lint "$FIREBASE_CONFIG" > /dev/null 2>&1; then
    echo "❌ The file is not a valid plist file!"
    exit 1
fi

echo "📋 Encoding GoogleService-Info.plist to base64..."
echo ""

# Encode and copy to clipboard
base64 -i "$FIREBASE_CONFIG" | pbcopy

echo "✅ Base64 encoded string copied to clipboard!"
echo ""
echo "Next steps:"
echo "1. Go to your GitHub repository"
echo "2. Click Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Name: FIREBASE_CONFIG_PLIST"
echo "5. Value: Press ⌘V to paste from clipboard"
echo "6. Click 'Add secret'"
echo ""
echo "The secret is now ready for GitHub Actions! 🚀"
echo ""
