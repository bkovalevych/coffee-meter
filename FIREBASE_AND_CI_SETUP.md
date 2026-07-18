# 🔥 Firebase & CI/CD Setup Complete!

## What Was Done

### 🔐 Security - Firebase Configuration
1. **Added to `.gitignore`:**
   - `GoogleService-Info.plist` (contains Firebase secrets)
   - Other sensitive files (`.env`, `*.secret`)

2. **Created Template File:**
   - `coffee meter/GoogleService-Info.plist.template`
   - Committed to repo as a reference

### 🤖 GitHub Actions CI/CD
1. **Created Workflow:** `.github/workflows/ios-build.yml`
   - Builds on every push to `main` and `develop`
   - Builds on pull requests
   - Can be triggered manually
   - Builds both iOS and watchOS apps
   - Uses secrets from GitHub

### 📝 Documentation
1. **SETUP.md** - Complete setup guide covering:
   - Local development setup
   - GitHub Actions configuration
   - Troubleshooting common issues
   - Security best practices

### 🛠 Helper Scripts
1. **`scripts/setup-firebase.sh`** - Automated local setup
   - Finds GoogleService-Info.plist in Downloads
   - Validates and copies to project
   - Interactive and user-friendly

2. **`scripts/encode-for-github.sh`** - GitHub secret encoder
   - Encodes plist to base64
   - Copies to clipboard automatically
   - Provides step-by-step instructions

## ✅ Next Steps for YOU

### 1. Set Up GitHub Secret (5 minutes)

```bash
# Navigate to project
cd "/Users/bohdankovalevych/Documents/study/the-most-useless-app/coffee meter"

# Run the encoder script
./scripts/encode-for-github.sh
```

Then:
1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions
2. Click **"New repository secret"**
3. Name: `FIREBASE_CONFIG_PLIST`
4. Value: Press ⌘V (the script copied it to clipboard)
5. Click **"Add secret"**

### 2. Test GitHub Actions

```bash
# Commit the changes
git add .
git commit -m "Add Firebase secrets management and CI/CD"
git push origin main
```

Then check: https://github.com/YOUR_USERNAME/YOUR_REPO/actions

### 3. Fix SwiftData Migration Error

The error you're seeing is because we added new properties to `CoffeePurchase` model:
- `quantity: Int`
- `coffeeName: String?`

**Option A: Clean Install (Easiest)**
Delete the app from simulator/device and reinstall. This will recreate the database with the new schema.

**Option B: Keep Existing Data**
If you want to keep existing purchases, SwiftData should automatically migrate them with:
- `quantity = 1` (default value)
- `coffeeName = nil`

Try building and running again. The model now has default values which should allow automatic migration.

## 🔒 Security Checklist

- [x] GoogleService-Info.plist is in .gitignore
- [ ] FIREBASE_CONFIG_PLIST secret added to GitHub
- [ ] GoogleService-Info.plist NOT in git history (check: `git log --all --full-history -- "*GoogleService-Info.plist"`)
- [ ] Firebase project has security rules configured
- [ ] App Group entitlement is properly configured

## 📁 File Structure

```
coffee meter/
├── .github/
│   └── workflows/
│       └── ios-build.yml                    # ✅ GitHub Actions workflow
├── coffee meter/
│   ├── GoogleService-Info.plist             # ⚠️ NOT in git (local only)
│   └── GoogleService-Info.plist.template    # ✅ In git (template)
├── scripts/
│   ├── setup-firebase.sh                    # ✅ Local setup helper
│   └── encode-for-github.sh                 # ✅ GitHub secret encoder
├── .gitignore                               # ✅ Updated with Firebase
├── SETUP.md                                 # ✅ Complete guide
└── FIREBASE_AND_CI_SETUP.md                 # ✅ This file
```

## 🚨 If Firebase Config Was Committed to Git

If you accidentally committed the file before:

```bash
# Remove from git history (DANGEROUS - use with caution)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch 'coffee meter/GoogleService-Info.plist'" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (only if you're sure!)
git push origin --force --all

# Rotate Firebase API keys in Firebase Console
```

## 🎯 Testing the CI/CD

### Manual Test
1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/actions
2. Click "iOS Build" workflow
3. Click "Run workflow"
4. Select branch: `main`
5. Click "Run workflow"
6. Wait ~5-10 minutes
7. Check if build succeeds ✅

### Automatic Test
Push any code change to `main` or `develop` - workflow runs automatically.

## 🆘 Troubleshooting

### "Could not get GOOGLE_APP_ID" in GitHub Actions
- Check secret name: Must be exactly `FIREBASE_CONFIG_PLIST`
- Re-run the encode script and update the secret
- Check workflow logs in Actions tab

### Local build fails with Firebase error
- Run: `./scripts/setup-firebase.sh`
- Make sure file exists: `ls "coffee meter/GoogleService-Info.plist"`
- Clean build: Shift+⌘+K in Xcode

### SwiftData migration error
- Delete app from simulator
- Reinstall and run again
- Or check Xcode console for specific migration errors

---

**Created:** July 2026
**Status:** ✅ Ready for GitHub Actions
