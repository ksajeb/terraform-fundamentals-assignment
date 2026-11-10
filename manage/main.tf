provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-20260320"]
  }
  owners = ["099720109477"]
}


resource "aws_instance" "my_ubuntu" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "learning-tf"
  }
}
