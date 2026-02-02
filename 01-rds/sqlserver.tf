# ===============================================================================
# DATABASE SUBNET GROUP (PRIVATE SUBNETS)
# ===============================================================================
# Defines a DB subnet group spanning private subnets for RDS placement
# across multiple availability zones.
# ===============================================================================

resource "aws_db_subnet_group" "sqlserver_subnet_group" {

  # -----------------------------------------------------------------------------
  # SUBNET GROUP IDENTIFICATION
  # -----------------------------------------------------------------------------
  # Name assigned to the DB subnet group
  name = "sqlserver-subnet-group"

  # -----------------------------------------------------------------------------
  # SUBNET MEMBERSHIP
  # -----------------------------------------------------------------------------
  # Private subnets used for RDS instance network placement
  subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]

  tags = {
    Name = "sqlserver-subnet-group"
  }
}

# ===============================================================================
# RDS SQL SERVER INSTANCE (STANDARD EDITION)
# ===============================================================================
# Provisions a Microsoft SQL Server Standard Edition RDS instance
# deployed into private subnets within the VPC.
# ===============================================================================

resource "aws_db_instance" "sqlserver_rds" {

  # -----------------------------------------------------------------------------
  # INSTANCE IDENTIFICATION
  # -----------------------------------------------------------------------------
  # Unique identifier for the RDS instance
  identifier = "sqlserver-db"

  # -----------------------------------------------------------------------------
  # STORAGE CONFIGURATION
  # -----------------------------------------------------------------------------
  # Initial allocated storage in GiB
  allocated_storage = 20

  # Enable storage auto-scaling up to the specified limit
  max_allocated_storage = 50

  # General Purpose SSD storage type
  storage_type = "gp3"

  # -----------------------------------------------------------------------------
  # ENGINE CONFIGURATION
  # -----------------------------------------------------------------------------
  # RDS instance class sizing
  instance_class = "db.m5.large"

  # Microsoft SQL Server Standard Edition engine
  engine = "sqlserver-se"

  # SQL Server 2022 engine version
  # engine_version = "16.00.4185.3.v1"

  # AWS-managed SQL Server licensing model
  license_model = "license-included"

  # -----------------------------------------------------------------------------
  # AUTHENTICATION
  # -----------------------------------------------------------------------------
  # Administrative username for SQL Server
  username = "sqladmin"

  # Generated administrative password
  password = random_password.sqlserver_password.result

  # -----------------------------------------------------------------------------
  # NETWORKING
  # -----------------------------------------------------------------------------
  # Deploy the RDS instance into private subnets
  db_subnet_group_name = aws_db_subnet_group.sqlserver_subnet_group.name

  # Apply the RDS security group for access control
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Disable Multi-AZ to reduce cost and provisioning time
  multi_az = false

  # Prevent public internet access to the RDS instance
  publicly_accessible = false

  # -----------------------------------------------------------------------------
  # BACKUP AND LIFECYCLE
  # -----------------------------------------------------------------------------
  # Number of days to retain automated backups
  backup_retention_period = 7

  # Skip final snapshot on deletion
  skip_final_snapshot = true

  # Disable deletion protection
  deletion_protection = false

  tags = {
    Name = "sqlserver-rds"
  }
}
