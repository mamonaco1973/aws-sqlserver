#!/bin/bash

# Set your region if needed
AWS_DEFAULT_REGION="us-east-2"

ADMINER_FQDN=$(aws ec2 describe-instances \
  --region us-east-2 \
  --filters "Name=tag:Name,Values=adminer" \
  --query "Reservations[].Instances[].PublicDnsName" \
  --output text)

echo "NOTE: Adminer running at http://$ADMINER_FQDN"

# Wait until the Adminer URL is reachable (HTTP 200 or similar)
echo "NOTE: Waiting for Adminer to become available at http://$ADMINER_FQDN ..."

# Max attempts (optional)
MAX_ATTEMPTS=30
ATTEMPT=1

until curl -s --head --fail "http://$ADMINER_FQDN/adminer" > /dev/null; do
   if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
     echo "ERROR: Adminer did not become available after $MAX_ATTEMPTS attempts."
     exit 1
   fi
   echo "WARNING: Adminer not yet reachable. Retrying in 30 seconds..."
   sleep 30
   ATTEMPT=$((ATTEMPT+1))
done

SQLSERVER_FQDN=$(aws rds describe-db-instances \
  --db-instance-identifier sqlserver-db \
  --query "DBInstances[].Endpoint.Address" \
  --output text)

echo "NOTE: Hostname for SQL Server is \"$SQLSERVER_FQDN\""

