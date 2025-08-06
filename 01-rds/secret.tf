##################################################
# SECURELY GENERATE AND STORE CREDENTIALS FOR RDS
##################################################

# Generate a secure random alphanumeric password
resource "random_password" "sqlserver_password" {
  length  = 24    # Total password length: 24 characters
  special = false # Exclude special characters (alphanumeric only for compatibility)
}

# Define a new Secrets Manager secret to store RDS credentials
resource "aws_secretsmanager_secret" "sqlserver_credentials" {
  name                    = "sqlserver-credentials" # Logical name for the secret in AWS Secrets Manager
  recovery_window_in_days = 0
}

# Store the actual credential values in the secret (versioned)
resource "aws_secretsmanager_secret_version" "sqlserver_credentials_version" {
  secret_id = aws_secretsmanager_secret.sqlserver_credentials.id # Reference the previously created secret

  # Encode credentials as a JSON string and store as the secret value
  secret_string = jsonencode({
    user            = "sqladmin"                                # Static username for SQL Server admin
    password        = random_password.sqlserver_password.result # Dynamic, securely generated password
    endpoint        = split(":", aws_rds_cluster.sqlserver_cluster.endpoint)[0]
  })
}

