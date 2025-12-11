# Android Deployment Guide

This guide explains how to set up automated Android builds using GitHub Actions.

## 🔒 Privacy & Security Notice

**The keystore generation script (`scripts/generate-keystore.ps1` or `scripts/generate-keystore.sh`):**
- ✅ Does NOT collect any system information
- ✅ Does NOT read usernames, IP addresses, or location data
- ✅ Does NOT auto-fill any fields
- ✅ Uses ONLY the information you manually provide
- ✅ All inputs are prompted interactively

**The GitHub Actions workflow:**
- ✅ Never prints secrets to logs
- ✅ Decodes keystore only at runtime
- ✅ Deletes sensitive files after build
- ✅ Uses GitHub Secrets for all credentials

---

## 📋 Prerequisites

1. **Java JDK** installed (for `keytool` command)
   - Download: https://adoptium.net/
2. **GitHub Repository** with Actions enabled
3. **Repository Admin access** (to add secrets)

---

## 🔑 Step 1: Generate Keystore

### Windows (PowerShell)

```powershell
cd scripts
.\generate-keystore.ps1
```

### macOS/Linux (Bash)

```bash
cd scripts
chmod +x generate-keystore.sh
./generate-keystore.sh
```

### What You'll Be Asked

The script will prompt you for:

| Field | Description | Example |
|-------|-------------|---------|
| Common Name | App or company name | `Food Truck Frenzy` |
| Organization | Company legal name | `Awesome Games Ltd` |
| Org Unit | Department (optional) | `Mobile Development` |
| City | City name | `New York` |
| State | State/Province (optional) | `NY` |
| Country Code | 2-letter code | `US` |
| Key Alias | Identifier for the key | `upload` |
| Keystore Password | Min 6 characters | (your password) |
| Key Password | Min 6 characters | (your password) |

### Output Files

After running, you'll have:
- `upload-keystore.jks` - The keystore file (KEEP SECURE!)
- `keystore-base64.txt` - Base64 version for GitHub

---

## 🔐 Step 2: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these 4 secrets:

| Secret Name | Value |
|-------------|-------|
| `ANDROID_KEYSTORE_BASE64` | Contents of `keystore-base64.txt` |
| `ANDROID_KEYSTORE_PASSWORD` | Your keystore password |
| `ANDROID_KEY_ALIAS` | Your key alias (e.g., `upload`) |
| `ANDROID_KEY_PASSWORD` | Your key password |

---

## 🚀 Step 3: Trigger Build

The workflow runs automatically on:

| Trigger | Action |
|---------|--------|
| Push to `main`/`master` | Builds APK & AAB |
| Push a tag (e.g., `v1.0.0`) | Builds + Creates GitHub Release |
| Pull Request | Builds (for validation) |
| Manual trigger | Go to Actions → Run workflow |

### Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **Build Android Release**
3. Click **Run workflow**
4. Select branch and click **Run workflow**

---

## 📦 Step 4: Download Artifacts

After a successful build:

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download:
   - `release-apk` - Signed APK file
   - `release-aab` - Signed AAB for Play Store

---

## 🏷️ Creating a Release

To create a versioned release with download links:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will:
1. Build signed APK & AAB
2. Create a GitHub Release
3. Attach both files to the release

---

## 📁 File Structure

```
.github/
└── workflows/
    └── build-release.yml    # GitHub Actions workflow

scripts/
├── generate-keystore.ps1    # Windows keystore generator
└── generate-keystore.sh     # macOS/Linux keystore generator

android/
├── app/
│   └── build.gradle.kts     # App build config (DO NOT add keystore here)
└── key.properties           # Created at runtime by CI (gitignored)
```

---

## ⚠️ Security Checklist

Before pushing to GitHub, verify:

- [ ] `*.jks` files are in `.gitignore`
- [ ] `key.properties` is in `.gitignore`
- [ ] `keystore-base64.txt` is in `.gitignore`
- [ ] No passwords are hardcoded anywhere
- [ ] Secrets are added to GitHub, not committed

### Files That Should NEVER Be Committed

```
upload-keystore.jks
keystore-base64.txt
key.properties
android/app/*.jks
android/key.properties
```

---

## 🔧 Troubleshooting

### Build Fails: "Keystore not found"
- Verify `ANDROID_KEYSTORE_BASE64` secret is set correctly
- Check the base64 encoding (no line breaks)

### Build Fails: "Wrong password"
- Double-check `ANDROID_KEYSTORE_PASSWORD` and `ANDROID_KEY_PASSWORD`
- Passwords are case-sensitive

### Build Fails: "Alias not found"
- Verify `ANDROID_KEY_ALIAS` matches exactly what you entered during generation

### keytool Not Found
- Install Java JDK: https://adoptium.net/
- Ensure `JAVA_HOME` is set correctly

---

## 📞 Support

For issues with:
- **Build failures**: Check the Actions logs in GitHub
- **Keystore issues**: Re-run the generation script
- **Play Store upload**: Ensure you're using the AAB file

---

## 📄 License

This deployment setup is provided as-is for use with the Food Truck Frenzy project.

