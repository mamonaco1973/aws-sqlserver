#!/bin/bash
# ===============================================================================
# FILE: apply.sh
# ===============================================================================
# Orchestrates end-to-end provisioning and validation for the SQL Server
# RDS environment using Terraform and supporting helper scripts.
#
# This script performs the following steps:
#   1) Validates required tools, credentials, and environment variables
#   2) Sets the AWS default region for CLI and Terraform operations
#   3) Builds the RDS infrastructure using Terraform
#   4) Validates the deployment and performs post-build checks
# ===============================================================================

# ===============================================================================
# STEP 0: ENVIRONMENT VALIDATION
# ===============================================================================
# Execute preflight checks to ensure all required dependencies and
# configuration prerequisites are satisfied before continuing.
# ===============================================================================

./check_env.sh

# Abort immediately if the environment validation fails
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

# ===============================================================================
# STEP 1: SET AWS DEFAULT REGION
# ===============================================================================
# Define the AWS region used by all subsequent AWS CLI and Terraform
# operations executed by this script.
# ===============================================================================

export AWS_DEFAULT_REGION="us-east-2"

# ===============================================================================
# STEP 2: TERRAFORM APPLY - RDS INFRASTRUCTURE
# ===============================================================================
# Initialize and apply the Terraform configuration that provisions
# the SQL Server RDS instance and supporting resources.
# ===============================================================================

# Inform the user that infrastructure provisioning is starting
echo "NOTE: Building SQL Server Instance."

# Change into the Terraform configuration directory
cd 01-rds

# Initialize the Terraform backend and required providers
terraform init

# Apply the Terraform configuration without interactive approval
terraform apply -auto-approve

# Return to the root project directory
cd ..

# ===============================================================================
# STEP 3: POST-DEPLOYMENT VALIDATION
# ===============================================================================
# Validate the deployed infrastructure and perform any required
# post-provisioning.
# ===============================================================================

./validate.sh
