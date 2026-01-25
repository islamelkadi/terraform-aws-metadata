variable "organization" {
  description = "Organization name"
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
  description = "AWS region"
  type        = string
}

variable "resource_type" {
  description = "Resource type (e.g., config-aggregator, s3-bucket)"
  type        = string
}
