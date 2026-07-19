# GitHub Actions Runner Information

## Current Issue
The project uses Firebase 11.7.0, which depends on `swift-protobuf @ 1.38.1`.
`swift-protobuf 1.38.1` requires **Swift Tools 6.2.0**, but:
- `macos-14` runners only have up to **Xcode 16.1** (Swift 6.0.0)
- `macos-15` runners have **Xcode 16.2+** (Swift 6.2.0) ✅

## Solution
Updated workflows to use `runs-on: macos-15` to get Xcode 16.2/Swift 6.2.0.

## Fallback Options (if macos-15 fails)

### Option 1: Downgrade Firebase to 10.18.0 (uses swift-protobuf 1.26.x)
```yaml
# In project.pbxproj
version = 10.18.0;
```

### Option 2: Use macos-14 with Xcode 16.1 and older Firebase
```yaml
runs-on: macos-14
env:
  XCODE_VERSION: '16.1'
# Requires Firebase 10.18.0 or earlier
```

### Option 3: Wait for Xcode 16.2 on macos-14
GitHub typically updates runner images 2-4 weeks after Xcode releases.

## References
- [GitHub Actions Runner Images](https://github.com/actions/runner-images)
- [macos-15 image](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)
- [swift-protobuf releases](https://github.com/apple/swift-protobuf/releases)
