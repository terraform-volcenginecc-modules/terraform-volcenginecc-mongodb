# MongoDB 基础示例

## 1. 概述

本示例创建一个私网、单可用区 MongoDB 副本集实例，适合内容、用户画像、订单扩展字段和 IoT 数据等文档型负载。

## 2. 用法

需提供已有 VPC、子网、可信应用 CIDR、当前地域可用的节点规格以及 root 密码：

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. 示例

这是最小副本集场景。VPC、子网和应用安全组仍是调用方管理的依赖资源。

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
| MongoDB Module | 副本集实例、IPv4 白名单、root 账号配置和 SSL 状态。 |

## 7. 输入

| 名称 | 说明 |
|---|---|
| `region` | 火山引擎地域。 |
| `instance_name` | MongoDB 实例名称。 |
| `vpc_id` | 已有 VPC ID。 |
| `subnet_id` | 已有子网 ID。 |
| `zone_id` | 子网所在可用区。 |
| `node_spec` | 当前地域可用的 MongoDB 节点规格。 |
| `storage_space_gb` | 存储容量，单位 GiB。 |
| `application_cidrs` | 可信私网客户端 CIDR。 |
| `root_password` | 敏感的 root 密码。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `instance_id` | MongoDB 实例 ID。 |
| `private_endpoint` | 私网连接字符串。 |
| `allow_list_ids` | 已关联白名单 ID。 |
| `ssl` | SSL 状态。 |

## 9. 注意事项

- MongoDB Provider 资源接受 IPv4 白名单，但不接受安全组 ID。调用方应限制应用安全组，并把对应的私网 CIDR 传给 `application_cidrs`。
- 本示例不创建公网 Endpoint 或 EIP。
- 凭据和密码必须通过安全的 Terraform 输入方式提供，并会存在于 Terraform State 中。
