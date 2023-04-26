package self_service.filters

import future.keywords.contains
import future.keywords.if
import future.keywords.in


test_phone_writable if {
    allow_write with input as "phone"
}

test_fax_not_writable if {
    not allow_write with input as "fax"
}

test_allow_writes if {
    allow_writes with input as ["country", "fax", "phone"] == ["country", "phone"]
}

test_user_data_attribute_values if {
    user_data_attribute_values
        with input as { "country": "NL", "fax": "1234", "phone": "4321" }
        == { "country": "NL", "phone": "4321" }
}

