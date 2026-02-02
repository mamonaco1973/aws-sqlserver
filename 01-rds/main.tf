# ===============================================================================
# AWS PROVIDER CONFIGURATION
# ===============================================================================
# Configures the AWS provider used by Terraform to authenticate and
# manage AWS resources defined in this configuration.
#
# The selected region determines where all AWS resources are created.
# Choosing an incorrect region may increase latency, cost, or violate
# organizational or regulatory compliance requirements.
#
# NOTES:
# - AWS credentials must be configured outside of Terraform.
# - Supported methods include AWS CLI config, environment variables,
#   or IAM roles when running on AWS infrastructure.
# - Update the region value when deploying to a different AWS region.
# ===============================================================================

provider "aws" {

  # AWS region where all Terraform-managed resources will be provisioned
  region = "us-east-2"
}
