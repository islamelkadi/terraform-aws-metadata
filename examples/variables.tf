variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, qa, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region for resource deployment (e.g., us-east-1, eu-west-1)"
  type        = string
}

variable "resource_type" {
  description = "Resource type (e.g., config-aggregator, s3-bucket)"
  type        = string
}

variable "security_profile" {
  description = "Security profile to apply (dev, staging, prod). Defaults to environment mapping."
  type        = string
  default     = null
}

variable "compliance_frameworks" {
  description = "List of compliance frameworks to enforce (e.g., FCAC, PCI_DSS, SOC2)"
  type        = list(string)
  default     = []
}
