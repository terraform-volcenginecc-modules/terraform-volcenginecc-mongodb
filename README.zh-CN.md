# terraform-volcenginecc-mongodb

## 1. 概述

本模块使用 `volcenginecc` Provider 创建和管理火山引擎 MongoDB 文档数据库，适合内容、用户画像、订单扩展字段和 IoT 数据等半结构化数据场景。

模块管理一个副本集或分片集群实例、IPv4 白名单、数据库级账号权限、实例参数和 SSL 状态。Provider 配置、VPC、子网、应用安全组以及通过 ID 传入的已有白名单由调用方管理。

## 2. 用法

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

Provider 认证和地域配置必须由调用方提供。

## 3. 示例

- **副本集：** basic 配置创建私网单可用区副本集，适合中等规模的内容、画像、订单扩展字段或 IoT 负载。
- **分片集群：** complete 配置使用三个可用区、多个分片、Mongos 与 ConfigServer 规格、只读节点和实例参数。
- **账号数据库：** complete 配置为应用数据库授予读写角色。MongoDB 在首次写入时创建数据库；Provider 0.0.71 没有独立 MongoDB 数据库资源。
- **备份恢复：** 设置 `restore.source_instance_id`，并在 `restore.backup_id` 和 `restore.restore_time` 中恰好选择一个，以创建新的恢复实例。Provider 仅支持副本集按备份集恢复。
- **私网访问：** 所有示例使用已有 VPC 和子网，只暴露私网 Endpoint，并通过 IPv4 白名单限制客户端。应用安全组由调用方管理。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.0` |
| `volcengine/volcenginecc` | `>= 0.0.71` |

最低要求 Provider 0.0.71，因为该版本新增 MongoDB 备份元数据、可恢复时间和恢复到新实例字段。

## 5. Provider

| 名称 | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| `volcenginecc_mongodb_instance.this` | 副本集或分片集群 MongoDB 实例。 |
| `volcenginecc_mongodb_allow_list.this` | 使用稳定逻辑名称管理的 IPv4 白名单。 |
| `volcenginecc_mongodb_account.this` | 具有数据库级权限的账号。 |
| `volcenginecc_mongodb_ssl_state.this` | 可选的 SSL 启用状态。 |

## 7. 输入

| 名称 | 必填 | 说明 |
|---|---:|---|
| `instance_name` | 是 | MongoDB 实例名称。 |
| `vpc_id` | 是 | 已有 VPC ID。 |
| `subnet_id` | 是 | 已有子网 ID。 |
| `zone_ids` | 是 | 一个或三个可用区。 |
| `node_spec` | 是 | 副本集或 Shard 节点规格。 |
| `storage_space_gb` | 是 | 以 10 GiB 为步长的正数存储容量。 |
| `root_password` | 是 | 敏感的 root 密码。 |
| `instance_type` | 否 | `ReplicaSet` 或 `ShardedCluster`，默认 `ReplicaSet`。 |
| `db_engine_version` | 否 | MongoDB 引擎版本，默认 `MongoDB_7_0`。 |
| `node_number` | 否 | 每个副本集或分片的计算节点数，默认 `3`。 |
| `sharded_cluster` | 否 | Shard、Mongos 和 ConfigServer 配置。 |
| `read_only_nodes` | 否 | 按可用区设置只读节点数量。 |
| `allow_list_ids` | 否 | 创建实例时关联的已有白名单 ID。 |
| `allow_lists` | 否 | 模块管理的 IPv4 白名单。 |
| `accounts` | 否 | 使用稳定名称管理的账号和数据库权限。 |
| `account_passwords` | 否 | 与 `accounts` 完全同键的敏感密码。 |
| `instance_parameters` | 否 | 按参数名管理的实例参数。 |
| `restore` | 否 | 源实例以及备份 ID 或时间点恢复值。 |
| `enable_ssl` | 否 | 是否启用 SSL，默认 `true`。 |
| `charge_type` | 否 | `PostPaid` 或 `Prepaid`，默认 `PostPaid`。 |
| `period` | 否 | 预付费时长。 |
| `period_unit` | 否 | `Month` 或 `Year`。 |
| `auto_renew` | 否 | 预付费自动续费。 |
| `project_name` | 否 | 火山引擎项目，默认 `default`。 |
| `tags` | 否 | 字符串 Map 格式的实例标签。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `instance_id` | MongoDB 实例 ID。 |
| `instance_name` | 云端返回的实例名称。 |
| `instance_type` | 云端返回的架构。 |
| `instance_status` | 当前实例状态。 |
| `private_endpoint` | MongoDB 私网连接字符串。 |
| `allow_list_ids` | 全部已关联白名单 ID。 |
| `managed_allow_list_ids` | 按逻辑名称返回的模块管理白名单 ID。 |
| `account_names` | 按逻辑名称返回的模块管理账号。 |
| `ssl` | SSL 启用和证书状态。 |

## 9. 注意事项

- 在 Provider 0.0.71 下，修改 `vpc_id`、`subnet_id`、`zone_ids`、实例架构、引擎版本、节点数、root 密码、项目、计费设置、源实例/备份/恢复时间字段或创建时白名单 ID 会替换实例。
- 白名单和账号的 Map Key 是 Terraform 资源身份；修改 Key 会销毁并重建对应子资源。
- Provider 0.0.71 在配置任一 MongoDB 参数后会回读全部默认参数。模块在创建时应用 `instance_parameters`，并忽略后续差异以避免持续漂移；在 Provider 修复部分集合回读前，修改参数需要重建实例。
- Provider 返回的最晚可恢复时间会持续前移，因此模块有意不将其导出为 Terraform Output；需要当前恢复窗口时应查询 MongoDB API。
- 备份记录会自动变更状态并定期轮换，因此模块同样不将其导出为 Terraform Output；当前备份策略和记录应通过 MongoDB API 查询。
- Provider Schema 中的 root 和账号密码是 write-only，但未标记为 sensitive。本模块将输入标记为敏感，但密码仍会存在于 Terraform State 中。
- 账号密码在创建账号时应用；由于 Provider 0.0.71 无法回读，后续 Plan 会忽略密码差异。轮换密码需在模块外执行，或使用新的 Map Key 重建账号。
- Provider 0.0.71 无法删除认证库不是 `admin` 的账号，因此模块校验 `accounts[*].auth_db = "admin"`；数据库权限仍可指向应用数据库。
- Provider 0.0.71 没有 MongoDB 备份策略、手工备份或独立数据库资源，只能返回备份元数据并支持恢复到新实例。
- MongoDB 白名单资源不接受安全组 ID。应在模块外保持应用安全组规则和 MongoDB CIDR 一致。
- 底层 Provider 资源支持 Import，但接管已有实例及全部子资源时，必须分别导入到准确的 Module 资源地址。
