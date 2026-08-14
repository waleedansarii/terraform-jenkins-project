terraform {
  backend "s3" {
    bucket       = "terraform-state-786"
    region       = "ap-south-2"
    key          = "terraform/state.tfstate"
    use_lockfile = true
  }
}
