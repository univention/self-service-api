package self_service.filters

import future.keywords.contains
import future.keywords.every
import future.keywords.if
import future.keywords.in

import data.self_service.mappings.config.readable_keys
import data.self_service.mappings.config.writeable_keys

user_data_attribute_values[key] := value if {
	some key
	value := input[key]
	some writeable_key in writeable_keys
	key == writeable_key
}

user_data_attribute_values[key] := value if {
	some key
	value := input[key]
	some readable_key in readable_keys
	key == readable_key
}

user_data_attribute_descriptions contains output if {
	some i
	value := input[i]

	# Ensure non readable items are filtered out
	value.id in readable_keys
	output := {
		"description": value.description,
		"id": value.id,
		"label": value.label,
		"required": value.required,
		"size": value.size,
		"syntax": value.syntax,
		"editable": is_editable(value.id),
		"readonly": is_readonly(value.id),
		"multivalue": value.multivalue,
		"type": value.type,
		"staticValues": value.staticValues,
		"subtypes": [v | some v in value.subtypes],
	}
}

validate_user_attributes := {
	"result": validate_user_attributes_result,
	"message": sprintf("%d errors occurred", [count(_invalid_user_attributes)]),
	"error": "",
	"reason": "",
	"status": 200,
}

validate_user_attributes_result[key] := value if {
	some key
	input.options.attributes[key]

	value := {
		"isValid": is_editable(key),
		"message": _validate_user_attribute_message(is_editable(key)),
	}
}

_invalid_user_attributes contains key if {
	input.options.attributes[key]
	not is_editable(key)
}

_validate_user_attribute_message(writable) := "" if writable

_validate_user_attribute_message(writable) := "Not writable" if not writable

set_user_attributes := {"options": {"attributes": set_user_attributes_inner}}

set_user_attributes_inner[key] := value if {
	some key
	value := input.options.attributes[key]
	is_editable(key)
}

# Check if an item is editable based on if it can be written
is_editable(id) = editable if {
	editable := id in writeable_keys
}

# Check if an item is readonly based on if it can be readed but not written
is_readonly(id) = readonly if {
	id in readable_keys
	not id in writeable_keys
	readonly := true
}

is_readonly(id) = readonly if {
	not id in readable_keys
	readonly := false
}

is_readonly(id) = readonly if {
	id in writeable_keys
	readonly := false
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
