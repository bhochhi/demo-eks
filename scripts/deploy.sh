#!/usr/bin/env bash
# deploy.sh — Build, push, and deploy the Hello World app to EKS
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
APP_DIR="$PROJECT_ROOT/app"

export AWS_PROFILE="dev"

echo "============================================"
echo "  🚀 EKS Hello World — Deploy"
echo "  📌 Using AWS profile: $AWS_PROFILE"
echo "============================================"

# --------------------------------------------------
# Step 1: Terraform init & apply (infra + ECR)
# --------------------------------------------------
echo ""
echo "▶ Step 1/3: Provisioning infrastructure with Terraform..."
echo "  (This takes ~15 minutes on first run for EKS)"
echo ""

cd "$TERRAFORM_DIR"
terraform init -upgrade
terraform apply -auto-approve

# --------------------------------------------------
# Step 2: Build & push Docker image to ECR
# --------------------------------------------------
echo ""
echo "▶ Step 2/3: Building and pushing Docker image..."
echo ""

ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -raw aws_region)
AWS_ACCOUNT_ID=$(echo "$ECR_URL" | cut -d'.' -f1)

# Login to ECR
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$ECR_URL"

# Build and push
cd "$APP_DIR"
docker build --platform linux/amd64 -t "${ECR_URL}:latest" .
docker push "${ECR_URL}:latest"

# --------------------------------------------------
# Step 3: Re-apply Terraform to pick up the new image
# --------------------------------------------------
echo ""
echo "▶ Step 3/3: Updating Kubernetes deployment..."
echo ""

cd "$TERRAFORM_DIR"

# Force the deployment to re-pull by using a unique tag
TIMESTAMP=$(date +%Y%m%d%H%M%S)
cd "$APP_DIR"
docker tag "${ECR_URL}:latest" "${ECR_URL}:${TIMESTAMP}"
docker push "${ECR_URL}:${TIMESTAMP}"

cd "$TERRAFORM_DIR"
terraform apply -auto-approve -var="app_image_tag=${TIMESTAMP}"

# --------------------------------------------------
# Done!
# --------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ Deployment complete!"
echo "============================================"
echo ""

# Update kubeconfig for kubectl access
EKS_CLUSTER=$(terraform output -raw eks_cluster_name)
aws eks update-kubeconfig --region "$AWS_REGION" --name "$EKS_CLUSTER"

echo "📍 ALB URL (may take 1-2 min to become active):"
terraform output alb_url
echo ""
echo "📍 Useful commands:"
echo "  kubectl get pods -n demo-eks"
echo "  kubectl get ingress -n demo-eks"
echo "  kubectl logs -n demo-eks -l app=demo-eks"
echo ""
