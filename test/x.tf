provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-insecure-bucket"
  acl    = "public-read"  # Vulnerability: Publicly readable bucket
}

resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Overly permissive security group"
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Vulnerability: Allows all incoming traffic
  }
}

resource "aws_instance" "insecure_instance" {
  ami           = "ami-123456718"
  instance_type = "t2.micro"
  key_name      = "hardcoded-key"  # Vulnerability: Hardcoded SSH key
  security_groups = [aws_security_group.open_sg.name]
}

resource "aws_iam_policy" "overprivileged_policy" {
  name        = "overprivileged"
  description = "Policy with overly broad permissions"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",  # Vulnerability: Grants all permissions
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_iam_user" "bad_user" {
  name = "insecure-user"
}

resource "aws_iam_user_policy_attachment" "bad_attachment" {
  user       = aws_iam_user.bad_user.name
  policy_arn = aws_iam_policy.overprivileged_policy.arn
}
