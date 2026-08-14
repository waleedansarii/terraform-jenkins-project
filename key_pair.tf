resource "aws_key_pair" "student-key" {
  key_name   = "student-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}
