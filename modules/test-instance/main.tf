data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "my_ip" {
  url = "https://ipinfo.io/ip"
}

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-test-sg"
  description = "Allow SSH and test traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "this" {
  count                  = length(var.subnet_ids)
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-test-${count.index + 1}"
  })
}

resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id          = try(var.subnet_ids[0], null)
  security_group_ids = [aws_security_group.this.id]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-instance-connect"
  })
}
