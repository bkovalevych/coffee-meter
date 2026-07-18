# Swift 6.0 Compatibility Fix for Firebase Dependencies

## The Problem

GitHub Actions was failing with:
```
xcodebuild: error: Could not resolve package dependencies:
  package 'swift-protobuf' @ 1.38.1 is using Swift tools version 6.2.0
  but the installed version is 6.0.0
```

**Root Cause:**
- Firebase 11.7.0 depends on `swift-protobuf` with version range `1.19.0 ..< 2.0.0`
- SPM picks the latest compatible version: `1.38.1` (released Dec 20, 2024)
- `swift-protobuf 1.38.1` requires **Swift Tools 6.2.0**
- `macos-14` GitHub runners only have **Xcode 16.1** (Swift 6.0.0) ❌

## The Solution

### ✅ Updated to macos-15 Runners (Xcode 16.2/Swift 6.2.0)

**Changes Made:**

1. **`.github/workflows/ios-pr-check.yml`** (line 9, 15)
   ```yaml
   env:
     XCODE_VERSION: '16.2'  # Was: 16.1

   jobs:
     test:
       runs-on: macos-15    # Was: macos-14
   ```

2. **`.github/workflows/ios-build.yml`** (line 18, 25, 115)
   ```yaml
   env:
     XCODE_VERSION: '16.2'  # Was: 16.1

   jobs:
     build-development:
       runs-on: macos-15    # Was: macos-14

     build-production:
       runs-on: macos-15    # Was: macos-14
   ```

3. **Added swift-protobuf 1.28.2 as fallback** (project.pbxproj)
   - Added as direct dependency (though SPM still picks 1.38.1)
   - Available if we need to downgrade Firebase in the future

## Fallback Plan

If `macos-15` runners are not available or unstable:

### Option A: Downgrade Firebase to 10.18.0
```bash
# In coffee meter.xcodeproj/project.pbxproj, change:
version = 10.18.0;  # Uses swift-protobuf 1.26.x (Swift 6.0 compatible)
```

### Option B: Wait for Xcode 16.2 on macos-14
GitHub typically updates runner images 2-4 weeks after Xcode releases.
Monitor: https://github.com/actions/runner-images/issues

## Testing Locally

Run the PR check script to test locally:
```bash
./scripts/test-pr-check.sh
```

This simulates the exact GitHub Actions workflow on your local machine.

## Current Dependencies

- **Firebase iOS SDK:** 11.7.0
- **swift-protobuf:** 1.38.1 (requires Swift 6.2.0)
- **Xcode (CI):** 16.2 on macos-15
- **Swift (CI):** 6.2.0

## References

- [GitHub macos-15 Runner](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)
- [swift-protobuf 1.38.1 Release](https://github.com/apple/swift-protobuf/releases/tag/1.38.1)
- [Firebase iOS SDK Releases](https://github.com/firebase/firebase-ios-sdk/releases)

---

**Date:** 2026-07-18
**Issue:** Swift 6.0 vs Swift 6.2 tools version mismatch
**Status:** ✅ Fixed - Using macos-15 with Xcode 16.2
