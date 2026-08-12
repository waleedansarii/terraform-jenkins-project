resource "aws_s3_bucket" "tf-bucket" {
  bucket = "tf-bucket0000"

  tags = {
    Name        = "My Bucket"
    Environment = "Dev"
  }
}
