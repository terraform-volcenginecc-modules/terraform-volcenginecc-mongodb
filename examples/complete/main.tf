provider "volcenginecc" {
  region = var.region
}

module "mongodb" {
  source  = "terraform-volcenginecc-modules/mongodb/volcenginecc"
  version = "~> 1.0"

  instance_name     = var.instance_name
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  zone_ids          = var.zone_ids
  instance_type     = "ShardedCluster"
  db_engine_version = var.db_engine_version
  node_spec         = var.shard_node_spec
  node_number       = 3
  storage_space_gb  = var.shard_storage_space_gb
  root_password     = var.root_password
  project_name      = var.project_name
  enable_ssl        = true

  sharded_cluster = {
    shard_number                   = var.shard_number
    mongos_node_number             = 2
    mongos_node_spec               = var.mongos_node_spec
    config_server_node_spec        = var.config_server_node_spec
    config_server_storage_space_gb = 20
  }

  read_only_nodes = [
    {
      zone_id     = var.zone_ids[0]
      node_number = 1
    }
  ]

  instance_parameters = {
    "operationProfiling.mode" = {
      role  = "Shard"
      value = "slowOp"
    }
  }

  allow_lists = {
    application = {
      name         = "${var.instance_name}-application"
      description  = "Private application clients"
      ip_addresses = var.application_cidrs
    }
    operations = {
      name         = "${var.instance_name}-operations"
      description  = "Private operations clients"
      ip_addresses = var.operations_cidrs
    }
  }

  accounts = {
    application = {
      name        = var.application_account_name
      auth_db     = "admin"
      description = "Application read-write account"
      privileges = [
        {
          database_name = var.application_database_name
          role_name     = "readWrite"
        }
      ]
    }
  }

  account_passwords = {
    application = var.application_account_password
  }

  tags = {
    Environment = "production-example"
    Scenario    = "sharded-document-store"
  }
}
