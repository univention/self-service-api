package auth.token

import future.keywords.contains
import future.keywords.if
import future.keywords.in


# *** Signing: private key ***

# JSON Web Key Set (public and private key)
private_key := {
    "keys": [
        {
            "kty": "EC",
            "d": "SjEpoLOWw25HOS0295aSStMXlilrFPpCl7M0YyJlYVA",
            "use": "sig",
            "crv": "P-256",
            "kid": "sig-1682689806",
            "x": "oIZm56fLU74PmWrigBAcM3FWLyl2vaIlcNckDiFZ3Yo",
            "y": "3_W1Pg7XrI63_rMZk99rHjGk1OuUkRaActZ3_vyVvTA",
            "alg": "ES256"
        }
    ]
}

# X.509 PEM Format (not useable in OPA!)
# private_key := "-----BEGIN PRIVATE KEY-----\nMEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCBKMSmgs5bDbkc5LTb3\nlpJK0xeWKWsU+kKXszRjImVhUA==\n-----END PRIVATE KEY-----\n"


# *** Verifying: public key ***

# Option 1: JWKS string
public_key := `{
    "keys": [
        {
            "kty": "EC",
            "use": "sig",
            "crv": "P-256",
            "kid": "sig-1682689806",
            "x": "oIZm56fLU74PmWrigBAcM3FWLyl2vaIlcNckDiFZ3Yo",
            "y": "3_W1Pg7XrI63_rMZk99rHjGk1OuUkRaActZ3_vyVvTA",
            "alg": "ES256"
        }
    ]
}`

# Option 2: Self-signed certificate
# public_key := "-----BEGIN CERTIFICATE-----\nMIIBIjCByqADAgECAgYBh8gg0Z4wCgYIKoZIzj0EAwIwGTEXMBUGA1UEAwwOc2ln\nLTE2ODI2ODk4MDYwHhcNMjMwNDI4MTM1MDA2WhcNMjQwMjIyMTM1MDA2WjAZMRcw\nFQYDVQQDDA5zaWctMTY4MjY4OTgwNjBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IA\nBKCGZueny1O+D5lq4oAQHDNxVi8pdr2iJXDXJA4hWd2K3/W1Pg7XrI63/rMZk99r\nHjGk1OuUkRaActZ3/vyVvTAwCgYIKoZIzj0EAwIDRwAwRAIgddG4+1IxBmSbaFkw\ntctDKd3LrxDemmZR/v9uQgt/YWECICNykguXxVUJmd6cNapU/uNo+hkP5+JYH64d\nMz6NEjF/\n-----END CERTIFICATE-----\n"

# Option 3: X.509 PEM format
# public_key := "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEoIZm56fLU74PmWrigBAcM3FWLyl2\nvaIlcNckDiFZ3Yrf9bU+Dtesjrf+sxmT32seMaTU65SRFoBy1nf+/JW9MA==\n-----END PUBLIC KEY-----\n"


# Dummy token for testing
token := io.jwt.encode_sign(
        {
            "typ": "JWT",
            "alg": "ES256"
        },
        {
            "iss": "test-issuer",
            "nbf": 1,
            "aud": ["valid-audience"],
            "roles": ["admin", "user"],
            "foo": "bar"
        },
        private_key
    )


# *** Test OPA functions ***

# Test: only verify the token's signature
test_jwt_verify if {
    io.jwt.verify_es256(token, public_key)
}

# Test: verify the signature, decode, and manually verify some claims
test_jwt_verify_decode if {
    io.jwt.verify_es256(token, public_key)
    [header, payload, _] := io.jwt.decode(token)
    "test-issuer" == payload.iss
    "admin" in payload.roles
}

# Test: verify the signature, decode, and verify all standard claims
test_jwt_decode_verify if {
    [valid, header, payload] := io.jwt.decode_verify(
        token,
        {
            "cert": public_key,
            # note: must verify the standard `aud` claim here!
            "aud": "valid-audience",
        })
    valid
}

