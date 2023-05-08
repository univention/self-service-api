package self_service.filters

import future.keywords

test_validate_user_attributes if {
	result := validate_user_attributes with input as {"options": {"attributes": {"country": "DE", "bad_attribute": "should_not_be_set"}}}
		with data.self_service.mappings.config.writeable_keys as ["country"]
	result == {"country"}
}

test_set_user_attributes if {
	result := set_user_attributes with input as {"options": {"attributes": {"country": "DE", "bad_attribute": "should_not_be_set"}}}
		with data.self_service.mappings.config.writeable_keys as ["country"]
	result == {"options": {"attributes": {"country": "DE"}}}
}
