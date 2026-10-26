variable "region" {
  type        = string
  description = "Volcengine region for this example."
  default     = "cn-beijing"
}

variable "instance_name" {
  type        = string
  description = "Name of the replica-set MongoDB instance."
  default     = "mongodb-basic-example"
}

variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC."
}

variable "subnet_id" {
  type        = string
  description = "ID of an existing subnet in zone_id."
}

variable "zone_id" {
  type        = string
  description = "Availability zone for the MongoDB instance."
}

variable "node_spec" {
  type        = string
  description = "MongoDB replica-set node specification code available in the selected region."
}

variable "storage_space_gb" {
  type        = number
  description = "Replica-set storage in GiB, in increments of 10."
  default     = 100
}

variable "application_cidrs" {
  type        = set(string)
  description = "Trusted private IPv4 addresses or CIDRs. Keep the application security group restricted to the same clients."
}

variable "root_password" {
  type        = string
  description = "Root account password."
  sensitive   = true
}
