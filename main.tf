locals {
  managed_allow_list_ids = toset([
    for allow_list in volcenginecc_mongodb_allow_list.this : allow_list.allow_list_id
  ])
  effective_allow_list_ids = setunion(var.allow_list_ids, local.managed_allow_list_ids)
}

resource "volcenginecc_mongodb_allow_list" "this" {
  for_each = var.allow_lists

  allow_list          = each.value.ip_addresses
  allow_list_category = each.value.category
  allow_list_desc     = each.value.description
  allow_list_name     = each.value.name
  allow_list_type     = "IPv4"
  project_name        = var.project_name
}

resource "volcenginecc_mongodb_instance" "this" {
  allow_list_ids         = length(local.effective_allow_list_ids) == 0 ? null : local.effective_allow_list_ids
  auto_renew             = var.auto_renew
  backup_id              = var.restore == null ? null : var.restore.backup_id
  backup_type            = var.restore == null ? null : var.restore.backup_type
  charge_type            = var.charge_type
  db_engine              = "MongoDB"
  db_engine_version      = var.db_engine_version
  instance_name          = var.instance_name
  instance_type          = var.instance_type
  node_number            = var.node_number
  node_spec              = var.node_spec
  period                 = var.period
  period_unit            = var.period_unit
  project_name           = var.project_name
  restore_time           = var.restore == null ? null : var.restore.restore_time
  src_db_instance_id     = var.restore == null ? null : var.restore.source_instance_id
  storage_space_gb       = var.storage_space_gb
  subnet_id              = var.subnet_id
  super_account_name     = "root"
  super_account_password = var.root_password
  vpc_id                 = var.vpc_id
  zone_id                = join(",", var.zone_ids)

  config_server_node_spec        = var.sharded_cluster == null ? null : var.sharded_cluster.config_server_node_spec
  config_server_storage_space_gb = var.sharded_cluster == null ? null : var.sharded_cluster.config_server_storage_space_gb
  mongos_node_number             = var.sharded_cluster == null ? null : var.sharded_cluster.mongos_node_number
  mongos_node_spec               = var.sharded_cluster == null ? null : var.sharded_cluster.mongos_node_spec
  shard_number                   = var.sharded_cluster == null ? null : var.sharded_cluster.shard_number

  instance_parameters = length(var.instance_parameters) == 0 ? null : [
    for name, parameter in var.instance_parameters : {
      parameter_name  = name
      parameter_role  = parameter.role
      parameter_value = parameter.value
    }
  ]

  node_availability_zone = length(var.read_only_nodes) == 0 ? null : [
    for node in var.read_only_nodes : {
      node_number = node.node_number
      zone_id     = node.zone_id
    }
  ]

  tags = length(var.tags) == 0 ? null : [
    for key, value in var.tags : {
      key   = key
      value = value
    }
  ]

  lifecycle {
    ignore_changes = [instance_parameters]

    precondition {
      condition     = (var.instance_type == "ShardedCluster") == (var.sharded_cluster != null)
      error_message = "sharded_cluster must be set exactly when instance_type is ShardedCluster."
    }

    precondition {
      condition     = var.charge_type == "Prepaid" ? (var.period != null && var.period_unit != null) : (var.period == null && var.period_unit == null && !var.auto_renew)
      error_message = "Prepaid instances require period and period_unit; PostPaid instances must omit them and disable auto_renew."
    }

    precondition {
      condition     = var.restore == null || ((try(var.restore.backup_id, null) != null) != (try(var.restore.restore_time, null) != null))
      error_message = "restore must specify exactly one of backup_id or restore_time."
    }

    precondition {
      condition     = var.restore == null || try(var.restore.backup_id, null) == null || var.instance_type == "ReplicaSet"
      error_message = "The Provider supports backup-set restore only for ReplicaSet instances."
    }

    precondition {
      condition = (
        length(setsubtract(toset(keys(var.accounts)), toset(keys(nonsensitive(var.account_passwords))))) == 0 &&
        length(setsubtract(toset(keys(nonsensitive(var.account_passwords))), toset(keys(var.accounts)))) == 0
      )
      error_message = "accounts and account_passwords must have identical keys."
    }
  }
}

resource "volcenginecc_mongodb_account" "this" {
  for_each = var.accounts

  depends_on = [volcenginecc_mongodb_ssl_state.this]

  account_desc     = each.value.description
  account_name     = each.value.name
  account_password = var.account_passwords[each.key]
  auth_db          = each.value.auth_db
  instance_id      = volcenginecc_mongodb_instance.this.instance_id

  account_privileges = [
    for privilege in each.value.privileges : {
      db_name   = privilege.database_name
      role_name = privilege.role_name
    }
  ]

  lifecycle {
    ignore_changes = [account_password]
  }
}

resource "volcenginecc_mongodb_ssl_state" "this" {
  count = var.enable_ssl ? 1 : 0

  instance_id = volcenginecc_mongodb_instance.this.instance_id
  ssl_action  = "Open"
}
