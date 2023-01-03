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

resource "aws_subnet" "private_webserver_1" {
    vpc_id = aws_vpc.alt_school_project.id
    availability_zone = "us-east-1a"
    #cidr_block = ""
}

resource "aws_subnet" "private_webserver_2" {
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

resource "aws_instance" "public_server_1" {
    ami = "ami-0574da719dca65348"
    associate_public_ip_address = true
    instance_type = "t2.micro"
    key_name = "newkey-e1.pem"
    subnet_id = aws.alt_school_project_public_webserver-1.id
    vpc_security_group_id = [aws_security_group.alt_school_project_sg.id]
}

resource "aws_instance" "public_server-2" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    subnet_id = aws.alt_school_project_public_webserver-2.id
    key_name = "newkey-e1.pem"
    vpc_security_group_id = [aws_security_group.alt_school_project_sg.id]
    associate_public_ip_address = true
}

resource "aws_instance" "private_server-1" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    subnet_id = aws.alt_school_project_private_webserver-1.id 
    key_name = "newkey-e1.pem"
    vpc_security_group_id = [aws_security_group.alt_school_project_sg.id]
    associate_public_ip_address = false
}

resource "aws_instance" "private_server-2" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    subnet_id = aws.alt_school_project_private_webserver-2.id 
    key_name = "newkey-e1.pem"
    vpc_security_group_id = [aws_security_group.alt_school_project_sg.id]
    associate_public_ip_address = false
}


# Create an Elastic Ip Address
resource "aws_eip" "alt_school_project_eip_1" {
    vpc = true
}

resource "aws_eip" "alt_school_project_eip_2" {
    vpc = true
}

# Create a NatGateway then attach the EIP
resource "aws_nat_gateway" "nat_public_server_1"




