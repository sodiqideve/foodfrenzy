<#
.SYNOPSIS
    Generates an Android signing keystore for Google Play Store deployment.

.DESCRIPTION
    This script generates a JKS keystore using ONLY user-provided company information.
    It does NOT read any system data, IP addresses, usernames, or location information.
    All inputs are manually entered by the user.

.NOTES
    - Requires Java JDK installed (keytool command)
    - Output: keystore file + base64-encoded version for GitHub Secrets
    - NEVER commit the keystore or passwords to version control
#>

# =============================================================================
# PRIVACY NOTICE
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ANDROID KEYSTORE GENERATOR" -ForegroundColor Cyan
Write-Host "  For GitHub Actions Deployment" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PRIVACY NOTICE:" -ForegroundColor Yellow
Write-Host "This script does NOT collect or use any system information."
Write-Host "All data is provided manually by you."
Write-Host "The keystore will be generated using ONLY your inputs."
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# CHECK PREREQUISITES
# =============================================================================
Write-Host "Checking for Java keytool..." -ForegroundColor Gray
try {
    $keytoolVersion = & keytool -help 2>&1 | Select-String "keytool"
    if (-not $keytoolVersion) {
        throw "keytool not found"
    }
    Write-Host "keytool found!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Java keytool not found. Please install JDK first." -ForegroundColor Red
    Write-Host "Download from: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ENTER COMPANY/ORGANIZATION DETAILS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# COLLECT USER INPUT (NO AUTO-FILL, NO SYSTEM DATA)
# =============================================================================

# Common Name (CN)
do {
    $CN = Read-Host "Common Name (e.g., App Name or Company Name)"
    if ([string]::IsNullOrWhiteSpace($CN)) {
        Write-Host "Common Name is required." -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($CN))

# Organization Name (O)
do {
    $O = Read-Host "Organization Name (e.g., Your Company Ltd)"
    if ([string]::IsNullOrWhiteSpace($O)) {
        Write-Host "Organization Name is required." -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($O))

# Organizational Unit (OU) - Optional
$OU = Read-Host "Organizational Unit (optional, press Enter to skip)"
if ([string]::IsNullOrWhiteSpace($OU)) { $OU = "Development" }

# City/Locality (L)
do {
    $L = Read-Host "City/Locality (e.g., London)"
    if ([string]::IsNullOrWhiteSpace($L)) {
        Write-Host "City is required." -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($L))

# State/Province (ST) - Optional
$ST = Read-Host "State/Province (optional, press Enter to skip)"
if ([string]::IsNullOrWhiteSpace($ST)) { $ST = $L }

# Country Code (C)
do {
    $C = Read-Host "Country Code (2 letters, e.g., US, GB, DE)"
    $C = $C.ToUpper()
    if ($C.Length -ne 2) {
        Write-Host "Country code must be exactly 2 letters." -ForegroundColor Red
        $C = ""
    }
} while ([string]::IsNullOrWhiteSpace($C))

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ENTER KEYSTORE CREDENTIALS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Key Alias
do {
    $KEY_ALIAS = Read-Host "Key Alias (e.g., upload, release)"
    if ([string]::IsNullOrWhiteSpace($KEY_ALIAS)) {
        Write-Host "Key Alias is required." -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($KEY_ALIAS))

# Store Password
do {
    $STORE_PASSWORD = Read-Host "Keystore Password (min 6 characters)" -AsSecureString
    $STORE_PASSWORD_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($STORE_PASSWORD)
    )
    if ($STORE_PASSWORD_PLAIN.Length -lt 6) {
        Write-Host "Password must be at least 6 characters." -ForegroundColor Red
        $STORE_PASSWORD_PLAIN = ""
    }
} while ([string]::IsNullOrWhiteSpace($STORE_PASSWORD_PLAIN))

# Confirm Store Password
do {
    $STORE_PASSWORD_CONFIRM = Read-Host "Confirm Keystore Password" -AsSecureString
    $STORE_PASSWORD_CONFIRM_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($STORE_PASSWORD_CONFIRM)
    )
    if ($STORE_PASSWORD_CONFIRM_PLAIN -ne $STORE_PASSWORD_PLAIN) {
        Write-Host "Passwords do not match. Try again." -ForegroundColor Red
        $STORE_PASSWORD_CONFIRM_PLAIN = ""
    }
} while ($STORE_PASSWORD_CONFIRM_PLAIN -ne $STORE_PASSWORD_PLAIN)

# Key Password
do {
    $KEY_PASSWORD = Read-Host "Key Password (min 6 characters, can be same as keystore)" -AsSecureString
    $KEY_PASSWORD_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($KEY_PASSWORD)
    )
    if ($KEY_PASSWORD_PLAIN.Length -lt 6) {
        Write-Host "Password must be at least 6 characters." -ForegroundColor Red
        $KEY_PASSWORD_PLAIN = ""
    }
} while ([string]::IsNullOrWhiteSpace($KEY_PASSWORD_PLAIN))

# =============================================================================
# GENERATE KEYSTORE
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GENERATING KEYSTORE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Use absolute paths to avoid .NET vs PowerShell working directory mismatch
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($ScriptDir)) {
    $ScriptDir = (Get-Location).Path
}
$KEYSTORE_FILE = Join-Path $ScriptDir "upload-keystore.jks"
$BASE64_FILE = Join-Path $ScriptDir "keystore-base64.txt"
$DNAME = "CN=$CN, OU=$OU, O=$O, L=$L, ST=$ST, C=$C"

$KEYSTORE_FILENAME = Split-Path -Leaf $KEYSTORE_FILE
$BASE64_FILENAME = Split-Path -Leaf $BASE64_FILE

Write-Host "Generating keystore with the following details:" -ForegroundColor Gray
Write-Host "  DN: $DNAME" -ForegroundColor Gray
Write-Host "  Alias: $KEY_ALIAS" -ForegroundColor Gray
Write-Host "  File: $KEYSTORE_FILENAME" -ForegroundColor Gray
Write-Host "  Location: $ScriptDir" -ForegroundColor Gray
Write-Host ""

# Remove existing keystore if present
if (Test-Path $KEYSTORE_FILE) {
    Remove-Item $KEYSTORE_FILE -Force
}

# Generate keystore using keytool
$keytoolArgs = @(
    "-genkey",
    "-v",
    "-keystore", $KEYSTORE_FILE,
    "-storetype", "JKS",
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-alias", $KEY_ALIAS,
    "-dname", $DNAME,
    "-storepass", $STORE_PASSWORD_PLAIN,
    "-keypass", $KEY_PASSWORD_PLAIN
)

try {
    & keytool @keytoolArgs 2>&1 | Out-Null
    
    if (-not (Test-Path $KEYSTORE_FILE)) {
        throw "Keystore file was not created"
    }
    
    Write-Host "Keystore generated successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to generate keystore: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# ENCODE KEYSTORE TO BASE64
# =============================================================================
Write-Host ""
Write-Host "Encoding keystore to Base64..." -ForegroundColor Gray

$keystoreBytes = [System.IO.File]::ReadAllBytes($KEYSTORE_FILE)
$keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)

# Save base64 to file (BASE64_FILE already set to absolute path above)
$keystoreBase64 | Out-File -FilePath $BASE64_FILE -Encoding ASCII -NoNewline

Write-Host "Base64-encoded keystore saved to: $BASE64_FILE" -ForegroundColor Green

# =============================================================================
# OUTPUT INSTRUCTIONS
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  KEYSTORE GENERATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "FILES CREATED:" -ForegroundColor Yellow
Write-Host "  1. $KEYSTORE_FILENAME - The keystore file (keep secure!)"
Write-Host "  2. $BASE64_FILENAME - Base64-encoded keystore for GitHub"
Write-Host "  Location: $ScriptDir" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GITHUB SECRETS SETUP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Go to your GitHub repository:" -ForegroundColor Yellow
Write-Host "  Settings > Secrets and variables > Actions > New repository secret"
Write-Host ""
Write-Host "Add these 4 secrets:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. ANDROID_KEYSTORE_BASE64" -ForegroundColor White
Write-Host "   Value: (copy entire contents of $BASE64_FILENAME)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. ANDROID_KEYSTORE_PASSWORD" -ForegroundColor White
Write-Host "   Value: (your keystore password)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. ANDROID_KEY_ALIAS" -ForegroundColor White
Write-Host "   Value: $KEY_ALIAS" -ForegroundColor Gray
Write-Host ""
Write-Host "4. ANDROID_KEY_PASSWORD" -ForegroundColor White
Write-Host "   Value: (your key password)" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================================" -ForegroundColor Red
Write-Host "  SECURITY REMINDERS" -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Red
Write-Host ""
Write-Host "1. NEVER commit $KEYSTORE_FILENAME or $BASE64_FILENAME to Git!" -ForegroundColor Red
Write-Host "2. Store these files securely (offline backup recommended)" -ForegroundColor Red
Write-Host "3. Delete $BASE64_FILENAME after adding to GitHub Secrets" -ForegroundColor Red
Write-Host "4. The keystore is valid for ~27 years (10000 days)" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  DONE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

# Clear sensitive variables from memory
$STORE_PASSWORD_PLAIN = $null
$KEY_PASSWORD_PLAIN = $null
$STORE_PASSWORD_CONFIRM_PLAIN = $null
[System.GC]::Collect()

