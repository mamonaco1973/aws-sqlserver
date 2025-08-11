############################################
# SECURITY GROUP: SQL SERVER ACCESS
############################################

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg" # Name of the security group
  description = "Security group to allow port 5432 access and open all outbound traffic"
  vpc_id      = aws_vpc.rds-vpc.id # Associate SG with the rds VPC

  # Ingress Rule — Allow Postgres traffic from anywhere
  ingress {
    from_port   = 1433          # Starting port — SQL Server
    to_port     = 1433          # Ending port — SQL Server
    protocol    = "tcp"         # TCP protocol required for SQL Server
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

###########################################
# SECURITY GROUP: WEB (HTTP/HTTPS) ACCESS
###########################################

resource "aws_security_group" "web_sg" {
  name        = "web-sg" # Name of the security group
  description = "Allow HTTP (80) and HTTPS (443) inbound; allow all outbound"
  vpc_id      = aws_vpc.rds-vpc.id # Associate SG with the rds VPC

  # Ingress Rule — Allow HTTP traffic from anywhere
  ingress {
    from_port        = 80            # Starting port — HTTP
    to_port          = 80            # Ending port — HTTP
    protocol         = "tcp"         # TCP protocol required for HTTP
    cidr_blocks      = ["0.0.0.0/0"] # ⚠️ Open to all IPv4 — restrict in production
    ipv6_cidr_blocks = ["::/0"]      # ⚠️ Open to all IPv6 — restrict in production
  }

  # Ingress Rule — Allow HTTPS traffic from anywhere
  ingress {
    from_port        = 443           # Starting port — HTTPS
    to_port          = 443           # Ending port — HTTPS
    protocol         = "tcp"         # TCP protocol required for HTTPS
    cidr_blocks      = ["0.0.0.0/0"] # ⚠️ Open to all IPv4 — restrict in production
    ipv6_cidr_blocks = ["::/0"]      # ⚠️ Open to all IPv6 — restrict in production
  }

  # Egress Rule — Allow all outbound traffic
  egress {
    from_port        = 0             # Start of port range (0 = all)
    to_port          = 0             # End of port range (0 = all)
    protocol         = "-1"          # -1 = all protocols
    cidr_blocks      = ["0.0.0.0/0"] # Unrestricted outbound access
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web-sg" # Name tag for easier lookup
  }
}
