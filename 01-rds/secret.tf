##################################################
# SECURELY GENERATE AND STORE CREDENTIALS FOR RDS
##################################################

# Generate a secure random alphanumeric password
resource "random_password" "aurora_password" {
  length  = 24    # Total password length: 24 characters
  special = false # Exclude special characters (alphanumeric only for compatibility)
}

# Define a new Secrets Manager secret to store RDS credentials
resource "aws_secretsmanager_secret" "aurora_credentials" {
  name                    = "aurora-credentials" # Logical name for the secret in AWS Secrets Manager
  recovery_window_in_days = 0
}

# Store the actual credential values in the secret (versioned)
resource "aws_secretsmanager_secret_version" "aurora_credentials_version" {
  secret_id = aws_secretsmanager_secret.aurora_credentials.id # Reference the previously created secret

  # Encode credentials as a JSON string and store as the secret value
  secret_string = jsonencode({
    user            = "postgres"                             # Static username for the Packer user
    password        = random_password.aurora_password.result # Dynamic, securely generated password
    endpoint        = split(":", aws_rds_cluster.aurora_cluster.endpoint)[0]
  })
}

# Generate a secure random alphanumeric password
resource "random_password" "postgres_password" {
  length  = 24    # Total password length: 24 characters
  special = false # Exclude special characters (alphanumeric only for compatibility)
}

# Define a new Secrets Manager secret to store RDS credentials
resource "aws_secretsmanager_secret" "postgres_credentials" {
  name                    = "postgres-credentials" # Logical name for the secret in AWS Secrets Manager
  recovery_window_in_days = 0
}

# Store the actual credential values in the secret (versioned)
resource "aws_secretsmanager_secret_version" "postgres_credentials_version" {
  secret_id = aws_secretsmanager_secret.postgres_credentials.id # Reference the previously created secret

  # Encode credentials as a JSON string and store as the secret value
  secret_string = jsonencode({
    user     = "postgres"                             # Static username for the Packer user
    password = random_password.postgres_password.result # Dynamic, securely generated password
    endpoint = split(":", aws_db_instance.postgres_rds.endpoint)[0]
  })
}
