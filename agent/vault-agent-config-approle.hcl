pid_file = "/tmp/vault-agent-pid"

vault {
  address = "$VAULT_ADDR"
}

auto_auth {
  method "approle" {
    # namespace name that starts with "admin/" is required for HashiCorp Vault Dedicated 
    namespace = "admin/ibm_mq_clm"
    mount_path = "auth/mq"
    config = {
      role_id_file_path = "./role-id.txt"
      secret_id_file_path = "./secret-id.txt"

      # For production workloads, this value should be set to true to remove the 
      # secret_id file after reading it.
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "./vault-token-via-agent"
    }
  }
}

# This template will work when deployed on an MQ server with default install paths.
# template {
#   source      = "./get-certs-and-chain.ctmpl"
#   destination =  "/var/mqm/qmgrs/QM1/ssl/vault-agent-template-cache"
#   exec {
#     command = ["/opt/vault/vault-agent/update-qm.sh"]
#   }

  # Template for testing locally to ensure that you can connec to vault and retreive certificates
template {
  source      = "./get-certs-and-chain-local.ctmpl"
  destination =  "./template-cache"
  exec {
    command = ["echo", "Template rendered"]
  }
}