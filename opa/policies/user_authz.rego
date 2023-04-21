package user_authz

import data.user_data

# Define a default deny policy for all requests
default allow = false

# Allow admins to perform any action on any user data
allow {
    user_data.is_admin == true
}

# Allow users to read their own data
allow {
    user_data.user_id == input.user_id
    input.http_method == "GET"
}

# Allow users to update their own data
allow {
    user_data.user_id == input.user_id
    input.http_method == "PUT"
}

# Allow users to create new data
allow {
    input.http_method == "POST"
    input.path == ["users"]
}

# Allow users to delete their own data
allow {
    user_data.user_id == input.user_id
    input.http_method == "DELETE"
}

# Allow admins to read, modify or write any user data
allow {
    user_data.is_admin == true
    input.http_method == "GET"  # Read any user data
    input.http_method == "PUT"  # Modify any user data
    input.http_method == "POST" # Write new user data
}

# Define the structure of the user data
# This should be provided by the calling API
# Example:
# {
#     "user_id": "abc123",
#     "is_admin": false,
#     "username": "jdoe",
#     "password": "password",
#     "name": "John",
#     "surname": "Doe",
#     "phone": "555-555-5555"
# }
input user_data {
    user_id: string
    is_admin: bool
    username: string
    password: string
    name: string
    surname: string
    phone: string
}

# Define the structure of the input data
# This should be provided by the calling API
# Example:
# {
#     "user_id": "abc123",
#     "http_method": "GET",
#     "path": ["users", "abc123"]
# }
input input {
    user_id: string
    http_method: string
    path: [string]
}
