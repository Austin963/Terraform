terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0dfcb1ef8550277af"
  instance_type = "t2.micro"
}

resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "instance" {
  name        = "instance"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}
resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXktN/pEG3nQmlHKULLPDjX+0f31DEmpjYR255BamInAajqBmM2UH/ERv8VL/rpbQ7HiHe2/rdq0euwQJDqXURrmni1IMg1OOtOnjPHMxmkMOLoLfjqlZH5Wzkvw4g4D1Nkq+VuUslDfSypBzdpoBeWP9HAU4LvVdrNtPDK0ddacgEkELx8c6b06Ni69MRr52lvXNVxQA3r3ojDIRQ5zQE+TOkcC4vOq4xgO96FD7xP3pLtqg3dwHouhbQrpAqjDPh/CcCs6eWSRJt6ZGkNjKnW3s44cxOVfQcmkJ0aLrQucfjvTZCnTCcGylAK+xWcxN/8ZWPqtJ2fBo08Ql2xarp d00414848@desdemona"
}


resource "aws_instance" "dev" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = "true"
  key_name                    = "tf-key"
  subnet_id                   = aws_subnet.main.id
 user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}
output "instance_ip_addr1" {
  value = aws_instance.dev.public_ip
}

resource "aws_instance" "test" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = "true"
  key_name                    = "tf-key"
  subnet_id                   = aws_subnet.main.id

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}
output "instance_ip_addr2" {
  value = aws_instance.test.public_ip
}

resource "aws_instance" "prod" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = "true"
  key_name                    = "tf-key"
  subnet_id                   = aws_subnet.main.id

  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}
output "instance_ip_addr3" {
  value = aws_instance.prod.public_ip
}
