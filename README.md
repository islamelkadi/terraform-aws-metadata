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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization"></a> [organization](#input\_organization) | The name of the organization to deploy the config aggregator. This is used for semantic organization. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | A unique name to assign for this project. This is used for semantic organization. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The name of the AWS region to deploy the config aggregator. | `string` | n/a | yes |
| <a name="input_resource_type"></a> [resource\_type](#input\_resource\_type) | The type of resource being created (e.g., config-aggregator, s3-bucket, etc.) | `string` | n/a | yes |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | A map of generic additional tags to blanket apply to resources created via this module. | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment to deploy the config aggregator (dev, test, prod, etc). This is used for semantic organization. | `string` | `"dev"` | no |

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
<!-- END_TF_DOCS -->
