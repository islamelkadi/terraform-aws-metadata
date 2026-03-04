# Generic module variables
variable "environment" {
  description = "The name of the environment to deploy the config aggregator (dev, test, prod, etc). This is used for semantic organization."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "qa", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, qa, staging, prod."
  }
}

variable "project_name" {
  description = "A unique name to assign for this project. This is used for semantic organization."
  type        = string
}

variable "namespace" {
  description = "Namespace (organization/team name) for resource naming and tagging."
  type        = string
}

variable "resource_type" {
  description = "The type of resource being created (e.g., config-aggregator, s3-bucket, etc.)"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "AWS region for deployment. Used for region-aware naming and passed through to consuming modules for provider configuration."
  type        = string
  default     = null

  validation {
    condition     = var.region == null || can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1, eu-west-2) or null to auto-detect."
  }
}

variable "security_profile" {
  description = "Security profile to apply (dev, staging, prod). Determines security control defaults."
  type        = string
  default     = null

  validation {
    condition     = var.security_profile == null || contains(["dev", "staging", "prod"], var.security_profile)
    error_message = "Security profile must be one of: dev, staging, prod."
  }
}

variable "compliance_frameworks" {
  description = "List of compliance frameworks to enforce (e.g., FCAC, PCI_DSS, SOC2)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for framework in var.compliance_frameworks :
      contains(["FCAC", "PCI_DSS", "SOC2", "HIPAA", "ISO27001"], framework)
    ])
    error_message = "Compliance frameworks must be one of: FCAC, PCI_DSS, SOC2, HIPAA, ISO27001."
  }
}
