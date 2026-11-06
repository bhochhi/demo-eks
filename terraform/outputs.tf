output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "ecr_repository_url" {
  description = "ECR repository URL for the app image"
  value       = aws_ecr_repository.app.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_url" {
  description = "URL to access the Hello World app (may take a minute to provision)"
  value       = try("http://${kubernetes_ingress_v1.app.status[0].load_balancer[0].ingress[0].hostname}", "ALB not yet provisioned — run: kubectl get ingress -n ${var.project_name}")
}
