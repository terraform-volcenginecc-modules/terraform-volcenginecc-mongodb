output "instance_id" {
  description = "ID of the MongoDB instance."
  value       = volcenginecc_mongodb_instance.this.instance_id
}

output "instance_name" {
  description = "Name of the MongoDB instance."
  value       = volcenginecc_mongodb_instance.this.instance_name
}

output "instance_type" {
  description = "MongoDB architecture returned by the cloud."
  value       = volcenginecc_mongodb_instance.this.instance_type
}

output "instance_status" {
  description = "Current MongoDB instance status."
  value       = volcenginecc_mongodb_instance.this.instance_status
}

output "private_endpoint" {
  description = "Private connection string returned by the MongoDB instance."
  value       = volcenginecc_mongodb_instance.this.private_endpoint
}

output "allow_list_ids" {
  description = "All allowlist IDs associated at instance creation."
  value       = local.effective_allow_list_ids
}

output "managed_allow_list_ids" {
  description = "IDs of allowlists managed by this module, keyed by the input map key."
  value = {
    for key, allow_list in volcenginecc_mongodb_allow_list.this : key => allow_list.allow_list_id
  }
}

output "account_names" {
  description = "Names of MongoDB accounts managed by this module, keyed by the input map key."
  value = {
    for key, account in volcenginecc_mongodb_account.this : key => account.account_name
  }
}

output "ssl" {
  description = "SSL status returned by the cloud, or null when SSL management is disabled."
  value = var.enable_ssl ? {
    enabled      = volcenginecc_mongodb_ssl_state.this[0].ssl_enable
    valid        = volcenginecc_mongodb_ssl_state.this[0].is_valid
    expired_time = volcenginecc_mongodb_ssl_state.this[0].ssl_expired_time
  } : null
}
