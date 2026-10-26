variable "instance_name" {
  type        = string
  description = "Name of the MongoDB instance."
  nullable    = false

  validation {
    condition     = length(var.instance_name) >= 2 && length(var.instance_name) <= 64 && can(regex("^[^0-9-][A-Za-z0-9_-]*$", var.instance_name))
    error_message = "instance_name must be 2-64 characters, must not start with a digit or hyphen, and may contain letters, digits, underscores, or hyphens."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC for private MongoDB access."
  nullable    = false
}

variable "subnet_id" {
  type        = string
  description = "ID of the existing subnet where the MongoDB instance is created."
  nullable    = false
}

variable "zone_ids" {
  type        = list(string)
  description = "One availability zone ID, or three zone IDs for a multi-zone deployment. The Provider sends these as a comma-separated value."
  nullable    = false

  validation {
    condition     = contains([1, 3], length(var.zone_ids)) && alltrue([for zone_id in var.zone_ids : trimspace(zone_id) != ""])
    error_message = "zone_ids must contain either one or three non-empty availability zone IDs."
  }
}

variable "instance_type" {
  type        = string
  description = "MongoDB architecture: ReplicaSet or ShardedCluster."
  default     = "ReplicaSet"
  nullable    = false

  validation {
    condition     = contains(["ReplicaSet", "ShardedCluster"], var.instance_type)
    error_message = "instance_type must be ReplicaSet or ShardedCluster."
  }
}

variable "db_engine_version" {
  type        = string
  description = "MongoDB engine version accepted by the Provider."
  default     = "MongoDB_7_0"
  nullable    = false

  validation {
    condition = contains([
      "MongoDB_4_0",
      "MongoDB_4_2",
      "MongoDB_4_4",
      "MongoDB_5_0",
      "MongoDB_6_0",
      "MongoDB_7_0",
      "MongoDB_8_0",
      "MongoDB_8_3",
    ], var.db_engine_version)
    error_message = "db_engine_version must be a MongoDB version exposed by volcenginecc 0.0.71."
  }
}

variable "node_spec" {
  type        = string
  description = "Compute specification code for replica-set nodes or sharded-cluster shard nodes."
  nullable    = false

  validation {
    condition     = trimspace(var.node_spec) != ""
    error_message = "node_spec must not be empty."
  }
}

variable "node_number" {
  type        = number
  description = "Compute-node count for a replica set, or node count in each shard."
  default     = 3
  nullable    = false

  validation {
    condition     = var.node_number >= 1 && floor(var.node_number) == var.node_number
    error_message = "node_number must be a positive integer."
  }
}

variable "storage_space_gb" {
  type        = number
  description = "Storage in GiB for a replica set, or for each shard. The service requires increments of 10 GiB."
  nullable    = false

  validation {
    condition     = var.storage_space_gb > 0 && var.storage_space_gb % 10 == 0
    error_message = "storage_space_gb must be a positive multiple of 10."
  }
}

variable "sharded_cluster" {
  type = object({
    shard_number                   = number
    mongos_node_number             = number
    mongos_node_spec               = string
    config_server_node_spec        = optional(string, "mongo.config.1c2g")
    config_server_storage_space_gb = optional(number, 20)
  })
  description = "Sharded-cluster settings. Set this exactly when instance_type is ShardedCluster."
  default     = null

  validation {
    condition = var.sharded_cluster == null ? true : (
      var.sharded_cluster.shard_number >= 2 &&
      var.sharded_cluster.shard_number <= 32 &&
      floor(var.sharded_cluster.shard_number) == var.sharded_cluster.shard_number &&
      var.sharded_cluster.mongos_node_number >= 2 &&
      var.sharded_cluster.mongos_node_number <= 32 &&
      floor(var.sharded_cluster.mongos_node_number) == var.sharded_cluster.mongos_node_number &&
      var.sharded_cluster.config_server_storage_space_gb > 0 &&
      var.sharded_cluster.config_server_storage_space_gb % 10 == 0
    )
    error_message = "shard_number and mongos_node_number must be integers from 2 through 32, and config-server storage must be a positive multiple of 10 GiB."
  }
}

variable "read_only_nodes" {
  type = list(object({
    zone_id     = string
    node_number = number
  }))
  description = "Read-only node counts by availability zone. Each replica set or shard supports at most five read-only nodes."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for node in var.read_only_nodes :
      trimspace(node.zone_id) != "" &&
      node.node_number >= 1 &&
      node.node_number <= 5 &&
      floor(node.node_number) == node.node_number
    ])
    error_message = "Each read_only_nodes entry must use a non-empty zone_id and an integer node_number from 1 through 5."
  }
}

variable "root_password" {
  type        = string
  description = "Password for the root account. It is stored in Terraform state because the Provider models it as an instance property."
  sensitive   = true
  nullable    = false

  validation {
    condition = (
      length(var.root_password) >= 8 &&
      length(var.root_password) <= 32 &&
      can(regex("^[A-Za-z0-9_#!@$%^&*()+=-]+$", var.root_password)) &&
      (
        (can(regex("[A-Z]", var.root_password)) ? 1 : 0) +
        (can(regex("[a-z]", var.root_password)) ? 1 : 0) +
        (can(regex("[0-9]", var.root_password)) ? 1 : 0) +
        (can(regex("[_#!@$%^&*()+=-]", var.root_password)) ? 1 : 0)
      ) >= 3
    )
    error_message = "root_password must be 8-32 characters from letters, digits, or _#!@$%^&*()+=-, and contain at least three character classes."
  }
}

