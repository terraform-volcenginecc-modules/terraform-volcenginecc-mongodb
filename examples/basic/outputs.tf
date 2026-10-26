output "instance_id" {
  description = "ID of the MongoDB instance."
  value       = module.mongodb.instance_id
}

output "private_endpoint" {
  description = "Private MongoDB connection string."
  value       = module.mongodb.private_endpoint
}

output "allow_list_ids" {
  description = "IDs of allowlists associated with the instance."
  value       = module.mongodb.allow_list_ids
}

output "ssl" {
  description = "MongoDB SSL status."
  value       = module.mongodb.ssl
}
