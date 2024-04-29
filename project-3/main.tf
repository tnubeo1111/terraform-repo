resource "aws_vpc" "vpc-ltt" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-dev-ltt"
  }
}

resource "aws_subnet" "sn-ltt-public-1" {
  vpc_id                  = aws_vpc.vpc-ltt.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "sn-dev-public-1"
  }
}

resource "aws_internet_gateway" "ltt-igw" {
  vpc_id = aws_vpc.vpc-ltt.id

  tags = {
    Name = "igw-dev-ltt"
  }
}

resource "aws_route_table" "rtb-ltt-public" {
  vpc_id = aws_vpc.vpc-ltt.id

  tags = {
    Name = "rtb-dev-ltt-public"
  }
}

resource "aws_route" "route-ltt-public" {
  route_table_id         = aws_route_table.rtb-ltt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ltt-igw.id

}

resource "aws_route_table_association" "sn-dev-public-1" {
  route_table_id = aws_route_table.rtb-ltt-public.id
  subnet_id      = aws_subnet.sn-ltt-public-1.id
}

resource "aws_security_group" "sg-dev-public" {
  name        = "dev-public-sg"
  description = "dev public security group"
  vpc_id      = aws_vpc.vpc-ltt.id

  ingress {
    description = "SSH"
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
    Name = "sg-dev-public"
  }
}

resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "ec2-dev-node-public" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ec2-ami.id
  subnet_id              = aws_subnet.sn-ltt-public-1.id
  vpc_security_group_ids = [aws_security_group.sg-dev-public.id]
  key_name               = aws_key_pair.ec2-key.id
  user_data = file("userdata.tpl")

  # ncrease volume size for EC2 to default 8

  # root_block_device {
  #   volume_size = 10
  # }

  tags = {
    Name = "ec2-dev-node-public"
  }
}