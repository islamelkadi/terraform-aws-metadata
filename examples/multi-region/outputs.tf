output "account_id" {
  description = "AWS Account ID"
  value       = module.metadata.account_id
}

output "organization_id" {
  description = "AWS Organization ID"
  value       = module.metadata.organization_id
}

output "region_name" {
  description = "AWS Region Name"
  value       = module.metadata.region_name
}

output "region_code" {
  description = "AWS Region Code (abbreviated)"
  value       = module.metadata.region_code
}

output "resource_type_code" {
  description = "Resource Type Code (abbreviated)"
  value       = module.metadata.resource_type_code
}

output "resource_prefix" {
  description = "Resource prefix: organization-project-environment-resourcetype"
  value       = module.metadata.resource_prefix
}

output "resource_prefix_with_region" {
  description = "Resource prefix with region: organization-project-environment-region-resourcetype"
  value       = module.metadata.resource_prefix_with_region
}

output "resource_path" {
  description = "Resource path: /organization/project/environment/resourcetype/"
  value       = module.metadata.resource_path
}

output "resource_path_with_region" {
  description = "Resource path with region: /organization/project/environment/region/resourcetype/"
  value       = module.metadata.resource_path_with_region
}
