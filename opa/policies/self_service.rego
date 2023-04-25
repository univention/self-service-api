package self_service

# Define a default deny policy for all requests
default allow = false

# Allow users get their attributes
allow {
    # input["e-mail"] != null
    input[0].editable = true
}


# Define the structure of the user data
# This should be provided by the calling API
# user_data {
#     jpegPhoto: string
#     "e-mail": [string]
#     phone:[string]
#     departmentNumber:[string]
#     country: string
#     homeTelephoneNumber: [string]
#     mobileTelephoneNumber: [string]
#     homePostalAddress:[[string]]
# }
