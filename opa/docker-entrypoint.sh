#!/bin/bash
set -euo pipefail

# require environment variables to be set
if [[ -z "${KEYCLOAK_BASE_URL:-}" ]]; then
  echo "Please set the environment variable KEYCLOAK_BASE_URL"
  exit 126
fi

if [[ -z "${KEYCLOAK_REALM:-}" ]]; then
  echo "Please set the environment variable KEYCLOAK_REALM"
  exit 126
fi

while :
do
  echo "Waiting for Keycloak to be ready..."
  curl $KEYCLOAK_BASE_URL/realms/$KEYCLOAK_REALM && break
  sleep 1
done

# get OpenID certificate url
JWKS_URI=$(curl --silent $KEYCLOAK_BASE_URL/realms/$KEYCLOAK_REALM/.well-known/openid-configuration \
          | jq --raw-output '.jwks_uri')

# get certificates
JWKS=$(curl --silent $JWKS_URI)

# place certificates in object for OPA data
cat /bundles/auth/data.json | jq --arg jwks "$JWKS" '.jwks = $jwks' > /bundles/auth/data.json
