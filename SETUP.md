# Coffee Meter - Development Setup

This guide explains how to set up the Coffee Meter project for local development and configure CI/CD with GitHub Actions.

## 📋 Prerequisites

- macOS 14.0 or later
- Xcode 15.4 or later
- Firebase account (free tier is sufficient)
- GitHub account (for CI/CD)

## 🔐 Firebase Configuration Setup

The project uses Firebase for Analytics and Crashlytics. The configuration file (`GoogleService-Info.plist`) contains sensitive data and is **not** committed to the repository.

### For Local Development

1. **Download Firebase Configuration:**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project: `peaky-flow-solution`
   - Go to Project Settings (⚙️ icon)
   - Scroll down to "Your apps" section
   - Find the iOS app with Bundle ID: `useless.com.coffee-meter`
   - Click "Download GoogleService-Info.plist"

2. **Add to Project:**
   ```bash
   # Copy the downloaded file to the project
   cp ~/Downloads/GoogleService-Info.plist "coffee meter/GoogleService-Info.plist"
   ```

3. **Verify Setup:**
   - Open `coffee meter.xcodeproj` in Xcode
   - The file should appear in the file navigator (but grayed out in git)
   - Build the project (⌘B) - it should compile successfully

### For New Firebase Project (Optional)

If you want to create your own Firebase project instead of using the existing one:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Follow the setup wizard
4. Add an iOS app with Bundle ID: `useless.com.coffee-meter`
5. Download `GoogleService-Info.plist`
6. Enable Analytics and Crashlytics in Firebase Console

## 🤖 GitHub Actions Setup

The project includes automated builds using GitHub Actions. Here's how to set it up:

### Step 1: Encode Firebase Config

First, convert your `GoogleService-Info.plist` to base64:

```bash
# Navigate to project directory
cd "coffee meter"

# Encode the file to base64
base64 -i "GoogleService-Info.plist" | pbcopy
```

The base64 string is now in your clipboard.

### Step 2: Add GitHub Secret

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the secret:
   - **Name:** `FIREBASE_CONFIG_PLIST`
   - **Value:** Paste the base64 string from your clipboard
5. Click **Add secret**

### Step 3: Test the Workflow

1. Push code to `main` or `develop` branch
2. Go to **Actions** tab in GitHub
3. You should see "iOS Build" workflow running
4. Wait for it to complete (usually 5-10 minutes)

### Manual Trigger

You can also trigger builds manually:

1. Go to **Actions** tab
2. Select "iOS Build" workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## 📁 Project Structure

```
coffee meter/
├── .github/
│   └── workflows/
│       └── ios-build.yml          # GitHub Actions workflow
├── coffee meter/
│   ├── GoogleService-Info.plist   # ⚠️ NOT in git (ignored)
│   └── GoogleService-Info.plist.template  # Template for reference
├── .gitignore                     # Ignores Firebase config
└── SETUP.md                       # This file
```

## 🔧 Troubleshooting

### "Could not get GOOGLE_APP_ID" Error

**Problem:** Xcode can't find the Firebase configuration file.

**Solution:**
```bash
# Verify file exists
ls -la "coffee meter/GoogleService-Info.plist"

# If missing, download from Firebase Console
# Then copy to project directory
cp ~/Downloads/GoogleService-Info.plist "coffee meter/GoogleService-Info.plist"

# Clean build folder
# In Xcode: Product → Clean Build Folder (⇧⌘K)
```

### GitHub Actions Build Failing

**Problem:** Workflow fails with Firebase-related errors.

**Solutions:**

1. **Check Secret Encoding:**
   ```bash
   # Re-encode and update the secret
   base64 -i "GoogleService-Info.plist" | pbcopy
   # Update FIREBASE_CONFIG_PLIST in GitHub Secrets
   ```

2. **Verify Secret Name:**
   - Must be exactly: `FIREBASE_CONFIG_PLIST`
   - Case-sensitive
   - No extra spaces

3. **Check Workflow Logs:**
   - Go to Actions tab
   - Click on failed run
   - Expand "Setup Firebase Config" step
   - Look for error messages

### Firebase Not Initializing

**Problem:** App crashes or Firebase features don't work.

**Solution:**
```swift
// Verify Firebase is initialized in coffee_meterApp.swift
init() {
    FirebaseApp.configure()  // ← Should be present
}
```

## 🔒 Security Best Practices

### ✅ DO:
- Keep `GoogleService-Info.plist` in `.gitignore`
- Use GitHub Secrets for CI/CD
- Rotate Firebase API keys if exposed
- Enable Firebase App Check for production
- Review Firebase security rules regularly

### ❌ DON'T:
- Commit `GoogleService-Info.plist` to git
- Share Firebase config in public channels
- Use production Firebase project for development
- Push secrets to public repositories

## 🚀 Building for Production

### Archive Build (for App Store)

1. **Ensure Firebase Config Exists:**
   ```bash
   ls "coffee meter/GoogleService-Info.plist"
   ```

2. **Create Archive:**
   - Open project in Xcode
   - Select "Any iOS Device" as destination
   - Product → Archive (⌘B)

3. **Upload to App Store:**
   - Window → Organizer
   - Select archive
   - Click "Distribute App"
   - Follow App Store Connect wizard

### Release Configuration

The GitHub Actions workflow uses `Release` configuration which:
- Enables optimizations
- Strips debug symbols
- Runs Crashlytics symbol upload (for Release builds only)

## 📚 Additional Resources

- [Firebase iOS Setup Guide](https://firebase.google.com/docs/ios/setup)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)

## 🆘 Getting Help

If you encounter issues:

1. Check this SETUP.md file
2. Review GitHub Actions logs
3. Check Firebase Console for project status
4. Verify all prerequisites are installed
5. Try cleaning derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

---

**Last Updated:** July 2026
