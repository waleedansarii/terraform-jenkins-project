
output "ubuntu_ami_id" {
  value       = data.aws_ami.ubuntu.id
  description = "Ubuntu AMI ID"
}

output "ec2_public_ip" {
  description = "The public IP address of the provisioned EC2 instance"
  value       = aws_instance.tf-instance.public_ip
}
