#!/bin/bash
git reset --soft $(git rev-list --max-parents=0 HEAD)
git commit -F- <<EOF
feat!: First publish - Metadata Terraform module

This initial release provides a production-ready Terraform module for AWS resource metadata with:
- Consistent naming conventions across all resources
- Standardized tagging framework
- Environment and project identification
- Cost allocation and tracking support
- Security and compliance tagging
- Complete documentation and examples
- GitHub workflows for CI/CD automation
EOF
git push --force
