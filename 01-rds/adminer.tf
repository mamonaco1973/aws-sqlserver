# --------------------------------------------------------------------------------------------------
# FETCH THE AMI ID FOR UBUNTU 24.04 FROM AWS PARAMETER STORE
# --------------------------------------------------------------------------------------------------
data "aws_ssm_parameter" "ubuntu_24_04" {
  # Pull the latest stable Ubuntu 24.04 AMI ID published by Canonical via AWS Systems Manager
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# --------------------------------------------------------------------------------------------------
# RESOLVE THE FULL AMI OBJECT USING THE ID FROM SSM
# --------------------------------------------------------------------------------------------------
data "aws_ami" "ubuntu_ami" {
  # Just in case there are multiple versions, this ensures the most recent one is picked
  most_recent = true

  # Canonical's AWS account ID contains the official Ubuntu AMIs
  owners = ["099720109477"]

  # Only fetch the AMI that matches the ID we just pulled from SSM
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_24_04.value]
  }
}

# --------------------------------------------------------------------------------------------------
# CREATE AN EC2 INSTANCE RUNNING UBUNTU 24.04
# --------------------------------------------------------------------------------------------------
resource "aws_instance" "ubuntu_instance" {
  # Use the resolved AMI ID for Ubuntu 24.04 (from the data source above)
  ami = data.aws_ami.ubuntu_ami.id

  # Choose a micro instance type – good enough for demo workloads, not prod
  instance_type = "t3.micro"

  # Drop this instance in the specified private subnet
  subnet_id = aws_subnet.rds-subnet-1.id

  # Attach both the general SSM security group and one allowing HTTP access (if needed)
  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  # Assign a public IP so it is reachable from the internet
  associate_public_ip_address = true

  # Attach the IAM instance profile that allows this EC2 to talk to SSM
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("./scripts/adminer.tf.template", {
    DBPASSWORD = random_password.sqlserver_password.result # Use generated SQL Server password
    DBUSER     = "sqladmin "                               # Static username for SQL Server
    DBENDPOINT = aws_db_instance.sqlserver_rds.address     # RDS endpoint from the resource above
  })

  # Tag the instance with a recognizable name for filtering or UI display
  tags = {
    Name = "adminer"
  }

  depends_on = [aws_db_instance.sqlserver_rds]
}