# *** Test our own functions with Keycloak-issued tokens ***

test_token_valid if {
    token_valid
        with input as {
            "token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0akdSc2x0ZC1rZ0tBYzNNNzV3SEdsZ19fZ3p4OF9CTmtaeXpmZDBnYlJJIn0.eyJleHAiOjE2ODI3MTI1NDgsImlhdCI6MTY4MjcxMjI0OCwiYXV0aF90aW1lIjoxNjgyNzExOTQxLCJqdGkiOiIwNGE3NWQ1OS03NTU2LTRkNTctOTU1My1hYzQ5Yjg0YTA5OTkiLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwOTcvcmVhbG1zL3VjcyIsImF1ZCI6Im5vdGlmaWNhdGlvbnMtYXBpIiwic3ViIjoiZjoyMzMwZjMzOC1jMjdiLTRlZGUtODA2Zi0wYTNjYzRjYjc5NzM6QWRtaW5pc3RyYXRvciIsInR5cCI6IkJlYXJlciIsImF6cCI6InBvcnRhbC1mcm9udGVuZCIsIm5vbmNlIjoiOWRkNDU3MDgtZjcwOC00NzQzLTgyYzYtNGY0OWZlMzg2N2NlIiwic2Vzc2lvbl9zdGF0ZSI6IjNhNTUyZjUwLTI0NjktNGRjYi1iYmQzLTdkMzQ2MWQ0YWQ1YSIsImFjciI6IjAiLCJhbGxvd2VkLW9yaWdpbnMiOlsiaHR0cDovL2xvY2FsaG9zdDo4MDAwIl0sInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJzaWQiOiIzYTU1MmY1MC0yNDY5LTRkY2ItYmJkMy03ZDM0NjFkNGFkNWEiLCJlbnRyeXV1aWQiOiJiY2FlZDJiNC0yOWUyLTEwM2QtODA2Zi1iZmZjNjdhNmVhNTMiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5hbWUiOiJBZG1pbmlzdHJhdG9yIEFkbWluaXN0cmF0b3IiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJhZG1pbmlzdHJhdG9yIiwiZ2l2ZW5fbmFtZSI6IkFkbWluaXN0cmF0b3IiLCJmYW1pbHlfbmFtZSI6IkFkbWluaXN0cmF0b3IifQ.GOakKlJySODJpG7NbZZGi97RU8R4bcQFS_faRWttT21VEoUOPjeugFq3PHWGkVexAMlTm0lM1DKFbtP-2EksrcjxmrsaX5lhAVY8Q0xLzHytBcdiRIsMdKvV-4vpLgw1koAvsLHAwqPtz1M9B8o4ir4MBIPIbN_if2A_FL2vhzLaDDO1kWAybcDP9jGyJ2xSn0Dv9DFAoy_gNBM2HTPdXXVWA0bHc5u45WTAm4pQejxwSQvGXHulHKn5VrPPUWfBz7s__VfIv-1lBEJ5MQ6Ni6b3ohxjM9BSpYy1j3mNe7lT0seYx9EuSWCB7y3tSFB5rkyMQ_VSdYfCRsdHq2B2AA",
            "aud": "notifications-api"
        }
        with data.auth.jwks as `{"keys":[{"kid":"AUwEBa5JRYAHOFUNy9O4OfS3ClGmJyqldPVJ0Q7_nJw","kty":"RSA","alg":"RSA-OAEP","use":"enc","n":"roOObanlEqZO8fSvLoBrSnZ__CT7ouXUZ4dLNTT7QMDahP-3MqKLMaDr9rUoa7s83NETzuo_WifL4bP6GMPez-rMf2NIylqIYSqjILP5peNRUePDLqUPlvF_b7lagVq5dYnMxxaqKPl6mCTy_egBdIWjrMAGJEmgxYzr9ylyKjaIghRuXO9yD9eYXoAo9IfX0fDvFRu_G_3z1l53hCGOUThhhCqIT0d3Mm9126n9Q9IQnVMmPAXJQEEwTHn11fGuosrCq-DytVfnURM11t6KjQUMbVYM3BjDr7_AN5-xaZsMrZU0dNDW_lI-LH_9uKkmZPrY4zUCkzsflA7cjlSTLw","e":"AQAB","x5c":["MIIClTCCAX0CBgGHyXJR8TANBgkqhkiG9w0BAQsFADAOMQwwCgYDVQQDDAN1Y3MwHhcNMjMwNDI4MTk1NzA1WhcNMzMwNDI4MTk1ODQ1WjAOMQwwCgYDVQQDDAN1Y3MwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCug45tqeUSpk7x9K8ugGtKdn/8JPui5dRnh0s1NPtAwNqE/7cyoosxoOv2tShruzzc0RPO6j9aJ8vhs/oYw97P6sx/Y0jKWohhKqMgs/ml41FR48MupQ+W8X9vuVqBWrl1iczHFqoo+XqYJPL96AF0haOswAYkSaDFjOv3KXIqNoiCFG5c73IP15hegCj0h9fR8O8VG78b/fPWXneEIY5ROGGEKohPR3cyb3Xbqf1D0hCdUyY8BclAQTBMefXV8a6iysKr4PK1V+dREzXW3oqNBQxtVgzcGMOvv8A3n7FpmwytlTR00Nb+Uj4sf/24qSZk+tjjNQKTOx+UDtyOVJMvAgMBAAEwDQYJKoZIhvcNAQELBQADggEBACrK8151EPGyFj06N1jMjAl7j3CvYRL4N0DWoKpd7KNjz4gRe+OtcTlGFhjqPFDtrrsgq1XD7LWb1VzJl2jK9NN5mqJpog3x2Jpc6qrkBfjUkddKzX85SjFt/gzf/qhSfntCPWTaE79VpklZ3pbQlv9kN6pVCW77gjD1rLfMdTdT3CF7Ja0+Jlnh3xfkDhO+turR42uAzaEN6z1lOo28/9xpio80ONGQl77AfXjblW3mqE+rF+sdmHq3IZfQxs4WukoLDKm6lJ1m9bh2xOLtTg+oGbnrKbrTBek29MZjU1MRA4sQ36ff4XtKqtzBztIgCrQOcvVRQBfmjiz38xtt+vs="],"x5t":"IP80FKVKHZemQ4lIxGFvGbDFe0o","x5t#S256":"1mOoQ3B-QEOn92x_hWmz9ScFTMIxrVg7hCz9G_QzJ5M"},{"kid":"4jGRsltd-kgKAc3M75wHGlg__gzx8_BNkZyzfd0gbRI","kty":"RSA","alg":"RS256","use":"sig","n":"j77M85qwrtdK-KqZcyhVETqACeNpgQZgsRMQtI-Q1yY8YAqGgpiofP_l9nngL2_waA3eNg3a7z_CwGC1PFARTNvch8oBvDobROpl5XCXyoB8zSicAGnA5HFQm1NwKN5MuXjUjw82dX6DD4Z3ovRuxOluBD2R93GADQ0-nw4c8CjkLxvYspCF8ZOjP-0i-4ymdY0kHMOblzcSO0ElknAgA43eotIeFXnSuOZSqC0YvyGKxb-2q7RDcKpKFPrvzF93xIWabslq5y-xczrlL3OteqnQlzPjR1736WSf-XPwOHtf-6GS6fUli2v8Jrpupm_RYTjccp5tCYg3ZN4y8c1xRw","e":"AQAB","x5c":["MIIClTCCAX0CBgGHyXJQ2jANBgkqhkiG9w0BAQsFADAOMQwwCgYDVQQDDAN1Y3MwHhcNMjMwNDI4MTk1NzA0WhcNMzMwNDI4MTk1ODQ0WjAOMQwwCgYDVQQDDAN1Y3MwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCPvszzmrCu10r4qplzKFUROoAJ42mBBmCxExC0j5DXJjxgCoaCmKh8/+X2eeAvb/BoDd42DdrvP8LAYLU8UBFM29yHygG8OhtE6mXlcJfKgHzNKJwAacDkcVCbU3Ao3ky5eNSPDzZ1foMPhnei9G7E6W4EPZH3cYANDT6fDhzwKOQvG9iykIXxk6M/7SL7jKZ1jSQcw5uXNxI7QSWScCADjd6i0h4VedK45lKoLRi/IYrFv7artENwqkoU+u/MX3fEhZpuyWrnL7FzOuUvc616qdCXM+NHXvfpZJ/5c/A4e1/7oZLp9SWLa/wmum6mb9FhONxynm0JiDdk3jLxzXFHAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAIlhqCwhoJ2hYc0KpDLW22bybf7tCpCiIFP/HFpJBL1U7zhElxugxU1WIEjzN2Inwf7mUsCkHa+fzbiam2654dyQHu2xxQT3Qc3Std009kAbUAvZInMXSHWnJgAQmp8I7qSd0gE8t8tZiQ3dUIvythiHyaM9CTutJvM42tyZAXb2ncaMEIh+Exjs6ofzFV1OeEwIGcALKbzakwhMnfe1aqnX3WusnhlV4Mx9ULlWanJPaRAIxsZL7OeLT3g5i9HE4g2I2J4rJCV6oF5f+WVF9es82S2CkQLj5iCs1+eS7yt/BIlO2OpN1ShOf+t7xbXU5YPbeVIjsVoNFmfYWoMho6c="],"x5t":"9KxIcapFN47G_Qdf3eS6vbqWxz4","x5t#S256":"EPNnLeHVoDeHPq8CbMoLuJ-2RDtJBBD79sEB4uAcEpk"}]}`
        with time.now_ns as 1682712348
}

