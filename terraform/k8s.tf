# ---------- Kubernetes Resources ----------
# Deployment, Service, and Ingress for the FastAPI app.

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.project_name
  }

  depends_on = [module.eks]
}

# ---------- Deployment ----------

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.project_name}-app"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = var.project_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.project_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.project_name
        }
      }

      spec {
        container {
          name  = "app"
          image = "${aws_ecr_repository.app.repository_url}:${var.app_image_tag}"

          port {
            container_port = 8000
          }

          # Health checks
          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [module.eks]
}

# ---------- Service ----------

resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.project_name}-svc"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = var.project_name
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# ---------- Ingress (ALB) ----------

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.project_name}-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.lb_controller]
}
