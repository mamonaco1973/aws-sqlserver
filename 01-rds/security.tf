############################################
# SECURITY GROUP: HTTP (PORT 80)
############################################

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg" # Name of the security group
  description = "Security group to allow port 5432 access and open all outbound traffic"
  vpc_id      = aws_vpc.rds-vpc.id # Associate SG with the rds VPC

  # Ingress Rule — Allow Postgres traffic from anywhere
  ingress {
    from_port   = 5432          # Starting port — HTTP
    to_port     = 5432          # Ending port — HTTP
    protocol    = "tcp"         # TCP protocol required for HTTP
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Open to all IPv4 addresses — not secure for production
  }

  # Egress Rule — Allow all outbound traffic
  egress {
    from_port   = 0             # Start of port range (0 = all)
    to_port     = 0             # End of port range (0 = all)
    protocol    = "-1"          # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Unrestricted outbound access
  }

  tags = {
    Name = "rds-sg" # Name tag for easier lookup
  }
}

