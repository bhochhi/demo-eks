# ---------- VPC via terraform-aws-modules ----------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  # Subnets
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  # NAT Gateway — single to save cost
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags required for AWS Load Balancer Controller auto-discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = 1
    "kubernetes.io/cluster/${var.project_name}-eks"  = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                = 1
    "kubernetes.io/cluster/${var.project_name}-eks"  = "shared"
  }

  tags = local.tags
}
