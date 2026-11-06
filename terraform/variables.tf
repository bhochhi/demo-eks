variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "demo-eks"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.small"
}

variable "node_desired_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "dev"
}

variable "app_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}
