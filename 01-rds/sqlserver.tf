# =================================================================================
# CREATE A SUBNET GROUP USING PRIVATE SUBNETS
# =================================================================================
resource "aws_db_subnet_group" "sqlserver_subnet_group" {
  # Name of the DB subnet group
  name = "sqlserver-subnet-group"

  # Include both private subnets to host the RDS instance across multiple AZs
  subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]

  tags = {
    Name = "sqlserver-subnet-group" # Tag for easy identification
  }
}

# =================================================================================
# CREATE AN RDS SQL SERVER INSTANCE (Standard Edition)
# =================================================================================
resource "aws_db_instance" "sqlserver_rds" {
  identifier            = "sqlserver-db" # Unique RDS instance name
  allocated_storage     = 20             # Initial storage (GiB)
  max_allocated_storage = 50             # Enable storage auto-scaling
  storage_type          = "gp3"          # General Purpose SSD

  instance_class = "db.m5.large"     # Instance size (2 vCPUs, 8 GiB RAM)
  engine         = "sqlserver-se"    # SQL Server Standard Edition
  engine_version = "16.00.4185.3.v1" # SQL Server 2022

  license_model = "license-included"                        # AWS-provided SQL Server licensing
  username      = "sqladmin"                                # SQL Server admin username
  password      = random_password.sqlserver_password.result # Generated admin password

  # Networking configuration
  db_subnet_group_name   = aws_db_subnet_group.sqlserver_subnet_group.name # Deploy into private subnets
  vpc_security_group_ids = [aws_security_group.rds_sg.id]                  # Apply RDS SG for access control
  multi_az               = false                                           # No high availability - turning this on
                                                                           # doubles the buid time and cost.
  publicly_accessible    = false                                           # Restrict to VPC private access only

  # Backup and lifecycle settings
  backup_retention_period = 7     # Retain backups for 7 days
  skip_final_snapshot     = true  # Skip snapshot on deletion
  deletion_protection     = false # Allow deletion

  tags = {
    Name = "sqlserver-rds" # Tag for easier management in AWS Console
  }
}
