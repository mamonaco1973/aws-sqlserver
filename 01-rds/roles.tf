# ===============================================================================
# IAM ROLE FOR EC2 SYSTEMS MANAGER (SSM) ACCESS
# ===============================================================================
# Defines an IAM role that allows EC2 instances to register with and be
# managed by AWS Systems Manager.
# ===============================================================================

resource "aws_iam_role" "ec2_ssm_role" {

  # -----------------------------------------------------------------------------
  # ROLE IDENTIFICATION
  # -----------------------------------------------------------------------------
  # Friendly name for the EC2 Systems Manager IAM role
  name = "EC2SSMRole-Adminer"

  # -----------------------------------------------------------------------------
  # TRUST POLICY
  # -----------------------------------------------------------------------------
  # Allow EC2 instances to assume this role via the STS service
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ===============================================================================
# SSM MANAGED POLICY ATTACHMENT
# ===============================================================================
# Attaches the AWS-managed policy required for Systems Manager
# functionality on EC2 instances.
# ===============================================================================

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {

  # IAM role receiving the Systems Manager permissions
  role = aws_iam_role.ec2_ssm_role.name

  # AWS-managed policy enabling SSM core functionality
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ===============================================================================
# IAM INSTANCE PROFILE FOR EC2
# ===============================================================================
# Creates an instance profile allowing EC2 instances to use the
# Systems Manager IAM role.
# ===============================================================================

resource "aws_iam_instance_profile" "ec2_ssm_profile" {

  # Name of the EC2 instance profile
  name = "EC2SSMProfile-Adminer"

  # Associate the SSM IAM role with this instance profile
  role = aws_iam_role.ec2_ssm_role.name
}
