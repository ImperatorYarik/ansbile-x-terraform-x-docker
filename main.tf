provider "aws" {
  region = "eu-central-1"
}
resource "tls_private_key" "Ansible_key" {
  algorithm = "RSA"
}
resource "aws_key_pair" "generated_key" {
  key_name   = "Ansible_key"
  public_key = tls_private_key.Ansible_key.public_key_openssh
  depends_on = [
    tls_private_key.Ansible_key
  ]
}
resource "local_file" "key" {
  content         = tls_private_key.Ansible_key.private_key_pem
  filename        = "Ansible_key.pem"
  file_permission = "0400"
  depends_on = [
    tls_private_key.Ansible_key
  ]
}
resource "aws_vpc" "Cloud_DevOps_Ansible_VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Cloud_DevOps_Ansible_VPC"
  }
}

resource "aws_security_group" "private_ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.Cloud_DevOps_Ansible_VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.Cloud_DevOps_Ansible_VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "AnsibleTask_public_subnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.Cloud_DevOps_Ansible_VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "AnsibleTask_private_subnet"
  }
}
resource "aws_internet_gateway" "AnsibleTask_internet_gateway" {
  vpc_id = aws_vpc.Cloud_DevOps_Ansible_VPC.id

  tags = {
    Name = "AnsibleTask_internet_gateway"
  }
}
resource "aws_route_table" "AnsibleTask_route-table" {
  vpc_id = aws_vpc.Cloud_DevOps_Ansible_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.AnsibleTask_internet_gateway.id
  }

  tags = {
    Name = "AnsibleTask_route-table"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.AnsibleTask_route-table.id
}
resource "aws_instance" "control_example_com" {
  ami             = "ami-01e444924a2233b07"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.private_ssh_access.id]
  subnet_id       = aws_subnet.public.id
  key_name        = aws_key_pair.generated_key.key_name

  tags = {
    Name = "control.example.com"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "aws_instance" "node1_example_com" {
  ami             = "ami-01e444924a2233b07"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.private_ssh_access.id]
  subnet_id       = aws_subnet.public.id
  key_name        = aws_key_pair.generated_key.key_name



  tags = {
    Name = "node1.example.com"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "aws_instance" "node2_example_com" {
  ami             = "ami-01e444924a2233b07"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.private_ssh_access.id]
  subnet_id       = aws_subnet.public.id
  key_name        = aws_key_pair.generated_key.key_name


  tags = {
    Name = "node2.example.com"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}