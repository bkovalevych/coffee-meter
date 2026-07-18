# 🌍 GitHub Environments Setup Guide

This guide shows you how to set up **multiple environments** (development & production) in GitHub Actions with separate Firebase configurations.

## 📊 What You'll Get

### Current Problem
- ❌ Only one `FIREBASE_CONFIG_PLIST` secret
- ❌ Same Firebase app for dev and production
- ❌ Test data mixed with production analytics

### After Setup
- ✅ Separate Firebase apps for dev/production
- ✅ Clean production analytics (no test data)
- ✅ Automatic environment selection based on branch
- ✅ Protection rules for production deploys

## 🎯 Environment Strategy

```
┌─────────────────────────────────────────────────────┐
│  develop branch → development environment           │
│  └── Debug build                                    │
│  └── Development Firebase (test data)               │
│  └── Auto-deploys on push                          │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  main branch → production environment               │
│  └── Release build                                  │
│  └── Production Firebase (real user data)          │
│  └── Optional: Requires approval                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Pull Requests → No secrets needed                  │
│  └── Debug build                                    │
│  └── Dummy Firebase config (just compile check)    │
│  └── Fast syntax validation                        │
└─────────────────────────────────────────────────────┘
```

## 🛠 Step-by-Step Setup

### Step 1: Create Firebase Apps (In Firebase Console)

You need **two iOS apps** in the same Firebase project.

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: `peaky-flow-solution`

**Create Development App:**
1. Click "Add app" → iOS
2. Bundle ID: `useless.com.coffee-meter.dev`
3. App nickname: `Coffee Meter (Development)`
4. Download `GoogleService-Info.plist`
5. Rename to `GoogleService-Info-Dev.plist`
6. Save to Downloads folder

**Your Production App (Already Exists):**
- Bundle ID: `useless.com.coffee-meter`
- GoogleService-Info.plist (you already have this)

### Step 2: Encode Both Firebase Configs

```bash
cd "/Users/bohdankovalevych/Documents/study/the-most-useless-app/coffee meter"

# Encode Development config
base64 -i ~/Downloads/GoogleService-Info-Dev.plist | pbcopy
# Save this somewhere temporarily (Notes app)

# Encode Production config
base64 -i "coffee meter/GoogleService-Info.plist" | pbcopy
# Save this somewhere temporarily too
```

### Step 3: Create Environments in GitHub

1. Go to your repo on GitHub
2. Click **Settings** → **Environments**

#### Create Development Environment

1. Click **"New environment"**
2. Name: `development`
3. Click **"Configure environment"**
4. **Protection rules:** (optional)
   - Leave empty (no restrictions for dev)
5. **Environment secrets:**
   - Click **"Add secret"**
   - Name: `FIREBASE_CONFIG_PLIST`
   - Value: Paste the **development** base64 string
   - Click **"Add secret"**

#### Create Production Environment

1. Click **"New environment"**
2. Name: `production`
3. Click **"Configure environment"**
4. **Protection rules:** (recommended)
   - ✅ **Required reviewers:** Add yourself
     - This forces you to approve production deploys
   - ✅ **Deployment branches:** Select "Selected branches"
     - Add: `main`
     - This ensures only main branch can deploy to production
5. **Environment secrets:**
   - Click **"Add secret"**
   - Name: `FIREBASE_CONFIG_PLIST`
   - Value: Paste the **production** base64 string
   - Click **"Add secret"**

### Step 4: Test the Setup

#### Test Development Build

```bash
git checkout develop
# or create develop branch: git checkout -b develop

git add .
git commit -m "Test development build"
git push origin develop
```

Go to **Actions** tab → You should see "Build (Development)" running

#### Test Production Build

```bash
git checkout main
git add .
git commit -m "Test production build"
git push origin main
```

Go to **Actions** tab → You should see "Build (Production)" running

If you set up approval requirement, you'll need to **approve** it first!

## 🎮 Manual Workflow Triggers

You can also trigger builds manually:

1. Go to **Actions** tab
2. Click "iOS Build" workflow
3. Click **"Run workflow"**
4. Select:
   - **Branch:** `develop` or `main`
   - **Environment:** `development` or `production`
5. Click **"Run workflow"**

## 📋 What Happens Now

### When you push to `develop` branch:
- ✅ Builds with **Debug** configuration
- ✅ Uses **development** Firebase app
- ✅ Test data goes to development analytics
- ✅ No approval needed
- ✅ Fast feedback loop

### When you push to `main` branch:
- ✅ Builds with **Release** configuration
- ✅ Uses **production** Firebase app
- ✅ Real data goes to production analytics
- ⏸️ Requires approval (if you set it up)
- ✅ Protected deployment

### When you create a Pull Request:
- ✅ Builds with **Debug** configuration
- ✅ Uses **dummy** Firebase config (no real secrets)
- ✅ Fast compile check only
- ✅ No Firebase data sent

## 🔍 Verifying It Works

### Check Build Logs

1. Go to **Actions** tab
2. Click on a workflow run
3. Expand the job (Development or Production)
4. Look for these messages:

**Development:**
```
🔧 Setting up Development Firebase configuration...
✅ Development Firebase configuration created
```

**Production:**
```
🚀 Setting up Production Firebase configuration...
✅ Production Firebase configuration created
```

### Check Firebase Console

After running builds:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Check **Analytics** → **Events**
3. You should see different data for:
   - Development app (test events)
   - Production app (real user events)

## 🚨 Troubleshooting

### "Environment not found" Error

**Problem:** Workflow can't find the environment.

**Solution:**
- Make sure environment names are exactly: `development` and `production`
- Check spelling and capitalization

### "Secret not found" Error

**Problem:** Secret doesn't exist in the environment.

**Solution:**
1. Go to Settings → Environments → (environment name)
2. Verify `FIREBASE_CONFIG_PLIST` secret exists
3. If not, add it with the correct base64 value

### Builds Running on Wrong Environment

**Problem:** Main branch using development config.

**Solution:**
- Check the workflow file conditions are correct
- Look at the job's `if:` statement
- Make sure you're pushing to the right branch

### Need to Update a Secret

**To update:**
1. Settings → Environments → (environment name)
2. Click on the secret name
3. Click **"Update secret"**
4. Paste new value
5. Click **"Update secret"**

## 📚 Summary

### Before:
```
Repository Secrets:
└── FIREBASE_CONFIG_PLIST (single secret for everything)
```

### After:
```
Environments:
├── development
│   └── FIREBASE_CONFIG_PLIST (dev Firebase app)
│   └── No protection rules
│   └── Used by: develop branch
│
└── production
    └── FIREBASE_CONFIG_PLIST (production Firebase app)
    └── Requires approval
    └── Only from: main branch
    └── Used by: main branch
```

## 🎯 Next Steps

1. ✅ Create two Firebase apps (dev & production)
2. ✅ Encode both configs to base64
3. ✅ Create environments in GitHub
4. ✅ Add secrets to each environment
5. ✅ Set up protection rules for production
6. ✅ Create `develop` branch if you don't have it
7. ✅ Test by pushing to both branches

---

**Last Updated:** July 2026
**Status:** ✅ Ready for multi-environment deployment
