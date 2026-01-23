# Basic usage of AWS Metadata module
module "metadata" {
  source = "../.."

  # Generic variables
  organization = var.organization
  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  # Resource type
  resource_type = var.resource_type

  # Additional tags
  additional_tags = var.additional_tags
}
