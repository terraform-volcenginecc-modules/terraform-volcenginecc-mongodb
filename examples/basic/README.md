# Basic MongoDB Example

## 1. Overview

This example creates a private, single-zone MongoDB replica-set instance for document-oriented workloads such as content, user profiles, order extensions, and IoT data.

## 2. Usage

Provide an existing VPC, subnet, trusted application CIDRs, a region-valid node specification, and the root password:

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 3. Examples

This is the minimum replica-set scenario. The VPC, subnet, and application security group remain caller-owned dependencies.

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
| MongoDB module | Replica-set instance, IPv4 allowlist, root account configuration, and SSL state. |

## 7. Inputs

| Name | Description |
|---|---|
| `region` | Volcengine region. |
| `instance_name` | MongoDB instance name. |
| `vpc_id` | Existing VPC ID. |
| `subnet_id` | Existing subnet ID. |
| `zone_id` | Subnet availability zone. |
| `node_spec` | Region-valid MongoDB node specification. |
| `storage_space_gb` | Storage in GiB. |
| `application_cidrs` | Trusted private client CIDRs. |
| `root_password` | Sensitive root password. |

## 8. Outputs

| Name | Description |
|---|---|
| `instance_id` | MongoDB instance ID. |
| `private_endpoint` | Private connection string. |
| `allow_list_ids` | Associated allowlist IDs. |
| `ssl` | SSL status. |

## 9. Notes

- The MongoDB Provider resource accepts IPv4 allowlists but not security-group IDs. Restrict the caller-owned application security group and pass matching private CIDRs to `application_cidrs`.
- No public endpoint or EIP is created.
- Credentials and passwords must be supplied through secure Terraform input mechanisms and will exist in Terraform state.
