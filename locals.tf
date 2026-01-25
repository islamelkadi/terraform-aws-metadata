locals {
  account_id      = data.aws_caller_identity.current.account_id
  organization_id = data.aws_organizations_organization.current.id

  resource_type_code = try(local.resource_types_lookup[var.resource_type], var.resource_type)

  # Name formats & Validation checks (Validation assertions - will fail terraform plan/apply if names are too long)
  resource_prefix        = "${var.organization}-${var.project_name}-${var.environment}-${local.resource_type_code}"
  resource_prefix_length = length(local.resource_prefix)

  resource_prefix_with_region        = "${var.organization}-${var.project_name}-${var.environment}-${local.region_code}-${local.resource_type_code}"
  resource_prefix_with_region_length = length(local.resource_prefix_with_region)

  # tflint-ignore: terraform_unused_declarations
  validate_resource_prefix = local.resource_prefix_length <= 64 ? true : tobool("Error: resource_prefix exceeds 64 characters (${local.resource_prefix_length} chars). Please use shorter names.")
  # tflint-ignore: terraform_unused_declarations
  validate_resource_prefix_with_region = local.resource_prefix_with_region_length <= 64 ? true : tobool("Error: resource_prefix_with_region exceeds 64 characters (${local.resource_prefix_with_region_length} chars). Please use shorter names.")

  # Path formats (for IAM and other resources that use paths)
  resource_path             = "/${var.organization}/${var.project_name}/${var.environment}/${local.resource_type_code}/"
  resource_path_with_region = "/${var.organization}/${var.project_name}/${var.environment}/${local.region_code}/${local.resource_type_code}/"

  # Region mappings
  region_name = data.aws_region.current.region
  region_code = local.region_codes[local.region_name]
  region_codes = {
    # US Regions
    us-east-1 = "use1"
    us-east-2 = "use2"
    us-west-1 = "usw1"
    us-west-2 = "usw2"

    # EU Regions
    eu-west-1    = "euw1"
    eu-west-2    = "euw2"
    eu-west-3    = "euw3"
    eu-north-1   = "eun1"
    eu-central-1 = "euc1"
    eu-central-2 = "euc2"
    eu-south-1   = "eus1"
    eu-south-2   = "eus2"

    # Asia Pacific Regions
    ap-southeast-1 = "apse1"
    ap-southeast-2 = "apse2"
    ap-southeast-3 = "apse3"
    ap-southeast-4 = "apse4"
    ap-northeast-1 = "apne1"
    ap-northeast-2 = "apne2"
    ap-northeast-3 = "apne3"
    ap-south-1     = "aps1"
    ap-south-2     = "aps2"
    ap-east-1      = "ape1"

    # Canada Region
    ca-central-1 = "cac1"
    ca-west-1    = "caw1"

    # South America Region
    sa-east-1 = "sae1"

    # Middle East Regions
    me-south-1   = "mes1"
    me-central-1 = "mec1"

    # Africa Region
    af-south-1 = "afs1"
  }
}
