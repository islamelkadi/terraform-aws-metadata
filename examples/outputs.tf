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

output "effective_security_profile" {
  description = "Effective security profile being applied"
  value       = module.metadata.effective_security_profile
}

output "security_tags" {
  description = "Security and compliance tags"
  value       = module.metadata.security_tags
}

output "availability_zones" {
  description = "Available availability zones in the current region"
  value       = module.metadata.availability_zones
}

output "security_controls_summary" {
  description = "Summary of key security controls"
  value = {
    kms_customer_managed_required = module.metadata.security_controls.encryption.require_kms_customer_managed
    log_retention_days            = module.metadata.security_controls.logging.min_log_retention_days
    versioning_required           = module.metadata.security_controls.data_protection.require_versioning
    multi_az_required             = module.metadata.security_controls.high_availability.require_multi_az
    deletion_protection_enabled   = module.metadata.security_controls.compliance.enable_deletion_protection
  }
}
