# Terraform AWS Metadata Module

A Terraform module that generates standardized naming conventions, security controls, and compliance tags for AWS resources. This module serves as the foundation for consistent resource management across your AWS infrastructure.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Features](#features)
- [Security](#security)
- [Usage](#usage)
- [Supported Environments](#supported-environments)
- [Supported Resource Types](#supported-resource-types)
- [Benefits](#benefits)
- [Region Configuration](#region-configuration)
- [Requirements](#requirements)
- [MCP Servers](#mcp-servers)

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Features

- **Standardized Naming**: Generates consistent resource prefixes in the format `organization-project-environment-resourcetype`
- **Security Profiles**: Environment-aware security controls (dev, staging, prod)
- **Compliance Support**: Built-in support for FCAC, PCI DSS, SOC2, HIPAA, ISO27001
- **Region Abbreviations**: Converts AWS region names to short codes (e.g., `us-east-1` → `use1`)
- **Resource Type Codes**: Provides abbreviated codes for common AWS resource types
- **Path Generation**: Creates hierarchical paths for IAM and other resources
- **Length Validation**: Ensures generated names don't exceed AWS naming limits (64 characters)
- **Organization Context**: Automatically retrieves AWS account ID and organization ID

## Security

### Security Controls

The `security_controls` output provides a comprehensive object with security settings organized by category:

- **encryption**: KMS, encryption at rest/transit, key rotation
- **logging**: CloudWatch Logs, retention, access logging, flow logs
- **network**: Private subnets, VPC endpoints, public access, IMDSv2
- **iam**: Least privilege, wildcard restrictions, MFA, service roles
- **data_protection**: Versioning, MFA delete, backups, public access, lifecycle
- **monitoring**: X-Ray, enhanced monitoring, Performance Insights, CloudTrail
- **high_availability**: Multi-AZ, cross-region backup
- **compliance**: PITR, reserved concurrency, deletion protection

### Using Security Controls in Modules

```hcl
# In a module (e.g., terraform-aws-s3)
module "metadata" {
  source = "../terraform-aws-metadata"
  
  organization  = var.namespace
  environment   = var.environment
  project_name  = var.name
  resource_type = "s3"
}

# Use security controls
locals {
  # Check if versioning is required
  versioning_required = module.metadata.security_controls.data_protection.require_versioning
  
  # Check if KMS customer-managed key is required
  kms_required = module.metadata.security_controls.encryption.require_kms_customer_managed
  
  # Get minimum log retention
  log_retention = module.metadata.security_controls.logging.min_log_retention_days
}

# Apply security tags
resource "aws_s3_bucket" "this" {
  bucket = module.metadata.resource_prefix
  
  tags = merge(
    module.metadata.security_tags,
    var.tags
  )
}
```

### Security Control Override Pattern

Modules should allow overriding security controls with justification:

```hcl
variable "security_control_overrides" {
  description = "Override specific security controls with documented justification"
  
  type = object({
    disable_versioning_requirement = optional(bool, false)
    disable_kms_requirement        = optional(bool, false)
    justification                  = optional(string, "")
  })
  
  default = {
    disable_versioning_requirement = false
    disable_kms_requirement        = false
    justification                  = ""
  }
}

locals {
  # Control is enforced UNLESS explicitly overridden
  versioning_required = module.metadata.security_controls.data_protection.require_versioning && 
                        !var.security_control_overrides.disable_versioning_requirement
}
```
## Overview

This module provides three core capabilities:

1. **Standardized Naming**: Consistent resource prefixes, paths, and abbreviated codes
2. **Security Controls**: Environment-aware security policies (dev/staging/prod)
3. **Compliance Tags**: Automated tagging for security and compliance frameworks

## Key Features

- **Standardized Naming**: Generates consistent resource prefixes in the format `organization-project-environment-resourcetype`
- **Security Profiles**: Environment-aware security controls (dev, staging, prod)
- **Compliance Support**: Built-in support for FCAC, PCI DSS, SOC2, HIPAA, ISO27001
- **Region Abbreviations**: Converts AWS region names to short codes (e.g., `us-east-1` → `use1`)
- **Resource Type Codes**: Provides abbreviated codes for common AWS resource types
- **Path Generation**: Creates hierarchical paths for IAM and other resources
- **Length Validation**: Ensures generated names don't exceed AWS naming limits (64 characters)
- **Organization Context**: Automatically retrieves AWS account ID and organization ID

## Quick Start

### Basic Usage (Naming Only)

```hcl
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata"

  namespace     = "myorg"
  project_name  = "myapp"
  environment   = "prod"
  region        = "us-east-1"
  resource_type = "lambda"
}

# Use the outputs in your resources
resource "aws_lambda_function" "example" {
  function_name = "${module.metadata.resource_prefix}-handler"
  # Results in: myorg-myapp-prod-lambda-handler
  
  tags = module.metadata.security_tags
}
```

### With Security Controls and Compliance

```hcl
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata"

  namespace     = "myorg"
  project_name  = "myapp"
  environment   = "prod"
  region        = "us-east-1"
  resource_type = "s3"

  # Optional: Override security profile
  security_profile = "prod"  # dev, staging, or prod

  # Optional: Specify compliance frameworks
  compliance_frameworks = ["FCAC", "PCI_DSS"]
}

# Use security controls in your modules
resource "aws_s3_bucket" "example" {
  bucket = module.metadata.resource_prefix
  
  tags = merge(
    module.metadata.security_tags,
    {
      Component = "STORAGE"
      Purpose   = "DATA_LAKE"
    }
  )
}

# Enforce versioning based on security controls
resource "aws_s3_bucket_versioning" "example" {
  count = module.metadata.security_controls.data_protection.require_versioning ? 1 : 0
  
  bucket = aws_s3_bucket.example.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```

## Security Profiles

The module provides three security profiles that automatically configure security controls based on your environment:

### Dev Profile

**Purpose**: Development and testing environments

**Characteristics**:
- Relaxed security controls for faster iteration
- Shorter log retention (7 days)
- Optional encryption with AWS-managed keys
- Single AZ deployments allowed
- Public access allowed for testing
- No deletion protection (easy teardown)

**Use cases**: Local development, feature branches, proof of concepts, cost optimization

### Staging Profile

**Purpose**: Pre-production testing and validation

**Characteristics**:
- Production-like security controls
- 90-day log retention
- Customer-managed KMS keys required
- Multi-AZ for databases
- Private subnets required
- Full monitoring enabled
- Deletion protection enabled

**Use cases**: Integration testing, performance testing, security testing, UAT environments

### Prod Profile

**Purpose**: Production workloads

**Characteristics**:
- Maximum security controls
- 365-day log retention (PCI DSS compliance)
- Customer-managed KMS keys required
- Multi-AZ for all critical resources
- Cross-region backups enabled
- MFA delete for S3
- Reserved Lambda concurrency
- Full monitoring and tracing

**Use cases**: Production applications, customer-facing services, regulated workloads, mission-critical systems

### Security Tags

The `security_tags` output provides standard security and compliance tags:

- **Organization**: Organization name (SCREAMING_SNAKE_CASE)
- **Project**: Project name (SCREAMING_SNAKE_CASE)
- **Environment**: Environment (DEV, STAGING, PROD)
- **Region**: Region code (USE1, EUW1, etc.)
- **ResourceType**: Resource type code (SCREAMING_SNAKE_CASE)
- **ManagedBy**: TERRAFORM
- **Repository**: CORPORATE_ACTIONS_ORCHESTRATOR
- **SecurityProfile**: DEV, STAGING, or PROD
- **DataClass**: CONFIDENTIAL, INTERNAL, or PUBLIC
- **ComplianceFrameworks**: Comma-separated list (FCAC, PCI_DSS, etc.)
- **ComplianceRequired**: TRUE (if frameworks specified)
- **AuditRequired**: TRUE (if frameworks specified)

## Usage

- `dev` - Development
- `test` - Testing
- `qa` - Quality Assurance
- `staging` - Staging
- `prod` - Production

## Supported Resource Types

The module supports a comprehensive set of AWS resource types with intuitive abbreviations. You can use either the full name or common aliases.

### Compute Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `lambda` | `lambda` | AWS Lambda function |
| `lambda-layer` | `layer` | Lambda layer |
| `sfn`, `step-functions` | `sfn` | Step Functions state machine |

### Storage Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `s3`, `s3-bucket` | `s3` | S3 bucket |

### Database Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `dynamodb`, `dynamodb-table` | `ddb` | DynamoDB table |
| `rds`, `rds-cluster` | `rds` | RDS database instance/cluster |
| `rds-proxy` | `rdsprx` | RDS Proxy |
| `aurora` | `aurora` | Aurora cluster |

### Networking Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `vpc` | `vpc` | Virtual Private Cloud |
| `subnet` | `subnet` | VPC Subnet |
| `sg`, `security-group` | `sg` | Security Group |
| `nacl` | `nacl` | Network ACL |
| `nat`, `nat-gateway` | `nat` | NAT Gateway |
| `vpce`, `vpc-endpoint` | `vpce` | VPC Endpoint |

### Security & Identity Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `kms`, `kms-key` | `kms` | KMS key |
| `secret`, `secrets-manager` | `secret` | Secrets Manager secret |
| `iam-role` | `role` | IAM role |
| `iam-policy` | `policy` | IAM policy |
| `iam-user` | `user` | IAM user |
| `iam-group` | `group` | IAM group |

### Identity Services (Cognito)

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `cognito-user-pool` | `userpool` | Cognito User Pool |
| `cognito-user-pool-client` | `upclient` | Cognito User Pool Client |
| `cognito-user-pool-domain` | `updomain` | Cognito User Pool Domain |
| `cognito-identity-pool` | `idpool` | Cognito Identity Pool |

### Monitoring & Logging Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `logs`, `log-group` | `logs` | CloudWatch Log Group |
| `alarm`, `cloudwatch-alarm` | `alarm` | CloudWatch Alarm |

### Integration Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `eventbridge` | `eb` | EventBridge bus |
| `eventbridge-rule` | `ebrule` | EventBridge rule |
| `sns`, `sns-topic` | `sns` | SNS topic |
| `sqs`, `sqs-queue` | `sqs` | SQS queue |
| `apigateway`, `api-gateway`, `apigw-rest` | `apigw` | API Gateway REST API |
| `apigw-http` | `httpapi` | API Gateway HTTP API |
| `apigw-websocket` | `wsapi` | API Gateway WebSocket API |

### AI/ML Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `bedrock` | `bedrock` | Bedrock agent/model |
| `bedrock-agent` | `agent` | Bedrock agent |
| `bedrock-kb` | `kb` | Bedrock knowledge base |

### Content Delivery Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `cloudfront`, `cloudfront-dist` | `cf` | CloudFront distribution |

### Governance & Management Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `config` | `config` | AWS Config |
| `config-aggregator` | `cfgagg` | Config aggregator |
| `config-rule` | `cfgrule` | Config rule |

### Application Services

| Resource Type | Abbreviation | Description |
|--------------|--------------|-------------|
| `app` | `app` | Generic application |

### Usage Examples

```hcl
# Lambda function
resource_type = "lambda"           # → acme-payments-prod-lambda

# DynamoDB table
resource_type = "dynamodb"         # → acme-payments-prod-ddb

# API Gateway (multiple aliases)
resource_type = "apigateway"       # → acme-payments-prod-apigw
resource_type = "api-gateway"      # → acme-payments-prod-apigw
resource_type = "apigw-rest"       # → acme-payments-prod-apigw

# Cognito User Pool
resource_type = "cognito-user-pool" # → acme-payments-prod-userpool
```

## Benefits

1. **Centralized Policy Management**: Security policies defined once, applied everywhere
2. **Environment-Aware**: Automatic security controls based on environment
3. **Compliance Support**: Built-in support for compliance frameworks
4. **Consistent Tagging**: Standard tags applied to all resources
5. **Audit Trail**: Override justifications documented in code
6. **Flexibility**: Can override controls when needed with justification
7. **Standardized Naming**: Consistent resource names across all infrastructure

## Region Configuration

The `region` variable is required for consistent resource naming and tagging across your infrastructure. While AWS provider configuration can auto-detect the region from credentials or environment variables, explicitly passing the region to this module ensures:

1. **CI/CD Pipeline Control**: In automated pipelines (GitHub Actions, GitLab CI, etc.) with Terragrunt or similar tools, you can explicitly control which region resources are deployed to
2. **Consistent Naming**: Region abbreviations (e.g., `us-east-1` → `use1`) are included in resource names and paths
3. **Multi-Region Deployments**: When deploying to multiple regions, each module instance can have its own region-specific naming

**Usage in CI/CD**:
```hcl
# In your Terragrunt or Terraform configuration
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata"
  
  namespace     = "myorg"
  project_name  = "myapp"
  environment   = "prod"
  region        = var.region  # Passed from pipeline or tfvars
  resource_type = "lambda"
}
```

**Setting the region**:
- Via variable: `region = "us-east-1"`
- Via environment variable: `export TF_VAR_region="us-east-1"`
- Via tfvars file: `region = "us-east-1"` in `terraform.tfvars`
- Via AWS provider: The module uses `data.aws_region.current` as fallback if region is null

## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compliance_frameworks"></a> [compliance\_frameworks](#input\_compliance\_frameworks) | List of compliance frameworks to enforce (e.g., FCAC, PCI\_DSS, SOC2) | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment to deploy the config aggregator (dev, test, prod, etc). This is used for semantic organization. | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) for resource naming and tagging. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | A unique name to assign for this project. This is used for semantic organization. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for deployment. Used for region-aware naming and passed through to consuming modules for provider configuration. | `string` | `null` | no |
| <a name="input_resource_type"></a> [resource\_type](#input\_resource\_type) | The type of resource being created (e.g., config-aggregator, s3-bucket, etc.) | `string` | n/a | yes |
| <a name="input_security_profile"></a> [security\_profile](#input\_security\_profile) | Security profile to apply (dev, staging, prod). Determines security control defaults. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID. |
| <a name="output_effective_security_profile"></a> [effective\_security\_profile](#output\_effective\_security\_profile) | The effective security profile being applied (dev, staging, or prod) |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | The AWS organization ID. |
| <a name="output_region_code"></a> [region\_code](#output\_region\_code) | The AWS region code (abbreviated). |
| <a name="output_region_name"></a> [region\_name](#output\_region\_name) | The AWS region name. |
| <a name="output_resource_path"></a> [resource\_path](#output\_resource\_path) | The resource path in format: /organization/project/environment/resourcetype/ |
| <a name="output_resource_path_with_region"></a> [resource\_path\_with\_region](#output\_resource\_path\_with\_region) | The resource path with region in format: /organization/project/environment/region/resourcetype/ |
| <a name="output_resource_prefix"></a> [resource\_prefix](#output\_resource\_prefix) | The resource prefix in format: organization-project-environment-resourcetype |
| <a name="output_resource_prefix_with_region"></a> [resource\_prefix\_with\_region](#output\_resource\_prefix\_with\_region) | The resource prefix with region in format: organization-project-environment-region-resourcetype |
| <a name="output_resource_type_code"></a> [resource\_type\_code](#output\_resource\_type\_code) | The resource type code (abbreviated). |
| <a name="output_security_controls"></a> [security\_controls](#output\_security\_controls) | Security controls configuration based on environment and security profile |
| <a name="output_security_tags"></a> [security\_tags](#output\_security\_tags) | Standard security and compliance tags to apply to all resources |

