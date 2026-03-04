# Basic example configuration
namespace     = "acme"
project_name  = "payments"
environment   = "prod"
region        = "us-east-1"
resource_type = "config-aggregator"

# Optional: Override security profile (defaults to environment mapping)
# security_profile = "prod"

# Optional: Specify compliance frameworks
compliance_frameworks = ["FCAC", "PCI_DSS"]
