output "instance_id" {
  description = "ID of the sharded MongoDB instance."
  value       = module.mongodb.instance_id
}

output "private_endpoint" {
  description = "Private MongoDB connection string."
  value       = module.mongodb.private_endpoint
}

output "managed_allow_list_ids" {
  description = "Managed allowlist IDs keyed by logical name."
  value       = module.mongodb.managed_allow_list_ids
}

output "account_names" {
  description = "Managed account names keyed by logical name."
  value       = module.mongodb.account_names
}

output "ssl" {
  description = "MongoDB SSL status."
  value       = module.mongodb.ssl
}
