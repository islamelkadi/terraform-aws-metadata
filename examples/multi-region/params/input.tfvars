# Multi-region example configuration
organization  = "acme"
project_name  = "payments"
environment   = "prod"
resource_type = "config-aggregator"

# Deploy to multiple regions
regions = [
  "us-east-1",
  "us-west-2",
  "eu-west-1"
]

additional_tags = {
  ManagedBy   = "Terraform"
  Team        = "Platform"
  MultiRegion = "true"
}
