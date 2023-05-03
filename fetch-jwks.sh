#!/bin/sh

KEYCLOAK_BASE_URL=${KEYCLOAK_BASE_URL:-http://localhost:8097}
KEYCLOAK_REALM=ucs

# get OpenID certificate url
JWKS_URI=$(curl --silent $KEYCLOAK_BASE_URL/realms/$KEYCLOAK_REALM/.well-known/openid-configuration \
          | jq --raw-output '.jwks_uri')

# get certificates
JWKS=$(curl --silent $JWKS_URI)

# place certificates in object for OPA data
cat opa/auth/data.json | jq --arg f "$JWKS" '.jwks = $f'

