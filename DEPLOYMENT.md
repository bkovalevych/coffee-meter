# iOS Deployment & CI/CD Strategy

## Development Stages (Web vs iOS Comparison)

### Web Development (Your Experience)
```
Local Dev → Dev Server → Staging → Production
           (devs only)  (QA/testing) (public)
```

### iOS Development (Equivalent)
```
Local Dev → Internal Testing → TestFlight (Beta) → App Store (Production)
(Xcode)     (Ad-hoc/Dev)        (limited users)      (public)
```

## iOS Distribution Channels

### 1. **Local Development** (Xcode Simulator/Physical Device)
- **Web equivalent**: localhost
- Run directly from Xcode
- Instant testing during development
- Free, no Apple Developer account needed for simulator
- Physical device testing requires Apple Developer account ($99/year)

### 2. **Internal Testing (Ad-hoc Distribution)**
- **Web equivalent**: Dev environment (password-protected)
- Max 100 devices per year
- Direct installation via:
  - Ad-hoc provisioning profiles
  - Enterprise distribution (requires Enterprise account $299/year)
  - Firebase App Distribution (free)
- Good for: Internal team testing before TestFlight

### 3. **TestFlight (Beta Testing)**
- **Web equivalent**: Staging environment
- **Official Apple beta testing platform** (FREE)
- Two groups:
  - **Internal Testing**: Up to 100 Apple Developer team members
  - **External Testing**: Up to 10,000 external testers
- Features:
  - Testers install via TestFlight app
  - Invite testers by email or public link
  - Builds expire after 90 days
  - Submit for "External Testing" (Apple review ~24 hours, lighter than App Store)
  - No review needed for Internal Testing
- **This is what you want for "dev" testing!**

### 4. **App Store (Production)**
- **Web equivalent**: Production hosting
- Public release
- Full App Review (~1-3 days)
- Anyone can download

## Versioning Strategy

### Version Numbers
```swift
Version: 1.2.3
         ^ ^ ^
         | | +-- Patch (bug fixes)
         | +---- Minor (new features, backwards compatible)
         +------ Major (breaking changes)

Build Number: 42 (auto-incremented on each build)
```

### Recommended Scheme
- **Main branch** → App Store (1.0.0, 1.1.0, 2.0.0)
- **Develop branch** → TestFlight Internal (1.0.0-beta.1, 1.0.0-beta.2)
- **Feature branches** → Local testing only

### Xcode Build Configurations
Create separate configurations for different stages:
- **Debug** (default) - Local development
- **Beta** - TestFlight builds with beta endpoints
- **Release** (default) - Production App Store

## CI/CD Options for iOS

### Option 1: **GitHub Actions** (Recommended for you)
**Pros**:
- Free for public repos, 2000 min/month for private
- Full control over pipeline
- Integrate with your existing GitHub workflow
- Popular in community

**Cons**:
- Requires macOS runner (self-hosted or GitHub's)
- Need to manage certificates/provisioning profiles
- More manual setup

**Cost**: Free (for your use case)

**Example Workflow**:
```yaml
on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  build:
    runs-on: macos-latest
    steps:
      - Checkout code
      - Build & test
      - Upload to TestFlight (develop) or App Store (main)
```

### Option 2: **Xcode Cloud** (Apple's official CI/CD)
**Pros**:
- Native Apple solution
- Automatic setup with Xcode
- Handles certificates automatically
- Integrated with App Store Connect
- 25 compute hours/month FREE

**Cons**:
- Locked to Apple ecosystem
- Less flexible than GitHub Actions
- Limited free tier

**Cost**: Free tier: 25 hours/month (plenty for small project)

### Option 3: **Fastlane** (Tool, not service)
**What**: Automation tool for iOS deployment (used WITH CI/CD)
**Use with**: GitHub Actions, GitLab CI, Bitrise, etc.
**Pros**:
- Industry standard
- Automates screenshots, metadata, signing, upload
- Works with any CI/CD

**Recommended**: Use Fastlane + GitHub Actions together

### Option 4: **Bitrise, CircleCI, Travis CI**
- Paid services with iOS support
- Not needed for your project size

## Recommended Setup for Coffee Meter

### Branch Strategy
```
main (production)
  └── develop (TestFlight beta)
       ├── feature/add-watch-support
       ├── feature/monthly-chart
       └── bugfix/calculation-error
```

### CI/CD Pipeline
**GitHub Actions** (free) + **Fastlane** (automation):

1. **On PR to develop**:
   - Run tests
   - Build app
   - Post build status

2. **On merge to develop**:
   - Run tests
   - Build beta version
   - Upload to TestFlight (Internal Testing)
   - Auto-increment build number

3. **On merge to main** (or tag v1.0.0):
   - Run tests
   - Build release version
   - Upload to App Store (for review)
   - Create GitHub release

### Environment Configuration
Create different build configurations:

```swift
// Config.swift
#if DEBUG
let apiEndpoint = "http://localhost:3000" // if you add backend later
let analyticsEnabled = false
#elseif BETA
let apiEndpoint = "https://dev-api.coffee-meter.com"
let analyticsEnabled = true
#else // RELEASE
let apiEndpoint = "https://api.coffee-meter.com"
let analyticsEnabled = true
#endif
```

## Getting Started Checklist

### Immediate (Free)
- [x] GitHub repository
- [ ] Enable GitHub Actions
- [ ] TestFlight setup (requires Apple Developer account)

### Required for TestFlight/App Store
- [ ] Apple Developer Account ($99/year)
  - Sign up at: https://developer.apple.com/programs/
  - Needed for: TestFlight, App Store, physical device testing

### Recommended Tools
- [ ] Fastlane (free, automate builds)
- [ ] Xcode Cloud or GitHub Actions (CI/CD)

## Quick Start: Manual TestFlight (Before CI/CD)

1. **Build in Xcode**
   - Product → Archive
   - Creates .xcarchive

2. **Upload to App Store Connect**
   - Xcode Organizer → Distribute App → TestFlight
   - Wait ~5 minutes for processing

3. **Invite Testers**
   - App Store Connect → TestFlight → Add testers
   - They install TestFlight app → Get your beta

4. **Iterate**
   - Fix bugs, add features
   - Archive → Upload new build
   - Auto-notifies testers

## Costs Summary

| Service | Cost | What You Get |
|---------|------|--------------|
| GitHub (Private repo) | Free | Unlimited repos, 2000 CI min/month |
| Apple Developer | $99/year | TestFlight, App Store, device testing |
| Xcode Cloud | Free tier | 25 hours/month CI/CD |
| GitHub Actions (macOS) | Free | 2000 min/month (plenty for small app) |
| Fastlane | Free | Automation tool |

**Total to start**: $99/year (Apple Developer account only)

## Next Steps

1. Keep building the app locally
2. When ready for first beta:
   - Sign up for Apple Developer account
   - Set up TestFlight
   - Manual upload first build
3. When app is stable:
   - Add GitHub Actions
   - Add Fastlane
   - Automate TestFlight uploads
4. Before App Store launch:
   - Polish UI/UX
   - Add screenshots
   - Write App Store description
   - Submit for review

## Resources

- **TestFlight**: https://developer.apple.com/testflight/
- **App Store Connect**: https://appstoreconnect.apple.com/
- **Fastlane**: https://fastlane.tools/
- **GitHub Actions iOS**: https://docs.github.com/en/actions/deployment/deploying-xcode-applications