test_token_valid if {
    payload := decode_valid_token
        with input as {
            "token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0akdSc2x0ZC1rZ0tBYzNNNzV3SEdsZ19fZ3p4OF9CTmtaeXpmZDBnYlJJIn0.eyJleHAiOjE2ODI3MTI1NDgsImlhdCI6MTY4MjcxMjI0OCwiYXV0aF90aW1lIjoxNjgyNzExOTQxLCJqdGkiOiIwNGE3NWQ1OS03NTU2LTRkNTctOTU1My1hYzQ5Yjg0YTA5OTkiLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwOTcvcmVhbG1zL3VjcyIsImF1ZCI6Im5vdGlmaWNhdGlvbnMtYXBpIiwic3ViIjoiZjoyMzMwZjMzOC1jMjdiLTRlZGUtODA2Zi0wYTNjYzRjYjc5NzM6QWRtaW5pc3RyYXRvciIsInR5cCI6IkJlYXJlciIsImF6cCI6InBvcnRhbC1mcm9udGVuZCIsIm5vbmNlIjoiOWRkNDU3MDgtZjcwOC00NzQzLTgyYzYtNGY0OWZlMzg2N2NlIiwic2Vzc2lvbl9zdGF0ZSI6IjNhNTUyZjUwLTI0NjktNGRjYi1iYmQzLTdkMzQ2MWQ0YWQ1YSIsImFjciI6IjAiLCJhbGxvd2VkLW9yaWdpbnMiOlsiaHR0cDovL2xvY2FsaG9zdDo4MDAwIl0sInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJzaWQiOiIzYTU1MmY1MC0yNDY5LTRkY2ItYmJkMy03ZDM0NjFkNGFkNWEiLCJlbnRyeXV1aWQiOiJiY2FlZDJiNC0yOWUyLTEwM2QtODA2Zi1iZmZjNjdhNmVhNTMiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5hbWUiOiJBZG1pbmlzdHJhdG9yIEFkbWluaXN0cmF0b3IiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJhZG1pbmlzdHJhdG9yIiwiZ2l2ZW5fbmFtZSI6IkFkbWluaXN0cmF0b3IiLCJmYW1pbHlfbmFtZSI6IkFkbWluaXN0cmF0b3IifQ.GOakKlJySODJpG7NbZZGi97RU8R4bcQFS_faRWttT21VEoUOPjeugFq3PHWGkVexAMlTm0lM1DKFbtP-2EksrcjxmrsaX5lhAVY8Q0xLzHytBcdiRIsMdKvV-4vpLgw1koAvsLHAwqPtz1M9B8o4ir4MBIPIbN_if2A_FL2vhzLaDDO1kWAybcDP9jGyJ2xSn0Dv9DFAoy_gNBM2HTPdXXVWA0bHc5u45WTAm4pQejxwSQvGXHulHKn5VrPPUWfBz7s__VfIv-1lBEJ5MQ6Ni6b3ohxjM9BSpYy1j3mNe7lT0seYx9EuSWCB7y3tSFB5rkyMQ_VSdYfCRsdHq2B2AA",
            "aud": "notifications-api"
        }
        with data.auth.jwks as `{"keys":[{"kid":"AUwEBa5JRYAHOFUNy9O4OfS3ClGmJyqldPVJ0Q7_nJw","kty":"RSA","alg":"RSA-OAEP","use":"enc","n":"roOObanlEqZO8fSvLoBrSnZ__CT7ouXUZ4dLNTT7QMDahP-3MqKLMaDr9rUoa7s83NETzuo_WifL4bP6GMPez-rMf2NIylqIYSqjILP5peNRUePDLqUPlvF_b7lagVq5dYnMxxaqKPl6mCTy_egBdIWjrMAGJEmgxYzr9ylyKjaIghRuXO9yD9eYXoAo9IfX0fDvFRu_G_3z1l53hCGOUThhhCqIT0d3Mm9126n9Q9IQnVMmPAXJQEEwTHn11fGuosrCq-DytVfnURM11t6KjQUMbVYM3BjDr7_AN5-xaZsMrZU0dNDW_lI-LH_9uKkmZPrY4zUCkzsflA7cjlSTLw","e":"AQAB","x5c":["MIIClTCCAX0CBgGHyXJR8TANBgkqhkiG9w0BAQsFADAOMQwwCgYDVQQDDAN1Y3MwHhcNMjMwNDI4MTk1NzA1WhcNMzMwNDI4MTk1ODQ1WjAOMQwwCgYDVQQDDAN1Y3MwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCug45tqeUSpk7x9K8ugGtKdn/8JPui5dRnh0s1NPtAwNqE/7cyoosxoOv2tShruzzc0RPO6j9aJ8vhs/oYw97P6sx/Y0jKWohhKqMgs/ml41FR48MupQ+W8X9vuVqBWrl1iczHFqoo+XqYJPL96AF0haOswAYkSaDFjOv3KXIqNoiCFG5c73IP15hegCj0h9fR8O8VG78b/fPWXneEIY5ROGGEKohPR3cyb3Xbqf1D0hCdUyY8BclAQTBMefXV8a6iysKr4PK1V+dREzXW3oqNBQxtVgzcGMOvv8A3n7FpmwytlTR00Nb+Uj4sf/24qSZk+tjjNQKTOx+UDtyOVJMvAgMBAAEwDQYJKoZIhvcNAQELBQADggEBACrK8151EPGyFj06N1jMjAl7j3CvYRL4N0DWoKpd7KNjz4gRe+OtcTlGFhjqPFDtrrsgq1XD7LWb1VzJl2jK9NN5mqJpog3x2Jpc6qrkBfjUkddKzX85SjFt/gzf/qhSfntCPWTaE79VpklZ3pbQlv9kN6pVCW77gjD1rLfMdTdT3CF7Ja0+Jlnh3xfkDhO+turR42uAzaEN6z1lOo28/9xpio80ONGQl77AfXjblW3mqE+rF+sdmHq3IZfQxs4WukoLDKm6lJ1m9bh2xOLtTg+oGbnrKbrTBek29MZjU1MRA4sQ36ff4XtKqtzBztIgCrQOcvVRQBfmjiz38xtt+vs="],"x5t":"IP80FKVKHZemQ4lIxGFvGbDFe0o","x5t#S256":"1mOoQ3B-QEOn92x_hWmz9ScFTMIxrVg7hCz9G_QzJ5M"},{"kid":"4jGRsltd-kgKAc3M75wHGlg__gzx8_BNkZyzfd0gbRI","kty":"RSA","alg":"RS256","use":"sig","n":"j77M85qwrtdK-KqZcyhVETqACeNpgQZgsRMQtI-Q1yY8YAqGgpiofP_l9nngL2_waA3eNg3a7z_CwGC1PFARTNvch8oBvDobROpl5XCXyoB8zSicAGnA5HFQm1NwKN5MuXjUjw82dX6DD4Z3ovRuxOluBD2R93GADQ0-nw4c8CjkLxvYspCF8ZOjP-0i-4ymdY0kHMOblzcSO0ElknAgA43eotIeFXnSuOZSqC0YvyGKxb-2q7RDcKpKFPrvzF93xIWabslq5y-xczrlL3OteqnQlzPjR1736WSf-XPwOHtf-6GS6fUli2v8Jrpupm_RYTjccp5tCYg3ZN4y8c1xRw","e":"AQAB","x5c":["MIIClTCCAX0CBgGHyXJQ2jANBgkqhkiG9w0BAQsFADAOMQwwCgYDVQQDDAN1Y3MwHhcNMjMwNDI4MTk1NzA0WhcNMzMwNDI4MTk1ODQ0WjAOMQwwCgYDVQQDDAN1Y3MwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCPvszzmrCu10r4qplzKFUROoAJ42mBBmCxExC0j5DXJjxgCoaCmKh8/+X2eeAvb/BoDd42DdrvP8LAYLU8UBFM29yHygG8OhtE6mXlcJfKgHzNKJwAacDkcVCbU3Ao3ky5eNSPDzZ1foMPhnei9G7E6W4EPZH3cYANDT6fDhzwKOQvG9iykIXxk6M/7SL7jKZ1jSQcw5uXNxI7QSWScCADjd6i0h4VedK45lKoLRi/IYrFv7artENwqkoU+u/MX3fEhZpuyWrnL7FzOuUvc616qdCXM+NHXvfpZJ/5c/A4e1/7oZLp9SWLa/wmum6mb9FhONxynm0JiDdk3jLxzXFHAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAIlhqCwhoJ2hYc0KpDLW22bybf7tCpCiIFP/HFpJBL1U7zhElxugxU1WIEjzN2Inwf7mUsCkHa+fzbiam2654dyQHu2xxQT3Qc3Std009kAbUAvZInMXSHWnJgAQmp8I7qSd0gE8t8tZiQ3dUIvythiHyaM9CTutJvM42tyZAXb2ncaMEIh+Exjs6ofzFV1OeEwIGcALKbzakwhMnfe1aqnX3WusnhlV4Mx9ULlWanJPaRAIxsZL7OeLT3g5i9HE4g2I2J4rJCV6oF5f+WVF9es82S2CkQLj5iCs1+eS7yt/BIlO2OpN1ShOf+t7xbXU5YPbeVIjsVoNFmfYWoMho6c="],"x5t":"9KxIcapFN47G_Qdf3eS6vbqWxz4","x5t#S256":"EPNnLeHVoDeHPq8CbMoLuJ-2RDtJBBD79sEB4uAcEpk"}]}`
        with time.now_ns as 1682712348

    payload.azp == "portal-frontend"
    payload.sub == "f:2330f338-c27b-4ede-806f-0a3cc4cb7973:Administrator"
}
