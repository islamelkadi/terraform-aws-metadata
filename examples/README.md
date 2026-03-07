# AWS Metadata Module Examples

This directory contains example implementations of the AWS Metadata module.

## Example Usage

Demonstrates complete usage of the metadata module including:
- Standardized resource naming
- Security controls configuration
- Compliance framework tagging
- Region-aware naming
- Path generation for IAM resources

### Features

- **Standard resource naming**: Consistent prefixes and paths
- **Security profiles**: Environment-aware security controls (dev/staging/prod)
- **Compliance tagging**: Automated tags for FCAC, PCI DSS, SOC2, etc.
- **Metadata outputs**: Account ID, organization ID, region codes
- **Security controls**: Encryption, logging, network, IAM, data protection, monitoring, HA, compliance

### Usage

```bash
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

### Configuration

Edit `params/input.tfvars` to customize:

```hcl
namespace     = "example"
project_name  = "payments"
environment   = "prod"
region        = "us-east-1"
resource_type = "config-aggregator"

# Optional: Override security profile
# security_profile = "prod"

# Optional: Specify compliance frameworks
compliance_frameworks = ["FCAC", "PCI_DSS"]
```

## Output Examples

### Naming Outputs

The module generates several naming formats:

- **resource_prefix**: `example-payments-prod-cfgagg`
- **resource_prefix_with_region**: `example-payments-prod-use1-cfgagg`
- **resource_path**: `/example/payments/prod/cfgagg/`
- **resource_path_with_region**: `/example/payments/prod/use1/cfgagg/`

### Security Outputs

**Security Profile**: `PROD`

**Security Tags**:
```hcl
{
  Organization         = "EXAMPLE"
  Project              = "PAYMENTS"
  Environment          = "PROD"
  Region               = "USE1"
  ResourceType         = "CONFIG_AGGREGATOR"
  ManagedBy            = "TERRAFORM"
  Repository           = "CORPORATE_ACTIONS_ORCHESTRATOR"
  SecurityProfile      = "PROD"
  DataClass            = "CONFIDENTIAL"
  ComplianceFrameworks = "FCAC,PCI_DSS"
  ComplianceRequired   = "TRUE"
  AuditRequired        = "TRUE"
}
```

**Security Controls Summary** (for prod environment):
```hcl
{
  kms_customer_managed_required = true
  log_retention_days            = 365
  versioning_required           = true
  multi_az_required             = true
  deletion_protection_enabled   = true
}
```

## Security Profiles

### Dev Profile Example

```hcl
environment = "dev"
# Results in:
# - 7-day log retention
# - AWS-managed keys allowed
# - Single AZ OK
# - No deletion protection
```

### Staging Profile Example

```hcl
environment = "staging"
# Results in:
# - 90-day log retention
# - Customer-managed KMS required
# - Multi-AZ for databases
# - Deletion protection enabled
```

### Prod Profile Example

```hcl
environment = "prod"
# Results in:
# - 365-day log retention
# - Customer-managed KMS required
# - Multi-AZ for all critical resources
# - Cross-region backups
# - MFA delete for S3
```

## Using Security Controls in Your Modules

```hcl
module "metadata" {
  source = "../../"

  namespace     = "example"
  project_name  = "myapp"
  environment   = "prod"
  region        = "us-east-1"
  resource_type = "s3"
}

# Use security controls
resource "aws_s3_bucket_versioning" "example" {
  count = module.metadata.security_controls.data_protection.require_versioning ? 1 : 0
  
  bucket = aws_s3_bucket.example.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Apply security tags
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
```

## Prerequisites

- Terraform >= 1.14.3
- AWS credentials configured
- Access to AWS Organizations (for organization_id output)

## Important Notes

- **Name Length Validation**: The module validates that generated names don't exceed 64 characters (AWS resource name limit)
- **Environment Validation**: Only accepts: dev, test, qa, staging, prod
- **Security Profile Mapping**: Automatically maps environment to security profile (dev→dev, staging→staging, prod→prod)
- **Compliance Frameworks**: Valid values: FCAC, PCI_DSS, SOC2, HIPAA, ISO27001
- **Resource Type Codes**: Define custom abbreviations in `resource-types.tf` for your resource types
- **Supported Regions**: All AWS commercial regions are supported with abbreviated codes

## Testing

Run the example to see all outputs:

```bash
terraform init
terraform apply -var-file=params/input.tfvars

# View outputs
terraform output
```

Expected output includes:
- Naming conventions (prefixes, paths, codes)
- Security profile (dev/staging/prod)
- Security tags (with compliance frameworks)
- Security controls summary (key settings)
