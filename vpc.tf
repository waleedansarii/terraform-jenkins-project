module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.VPC_NAME
  cidr = var.VPC_CIDR

  azs             = [var.Zone1, var.Zone2, var.Zone3]
  private_subnets = [var.PRIVATE_SUBNET_1, var.PRIVATE_SUBNET_2, var.PRIVATE_SUBNET_3]
  public_subnets  = [var.PUBLIC_SUBNET_1, var.PUBLIC_SUBNET_2, var.PUBLIC_SUBNET_3]

  enable_nat_gateway      = true
  enable_vpn_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true



  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
