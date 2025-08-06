# =================================================================================
# CREATE A SUBNET GROUP USING PRIVATE SUBNETS
# =================================================================================
resource "aws_db_subnet_group" "sqlserver_subnet_group" {
  name = "sqlserver-subnet-group"
  subnet_ids = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]
  tags = {
    Name = "sqlserver-subnet-group"
  }
}

# =================================================================================
# CREATE AN RDS SQL SERVER INSTANCE (Express Edition)
# =================================================================================
resource "aws_db_instance" "sqlserver_rds" {
  identifier            = "sqlserver-db"
  allocated_storage     = 20 # 20GB is minimum for RDS SQL Server
  max_allocated_storage = 50 # Allow storage auto-scaling
  storage_type          = "gp3"
  engine                = "sqlserver-se"    # Standard Edition
  engine_version        = "16.00.4185.3.v1" # Specify the SQL Server version

  instance_class = "db.t3.small" # 2 vCPUs, 2 GiB RAM
  license_model  = "license-included"
  username       = "sqladmin"                                # Static username for SQL Server admin
  password       = random_password.sqlserver_password.result # Use the generated password

  db_subnet_group_name    = aws_db_subnet_group.sqlserver_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id] # Use the security group defined earlier
  multi_az                = true                           # High availability
  publicly_accessible     = false                          # Private subnets only
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 7

  # Monitoring
  monitoring_interval = 60

  tags = {
    Name = "sqlserver-rds"
  }
}
