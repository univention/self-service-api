package self_service.filters

import future.keywords.contains
import future.keywords.every
import future.keywords.if
import future.keywords.in

import data.self_service.mappings.config.writeable_keys


# Checks if a key is in the list of writeable keys.
#
# `input`: a string, e.g. "phone"
# returns: true/false
default allow_write := false
allow_write := true if {
    some key in writeable_keys
    key == input
}


# Filters the given list of keys for writeable keys.
#
# `input`: a list of keys, e.g. ["phone", "fax"]
# returns: a filtered list of keys, e.g. ["phone"]
allow_writes contains key if {
    some key in input
    some writeable_key in writeable_keys
    key == writeable_key
}

# Filter the given map for writeable keys.
#
# `input`: a dictionary, e.g. {"phone": "1234567", "country": "NL"}
# returns: a filtered dictionary, containing only the keys which are writable
user_data_attribute_values[key] := value if {
    some key
    value := input[key]
    some writeable_key in writeable_keys
    key == writeable_key
}


user_data_attribute_descriptions contains field if {
    some field in input
    some writeable_key in writeable_keys
    field.id == writeable_key
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
