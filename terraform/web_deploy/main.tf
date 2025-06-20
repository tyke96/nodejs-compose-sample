resource "kubernetes_deployment" "deploy" {
  metadata {
    name = "${var.deployment_name}"
    labels = {
      app = "nodejs-${var.deployment_name}"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "nodejs-${var.deployment_name}"
      }
    }

    template {
      metadata {
        labels = {
          app = "nodejs-${var.deployment_name}"
        }
        annotations = {
          "config.linkerd.io/proxy-cpu-limit" = "10m"
          "linkerd.io/inject" = "enabled"
        }
      }

      spec {
        container {
          image = "${var.image}"
          image_pull_policy = "Always"
          name  = "${var.deployment_name}"

          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name = "${var.deployment_name}"
  }
  spec {
    selector = {
      app = "nodejs-${var.deployment_name}"
    }

    port {
      port        = 5000
      target_port = 5000
    }

    type = "ClusterIP"
  }
}
