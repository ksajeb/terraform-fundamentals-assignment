output "instance_hostname" {
 description = "Private DNS name of the EC2 instance."
 value = aws_instance.my_ubuntu_2.private_dns
}

