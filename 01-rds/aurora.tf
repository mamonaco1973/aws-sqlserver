##############################################
# RDS Cluster Definition (Aurora PostgreSQL) #
##############################################
resource "aws_rds_cluster" "aurora_cluster" {
  # Logical name for the cluster
  cluster_identifier = "aurora-postgres-cluster"

  # Use the Aurora PostgreSQL engine
  engine = "aurora-postgresql"

  # Version must explicitly support Serverless v2
  engine_version = "15.12"

  # Serverless v2 requires engine_mode to be "provisioned"
  engine_mode = "provisioned"

  # Default DB name created in the cluster
  database_name = "postgres"

  # Master credentials — store password securely or generate it
  master_username = "postgres"
  master_password = random_password.aurora_password.result

  # Subnet group — must span at least 2 AZs for Multi-AZ support
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name

  # Attach security group(s) to control inbound/outbound traffic
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Don't force a final snapshot when destroying the cluster (be careful!)
  skip_final_snapshot = true

  # How long to retain backups (in days)
  backup_retention_period = 5

  # Preferred backup window (UTC time)
  preferred_backup_window = "07:00-09:00"

  # ✅ Serverless v2 auto-scaling config — ACUs (Aurora Capacity Units)
  serverlessv2_scaling_configuration {
    min_capacity = 0.5 # Minimum: 0.5 ACUs
    max_capacity = 4.0 # Maximum: 4 ACUs (scale up automatically under load)
  }
}

#####################################################
# PRIMARY INSTANCE — Writer for the Aurora Cluster #
#####################################################
resource "aws_rds_cluster_instance" "aurora_instance_primary" {
  # Unique identifier for the DB instance
  identifier = "aurora-postgres-instance-1"

  # Link to the RDS cluster defined above
  cluster_identifier = aws_rds_cluster.aurora_cluster.id

  # Serverless v2 class required
  instance_class = "db.serverless"

  # Reuse the same engine & version to avoid conflicts
  engine         = aws_rds_cluster.aurora_cluster.engine
  engine_version = aws_rds_cluster.aurora_cluster.engine_version

  # Same subnet group as the cluster — ensures AZ coverage
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name

  # Allow public access if needed — for testing only; disable in production
  publicly_accessible = true

  # Enable Performance Insights for SQL-level metrics
  performance_insights_enabled = true
}

######################################################
# REPLICA INSTANCE — Reader for High Availability    #
# This enables Multi-AZ failover and read scaling    #
######################################################
resource "aws_rds_cluster_instance" "aurora_instance_replica" {
  identifier                   = "aurora-postgres-instance-2"
  cluster_identifier           = aws_rds_cluster.aurora_cluster.id
  instance_class               = "db.serverless"
  engine                       = aws_rds_cluster.aurora_cluster.engine
  engine_version               = aws_rds_cluster.aurora_cluster.engine_version
  db_subnet_group_name         = aws_db_subnet_group.aurora_subnet_group.name
  publicly_accessible          = true
  performance_insights_enabled = true
}

#############################################################
# DB Subnet Group — Required for Aurora to place ENIs       #
# Must include at least two subnets in different AZs        #
#############################################################
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name = "aurora-subnet-group"

  # List of private subnets to deploy the Aurora ENIs into
  subnet_ids = [
    aws_subnet.rds-subnet-1.id,
    aws_subnet.rds-subnet-2.id
  ]

  tags = {
    Name = "Aurora Subnet Group"
  }
}
