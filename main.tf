# Cloud provider
provider "aws" = {
    region = "us-east-1"
    access_key = 
    secret_key =
}


# Create a vpc
resource "aws_vpc" "alt_school_project" {
  cidr_block = "10.0.0.0/16"

tags = {
    name = ""
}

}

# Create a two subnet
resource "aws_subnet" "public_webserver_1" {
    vpc_id = aws_vpc.alt_school_project.vpc_id
    availability_zone = "us-east-1a"
    #cidr_block = 
}

resource "aws_subnet" "public_webserver_2" {
    vpc_id = aws_vpc.alt_school_project.id
    availability_zone = "us-east-1b"
    #cidr_block = 
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.alt_school_project.id
    availability_zone = "us-east-1a"
    #cidr_block = ""
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.altschool_project.vpc.id
    availability_zone = "us-east-1b"
    #cidr_block = ""
}


# Create an Internet Gateway
resource "aws_internet_gateway" "alt_school_project_igw" {
    vpc_id = aws.vpc.alts_school_project.vpc.id   
}

# Create a Security Group for alt_school_project

resource "aws_security_group" "alt_school_project_sg" {
    name = "alt_school_project_sg"
    vpc_id = myvars.tfvars.vpc.id
    description = "Allow HTTPS, HTTP and SSH"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        from_port = 80
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    eggress {
        from_port = 
        to _port =
        protocol = ""
        cidr_block = [0.0.0.0/0]
    }
}

# Deploy Ec2 instances in the public and private subnets

resource "aws_instance" "public_server-1" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    key_name = "newkey-e1.pem"
    vpc_security_group_id = [aws_security_group.alt_school_project_sg.id]
    associate_public_ip_address = false
}

resource "aws_instance" "public_server-1" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    key_name = "newkey-e1.pem"
    vpc_security_group_id = [aws_security_group.alt_school_project_sg.id]
    associate_public_ip_address = false
}

