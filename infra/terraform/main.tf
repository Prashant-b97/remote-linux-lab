terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "remote-linux-lab-vpc"
  })
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = merge(var.tags, {
    Name = "remote-linux-lab-igw"
  })
}

resource "aws_subnet" "lab" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "remote-linux-lab-subnet"
  })
}

resource "aws_route_table" "lab" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = merge(var.tags, {
    Name = "remote-linux-lab-rt"
  })
}

resource "aws_route_table_association" "lab" {
  subnet_id      = aws_subnet.lab.id
  route_table_id = aws_route_table.lab.id
}

resource "aws_key_pair" "lab" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)

  tags = merge(var.tags, {
    Name = "remote-linux-lab-key"
  })
}

resource "aws_security_group" "lab" {
  name        = "remote-linux-lab"
  description = "Allow SSH from workstation"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "remote-linux-lab-sg"
  })
}

resource "aws_instance" "lab" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.lab.id
  vpc_security_group_ids      = [aws_security_group.lab.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.lab.key_name

  user_data = <<-EOT
              #!/usr/bin/env bash
              set -euxo pipefail
              export DEBIAN_FRONTEND=noninteractive
              apt-get update
              apt-get install -y --no-install-recommends \
                bash \
                ca-certificates \
                curl \
                dnsutils \
                git \
                htop \
                iproute2 \
                iputils-ping \
                jq \
                locales \
                net-tools \
                openssh-server \
                python3 \
                sudo \
                tmux \
                unzip \
                vim \
                nano
              locale-gen en_US.UTF-8
              systemctl enable ssh
              EOT

  tags = merge(var.tags, {
    Name = "remote-linux-lab-instance"
  })
}

output "lab_public_ip" {
  value       = aws_instance.lab.public_ip
  description = "Public IP address of the lab VM"
}

output "lab_public_dns" {
  value       = aws_instance.lab.public_dns
  description = "Public DNS name of the lab VM"
}

output "lab_ssh_command" {
  value = "ssh -i ${var.public_key_path} ubuntu@${aws_instance.lab.public_dns}"
  description = "Sample SSH command for the lab instance"
}
