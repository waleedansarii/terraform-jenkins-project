# 1. Define the variable
variable "ssh_public_key" {
  description = "SSH public key injected from Jenkins credentials"
  type        = string
}

# 2. Use the variable in the resource
resource "aws_key_pair" "student-key" {
  key_name   = "student-key"
  public_key = var.ssh_public_key
}
