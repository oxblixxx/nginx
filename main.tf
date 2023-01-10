# Cloud provider
provider "aws"  {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}


# Create a vpc
resource "aws_vpc" "altschool-project-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

tags = {
    name = "altschool-project-vpc"
}

}

# Create two subnet(public and private) and the two az(us-east-1a && us-east-1b) 

# public-subnet-1(us-east-1a)

resource "aws_subnet" "altschool-project-public-subnet-1" {
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    cidr_block = "10.0.16.0/28" 
    vpc_id = aws_vpc.altschool-project-vpc.id
    tags = {
      "Name" = "altschool-public-subnet-1"
    }
}

# public-subnet-1(us-east-1b)

resource "aws_subnet" "altschool-project-public-subnet-2" {
    availability_zone = "us-east-1b"
    cidr_block = "10.0.32.0/28"
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.altschool-project-vpc.id
    tags = {
      "Name" = "altschool-public-subnet-2"
    }
}

# private-subnet-1(us-east-1a)

resource "aws_subnet" "altschool-project-private-subnet-1" {
    availability_zone = "us-east-1a"
    cidr_block = "10.0.48.0/28"
    map_public_ip_on_launch = false
    vpc_id = aws_vpc.altschool-project-vpc.id
    tags = {
      "Name" = "altschool-private-subnet-1"
    }
}
# private-subnet-1(us-east-1b)

resource "aws_subnet" "altschool-project-private-subnet-2" {
    availability_zone = "us-east-1b"
    cidr_block = "10.0.64.0/28"
    map_public_ip_on_launch = false
    vpc_id = aws_vpc.altschool-project-vpc.id
    tags = {
      "Name" = "altschool-private-subnet-2"
    }
}


# Create an Internet Gateway
resource "aws_internet_gateway" "altschool-project-igw" {
    vpc_id = aws_vpc.altschool-project-vpc.id  
}


# Create a network ACL for the subnet
resource "aws_network_acl" "altschool-project-ACL" {
    vpc_id = aws_vpc.altschool-project-vpc.id
    subnet_ids = [aws_subnet.altschool-project-private-subnet-1.id, aws_subnet.altschool-project-private-subnet-2.id]

    ingress {
        rule_no    = 100
        protocol   = "-1"
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    egress {
        rule_no    = 100
        protocol   = "-1"
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }
}


# Create a Security Group for alt_school_project

resource "aws_security_group" "altschool-project-sg" {
    description = "Allow HTTPS, HTTP and SSH"
    name = "alt_school_project_sg"
    vpc_id = aws_vpc.altschool-project-vpc.id

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH"
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }

    ingress {
        from_port = 443
        description = "HTTPS"
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
       security_groups = [aws_security_group.altschool-project-lb-sg.id]
    }

    ingress {
        from_port = 80
        description = "HTTP"
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        security_groups = [aws_security_group.altschool-project-lb-sg.id]
    }

    egress {
        from_port = 0 
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      "Name" = "altschool-project-sg"
    }
}




# Create Route tables associations with Nat gateways for private subnet and igw for public subnet
resource "aws_route_table" "altschool-project-public-subnet-rtb" {
    vpc_id = aws_vpc.altschool-project-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.altschool-project-igw.id 
    }
}

resource "aws_route_table" "altschool-project-private-subnet-1-rtb" {
    vpc_id = aws_vpc.altschool-project-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.altschool-project-ngw-server-2.id 
    }
}


resource "aws_route_table" "altschool-project-private-subnet-2-rtb" {
    vpc_id = aws_vpc.altschool-project-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.altschool-project-ngw-server-2.id 
    }
}


# Associate created Route tables with public subnet and private subnet

# Associate Public-subnet-1
resource "aws_route_table_association" "altschool-project-public-subnet-1-rtb-associate" {
    subnet_id = aws_subnet.altschool-project-public-subnet-1.id
    route_table_id =  aws_route_table.altschool-project-public-subnet-rtb.id
}

# Associate Public-Subnet-2

resource "aws_route_table_association" "altschool-project-public-subnet-2-rtb-associate" {
    subnet_id = aws_subnet.altschool-project-public-subnet-2.id
    route_table_id =  aws_route_table.altschool-project-public-subnet-rtb.id
}

# Associate Private-Subnet-1

resource "aws_route_table_association" "altschool-project-private-subnet-1-rtb-associate" {
    subnet_id = aws_subnet.altschool-project-private-subnet-1.id
    route_table_id =  aws_route_table.altschool-project-private-subnet-1-rtb.id
}

# Associate Private Subnet-2

resource "aws_route_table_association" "altschool-project-private-subnet-2-rtb-associate" {
    subnet_id = aws_subnet.altschool-project-private-subnet-2.id
    route_table_id =  aws_route_table.altschool-project-private-subnet-2-rtb.id
}


# Create an Elastic Ip Address
resource "aws_eip" "altschool-project-eip-1" {
    vpc = true
    depends_on = [aws_internet_gateway.altschool-project-igw]
}

resource "aws_eip" "altschool-project-eip-2" {
    vpc = true
    depends_on = [aws_internet_gateway.altschool-project-igw]

}

# Create a NatGateway then attach the EIP
resource "aws_nat_gateway" "altschool-project-ngw-server-1" {
    allocation_id = aws_eip.altschool-project-eip-1.id
    subnet_id = aws_subnet.altschool-project-public-subnet-1.id  
    depends_on = [aws_internet_gateway.altschool-project-igw]

}

resource "aws_nat_gateway" "altschool-project-ngw-server-2" {
    allocation_id = aws_eip.altschool-project-eip-2.id
    subnet_id = aws_subnet.altschool-project-public-subnet-2.id   
    depends_on = [aws_internet_gateway.altschool-project-igw]
}