variable "allow_list_ids" {
  type        = set(string)
  description = "Existing MongoDB allowlist IDs to associate when the instance is created. Changing this set replaces the instance in Provider 0.0.71."
  default     = []
  nullable    = false
}

variable "allow_lists" {
  type = map(object({
    name         = string
    ip_addresses = set(string)
    description  = optional(string)
    category     = optional(string, "Ordinary")
  }))
  description = "IPv4 allowlists managed by this module. Map keys are stable Terraform identities."
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for allow_list in values(var.allow_lists) :
      length(allow_list.ip_addresses) > 0 &&
      !contains(allow_list.ip_addresses, "0.0.0.0/0") &&
      contains(["Ordinary", "Default"], allow_list.category)
    ])
    error_message = "Each allowlist must contain at least one IPv4 address or CIDR, must not contain 0.0.0.0/0, and must use category Ordinary or Default."
  }
}

variable "accounts" {
  type = map(object({
    name        = string
    auth_db     = string
    description = optional(string)
    privileges = set(object({
      database_name = string
      role_name     = string
    }))
  }))
  description = "MongoDB accounts and database privileges managed by this module. Map keys are stable Terraform identities."
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for account in values(var.accounts) :
      trimspace(account.name) != "" &&
      account.auth_db == "admin" &&
      length(account.privileges) > 0 &&
      alltrue([
        for privilege in account.privileges :
        trimspace(privilege.database_name) != "" && trimspace(privilege.role_name) != ""
      ])
    ])
    error_message = "Each account requires a name, auth_db set to admin, and at least one complete database privilege."
  }
}

variable "account_passwords" {
  type        = map(string)
  description = "Passwords keyed exactly like accounts. Values are stored in Terraform state because the Provider models them as account properties."
  default     = {}
  sensitive   = true
  nullable    = false

  validation {
    condition = alltrue([
      for password in values(var.account_passwords) :
      length(password) >= 8 &&
      length(password) <= 32 &&
      can(regex("^[A-Za-z0-9_#!@$%^&*()+=-]+$", password)) &&
      (
        (can(regex("[A-Z]", password)) ? 1 : 0) +
        (can(regex("[a-z]", password)) ? 1 : 0) +
        (can(regex("[0-9]", password)) ? 1 : 0) +
        (can(regex("[_#!@$%^&*()+=-]", password)) ? 1 : 0)
      ) >= 3
    ])
    error_message = "Each account password must be 8-32 characters from letters, digits, or _#!@$%^&*()+=-, and contain at least three character classes."
  }
}

variable "instance_parameters" {
  type = map(object({
    role  = string
    value = string
  }))
  description = "MongoDB parameters keyed by parameter name. Role is one of Node, Shard, ConfigServer, or Mongos."
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for parameter in values(var.instance_parameters) :
      contains(["Node", "Shard", "ConfigServer", "Mongos"], parameter.role)
    ])
    error_message = "Each instance parameter role must be Node, Shard, ConfigServer, or Mongos."
  }
}

variable "restore" {
  type = object({
    source_instance_id = string
    backup_id          = optional(string)
    restore_time       = optional(string)
    backup_type        = optional(string)
  })
  description = "Create a new instance from an existing source instance using exactly one backup ID or UTC restore time. Source, backup ID, and restore time are create-only."
  default     = null

  validation {
    condition = var.restore == null ? true : (
      trimspace(var.restore.source_instance_id) != "" &&
      (var.restore.backup_type == null ? true : contains(["Physical", "Logical"], var.restore.backup_type))
    )
    error_message = "restore.source_instance_id must not be empty and backup_type, when set, must be Physical or Logical."
  }
}

variable "enable_ssl" {
  type        = bool
  description = "Whether to enable SSL encryption through a managed MongoDB SSL-state resource."
  default     = true
  nullable    = false
}

variable "charge_type" {
  type        = string
  description = "Billing type: PostPaid or Prepaid."
  default     = "PostPaid"
  nullable    = false

  validation {
    condition     = contains(["PostPaid", "Prepaid"], var.charge_type)
    error_message = "charge_type must be PostPaid or Prepaid."
  }
}

variable "period" {
  type        = number
  description = "Prepaid duration. Use 1-9 for months or 1-3 for years."
  default     = null

  validation {
    condition     = var.period == null ? true : (var.period >= 1 && var.period <= 9 && floor(var.period) == var.period)
    error_message = "period must be null or an integer from 1 through 9."
  }
}

variable "period_unit" {
  type        = string
  description = "Prepaid duration unit: Month or Year."
  default     = null

  validation {
    condition     = var.period_unit == null ? true : contains(["Month", "Year"], var.period_unit)
    error_message = "period_unit must be null, Month, or Year."
  }
}

variable "auto_renew" {
  type        = bool
  description = "Whether to enable automatic renewal for a prepaid instance."
  default     = false
  nullable    = false
}

variable "project_name" {
  type        = string
  description = "Volcengine project for the instance and managed allowlists."
  default     = "default"
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the MongoDB instance."
  default     = {}
  nullable    = false
}
