# ===============================================================================
# SECURITY GROUP: SQL SERVER ACCESS
# ===============================================================================
# Controls inbound SQL Server access and allows unrestricted outbound
# traffic for database connectivity and updates.
# ===============================================================================

resource "aws_security_group" "rds_sg" {

  # -----------------------------------------------------------------------------
  # SECURITY GROUP METADATA
  # -----------------------------------------------------------------------------
  # Name assigned to the security group
  name = "rds-sg"

  # Description of the security group purpose
  description = "Allow SQL Server inbound access and all outbound traffic"

  # Associate the security group with the RDS VPC
  vpc_id = aws_vpc.rds-vpc.id

  # -----------------------------------------------------------------------------
  # INBOUND RULES
  # -----------------------------------------------------------------------------
  # Allow inbound SQL Server traffic on port 1433
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------------------------------------------------------
  # OUTBOUND RULES
  # -----------------------------------------------------------------------------
  # Allow all outbound traffic from the security group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# ===============================================================================
# SECURITY GROUP: WEB (HTTP AND HTTPS) ACCESS
# ===============================================================================
# Allows inbound web traffic over HTTP and HTTPS and unrestricted
# outbound access for web-facing resources.
# ===============================================================================

resource "aws_security_group" "web_sg" {

  # -----------------------------------------------------------------------------
  # SECURITY GROUP METADATA
  # -----------------------------------------------------------------------------
  # Name assigned to the security group
  name = "web-sg"

  # Description of the security group purpose
  description = "Allow HTTP and HTTPS inbound access and all outbound traffic"

  # Associate the security group with the RDS VPC
  vpc_id = aws_vpc.rds-vpc.id

  # -----------------------------------------------------------------------------
  # INBOUND RULES
  # -----------------------------------------------------------------------------
  # Allow inbound HTTP traffic on port 80
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow inbound HTTPS traffic on port 443
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # -----------------------------------------------------------------------------
  # OUTBOUND RULES
  # -----------------------------------------------------------------------------
  # Allow all outbound traffic from the security group
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web-sg"
  }
}
