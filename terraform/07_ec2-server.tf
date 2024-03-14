data "aws_ami" "devops_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "devops_sg" {
  name        = "devops_allow_egress_sg"
  description = "Only allow egress traffic for devops security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "devops_allow_egress_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_for_devops" {
  security_group_id = aws_security_group.devops_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4_for_smtp" {
  security_group_id = aws_security_group.devops_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 25
  ip_protocol = "tcp"
  to_port     = 25
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4_for_kubernetes" {
  security_group_id = aws_security_group.devops_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 30000
  ip_protocol = "tcp"
  to_port     = 32768
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4_for_application" {
  security_group_id = aws_security_group.devops_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3000
  ip_protocol = "tcp"
  to_port     = 10000
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4_for_http" {
  security_group_id = aws_security_group.devops_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4_for_https" {
  security_group_id = aws_security_group.devops_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4_for_kubeapi_server" {
  security_group_id = aws_security_group.devops_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 6443
  ip_protocol = "tcp"
  to_port     = 6443
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4_for_smtps_email" {
  security_group_id = aws_security_group.devops_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 465
  ip_protocol = "tcp"
  to_port     = 465
}

resource "aws_iam_role" "devops_role" {
  name = "devops-iam-role"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = "sts:AssumeRole",
        "Effect" = "Allow",
        "Sid"    = "",
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.devops_role.name
}

resource "aws_iam_instance_profile" "devops_instance_profile" {
  name = "devops-instance-profile"
  role = aws_iam_role.devops_role.name
}

resource "aws_instance" "devops_ami" {
  for_each               = var.ec2
  ami                    = data.aws_ami.devops_image.id
  instance_type          = each.value["instance_type"]
  iam_instance_profile   = aws_iam_instance_profile.devops_instance_profile.name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  subnet_id              = aws_subnet.public_1.id
  key_name               = "EC2JakartaKey"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = each.value["tags"]
}
