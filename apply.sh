#!/bin/bash

############################################
# STEP 0: ENVIRONMENT VALIDATION
############################################

# Execute the environment check script to ensure all preconditions are met
./check_env.sh

# If the script failed (non-zero exit code), abort the process immediately
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

############################################
# STEP 1: SET AWS DEFAULT REGION
############################################

# Set the AWS region for all subsequent CLI commands
export AWS_DEFAULT_REGION="us-east-2"

############################################
# STEP 2: TERRAFORM - BUILD NETWORKING INFRASTRUCTURE
############################################

# Inform user about infrastructure provisioning step
echo "NOTE: Building Database Instances."

# Navigate to the infrastructure provisioning folder
cd 01-rds

# Initialize the Terraform backend and plugins
terraform init

# Apply the Terraform configuration non-interactively (auto-approve skips manual confirmation)
terraform apply -auto-approve

# Return to the root directory
cd ..

############################################
# STEP 3: VALIDATE AND LOAD PAGILA DATA
############################################

./validate.sh

