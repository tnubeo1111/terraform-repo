output "ec2-dev-public-ipv4" {
  value = aws_instance.ec2-dev-node-public.public_ip
}