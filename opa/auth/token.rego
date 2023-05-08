package auth.token

import future.keywords.contains
import future.keywords.if
import future.keywords.in

import data.auth.jwks


# Verify a token's signature.
# Validates the `aud` claim.
#
# `input`: a dict, { "token": "string", "aud": "string" }
# returns: true/false
default token_valid := false
token_valid := true if {
    [valid, _, _] := io.jwt.decode_verify(
        input["token"],
        {
            "cert": jwks,
            "aud": input["aud"],
            "time": time.now_ns()
        }
    )
    valid
}


# Verify a token's signature and decode the content.
# Validates the `aud` claim.
#
# `input`: a dict, { "token": "string", "aud": "string" }
# returns: the payload of the token if the token is valid, undefined otherwise
decode_valid_token := payload if {
    [valid, _, payload] := io.jwt.decode_verify(
        input["token"],
        {
            "cert": jwks,
            "aud": input["aud"],
            "time": time.now_ns()
        }
    )
    valid
}
