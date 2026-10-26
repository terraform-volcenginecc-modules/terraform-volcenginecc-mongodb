# Complete MongoDB Example

## 1. Overview

This example creates a private, three-zone sharded MongoDB cluster with two shards, Mongos and ConfigServer sizing, a read-only node, SSL, separate application and operations allowlists, and a database-scoped application account.

## 2. Usage

Provide existing network IDs, three availability zones, region-valid node specifications, trusted private CIDRs, and all account passwords:

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. Examples

The runnable configuration covers a sharded cluster, account/database authorization, and private access. A replica set is shown by the basic example. Backup restore is a separate creation mode: set `restore.source_instance_id` and exactly one of `restore.backup_id` or `restore.restore_time`; do not combine backup-set restore with `ShardedCluster`.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| `volcengine/volcenginecc` | `>= 0.0.71` |

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Description |
|---|---|
| MongoDB module | Sharded cluster, allowlists, accounts, database privileges, parameters, and SSL state. |

## 7. Inputs

| Name | Description |
|---|---|
| `region` | Volcengine region. |
| `instance_name` | MongoDB instance name. |
| `vpc_id` | Existing VPC ID. |
| `subnet_id` | Existing subnet ID. |
| `zone_ids` | Three availability zones. |
| `db_engine_version` | MongoDB engine version. |
| `shard_node_spec` | Shard node specification. |
| `mongos_node_spec` | Mongos node specification. |
| `config_server_node_spec` | ConfigServer node specification. |
| `shard_number` | Number of shards. |
| `shard_storage_space_gb` | Storage per shard. |
| `application_cidrs` | Trusted application CIDRs. |
| `operations_cidrs` | Trusted operations CIDRs. |
| `application_database_name` | Database used by account grants. |
| `application_account_name` | Read-write account name. |
| `application_account_password` | Read-write account password. |
| `root_password` | Root password. |
| `project_name` | Volcengine project. |

## 8. Outputs

| Name | Description |
|---|---|
| `instance_id` | MongoDB instance ID. |
| `private_endpoint` | Private connection string. |
| `managed_allow_list_ids` | Managed allowlist IDs. |
| `account_names` | Managed account names. |
| `ssl` | SSL status. |

## 9. Notes

- MongoDB databases are created on first write. Provider 0.0.71 has no standalone MongoDB database resource; this example manages database-scoped account privileges.
- Provider 0.0.71 reports backups and recoverable ranges but has no MongoDB backup-policy or manual-backup resource. Restore creates a new instance from an existing source.
- The Provider accepts IPv4 allowlists but not security-group IDs. The caller must manage the application security groups and align their permitted clients with these CIDRs.
- No public endpoint or EIP is created.
- Passwords exist in Terraform state. Use encrypted remote state with tightly restricted access.