# Create a Network Interface

## Network Interface for Private Subnet 1
resource "aws_network_interface" "altschool-project-private-network-interface-1" {
    private_ips = ["10.0.48.10"]
    subnet_id = aws_subnet.altschool-project-private-subnet-1.id
    security_groups = [aws_security_group.altschool-project-sg.id]
    ipv4_prefix_count = 0
}

## Network Interface for Private Subnet 2

resource "aws_network_interface" "altschool-project-private-network-interface-2" {
    subnet_id = aws_subnet.altschool-project-private-subnet-2.id
    private_ips = ["10.0.64.10"]
    security_groups = [aws_security_group.altschool-project-sg.id]
}


## Network Interface for Public Subnet 1
resource "aws_network_interface" "altschool-project-public-network-interface-1" {
    subnet_id = aws_subnet.altschool-project-public-subnet-1.id
    security_groups = [aws_security_group.altschool-project-sg.id]
}

resource "aws_network_interface" "altschool-project-public-network-interface-2" {
    subnet_id = aws_subnet.altschool-project-public-subnet-2.id
    security_groups = [aws_security_group.altschool-project-sg.id]
}

# Deploy Ec2 instances in the public and private subnets

#resource "aws_instance" "altschool-project-public-server-1" {
#    ami = "ami-0574da719dca65348"
#    availability_zone = "us-east-1a"
#    instance_type = "t2.micro"
#    key_name = "newkey-e1"

## Network interface for public server
#    network_interface {
#        network_interface_id = aws_network_interface.altschool-project-public-network-interface-1.id
#        device_index = 0
#    }

#}

#resource "aws_instance" "altschool-project-public-server-2" {
#    ami = "ami-0574da719dca65348"
#    instance_type = "t2.micro"
#    availability_zone = "us-east-1b"
#    key_name = "newkey-e1"

## Network Interface for public server
#    network_interface {
#        network_interface_id = aws_network_interface.altschool-project-public-network-interface-2.id
#        device_index = 0
#    }
#}

resource "aws_instance" "altschool-project-private-server-1" {
    ami = "ami-0574da719dca65348"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    #associate_public_ip_address = false
    key_name = "newkey-e1"

## Network interface for private subnet 1
    network_interface {
        network_interface_id = aws_network_interface.altschool-project-private-network-interface-1.id
        device_index = 0
    }
    user_data = <<-EOF
                 #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install nginx -y
                sudo systemctl start nginx.service
                sudo systemctl enable nginx.service
                host=$(hostname)
                ip=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | cut -c 7-17)
                sudo chown -R $USER:$USER /var/www
                echo 'Hi! Abdul-Barri deployed this server. Host name / IP address for this server is '$host'' > /var/www/html/index.nginx-debian.html
                EOF
            
}

resource "aws_instance" "altschool-project-private-server-2" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    availability_zone = "us-east-1b"
    key_name = "newkey-e1"
#    associate_public_ip_address = false


    network_interface {
        network_interface_id = aws_network_interface.altschool-project-private-network-interface-2.id
        device_index = 0
    }
    user_data = <<-EOF
                 #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install nginx -y
                sudo systemctl start nginx.service
                sudo systemctl enable nginx.service
                host=$(hostname)
                ip=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | cut -c 7-17)
                sudo chown -R $USER:$USER /var/www
                echo 'Hi! Abdul-Barri deployed this server. Host name / IP address for this server is '$host'' > /var/www/html/index.nginx-debian.html
                EOF
}
#Create a Load balancer
resource "aws_lb" "altschool-project-lb" {
    name            = "altschoolproject-lb"
    internal        = false
    security_groups = [aws_security_group.altschool-project-sg.id]
    subnets         = [aws_subnet.altschool-project-public-subnet-1.id, aws_subnet.altschool-project-public-subnet-2.id]
    enable_deletion_protection = false
#    depends_on                 = [aws_autoscaling_group.terraform-auto-scaling-grp]
}



# Create a Listener for AltSchool LB
resource "aws_lb_listener" "altschool-project-lb-listener" {
   protocol = "HTTP"
   port = "80"
   load_balancer_arn = aws_lb.altschool-project-lb.arn

   default_action {
        target_group_arn = aws_lb_target_group.altschool-project-lb-tgp.arn
        type = "forward"
    }
}

# Create Target Group

resource "aws_lb_target_group" "altschool-project-lb-tgp" {
    name = "altschoolproject-lb-tgp"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.altschool-project-vpc.id

    
    health_check {
      path = "/"
      protocol = "HTTP"
      matcher = "200"
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
  }
} 


# Create a Load Balancer security group
resource "aws_security_group" "altschool-project-lb-sg" {
  name        = "altschool-project-lb-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.altschool-project-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Attach Target Group to Loadbalancer
resource "aws_lb_target_group_attachment" "altschool-project-tgp-attachment-1" {
    target_group_arn = aws_lb_target_group.altschool-project-lb-tgp.arn
    target_id = aws_instance.altschool-project-private-server-1.id
    port = 80
} 

resource "aws_lb_target_group_attachment" "altschool-project-tgp-attachment-2" {
    target_group_arn = aws_lb_target_group.altschool-project-lb-tgp.arn
    target_id = aws_instance.altschool-project-private-server-2.id
    port = 80
} 



# Create load balancer listener rule
resource "aws_lb_listener_rule" "altschool-lb-listener-rule" {
    listener_arn = aws_lb_listener.altschool-project-lb-listener.arn
    priority = 1

    action {
        type             = "forward"
        target_group_arn =  aws_lb_target_group.altschool-project-lb-tgp.arn
    }

    condition {
        path_pattern {
            values = ["/"]
        }
    }
}


