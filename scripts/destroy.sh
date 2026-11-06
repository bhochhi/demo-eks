#!/usr/bin/env bash
# destroy.sh — Tear down ALL resources to stop all AWS costs
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")/terraform"

export AWS_PROFILE="dev"

echo "============================================"
echo "  💥 EKS Hello World — DESTROY"
echo "  📌 Using AWS profile: $AWS_PROFILE"
echo "============================================"
echo ""
echo "This will destroy ALL resources:"
echo "  - EKS cluster & node group"
echo "  - VPC, subnets, NAT gateway"
echo "  - ECR repository & images"
echo "  - ALB & load balancer controller"
echo "  - All Kubernetes resources"
echo ""

read -p "Are you sure? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "▶ Destroying all resources with Terraform..."
echo "  (This takes ~10-15 minutes)"
echo ""

cd "$TERRAFORM_DIR"
terraform init -upgrade
terraform destroy -auto-approve

echo ""
echo "============================================"
echo "  ✅ All resources destroyed!"
echo "  💰 No more AWS charges from this project."
echo "============================================"
echo ""
