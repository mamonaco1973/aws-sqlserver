#!/bin/bash

# Set your region if needed
AWS_REGION="us-east-2"

# Cluster identifier from your Terraform
CLUSTER_ID="aurora-postgres-cluster"

# Get the primary endpoint (writer) from the cluster description
PRIMARY_ENDPOINT=$(aws rds describe-db-clusters \
  --region "$AWS_REGION" \
  --db-cluster-identifier "$CLUSTER_ID" \
  --query 'DBClusters[0].Endpoint' \
  --output text)

echo "NOTE: Primary Aurora Endpoint: $PRIMARY_ENDPOINT"

# Name of the secret created in Terraform
SECRET_NAME="aurora-credentials"

# Retrieve and parse the secret
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --query 'SecretString' \
  --output text)

# Extract user and password using jq
USER=$(echo "$SECRET_JSON" | jq -r .user)
PASSWORD=$(echo "$SECRET_JSON" | jq -r .password)

rm -f -r /tmp/db_load.log

echo "NOTE: Loading 'pagila' data into Aurora"

PGPASSWORD=$PASSWORD psql -h $PRIMARY_ENDPOINT -U postgres -d postgres -f ./01-rds/data/pagila-db.sql >> /tmp/db_load.log
PGPASSWORD=$PASSWORD psql -h $PRIMARY_ENDPOINT -U postgres -d pagila -f ./01-rds/data/pagila-schema.sql >> /tmp/db_load.log
PGPASSWORD=$PASSWORD psql -h $PRIMARY_ENDPOINT -U postgres -d pagila -f ./01-rds/data/pagila-data.sql >> /tmp/db_load.log

RDS_ENDPOINT=$(aws rds describe-db-instances \
  --region us-east-2 \
  --db-instance-identifier postgres-rds-instance \
  --query "DBInstances[0].Endpoint.Address" \
  --output text)

echo "NOTE: Primary RDS Endpoint: $RDS_ENDPOINT"

# Name of the secret created in Terraform
SECRET_NAME="postgres-credentials"

# Retrieve and parse the secret
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --query 'SecretString' \
  --output text)

# Extract user and password using jq
USER=$(echo "$SECRET_JSON" | jq -r .user)
PASSWORD=$(echo "$SECRET_JSON" | jq -r .password)

echo "NOTE: Loading 'pagila' data into RDS"

PGPASSWORD=$PASSWORD psql -h $RDS_ENDPOINT -U postgres -d postgres -f ./01-rds/data/pagila-db.sql >> /tmp/db_load.log
PGPASSWORD=$PASSWORD psql -h $RDS_ENDPOINT -U postgres -d pagila -f ./01-rds/data/pagila-schema.sql >> /tmp/db_load.log
PGPASSWORD=$PASSWORD psql -h $RDS_ENDPOINT -U postgres -d pagila -f ./01-rds/data/pagila-data.sql >> /tmp/db_load.log
