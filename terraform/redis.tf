resource "kubernetes_pod" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
    annotations = {
      "config.linkerd.io/proxy-cpu-limit" = "10m"
      "linkerd.io/inject" = "enabled"
    }
  }

  spec {
    container {
      image = "redislabs/redismod"
      name  = "redis"

      port {
        container_port = 6379
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
  }

  spec {
    port {
      port        = 6379
      target_port = 6379
    }

    selector = {
      app = "redis"
    }

    type = "ClusterIP"
  }
}
