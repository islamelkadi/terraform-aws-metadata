# Terraform AWS Metadata Module

A Terraform module that generates standardized naming conventions and metadata for AWS resources. This module helps maintain consistent resource naming across your AWS infrastructure by providing prefixes, paths, and abbreviated codes based on your organization structure, project, environment, region, and resource type.

## Overview

This module is designed to be used as a foundational component in other Terraform modules. It takes organizational metadata as input and outputs standardized naming patterns that can be used for:

- Resource naming (S3 buckets, IAM roles, Lambda functions, etc.)
- IAM paths
- Tagging strategies
- Resource organization

## Key Features

- **Standardized Naming**: Generates consistent resource prefixes in the format `organization-project-environment-resourcetype`
- **Region Abbreviations**: Converts AWS region names to short codes (e.g., `us-east-1` → `use1`)
- **Resource Type Codes**: Provides abbreviated codes for common AWS resource types
- **Path Generation**: Creates hierarchical paths for IAM and other resources
- **Length Validation**: Ensures generated names don't exceed AWS naming limits (64 characters)
- **Organization Context**: Automatically retrieves AWS account ID and organization ID

## Usage

```hcl
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata"

  organization  = "myorg"
  project_name  = "myapp"
  environment   = "prod"
  region        = "us-east-1"
  resource_type = "lambda"

  additional_tags = {
    ManagedBy = "Terraform"
    Team      = "Platform"
  }
}

# Use the outputs in your resources
resource "aws_lambda_function" "example" {
  function_name = "${module.metadata.resource_prefix_with_region}-handler"
  # Results in: myorg-myapp-prod-use1-lambda-handler
  
  tags = merge(
    module.metadata.additional_tags,
    {
      Name = "${module.metadata.resource_prefix}-handler"
    }
  )
}
```

## Supported Environments

- `dev` - Development
- `test` - Testing
- `qa` - Quality Assurance
- `staging` - Staging
- `prod` - Production

## Supported Resource Types

The module validates and supports the following AWS resource types:

### Compute
- `lambda` - AWS Lambda functions
- `sfn` - AWS Step Functions state machines

### Storage
- `s3` - Amazon S3 buckets
- `dynamodb` - Amazon DynamoDB tables

### Database
- `rds` - Amazon RDS databases (including Aurora)
- `rds-proxy` - Amazon RDS Proxy

### Networking
- `vpc` - Amazon VPC
- `vpce` - VPC Endpoints
- `sg` - Security Groups
- `nacl` - Network ACLs
- `nat` - NAT Gateways

### Security & Identity
- `kms` - AWS KMS keys
- `secret` - AWS Secrets Manager secrets
- `iam-role` - IAM roles
- `iam-policy` - IAM policies
- `cognito-user-pool` - Amazon Cognito User Pools
- `cognito-user-pool-client` - Amazon Cognito User Pool Clients
- `cognito-user-pool-domain` - Amazon Cognito User Pool Domains
- `cognito-identity-pool` - Amazon Cognito Identity Pools

### Monitoring & Logging
- `logs` - CloudWatch Log Groups
- `alarm` - CloudWatch Alarms

### Integration
- `eventbridge-rule` - Amazon EventBridge Rules
- `sns` - Amazon SNS topics
- `sqs-queue` - Amazon SQS queues
- `apigateway` - Amazon API Gateway

### AI/ML
- `bedrock` - Amazon Bedrock agents and models

### Content Delivery
- `cloudfront` - Amazon CloudFront distributions

