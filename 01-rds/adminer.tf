# ===============================================================================
# UBUNTU 24.04 AMI RESOLUTION
# ===============================================================================
# Retrieves the latest Canonical-published Ubuntu 24.04 AMI using AWS
# Systems Manager Parameter Store and resolves the full AMI object.
# ===============================================================================

data "aws_ssm_parameter" "ubuntu_24_04" {

  # -----------------------------------------------------------------------------
  # AMI PARAMETER LOOKUP
  # -----------------------------------------------------------------------------
  # Canonical-maintained SSM parameter pointing to the latest Ubuntu 24.04
  # amd64 HVM gp3-backed AMI for the current AWS region.
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# ===============================================================================
# UBUNTU 24.04 AMI OBJECT RESOLUTION
# ===============================================================================
# Resolves the full AMI metadata using the image ID retrieved from SSM.
# ===============================================================================

data "aws_ami" "ubuntu_ami" {

  # Select the most recent AMI result if multiple matches are returned
  most_recent = true

  # Restrict AMI ownership to Canonical to avoid untrusted images
  owners = ["099720109477"]

  # Match only the AMI ID returned by the Canonical SSM parameter
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_24_04.value]
  }
}

# ===============================================================================
# ADMINER EC2 INSTANCE (UBUNTU 24.04)
# ===============================================================================
# Launches an Ubuntu 24.04 EC2 instance and bootstraps Adminer for
# connectivity testing against a SQL Server RDS instance.
# ===============================================================================

resource "aws_instance" "ubuntu_instance" {

  # Ubuntu 24.04 AMI resolved from Canonical SSM and AMI data sources
  ami = data.aws_ami.ubuntu_ami.id

  # Instance size suitable for lightweight demo workloads
  instance_type = "t3.micro"

  # Target subnet for EC2 instance placement
  subnet_id = aws_subnet.rds-subnet-1.id

  # Security groups controlling inbound and outbound network access
  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  # Assign a public IPv4 address for direct access if routing permits
  associate_public_ip_address = true

  # IAM instance profile enabling AWS Systems Manager access
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  # -----------------------------------------------------------------------------
  # BOOTSTRAP CONFIGURATION
  # -----------------------------------------------------------------------------
  # Render the Adminer initialization script with database connection
  # parameters injected at instance launch time.
  user_data = templatefile("./scripts/adminer.sh.template", {
    DBPASSWORD = random_password.sqlserver_password.result
    DBUSER     = "sqladmin"
    DBENDPOINT = aws_db_instance.sqlserver_rds.address
  })

  # -----------------------------------------------------------------------------
  # TAGGING
  # -----------------------------------------------------------------------------
  # Name tag for console identification and resource filtering
  tags = {
    Name = "adminer"
  }

  # Ensure the SQL Server RDS instance exists before instance initialization
  depends_on = [aws_db_instance.sqlserver_rds]
}
