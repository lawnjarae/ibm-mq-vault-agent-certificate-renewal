resource "vault_namespace" "demo_namespace" {
  path = "ibm_mq_clm"
}

resource "vault_mount" "kvv2" {
  namespace   = vault_namespace.demo_namespace.path_fq
  path        = "secret"
  type        = "kv-v2"
  description = "Key-Value v2 secrets engine"
}

resource "vault_kv_secret_v2" "qm1_kdb_password" {
  namespace = vault_namespace.demo_namespace.path_fq
  mount     = vault_mount.kvv2.path
  name      = "qmgrs/QM1"

  data_json = jsonencode({
    kdb_password     = "password-from-vault"
  })
}


resource "vault_policy" "mq_policy" {
  namespace = vault_namespace.demo_namespace.path_fq
  name      = "mq"

  policy = <<EOT
path "secret/data/qmgrs/QM1" {
  capabilities = ["read"]
}

path "postgres/creds/dev1" {
  capabilities = ["read"]
}

# Enable secrets engine
path "sys/mounts/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# List enabled secrets engine
path "sys/mounts" {
  capabilities = [ "read", "list" ]
}

# Work with pki secrets engine
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo", "patch" ]
}

EOT
}

# Create the AppRole auth mount on the path "mq"
resource "vault_auth_backend" "mq-approle" {
  namespace = vault_namespace.demo_namespace.path_fq
  type      = "approle"
  path      = "mq"
}

# Create the AppRole role and map our policy to it. This AppRole will not expire and
# has unlimited number of uses.
resource "vault_approle_auth_backend_role" "mq_role" {
  namespace          = vault_namespace.demo_namespace.path_fq
  backend            = vault_auth_backend.mq-approle.path
  role_name          = "mq-role"
  token_policies     = ["default", vault_policy.mq_policy.name, vault_policy.engine-policy.name]
  token_ttl          = "3600"
  token_max_ttl      = "43200"
  token_num_uses     = 0
  secret_id_num_uses = 0
  secret_id_ttl      = 0
}

# Create a secret id for the previously created role. 
resource "vault_approle_auth_backend_role_secret_id" "mq_secret_id" {
  namespace = vault_namespace.demo_namespace.path_fq
  backend   = vault_auth_backend.mq-approle.path
  role_name = vault_approle_auth_backend_role.mq_role.role_name
}

resource "local_file" "role_id_file" {
  content  = vault_approle_auth_backend_role.mq_role.role_id
  filename = "${path.module}/../agent/role-id.txt"
}

resource "local_file" "secret_id_file" {
  content  = vault_approle_auth_backend_role_secret_id.mq_secret_id.secret_id
  filename = "${path.module}/../agent/secret-id.txt"
}



# This was already commented out in the original code, but leaving it here for reference.
# resource "vault_auth_backend" "aws" {
#   namespace   = vault_namespace.demo_namespace.path_fq
#   type        = "aws"
#   description = "AWS Auth Method"
# }

# Requires Vault 1.17+
# resource "vault_aws_auth_backend_client" "example" {
#   namespace               = vault_namespace.demo_namespace.path_fq
#   identity_token_audience = "<TOKEN_AUDIENCE>"
#   identity_token_ttl      = ""
#   role_arn                = "arn:aws:iam::515812054002:role/aws_justin.jarae_test-admin"
# }

# resource "vault_aws_auth_backend_role" "example" {
#   namespace                = vault_namespace.demo_namespace.path_fq
#   backend                  = vault_auth_backend.aws.path
#   role                     = "mq-role"
#   auth_type                = "iam"
#   bound_iam_principal_arns = ["arn:aws:iam::515812054002:role/aws_justin.jarae_test-developer"]
#   token_policies           = ["default", "mq"]
#   token_ttl                = "60"
#   token_max_ttl            = "120"
# }