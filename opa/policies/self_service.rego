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
# user_attribute_values {
#     jpegPhoto: string
#     "e-mail": [string]
#     phone:[string]
#     departmentNumber:[string]
#     country: string
#     homeTelephoneNumber: [string]
#     mobileTelephoneNumber: [string]
#     homePostalAddress:[[string]]
# }

# Define the structure of the user available fields
# This should be provided by the calling API
# user_attribute_descriptions {[{
#     id:string
#     label: string
#     description: string
#     syntax: string
#     size: string
#     required: bool
#     editable: bool
#     readonly: bool
#     multivalue: bool
#     type: string
#     staticValues: [{
#         id: string
#         label: string
#     }]
#     subtypes: [{
#         type: string
#         dynamicValues: []
#         dynamicValuesInfo: []
#         dynamicOptions: []
#         staticValues: []
#         size: string
#         label: string
#         depends: []
#     }]
# }]}
