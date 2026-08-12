
output "ubuntu_ami_id" {
  value       = data.aws_ami.ubuntu.id
  description = "Ubuntu AMI ID"
}
