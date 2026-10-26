variable "region" {
  type        = string
  description = "Volcengine region for this example."
  default     = "cn-beijing"
}

variable "instance_name" {
  type        = string
  description = "Name of the sharded MongoDB instance."
  default     = "mongodb-complete-example"
}

variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC."
}

variable "subnet_id" {
  type        = string
  description = "ID of an existing subnet in the first availability zone."
}

variable "zone_ids" {
  type        = list(string)
  description = "Exactly three availability zones for the sharded cluster."

  validation {
    condition     = length(var.zone_ids) == 3
    error_message = "zone_ids must contain exactly three availability zones."
  }
}

variable "db_engine_version" {
  type        = string
  description = "MongoDB engine version."
  default     = "MongoDB_7_0"
}

variable "shard_node_spec" {
  type        = string
  description = "Region-valid specification code for shard nodes."
}

variable "mongos_node_spec" {
  type        = string
  description = "Region-valid specification code for Mongos nodes."
}

variable "config_server_node_spec" {
  type        = string
  description = "Region-valid specification code for ConfigServer nodes."
  default     = "mongo.config.1c2g"
}

variable "shard_number" {
  type        = number
  description = "Number of shards."
  default     = 2
}

variable "shard_storage_space_gb" {
  type        = number
  description = "Storage per shard in GiB, in increments of 10."
  default     = 100
}

variable "application_cidrs" {
  type        = set(string)
  description = "Trusted private application IPv4 addresses or CIDRs."
}

variable "operations_cidrs" {
  type        = set(string)
  description = "Trusted private operations IPv4 addresses or CIDRs."
}

variable "application_database_name" {
  type        = string
  description = "Application database used in account privilege grants. MongoDB creates it on first write."
  default     = "application"
}

variable "application_account_name" {
  type        = string
  description = "Application read-write account name."
  default     = "app_rw"
}

variable "application_account_password" {
  type        = string
  description = "Application account password."
  sensitive   = true
}

variable "root_password" {
  type        = string
  description = "Root account password."
  sensitive   = true
}

variable "project_name" {
  type        = string
  description = "Volcengine project for the instance and allowlists."
  default     = "default"
}
