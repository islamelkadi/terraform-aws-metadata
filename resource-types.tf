# ============================================================================
# Resource Type Abbreviations
# ============================================================================
# This file defines the mapping between full resource type names and their
# abbreviated codes used in resource naming conventions.
#
# Abbreviation Rules:
# - 3-6 characters: Short enough for naming, long enough to be clear
# - Lowercase: Consistent with Terraform conventions
# - No special characters: Only letters and hyphens
# - Intuitive: Use common AWS abbreviations where possible
# - Unique: No conflicts between abbreviations
#
# Usage:
#   resource_type = "lambda"        → "lambda"
#   resource_type = "dynamodb"      → "ddb"
#   resource_type = "api-gateway"   → "apigw"
# ============================================================================

locals {
  resource_types_lookup = {
    # ============================================================================
    # Compute Services
    # ============================================================================
    "lambda"         = "lambda" # AWS Lambda function
    "lambda-layer"   = "layer"  # Lambda layer
    "sfn"            = "sfn"    # Step Functions state machine
    "step-functions" = "sfn"    # Alias for sfn
    "eks"            = "eks"    # Amazon EKS cluster
    "eks-cluster"    = "eks"    # Alias for eks

    # ============================================================================
    # Storage Services
    # ============================================================================
    "s3"        = "s3" # S3 bucket
    "s3-bucket" = "s3" # Alias for s3
    "efs"       = "efs" # Amazon EFS file system
    "efs-fs"    = "efs" # Alias for efs

    # ============================================================================
    # Database Services
    # ============================================================================
    "dynamodb"       = "ddb"    # DynamoDB table
    "dynamodb-table" = "ddb"    # Alias for dynamodb
    "rds"            = "rds"    # RDS database instance
    "rds-cluster"    = "rds"    # RDS/Aurora cluster
    "rds-proxy"      = "rdsprx" # RDS Proxy
    "aurora"         = "aurora" # Aurora cluster

    # ============================================================================
    # Networking Services
    # ============================================================================
    "vpc"            = "vpc"    # Virtual Private Cloud
    "subnet"         = "subnet" # VPC Subnet
    "sg"             = "sg"     # Security Group
    "security-group" = "sg"     # Alias for sg
    "nacl"           = "nacl"   # Network ACL
    "nat"            = "nat"    # NAT Gateway
    "nat-gateway"    = "nat"    # Alias for nat
    "vpce"           = "vpce"   # VPC Endpoint
    "vpc-endpoint"   = "vpce"   # Alias for vpce

    # ============================================================================
    # Security & Identity Services
    # ============================================================================
    "kms"             = "kms"    # KMS key
    "kms-key"         = "kms"    # Alias for kms
    "secret"          = "secret" # Secrets Manager secret
    "secrets-manager" = "secret" # Alias for secret
    "iam-role"        = "role"   # IAM role
    "iam-policy"      = "policy" # IAM policy
    "iam-user"        = "user"   # IAM user
    "iam-group"       = "group"  # IAM group

    # ============================================================================
    # Identity Services (Cognito)
    # ============================================================================
    "cognito-user-pool"        = "userpool" # Cognito User Pool
    "cognito-user-pool-client" = "upclient" # Cognito User Pool Client
    "cognito-user-pool-domain" = "updomain" # Cognito User Pool Domain
    "cognito-identity-pool"    = "idpool"   # Cognito Identity Pool

    # ============================================================================
    # Monitoring & Logging Services
    # ============================================================================
    "logs"             = "logs"  # CloudWatch Log Group
    "log-group"        = "logs"  # Alias for logs
    "alarm"            = "alarm" # CloudWatch Alarm
    "cloudwatch-alarm" = "alarm" # Alias for alarm

    # ============================================================================
    # Integration Services
    # ============================================================================
    "eventbridge"      = "eb"      # EventBridge bus
    "eventbridge-rule" = "ebrule"  # EventBridge rule
    "sns"              = "sns"     # SNS topic
    "sns-topic"        = "sns"     # Alias for sns
    "sqs"              = "sqs"     # SQS queue
    "sqs-queue"        = "sqs"     # Alias for sqs
    "apigateway"       = "apigw"   # API Gateway REST API
    "api-gateway"      = "apigw"   # Alias for apigateway
    "apigw-rest"       = "apigw"   # API Gateway REST API
    "apigw-http"       = "httpapi" # API Gateway HTTP API
    "apigw-websocket"  = "wsapi"   # API Gateway WebSocket API

    # ============================================================================
    # AI/ML Services
    # ============================================================================
    "bedrock"       = "bedrock" # Bedrock agent/model
    "bedrock-agent" = "agent"   # Bedrock agent
    "bedrock-kb"    = "kb"      # Bedrock knowledge base

    # ============================================================================
    # Content Delivery Services
    # ============================================================================
    "cloudfront"      = "cf" # CloudFront distribution
    "cloudfront-dist" = "cf" # Alias for cloudfront

    # ============================================================================
    # Governance & Management Services
    # ============================================================================
    "config"            = "config"  # AWS Config
    "config-aggregator" = "cfgagg"  # Config aggregator
    "config-rule"       = "cfgrule" # Config rule

    # ============================================================================
    # Application Services
    # ============================================================================
    "app" = "app" # Generic application
  }
}
