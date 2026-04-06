#!/bin/bash
# Refreshes npm authentication against the Alight Artifactory registry.
# Run this script whenever your credentials change or expire:
#   bash .devcontainer/refresh-auth.sh

REGISTRY_URL="https://artifactory.alight.com/artifactory/api/npm/devops-npm"
REGISTRY_HOST="//artifactory.alight.com/artifactory/api/npm/"
REGISTRY_HOST_JFROG="//jfrog.alight.com/artifactory/api/npm/"

echo "Artifactory npm authentication setup"
echo "Registry: $REGISTRY_URL"
echo ""

read -rp "Username: " USERNAME
read -rsp "API Key / Identity Token (input hidden): " TOKEN
echo ""

if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
  echo "Error: username and token are required."
  exit 1
fi

echo ""
echo "Token type:"
echo "  1) Identity Token (JFrog Platform / newer Artifactory)"
echo "  2) API Key or Password (older Artifactory)"
read -rp "Select [1/2] (default: 1): " TOKEN_TYPE
TOKEN_TYPE="${TOKEN_TYPE:-1}"

# Remove any previously set credentials for both registry hosts
npm config delete "${REGISTRY_HOST}:_auth" 2>/dev/null
npm config delete "${REGISTRY_HOST}:_authToken" 2>/dev/null
npm config delete "${REGISTRY_HOST_JFROG}:_auth" 2>/dev/null
npm config delete "${REGISTRY_HOST_JFROG}:_authToken" 2>/dev/null

if [[ "$TOKEN_TYPE" == "2" ]]; then
  # Basic auth: base64-encode username:token
  AUTH=$(echo -n "${USERNAME}:${TOKEN}" | base64 -w 0)
  npm config set "${REGISTRY_HOST}:_auth" "$AUTH"
  npm config set "${REGISTRY_HOST}:email" "${USERNAME}"
  npm config set "${REGISTRY_HOST_JFROG}:_auth" "$AUTH"
  npm config set "${REGISTRY_HOST_JFROG}:email" "${USERNAME}"
else
  # Identity token: set directly as _authToken
  npm config set "${REGISTRY_HOST}:_authToken" "${TOKEN}"
  npm config set "${REGISTRY_HOST_JFROG}:_authToken" "${TOKEN}"
fi

echo ""
echo "Authentication updated. Verifying access..."
WHOAMI=$(npm whoami --registry "$REGISTRY_URL" 2>&1)
if [[ $? -eq 0 ]]; then
  echo "Successfully authenticated as: $WHOAMI"
else
  echo "Error: authentication failed — $WHOAMI"
  echo "Check your credentials and token type, then run this script again."
  exit 1
fi