### Governance
- `config-aggregator` - AWS Config aggregators

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization"></a> [organization](#input\_organization) | The name of the organization to deploy the config aggregator. This is used for semantic organization. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | A unique name to assign for this project. This is used for semantic organization. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The name of the AWS region to deploy the config aggregator. | `string` | n/a | yes |
| <a name="input_resource_type"></a> [resource\_type](#input\_resource\_type) | The type of resource being created (e.g., lambda, s3, rds, etc.) | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment to deploy the config aggregator (dev, test, prod, etc). This is used for semantic organization. | `string` | `"dev"` | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Map of security controls to enable/disable across all modules | <pre>object({<br/>    # Encryption Controls<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool # Use customer-managed KMS keys (vs AWS-managed)<br/>      require_encryption_at_rest    = bool # Enforce encryption for all data stores<br/>      require_encryption_in_transit = bool # Enforce TLS 1.2+ for all connections<br/>      enable_kms_key_rotation       = bool # Auto-rotate KMS keys annually<br/>    })<br/><br/>    # Logging Controls<br/>    logging = object({<br/>      require_cloudwatch_logs = bool   # CloudWatch Logs for all compute<br/>      min_log_retention_days  = number # Minimum log retention (90 for NIST, 365 for PCI)<br/>      require_access_logging  = bool   # Access logs for S3, ALB, CloudFront<br/>      require_flow_logs       = bool   # VPC Flow Logs<br/>    })<br/><br/>    # Network Security Controls<br/>    network = object({<br/>      require_private_subnets = bool # Compute resources in private subnets<br/>      require_vpc_endpoints   = bool # Use VPC endpoints for AWS services<br/>      block_public_ingress    = bool # Block 0.0.0.0/0 ingress (except ALB/CloudFront)<br/>      require_imdsv2          = bool # Require IMDSv2 for EC2/ECS<br/>    })<br/><br/>    # IAM Controls<br/>    iam = object({<br/>      enforce_least_privilege  = bool # Validate IAM policies for least privilege<br/>      block_wildcard_resources = bool # Prohibit "*" in resource ARNs<br/>      require_mfa_for_humans   = bool # MFA required for console access<br/>      require_service_roles    = bool # Use service roles (no user credentials)<br/>    })<br/><br/>    # Data Protection Controls<br/>    data_protection = object({<br/>      require_versioning         = bool # S3 versioning required<br/>      require_mfa_delete         = bool # MFA Delete for production S3<br/>      require_automated_backups  = bool # Automated backups for databases<br/>      block_public_access        = bool # Block public access by default<br/>      require_lifecycle_policies = bool # Lifecycle policies for data retention<br/>    })<br/><br/>    # Monitoring Controls<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool # X-Ray tracing for Lambda/Step Functions<br/>      enable_enhanced_monitoring  = bool # Enhanced monitoring for RDS<br/>      enable_performance_insights = bool # Performance Insights for RDS<br/>      require_cloudtrail          = bool # CloudTrail for audit logging<br/>    })<br/><br/>    # High Availability Controls<br/>    high_availability = object({<br/>      require_multi_az           = bool # Multi-AZ for databases<br/>      require_multi_az_nat       = bool # Multi-AZ NAT Gateways<br/>      enable_cross_region_backup = bool # Cross-region backup replication<br/>    })<br/><br/>    # Compliance Controls<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool # PITR for DynamoDB<br/>      require_reserved_concurrency  = bool # Reserved concurrency for Lambda<br/>      enable_deletion_protection    = bool # Deletion protection for critical resources<br/>    })<br/>  })</pre> | <pre>{<br/>  "compliance": {<br/>    "enable_deletion_protection": false,<br/>    "enable_point_in_time_recovery": true,<br/>    "require_reserved_concurrency": false<br/>  },<br/>  "data_protection": {<br/>    "block_public_access": true,<br/>    "require_automated_backups": true,<br/>    "require_lifecycle_policies": true,<br/>    "require_mfa_delete": false,<br/>    "require_versioning": true<br/>  },<br/>  "encryption": {<br/>    "enable_kms_key_rotation": true,<br/>    "require_encryption_at_rest": true,<br/>    "require_encryption_in_transit": true,<br/>    "require_kms_customer_managed": true<br/>  },<br/>  "high_availability": {<br/>    "enable_cross_region_backup": false,<br/>    "require_multi_az": false,<br/>    "require_multi_az_nat": false<br/>  },<br/>  "iam": {<br/>    "block_wildcard_resources": true,<br/>    "enforce_least_privilege": true,<br/>    "require_mfa_for_humans": true,<br/>    "require_service_roles": true<br/>  },<br/>  "logging": {<br/>    "min_log_retention_days": 365,<br/>    "require_access_logging": true,<br/>    "require_cloudwatch_logs": true,<br/>    "require_flow_logs": true<br/>  },<br/>  "monitoring": {<br/>    "enable_enhanced_monitoring": true,<br/>    "enable_performance_insights": true,<br/>    "enable_xray_tracing": true,<br/>    "require_cloudtrail": true<br/>  },<br/>  "network": {<br/>    "block_public_ingress": true,<br/>    "require_imdsv2": true,<br/>    "require_private_subnets": true,<br/>    "require_vpc_endpoints": true<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | The AWS organization ID. |
| <a name="output_region_code"></a> [region\_code](#output\_region\_code) | The AWS region code (abbreviated). |
| <a name="output_region_name"></a> [region\_name](#output\_region\_name) | The AWS region name. |
| <a name="output_resource_path"></a> [resource\_path](#output\_resource\_path) | The resource path in format: /organization/project/environment/resourcetype/ |
| <a name="output_resource_path_with_region"></a> [resource\_path\_with\_region](#output\_resource\_path\_with\_region) | The resource path with region in format: /organization/project/environment/region/resourcetype/ |
| <a name="output_resource_prefix"></a> [resource\_prefix](#output\_resource\_prefix) | The resource prefix in format: organization-project-environment-resourcetype |
| <a name="output_resource_prefix_with_region"></a> [resource\_prefix\_with\_region](#output\_resource\_prefix\_with\_region) | The resource prefix with region in format: organization-project-environment-region-resourcetype |
| <a name="output_resource_type_code"></a> [resource\_type\_code](#output\_resource\_type\_code) | The resource type code (abbreviated). |
| <a name="output_security_controls"></a> [security\_controls](#output\_security\_controls) | Security controls configuration |
| <a name="output_security_posture"></a> [security\_posture](#output\_security\_posture) | Summary of enabled security controls |
| <a name="output_security_tags"></a> [security\_tags](#output\_security\_tags) | Security-related tags to apply to all resources |
<!-- END_TF_DOCS -->
