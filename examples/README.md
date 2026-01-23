# AWS Metadata Module Examples

This directory contains example implementations of the AWS Metadata module.

## Examples

### 1. Basic Usage
**Directory:** `basic/`

Demonstrates basic usage of the metadata module to generate standardized resource names and paths.

**Features:**
- Standard resource naming
- Region-aware naming
- Path generation for IAM resources
- Metadata outputs (account ID, organization ID, region codes)

**Usage:**
```bash
cd basic
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

**Configuration:** Edit `basic/params/input.tfvars`

### 2. Multi-Region Usage
**Directory:** `multi-region/`

Shows how to use the metadata module across multiple regions with consistent naming.

**Features:**
- Region-specific resource names
- Demonstrates regional resource deployment
- Shows how to use `resource_prefix_with_region` output

**Usage:**
```bash
cd multi-region
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

**Configuration:** Edit `multi-region/params/input.tfvars`

## Customization

Each example has its own `params/input.tfvars` file that you can customize:

**Basic Example:**
```hcl
organization  = "acme"
project_name  = "payments"
environment   = "prod"
resource_type = "config-aggregator"
region        = "us-east-1"
```

**Multi-Region Example:**
```hcl
organization  = "acme"
project_name  = "payments"
environment   = "prod"
resource_type = "config-aggregator"
regions       = ["us-east-1", "us-west-2", "eu-west-1"]
```

## Output Examples

The module generates several naming formats:

- **resource_prefix**: `acme-payments-prod-cfgagg`
- **resource_prefix_with_region**: `acme-payments-prod-use1-cfgagg`
- **resource_path**: `/acme/payments/prod/cfgagg/`
- **resource_path_with_region**: `/acme/payments/prod/use1/cfgagg/`

## Prerequisites

- Terraform >= 1.14.3
- AWS credentials configured
- Access to AWS Organizations (for organization_id output)

## Important Notes

- **Name Length Validation:** The module validates that generated names don't exceed 64 characters (AWS resource name limit)
- **Environment Validation:** Only accepts: dev, test, qa, staging, prod
- **Resource Type Codes:** Define custom abbreviations in `resource-types.tf` for your resource types
