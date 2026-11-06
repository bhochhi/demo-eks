# ---------- EKS Cluster via terraform-aws-modules ----------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = var.eks_cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public endpoint for kubectl access (simple for demo)
  cluster_endpoint_public_access = true

  # Managed node group
  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = 1
      max_size       = 2
      desired_size   = var.node_desired_count

      # Use latest Amazon Linux 2023 EKS-optimised AMI
      ami_type = "AL2023_x86_64_STANDARD"
    }
  }

  # Allow the current caller (your IAM user/role) full cluster admin
  enable_cluster_creator_admin_permissions = true

  tags = local.tags
}
