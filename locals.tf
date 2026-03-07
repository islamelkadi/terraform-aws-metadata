locals {
  account_id      = data.aws_caller_identity.current.account_id
  organization_id = data.aws_organizations_organization.current.id

  resource_type_code = try(local.resource_types_lookup[var.resource_type], var.resource_type)

  # Name formats & Validation checks (Validation assertions - will fail terraform plan/apply if names are too long)
  resource_prefix        = "${var.namespace}-${var.project_name}-${var.environment}-${local.resource_type_code}"
  resource_prefix_length = length(local.resource_prefix)

  resource_prefix_with_region        = "${var.namespace}-${var.project_name}-${var.environment}-${local.region_code}-${local.resource_type_code}"
  resource_prefix_with_region_length = length(local.resource_prefix_with_region)

  # tflint-ignore: terraform_unused_declarations
  validate_resource_prefix = local.resource_prefix_length <= 64 ? true : tobool("Error: resource_prefix exceeds 64 characters (${local.resource_prefix_length} chars). Please use shorter names.")
  # tflint-ignore: terraform_unused_declarations
  validate_resource_prefix_with_region = local.resource_prefix_with_region_length <= 64 ? true : tobool("Error: resource_prefix_with_region exceeds 64 characters (${local.resource_prefix_with_region_length} chars). Please use shorter names.")

  # Path formats (for IAM and other resources that use paths)
  resource_path             = "/${var.namespace}/${var.project_name}/${var.environment}/${local.resource_type_code}/"
  resource_path_with_region = "/${var.namespace}/${var.project_name}/${var.environment}/${local.region_code}/${local.resource_type_code}/"

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

  # ============================================================================
  # Security Controls Configuration
  # ============================================================================
  # Determines security control defaults based on environment and security profile
  # Security profile takes precedence over environment if specified

  # Determine effective security profile (explicit profile > environment mapping)
  effective_security_profile = coalesce(
    var.security_profile,
    var.environment == "prod" ? "prod" : var.environment == "staging" ? "staging" : "dev"
  )

  # Security control profiles by environment
  security_control_profiles = {
    dev = {
      # Encryption Controls (relaxed for dev)
      encryption = {
        require_kms_customer_managed  = false # Allow AWS-managed keys in dev
        require_encryption_at_rest    = true  # Still require encryption
        require_encryption_in_transit = true  # TLS 1.2+ required
        enable_kms_key_rotation       = false # Optional in dev
      }

      # Logging Controls (minimal for dev)
      logging = {
        require_cloudwatch_logs = true  # CloudWatch Logs required
        min_log_retention_days  = 7     # Short retention for dev
        require_access_logging  = false # Optional in dev
        require_flow_logs       = false # Optional in dev
      }

      # Network Security Controls (relaxed for dev)
      network = {
        require_private_subnets = false # Can use public subnets in dev
        require_vpc_endpoints   = false # Optional in dev
        block_public_ingress    = false # Allow public access for testing
        require_imdsv2          = true  # IMDSv2 always required
      }

      # IAM Controls (enforced)
      iam = {
        enforce_least_privilege  = true  # Always enforce
        block_wildcard_resources = false # Allow wildcards in dev
        require_mfa_for_humans   = false # Optional in dev
        require_service_roles    = true  # Always use service roles
      }

      # Data Protection Controls (minimal for dev)
      data_protection = {
        require_versioning         = false # Optional in dev
        require_mfa_delete         = false # Not needed in dev
        require_automated_backups  = false # Optional in dev
        block_public_access        = true  # Always block public access
        require_lifecycle_policies = false # Optional in dev
      }

      # Monitoring Controls (basic for dev)
      monitoring = {
        enable_xray_tracing         = false # Optional in dev
        enable_enhanced_monitoring  = false # Optional in dev
        enable_performance_insights = false # Optional in dev
        require_cloudtrail          = true  # Always required
      }

      # High Availability Controls (not required for dev)
      high_availability = {
        require_multi_az           = false # Single AZ OK for dev
        require_multi_az_nat       = false # Single NAT OK for dev
        enable_cross_region_backup = false # Not needed in dev
      }

      # Compliance Controls (relaxed for dev)
      compliance = {
        enable_point_in_time_recovery = false # Optional in dev
        require_reserved_concurrency  = false # Optional in dev
        enable_deletion_protection    = false # Allow easy teardown in dev
      }
    }

    staging = {
      # Encryption Controls (production-like)
      encryption = {
        require_kms_customer_managed  = true # Customer-managed keys
        require_encryption_at_rest    = true # Required
        require_encryption_in_transit = true # TLS 1.2+ required
        enable_kms_key_rotation       = true # Auto-rotate keys
      }

      # Logging Controls (production-like)
      logging = {
        require_cloudwatch_logs = true # CloudWatch Logs required
        min_log_retention_days  = 90   # 90-day retention
        require_access_logging  = true # Access logs required
        require_flow_logs       = true # VPC Flow Logs required
      }

      # Network Security Controls (production-like)
      network = {
        require_private_subnets = true # Private subnets required
        require_vpc_endpoints   = true # VPC endpoints required
        block_public_ingress    = true # Block public access
        require_imdsv2          = true # IMDSv2 required
      }

      # IAM Controls (enforced)
      iam = {
        enforce_least_privilege  = true # Enforce least privilege
        block_wildcard_resources = true # No wildcards
        require_mfa_for_humans   = true # MFA required
        require_service_roles    = true # Service roles required
      }

      # Data Protection Controls (production-like)
      data_protection = {
        require_versioning         = true  # Versioning required
        require_mfa_delete         = false # Optional in staging
        require_automated_backups  = true  # Backups required
        block_public_access        = true  # Block public access
        require_lifecycle_policies = true  # Lifecycle policies required
      }

      # Monitoring Controls (full monitoring)
      monitoring = {
        enable_xray_tracing         = true # X-Ray tracing enabled
        enable_enhanced_monitoring  = true # Enhanced monitoring enabled
        enable_performance_insights = true # Performance Insights enabled
        require_cloudtrail          = true # CloudTrail required
      }

      # High Availability Controls (production-like)
      high_availability = {
        require_multi_az           = true  # Multi-AZ required
        require_multi_az_nat       = false # Single NAT OK for staging
        enable_cross_region_backup = false # Optional in staging
      }

      # Compliance Controls (production-like)
      compliance = {
        enable_point_in_time_recovery = true  # PITR enabled
        require_reserved_concurrency  = false # Optional in staging
        enable_deletion_protection    = true  # Deletion protection enabled
      }
    }

    prod = {
      # Encryption Controls (maximum security)
      encryption = {
        require_kms_customer_managed  = true # Customer-managed keys required
        require_encryption_at_rest    = true # Required
        require_encryption_in_transit = true # TLS 1.2+ required
        enable_kms_key_rotation       = true # Auto-rotate keys
      }

      # Logging Controls (maximum retention)
      logging = {
        require_cloudwatch_logs = true # CloudWatch Logs required
        min_log_retention_days  = 365  # 365-day retention (PCI DSS)
        require_access_logging  = true # Access logs required
        require_flow_logs       = true # VPC Flow Logs required
      }

      # Network Security Controls (maximum security)
      network = {
        require_private_subnets = true # Private subnets required
        require_vpc_endpoints   = true # VPC endpoints required
        block_public_ingress    = true # Block public access
        require_imdsv2          = true # IMDSv2 required
      }

      # IAM Controls (maximum security)
      iam = {
        enforce_least_privilege  = true # Enforce least privilege
        block_wildcard_resources = true # No wildcards
        require_mfa_for_humans   = true # MFA required
        require_service_roles    = true # Service roles required
      }

      # Data Protection Controls (maximum protection)
      data_protection = {
        require_versioning         = true # Versioning required
        require_mfa_delete         = true # MFA Delete required
        require_automated_backups  = true # Backups required
        block_public_access        = true # Block public access
        require_lifecycle_policies = true # Lifecycle policies required
      }

      # Monitoring Controls (full monitoring)
      monitoring = {
        enable_xray_tracing         = true # X-Ray tracing enabled
        enable_enhanced_monitoring  = true # Enhanced monitoring enabled
        enable_performance_insights = true # Performance Insights enabled
        require_cloudtrail          = true # CloudTrail required
      }

      # High Availability Controls (maximum availability)
      high_availability = {
        require_multi_az           = true # Multi-AZ required
        require_multi_az_nat       = true # Multi-AZ NAT required
        enable_cross_region_backup = true # Cross-region backup enabled
      }

      # Compliance Controls (maximum compliance)
      compliance = {
        enable_point_in_time_recovery = true # PITR enabled
        require_reserved_concurrency  = true # Reserved concurrency required
        enable_deletion_protection    = true # Deletion protection enabled
      }
    }
  }

  # Select security controls based on effective profile
  security_controls = local.security_control_profiles[local.effective_security_profile]

  # ============================================================================
  # Security Tags
  # ============================================================================
  # Standard security and compliance tags applied to all resources

  security_tags = merge(
    {
      # Core identification tags
      Namespace    = upper(var.namespace)
      Project      = upper(replace(var.project_name, "-", "_"))
      Environment  = upper(var.environment)
      Region       = upper(local.region_code)
      ResourceType = upper(replace(local.resource_type_code, "-", "_"))

      # Management tags
      ManagedBy  = "TERRAFORM"
      Repository = "CORPORATE_ACTIONS_ORCHESTRATOR"

      # Security tags
      SecurityProfile = upper(local.effective_security_profile)
      DataClass       = local.effective_security_profile == "prod" ? "CONFIDENTIAL" : local.effective_security_profile == "staging" ? "INTERNAL" : "PUBLIC"

      # Compliance tags
      ComplianceFrameworks = length(var.compliance_frameworks) > 0 ? join(",", var.compliance_frameworks) : "NONE"
    },
    # Add compliance-specific tags if frameworks are specified
    length(var.compliance_frameworks) > 0 ? {
      ComplianceRequired = "TRUE"
      AuditRequired      = "TRUE"
    } : {}
  )
}
