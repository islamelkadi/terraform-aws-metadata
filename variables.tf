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

variable "region" {
  description = "The name of the AWS region to deploy the config aggregator."
  type        = string
}

variable "project_name" {
  description = "A unique name to assign for this project. This is used for semantic organization."
  type        = string
}

variable "organization" {
  description = "The name of the organization to deploy the config aggregator. This is used for semantic organization."
  type        = string
}

variable "resource_type" {
  description = "The type of resource being created (e.g., config-aggregator, s3-bucket, etc.)"
  type        = string
}
