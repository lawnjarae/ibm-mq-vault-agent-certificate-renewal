# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

path "auth/token/create" {  
  capabilities = ["create", "update"]  
}


########## Permissions to handle all Approle related operations
path "sys/mounts/auth/mq" {
  capabilities = ["read"]
}

path "auth/mq/role/*" {
  capabilities = ["read", "list"]
}

# Grant permissions for creating SecretIDs for the specific role
path "auth/mq/role/mq-role/secret-id" {
  capabilities = ["create", "update"]
}

# To read SecretID accessors:
path "auth/mq/role/mq-role/secret-id-accessor" {
  capabilities = ["read", "list"]
}

# Allow lookup of SecretID accessors
path "auth/mq/role/mq-role/secret-id-accessor/*" {
  capabilities = ["read", "list", "update", "delete"]
}

# Configure the actual secrets the token should have access to
path "secret/*" {
  capabilities = ["read"]
}
