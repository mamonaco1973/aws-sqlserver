############################################
# VPC CONFIGURATION FOR RDS INFRASTRUCTURE
############################################

# Define the main Virtual Private Cloud (VPC)
resource "aws_vpc" "rds-vpc" {
  cidr_block           = "10.0.0.0/24" # Assign a /24 CIDR block (256 IPs total) for internal networking
  enable_dns_support   = true          # Enable internal DNS resolution for EC2 instances
  enable_dns_hostnames = true          # Allow EC2 instances to be assigned DNS hostnames
  tags = {
    Name          = "rds-vpc"    # Name tag for resource identification
  }
}

############################################
# INTERNET GATEWAY FOR OUTBOUND ACCESS
############################################

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "rds-igw" {
  vpc_id = aws_vpc.rds-vpc.id # Attach IGW to the main VPC
  tags = {
    Name = "rds-igw" # Name tag for resource identification
  }
}

############################################
# PUBLIC ROUTE TABLE FOR INTERNET ACCESS
############################################

# Create a new route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rds-vpc.id # Associate route table with the main VPC
  tags = {
    Name = "public-route-table" # Name tag for route table
  }
}

# Create a default route to forward all internet-bound traffic to the IGW
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id       # Bind route to the public route table
  destination_cidr_block = "0.0.0.0/0"                     # Catch-all route for all IPv4 traffic
  gateway_id             = aws_internet_gateway.rds-igw.id # Route traffic to the Internet Gateway
}

############################################
# PUBLIC SUBNET DEFINITIONS
############################################

# Define the public subnet (AZ: us-east-2a)
resource "aws_subnet" "rds-subnet-1" {
  vpc_id                  = aws_vpc.rds-vpc.id # Associate subnet with the main VPC
  cidr_block              = "10.0.0.0/26"      # Allocate 64 IP addresses (10.0.0.0–10.0.0.63)
  map_public_ip_on_launch = true               # Automatically assign public IPs to instances
  availability_zone       = "us-east-2a"       # Place subnet in the first AZ
  tags = {
    Name = "rds-subnet-1" # Name tag for subnet identification
  }
}

############################################
# ROUTE TABLE ASSOCIATIONS WITH SUBNETS
############################################

# Associate the public route table with the first public subnet
resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.rds-subnet-1.id # Target: rds-subnet-1
  route_table_id = aws_route_table.public.id  # Use the public route table
}


