#!/bin/bash
set -e

# Coffee Meter - Local PR Check Script
# Simulates GitHub Actions PR check workflow locally

SCHEME="coffee meter"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "🔍 Coffee Meter - Local PR Check"
echo "================================="
echo ""

# Show Xcode version
echo "📱 Xcode Version:"
xcodebuild -version
echo ""

# Show Swift version
echo "🔧 Swift Version:"
swift --version | head -1
echo ""

# Create dummy Firebase config
echo "ℹ️  Creating dummy Firebase config for testing..."
cat > "coffee meter/GoogleService-Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>API_KEY</key>
  <string>dummy-api-key</string>
  <key>GCM_SENDER_ID</key>
  <string>123456789</string>
  <key>PLIST_VERSION</key>
  <string>1</string>
  <key>BUNDLE_ID</key>
  <string>useless.com.coffee-meter</string>
  <key>PROJECT_ID</key>
  <string>dummy-project</string>
  <key>STORAGE_BUCKET</key>
  <string>dummy-bucket</string>
  <key>IS_ADS_ENABLED</key>
  <false/>
  <key>IS_ANALYTICS_ENABLED</key>
  <false/>
  <key>IS_APPINVITE_ENABLED</key>
  <false/>
  <key>IS_GCM_ENABLED</key>
  <false/>
  <key>IS_SIGNIN_ENABLED</key>
  <false/>
  <key>GOOGLE_APP_ID</key>
  <string>1:123456789:ios:dummy</string>
</dict>
</plist>
EOF
echo "✅ Dummy Firebase config created"
echo ""

# Resolve dependencies
echo "📦 Resolving Package Dependencies..."
xcodebuild -resolvePackageDependencies \
  -scheme "$SCHEME" \
  -configuration Debug
echo "✅ Dependencies resolved"
echo ""

# Run tests
echo "🧪 Running Unit Tests..."
set +e
xcodebuild test \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:coffee_meterTests \
  -enableCodeCoverage YES \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  | tee test-output.log \
  | xcpretty --simple --color 2>/dev/null || cat test-output.log

TEST_EXIT_CODE=$?
set -e
echo ""

# Parse test results
echo "📊 Test Results Summary"
echo "======================"

if grep -q "Test Suite.*passed" test-output.log; then
  PASSED=$(grep "Test Suite.*passed" test-output.log | tail -1 | sed 's/.*(\([0-9]*\) tests).*/\1/' || echo "0")
  echo "✅ Tests Passed: $PASSED"
fi

if grep -q "Test Suite.*failed" test-output.log; then
  FAILED=$(grep "Test Suite.*failed" test-output.log | tail -1 | sed 's/.*(\([0-9]*\) failures).*/\1/' || echo "0")
  echo "❌ Tests Failed: $FAILED"
fi

if grep -q "FAILED" test-output.log; then
  echo ""
  echo "Failed Tests:"
  grep "FAILED" test-output.log || true
fi

# Cleanup
echo ""
echo "🧹 Cleaning up..."
rm -f "coffee meter/GoogleService-Info.plist"
rm -f test-output.log
echo "✅ Cleanup complete"

if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo ""
  echo "🎉 All checks passed!"
  exit 0
else
  echo ""
  echo "❌ Checks failed"
  exit 1
fi
