# terraform-volcenginecc-mongodb

## 1. Overview

Terraform module for a managed Volcengine MongoDB document database using the `volcenginecc` provider. It targets semi-structured content, user-profile, order-extension, and IoT workloads.

The module manages one replica-set or sharded-cluster instance, IPv4 allowlists, database-scoped accounts, instance parameters, and SSL state. The caller owns provider configuration, VPC, subnet, application security groups, and any existing allowlists passed by ID.

## 2. Usage

```hcl
module "mongodb" {
  source  = "terraform-volcenginecc-modules/mongodb/volcenginecc"
  version = "~> 1.0"

  instance_name   = "content-documents"
  vpc_id           = "vpc-example"
  subnet_id        = "subnet-example"
  zone_ids         = ["cn-beijing-a"]
  node_spec        = "mongo.example"
  storage_space_gb = 100
  root_password    = var.mongodb_root_password

  allow_lists = {
    application = {
      name         = "content-application"
      ip_addresses = ["10.20.0.0/24"]
    }
  }
}
```

Provider authentication and region configuration must be supplied by the caller.

## 3. Examples

- **Replica set:** the basic configuration creates a private single-zone replica set for moderate content, profile, order-extension, or IoT workloads.
- **Sharded cluster:** the complete configuration uses three availability zones, multiple shards, Mongos and ConfigServer sizing, a read-only node, and instance parameters.
- **Accounts and databases:** the complete configuration grants a read-write role for an application database. MongoDB creates the database on first write; Provider 0.0.71 has no standalone MongoDB database resource.
- **Backup restore:** set `restore.source_instance_id` and exactly one of `restore.backup_id` or `restore.restore_time` to create a new restored instance. Backup-set restore is limited to replica sets by the Provider.
- **Private access:** all examples use an existing VPC and subnet, expose only the private endpoint, and restrict clients with IPv4 allowlists. Application security groups remain caller-owned.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| `volcengine/volcenginecc` | `>= 0.0.71` |

Provider 0.0.71 is required because it adds MongoDB backup metadata, recoverable time, and restore-to-new-instance fields.

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Description |
|---|---|
| `volcenginecc_mongodb_instance.this` | Replica-set or sharded-cluster MongoDB instance. |
| `volcenginecc_mongodb_allow_list.this` | IPv4 allowlists keyed by stable logical names. |
| `volcenginecc_mongodb_account.this` | Accounts with database-scoped privileges. |
| `volcenginecc_mongodb_ssl_state.this` | Optional SSL enablement state. |

## 7. Inputs

| Name | Required | Description |
|---|---:|---|
| `instance_name` | Yes | MongoDB instance name. |
| `vpc_id` | Yes | Existing VPC ID. |
| `subnet_id` | Yes | Existing subnet ID. |
| `zone_ids` | Yes | One or three availability zones. |
| `node_spec` | Yes | Replica-set or shard node specification. |
| `storage_space_gb` | Yes | Storage in positive 10 GiB increments. |
| `root_password` | Yes | Sensitive root password. |
| `instance_type` | No | `ReplicaSet` or `ShardedCluster`; default `ReplicaSet`. |
| `db_engine_version` | No | MongoDB engine version; default `MongoDB_7_0`. |
| `node_number` | No | Compute nodes per replica set or shard; default `3`. |
| `sharded_cluster` | No | Shard, Mongos, and ConfigServer configuration. |
| `read_only_nodes` | No | Read-only node counts by availability zone. |
| `allow_list_ids` | No | Existing allowlist IDs associated at instance creation. |
| `allow_lists` | No | Module-managed IPv4 allowlists. |
| `accounts` | No | Accounts and database privileges keyed by stable names. |
| `account_passwords` | No | Sensitive passwords keyed exactly like `accounts`. |
| `instance_parameters` | No | Parameters keyed by parameter name. |
| `restore` | No | Source instance plus backup ID or point-in-time restore value. |
| `enable_ssl` | No | Enable SSL; default `true`. |
| `charge_type` | No | `PostPaid` or `Prepaid`; default `PostPaid`. |
| `period` | No | Prepaid duration. |
| `period_unit` | No | `Month` or `Year`. |
| `auto_renew` | No | Prepaid auto-renewal. |
| `project_name` | No | Volcengine project; default `default`. |
| `tags` | No | Instance tags as a string map. |

## 8. Outputs

| Name | Description |
|---|---|
| `instance_id` | MongoDB instance ID. |
| `instance_name` | Cloud-returned instance name. |
| `instance_type` | Cloud-returned architecture. |
| `instance_status` | Current instance status. |
| `private_endpoint` | Private MongoDB connection string. |
| `allow_list_ids` | All associated allowlist IDs. |
| `managed_allow_list_ids` | Managed allowlist IDs keyed by logical name. |
| `account_names` | Managed account names keyed by logical name. |
| `ssl` | SSL enablement and certificate status. |

## 9. Notes

- Changing `vpc_id`, `subnet_id`, `zone_ids`, architecture, engine version, node count, root password, project, billing settings, source/backup/restore-time fields, or creation-time allowlist IDs replaces the instance under Provider 0.0.71.
- Managed allowlist map keys and account map keys are Terraform resource identities. Renaming a key destroys and recreates that child resource.
- Provider 0.0.71 returns every default MongoDB parameter when any parameter is configured. The module applies `instance_parameters` during creation and ignores later diffs to prevent perpetual drift; recreate the instance to change parameters until the Provider fixes partial-set read-back.
- The Provider's latest recoverable time advances continuously, so it is intentionally not exported as a Terraform output. Query the MongoDB API when a current restore window is needed.
- Backup records transition state and rotate automatically, so they are also intentionally not exported as Terraform outputs. Query the MongoDB API for current backup policy and records.
- Root and account passwords are write-only but are not marked sensitive by the Provider schema. This module marks inputs sensitive, but values still exist in Terraform state.
- Account passwords are applied during account creation and ignored on later plans because Provider 0.0.71 cannot read them back. Rotate a managed account password outside this module or recreate the account with a new map key.
- Provider 0.0.71 cannot delete an account whose authentication database is not `admin`; the module therefore validates `accounts[*].auth_db = "admin"`. Database privileges may still target application databases.
- Provider 0.0.71 has no MongoDB backup-policy, manual-backup, or standalone database resource. It only reports backup metadata and supports restore-to-new-instance.
- The MongoDB allowlist resource does not accept security-group IDs. Keep application security-group rules and MongoDB CIDRs aligned outside this module.
- Import is available for underlying Provider resources, but adopting an existing instance and all child resources requires separate imports into their exact module addresses.
