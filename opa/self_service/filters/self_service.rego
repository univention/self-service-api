package self_service.filters

import future.keywords.contains
import future.keywords.every
import future.keywords.if
import future.keywords.in

import data.mappings.self_service.config.accessible_keys

user_data_attribute_values[filtered] {
    # filtered := {k: x[k]}
    # filtered := {
    #   "jpegPhoto": x["jpegPhoto"],
    #   "e-mail": x["e-mail"],
    #   "phone": x["phone"],
    #   "departmentNumber": x["departmentNumber"],
    #   "country": x["country"],
    #   "homeTelephoneNumber": x["homeTelephoneNumber"],
    #   "mobileTelephoneNumber": x["mobileTelephoneNumber"],
    #   "homePostalAddress": x["homePostalAddress"]
    # }
    # filtered := accessible_keys
    filtered := { k:v |
        k = accessible_keys[i]
        v := input[k]
    }
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
