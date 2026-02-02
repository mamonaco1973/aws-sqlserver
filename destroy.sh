#!/bin/bash
# ===============================================================================
# FILE: destroy.sh
# ===============================================================================
# Tears down all Terraform-managed infrastructure for the SQL Server
# RDS environment in a controlled and repeatable manner.
#
# This script:
#   1) Sets the AWS default region for CLI and Terraform operations
#   2) Initializes the Terraform working directory
#   3) Destroys all provisioned RDS resources without prompting
# ===============================================================================

# Enable strict shell behavior:
#   -e  Exit immediately on error
#   -u  Treat unset variables as errors
#   -o pipefail  Fail pipelines if any command fails
set -euo pipefail


# ===============================================================================
# SET AWS DEFAULT REGION
# ===============================================================================
# Define the AWS region used by all subsequent AWS CLI and Terraform
# commands executed by this script.
# ===============================================================================

export AWS_DEFAULT_REGION="us-east-2"

# ===============================================================================
# DESTROY RDS INFRASTRUCTURE
# ===============================================================================
# Destroy all Terraform-managed resources defined in the RDS module.
# ===============================================================================

# Change into the Terraform configuration directory
cd 01-rds

# Initialize the Terraform backend and required providers
terraform init

# Destroy all resources without interactive approval
terraform destroy -auto-approve

# Return to the root project directory
cd ..
