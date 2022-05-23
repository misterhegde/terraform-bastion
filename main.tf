provider "aws"{
    region="us-east-1"
    access_key="AKIAYS65P3YUZIG63ZLU"
    secret_key="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"
}
variable vpc_cidr {
}
variable vpc_env_name {
}

variable subnet_cidr {
}

resource "aws_vpc" "dev-vpc"{
    cidr_block = var.vpc_cidr
    tags = {
        Name: "${var.vpc_env_name}-vpc"
    }
}

resource "aws_subnet" "dev-subnet-1"{
    vpc_id=aws_vpc.dev-vpc.id
    cidr_block = var.subnet_cidr
    availability_zone="us-east-1a"
    tags = {
        Name: "${var.vpc_env_name}-subnet"
    }
}

resource "aws_route_table" "dev-rtb"{
    vpc_id = aws_vpc.dev-vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev-igw.id

    }
    tags = {
        Name: "${var.vpc_env_name}-rtb"
    }


}

resource "aws_internet_gateway" "dev-igw"{
    vpc_id = aws_vpc.dev-vpc.id
     tags = {
        Name: "${var.vpc_env_name}-igw"
    }
}

resource "aws_route_table_association" "dev-rtb-association"{
    subnet_id = aws_subnet.dev-subnet-1.id
    route_table_id = aws_route_table.dev-rtb.id
}

resource "aws_security_group" "dev-sg"{
    vpc_id = aws_vpc.dev-vpc.id
    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name: "${var.vpc_env_name}-sg"

    }

}

data "aws_ami" "dev-ami" {
  most_recent      = true
  owners           = ["amazon"]
 
}

output "ami_id" {
  value       = data.aws_ami.dev-ami.id
 
}


  resource "aws_instance" "dev-instance"{
      ami = data.aws_ami.dev-ami.id
      instance_type = "t2.micro"
      subnet_id = aws_subnet.dev-subnet-1.id
      vpc_security_group_ids = [aws_security_group.dev-sg.id] 
      associate_public_ip_address = true

      tags = {
        Name: "${var.vpc_env_name}-ec2"

      }

  }

