#!/bin/sh

KEYCLOAK_BASE_URL=${KEYCLOAK_BASE_URL:-http://localhost:8097}
KEYCLOAK_REALM=ucs

JWKS_URI=$(curl --silent $KEYCLOAK_BASE_URL/realms/$KEYCLOAK_REALM/.well-known/openid-configuration \
          | jq --raw-output '.jwks_uri')

JWKS=$(curl --silent $JWKS_URI)

echo $JWKS
