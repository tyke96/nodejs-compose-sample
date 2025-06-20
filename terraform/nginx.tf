resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
        annotations = {
          "config.linkerd.io/proxy-cpu-limit" = "10m"
          "linkerd.io/inject" = "enabled"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "nginx"

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

          volume_mount {
            name       = "${kubernetes_config_map.nginx.metadata.0.name}" 
            mount_path = "/etc/nginx/conf.d/"
          }
        }
        volume {
          name = "${kubernetes_config_map.nginx.metadata.0.name}"
          config_map {
            name = "${kubernetes_config_map.nginx.metadata.0.name}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_config_map" "nginx" {
  metadata {
    name = "nginx-config"
  }

  data = {
    "default.conf" = "${file("nginx.conf")}"
  }
}
