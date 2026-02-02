#!/bin/bash
# ===============================================================================
# FILE: check_env.sh
# ===============================================================================
# Validates that required command-line tools are available and verifies
# connectivity to AWS using the currently configured credentials.
# ===============================================================================

# ===============================================================================
# REQUIRED COMMAND VALIDATION
# ===============================================================================
# Ensure all required executables are present in the user's PATH before
# continuing with any provisioning or validation steps.
# ===============================================================================

echo "NOTE: Validating required commands are available in PATH."

# List of required command-line tools
commands=("aws" "terraform" "jq")

# Track validation status across all checks
all_found=true

# Iterate through each command and verify availability
for cmd in "${commands[@]}"; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "ERROR: ${cmd} is not found in the current PATH."
    all_found=false
  else
    echo "NOTE: ${cmd} is available."
  fi
done

# Abort if any required command is missing
if [ "${all_found}" = false ]; then
  echo "ERROR: One or more required commands are missing."
  exit 1
fi

echo "NOTE: All required commands are available."

# ===============================================================================
# AWS CREDENTIAL VALIDATION
# ===============================================================================
# Verify that AWS credentials are configured and usable by performing
# a lightweight STS identity lookup.
# ===============================================================================

echo "NOTE: Validating AWS CLI connectivity."

aws sts get-caller-identity --query "Account" --output text >/dev/null 2>&1

# Abort if AWS authentication fails
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to connect to AWS."
  echo "ERROR: Verify credentials, region, and environment variables."
  exit 1
fi

echo "NOTE: AWS authentication successful."
