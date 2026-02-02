#!/bin/bash
# ===============================================================================
# FILE: validate.sh
# ===============================================================================
# Resolves and prints the Adminer endpoint and the SQL Server RDS endpoint.
# Also waits for Adminer to become reachable before returning success.
#
# OUTPUT (SUMMARY):
#   - Adminer URL
#   - SQL Server RDS hostname
# ===============================================================================

# Enable strict shell behavior:
#   -e  Exit immediately on error
#   -u  Treat unset variables as errors
#   -o pipefail  Fail pipelines if any command fails
set -euo pipefail


# ===============================================================================
# CONFIGURATION
# ===============================================================================
AWS_DEFAULT_REGION="us-east-2"
ADMINER_TAG_NAME="adminer"
ADMINER_PATH="/adminer"
SQLSERVER_INSTANCE_ID="sqlserver-db"

MAX_ATTEMPTS=30
SLEEP_SECONDS=30

# ===============================================================================
# RESOLVE ADMINER PUBLIC DNS
# ===============================================================================
ADMINER_FQDN="$(aws ec2 describe-instances \
  --region "${AWS_DEFAULT_REGION}" \
  --filters "Name=tag:Name,Values=${ADMINER_TAG_NAME}" \
            "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].PublicDnsName" \
  --output text)"

if [ -z "${ADMINER_FQDN}" ] || [ "${ADMINER_FQDN}" = "None" ]; then
  echo "ERROR: Could not resolve Adminer instance PublicDnsName."
  echo "ERROR: Ensure an EC2 instance exists with tag Name=${ADMINER_TAG_NAME}."
  exit 1
fi

ADMINER_URL="http://${ADMINER_FQDN}${ADMINER_PATH}"

# ===============================================================================
# WAIT FOR ADMINER TO BECOME REACHABLE
# ===============================================================================
echo "NOTE: Waiting for Adminer to become available:"
echo "NOTE:   ${ADMINER_URL}"

attempt=1
until curl -sS --head --fail "${ADMINER_URL}" >/dev/null 2>&1; do
  if [ "${attempt}" -ge "${MAX_ATTEMPTS}" ]; then
    echo "ERROR: Adminer did not become available after ${MAX_ATTEMPTS} attempts."
    echo "ERROR: Last checked URL: ${ADMINER_URL}"
    exit 1
  fi

  echo "NOTE: Adminer not reachable yet. Retry ${attempt}/${MAX_ATTEMPTS}."
  sleep "${SLEEP_SECONDS}"
  attempt=$((attempt + 1))
done

# ===============================================================================
# RESOLVE SQL SERVER RDS ENDPOINT
# ===============================================================================
SQLSERVER_FQDN="$(aws rds describe-db-instances \
  --region "${AWS_DEFAULT_REGION}" \
  --db-instance-identifier "${SQLSERVER_INSTANCE_ID}" \
  --query "DBInstances[0].Endpoint.Address" \
  --output text)"

if [ -z "${SQLSERVER_FQDN}" ] || [ "${SQLSERVER_FQDN}" = "None" ]; then
  echo "ERROR: Could not resolve SQL Server endpoint for ${SQLSERVER_INSTANCE_ID}."
  exit 1
fi

# ===============================================================================
# OUTPUT SUMMARY
# ===============================================================================
echo "==============================================================================="
echo "BUILD VALIDATION RESULTS"
echo "==============================================================================="
echo "Adminer URL:"
echo "  ${ADMINER_URL}"
echo
echo "SQL Server RDS Endpoint:"
echo "  ${SQLSERVER_FQDN}"
echo "==============================================================================="
