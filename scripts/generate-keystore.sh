#!/bin/bash
# =============================================================================
# ANDROID KEYSTORE GENERATOR
# For GitHub Actions Deployment
# =============================================================================
#
# This script generates a JKS keystore using ONLY user-provided company information.
# It does NOT read any system data, IP addresses, usernames, or location information.
# All inputs are manually entered by the user.
#
# Requirements: Java JDK installed (keytool command)
# Output: keystore file + base64-encoded version for GitHub Secrets
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  ANDROID KEYSTORE GENERATOR${NC}"
echo -e "${CYAN}  For GitHub Actions Deployment${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}PRIVACY NOTICE:${NC}"
echo "This script does NOT collect or use any system information."
echo "All data is provided manually by you."
echo "The keystore will be generated using ONLY your inputs."
echo ""
echo -e "${CYAN}============================================================${NC}"
echo ""

# =============================================================================
# CHECK PREREQUISITES
# =============================================================================
echo -e "Checking for Java keytool..."
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}ERROR: Java keytool not found. Please install JDK first.${NC}"
    echo -e "${YELLOW}Download from: https://adoptium.net/${NC}"
    exit 1
fi
echo -e "${GREEN}keytool found!${NC}"

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  ENTER COMPANY/ORGANIZATION DETAILS${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# =============================================================================
# COLLECT USER INPUT (NO AUTO-FILL, NO SYSTEM DATA)
# =============================================================================

# Common Name (CN)
while true; do
    read -p "Common Name (e.g., App Name or Company Name): " CN
    if [ -n "$CN" ]; then break; fi
    echo -e "${RED}Common Name is required.${NC}"
done

# Organization Name (O)
while true; do
    read -p "Organization Name (e.g., Your Company Ltd): " O
    if [ -n "$O" ]; then break; fi
    echo -e "${RED}Organization Name is required.${NC}"
done

# Organizational Unit (OU) - Optional
read -p "Organizational Unit (optional, press Enter to skip): " OU
if [ -z "$OU" ]; then OU="Development"; fi

# City/Locality (L)
while true; do
    read -p "City/Locality (e.g., London): " L
    if [ -n "$L" ]; then break; fi
    echo -e "${RED}City is required.${NC}"
done

# State/Province (ST) - Optional
read -p "State/Province (optional, press Enter to skip): " ST
if [ -z "$ST" ]; then ST="$L"; fi

# Country Code (C)
while true; do
    read -p "Country Code (2 letters, e.g., US, GB, DE): " C
    C=$(echo "$C" | tr '[:lower:]' '[:upper:]')
    if [ ${#C} -eq 2 ]; then break; fi
    echo -e "${RED}Country code must be exactly 2 letters.${NC}"
done

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  ENTER KEYSTORE CREDENTIALS${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# Key Alias
while true; do
    read -p "Key Alias (e.g., upload, release): " KEY_ALIAS
    if [ -n "$KEY_ALIAS" ]; then break; fi
    echo -e "${RED}Key Alias is required.${NC}"
done

# Store Password
while true; do
    read -s -p "Keystore Password (min 6 characters): " STORE_PASSWORD
    echo ""
    if [ ${#STORE_PASSWORD} -ge 6 ]; then break; fi
    echo -e "${RED}Password must be at least 6 characters.${NC}"
done

# Confirm Store Password
while true; do
    read -s -p "Confirm Keystore Password: " STORE_PASSWORD_CONFIRM
    echo ""
    if [ "$STORE_PASSWORD" = "$STORE_PASSWORD_CONFIRM" ]; then break; fi
    echo -e "${RED}Passwords do not match. Try again.${NC}"
done

# Key Password
while true; do
    read -s -p "Key Password (min 6 characters, can be same as keystore): " KEY_PASSWORD
    echo ""
    if [ ${#KEY_PASSWORD} -ge 6 ]; then break; fi
    echo -e "${RED}Password must be at least 6 characters.${NC}"
done

# =============================================================================
# GENERATE KEYSTORE
# =============================================================================
echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  GENERATING KEYSTORE${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

KEYSTORE_FILE="upload-keystore.jks"
DNAME="CN=$CN, OU=$OU, O=$O, L=$L, ST=$ST, C=$C"

echo "Generating keystore with the following details:"
echo "  DN: $DNAME"
echo "  Alias: $KEY_ALIAS"
echo "  File: $KEYSTORE_FILE"
echo ""

# Remove existing keystore if present
rm -f "$KEYSTORE_FILE"

# Generate keystore using keytool
keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -storetype JKS \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -dname "$DNAME" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" 2>/dev/null

if [ ! -f "$KEYSTORE_FILE" ]; then
    echo -e "${RED}ERROR: Failed to generate keystore${NC}"
    exit 1
fi

echo -e "${GREEN}Keystore generated successfully!${NC}"

# =============================================================================
# ENCODE KEYSTORE TO BASE64
# =============================================================================
echo ""
echo "Encoding keystore to Base64..."

BASE64_FILE="keystore-base64.txt"
base64 -i "$KEYSTORE_FILE" > "$BASE64_FILE"

echo -e "${GREEN}Base64-encoded keystore saved to: $BASE64_FILE${NC}"

# =============================================================================
# OUTPUT INSTRUCTIONS
# =============================================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  KEYSTORE GENERATED SUCCESSFULLY!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "${YELLOW}FILES CREATED:${NC}"
echo "  1. $KEYSTORE_FILE - The keystore file (keep secure!)"
echo "  2. $BASE64_FILE - Base64-encoded keystore for GitHub"
echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  GITHUB SECRETS SETUP${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}Go to your GitHub repository:${NC}"
echo "  Settings > Secrets and variables > Actions > New repository secret"
echo ""
echo -e "${YELLOW}Add these 4 secrets:${NC}"
echo ""
echo -e "${WHITE}1. ANDROID_KEYSTORE_BASE64${NC}"
echo "   Value: (copy entire contents of $BASE64_FILE)"
echo ""
echo -e "${WHITE}2. ANDROID_KEYSTORE_PASSWORD${NC}"
echo "   Value: (your keystore password)"
echo ""
echo -e "${WHITE}3. ANDROID_KEY_ALIAS${NC}"
echo "   Value: $KEY_ALIAS"
echo ""
echo -e "${WHITE}4. ANDROID_KEY_PASSWORD${NC}"
echo "   Value: (your key password)"
echo ""
echo -e "${RED}============================================================${NC}"
echo -e "${RED}  SECURITY REMINDERS${NC}"
echo -e "${RED}============================================================${NC}"
echo ""
echo -e "${RED}1. NEVER commit $KEYSTORE_FILE or $BASE64_FILE to Git!${NC}"
echo -e "${RED}2. Store these files securely (offline backup recommended)${NC}"
echo -e "${RED}3. Delete $BASE64_FILE after adding to GitHub Secrets${NC}"
echo -e "${YELLOW}4. The keystore is valid for ~27 years (10000 days)${NC}"
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  DONE!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""

# Clear sensitive variables
unset STORE_PASSWORD
unset STORE_PASSWORD_CONFIRM
unset KEY_PASSWORD

