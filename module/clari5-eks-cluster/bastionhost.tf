# data "aws_ami" "ubuntu" {
#   owners = ["099720109477"]
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }
#   filter {
#     name = "root-device-type"
#     values = ["ebs"]
#   }
#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }
# }

resource "aws_instance" "bastion_host" {
  subnet_id     = module.vpc.private_subnets[0]
  ami           = "ami-0f8ca728008ff5af4" #"ami-043a72cf696697251"
  key_name      = aws_key_pair.generated_key.id
  vpc_security_group_ids = [aws_security_group.bastion_host_sg.id]
  instance_type = var.bastion_host_instance_type
  depends_on = [
    aws_security_group.bastion_host_sg,
    aws_iam_role.bastion-ssm-role
  ]
  iam_instance_profile = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-bastion-instance-profile"
  tags = merge(tomap({
    Name = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-bastion-host",
    environment = "production",
    lastreviewed = "-",
    project = "-",
    backup = "-"
    os = "Linux"
    auto-stop-start	= "-",
    auditlevel = "-",
    costcenter = "-",
    owner = "-"
    }), var.resource_tags
    
  )
}
resource "aws_security_group" "bastion_host_sg" {
  name = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-bastion-host-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${var.vpc_cidr}"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = var.resource_tags
}

resource "aws_iam_instance_profile" "bastion-instance-profile" {
  name = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-bastion-instance-profile"
  role = aws_iam_role.bastion-ssm-role.name
  tags = var.resource_tags
}

resource "aws_iam_role" "bastion-ssm-role" {
  name                = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-bastion-host-iam-role"
  assume_role_policy  = data.aws_iam_policy_document.instance-assume-role-policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "${aws_iam_policy.ssm_inline_policy.arn}"
  ]
  tags = var.resource_tags
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ssm_inline_policy" {
  name = "policy-381966"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ssmmessages:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  tags = var.resource_tags
}