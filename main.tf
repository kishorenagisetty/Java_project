//provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_vpc" "TF_VPC" {
  cidr_block       = "${var.vpc-cidr}"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Proj-A_VPC"
  }
}

// Subnets block
resource "aws_subnet" "TF_Public_subnet" {
  vpc_id     = aws_vpc.TF_VPC.id
  count = "${length(var.public_subnet_cidr)}"
  cidr_block = "${element(var.public_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availablity_zones, count.index)}"

  tags = {
    Name = "Proj-A_Public_subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "TF_igw" {
  vpc_id = aws_vpc.TF_VPC.id

  tags = {
    Name = "Proj-A_igw"
  }
}

resource "aws_route_table" "TF_Public_Route-table" {
  vpc_id = aws_vpc.TF_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TF_igw.id
  }

  tags = {
    "Name" = "Proj-A_Public_Route-table"
  }
}

resource "aws_route_table_association" "RT_association_public" {
  count = "${length(var.public_subnet_cidr)}"
  subnet_id  = "${element(aws_subnet.TF_Public_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.TF_Public_Route-table.id
}


// Security groups
resource "aws_security_group" "SG_Public" {
  name = "SG_Public"
  description = "Security group for instances in public subnets"
  vpc_id = aws_vpc.TF_VPC.id

  ingress {
    cidr_blocks = [ "${var.ingress_cidr}", "${var.vpc-cidr}" ]
    description = "SSH"
    from_port = 22
    protocol = "tcp"
    self = false
    to_port = 22
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Custom TCP"
    from_port = 8080
    protocol = "tcp"
    self = false
    to_port = 8080
  }
    ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Custom TCP"
    from_port = 80
    protocol = "tcp"
    self = false
    to_port = 80
  }
    ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Custom TCP"
    from_port = 443
    protocol = "tcp"
    self = false
    to_port = 443
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Custom TCP"
    from_port = 8081
    protocol = "tcp"
    self = false
    to_port = 8081
  }
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

tags = {
  "Name" = "Proj-A_Public_SG"
}
}


// Instances
resource "aws_instance" "TF_Public-Instance_jenkins" {
  ami = "${var.amis}"
  instance_type = "${var.inst_type}"
  count = 1
  associate_public_ip_address = "true"
  availability_zone = "${element(var.availablity_zones, count.index)}"
  subnet_id = "${element(aws_subnet.TF_Public_subnet.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.SG_Public.id}"]
  tags = {
    "Name" = "Jenkins server"
    "Instance_Backup" = "Daily"
  }
  key_name = "${var.key}"
}

resource "aws_instance" "TF_Public-Instance_Deployment" {
  ami = "${var.amis}"
  instance_type = "${var.inst_type}"
  count = 1
  associate_public_ip_address = "true"
  availability_zone = "${element(var.availablity_zones, count.index)}"
  subnet_id = "${element(aws_subnet.TF_Public_subnet.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.SG_Public.id}"]
  tags = {
    "Name" = "Deployment server"
    "Instance_Backup" = "Daily"
  }
  key_name = "${var.key}"
}