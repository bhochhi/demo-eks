# Demo EKS — Hello World on AWS EKS

A minimal **FastAPI** "Hello World" application deployed to **AWS EKS** using **Terraform**.

## Architecture

- **App**: FastAPI (Python 3.12) with `GET /` → `{"message": "Hello World"}`
- **Infra**: VPC → EKS (1× t3.small) → ALB (internet-facing)
- **Registry**: AWS ECR (private)
- **IaC**: Terraform manages everything

📖 **Deep Dive**: See [infrastructure-deep-dive.md](infrastructure-deep-dive.md) for a detailed walkthrough comparing this demo to enterprise setups, explaining ArgoCD & GitOps, public vs. private subnets, and an inventory of every deployed AWS resource.

## Prerequisites

| Tool | Minimum Version |
|------|----------------|
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | v2 |
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | ≥ 1.5 |
| [Docker](https://docs.docker.com/get-docker/) | 20+ |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.28+ |

## Quick Start

### 1. Configure AWS Credentials

The project uses the **`dev`** AWS CLI profile. Set it up if you haven't already:

```bash
aws configure --profile dev
# Enter your Access Key, Secret Key, region (us-east-1), and output format
```

### 2. Deploy

```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```

This will:
1. Create VPC, EKS cluster, ECR, and ALB (~15 min on first run)
2. Build the Docker image and push to ECR
3. Deploy the app to Kubernetes via Terraform

### 3. Access the App

```bash
# Get the ALB URL
terraform -chdir=terraform output alb_url

# Test it
curl http://<ALB_URL>/

# FastAPI auto-docs
open http://<ALB_URL>/docs
```

### 4. Useful kubectl Commands

```bash
# Check pods
kubectl get pods -n demo-eks

# Check ingress / ALB
kubectl get ingress -n demo-eks

# View logs
kubectl logs -n demo-eks -l app=demo-eks

# Describe pod (troubleshooting)
kubectl describe pod -n demo-eks -l app=demo-eks
```

## 💥 Destroy Everything (Stop All Costs)

```bash
./scripts/destroy.sh
```

This tears down **all** AWS resources created by this project. No lingering charges.

## Cost Estimate

| Resource | Cost |
|----------|------|
| EKS control plane | ~$0.10/hr |
| t3.small node | ~$0.02/hr |
| NAT Gateway | ~$0.045/hr |
| ALB | ~$0.025/hr |
| **Total** | **~$0.19/hr ≈ $4.56/day** |

> ⚠️ **Don't forget to run `./scripts/destroy.sh` when you're done!**

## Project Structure

```
demo-eks/
├── app/
│   ├── main.py              # FastAPI application
│   ├── requirements.txt     # Python dependencies
│   └── Dockerfile           # Multi-stage Docker build
├── terraform/
│   ├── main.tf              # Providers & locals
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Outputs (ALB URL, ECR URI, etc.)
│   ├── vpc.tf               # VPC + subnets + NAT
│   ├── ecr.tf               # Container registry
│   ├── eks.tf               # EKS cluster + node group
│   ├── alb.tf               # AWS LB Controller (Helm)
│   └── k8s.tf               # Deployment + Service + Ingress
├── scripts/
│   ├── deploy.sh            # One-command deploy
│   └── destroy.sh           # One-command teardown
├── infrastructure-deep-dive.md # Enterprise vs demo, subnets, GitOps, full AWS resource inventory
└── README.md
```
