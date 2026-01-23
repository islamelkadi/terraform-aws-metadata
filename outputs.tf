output "account_id" {
  description = "The AWS account ID."
  value       = local.account_id
}

output "organization_id" {
  description = "The AWS organization ID."
  value       = local.organization_id
}

output "region_name" {
  description = "The AWS region name."
  value       = local.region_name
}

output "resource_prefix" {
  description = "The resource prefix in format: organization-project-environment-resourcetype"
  value       = local.resource_prefix
}

output "resource_prefix_with_region" {
  description = "The resource prefix with region in format: organization-project-environment-region-resourcetype"
  value       = local.resource_prefix_with_region
}

output "resource_path" {
  description = "The resource path in format: /organization/project/environment/resourcetype/"
  value       = local.resource_path
}

output "resource_path_with_region" {
  description = "The resource path with region in format: /organization/project/environment/region/resourcetype/"
  value       = local.resource_path_with_region
}

output "region_code" {
  description = "The AWS region code (abbreviated)."
  value       = local.region_code
}

output "resource_type_code" {
  description = "The resource type code (abbreviated)."
  value       = local.resource_type_code
}
