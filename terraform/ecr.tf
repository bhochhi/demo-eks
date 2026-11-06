# ---------- ECR Repository ----------

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Allow terraform destroy to delete images

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = local.tags
}
