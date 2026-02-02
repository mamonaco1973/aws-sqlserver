# ===============================================================================
# SECURE CREDENTIAL GENERATION AND STORAGE FOR RDS
# ===============================================================================
# Generates a secure random password and stores database credentials
# in AWS Secrets Manager for use by dependent resources.
# ===============================================================================

resource "random_password" "sqlserver_password" {

  # -----------------------------------------------------------------------------
  # PASSWORD GENERATION
  # -----------------------------------------------------------------------------
  # Length of the generated password in characters
  length  = 24

  # Exclude special characters for engine and client compatibility
  special = false
}

# ===============================================================================
# SECRETS MANAGER SECRET DEFINITION
# ===============================================================================
# Defines a Secrets Manager secret used to store SQL Server credentials.
# ===============================================================================

resource "aws_secretsmanager_secret" "sqlserver_credentials" {

  # -----------------------------------------------------------------------------
  # SECRET METADATA
  # -----------------------------------------------------------------------------
  # Logical name of the secret in AWS Secrets Manager
  name = "sqlserver-credentials"

  # Disable recovery window to allow immediate deletion on destroy
  recovery_window_in_days = 0
}

# ===============================================================================
# SECRETS MANAGER SECRET VERSION
# ===============================================================================
# Stores the actual credential values as a versioned secret payload.
# ===============================================================================

resource "aws_secretsmanager_secret_version" "sqlserver_credentials_version" {

  # -----------------------------------------------------------------------------
  # SECRET ASSOCIATION
  # -----------------------------------------------------------------------------
  # Reference the previously created Secrets Manager secret
  secret_id = aws_secretsmanager_secret.sqlserver_credentials.id

  # -----------------------------------------------------------------------------
  # SECRET PAYLOAD
  # -----------------------------------------------------------------------------
  # Encode credentials as a JSON document for structured retrieval
  secret_string = jsonencode({
    user     = "sqladmin"
    password = random_password.sqlserver_password.result
    endpoint        = split(":", aws_db_instance.sqlserver_rds.endpoint)[0]
  })
}
