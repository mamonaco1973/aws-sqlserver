# ===============================================================================
# VPC CONFIGURATION FOR RDS INFRASTRUCTURE
# ===============================================================================
# Defines the networking foundation required for RDS and Aurora resources,
# including the VPC, subnets, routing, and outbound internet connectivity.
# ===============================================================================

resource "aws_vpc" "rds-vpc" {

  # -----------------------------------------------------------------------------
  # VPC CONFIGURATION
  # -----------------------------------------------------------------------------
  # IPv4 CIDR block allocated to the VPC address space
  cidr_block           = "10.0.0.0/24"

  # Enable internal DNS resolution within the VPC
  enable_dns_support   = true

  # Enable DNS hostnames for instances launched in the VPC
  enable_dns_hostnames = true

  tags = {
    Name = "rds-vpc"
  }
}

# ===============================================================================
# INTERNET GATEWAY FOR OUTBOUND ACCESS
# ===============================================================================
# Provides direct internet connectivity for public subnets in the VPC.
# ===============================================================================

resource "aws_internet_gateway" "rds-igw" {

  # -----------------------------------------------------------------------------
  # ATTACHMENT
  # -----------------------------------------------------------------------------
  # Attach the internet gateway to the target VPC
  vpc_id = aws_vpc.rds-vpc.id

  tags = {
    Name = "rds-igw"
  }
}

# ===============================================================================
# PUBLIC ROUTE TABLE FOR INTERNET ACCESS
# ===============================================================================
# Routes traffic from public subnets to the internet gateway.
# ===============================================================================

resource "aws_route_table" "public" {

  # -----------------------------------------------------------------------------
  # ASSOCIATION TARGET
  # -----------------------------------------------------------------------------
  # Associate the route table with the VPC
  vpc_id = aws_vpc.rds-vpc.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "default_route" {

  # -----------------------------------------------------------------------------
  # DEFAULT INTERNET ROUTE
  # -----------------------------------------------------------------------------
  # Route table receiving the default route
  route_table_id         = aws_route_table.public.id

  # Catch-all destination for all IPv4 traffic
  destination_cidr_block = "0.0.0.0/0"

  # Forward traffic to the internet gateway
  gateway_id             = aws_internet_gateway.rds-igw.id
}

# ===============================================================================
# PUBLIC SUBNET DEFINITIONS
# ===============================================================================
# Defines a public subnet for internet-facing resources and NAT placement.
# ===============================================================================

resource "aws_subnet" "rds-subnet-1" {

  # -----------------------------------------------------------------------------
  # SUBNET PLACEMENT
  # -----------------------------------------------------------------------------
  # Parent VPC for the subnet
  vpc_id                  = aws_vpc.rds-vpc.id

  # CIDR block assigned to the subnet
  cidr_block              = "10.0.0.0/26"

  # Assign public IPv4 addresses on instance launch
  map_public_ip_on_launch = true

  # Availability zone placement
  availability_zone       = "us-east-2a"

  tags = {
    Name = "rds-subnet-1"
  }
}

# ===============================================================================
# ROUTE TABLE ASSOCIATIONS WITH SUBNETS
# ===============================================================================
# Associates the public subnet with the public route table.
# ===============================================================================

resource "aws_route_table_association" "public_rta_1" {

  # -----------------------------------------------------------------------------
  # PUBLIC SUBNET ASSOCIATION
  # -----------------------------------------------------------------------------
  # Subnet to associate with the public route table
  subnet_id      = aws_subnet.rds-subnet-1.id

  # Route table providing internet egress
  route_table_id = aws_route_table.public.id
}

# ===============================================================================
# NAT GATEWAY CONFIGURATION
# ===============================================================================
# Provides outbound internet access for private subnets without exposing them
# directly to inbound internet traffic.
# ===============================================================================

resource "aws_eip" "nat_eip" {

  # -----------------------------------------------------------------------------
  # ELASTIC IP ALLOCATION
  # -----------------------------------------------------------------------------
  # Allocate a public Elastic IP for the NAT gateway
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "rds-nat" {

  # -----------------------------------------------------------------------------
  # NAT PLACEMENT
  # -----------------------------------------------------------------------------
  # Bind the NAT gateway to the allocated Elastic IP
  allocation_id = aws_eip.nat_eip.id

  # Place the NAT gateway in a public subnet
  subnet_id     = aws_subnet.rds-subnet-1.id

  tags = {
    Name = "rds-nat-gateway"
  }
}

# ===============================================================================
# PRIVATE SUBNET DEFINITIONS
# ===============================================================================
# Defines private subnets for database resources and backend components.
# ===============================================================================

resource "aws_subnet" "private-subnet-1" {

  # -----------------------------------------------------------------------------
  # SUBNET PLACEMENT
  # -----------------------------------------------------------------------------
  # Parent VPC for the subnet
  vpc_id            = aws_vpc.rds-vpc.id

  # CIDR block assigned to the private subnet
  cidr_block        = "10.0.0.64/26"

  # Availability zone placement
  availability_zone = "us-east-2a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-2" {

  # -----------------------------------------------------------------------------
  # SUBNET PLACEMENT
  # -----------------------------------------------------------------------------
  # Parent VPC for the subnet
  vpc_id            = aws_vpc.rds-vpc.id

  # CIDR block assigned to the private subnet
  cidr_block        = "10.0.0.128/26"

  # Availability zone placement
  availability_zone = "us-east-2b"

  tags = {
    Name = "private-subnet-2"
  }
}

# ===============================================================================
# PRIVATE ROUTE TABLE
# ===============================================================================
# Routes private subnet outbound traffic to the NAT gateway for egress.
# ===============================================================================

resource "aws_route_table" "private" {

  # -----------------------------------------------------------------------------
  # ASSOCIATION TARGET
  # -----------------------------------------------------------------------------
  # Associate the private route table with the VPC
  vpc_id = aws_vpc.rds-vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "private_default_route" {

  # -----------------------------------------------------------------------------
  # DEFAULT NAT ROUTE
  # -----------------------------------------------------------------------------
  # Route table receiving the default route
  route_table_id         = aws_route_table.private.id

  # Catch-all destination for all IPv4 traffic
  destination_cidr_block = "0.0.0.0/0"

  # Forward traffic to the NAT gateway
  nat_gateway_id         = aws_nat_gateway.rds-nat.id
}

# ===============================================================================
# PRIVATE ROUTE TABLE ASSOCIATIONS
# ===============================================================================
# Associates private subnets with the private route table.
# ===============================================================================

resource "aws_route_table_association" "private_rta_1" {

  # -----------------------------------------------------------------------------
  # PRIVATE SUBNET ASSOCIATION
  # -----------------------------------------------------------------------------
  # Private subnet to associate with the private route table
  subnet_id      = aws_subnet.private-subnet-1.id

  # Route table providing NAT egress
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_rta_2" {

  # -----------------------------------------------------------------------------
  # PRIVATE SUBNET ASSOCIATION
  # -----------------------------------------------------------------------------
  # Private subnet to associate with the private route table
  subnet_id      = aws_subnet.private-subnet-2.id

  # Route table providing NAT egress
  route_table_id = aws_route_table.private.id
}
