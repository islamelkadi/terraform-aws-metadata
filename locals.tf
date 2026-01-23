locals {
  account_id      = data.aws_caller_identity.current.account_id
  organization_id = data.aws_organizations_organization.current.id

  resource_type_code = try(local.resource_types_lookup[var.resource_type], var.resource_type)

  # Name formats & Validation checks (Validation assertions - will fail terraform plan/apply if names are too long)
  resource_prefix        = "${var.organization}-${var.project_name}-${var.environment}-${local.resource_type_code}"
  resource_prefix_length = length(local.resource_prefix)

  resource_prefix_with_region        = "${var.organization}-${var.project_name}-${var.environment}-${local.region_code}-${local.resource_type_code}"
  resource_prefix_with_region_length = length(local.resource_prefix_with_region)

  validate_resource_prefix             = local.resource_prefix_length <= 64 ? true : tobool("Error: resource_prefix exceeds 64 characters (${local.resource_prefix_length} chars). Please use shorter names.")
  validate_resource_prefix_with_region = local.resource_prefix_with_region_length <= 64 ? true : tobool("Error: resource_prefix_with_region exceeds 64 characters (${local.resource_prefix_with_region_length} chars). Please use shorter names.")

  # Path formats (for IAM and other resources that use paths)
  resource_path             = "/${var.organization}/${var.project_name}/${var.environment}/${local.resource_type_code}/"
  resource_path_with_region = "/${var.organization}/${var.project_name}/${var.environment}/${local.region_code}/${local.resource_type_code}/"

  # Region mappings
  region_name = data.aws_region.current.region
  region_code = local.region_codes[local.region_name]
  region_codes = {
    us-east-1      = "use1"
    us-east-2      = "use2"
    us-west-1      = "usw1"
    us-west-2      = "usw2"
    eu-west-1      = "euw1"
    eu-west-2      = "euw2"
    eu-west-3      = "euw3"
    eu-north-1     = "eun1"
    ap-southeast-1 = "aps1"
    ap-southeast-2 = "aps2"
    ap-northeast-1 = "apn1"
    ap-northeast-2 = "apn2"
    ap-south-1     = "aps3"
    sa-east-1      = "sae1"
  }
}
