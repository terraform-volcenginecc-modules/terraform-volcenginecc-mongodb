# MongoDB 完整示例

## 1. 概述

本示例创建一个私网、三可用区 MongoDB 分片集群，包含两个分片、Mongos 和 ConfigServer 规格、只读节点、SSL、独立的应用与运维白名单，以及一个数据库级应用账号。

## 2. 用法

需提供已有网络 ID、三个可用区、当前地域可用的节点规格、可信私网 CIDR 和全部账号密码：

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. 示例

可运行配置覆盖分片集群、账号数据库授权和私网访问；副本集由 basic 示例展示。备份恢复是独立的创建模式：设置 `restore.source_instance_id`，并在 `restore.backup_id` 与 `restore.restore_time` 中恰好选择一个；备份集恢复不能与 `ShardedCluster` 组合。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.0` |
| `volcengine/volcenginecc` | `>= 0.0.71` |

## 5. Provider

| 名称 | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| MongoDB Module | 分片集群、白名单、账号、数据库权限、参数和 SSL 状态。 |

## 7. 输入

| 名称 | 说明 |
|---|---|
| `region` | 火山引擎地域。 |
| `instance_name` | MongoDB 实例名称。 |
| `vpc_id` | 已有 VPC ID。 |
| `subnet_id` | 已有子网 ID。 |
| `zone_ids` | 三个可用区。 |
| `db_engine_version` | MongoDB 引擎版本。 |
| `shard_node_spec` | Shard 节点规格。 |
| `mongos_node_spec` | Mongos 节点规格。 |
| `config_server_node_spec` | ConfigServer 节点规格。 |
| `shard_number` | 分片数量。 |
| `shard_storage_space_gb` | 每个分片的存储容量。 |
| `application_cidrs` | 可信应用 CIDR。 |
| `operations_cidrs` | 可信运维 CIDR。 |
| `application_database_name` | 账号授权使用的数据库。 |
| `application_account_name` | 读写账号名称。 |
| `application_account_password` | 读写账号密码。 |
| `root_password` | root 密码。 |
| `project_name` | 火山引擎项目。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `instance_id` | MongoDB 实例 ID。 |
| `private_endpoint` | 私网连接字符串。 |
| `managed_allow_list_ids` | 模块管理的白名单 ID。 |
| `account_names` | 模块管理的账号名称。 |
| `ssl` | SSL 状态。 |

## 9. 注意事项

- MongoDB 数据库在首次写入时创建。Provider 0.0.71 没有独立 MongoDB 数据库资源，本示例管理数据库级账号权限。
- Provider 0.0.71 可返回备份和可恢复时间范围，但没有 MongoDB 备份策略或手工备份资源。恢复操作会基于已有源实例创建新实例。
- Provider 接受 IPv4 白名单，但不接受安全组 ID。调用方必须管理应用安全组，并使安全组允许的客户端与这些 CIDR 对齐。
- 本示例不创建公网 Endpoint 或 EIP。
- 密码会存在于 Terraform State 中，应使用加密且严格限制访问的远端 State。
