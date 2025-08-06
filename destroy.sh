#!/bin/bash

############################################
# SET DEFAULT AWS REGION
############################################

# Export the AWS region to ensure all AWS CLI commands run in the correct context
export AWS_DEFAULT_REGION="us-east-2"

############################################
# STEP 1: DESTROY RDS INSTANCES
############################################

# Navigate into the Terraform directory for EC2 deployment
cd 01-rds

# Initialize Terraform backend and provider plugins (safe for destroy)
terraform init

# Destroy all RDS instances and related resources provisioned by Terraform
terraform destroy -auto-approve  # Auto-approve skips manual confirmation prompts

# Return to root directory after RDS teardown
cd ..

