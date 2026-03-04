# Basic usage of AWS Metadata module
module "metadata" {
  source = "../"

  # Generic variables
  namespace    = var.namespace
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  # Resource type
  resource_type = var.resource_type

  # Optional: Security profile (defaults to environment mapping)
  security_profile = var.security_profile

  # Optional: Compliance frameworks
  compliance_frameworks = var.compliance_frameworks
}
